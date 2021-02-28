//
//  LoginViewController.swift
//  triv.ioApp
//
//  Created by Roberto Lozano on 2/22/21.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var logoOutlet: UIImageView!
    @IBOutlet weak var GoogleButtonOutlet: GIDSignInButton!
    let FaceBookButton = FBLoginButton()
    @IBOutlet weak var errorDescription: UILabel!
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    
        FaceBookButton.delegate = self
        FaceBookButton.permissions = ["public_profile", "email"]
       
        renderUI()
        
        
        if let token = AccessToken.current, !token.isExpired {
//            fireBaseFaceBookLogin(accessToken: token.tokenString)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: NSNotification.Name("SuccessfulSignInNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func renderUI(){
        let frameWidth = view.frame.width
        let frameHeight = view.frame.height
        
        FaceBookButton.frame = CGRect(x: 0, y: 0, width: frameWidth * 0.7, height: 40)
        FaceBookButton.center = CGPoint(x: frameWidth * 0.5, y: frameHeight * 0.80)
        
        view.addSubview(FaceBookButton)
        GoogleButtonOutlet.frame = CGRect(x: 0, y: 0, width: frameWidth * 0.7, height: 40)
        GoogleButtonOutlet.center = CGPoint(x: frameWidth * 0.5, y: frameHeight * 0.9)
        
        logoOutlet.frame = CGRect(x: 0, y: 0, width: frameWidth * 1.0, height: frameWidth)
        logoOutlet.center = CGPoint(x: frameWidth * 0.5, y: frameHeight * 0.35)
        
        errorDescription.text = ""
        errorDescription.frame = CGRect(x: 0, y: 0, width: frameWidth * 0.80, height: frameHeight * 0.16)
        errorDescription.center = CGPoint(x: frameWidth * 0.5, y: frameHeight * 0.65)
        errorDescription.backgroundColor = view.backgroundColor
        
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Facebook
    //Facebook Login Button Pressed
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        print("makes it here")
        
        guard let tokenString = AccessToken.current?.tokenString else {
            return
        }
        fireBaseFaceBookLogin(accessToken: tokenString)
        
        return
    }
    
    //Facebook Logout Button Pressed
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        return
    }
    
    //Authenticate Facebook with Firebase
    func fireBaseFaceBookLogin(accessToken: String) {
        //        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
                
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Unsuccessful Authentication \(error)")
                print(error.localizedDescription)
                self.errorDescription.text = error.localizedDescription
                return
            }
            NotificationCenter.default.post(name: Notification.Name("SuccessfulSignInNotification"), object: nil, userInfo: nil)
            
        }
    }
    
    //MARK: - Change VC after successful login
    @objc func didSignIn()  {
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        print("user signed in")
        self.ref.child("User/\(user.uid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                print("Got data \(snapshot.value!)")
            }
            else {
                print("No data available")
                // if user doesn't exist, create new user and push to database
                // FIXME: try to access user name
                self.ref.child("User").child(user.uid).setValue(["Name": "guest", "Streak": 0])
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "homeViewController")
        guard let navC = self.navigationController else {
            assertionFailure("couldn't find nav")
            return
        }
        navC.setViewControllers([homeViewController], animated: true)
    }
}
