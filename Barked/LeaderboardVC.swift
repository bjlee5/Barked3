//
//  LeaderboardVC.swift
//  Barked
//
//  Created by MacBook Air on 8/25/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase 

class LeaderboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leaders = [Leaderboard]()
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var selectedUID: String = ""

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveUser()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaders.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.leaders.sort(by: self.sortRankFor)
        let someLeader = leaders[indexPath.row]
        let someUID = someLeader.userID
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as? LeaderboardCell {
            cell.configure(leader: someLeader, indexPath: someUID!)
            return cell
        } else {
            return LeaderboardCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedUID = leaders[indexPath.row].userID
            checkSelectedUID()
        }
    
    // MARK: - Helper Methods
    
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
    
    /// Pulls down users from Firebase and assigns them to [Friend]
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
                                if let rank = value["rank"] as? Int {
                            let imagePath = value["photoURL"] as? String
                            
                            userToShow.username = username
                            userToShow.imagePath = imagePath
                            userToShow.breed = breed
                            userToShow.rank = rank
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
    
    func updateRank() {
        for leader in leaders {
        let userRef = DataService.ds.REF_USERS.child(leader.userID)
        var rank: Int
        var bestInShowAmount = [Post]()
        DataService.ds.REF_POSTS.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            bestInShowAmount = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        print("POST: \(postDict)")
                                if let userRank = postDict["bestInShow"] as? Bool {
                                    if userRank == true {
                                        print("WOOBLES - your best in show count is \(bestInShowAmount.count)")
                                        
                                        let key = snap.key
                                        let post = Post(postKey: key, postData: postDict)
                                        bestInShowAmount.append(post)

                            }
                        }
                    }
                }
                
            }
        })
        rank = bestInShowAmount.count
        userRef.child("rank").setValue(rank)
        }
    }
    
    func sortRankFor(this: Leaderboard, that: Leaderboard) -> Bool {
        if that.rank == nil {
            that.rank = 0
        }
        if this.rank == nil {
            this.rank = 0
        }
        return this.rank > that.rank
    }
    
    // MARK: - Actions 
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
