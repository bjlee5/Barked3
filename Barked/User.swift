//
//  User.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase


struct Users {
    
    var name: String?
    var username: String!
    var email: String?
    var breed: String?
    var photoURL: String!
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    
    init(snapshot: FIRDataSnapshot) {
        
        key = snapshot.key
        ref = snapshot.ref
        name = (snapshot.value! as! NSDictionary)["name"] as? String
        username = (snapshot.value! as! NSDictionary)["username"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        breed = (snapshot.value! as! NSDictionary)["breed"] as? String
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
    }
    
    init(name: String) {
        self.name = "Anonymous"
    }
    
}

