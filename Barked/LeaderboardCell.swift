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
    var bestInShowDict = [Post]()
    

    @IBOutlet weak var profileImage: BoarderedCircleImage!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userBreed: UILabel!
    @IBOutlet weak var bestInShowCount: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    func configure(leader: Leaderboard, indexPath: String, rank: Int) {
        
        self.leader = leader
        self.usernameLabel.text = leader.username
        self.userBreed.text = leader.breed
        self.bestInShowCount.text = "\(leader.rank!)"
        self.rankLabel.text = "\(rank + 1)"
        
        profileImage.sd_setImage(with: URL(string: leader.imagePath))
        
    }
    
//    func configureRank() {
//        let rankAmount = self.bestInShowDict.count
//        leader.increaseRank(by: rankAmount)
//        self.bestInShowCount.text = "\(leader.rank)"
//    }
}
