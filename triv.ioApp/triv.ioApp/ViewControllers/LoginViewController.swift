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
import CryptoKit
import AuthenticationServices



class LoginViewController: UIViewController, LoginButtonDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    @IBOutlet weak var logoOutlet: UIImageView!
    @IBOutlet weak var GoogleButtonOutlet: GIDSignInButton!
    let FaceBookButton = FBLoginButton()
    @IBOutlet weak var errorDescription: UILabel!
    var ref: DatabaseReference!
    let AppleButton = ASAuthorizationAppleIDButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        setUpSignInButton()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    
        FaceBookButton.delegate = self
        FaceBookButton.permissions = ["public_profile", "email"]
       
        renderUI()
        
        
        if let token = AccessToken.current, !token.isExpired {
            //fireBaseFaceBookLogin(accessToken: token.tokenString)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSignIn), name: NSNotification.Name("SuccessfulSignInNotification"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func renderUI(){
        let frameWidth = view.frame.width
        let frameHeight = view.frame.height
        
        AppleButton.frame = CGRect(x: 0, y: 0, width: frameWidth * 0.7, height: 40)
        AppleButton.center = CGPoint(x: frameWidth * 0.5, y: frameHeight * 0.70)
        view.addSubview(AppleButton)

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
        errorDescription.textColor = UIColor.white
        
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
    
    //MARK: - Apple Authentication
    
    func setUpSignInButton() {
//        let button = ASAuthorizationAppleIDButton()
        AppleButton.addTarget(self, action: #selector(handleSignInWithAppleTapped), for: .touchUpInside)
//        button.center = view.center
//        view.addSubview(button)
    }
    
    @objc func handleSignInWithAppleTapped() {
        performSignIn()
    }
    
    
    //    @available(iOS 13, *)
    //    func startSignInWithAppleFlow() {
    //      let nonce = randomNonceString()
    //      currentNonce = nonce
    //      let appleIDProvider = ASAuthorizationAppleIDProvider()
    //      let request = appleIDProvider.createRequest()
    //      request.requestedScopes = [.fullName, .email]
    //      request.nonce = sha256(nonce)
    //
    //      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    //      authorizationController.delegate = self
    //      authorizationController.presentationContextProvider = self
    //      authorizationController.performRequests()
    //    }
    
    func performSignIn() {
        let request = createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
    
        authorizationController.performRequests()
    }
    
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest {
        let AppleIDProvider = ASAuthorizationAppleIDProvider()
        let request = AppleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    // Creates random Number Used Once to give to Firebase
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    //hashing function needed for nonce
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    //Protocol for ASAuthorizationControllerDelegate
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    //Protocol for ASAuthorizationControllerPresentationContextProviding
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else{
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else{
                print("Unable to retrieve identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else{
                print("Unable to retrive idTokenString \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if let user = authDataResult?.user {
                    print("Signed in as \(user.uid), email: \(user.email ?? "email error")")
                }
            }
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
