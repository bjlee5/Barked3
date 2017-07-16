//
//  CommentsVC.swift
//  Barked
//
//  Created by MacBook Air on 6/6/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
//,CommentLikesDelegate {

    var selectedPost: Post!
    var comments = [Comment]()
    var comment: Comment!
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var likesRef: FIRDatabaseReference!
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    @IBOutlet weak var addCommentField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentUserProPic: UIImageView!
    @IBOutlet weak var currentUsername: UILabel!
    @IBOutlet weak var myPic: UIImageView!
    @IBOutlet weak var myUsername: UILabel!
    @IBOutlet weak var myComment: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "FFBackground"))
        
        currentUserProPic.isHidden = true
        currentUsername.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadMyComment()
        loadUserInfo()
        fetchComments()
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadMyComment() {
        myUsername.text = selectedPost.postUser
        myComment.text = selectedPost.caption
        
        self.storageRef.reference(forURL: selectedPost.profilePicURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.myPic.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUsername.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.currentUserProPic.image = UIImage(data: data)
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchComments() {
        DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").observe(.value, with: { (snapshot) in
            self.comments = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let comDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let postKey = self.selectedPost.postKey
                        let key = snap.key
                        let comment = Comment(postKey: postKey, commentKey: key, postData: comDict)
                        self.comments.append(comment)
                    }
                }
                
                self.tableView.reloadData()
            }
        })
        
    }
    
    func delete(commentKey: String) {
        
        // Remove the post from the DB
        DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").child(commentKey).removeValue { error in
            if error != nil {
                print("error \(error)")
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentsCell
        
        let comment = comments[indexPath.row]
//        cell.commentDelegate = self
        cell.configureCommentLikes(comment: comment, selectedPostKey: selectedPost.postKey, currentCommentKey: comment.commentKey)
        cell.usernameField.text = comments[indexPath.row].postUser
        cell.commentField.text = comments[indexPath.row].caption
        cell.commentDate.text = comments[indexPath.row].currentDate
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()

        
        FIRStorage.storage().reference(forURL: comments[indexPath.row].profilePicURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        cell.profilePicImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        return cell
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(commentKey: comments[indexPath.row].commentKey)
            comments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        if selectedPost.uid == FIRAuth.auth()?.currentUser?.uid || comments[indexPath.row].uid == FIRAuth.auth()?.currentUser?.uid {
            
            return UITableViewCellEditingStyle.delete
            
        }
        return UITableViewCellEditingStyle.none
        
    }

    
    @IBAction func addCommentPressed(_ sender: Any) {
        
        guard let caption = addCommentField.text, caption != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a caption!")
            return
        }
        
        guard let proImg = currentUserProPic.image else {
            print("BRIAN: The user has no profile pic!")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(proImg, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metdata, error) in
                if error != nil {
                    print("BRIAN: Unable to upload image to Firebase storage")
                } else {
                    print("BRIAN: Successfully printed image to Firebase")
                    let downloadURL = metdata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
                
            }
        }
        
    }
    
    // Retrieve the Current Date //
    
    let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
    
    // Posting to Firebase //
    
    func postToFirebase(imgUrl: String) {
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let comment: Dictionary<String, Any> = [
            "caption": addCommentField.text!,
            "postUser": currentUsername.text!,
            "profilePicURL": imgUrl,
            "currentDate": realDate,
            "uid": uid!,
            "likes": 0
        ]
        
        
        let firebasePost = DataService.ds.REF_POSTS.child(selectedPost.postKey).child("comments").childByAutoId()
        firebasePost.setValue(comment)
        
        addCommentField.text = ""
        
    }
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

