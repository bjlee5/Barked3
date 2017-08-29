//
//  BestInShowCell.swift
//  Barked
//
//  Created by MacBook Air on 8/25/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LeaderboardCell: UITableViewCell {
    
    var userID: String!
    var leader: Leaderboard!
    let uid = FIRAuth.auth()!.currentUser!.uid
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBreed: UILabel!
    @IBOutlet weak var bestInShowCount: UILabel!
    
    func configure(leader: Leaderboard, indexPath: String) {
        
        self.leader = leader
        self.usernameLabel.text = leader.username
        self.userBreed.text = leader.breed
        profileImage.downloadImage(from: leader.imagePath!)
        
        if leader.rank == nil {
            self.bestInShowCount.text = "\(0)"
        } else {
        self.bestInShowCount.text = "\(leader.rank)"
    }
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            var bestInShowDict = [Post]()
            bestInShowDict = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                print("LEE: \(snapshot)")
                for snap in snapshot {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        if let postUser = postDict["uid"] as? String {
                            if postUser == indexPath {
                                if let bestInShow = postDict["bestInShow"] as? Bool {
                                    if bestInShow == true {
                                        
                                        let bestKey = snap.key
                                        let bestPost = Post(postKey: bestKey, postData: postDict)
                                        bestInShowDict.append(bestPost)
                                        leader.rank = bestInShowDict.count
                                        self.bestInShowCount.text = "\(bestInShowDict.count)"
                                        
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
