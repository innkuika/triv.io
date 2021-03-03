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
    @IBOutlet weak var startNewGameButtonOutlet: UIButton!
    @IBOutlet weak var joinGameViaCodeButtonOutlet: UIButton!
    @IBOutlet weak var logOutButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: startNewGameButtonOutlet)
        styleButton(button: joinGameViaCodeButtonOutlet)
        styleButton(button: logOutButtonOutlet)
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
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        print("Log out button pressed")
       
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            
            if let tokenString = AccessToken.current?.tokenString{
                print("facebook logged in")
                let loginManager = LoginManager()
                loginManager.logOut()
            }
            else {
                print("no facebook login")
            }
            
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as? LoginViewController else {
                assertionFailure("cannot instantiate categorySelectionViewController")
                return
            }
            self.navigationController?.pushViewController(loginViewController, animated: true)
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func leaderboardButtonPressed(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let leaderboardViewController = storyboard.instantiateViewController(identifier: "leaderboardViewController") as? LeaderboardViewController else {
            assertionFailure("cannot instantiate leaderboardViewController")
            return
        }
        self.navigationController?.pushViewController(leaderboardViewController, animated: true)
    }
    
    
}
