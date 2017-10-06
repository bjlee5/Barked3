//
//  FeedVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Foundation
import UserNotifications
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CellSubclassDelegate, CommentsSubclassDelegate {
    
    // Refactor this storage ref using DataService //
    
    var posts = [Post]()
    var testPosts = [Post]()
    var users = [Friend]()
    var bestInShowDict = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var profilePicLoaded = false 
    var following = [String]()
    /// Referencing the Storage DB then, current User
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var selectedUID: String = ""
    var selectedPost: Post!
    let codedLabel:UILabel = UILabel()
    let otherLabel:UILabel = UILabel()
    var indicator = UIActivityIndicatorView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkNotificationsRead()
        startIndicator()
        retrieveUser()
        self.posts.sort(by: self.sortDatesFor)
        followingFriends()
        loadUserInfo()
        fetchPosts()
        
        otherLabel.isHidden = true
        otherLabel.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        otherLabel.textAlignment = .center
        otherLabel.text = "You are not following anyone"
        otherLabel.numberOfLines=1
        otherLabel.textColor=UIColor.gray
        otherLabel.font=UIFont.systemFont(ofSize: 16)
        
        view.addSubview(otherLabel)
        otherLabel.translatesAutoresizingMaskIntoConstraints = false
        otherLabel.centerXAnchor.constraint(equalTo: otherLabel.superview!.centerXAnchor).isActive = true
        otherLabel.centerYAnchor.constraint(equalTo: otherLabel.superview!.centerYAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        profilePic.isHidden = true
        currentUser.isHidden = true
        
        // Observer to Update "Likes" in Realtime
        tableView.reloadData()
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    // MARK: - Activity Indicator
    
    func startIndicator() {
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(indicator)
        
        indicator.startAnimating()
//        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopIndicator() {
        indicator.stopAnimating()
//        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // MARK: - Best in Show
    
    func bestInShow() {
        DispatchQueue.global().async {
        let mostLikes = self.testPosts.map { $0.likes }.max()
        for post in self.testPosts {
            if post.likes >= mostLikes! {
                let topPost = post

                DataService.ds.REF_POSTS.child(topPost.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    topPost.adjustBestInShow(addBest: true)
                    
                    })
                
                }
            }
        }
    }
                
    func worstInShow() {
        DispatchQueue.global().async {
        let mostLikes = self.testPosts.map { $0.likes }.max()
        for post in self.testPosts {
                if post.likes < mostLikes! {
                    let otherPosts = post
                    DataService.ds.REF_POSTS.child(otherPosts.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        otherPosts.adjustBestInShow(addBest: false)
                        })
                    }
            
                }
            }
        }
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUser.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                            self.profilePicLoaded = true
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
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Post, that: Post) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    /// Sort Feed of Posts by Amount of Likes
    func sortLikesFor(this: Post, that: Post) -> Bool {
        return this.likes > that.likes
    }
    
    // Show Current User Feed //
    
    func followingFriends() {
        
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            
            for (_, value) in users {
                if let uName = value["username"] as? String {
                    self.userRef.observe(.value, with: { (snapshot) in
                        
                        let myUser = Users(snapshot: snapshot)
                        
                        if uName == myUser.username {
                            if let followingUsers = value["following"] as? [String: String] {
                                for (_, user) in followingUsers {
                                    self.following.append(user)
                                    
                                }
                            }
                            
                            self.following.append((FIRAuth.auth()?.currentUser?.uid)!)
                            
                        }
                    })
                }
            }
            
            self.fetchPosts()
            self.test()
        })
    }
    
    func fetchPosts() {
        DataService.ds.REF_POSTS.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if self.following.contains(postUser) {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)
                                
                                
                            }
                        }
                    }
                }
                self.tableView.reloadData()
                self.posts.sort(by: self.sortDatesFor)
            }
        })
    }
    
    /// Creating value for "Rank" - number of "Best-In-Shows" each user was been awarded
    func updateRank() {
        if posts.count <= 0 {
            stopIndicator()
            otherLabel.isHidden = false
            print("LEEZUS: Your label function is being executed")
        } else {
        DispatchQueue.global().async {
        for user in self.users {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.bestInShowDict = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if postUser == user.userID {
                                if let bestInShow = postDict["bestInShow"] as? Bool {
                                    if bestInShow == true {
                                        
                                        let bestKey = snap.key
                                        let bestPost = Post(postKey: bestKey, postData: postDict)
                                        self.bestInShowDict.append(bestPost)
                                        let rank = self.bestInShowDict.count
                                        DataService.ds.REF_USERS.child(user.userID).child("rank").setValue(rank)
                                        print("LEEZUS: Ranks have been updated")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
            }
        }
    }
}
    
    func retrieveUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                        let userToShow = Friend()
                        if let username = value["username"] as? String {
                            
                            userToShow.username = username
                            userToShow.userID = uid
                            self.users.append(userToShow)
                            self.updateRank()
                        }
                    }
                }
            }

        })
        
        ref.removeAllObservers()
        
    }
    
    func test() {
        let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.medium, timeStyle: DateFormatter.Style.none)
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.testPosts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let posted = Post(postKey: key, postData: postDict)
                        
                        if posted.currentDate == realDate {
                            self.testPosts.append(posted)
                        }
                        
                    }
                }
            }
        })
        
        tableView.reloadData()
    }
    
    // User Feed //
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            
            cell.delegate = self
            cell.commentsDelegate = self
            
            if post.bestInShow == true {
                cell.bestShowPic.isHidden = false
            } else {
                cell.bestShowPic.isHidden = true
            }
            
            cell.postPic.sd_setImage(with: URL(string: post.imageURL))
            cell.profilePic.sd_setImage(with: URL(string: post.profilePicURL))
            
