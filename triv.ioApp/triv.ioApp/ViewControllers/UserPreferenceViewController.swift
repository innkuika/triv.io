//
//  UserPreferenceViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 3/3/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FBSDKLoginKit

class UserPreferenceViewController: UIViewController{
    
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: logoutButtonOutlet)

    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
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
}
