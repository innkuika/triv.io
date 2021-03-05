//
//  FriendListViewController.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 3/4/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendListViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var friendRequestView: UIView!
    @IBOutlet weak var friendRequestLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    
    var uid = ""
    var ref: DatabaseReference!
    var friends: [UserModel?] = []
    var requestUid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendRequestView.isHidden = true
        
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        uid = user.uid
        ref = Database.database().reference()
        
        friendsTableView.dataSource = self
        
        loadFriends()
        loadFriendRequests()
    }
    
    // Retrieve friend list from database
    func loadFriends() {
        self.ref.child("User").child(uid).child("Friends").observe(.value) { (snapshot) in
            self.friends = []
            if snapshot.exists() {
                guard let friendUids = snapshot.value as? [String] else { return }
                
                // Initialize semaphores for accessing friends array and reloading data inside the table view
                let accessSem = DispatchSemaphore(value: 1)
                let waitSem = DispatchSemaphore(value: 0)
                
                // Retrieve user data of each friend
                for fuid in friendUids {
                    DispatchQueue.global(qos: .default).async {
                        self.ref.child("User/\(fuid)").getData { (error, snapshot) in
                            if let error = error {
                                print("Error getting data \(error)")
                            } else if snapshot.exists() {
                                guard let userDict = snapshot.value as? NSDictionary else { return }
                                
                                accessSem.wait()
                                self.friends.append(UserModel(
                                    name: userDict["Name"] as? String,
                                    streak_score: userDict["Streak"] as? Int,
                                    id: fuid,
                                    database: 0
                                ))
                                accessSem.signal()
                                
                                waitSem.signal()
                            }
                        }
                    }
                }
                
                for _ in 1...friendUids.count {
                    waitSem.wait()
                }
                
                self.friendsTableView.reloadData()
            }
        }
    }
    
    // Retrieve pending friend requests from database
    func loadFriendRequests() {
        self.ref.child("User").child(uid).child("FriendRequests").observe(.value) { (snapshot) in
            if snapshot.exists() {
                guard var requestUids = snapshot.value as? [String] else { return }
                
                if requestUids.count > 0 {
                    self.requestUid = requestUids.removeFirst()
                    
                    // Retrieve user data associated with the user who sent the friend request
                    self.ref.child("User/\(self.requestUid)").getData { (error, snapshot) in
                        if let error = error {
                            print("Error getting data \(error)")
                        } else if snapshot.exists() {
                            // Show friend request
                            guard let userDict = snapshot.value as? NSDictionary else { return }
                            
                            DispatchQueue.main.async {
                                self.friendRequestLabel.text = "\(userDict["Name"] as? String ?? "Player") (UID: \(self.requestUid)) has sent you a friend request."
                                self.friendRequestView.isHidden = false
                            }
                        }
                    }
                } else {
                    // No pending friend requests
                    self.friendRequestView.isHidden = true
                }
            } else {
                // No pending friend requests
                self.friendRequestView.isHidden = true
            }
        }
    }

    // MARK: -UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") ?? UITableViewCell(style: .default, reuseIdentifier: "friendCell")
        
        let fname = friends[indexPath.row]?.name ?? "Player"
        let fuid = friends[indexPath.row]?.id ?? ""
        
        cell.textLabel?.text = "\(fname) (\(fuid))"
        
        // TODO: Replace default image with player avatar
        cell.imageView?.image = UIImage(systemName: "person.fill")
        
        cell.textLabel?.textColor = UIColor.white
        cell.imageView?.tintColor = UIColor.white
        cell.backgroundColor = trivioBackgroundColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = trivioBlue
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    // MARK: -UI action handlers
    @IBAction func acceptButtonPress() {
        self.ref.child("User/\(uid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                guard let userDict = snapshot.value as? NSDictionary else { return }
                
                // Add friend to friend list
                var friendUids = userDict["Friends"] as? [String] ?? []
                friendUids.append(self.requestUid)
                self.ref.child("User/\(self.uid)/Friends").setValue(friendUids)
                
                // Remove friend request
                var friendRequests = userDict["FriendRequests"] as? [String] ?? []
                if friendRequests.count > 0 {
                    friendRequests.removeFirst()
                }
                self.ref.child("User/\(self.uid)/FriendRequests").setValue(friendRequests)
            }
        }
        // Add current user to friend list of their new friend
        self.ref.child("User/\(requestUid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                // Add current user to friend list
                guard let userDict = snapshot.value as? NSDictionary else { return }
                var friendUids = userDict["Friends"] as? [String] ?? []
                friendUids.append(self.uid)
                self.ref.child("User/\(self.requestUid)/Friends").setValue(friendUids)
            }
        }
    }
    
    @IBAction func declineButtonPress() {
        self.ref.child("User/\(uid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                // Remove friend request
                guard let userDict = snapshot.value as? NSDictionary else { return }
                var friendRequests = userDict["FriendRequests"] as? [String] ?? []
                if friendRequests.count > 0 {
                    friendRequests.removeFirst()
                }
                self.ref.child("User/\(self.uid)/FriendRequests").setValue(friendRequests)
            }
        }
    }
    
    @IBAction func addFriendButtonPress() {
        let alert = UIAlertController(title: "Add New Friend", message: "Please enter the player ID that you would like to send a friend request to.", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Send Friend Request", style: .default, handler: { _ in
            guard let textFields = alert.textFields else { return }
            let input = textFields[0].text ?? ""
            self.ref.child("User").child(input).getData { (error, snapshot) in
                if snapshot.exists() {
                    let value = snapshot.value as? NSDictionary
                    var friendRequests = value?["FriendRequests"] as? [String] ?? []
                    friendRequests.append(self.uid)
                    self.ref.child("User/\(input)/FriendRequests").setValue(friendRequests)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
