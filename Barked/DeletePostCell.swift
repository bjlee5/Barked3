//
//  DeletePostCell.swift
//  Barked
//
//  Created by MacBook Air on 5/5/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AudioToolbox

protocol MyCommentSubclassDelegate: class {
    func commentButtonTapped(cell: DeletePostCell)
}

class DeletePostCell: UITableViewCell {
    
    var post: Post!
    var myCommentsDelegate: MyCommentSubclassDelegate?
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikes: UILabel!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postUser: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
    }
    
    func configureCell(post: Post) {
        
        self.post = post 
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postCaption.text = post.caption
        self.postLikes.text = "\(post.likes)"
        self.postDate.text = post.currentDate
        
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.postUser.text = "\(post.postUser)"
        })

        let ref = FIRStorage.storage().reference(forURL: post.imageURL)
        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.postImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
                print("WOOBLES: BIG TIME ERRORS")
            }
        })
        
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
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                self.barkSoundEffect()
                self.playSound()
            } else {
                self.likesImage.image = UIImage(named: "Paw")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func commentPressed(_ sender: Any) {
         self.myCommentsDelegate?.commentButtonTapped(cell: self)
    }
    
    // Play Sounds
    
    var gameSound: SystemSoundID = 0
    
    func barkSoundEffect() {
        let path = Bundle.main.path(forResource: "Woof", ofType: "mp3")!
        let soundURL = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
}
