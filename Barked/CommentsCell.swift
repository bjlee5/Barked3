//
//  CommentsCell.swift
//  Barked
//
//  Created by MacBook Air on 6/6/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

//protocol CommentLikesDelegate: class {
//    func commentLikesTapped(cell: CommentsCell)
//}

class CommentsCell: UITableViewCell {
    
//    var commentDelegate: CommentLikesDelegate?
    var comment: Comment!
    var likesRef: FIRDatabaseReference!
    
    @IBOutlet weak var profilePicImage: UIImageView!
    @IBOutlet weak var usernameField: UILabel!
    @IBOutlet weak var commentField: UILabel!
    @IBOutlet weak var commentDate: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var likesCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
        self.backgroundColor = UIColor.clear
        commentDate.isHidden = true
        
    }
    
    func configureCommentLikes(comment: Comment, selectedPostKey: String, currentCommentKey: String) {
        self.comment = comment
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(comment.postKey).child(comment.commentKey)
        self.likesCount.text = "\(comment.likes)"
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = UIImage(named: "Paw")
            } else {
                self.likesImage.image = UIImage(named: "PawFilled")
            }
        })
    }
    
    func likesTapped(sender: UIGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likesImage.image = UIImage(named: "PawFilled")
                self.comment.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImage.image = UIImage(named: "Paw")
                self.comment.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
        

    
//    @IBAction func likesBtnPress(_ sender: Any) {
//    self.commentDelegate?.commentLikesTapped(cell: self)
//    }
}
