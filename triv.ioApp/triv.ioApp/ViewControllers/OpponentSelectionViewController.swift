//
//  OpponentSelectionViewController.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 3/4/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OpponentSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var friendsTableView: UITableView!
    
    // Passed in from CategorySelectionViewController
    var gameInstance: GameModel?
    
    var uid = ""
    var ref: DatabaseReference!
    var friends: [UserModel?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        uid = user.uid
        ref = Database.database().reference()
        
        friendsTableView.dataSource = self
        
        loadFriends()
        
        friendsTableView.delegate = self
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
        
        let playLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        playLabel.text = "Play"
        playLabel.textColor = trivioGreen
        cell.accessoryView = playLabel
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
    
    // MARK: -UI action handlers
    @IBAction func shareLinkButtonPress() {
        // set game status to pending
        guard let unwrappedGameInstanceId = gameInstance?.gameInstanceId else { return }
        self.ref.child("GameInstance/\(unwrappedGameInstanceId)/GameStatus").setValue("pending")
        // navigate to pendingMessageViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pendingMessageViewController = storyboard.instantiateViewController(identifier: "pendingMessageViewController") as? PendingMessageViewController else {
            assertionFailure("cannot instantiate pendingMessageViewController")
            return
        }
        guard let unwrappedGameId = gameInstance?.gameInstanceId else { return }
        pendingMessageViewController.displayMessage = pendingMessageShareGameLink(gameLink: unwrappedGameId)
        
        navigationController?.pushViewController(pendingMessageViewController, animated: true)
    }
    
    @IBAction func randomMatchButtonPress() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
            assertionFailure("cannot instantiate spinWheelViewController")
            return
        }
        let viewControllers = [spinWheelViewController]
        // pass game instance to spinWheelViewController
        spinWheelViewController.gameInstance = gameInstance
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
}
