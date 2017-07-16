//
//  ForgotPasswordVC.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var forgotPW: RoundButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button Animation
        self.forgotPW.setBackgroundColor(color: UIColor.clear, forState: .normal)
        self.forgotPW.setTitleColor(UIColor.white, for: .normal)
        self.forgotPW.setBackgroundColor(color: UIColor.white, forState: .highlighted)
        self.forgotPW.setTitleColor(UIColor.purple, for: .highlighted)
        self.forgotPW.setBackgroundColor(color: UIColor.white, forState: .selected)
        self.forgotPW.setTitleColor(UIColor.purple, for: .selected)
        
    }
    

    @IBAction func resetPassword(_ sender: Any) {
    
        let email = emailField.text!
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                showComplete("Password", subTitle: "You will receive an e-mail momentarily with instructions!")
                
            } else {
                showWarningMessage("Oops!", subTitle: "Please enter a valid e-mail address")
                print(error?.localizedDescription)
            }
            
        })
    }
    

    @IBAction func backPressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LogInVC")
        self.present(vc, animated: true, completion: nil)
    }
    
}
extension UIButton {
    
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}

