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
    
    // Configures and presents an alert indicating that the user entered an invalid UID
    func showInvalidRequestPrompt(_ message: String?) {
        let message = message ?? "The player ID you entered is invalid."
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.showFriendRequestPrompt()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Sends a friend request to the player with the given UID
    func sendFriendRequest(_ requestUid: String) {
        
        // Checks if the current user is already friends with the player
        let friendUids = friends.compactMap { $0?.id }
        if friendUids.contains(requestUid) {
            showInvalidRequestPrompt("You are already friends with this player.")
            return
        }
        
        self.ref.child("User/\(requestUid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                // Add friend request
                guard let userDict = snapshot.value as? NSDictionary else { return }
                var friendRequests = userDict["FriendRequests"] as? [String] ?? []
                
                if !friendRequests.contains(self.uid) {
                    friendRequests.append(self.uid)
                    self.ref.child("User/\(requestUid)/FriendRequests").setValue(friendRequests)
                }
            } else {
                // The requestUid entered does not belong to a user
                DispatchQueue.main.async {
                    self.showInvalidRequestPrompt(nil)
                }
            }
        }
        
    }
    
    // Configures and presents an alert prompting the user to send a friend request
    func showFriendRequestPrompt() {
        let alert = UIAlertController(title: "Add New Friend", message: "Please enter the ID of the player you would like to send a friend request to.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let sendRequestAction = UIAlertAction(title: "Send Request", style: .default, handler: { _ in
            guard let alertTextFields = alert.textFields else { return }
            if let requestUid = alertTextFields[0].text {
                if requestUid == "" {
                    self.showInvalidRequestPrompt(nil)
                } else {
                    self.sendFriendRequest(requestUid)
                }
            } else {
                self.showInvalidRequestPrompt(nil)
            }
        })
        alert.addAction(sendRequestAction)
        alert.preferredAction = sendRequestAction
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addFriendButtonPress() {
        showFriendRequestPrompt()
    }
    
}
