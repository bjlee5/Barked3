//
//  CommentsVC.swift
//  Barked
//
//  Created by MacBook Air on 6/6/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import UserNotifications

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var selectedPost: Post!
    var comments = [Comment]()
    var comment: Comment!
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var likesRef: FIRDatabaseReference!
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var indicator = UIActivityIndicatorView()
    var isExpandable = false
    var selectedIndex: IndexPath?
    
    @IBOutlet weak var addCommentField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserProPic: UIImageView!
    @IBOutlet weak var currentUsername: UILabel!
    @IBOutlet weak var myPic: UIImageView!
    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var myComment: UILabel!
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nib = UINib.init(nibName: "CommentsCell", bundle: nil)
//        self.tableView.register(nib, forCellReuseIdentifier: "CommentsCell")
//
        print("WOOBLES - \(userRef.child("username"))")
        
//        tableView.backgroundView = UIImageView(image: UIImage(named: "FFBackground"))
        
        currentUserProPic.isHidden = true
        currentUsername.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadMyComment()
        loadUserInfo()
        fetchComments()
    }
    
    // MARK: - Notifications
    
    func scheduleNotifications() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let notifyingUser = String(user.username)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
                let content = UNMutableNotificationContent()
                content.body = "\(self.currentUsername.text!) commented on your photo!"
                content.sound = UNNotificationSound.default()
                content.badge = NOTE_BADGE_NUMBER as! NSNumber
                
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
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let result = formatter.string(from: date)
        return result
    }
    
    func commentNotification(imgURL: String) {
        
            scheduleNotifications()
            let uid = FIRAuth.auth()?.currentUser?.uid
        
            let notification: Dictionary<String, Any> = [
                "comment": "\(self.currentUsername.text!) has commented on your photo!",
                "photoURL": imgURL,
                "read": false,
                "uid": uid!,
                "username": "\(self.currentUsername.text!)",
                "currentDate": formatDate(),
                "identifier": selectedPost.postKey,
                "type": notificationType.comment.rawValue
                ]
        
        let firebaseNotify = DataService.ds.REF_USERS.child(self.selectedPost.uid).child("notifications").childByAutoId()
        firebaseNotify.setValue(notification)
    }
    
    // MARK: - Activity Indicator
    
    func startIndicator() {
        hideSubviews()
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(indicator)
        
        indicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopIndicator() {
        showSubviews()
        indicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //Hide all subviews but indicator
    func hideSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.alpha = 0.25
            }
        }
    }
    
    //Show all subviews but indicator
    func showSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.alpha = 1.0 
            }
        }
    }
    
    func loadMyComment() {
        myUsername.text = selectedPost.postUser
        myComment.text = selectedPost.caption
        myPic.sd_setImage(with: URL(string: selectedPost.profilePicURL))
    }
    
    func loadUserInfo() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUsername.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.currentUserProPic.image = UIImage(data: data)
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
    
    func fetchComments() {
        DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").observe(.value, with: { (snapshot) in
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let comDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let postKey = self.selectedPost.postKey
                        let key = snap.key
                        let comment = Comment(postKey: postKey, commentKey: key, postData: comDict)
                        self.comments.append(comment)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
        
    }
    
    func delete(commentKey: String) {
        
        // Remove the post from the DB
        DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").child(commentKey).removeValue { error in
            if error != nil {
                print("error \(error)")
            }
        }
        
        self.tableView.reloadData()
    }
    
    func didExpandCell() {
        self.isExpandable != isExpandable
        self.tableView.reloadRows(at: [selectedIndex!], with: .automatic)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath) as! CommentsCell
        
        let comment = comments[indexPath.row]
//        cell.commentDelegate = self
        cell.configureCommentLikes(comment: comment, selectedPostKey: selectedPost.postKey, currentCommentKey: comment.commentKey)
        cell.usernameField.text = comments[indexPath.row].postUser
        cell.usernameField.numberOfLines = 0
        cell.commentField.text = comments[indexPath.row].caption
        cell.commentDate.text = comments[indexPath.row].currentDate
        cell.profilePicImage.sd_setImage(with: URL(string: comments[indexPath.row].profilePicURL))
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()

        
//        FIRStorage.storage().reference(forURL: comments[indexPath.row].profilePicURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
//            if error == nil {
//                DispatchQueue.main.async {
//                    if let data = imgData {
//                        cell.profilePicImage.image = UIImage(data: data)
//                    }
//                }
//            } else {
//                print(error!.localizedDescription)
//            }
//        })
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(commentKey: comments[indexPath.row].commentKey)
            comments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if selectedPost.uid == FIRAuth.auth()?.currentUser?.uid || comments[indexPath.row].uid == FIRAuth.auth()?.currentUser?.uid {
            
            return UITableViewCellEditingStyle.delete
            
        }
        return UITableViewCellEditingStyle.none
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndex = indexPath
        self.didExpandCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpandable && self.selectedIndex == indexPath {
            return 200
        }
        return 100
    }

    
    @IBAction func addCommentPressed(_ sender: Any) {
    
        guard let caption = addCommentField.text, caption != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a caption!")
            return
        }
        
        guard let proImg = currentUserProPic.image else {
            print("BRIAN: The user has no profile pic!")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(proImg, 0.2) {
            
            startIndicator()
            
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
                        self.postToFirebase(imgUrl: url)
                        self.commentNotification(imgURL: url)
                    }
                }
            }
        }
    }
    
    // Retrieve the Current Date //
    
    let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    
    // Posting to Firebase //
    
    func postToFirebase(imgUrl: String) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let comment: Dictionary<String, Any> = [
            "caption": addCommentField.text!,
            "postUser": currentUsername.text!,
            "profilePicURL": imgUrl,
            "currentDate": realDate,
            "uid": uid!,
            "likes": 0
        ]

            if self.selectedPost.uid == uid! {
                print("VROOM - Notifications scheduled!!!")
//                self.scheduleNotifications(username: currentUsername.text!)
            } else {
                print("VROOM - Dog, this is your post...")
            }
        
        let firebasePost = DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").childByAutoId()
        firebasePost.setValue(comment)
        
        stopIndicator()
        addCommentField.text = ""
        
    }
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CommentsVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

