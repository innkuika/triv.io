//
//  HomeViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FBSDKLoginKit

class HomeViewController: UIViewController {
    @IBOutlet weak var leaderboardButtonOutlet: UIButton!
    @IBOutlet weak var startNewGameButtonOutlet: UIButton!
    @IBOutlet weak var joinGameViaCodeButtonOutlet: UIButton!
    @IBOutlet weak var userPreferenceButtonOutlet: UIButton!
    
    // query from db
    var ref: DatabaseReference!
    var avatarNumber: Int?
    var userName: String?
    var userId: String?
    var coinNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationItem.hidesBackButton = true
        getUserProfileData()
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: startNewGameButtonOutlet)
        styleButton(button: joinGameViaCodeButtonOutlet)
        styleCircleButton(button: leaderboardButtonOutlet)
    }
    
    // MARK: -UI action handlers
    
    @IBAction func addAQuestionButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let cqCreationViewController = storyboard.instantiateViewController(identifier: "cqCreationViewController") as? CQCreationViewController else {
            assertionFailure("cannot instantiate cqCreationViewController")
            return
        }
        navigationController?.pushViewController(cqCreationViewController, animated: true)
    }
    
    @IBAction func startGameButtonPress() {
        // create new game instance
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        let gameInstance = GameModel(userId: user.uid)
        
        // navigate to CategorySelectionViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
            assertionFailure("cannot instantiate categorySelectionViewController")
            return
        }
        // pass game instance to categorySelectionViewController
        categorySelectionViewController.gameInstance = gameInstance
        
        navigationController?.pushViewController(categorySelectionViewController, animated: true)
    }
    
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let leaderboardViewController = storyboard.instantiateViewController(identifier: "leaderboardViewController") as? LeaderboardViewController else {
            assertionFailure("cannot instantiate leaderboardViewController")
            return
        }
        self.navigationController?.pushViewController(leaderboardViewController, animated: true)
    }
    
    @IBAction func friendsButtonPressed() {
        // Navigate to Friend List View
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let friendListViewController = storyboard.instantiateViewController(identifier: "friendListViewController") as? FriendListViewController else {
            assertionFailure("cannot instantiate friendListViewController")
            return
        }
        self.navigationController?.pushViewController(friendListViewController, animated: true)
    }
    
    @IBAction func userPreferenceButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let userPreferenceViewController = storyboard.instantiateViewController(identifier: "userPreferenceViewController") as? UserPreferenceViewController else {
            assertionFailure("cannot instantiate userPreferenceViewController")
            return
        }
        self.navigationController?.pushViewController(userPreferenceViewController, animated: true)
    }
    
    func getUserProfileData(){
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        self.userId = user.uid

        self.ref.child("User/\(user.uid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                print("Got data \(snapshot.value!)")
                let value = snapshot.value as? NSDictionary
                // get user profile info
                let unwrappedAvatarNumber = value?["AvatarNumber"] as? Int ?? 1
                guard let unwrappedUserName = value?["Name"] as? String else { return }
                let unwrappedCoinNumber = value?["CoinNumber"] as? Int ?? 0

                self.userName = unwrappedUserName
                self.avatarNumber = unwrappedAvatarNumber
                self.coinNumber = unwrappedCoinNumber
            }
            else {
                print("No data available")
            }


        }
    }
}