//            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!) {
//                                cell.configureCell(post: post, img: img)
//                            } else {
//                
//            }
            self.stopIndicator()
            otherLabel.isHidden = true
            cell.configureCell(post: post)
            self.bestInShow()
            self.worstInShow()
            return cell
        } else {
            return PostCell()
            
        }
    }
    
    // MARK: - Helper Methods
    
    func formatDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func buttonTapped(cell: PostCell) {
        var clickedUser = ""
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        clickedUser = posts[indexPath.row].uid

        DataService.ds.REF_BASE.child("users/\(clickedUser)").observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.selectedUID = user.uid
            self.checkSelectedUID()
    })
}
    
    func commentButtonTapped(cell: PostCell) {
    var clickedPost: Post!
    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        clickedPost = posts[indexPath.row]
        selectedPost = clickedPost
        self.checkSelectedPost()
    }
    
    func checkSelectedPost() {
        print("BRIAN - Comments VC push")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentsVC") as! CommentsVC
        vc.selectedPost = selectedPost
        self.present(vc, animated: true, completion: nil)
    }
    
    func checkSelectedUID() {
        if selectedUID == FIRAuth.auth()?.currentUser?.uid {
            print("BRIAN - Selected UID is your own")
            let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyProfileVC")
            self.present(profileVC, animated: true, completion: nil)
        } else if selectedUID != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            vc.selectedUID = selectedUID
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func scheduleNotifications() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let notifyingUser = String(user.username)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
            let content = UNMutableNotificationContent()
            content.body = "You're currently today's best in show!"
            content.sound = UNNotificationSound.default()
            content.badge = NOTE_BADGE_NUMBER as NSNumber

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
    
    ///Check if notifications have been read 
    func checkNotificationsRead() {
            DataService.ds.REF_CURRENT_USERS.child("notifications").observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    for snap in snapshot {
                        print("SNAP: \(snap)")
                        
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            if let postUser = postDict["read"] as? Bool {
                                print("DYEUCK: \(postUser)")
                                if postUser == false {
                                self.tabBarController?.tabBar.items?[3].badgeValue = "1"
                            }
                        }
                    }
                }
            }
        })
    }
    
    // MARK: - Actions

    @IBAction func profileBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyProfileVC")
        self.present(vc, animated: true, completion: nil)
    }

    // Logging Out //
    
    @IBAction func signOutPress(_ sender: Any) {
    
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            
            // This code causes view stacking (potentially memory leaks), but cannot figure out a better way to get to LogInVC and clear the log in text //
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
            self.present(vc, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}

extension FeedVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
