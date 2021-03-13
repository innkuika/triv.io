//
//  FriendListViewController.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 3/4/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessagePromptDelegate, UITextFieldDelegate {

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var friendRequestView: UIView!
    @IBOutlet weak var friendRequestLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var addNewFriendButtonOutlet: UIButton!
    
    var uid = ""
    var ref: DatabaseReference!
    var friends: [UserModel?] = []
    var requestUid = ""
    
    // messagePrompt for friend message copied or send friend request button pressed
    var messagePrompt: MessagePrompt?
    let uidPromptView = UIView()
    let requestPromptView = UIView()
    let requestTextField = UITextField()
    let requestErrorMessageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleButton(button: addNewFriendButtonOutlet)
        friendRequestView.isHidden = true
        
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        uid = user.uid
        
        // init message prompt
        messagePrompt = MessagePrompt(parentView: self)
        messagePrompt?.delegate = self
        
        requestTextField.delegate = self
        requestErrorMessageLabel.numberOfLines = 2
        
        ref = Database.database().reference()
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
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
                                    database: 0,
                                    avatar_number: userDict["AvatarNumber"] as? Int
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
                                self.friendRequestLabel.text = "\(userDict["Name"] as? String ?? "Player") (ID: \(self.requestUid)) has sent you a friend request."
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? FriendTableViewCell ?? FriendTableViewCell(style: .default, reuseIdentifier: "friendCell")
        
        let fname = friends[indexPath.row]?.name ?? "guest"
        let fuid = friends[indexPath.row]?.id ?? ""
        let avatarNumber = friends[indexPath.row]?.avatar_number ?? 1
        
        cell.usernameLabel.text = fname
        cell.uidLabel.text = "ID: \(fuid)"
        
        // TODO: Replace default image with player avatar
        cell.avatarImageView.image = UIImage(named: "Robot Avatars_\(avatarNumber).png")
        
        cell.usernameLabel.textColor = UIColor.white
        cell.uidLabel.textColor = UIColor.white
        cell.avatarImageView.tintColor = UIColor.white
        cell.backgroundColor = trivioBackgroundColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = trivioBlue
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    // MARK: -UITableViewDelegate implementation
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
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
    
    // Sends a friend request to the player with the given UID
    func sendFriendRequest(_ requestUid: String) {
        
        if requestUid == uid {
            requestErrorMessageLabel.text = "You entered your own ID."
            return
        }
        
        // Checks if the current user is already friends with the player
        let friendUids = friends.compactMap { $0?.id }
        if friendUids.contains(requestUid) {
            requestErrorMessageLabel.text = "You are already friends with this player."
            return
        }
        
        self.ref.child("User/\(requestUid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                // Add friend request
                guard let userDict = snapshot.value as? NSDictionary else { return }
                var friendRequests = userDict["FriendRequests"] as? [String] ?? []
                
                if friendRequests.contains(self.uid) {
                    DispatchQueue.main.async {
                        self.requestErrorMessageLabel.text = "You have already sent this player a friend request."
                    }
                } else {
                    friendRequests.append(self.uid)
                    self.ref.child("User/\(requestUid)/FriendRequests").setValue(friendRequests)
                    DispatchQueue.main.async {
                        self.requestTextField.endEditing(true)
                        self.requestPromptView.isHidden = true
                    }
                }
            } else {
                // The requestUid entered does not belong to a user
                DispatchQueue.main.async {
                    self.requestErrorMessageLabel.text = "The player ID you entered is invalid."
                }
            }
        }
        
    }
    
    // Copies friend invitation message to pasteboard
    @IBAction func uidButtonPress() {
        UIPasteboard.general.string = generateFriendMessage(uid: uid)
        uidPromptView.isHidden = false
        messagePrompt?.displayMessageWithButton(view: self.view, messageText: "Copied friend message! Send it to your friend and get connected.", heightPercentage: 0.25, buttonText: "Got it", promptView: uidPromptView)
    }
    
    @IBAction func addFriendButtonPress() {
        requestTextField.text = nil
        
        // Try to get UID from pasteboard
        let strings = UIPasteboard.general.strings ?? []
        
        for str in strings {
            do {
                let pattern = NSRegularExpression.escapedPattern(for: "[triv.io] Add me as a friend in triv.io! Copy this whole message and go to add new friend page. ") + "(.+)" + NSRegularExpression.escapedPattern(for: ".")
                let regex = try NSRegularExpression(pattern: pattern)
                
                if let match = regex.firstMatch(in: str, range: NSMakeRange(0, str.count)) {
                    // Found a match in pasteboard
                    requestTextField.text = (str as NSString).substring(with: match.range(at: 1))
                }
            } catch {
                assertionFailure("regex expression is invalid")
            }
        }
        
        requestErrorMessageLabel.text = nil
        
        requestPromptView.isHidden = false
        messagePrompt?.displayMessageWithTextField(view: self.view, messageText: "Please enter the ID of the player you would like to send a friend request to.", heightPercentage: 0.4, promptView: requestPromptView, textField: requestTextField, textFieldPlaceHolder: "", errorMessageLabel: requestErrorMessageLabel)
    }
    
    // MARK: -MessagePromptDelegate implementation
    func buttonPressed() {
        uidPromptView.isHidden = true
    }
    
    func textFieldLeftButtonPressed() {
        requestTextField.endEditing(true)
        requestPromptView.isHidden = true
    }
    
    func textFieldRightButtonPressed() {
        if let requestUid = requestTextField.text {
            if requestUid == "" {
                requestErrorMessageLabel.text = "Please enter a valid player ID."
            } else {
                sendFriendRequest(requestUid)
            }
        } else {
            requestErrorMessageLabel.text = "Please enter a valid player ID."
        }
    }
    
    // MARK: -UITextFieldDelegate implementation
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let requestUid = requestTextField.text {
            if requestUid == "" {
                requestErrorMessageLabel.text = "Please enter a valid player ID."
            } else {
                sendFriendRequest(requestUid)
            }
        } else {
            requestErrorMessageLabel.text = "Please enter a valid player ID."
        }
        return false
    }
    
}
