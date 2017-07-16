//
//  FriendPost.swift
//  Barked
//
//  Created by MacBook Air on 6/7/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class FriendPostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MyCommentSubclassDelegate {
    
    var postArray = [Post]()
    var selectedPost: Post!
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postArray.append(selectedPost)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myPost = postArray[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath) as? DeletePostCell {
            cell.myCommentsDelegate = self
            cell.configureCell(post: myPost)
            return cell
            
        } else {
            
            return DeletePostCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit: UITableViewCellEditingStyle, forRowAt: IndexPath) {
        
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let storage = FIRStorage.storage().reference(forURL: "gs://barked-d0342.appspot.com")
        
        // Remove the post from the DB
        ref.child("posts").child(selectedPost.postKey).removeValue { error in
            if error != nil {
                print("error \(error)")
            }
        }
        // Remove the image from storage
        let imageRef = storage.child("posts").child(uid).child("\(selectedPost.postKey).jpg")
        imageRef.delete { error in
            if error != nil {
                print("LEEZUS: Your posts have not been removed successfully - FAGGOT!")
            } else {
                
            }
        }
        
        self.postArray.remove(at: forRowAt.row)
        self.tableView.deleteRows(at: [forRowAt], with: .automatic)
        
    }
    
    // MARK: - Helper Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentsVC" {
            let destinationViewController = segue.destination as! CommentsVC
            destinationViewController.selectedPost = selectedPost
        }
    }
    
    func commentButtonTapped(cell: DeletePostCell) {
        self.checkSelectedPost()
    }
    
    func checkSelectedPost() {
        performSegue(withIdentifier: "CommentsVC", sender: self)
    }
    
    
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

