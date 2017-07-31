//
//  FriendProfileVC.swift
//  Barked
//
//  Created by MacBook Air on 5/5/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import SCLAlertView

class FriendProfileVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Refactor storage reference //
    
    var selectedUID: String = ""
    var selectedPost: Post!
    var posts = [Post]()
//    var bestInShowArray = [Post]()
//    var bestInShowTotal = 0
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var profilePicLoaded = false
    var storageRef: FIRStorage { return FIRStorage.storage() }
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
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
    @IBOutlet weak var followersAmount: UILabel!
    @IBOutlet weak var postAmount: UILabel!
    @IBOutlet weak var followingAmount: UILabel!
    @IBOutlet weak var bestInShowImage: UIImageView!
    @IBOutlet weak var breed: UILabel!
    @IBOutlet weak var followButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observer to Update in Realtime

        
        print("LEEZUS: This is your man - \(selectedUID)")
        
        fetchPosts()
        loadUserInfo()
        showStats()
        collectionView.reloadData()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        showStats()
    }
    
//    func bestInShowStats() -> Int {
//        for post in posts {
//
//            if post.bestInShow == true && 3 >= bestInShowTotal {
//                bestInShowTotal += 1
//            }
//        }
//                return bestInShowTotal / 2
//    }
    
    // Load Current User Info
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(selectedUID)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            if user.name == nil {
                self.usernameLabel.text = user.username
            } else {
                self.usernameLabel.text = user.name
            }
            self.breed.text = user.breed
            let imageURL = user.photoURL!
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.proPic.image = UIImage(data: data)
                        }
                    }
                    
                    
                } else {
                    print(error!.localizedDescription)
                    
                }
                
            })
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
            checkFollowing(indexPath: selectedUID)
    }
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Post, that: Post) -> Bool {
        return this.currentDate > that.currentDate
    }
    
    // MARK: Show Current User Feed
    
    /// Grabbing the Posts from Firebase
    func fetchPosts() {
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.posts = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                print("LEE: \(snapshot)")
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if postUser == self.selectedUID {
                                
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
    
    
    func showStats() {
        
        var followersDict = [""]
        var followingDict = [""]

        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(selectedUID).child("following").queryOrderedByKey().observe(.value, with: { (snapshot) in
            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if let myFollower = value as? String {
                        followersDict.append(myFollower)
                        self.followingAmount.text = "\(followersDict.count - 1)"
                    }
                    
                }
            }
        })
        
        ref.removeAllObservers()
        
        ref.child("users").child(selectedUID).child("followers").queryOrderedByKey().observe(.value, with: { (snapshots) in
            if let followers = snapshots.value as? [String: AnyObject] {
                for (_, values) in followers {
                    if let myFollowing = values as? String {
                        followingDict.append(myFollowing)
                        self.followersAmount.text = "\(followingDict.count)"
                    }
                    
                }
            }
        })
        
        ref.removeAllObservers()
    }
    
    func checkFollowing(indexPath: String) {
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if value as! String == indexPath {
                        self.followButton.image = UIImage(named: "followed")
                    }
                }
            }
        })
        
        ref.removeAllObservers()
    }

    // Collection View
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        postAmount.text = "\(posts.count)"
        let post = posts[indexPath.row]
        
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
        if segue.identifier == "FriendPostVC" {
            print("LEEZUS: Segway to DeletePost is performed!")
            let destinationViewController = segue.destination as! FriendPostVC
            destinationViewController.selectedPost = selectedPost
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProfileCell
        selectedPost = cell.post
        performSegue(withIdentifier: "FriendPostVC", sender: self)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followersBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FriendFollowersVC") as! FriendFollowersVC
        vc.selectedUID = selectedUID
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func followingBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FriendFollowingVC") as! FriendFollowingVC
        vc.selectedUID = selectedUID
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: Actions 
    
    @IBAction func followBtnPress(_ sender: Any) {
        
        var isFollower = false
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        let clickedUser = selectedUID
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    
                    if value as? String == clickedUser {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(clickedUser).child("followers/\(ke)").removeValue()
                        print("LEEZUS: This is you \(clickedUser)")
                        
                        self.followButton.image = UIImage(named: "follow")
                        self.showStats()
                    }
                }
            }
            
            if isFollower == false {

                let following = ["following/\(key)" : clickedUser]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(clickedUser).updateChildValues(followers)
                
                self.followButton.image = UIImage(named: "followed")
                self.showStats()
            }
            
        })
        
        ref.removeAllObservers()
        
    }
    
    
}


