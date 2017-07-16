//
//  SexyButton.swift
//  Barked
//
//  Created by MacBook Air on 5/2/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import QuartzCore

class SexyButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        layer.cornerRadius = 5.0
    }
    
}


