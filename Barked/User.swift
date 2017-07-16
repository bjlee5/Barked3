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

//struct User {
//    
//    var username: String!
//    var email: String?
//    var bio: String?
//    var photoURL: String!
//    var uid: String!
//    var ref: FIRDatabaseReference?
//    var key: String?
//    
//    init(snapshot: FIRDataSnapshot) {
//        
//        key = snapshot.key
//        ref = snapshot.ref
//        username = (snapshot.value! as! NSDictionary)["username"] as! String
//        email = (snapshot.value! as! NSDictionary)["email"] as? String
//        bio = (snapshot.value! as! NSDictionary)["bio"] as? String
//        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
//        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
//    }
//    
//}


//class User {
//    private var _username: String!
//    private var _email: String!
//    private var _bio: String!
//    private var _photoURL: String!
//    private var _uid: String!
//    private var _ref: FIRDatabaseReference!
//    private var _key: String!
//
//    var username: String {
//        return _username
//    }
//
//    var email: String {
//        return _email
//    }
//
//    var bio: String {
//        return _bio
//    }
//
//    var photoURL: String {
//        return _photoURL
//    }
//
//    var uid: String {
//        return _uid
//    }
//
//    var key: String {
//        return _key
//    }
//
//    init(username: String, email: String, bio: String, photoURL: String, uid: String) {
//        self._username = username
//        self._email = email
//        self._bio = bio
//        self._photoURL = photoURL
//        self._uid = uid
//    }
//
//    init(postKey: String, postData: Dictionary<String, Any>) {
//        self._key = postKey
//
//        if let username = postData["username"] as? String {
//            self._username = username
//        }
//
//        if let email = postData["email"] as? String {
//            self._email = email
//        }
//
//
//      if let bio = postData["bio"] as? String {
//            self._bio = bio
//        }
//
//        if let photoURL = postData["photoURL"] as? String {
//            self._photoURL = photoURL
//        }
//
//        if let uid = postData["uid"] as? String {
//            self._uid = uid
//        }
//
//        _ref = DataService.ds.REF_POSTS.child(_key)
//    }
//
//
//}

