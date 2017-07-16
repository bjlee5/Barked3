//
//  EditProfile.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    var breeds = [String]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var nameField: UITextField! 
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var changeProBtn: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var breedField: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cancelBtn: RoundButton!
    @IBOutlet weak var doneBtn: RoundButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dogs = Breeds()
        let myDogs = dogs.breedList
        breeds = myDogs
        
        usernameField.backgroundColor = UIColor.clear
        emailField.backgroundColor = UIColor.clear
        breedField.backgroundColor = UIColor.clear
        nameField.backgroundColor = UIColor.clear
        
        cancelBtn.titleLabel?.layer.shadowRadius = 3
        cancelBtn.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        cancelBtn.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        cancelBtn.titleLabel?.layer.shadowOpacity = 0.5
        cancelBtn.titleLabel?.layer.masksToBounds = false
        
        doneBtn.titleLabel?.layer.shadowRadius = 3
        doneBtn.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        doneBtn.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        doneBtn.titleLabel?.layer.shadowOpacity = 0.5
        doneBtn.titleLabel?.layer.masksToBounds = false
        
        changeProBtn.titleLabel?.layer.shadowRadius = 3
        changeProBtn.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        changeProBtn.titleLabel?.layer.shadowOffset = CGSize(width: 0, height: 1)
        changeProBtn.titleLabel?.layer.shadowOpacity = 0.5
        changeProBtn.titleLabel?.layer.masksToBounds = false
        
        fetchCurrentUser()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        pickerView.isHidden = true
        pickerView.delegate = self
        pickerView.dataSource = self
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
        breedField.text = breeds[row]
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
        label.font = UIFont(name: "SanFranciscoText-Light", size: 12)
        
        // where data is an Array of String
        label.text = breeds[row]
        
        return label
    }

    
    
    func fetchCurrentUser() {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            self.usernameField.text = user.username
            if user.name == nil {
                self.nameField.text = user.username
            } else {
                self.nameField.text = user.name
            }
            self.emailField.text = user.email
            self.breedField.text = user.breed
            let imageURL = user.photoURL!
            
            // Clean up profilePic is storage - model after the post-pic, which is creating a folder in storage. This is too messy right now.
            
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
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
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
        
         profilePic.image = image
         imageSelected = true
        
        }
            imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    

    @IBAction func changeProPic(_ sender: Any) {

        present(imagePicker, animated: true, completion: nil)
    }
    


    @IBAction func updateProfile(_ sender: Any) {
        let user = FIRAuth.auth()?.currentUser
        
        guard let username = usernameField.text, username != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid username!")
            return
        }
        
        guard let name = nameField.text, name != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid name!")
            return
        }
        
        guard let email = emailField.text, email != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }
        
        guard let breed = breedField.text, breed != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }
        
        
        let pictureData = UIImageJPEGRepresentation(self.profilePic.image!, 0.70)
        
        let imgUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        DataService.ds.REF_PRO_IMAGES.child(imgUid).put(pictureData! as Data, metadata: metadata) { (newMetaData, error) in
            
            if error != nil {
                
                print("BRIAN: Error uploading profile Pic to Firebase")
                
            } else {
                print("BRIAN: New metadata stuff's workin.")
                
                let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                changeRequest?.didChangeValue(forKey: "email")
                changeRequest?.displayName = username
                changeRequest?.didChangeValue(forKey: "name")
                changeRequest?.didChangeValue(forKey: "breed")
                
                user?.updateEmail(email, completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                })
                
                let photoString = newMetaData!.downloadURL()?.absoluteString
                let photoURL = newMetaData!.downloadURL()
                changeRequest?.photoURL = photoURL
                
                changeRequest?.commitChanges(completion: { (error) in
                    
                    if error == nil {
                        
                        let user = FIRAuth.auth()?.currentUser
                        let userInfo = ["email": user!.email!, "username": username as Any, "name": name as Any, "breed": breed as Any, "uid": user!.uid, "photoURL": photoString!] as [String : Any]
                        
                        let userRef = DataService.ds.REF_USERS.child((user?.uid)!)
                        userRef.updateChildValues(userInfo)
                        print("BRIAN: New values saved properly!")
                        
                    }
                })
                
            }
        }
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    

    @IBAction func editPress(_ sender: Any) {
        pickerView.isHidden = false 
    }



    @IBAction func cancelPress(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBAction func deleteAccount(_ sender: Any) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Delete") {
            self.delete()
        }
        alertView.addButton("Cancel") {
            
        }
        alertView.showError("WARNING", subTitle: "Are you sure you want to delete your account?")
        
        
    }
    
    func delete() {
        let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            
            FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
                
                if error == nil {
                    
                    print("BRIAN: Account successfully deleted!")
                    DispatchQueue.main.async {
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
                        self.present(vc, animated: true, completion: nil)
                        
                        
                    }
                    
                } else {
                    
                    print(error?.localizedDescription)
                }
            })
        })
        
    }
    
}

