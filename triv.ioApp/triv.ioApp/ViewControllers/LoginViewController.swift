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

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var errorDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        if let token = AccessToken.current,
           !token.isExpired {
//            fireBaseFaceBookLogin(accessToken: token.tokenString)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: NSNotification.Name("SuccessfulSignInNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewController(identifier: "homeViewController")
        guard let navC = self.navigationController else {
            assertionFailure("couldn't find nav")
            return
        }
        navC.setViewControllers([homeViewController], animated: true)
    }
}
