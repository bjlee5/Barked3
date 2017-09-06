//
//  PostCell.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AudioToolbox
import UserNotifications
import SDWebImage

protocol CellSubclassDelegate: class {
    func buttonTapped(cell: PostCell)
}

protocol CommentsSubclassDelegate: class {
    func commentButtonTapped(cell: PostCell)
}

class PostCell: UITableViewCell {
    
    var delegate: CellSubclassDelegate?
    var commentsDelegate: CommentsSubclassDelegate?
    var post: Post!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var currentUsername: String!
    var currentUserPic: UIImage!
    var postKey: String = ""
    var selectedUID: String = ""
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var profilePic: BoarderedCircleImage!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var postPic: BoarderedSquareImage!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postUser: UILabel!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var bestShowPic: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bestShowPic.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
        let currentDate = NSDate()
        dateLabel.text = "\(currentDate)"
    }
    
    // Load Current User //
    
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
    
    // MARK: Configure Cell
    
    func configureCell(post: Post) {
        
//        if post.bestInShow == true {
//            bestShowPic.isHidden = false
//        } else {
//            bestShowPic.isHidden = true 
//        }
        
        self.post = post
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postText.text = post.caption
        self.likesNumber.text = "\(post.likes)"
        self.dateLabel.text = post.currentDate
        self.postKey = post.postKey
        self.selectedUID = post.uid
        
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.postUser.text = "\(post.postUser)"
            self.username.text = "\(post.postUser)"
        })
        
//        if img != nil {
//            self.postPic.image = img
//        } else {
//            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
//            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
//                if error != nil {
//                    print("BRIAN: Unable to download image from Firebase")
//                } else {
//                    print("Image downloaded successfully")
//                    if let imgData = data {
//                        
//                        if let img = UIImage(data: imgData) {
//                            self.postPic.image = img
//                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString!)
//                        }
//                    }
//                }
//            })
//        }
        

//        let otherRef = FIRStorage.storage().reference(forURL: post.profilePicURL)
//        otherRef.data(withMaxSize: 2 * 1024 * 1024, completion: { (imgData, error) in
//            if error == nil {
//                DispatchQueue.main.async {
//                    if let data = imgData {
//                        self.profilePic.image = UIImage(data: data)
//                    }
//                }
//            } else {
//                print(error!.localizedDescription)
//                print("WOOBLES: BIG TIME ERRORS")
//            }
//        })
    
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
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.downloadLikingUserPhoto()
                self.barkSoundEffect()
                self.playSound()
                self.likesImage.image = UIImage(named: "PawFilled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImage.image = UIImage(named: "Paw1")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    // MARK: Notifications Methods
    
    func scheduleNotifications() {
        
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
            let content = UNMutableNotificationContent()
            var badge = 0
            badge += 1
            content.body = "\(self.currentUsername!) liked your photo!"
            content.sound = UNNotificationSound.default()
            content.badge = badge as NSNumber
            
            let request = UNNotificationRequest(identifier: "likeNotification", content: content, trigger: trigger)
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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let result = formatter.string(from: date)
        return result
    }
    
    func likeNotification(imgURL: String) {
        loadUserInfo()
        scheduleNotifications()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let notification: Dictionary<String, Any> = [
            "comment": "\(currentUsername!) liked your photo!",
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
    
    // MARK: Actions
    
    @IBAction func userPressed(_ sender: Any) {
    self.delegate?.buttonTapped(cell: self)
    }

    @IBAction func commentPressed(_ sender: Any) {
        self.commentsDelegate?.commentButtonTapped(cell: self)
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

extension PostCell: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
