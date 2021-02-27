//
//  HomeViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class HomeViewController: UIViewController {
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    // MARK: -UI action handlers
    @IBAction func startGameButtonPress() {
        // create a game instance and push to database
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        let gameInstanceRef = self.ref.child("GameInstance").childByAutoId()
        gameInstanceRef.setValue(["CurrentTurn": user.uid,
                                  "PlayerIds": [user.uid, "bot"],
                                  "Players": [user.uid: ["Score": [], "Streak": 0],
                                              "bot": ["Score": [], "Streak": 0]],
                                  "Categories": []])
        
        // navigate to CategorySelectionViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
            assertionFailure("cannot instantiate categorySelectionViewController")
            return
        }
        // pass game instance to categorySelectionViewController
        categorySelectionViewController.gameInstanceRef = gameInstanceRef
        
        navigationController?.pushViewController(categorySelectionViewController, animated: true)
    }
    
}
