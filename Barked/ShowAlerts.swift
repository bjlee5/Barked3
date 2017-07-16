//
//  ShowAlerts.swift
//  Barked
//
//  Created by MacBook Air on 4/28/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import AudioToolbox


func showWarningMessage(_ message: String, subTitle: String = "") {
    let alertView = SCLAlertView()
    alertView.showError(message, subTitle: subTitle)
    barkSoundEffect()
    playSound()
}

func showComplete(_ message: String, subTitle: String = "") {
    let alertView = SCLAlertView()
    alertView.showSuccess(message, subTitle: subTitle)
}

func showNotice(_ message: String, subTitle: String = "") {
    
    let appearance = SCLAlertView.SCLAppearance(
        kTitleFont: UIFont(name: "HelveticaNeue", size: 14)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
        showCloseButton: false
    )
    
    let alertView = SCLAlertView(appearance: appearance)
    alertView.showNotice(message, subTitle: subTitle)
    barkSoundEffect()
    playSound()
    
}

// Play Sounds

var gameSound: SystemSoundID = 0

func barkSoundEffect() {
    let path = Bundle.main.path(forResource: "ErrorBark", ofType: "wav")!
    let soundURL = URL(fileURLWithPath: path)
    AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
}

func playSound() {
    AudioServicesPlaySystemSound(gameSound)
}
