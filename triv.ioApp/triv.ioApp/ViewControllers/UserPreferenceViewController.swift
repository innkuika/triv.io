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
    
    // messagePrompt for friend message copied
    var messagePrompt: MessagePrompt?
    let promptView = UIView()
    let editUserNameTextField = UITextField()
    let editUserNameErrorMessageLabel = UILabel()
    
    // pass in from homeView
    var ref: DatabaseReference!
    var avatarNumber: Int?
    var userName: String?
    var userId: String?
    var coinNumber: Int?
    
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        getUserProfileData()
        workerGroup.enter()
        workerGroup.notify(queue: DispatchQueue.main) {
            self.renderUI()
        }
        
    }
    
    func renderUI(){
        print("render ui")
        // init message prompt
        messagePrompt = MessagePrompt(parentView: self)
        messagePrompt?.delegate = self
        
        guard let unwrappedAvatarNumber = avatarNumber else { return }
        guard let unwrappedCoinNumber = coinNumber else { return }
        
        styleButton(button: logoutButtonOutlet)
        avatarImageViewOutlet.image = UIImage(named: "Robot Avatars_\(unwrappedAvatarNumber).png")
        userNameLabelOutlet.text = userName
        coinNumberLabelOutlet.text = "\(unwrappedCoinNumber)"
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
                self.workerGroup.leave()
            }
            else {
                print("No data available")
            }


        }
    }
    
    @IBAction func editUserNameButtonPressed(_ sender: Any) {
        promptView.isHidden = false
        messagePrompt?.displayMessageWithTextField(view: self.view, messageText: "Hello", heightPercentage: 0.4, promptView: promptView, textField: editUserNameTextField, textFieldPlaceHoler: "Enter your new username", errorMessageLabel: editUserNameErrorMessageLabel)
    }
    
    @IBAction func uidButtonPressed(_ sender: Any) {
        guard let unwarppedUserId = userId else { return }
        UIPasteboard.general.string = generateFriendMessage(uid: unwarppedUserId)
        promptView.isHidden = false
        messagePrompt?.displayMessageWithButton(view: self.view, messageText: "Copied friend message! Send it to your friend and get connected.", heightPercentage: 0.25, buttonText: "Got it", promptView: promptView)
    }
    
    // message prompt implementation
    func buttonPressed() {
        promptView.isHidden = true
    }
    
    func textFieldLeftButtonPressed(){
        promptView.isHidden = true
    }
    
    func textFieldRightButtonPressed(){
        print("right button pressed")
        guard let newUserName = editUserNameTextField.text else { return }
        let newUserNameLength = newUserName.count
        if newUserNameLength == 0 {
            editUserNameErrorMessageLabel.text = "Please enter your user name"
        }
        else if newUserNameLength > userNameCharacterLimit {
            editUserNameErrorMessageLabel.text = "Please enter your user name"
        }
        else {
            guard let userId = Auth.auth().currentUser?.uid else {
                assertionFailure("Unable to get current logged in user")
                return
            }
            // push to database
            print(userId)
            self.ref.child("User/\(userId)/Name").setValue(newUserName)
            
            // dismiss prompt if user name is successfully set
            promptView.isHidden = true
            view.endEditing(true)
            userNameLabelOutlet.text = newUserName
        }
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
