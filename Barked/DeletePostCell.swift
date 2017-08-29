//
//  DeletePostCell.swift
//  Barked
//
//  Created by MacBook Air on 5/5/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AudioToolbox
import UserNotifications

protocol MyCommentSubclassDelegate: class {
    func commentButtonTapped(cell: DeletePostCell)
}

class DeletePostCell: UITableViewCell {
    
    var post: Post!
    var myCommentsDelegate: MyCommentSubclassDelegate?
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var currentUsername: String!
    var currentUserPic: UIImage!
    var postKey: String = ""
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postUser: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
    }
    
    /// Retrieves Current Users Information
    func loadUserInfo() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUsername = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.currentUserPic = UIImage(data: data)
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func configureCell(post: Post) {
        
        self.post = post 
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postCaption.text = post.caption
        self.postLikes.text = "\(post.likes)"
        self.postDate.text = post.currentDate
        self.postKey = post.postKey
        
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.postUser.text = "\(post.postUser)"
        })

        let ref = FIRStorage.storage().reference(forURL: post.imageURL)
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.postImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
                print("WOOBLES: BIG TIME ERRORS")
            }
        })
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = UIImage(named: "Paw1")
            } else {
                self.likesImage.image = UIImage(named: "PawFilled")
            }
        })
    }
    
    func likesTapped(sender: UIGestureRecognizer) {
        loadUserInfo()
        if post.uid == FIRAuth.auth()?.currentUser?.uid {
        } else {
            // Do nothing
        }
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.downloadLikingUserPhoto()
                self.likesImage.image = UIImage(named: "PawFilled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                self.barkSoundEffect()
                self.playSound()
            } else {
                self.likesImage.image = UIImage(named: "Paw1")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    // MARK: - Push Notifications
    
    func scheduleNotifications() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let notifyingUser = String(user.username)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
            let content = UNMutableNotificationContent()
            content.body = "\(self.currentUsername!) likes your photo!"
            content.sound = UNNotificationSound.default()
            content.badge = NOTE_BADGE_NUMBER as NSNumber! 
            
            let request = UNNotificationRequest(identifier: "commentNotification", content: content, trigger: trigger)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { (error: Error?) in
                if let error = error {
                    print("Error is \(error.localizedDescription)")
                    
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // Retrieve the Current Date //
    
    func formatDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    
    func likeNotification(imgURL: String) {
        
        scheduleNotifications()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let notification: Dictionary<String, Any> = [
            "comment": "\(currentUsername!) likes your photo!",
            "photoURL": imgURL,
            "read": false,
            "uid": uid!,
            "username": "\(currentUsername!)",
            "currentDate": formatDate(),
            "identifier": "\(postKey)",
            "type": notificationType.like.rawValue
        ]
        
        let firebaseNotify = DataService.ds.REF_USERS.child(self.post.uid).child("notifications").childByAutoId()
        firebaseNotify.setValue(notification)
        
    }
    
    func downloadLikingUserPhoto() {
        loadUserInfo()
        guard let proImg = currentUserPic else {
            print("BRIAN: The user has no profile pic!")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(proImg, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metdata, error) in
                if error != nil {
                    print("BRIAN: Unable to upload image to Firebase storage")
                } else {
                    print("BRIAN: Successfully printed image to Firebase")
                    let downloadURL = metdata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.likeNotification(imgURL: url)
                    }
                }
                
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func commentPressed(_ sender: Any) {
         self.myCommentsDelegate?.commentButtonTapped(cell: self)
    }
    
    // Play Sounds
    
    var gameSound: SystemSoundID = 0
    
    func barkSoundEffect() {
        let path = Bundle.main.path(forResource: "Woof", ofType: "mp3")!
        let soundURL = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}


