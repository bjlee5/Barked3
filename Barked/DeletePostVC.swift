//
//  DeletePostVC.swift
//  Barked
//
//  Created by MacBook Air on 5/4/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class DeletePostVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MyCommentSubclassDelegate {
    
    var selectedPost: Post!
    var postArray = [Post]()
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
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myPost = postArray[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath) as? DeletePostCell {
            cell.configureCell(post: myPost)
            cell.myCommentsDelegate = self 
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

    
    // MARK: - Actions

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }



    @IBAction func deletePost(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Delete") {
            self.delete()
        }
        alertView.addButton("Cancel") {
            
        }
        alertView.showError("Warning", subTitle: "Are you sure you want to delete this post?")
        
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
    
    func delete() {
        
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
        
        self.postArray.remove(at: 0)
        self.tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}
