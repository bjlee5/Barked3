//
//  NewUserVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit

import UIKit
import Firebase
import SwiftKeychainWrapper

// The breed label / pickerView is a wreck. Need to find a way to edit button text and use that as breedLabel.text to coordinate w/ the rest of the code in this VC

class NewUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var breeds = [String]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
//    @IBOutlet weak var usernameField: UITextField!
//    @IBOutlet weak var passwordField: UITextField!
//    @IBOutlet weak var emailField: UITextField!
//    @IBOutlet weak var profilePic: UIImageView!


    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var selectedPic: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var breedBtn: UIButton!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var createBtn: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button Animation
        self.createBtn.setBackgroundColor(color: UIColor.clear, forState: .normal)
        self.createBtn.setTitleColor(UIColor.white, for: .normal)
        self.createBtn.setBackgroundColor(color: UIColor.white, forState: .highlighted)
        self.createBtn.setTitleColor(UIColor.purple, for: .highlighted)
        self.createBtn.setBackgroundColor(color: UIColor.white, forState: .selected)
        self.createBtn.setTitleColor(UIColor.purple, for: .selected)
        
        let dogs = Breeds()
        let myDogs = dogs.breedList
        breeds = myDogs
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        
        self.nameField.backgroundColor = UIColor.clear
        self.usernameField.backgroundColor = UIColor.clear
        self.passwordField.backgroundColor = UIColor.clear
        self.emailField.backgroundColor = UIColor.clear
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // PickerView //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return breeds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return breeds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        breedLabel.text = breeds[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "SanFranciscoText-Light", size: 14)
        
        // where data is an Array of String
        label.text = breeds[row]
        
        return label
    }
    
    // ImagePicker //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            selectedPic.isHidden = false
            selectedPic.image = image
            imageSelected = true
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions

    @IBAction func selectImagePress(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Creating a New User //

    @IBAction func createPress(_ sender: Any) {
    
        guard let name = nameField.text, name != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a name!")
            return
        }
        guard let username = usernameField.text, username != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a username!")
            return
        }
        guard let password = passwordField.text, password != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid password!")
            return
        }
        guard let email = emailField.text, email != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }
        
        guard let breed = breedLabel.text, breed != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid breed!")
            return
        }
        
        guard imageSelected == true else {
            showWarningMessage("Error", subTitle: "You have not selected an image!")
            return
        }
        
        let pictureData = UIImageJPEGRepresentation(self.selectedPic.image!, 0.70)
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                
                print("BRIAN: Could not create user")
                
            } else {
                
                print("BRIAN: The user has been created.")
                self.setUserInfo(user: user, email: email, password: password, username: username, name: name, breed: breed, proPic: pictureData as NSData!)
                
            }
        })
        
    }
    
    func setUserInfo(user: FIRUser!, email: String, password: String, username: String, name: String, breed: String, proPic: NSData!) {
        
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
                    
                    
                    self.saveUserInfo(user: user, username: username, name: name, password: password, breed: breed, image: url)
                    
                }
            }
        }
    }
    
    
    // This is func completeSignInID.createFIRDBuser from SocialApp1. Instead of only providing "provider": user.providerID - there is additional information provided - for the username, profile pic, etc. We need to provide a place for this information to be input. //
    
    private func saveUserInfo(user: FIRUser!, username: String, name: String, password: String, breed: String, image: String) {
        
        
        let userInfo = ["email": user.email!, "username": username , "name": name, "uid": user.uid , "breed": breed, "photoURL": image, "provider": user.providerID]
        
        self.completeSignIn(id: user.uid, userData: userInfo)
        print("BRIAN: User info has been saved to the database")
        
    }
    

    @IBAction func selectedBreed(_ sender: Any) {
        pickerView.isHidden = false
    }
    
    


    @IBAction func backBtnPrs(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    // Duplicative function - can I refactor this to DataService?
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("BRIAN: Segway completed \(keychainResult)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
        self.present(vc, animated: true, completion: nil)
    }
    
}


