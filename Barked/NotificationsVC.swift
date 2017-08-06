//
//  NotificationsVC.swift
//  Barked
//
//  Created by MacBook Air on 8/1/17.
//  Copyright © 2017 LionsEye. All rights reserved.
//

import UIKit
import Firebase

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var notifications = [Notification]()
    var databaseRef: FIRDatabaseReference!
    var storageRef: FIRStorage { return FIRStorage.storage() }
    var likesRef: FIRDatabaseReference!
    let userRef = DataService.ds.REF_BASE.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.items?[3].badgeValue = nil
        NOTE_BADGE_NUMBER = 0
        
        fetchNotifications()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tabBarController?.tabBar.items?[3].badgeValue = nil
        NOTE_BADGE_NUMBER = 0
    }
    
    func fetchNotifications() {
        DataService.ds.REF_CURRENT_USERS.child("notifications").observe(.value, with: { (snapshot) in
            self.notifications = []
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let noteDict = snap.value as? Dictionary<String, AnyObject> {
                        
                        let key = snap.key
                        let note = Notification(notificationKey: key, noteData: noteDict)
                        self.notifications.append(note)
                    }
                }
                self.notifications.sort(by: self.sortDatesFor)
                self.tableView.reloadData()
                self.updateNotes()
            }
        })
        
    }
    
    /// Playing around with change values in Firebase 
    
    func firebaseChangeObserver() {
        DataService.ds.REF_USERS.child("someUID").child("notifications")
    }
    
    // MARK: TableView 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.notificationLabel.text = notifications[indexPath.row].comment
        
        FIRStorage.storage().reference(forURL: notifications[indexPath.row].photoURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        cell.userImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        return cell
    }
    
    // MARK: Helper Functions
    
    /// Sort Feed of Posts by Current Date
    func sortDatesFor(this: Notification, that: Notification) -> Bool {
        return this.currentDate > that.currentDate
    }
    
//    func notificationsAreRead() {
//        DataService.ds.REF_CURRENT_USERS.child("notifications").observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
//                        if let postUser = postDict["read"] as? Bool {
//                            if postUser == false {
//                    
//                                self.updateNotes()
//                                self.tabBarController?.tabBar.items?[3].badgeValue = String(NOTE_BADGE_NUMBER)
//                                
//                            }
//                        }
//                    }
//                }
//            }
//        })
//    }
    
    func updateNotes() {
        for note in notifications {
            print("WEENER: Notifications are updated")
            let updatedNote = note
            DataService.ds.REF_CURRENT_USERS.child(note.notificationKey).observeSingleEvent(of: .value, with: { (snapshot) in
                updatedNote.adjustNotifications(read: true)
        })
    }
}


}
