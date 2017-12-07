//
//  WelcomeVC.swift
//  
//
//  Created by MacBook Air on 10/7/17.
//
//

import UIKit
import Firebase 

class WelcomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func tutorialPress(_ sender: Any) {
    }
    
    @IBAction func skipPress(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Tab")
        self.present(vc, animated: true, completion: nil)
    }
    
}
