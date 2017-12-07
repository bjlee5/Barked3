//
//  FirstNewUserVC.swift
//  Barked
//
//  Created by MacBook Air on 10/7/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FirstNewUserVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Helper Functions 
    
//    private func setUserInfo(email: String, password: String) {
//        
//        
//        let userInfo = ["email": user.email!, "username": username , "uid": user.uid , "breed": breed, "photoURL": image, "provider": user.providerID]
//        
//        self.completeSignIn(id: user.uid, userData: userInfo)
//        print("BRIAN: User info has been saved to the database")
//        
//    }
    
    // MARK: Actions
    
    @IBAction func nextBtnPress(_ sender: Any) {
        
        guard let password = passwordField.text, password != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid password!")
            return
        }
        guard let email = emailAddressField.text, email != "" else {
            showWarningMessage("Error", subTitle: "You have not entered a valid e-mail!")
            return
        }

        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondNewUserVC") as! SecondNewUserVC
        vc.password = password
        vc.email = email
        self.present(vc, animated: true, completion: nil)
        print("BRIAN: The user has been created.")

    }
    
    
}
