//
//  FriendsVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox
import UserNotifications

class FriendsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UserCellSubclassDelegate, UserCellProfilePressDelegate {
    
    var users = [Friend]()
    var filteredUsers = [Friend]()
    let searchController = UISearchController(searchResultsController: nil)
    var selectedUID: String = ""
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var currentUsername: String!
    var currentUserPic: UIImage!
    var currentUID: String = ""
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Observer to Update TableView in Realtime
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.friendsTableView.reloadData()
        })
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        retrieveUser()
        loadUserInfo()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        friendsTableView.tableHeaderView = searchController.searchBar
        
//        //Styling for background view
//        friendsTableView.backgroundView = UIImageView(image: UIImage(named: "FFBackground"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.friendsTableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            self.friendsTableView.reloadData()
        })
    }
    
    // MARK: Helper Methods
    
    /// Retrieves Current Users Information
    func loadUserInfo() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUsername = user.username
            self.currentUID = user.uid
            
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
    
    /// Schedules Push Notifications
    
    func scheduleNotifications() {
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let notifyingUser = String(user.username)
            print("WOOBLES - Schedule notification is run!!!")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
            let content = UNMutableNotificationContent()
            content.body = "\(self.currentUsername!) is now following you!"
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
    
    /// Path to Users profile
    func profileBtnTapped(cell: UserCell) {
        var isFollower = false
        guard let indexPath = self.friendsTableView.indexPath(for: cell) else { return }
        
        //  Do whatever you need to do with the indexPath
        
        print("BRIAN: Button tapped on row \(indexPath.row)")
        var clickedUser = users[indexPath.row].userID
        if searchController.isActive && searchController.searchBar.text != "" {
            clickedUser = filteredUsers[indexPath.row].userID
        } else {
            clickedUser = users[indexPath.row].userID
        }
            self.selectedUID = clickedUser!
            self.checkSelectedUID()
//        })
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FriendProfileVC" {
            print("LEEZUS: Segway to FriendsVC performed!!")
            let destinationViewController = segue.destination as! FriendProfileVC
            destinationViewController.selectedUID = selectedUID
        }
    }
    
    /// Follows or Unfollows a user
    func buttonTapped(cell: UserCell) {
        var isFollower = false
        self.playSound()
        self.soundEffect()
        
        guard let indexPath = friendsTableView.indexPath(for: cell) else {
            print("BRIAN: An error is occuring here")
            return
        }
        
        //  Do whatever you need to do with the indexPath
        
        var clickedUser: String
        
        if searchController.isActive && searchController.searchBar.text != "" {
            clickedUser = filteredUsers[indexPath.row].userID
        } else {
            clickedUser = users[indexPath.row].userID
        }
        
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
                if clickedUser != FIRAuth.auth()?.currentUser?.uid {
                }
                let following = ["following/\(key)" : clickedUser]
                let followers = ["followers/\(key)" : uid]
                
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(clickedUser).updateChildValues(followers)
                
                isFollower = true
                cell.followButton.image = UIImage(named: "following")
                

        
//        if isFollower == false {
                
            if let imgData = UIImageJPEGRepresentation(self.currentUserPic, 0.2) {
                
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
                            self.followingNotification(imgURL: url, selectedPostUID: clickedUser)
                        }
                    }
                }
            }
        }
    })
    
    
        
        ref.removeAllObservers()
        
}
    
    /// Helper method to segue to FriendProfileVC
    func checkSelectedUID() {
        if selectedUID != "" {
            performSegue(withIdentifier: "FriendProfileVC", sender: self)
    }
}
    
    /// Search Functionality
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = users.filter { user in
            return user.username.lowercased().contains(searchText.lowercased())
        }
        
        friendsTableView.reloadData()
    }
    
    /// Pulls down users from Firebase and assigns them to [Friend]
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
                            if let imagePath = value["photoURL"] as? String {
                                let breed = value["breed"] as? String
                            
                            userToShow.username = username
                            userToShow.imagePath = imagePath
                            userToShow.breed = breed
                            userToShow.userID = uid
                            self.users.append(userToShow)
                            
                            }
                        }
                    }
                }
            }
            
            self.friendsTableView.reloadData()
            
        })
        
        ref.removeAllObservers()
        
    }
    
    ///Retrieves Current Date
    func formatDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let result = formatter.string(from: date)
        return result
    }
    
    /// Notification for Following User 
    func followingNotification(imgURL: String, selectedPostUID: String) {
        
        self.scheduleNotifications()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let notification: Dictionary<String, Any> = [
            "comment": "\(currentUsername!) is now following you!",
            "photoURL": imgURL,
            "read": false,
            "uid": uid!,
            "username": "\(currentUsername!)",
            "currentDate": formatDate(),
            "identifier": "\(currentUID)",
            "type": notificationType.follow.rawValue
        ]
        
        let firebaseNotify = DataService.ds.REF_USERS.child(selectedPostUID).child("notifications").childByAutoId()
        firebaseNotify.setValue(notification)
    }

    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let someFriend: Friend
        if searchController.isActive && searchController.searchBar.text != "" {
            someFriend = filteredUsers[indexPath.row]
        } else {
            someFriend = users[indexPath.row]
        }

        let someUID = someFriend.userID
        
        if let cell = friendsTableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell {
            cell.userDelegate = self
            cell.profileDelegate = self
            cell.configure(friend: someFriend, indexPath: someUID!)
            cell.checkFollowing(indexPath: someUID!)
            return cell
        } else {
            return UserCell() 
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Nothing
    }

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        performSegue(withIdentifier: "MyProfileVC", sender: self)
    }
    
    // Play Sounds
    
    var gameSound: SystemSoundID = 0
    
    func soundEffect() {
        let path = Bundle.main.path(forResource: "clicky", ofType: "mp3")!
        let soundURL = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}

extension UIImageView {
    
    func downloadImage(from imageURL: String!) {
        let url = URLRequest(url: URL(string: imageURL)!)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
                
            }
        }
        
        task.resume()
        
    }
    
    class func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
}

extension FriendsVC: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension FriendsVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
