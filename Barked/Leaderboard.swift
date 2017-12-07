//
//  Leaderboard.swift
//  Barked
//
//  Created by MacBook Air on 8/25/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import Firebase

class Leaderboard: NSObject {
    
    var userID: String!
    var username: String!
    var breed: String!
    var winCount: Int!
    var imagePath: String!
    var userRef: FIRDatabaseReference! = DataService.ds.REF_USERS

    func increaseWins(by amount: Int) {
        winCount = amount
    userRef.child(userID).child("winCount").setValue(winCount)
    }
}
