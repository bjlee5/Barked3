//
//  PostCell.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import AudioToolbox

protocol CellSubclassDelegate: class {
    func buttonTapped(cell: PostCell)
}

protocol CommentsSubclassDelegate: class {
    func commentButtonTapped(cell: PostCell)
}

class PostCell: UITableViewCell {
    
    var delegate: CellSubclassDelegate?
    var commentsDelegate: CommentsSubclassDelegate?
    var post: Post!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var likesRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var profilePic: BoarderedCircleImage!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var postPic: BoarderedSquareImage!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postUser: UILabel!
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var bestShowPic: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bestShowPic.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likesTapped))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.isUserInteractionEnabled = true
        
        let currentDate = NSDate()
        dateLabel.text = "\(currentDate)"
    }
    
    // Load Current User //
    
    func loadUserInfo(){
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.username.text = user.username
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    //
    
    func configureCell(post: Post, img: UIImage? = nil) {
        
//        if post.bestInShow == true {
//            bestShowPic.isHidden = false
//        } else {
//            bestShowPic.isHidden = true 
//        }
        
        self.post = post
        self.likesRef = DataService.ds.REF_CURRENT_USERS.child("likes").child(post.postKey)
        self.postText.text = post.caption
        self.likesNumber.text = "\(post.likes)"
        self.dateLabel.text = post.currentDate
        
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            self.postUser.text = "\(post.postUser)"
            self.username.text = "\(post.postUser)"
        })

        
        if img != nil {
            self.postPic.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("BRIAN: Unable to download image from Firebase")
                } else {
                    print("Image downloaded successfully")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postPic.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageURL as NSString!)
                        }
                    }
                    
                    
                }
            })
        }
        
        let otherRef = FIRStorage.storage().reference(forURL: post.profilePicURL)
        otherRef.data(withMaxSize: 2 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.profilePic.image = UIImage(data: data)
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
                self.barkSoundEffect()
                self.playSound()
                self.likesImage.image = UIImage(named: "PawFilled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likesImage.image = UIImage(named: "Paw")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    

    
    
    @IBAction func userPressed(_ sender: Any) {
    self.delegate?.buttonTapped(cell: self)
    }

    @IBAction func commentPressed(_ sender: Any) {
        self.commentsDelegate?.commentButtonTapped(cell: self)
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

