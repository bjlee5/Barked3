//
//  BoarderedView.swift
//  Barked
//
//  Created by MacBook Air on 6/15/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class BoarderedView: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
        
    }
}
