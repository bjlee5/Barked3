//
//  BestInShowVC.swift
//  Barked
//
//  Created by MacBook Air on 7/31/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import Foundation
import UserNotifications

class BestInShowVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    // Refactor this storage ref using DataService //
    
    var posts = [Post]()
    var testPosts = [Post]()
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
    
    var leaders = [Leaderboard]()
    var filteredUsers = [Leaderboard]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    //    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.posts.sort(by: self.sortDatesFor)
        followingFriends()
        loadUserInfo()
        fetchPosts()
        retrieveUser()
//        updateRank()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        
        /////////////// Layout /////////////////
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        layout.itemSize = CGSize(width: screenWidth/4, height: screenWidth/4)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView!.collectionViewLayout = layout
        
        profilePic.isHidden = true
        currentUser.isHidden = true

    }
    
    // End ViewDidLoad
    
    // MARK: - Best in Show
    
    func bestInShow() {
        let mostLikes = testPosts.map { $0.likes }.max()
        for post in testPosts {
            if post.likes >= mostLikes! {
                let topPost = post
                
                DataService.ds.REF_POSTS.child(topPost.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    topPost.adjustBestInShow(addBest: true)
                })
                
            }
        }
    }
    
    func worstInShow() {
        let mostLikes = testPosts.map { $0.likes }.max()
        for post in testPosts {
            if post.likes < mostLikes! {
                let otherPosts = post
                DataService.ds.REF_POSTS.child(otherPosts.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    otherPosts.adjustBestInShow(addBest: false)
                })
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
                            print("BRIAN: You are following these users \(self.following)")
                            
                        }
                    })
                }
            }
            
            self.fetchPosts()
            self.test()
        })
    }
    
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print("POST: \(postDict)")
                        if let bestPosts = postDict["bestInShow"] as? Bool {
                            if bestPosts == true {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)
                                
                                
                            }
                        }
                    }
                }
                
                self.collectionView.reloadData()
                self.posts.sort(by: self.sortDatesFor)
            }
        })
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
        
        collectionView.reloadData()
    }
    
    func retrieveUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.leaders.removeAll()
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    let userToShow = Leaderboard()
                    if let username = value["username"] as? String {
                        if let breed = value["breed"] as? String {
                            if let winCount = value["winCount"] as? Int {
                                let imagePath = value["photoURL"] as? String
                                
                                userToShow.username = username
                                userToShow.imagePath = imagePath
                                userToShow.breed = breed
                                userToShow.winCount = winCount
                                userToShow.userID = uid
                                self.leaders.append(userToShow)
                                
                            }
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
        ref.removeAllObservers()
        
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.leaders.sort(by: self.sortRankFor)
        let someLeader: Leaderboard
        someLeader = leaders[indexPath.row]
        
        let someUID = someLeader.userID
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as? LeaderboardCell {
            cell.configure(leader: someLeader, indexPath: someUID!, rank: indexPath.row)
            return cell
        } else {
            return LeaderboardCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var clickedUser = leaders[indexPath.row].userID
        self.selectedUID = clickedUser!
        self.checkSelectedUID()
        print("Your selectedUID is - \(selectedUID)")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    // MARK: Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfCell", for: indexPath) as? ProfileCell {
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.white.cgColor
            //            cell.frame.size.width = screenWidth / 4
            //            cell.frame.size.height = screenWidth / 4
            cell.configureCell(post: post)
            return cell
        } else {
            
            return ProfileCell()
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCell
        selectedPost = cell.post
        print("SNOOPY: \(selectedPost)")
        performSegue(withIdentifier: "FriendPostVC", sender: self)
    }
    
    // MARK: Helper Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FriendPostVC" {
            print("LEEZUS: Segway to DeletePost is performed!")
            let destinationViewController = segue.destination as! FriendPostVC
            destinationViewController.selectedPost = selectedPost
        }
    }
    
//    func updateRank() {
//        for leader in leaders {
//            print("LEEZUS - update rank is being run")
//            let userRef = DataService.ds.REF_USERS.child(leader.userID)
//            var rank: Int
//            var bestInShowAmount = [Post]()
//            DataService.ds.REF_POSTS.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
//                bestInShowAmount = []
//                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                    for snap in snapshot {
//                        
//                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                            print("LEEZUS - post Dict is running")
//                            if let userRank = postDict["bestInShow"] as? Bool {
//                                if userRank == true {
//                                    print("LEEZUS - userRank is updating")
//                                    let key = snap.key
//                                    let post = Post(postKey: key, postData: postDict)
//                                    bestInShowAmount.append(post)
//                                    
//                                }
//                            }
//                        }
//                    }
//                }
//            })
//            
//            rank = bestInShowAmount.count
//            userRef.child("rank").setValue(rank)
//            
//        }
//    }
    
    func sortRankFor(this: Leaderboard, that: Leaderboard) -> Bool {
        if that.winCount == nil {
            that.winCount = 0
        }
        if this.winCount == nil {
            this.winCount = 0
        }
        return this.winCount > that.winCount
    }
    
    /// Search Functionality
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = leaders.filter { user in
            return user.username.lowercased().contains(searchText.lowercased()) || user.breed.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
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
            content.badge = 1 
            
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
    
    // MARK: - Actions
    
    @IBAction func listBtnPress(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaderboardVC")
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


extension BestInShowVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

extension BestInShowVC: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

