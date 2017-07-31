//
//  FollowingVC.swift
//  Barked
//
//  Created by MacBook Air on 7/21/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AudioToolbox

class MyFollowersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UserCellSubclassDelegate, UserCellProfilePressDelegate {
    
    var users = [Friend]()
    var displayedUsers = [String]()
    var followingUsers = [Friend]()
    var selectedUID: String = ""
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    let uid = FIRAuth.auth()!.currentUser!.uid
    let ref = FIRDatabase.database().reference()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFollowingUsersUID()
        uidToFriend()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = UIImageView(image: UIImage(named: "FFBackground"))
        
    }
    
    // MARK: - Helper Functions
    
    
    /// Pulls down users and appends UID's of following users to displayedUsers: [Array]
    func getFollowingUsersUID() {
        
        ref.child("users").child(uid).child("followers").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.users.removeAll()
            for (_, value) in users {
                self.displayedUsers.append(value as! String)
            }
        })
        
        ref.removeAllObservers()
        
    }
    
    /// Pulls users from Firebase and appends to users: [Array]
    func uidToFriend() {
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String: AnyObject]
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    
                    let userToShow = Friend()
                    if let username = value["username"] as? String {
                        let imagePath = value["photoURL"] as? String
                        
                        userToShow.username = username
                        userToShow.imagePath = imagePath
                        userToShow.userID = uid
                        
                        if self.displayedUsers.contains(uid) {
                            
                            self.followingUsers.append(userToShow)
                            print("LIONSEYE - \(self.followingUsers)")
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    func buttonTapped(cell: UserCell) {
        var isFollower = false
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("BRIAN: An error is occuring here")
            return
        }
        
        //  Do whatever you need to do with the indexPath
        
        var clickedUser: String
        
        clickedUser = followingUsers[indexPath.row].userID
        
        
        let uid = FIRAuth.auth()!.currentUser!.uid
        let ref = FIRDatabase.database().reference()
        let key = ref.child("users").childByAutoId().key
        
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (ke, value) in following {
                    
                    if value as? String == clickedUser {
                        isFollower = true
                        
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        ref.child("users").child(clickedUser).child("followers/\(ke)").removeValue()
                        print("LEEZUS: This is you \(clickedUser)")
                        
                        cell.followButton.image = UIImage(named: "follow")
                        
                    }
                }
            }
            
            if isFollower == false {
                //                if clickedUser != FIRAuth.auth()?.currentUser?.uid {
                //                    self.scheduleNotifications()
                //                }
                let following = ["following/\(key)" : clickedUser]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(clickedUser).updateChildValues(followers)
                
                cell.followButton.image = UIImage(named: "followed")
                
            }
            
        })
        
        ref.removeAllObservers()
        
    }
    
    func profileBtnTapped(cell: UserCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        
        //  Do whatever you need to do with the indexPath
        
        print("BRIAN: Button tapped on row \(indexPath.row)")
        let clickedUser = followingUsers[indexPath.row].userID
        self.selectedUID = clickedUser!
        self.checkSelectedUID()
    }
    
    func checkSelectedUID() {
        if selectedUID != "" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FriendProfileVC") as! FriendProfileVC
            vc.selectedUID = selectedUID
            self.present(vc, animated: true, completion: nil)
            
        }
    }

    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followingUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friend = followingUsers[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell {
            cell.userDelegate = self
            cell.profileDelegate = self 
            cell.userName.text = friend.username
            cell.userID = friend.userID
            cell.userImage.downloadImage(from: friend.imagePath!)
            cell.backgroundColor = UIColor.clear
            cell.checkFollowing(indexPath: friend.userID)
            return cell
        } else {
            return UserCell()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
