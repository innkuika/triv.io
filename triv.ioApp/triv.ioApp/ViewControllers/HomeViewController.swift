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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: startNewGameButtonOutlet)
        styleButton(button: joinGameViaCodeButtonOutlet)
        styleCircleButton(button: leaderboardButtonOutlet)
    }
    
    // MARK: -UI action handlers
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
    
    
    
    @IBAction func userPreferenceButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let userPreferenceViewController = storyboard.instantiateViewController(identifier: "userPreferenceViewController") as? UserPreferenceViewController else {
            assertionFailure("cannot instantiate userPreferenceViewController")
            return
        }
        self.navigationController?.pushViewController(userPreferenceViewController, animated: true)


        
    }
    
//    @IBAction func userPreferenceButtonPressed(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let userPreferenceViewController = storyboard.instantiateViewController(identifier: "userPreferenceViewController") as? UserPreferenceViewController else {
//            assertionFailure("cannot instantiate userPreferenceViewController")
//            return
//        }
//        self.navigationController?.pushViewController(userPreferenceViewController, animated: true)
//
//    }
    
}
