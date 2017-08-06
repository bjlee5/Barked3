//
//  Notification.swift
//  Barked
//
//  Created by MacBook Air on 8/2/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import Firebase

class Notification {
    private var _comment: String!
    private var _photoURL: String!
    private var _read: Bool!
    private var _uid: String!
    private var _username: String!
    private var _currentDate: String!
    private var _notificationRef: FIRDatabaseReference!
    private var _notificationKey: String!
    
    
    var comment: String {
        return _comment
    }
    
    var photoURL: String {
        return _photoURL
    }
    
    var read: Bool {
        return _read
    }
    
    var uid: String {
        return _uid
    }
    
    var username: String {
        return _username
    }
    
    var currentDate: String {
        return _currentDate
    }
    
    var notificationKey: String {
        return _notificationKey
    }
    
    init(comment: String, photoURL: String, read: Bool, uid: String, username: String, currentDate: String, notificationKey: String) {
        self._comment = comment
        self._photoURL = photoURL
        self._read = read
        self._uid = uid
        self._username = username
        self._currentDate = currentDate
        self._notificationKey = notificationKey 
    }
    
    init(notificationKey: String, noteData: Dictionary<String, Any>) {
        self._notificationKey = notificationKey
        
        if let comment = noteData["comment"] as? String {
            self._comment = comment
        }
        
        if let photoURL = noteData["photoURL"] as? String {
            self._photoURL = photoURL
        }
        
        if let read = noteData["read"] as? Bool {
            self._read = read
        }
        
        if let uid = noteData["uid"] as? String {
            self._uid = uid
        }
        
        if let username = noteData["username"] as? String {
            self._username = username
        }
        
        if let currentDate = noteData["currentDate"] as? String {
            self._currentDate = currentDate 
        }
        
        _notificationRef = DataService.ds.REF_CURRENT_USERS.child("notifications").child(_notificationKey).child("read")
    }
    
    func adjustNotifications(read: Bool) {
        if read {
            _read = true
        } else {
            _read = false
        }
        _notificationRef.setValue(_read)
    }
}
