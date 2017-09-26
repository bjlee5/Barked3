//
//  ProfileVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SCLAlertView

class MyProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Refactor storage reference //
    
    var selectedPost: Post!
    var posts = [Post]()
    var bestInShowArray = [Post]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var profilePicLoaded = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    let ref = FIRDatabase.database().reference()
    var bestInShowAmount = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // For Layout
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var myFollowersAmount: UILabel!
    @IBOutlet weak var myPostsAmount: UILabel!
    @IBOutlet weak var followingAmount: UILabel!
    @IBOutlet weak var bestInShowImage: UIImageView!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var editBtn: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button Animation
        self.editBtn.setBackgroundColor(color: UIColor.clear, forState: .normal)
        self.editBtn.setTitleColor(UIColor.white, for: .normal)
        self.editBtn.setBackgroundColor(color: UIColor.white, forState: .highlighted)
        self.editBtn.setTitleColor(UIColor.purple, for: .highlighted)
        self.editBtn.setBackgroundColor(color: UIColor.white, forState: .selected)
        self.editBtn.setTitleColor(UIColor.purple, for: .selected)
        
        fetchPosts()
        fetchBestPosts()
        loadUserInfo()
        collectionView.delegate = self
        collectionView.dataSource = self
        bestInShowImage.isHidden = true
        
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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        showStats()
    }
    
//    func bestInShowStats() {
//        for post in posts {
//            if post.bestInShow == true {
//                bestInShowArray.append(post)
//                print("Best in show is run")
//            }
//        }
//        
//        ref.removeAllObservers()
//    }
    
    // Load Current User Info
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            let user = Users(snapshot: snapshot)
            self.usernameLabel.text = user.username
            self.breed.text = user.breed
            self.proPic.sd_setImage(with: URL(string: user.photoURL))
        })
    }
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Post, that: Post) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    /// Grabbing the Posts from Firebase 
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if postUser == FIRAuth.auth()?.currentUser?.uid {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.posts.append(post)

                            }
                        }
                    }
                }
                
                self.collectionView.reloadData()
            }
        })
        
        ref.removeAllObservers()
        
    }
    
    /// Grabbing the Posts from Firebase
    func fetchBestPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.bestInShowArray = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["bestInShow"] as? String {
                            if postUser == "true" {
                                
                                let key = snap.key
                                let post = Post(postKey: key, postData: postDict)
                                self.bestInShowArray.append(post)

                            }
                        }
                    }
                }
                
                self.collectionView.reloadData()
            }
        })
        
        ref.removeAllObservers()
        
    }
    
    func showStats() {
        
//        bestInShowStats()
        var followersDict = [""]
        var followingDict = [""]
        var bestInShowDict = [Post]()
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observe(.value, with: { (snapshot) in
            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if let myFollower = value as? String {
                        followersDict.append(myFollower)
                        self.followingAmount.text = "\(followersDict.count - 1)"
                    }
                   
                }
            }
        })
        
        ref.child("users").child(uid).child("followers").queryOrderedByKey().observe(.value, with: { (snapshots) in
            if let followers = snapshots.value as? [String: AnyObject] {
                for (_, values) in followers {
                    if let myFollowing = values as? String {
                        followingDict.append(myFollowing)
                        self.myFollowersAmount.text = "\(followingDict.count)"
                    }

                }
            }
        })
        
        for post in posts {
             DataService.ds.REF_POSTS.child(post.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                            print("WOOBZ - \(postDict)")
                            if let postUser = postDict["bestInShow"] as? Bool {
                                print("WOOBZ - \(postUser)")
                                if postUser == true {
                                    bestInShowDict.append(post)
                                    self.myPostsAmount.text = "\(bestInShowDict.count)"
                    }
                }
            }
        })
    }
        ref.removeAllObservers()
        
    }
    
    @IBAction func backPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let post = posts[indexPath.row]
        print("The collection view is executed")
        
        for pst in posts {
            if pst.bestInShow == true {
                bestInShowImage.isHidden = false
            }
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProCell", for: indexPath) as? ProfileCell {

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeletePostVC" {
            print("LEEZUS: Segway to DeletePost is performed!")
            let destinationViewController = segue.destination as! DeletePostVC
            destinationViewController.selectedPost = selectedPost
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCell
        selectedPost = cell.post
        performSegue(withIdentifier: "DeletePostVC", sender: self)
    }
    
    // MARK: - Actions
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editProfile(_ sender: Any) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func bestPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LeaderboardVC") as! LeaderboardVC
        self.present(vc, animated: true, completion: nil)
    }
    

    
    @IBAction func followingBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyFollowingVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func followersBtn(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyFollowersVC")
        self.present(vc, animated: true, completion: nil)
    }
    
}

