//
//  PostVC.swift
//  Barked
//
//  Created by MacBook Air on 5/1/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox

class PostVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var profilePicLoaded = false
    var indicator = UIActivityIndicatorView()
    
    // Firebase References
    
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    var storageRef: FIRStorage { return FIRStorage.storage() }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UITextField! 
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var currentUser: UILabel!
    @IBOutlet weak var chooseImage: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelBtn.isHidden = true
        
        // Button Animation
        self.chooseImage.setBackgroundColor(color: UIColor.clear, forState: .normal)
        self.chooseImage.setTitleColor(UIColor.white, for: .normal)
        self.chooseImage.setBackgroundColor(color: UIColor.white, forState: .highlighted)
        self.chooseImage.setTitleColor(UIColor.purple, for: .highlighted)
        self.chooseImage.setBackgroundColor(color: UIColor.white, forState: .selected)
        self.chooseImage.setTitleColor(UIColor.purple, for: .selected)
 

        profilePic.isHidden = true
        currentUser.isHidden = true
        chooseImage.isHidden = false
        
        loadUserInfo()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if imageSelected == false {
        chooseImage.isHidden = false
        } else {
            chooseImage.isHidden = true
        }
    }
    
    // MARK: - Activity Indicator
    
    func startIndicator() {
        hideSubviews()
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(indicator)
        
        indicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopIndicator() {
        showSubviews()
        indicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //Hide all subviews but indicator
    func hideSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.alpha = 0.25
            }
        }
    }
    
    //Show all subviews but indicator
    func showSubviews() {
        for view in self.view.subviews {
            if view != indicator {
                view.alpha = 1.0
            }
        }
    }
    
    // Load Current User's Profile Pic
    
    func loadUserInfo(){
        userRef.observe(.value, with: { (snapshot) in
            
            let user = Users(snapshot: snapshot)
            let imageURL = user.photoURL!
            self.currentUser.text = user.username
            
            /// We are downloading the current user's ImageURL then converting it using "data" to the UIImage which takes a property of data
            self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        if let data = imgData {
                            self.profilePic.image = UIImage(data: data)
                            self.profilePicLoaded = true
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
    
    
    // Image Picker Controller
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImage.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    @IBAction func chooseImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        chooseImage.isHidden = true
        cancelBtn.isHidden = false 
    }
    


    @IBAction func postImage(_ sender: Any) {
        
        guard let caption = postText.text, caption != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a caption!")
            return
        }
        
        guard let img = postImage.image, imageSelected == true else {
            showWarningMessage("Error", subTitle: "You have not selected an image!")
            return
        }
        
        guard let proImg = profilePic.image, profilePicLoaded == true else {
            print("BRIAN: The user has no profile pic!")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            startIndicator()
            
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
                        
                        if let imgDatar = UIImageJPEGRepresentation(proImg, 0.2) {
                            
                            let imgUidr = NSUUID().uuidString
                            let metadatar = FIRStorageMetadata()
                            metadatar.contentType = "image/jpeg"
                            
                            DataService.ds.REF_PRO_IMAGES.child(imgUidr).put(imgDatar, metadata: metadatar) { (metdata, error) in
                                if error != nil {
                                    print("BRIAN: Unable to upload image to Firebase storage")
                                } else {
                                    print("BRIAN: Successfully printed image to Firebase")
                                    let downloadURL = metdata?.downloadURL()?.absoluteString
                                    if let urlr = downloadURL {
                                        self.postToFirebase(imgUrl: url, imgUrlr: urlr)
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        chooseImage.isHidden = false
        cancelBtn.isHidden = true
        postImage.image = UIImage(named: "golden 2")
    }
    
    
    
    // MARK: Helper Methods
    
    func imagesForPost(imgUrl: String) -> String {
        let mainImg = imgUrl
        return mainImg
    }
    
    // Retrieve the Current Date //
    

    let realDate = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)


    // Posting to Firebase //
    
    func postToFirebase(imgUrl: String, imgUrlr: String) {
        soundEffect()
        playSound()
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let post: Dictionary<String, Any> = [
            "caption": postText.text!,
            "imageURL": imgUrl,
            "likes": 0,
            "postUser": currentUser.text!,
            "profilePicURL": imgUrlr,
            "currentDate": realDate,
            "uid": uid!,
            "bestInShow": false
        ]
        
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        stopIndicator()
        postText.text = ""
        imageSelected = false
        postImage.image = UIImage(named: "add-image")
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    // Play Sounds
    
    var gameSound: SystemSoundID = 0
    
    func soundEffect() {
        let path = Bundle.main.path(forResource: "Post", ofType: "mp3")!
        let soundURL = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(gameSound)
    }

    
}
