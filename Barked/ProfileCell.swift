//
//  MyPostCell.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase



class ProfileCell: UICollectionViewCell {
    
    @IBOutlet weak var myImage: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    
    func configureCell(post: Post) {
        self.post = post
        myImage.sd_setImage(with: URL(string: post.imageURL))
    }

}

