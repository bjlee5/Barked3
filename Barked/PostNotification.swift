//
//  PostNotification.swift
//  Barked
//
//  Created by MacBook Air on 8/2/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import Firebase

//struct PostNotification {
//    
//    let selectedPost: Post!
//    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
//    
//    func commentNotification(imgUrl: String) {
//        
//        userRef.observe(.value, with: { (snapshot) in
//            
//            let user = Users(snapshot: snapshot)
//            let notifyingUser = String(user.username)
//        
//        let uid = FIRAuth.auth()?.currentUser?.uid
//        
//        let notification: Dictionary<String, Any> = [
//            "comment": "\(notifyingUser) has commented on your photo!",
//            "photoURL": "Some photo url",
//            "read": false,
//            "uid": uid!,
//            "username": notifyingUser,
//        ]
//    })
//    
//        
//        let firebaseNotify = DataService.ds.REF_USERS.child(selectedPost.uid).child("notifications").childByAutoId()
//        firebaseNotify.setValue(notification)
//        
//        stopIndicator()
//        addCommentField.text = ""
//        
//    }
//}
