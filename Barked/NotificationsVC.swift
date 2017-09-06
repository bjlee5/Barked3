//
//  NotificationsVC.swift
//  Barked
//
//  Created by MacBook Air on 8/1/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notifications = [Notification]()
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var likesRef: FIRDatabaseReference!
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var selectedUID: String = ""
    var selectedPost: Post!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.items?[3].badgeValue = nil
        fetchNotifications()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tabBarController?.tabBar.items?[3].badgeValue = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        updateNotes()
    }
    
    func fetchNotifications() {
        DataService.ds.REF_CURRENT_USERS.child("notifications").observe(.value, with: { (snapshot) in
            self.notifications = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let noteDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let note = Notification(notificationKey: key, noteData: noteDict)
                        self.notifications.append(note)
                    }
                }
                self.notifications.sort(by: self.sortDatesFor)
                self.tableView.reloadData()
            }
        })
        
    }
    
    // MARK: TableView 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.notificationLabel.text = notifications[indexPath.row].comment
            if notification.read == false {
                cell.unreadImage.isHidden = false
            } else {
                cell.unreadImage.isHidden = true
        }
        cell.userImage.sd_setImage(with: URL(string: notifications[indexPath.row].photoURL))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var uidToPass: String = ""
        let noteType = notifications[indexPath.row].type
        if noteType == "follow" {
        uidToPass = notifications[indexPath.row].identifier
        selectedUID = uidToPass
        if selectedUID != "" {
            checkSelectedUID()
            }
        } else if noteType == "like" {
            uidToPass = notifications[indexPath.row].identifier
            formatWithPostKey(postKey: uidToPass, type: .like)
        } else if noteType == "comment" {
            uidToPass = notifications[indexPath.row].identifier
            formatWithPostKey(postKey: uidToPass, type: .comment)
        }
    }
    
    // MARK: Helper Functions
    
    /// Segues to "Follow" notification details
    func checkSelectedUID() {
        if selectedUID == FIRAuth.auth()?.currentUser?.uid {
            let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyProfileVC")
            self.present(profileVC, animated: true, completion: nil)
        } else if selectedUID != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            vc.selectedUID = selectedUID
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    /// Segues to "Like" notification details
    func formatWithPostKey(postKey: String, type: notificationType) {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    let snapKey = snap.key
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            if snapKey == postKey {
                                
                                let post = Post(postKey: snapKey, postData: postDict)
                                self.selectedPost = post
                                
                                if type == .like {
                                self.passSelectedPost()
                                
                                } else if type == .comment {
                                    self.passSelectedComment()
                                            }
                                        }
                                    }
                                }
                            }
                        })
                    }
    
    
    func passSelectedPost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FriendPostVC") as! FriendPostVC
        vc.selectedPost = selectedPost
        self.present(vc, animated: true, completion: nil)
    }
    
    func passSelectedComment() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.selectedPost = selectedPost
        self.present(vc, animated: true, completion: nil)
    }
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Notification, that: Notification) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    func updateNotes() {
        for note in notifications {
            let updatedNote = note
            DataService.ds.REF_CURRENT_USERS.child(note.notificationKey).observeSingleEvent(of: .value, with: { (snapshot) in
                updatedNote.adjustNotifications(read: true)
            })
        }
    }
}
