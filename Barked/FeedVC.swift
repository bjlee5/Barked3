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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CellSubclassDelegate, CommentsSubclassDelegate {
    
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedController.selectedSegmentIndex = 0
        tableView.reloadData()
        
        // Observer to Update "Likes" in Realtime
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.tableView.reloadData()
        })
        
        // Coded Label
        
        codedLabel.isHidden = true
        codedLabel.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        codedLabel.textAlignment = .center
        codedLabel.text = "There are no posts today"
        codedLabel.numberOfLines=1
        codedLabel.textColor=UIColor.gray
        codedLabel.font=UIFont.systemFont(ofSize: 16)

        view.addSubview(codedLabel)
        codedLabel.translatesAutoresizingMaskIntoConstraints = false
        codedLabel.centerXAnchor.constraint(equalTo: codedLabel.superview!.centerXAnchor).isActive = true
        codedLabel.centerYAnchor.constraint(equalTo: codedLabel.superview!.centerYAnchor).isActive = true
        
        
        // Other Label
        
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
        
        profilePic.isHidden = true
        currentUser.isHidden = true
        
        followingFriends()
        loadUserInfo()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets.zero
        
        
        // Dismiss Keyboard //
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
        // End ViewDidLoad
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        indicator.startAnimating()
        segmentedController.selectedSegmentIndex = 0
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        segmentedController.selectedSegmentIndex = 0
        tableView.reloadData()
    }
    
//    func stopShowingIndicator() {
//        showSubviews()
//        indicator.stopAnimating()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//    func createIndicator() {
//        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
//        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//        indicator.center = self.view.center
//        self.view.addSubview(indicator)
//        indicator.bringSubview(toFront: view)
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    //Show all subviews but indicator
//    func showSubviews() {
//        for view in self.view.subviews {
//            if view != indicator {
//                view.isHidden = false
//            }
//        }
//    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Best in Show
    
    func bestInShow() {
        let mostLikes = testPosts.map { $0.likes }.max()
        for post in testPosts {
            if post.likes >= mostLikes! {
                let topPost = post

                DataService.ds.REF_POSTS.child(topPost.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    topPost.adjustBestInShow(addBest: true)
                    print("WOOBLES - Best in show exceuted")
                    
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
                        print("WOOBLES - Worst in show executed")
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
    
    /// Sort Feed of Posts by Amount of Likes
    func sortLikesFor(this: Post, that: Post) -> Bool {
        return this.likes > that.likes
    }
    
    // Show Current User Feed
    
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
            self.tableView.reloadData()
        })
    }
    
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    
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
        }
    })
}
    
    func test() {
        let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
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
        
//        tableView.reloadData()
    }
    
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        switch (segmentedController.selectedSegmentIndex) {
        case 0:
            print("DYEUCK - numbers of rows in section case 0")
            returnValue = posts.count
            break
        case 1:
            print("DYEUCK - numbers of rows in section case 1")
            returnValue = testPosts.count
            break
        default:
            print("DYEUCK - return 0")
            returnValue = 0
            break
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var post: Post!
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell {
            cell.delegate = self
            cell.commentsDelegate = self
            
            switch (segmentedController.selectedSegmentIndex) {
            case 0:
                print("DYEUCK - tableView case 0")
                posts.sort(by: self.sortDatesFor)
                post = posts[indexPath.row]
            case 1:
                print("DYEUCK - tableView case 1")
                testPosts.sort(by: self.sortLikesFor)
                post = testPosts[indexPath.row]
            default:
                print("DYEUCK - tableView case default")
                posts.sort(by: self.sortDatesFor)
                post = posts[indexPath.row]
                break
            }
            
            if post.bestInShow == true {
                cell.bestShowPic.isHidden = false
            } else {
                cell.bestShowPic.isHidden = true
            }

            // Cell Styling
            
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString!) {
                cell.configureCell(post: post, img: img)
            } else {
            cell.configureCell(post: post)
        }
            self.bestInShow()
            self.worstInShow()
            return cell
        } else {
            return PostCell()
        }
    
}
    
    // MARK: - Helper Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FriendProfileVC" {
            print("LEEZUS: Segway to FriendsVC performed!!")
            let destinationViewController = segue.destination as! FriendProfileVC
            destinationViewController.selectedUID = selectedUID
        } else if segue.identifier == "CommentsVC" {
            let destinationViewController = segue.destination as! CommentsVC
            destinationViewController.selectedPost = selectedPost
        }
    }
        
    func buttonTapped(cell: PostCell) {
        var clickedUser = ""
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        switch(self.segmentedController.selectedSegmentIndex) {
        case 0: clickedUser = posts[indexPath.row].uid
        case 1: clickedUser = testPosts[indexPath.row].uid
        default: clickedUser = posts[indexPath.row].uid
        }

        DataService.ds.REF_BASE.child("users/\(clickedUser)").observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.selectedUID = user.uid
            self.checkSelectedUID()
    })
}
    
    func commentButtonTapped(cell: PostCell) {
    var clickedPost: Post!
    guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        switch(self.segmentedController.selectedSegmentIndex) {
        case 0: clickedPost = posts[indexPath.row]
        case 1: clickedPost = testPosts[indexPath.row]
        default: clickedPost = posts[indexPath.row]
        }
        selectedPost = clickedPost
        self.checkSelectedPost()
    }
    
    func checkSelectedPost() {
        performSegue(withIdentifier: "CommentsVC", sender: self)
    }
    
    func checkSelectedUID() {
        print("LEEZUS: We're checking the selected UID")
        if selectedUID == FIRAuth.auth()?.currentUser?.uid {
            performSegue(withIdentifier: "MyProfileVC", sender: self)
        } else if selectedUID != "" {
            performSegue(withIdentifier: "FriendProfileVC", sender: self)
        }
    }
    
    // MARK: - Actions

    @IBAction func profileBtn(_ sender: Any) {
        performSegue(withIdentifier: "MyProfileVC", sender: self)
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
    
    @IBAction func segmentedPress(_ sender: Any) {
        tableView.reloadData()
        switch(self.segmentedController.selectedSegmentIndex) {
        case 0:
            print("DYEUCK - case 0 is selected")
            codedLabel.isHidden = true
            if posts.count <= 0 {
                otherLabel.isHidden = false }
            
        case 1:
            print("DYEUCK - case 1 is selected")
            if testPosts.count <= 0 {
                codedLabel.isHidden = false }
            otherLabel.isHidden = true
        default:
            codedLabel.isHidden = true
            otherLabel.isHidden = true
        }
    }
}
