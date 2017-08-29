//
//  NotificationCell.swift
//  Barked
//
//  Created by MacBook Air on 8/2/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class NotificationCell: UITableViewCell {

    var notification: Notification!
    
    @IBOutlet weak var userImage: BoarderedCircleImage!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var unreadImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(notification: Notification) {
        
        self.notification = notification
        
    }

}
