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
        let someLeader = leaders[indexPath.row]
        let someUID = someLeader.userID
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as? LeaderboardCell {
            cell.configure(leader: someLeader, indexPath: someUID!)
            return cell
        } else {
            return LeaderboardCell()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Pulls down users from Firebase and assigns them to [Friend]
    func retrieveUser() {
        let ref = FIRDatabase.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            let users = snapshot.value as! [String: AnyObject]
            self.leaders.removeAll()
            for (_, value) in users {
                if let uid = value["uid"] as? String {
                    if uid != FIRAuth.auth()!.currentUser!.uid {
                        let userToShow = Leaderboard()
                        if let username = value["username"] as? String {
                            if let breed = value["breed"] as? String {
                            let imagePath = value["photoURL"] as? String
                            
                            userToShow.username = username
                            userToShow.imagePath = imagePath
                            userToShow.breed = breed 
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
