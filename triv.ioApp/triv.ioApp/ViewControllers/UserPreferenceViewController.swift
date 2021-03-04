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

class UserPreferenceViewController: UIViewController, MessagePromptDelegate{
    
    
    @IBOutlet weak var avatarImageViewOutlet: UIImageView!
    @IBOutlet weak var userNameLabelOutlet: UILabel!
    @IBOutlet weak var uidButtonOutlet: UIButton!
    @IBOutlet weak var coinNumberLabelOutlet: UILabel!
    
    let workerGroup = DispatchGroup()
    
    var messagePrompt: MessagePrompt?
    let promptView = UIView()

    
    // query from database
    var ref: DatabaseReference!
    var avatarNumber = 1
    var userName = "guest"
    var userId = ""
    var coinNumber = 0
    
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        workerGroup.enter()
        
        // get latest data from database
        getUserProfileData()
        
        // do following once finish querying data from database
        workerGroup.notify(queue: DispatchQueue.main) {
            self.renderUI()
        }
    }
    
    func renderUI(){
        // init message prompt
        messagePrompt = MessagePrompt(parentView: self)
        messagePrompt?.delegate = self

        
        styleButton(button: logoutButtonOutlet)
        print("user id: \(userId)")
        avatarImageViewOutlet.image = UIImage(named: "Robot Avatars_\(avatarNumber).png")
        userNameLabelOutlet.text = userName

        coinNumberLabelOutlet.text = "\(coinNumber)"
    }
    @IBAction func uidButtonPressed(_ sender: Any) {
        UIPasteboard.general.string = generateFriendMessage(uid: userId)
        promptView.isHidden = false
        messagePrompt?.displayMessage(view: self.view, messageText: "Copied friend message! Send it to your friend and get connected.", heightPercentage: 0.25, buttonText: "Got it", promptView: promptView)


    }
    
    func tapped() {
        print("tapped")
    }
    
    func buttonPressed() {
        print("pressed")
        promptView.isHidden = true
    }
    
    
    func getUserProfileData(){
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        
        self.userId = user.uid
        
        self.ref.child("User/\(user.uid)").observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            // get user profile info
            let unwrappedAvatarNumber = value?["AvatarNumber"] as? Int ?? 1
            guard let unwrappedUserName = value?["Name"] as? String else { return }
            guard let unwrappedCoinNumber = value?["AvatarNumber"] as? Int else { return }
            
            self.userName = unwrappedUserName
            self.avatarNumber = unwrappedAvatarNumber
            self.coinNumber = unwrappedCoinNumber
        })
        workerGroup.leave()
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
