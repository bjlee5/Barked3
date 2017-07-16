//
//  UserCell.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

protocol UserCellSubclassDelegate: class {
    func buttonTapped(cell: UserCell)
}

protocol UserCellProfilePressDelegate: class {
    func profileBtnTapped(cell: UserCell)
}


class UserCell: UITableViewCell {
    
    var userID: String!
    var friend: Friend!
    let uid = FIRAuth.auth()!.currentUser!.uid
    let ref = FIRDatabase.database().reference()
    var isFollower = false
    var userDelegate: UserCellSubclassDelegate?
    var profileDelegate: UserCellProfilePressDelegate?
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followButton: UIImageView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var usernameBtn: UIButton!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userDelegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(followTapped))
//        tap.numberOfTapsRequired = 1
//        followButton.addGestureRecognizer(tap)
//        followButton.isUserInteractionEnabled = true
        
        
    }
    
    func configure(friend: Friend, indexPath: String) {
        
        self.friend = friend
        self.userName.text = friend.username
//        self.followingRef = nil
        
        userImage.downloadImage(from: friend.imagePath!)
        
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let following = snapshot.value as? [String: AnyObject] {
                for (_, value) in following {
                    if value as! String == indexPath {
                        self.isFollower = true
                        self.followButton.image = UIImage(named: "followed")
                    } else {
                        self.followButton.image = UIImage(named: "follow")
                        }
                    }
                }
            })

    }
    
    func checkFollowing(indexPath: String) {
        
                let uid = FIRAuth.auth()!.currentUser!.uid
                let ref = FIRDatabase.database().reference()
        
                ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                    if let following = snapshot.value as? [String: AnyObject] {
                        for (_, value) in following {
                            if value as! String == indexPath {
                                self.followButton.image = UIImage(named: "followed")
                            }
                        }
                    }
                })
                
                ref.removeAllObservers()
        
            }

    
    @IBAction func followPressed(_ sender: Any) {
        self.userDelegate?.buttonTapped(cell: self)
    }
    
    @IBAction func labelPress(_ sender: Any) {
        self.profileDelegate?.profileBtnTapped(cell: self)
    }

}
