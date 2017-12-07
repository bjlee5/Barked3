//
//  ThirdNewUserVC.swift
//  Barked
//
//  Created by MacBook Air on 10/7/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ThirdNewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var password = ""
    var email = ""
    var selectedBreed = ""
    var breedGroup = ""
    var username = ""
    var imagePicker: UIImagePickerController!
    var imageSelected = false

    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var selectedImage: BoarderedCircleImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("BRIAN: - The info passed is as follows \(password), \(email), \(selectedBreed), \(username)")
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        }
    
    // MARK: Helper Functions 
    
    func setUserInfo(user: FIRUser!, email: String, password: String, username: String, breed: String, breedGroup: String, proPic: NSData!) {
        
        let imgUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        DataService.ds.REF_PRO_IMAGES.child(imgUid).put(proPic as Data, metadata: metadata) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error uploading profile Pic to Firebase")
                
            } else {
                print("BRIAN: New metadata stuff's workin.")
                
                
                
                let photoURL = newMetaData?.downloadURL()?.absoluteString
                if let url = photoURL {
                    
                    
                    self.saveUserInfo(user: user, username: username, password: password, breed: breed, breedGroup: breedGroup, image: url)
                    
                }
            }
        }
    }
    
    private func saveUserInfo(user: FIRUser!, username: String, password: String, breed: String, breedGroup: String, image: String) {
        
        
        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "breed": breed, "breedGroup": breedGroup, "photoURL": image, "provider": user.providerID]
        
        self.completeSignIn(id: user.uid, userData: userInfo)
        print("BRIAN: User info has been saved to the database")
        
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WelcomeVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    // ImagePicker //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedImage.isHidden = false
            imageBtn.isHidden = true
            selectedImage.image = image
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions 
    
    @IBAction func finishPress(_ sender: Any) {
        guard imageSelected == true else {
            showWarningMessage("Error", subTitle: "You have not selected an image!")
            return
        }
        
        let pictureData = UIImageJPEGRepresentation(self.selectedImage.image!, 0.70)
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                
                print("BRIAN: Could not create user")
                
            } else {
                
                print("BRIAN: The user has been created.")
                self.setUserInfo(user: user, email: self.email, password: self.password, username: self.username, breed: self.selectedBreed, breedGroup: self.breedGroup, proPic: pictureData as NSData!)
            }
        })
    }
    
    @IBAction func imageBtnPress(_ sender: Any) {
            present(imagePicker, animated: true, completion: nil)
        }
    
    @IBAction func backPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
