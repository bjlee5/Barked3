//
//  Comment.swift
//  Barked
//
//  Created by MacBook Air on 6/6/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    private var _caption: String!
    private var _postUser: String!
    private var _profilePicURL: String!
    private var _currentDate: String!
    private var _uid: String!
    private var _likes: Int!
    private var _commentRef: FIRDatabaseReference!
    private var _postKey: String!
    private var _commentKey: String!
    
    var caption: String {
        return _caption
    }
    
    var postUser: String {
        return _postUser
    }
    
    var profilePicURL: String {
        return _profilePicURL
    }
    
    var currentDate: String {
        return _currentDate
    }
    
    var uid: String {
        return _uid
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    
    init(caption: String, postUser: String, profilePicURL: String, currentDate: String, uid: String, likes: Int, commentKey: String) {
        self._caption = caption
        self._postUser = postUser
        self._uid = uid
        self._profilePicURL = profilePicURL
        self._currentDate = currentDate
        self._likes = likes
    }
    
    init(postKey: String, commentKey: String, postData: Dictionary<String, Any>) {
        self._postKey = postKey
        self._commentKey = commentKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let postUser = postData["postUser"] as? String {
            self._postUser = postUser
        }
        
        if let profilePicURL = postData["profilePicURL"] as? String {
            self._profilePicURL = profilePicURL
        }
        
        if let currentDate =
            postData["currentDate"] as? String {
            self._currentDate = currentDate
        }
        
        if let uid =
            postData["uid"] as? String {
            self._uid = uid
        }
        
        if let likes =
            postData["likes"] as? Int {
            self._likes = likes 
        }
        
         _commentRef = DataService.ds.REF_POSTS.child(_postKey).child("comments").child(_commentKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _commentRef.child("likes").setValue(_likes)
    }
    
}


