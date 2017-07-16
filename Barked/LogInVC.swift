//
//  ViewController.swift
//  Barked
//
//  Created by MacBook Air on 4/27/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import SwiftKeychainWrapper
import AudioToolbox

class LogInVC: UIViewController {
    
    let user = FIRAuth.auth()?.currentUser
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInBtn: RoundButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button Animation
        self.signInBtn.setBackgroundColor(color: UIColor.clear, forState: .normal)
        self.signInBtn.setTitleColor(UIColor.white, for: .normal)
        self.signInBtn.setBackgroundColor(color: UIColor.white, forState: .highlighted)
        self.signInBtn.setTitleColor(UIColor.purple, for: .highlighted)
        self.signInBtn.setBackgroundColor(color: UIColor.white, forState: .selected)
        self.signInBtn.setTitleColor(UIColor.purple, for: .selected)

        self.loginField.backgroundColor = UIColor.clear
        self.passwordField.backgroundColor = UIColor.clear 
        
        showCurrentUser()
        shakeHeadSound()
        playSound()
        
        // Dismiss Keyboard //
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("BRIAN: ID found in keychain")
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showCurrentUser() {
        if FIRAuth.auth()?.currentUser != nil {
            print("BRIAN: There is somebody signed in!!!")
        } else {
            print("BRIAN: Aint nobody signed in!!!")
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("BRIAN: Unable to authenticate with Firebase")
                print("BRIAN: \(error?.localizedDescription)")
            } else {
                print("BRIAN: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["email": self.loginField.text!, "password": self.passwordField.text!]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
        
    }
    
    /* let userData = ["provider": user.providerID]
     self.completeSignIn(id: user.uid, userData: userData)*/
    
    // This is not signing the user in properly. Stops an e-mail that hasn't been authenticated but will not sign in a current user //
    

    @IBAction func loginPress(_ sender: Any) {
    
        guard loginField.text != "", passwordField.text != "" else {
            showWarningMessage("Error", subTitle: "Please ensure E-mail and Password fields are filled in!")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: loginField.text!, password: passwordField.text!, completion: { (user, error) in
            if let error = error {
                print("BRIAN: Password and E-mail address do not match our records!")
                
                showWarningMessage("Error", subTitle: "The password or E-mail you have entered do not match our records!")
            }
            if let user = user {
                let userData = ["email": self.loginField.text!, "password": self.passwordField.text!]
                self.completeSignIn(id: user.uid, userData: userData)
                print("BRIAN: You've successefully signed in with your e-mail player")
            }
        })
    }
    
    @IBAction func facebookLoginPress(_ sender: Any) {
    
//                let facebookLogin = FBSDKLoginManager()
//        
//                facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//                    if error != nil {
//                        print("BRIAN: Unable to Authenticate")
//                    } else if result?.isCancelled == true {
//                        print("BRIAN: User canceled Facebook authentication")
//                    } else {
//                        print("BRIAN: Succesfully autheticated with Facebook")
//                        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                        self.firebaseAuth(credential)
//        
//                    }
//                }
    }
    

    @IBAction func createPress(_ sender: Any) {
    
        performSegue(withIdentifier: "NewUserVC", sender: self)
    }
    
    // Add Logic here for the Facebook users - if provider is Facebook and username == nil then reroute to editProfile VC... would then need to add logic to support blank username, pic, etc there...
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
//        
//        if user?.providerID == "Faceebook" {
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditProfileVC")
//            self.present(vc, animated: true, completion: nil)
//        }
        
        print("BRIAN: Segway completed \(keychainResult)")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
        self.present(vc, animated: true, completion: nil)
        
    }

    @IBAction func forgotPW(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPasswordVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    // Play Sounds
    
    var gameSound: SystemSoundID = 0
    
    func shakeHeadSound() {
        let path = Bundle.main.path(forResource: "DogShakingHead", ofType: "wav")!
        let soundURL = URL(fileURLWithPath: path)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(gameSound)
    }

    
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: UIColor.white])
        }
    }
}


