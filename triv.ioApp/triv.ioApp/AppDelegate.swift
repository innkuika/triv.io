//
//  AppDelegate.swift
//  triv.ioApp
//
//  Created by Manprit Heer on 2/12/21.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import FBSDKCoreKit

//@main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var ref: DatabaseReference!
    // universal link functions
//    func presentProperViewController(_ gameID: gameIstanceID) {
//      let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//      guard
//        let categoryVC = storyboard
//          .instantiateViewController(withIdentifier: "CategorySelectionViewController")
//            as? CategorySelectionViewController,
//
//        let navigationVC = storyboard
//          .instantiateViewController(withIdentifier: "NavigationController")
//            as? UINavigationController
//      else { return }
//
//        categoryVC.item = computer
//      navigationVC.modalPresentationStyle = .formSheet
//      navigationVC.pushViewController(categoryVC, animated: true)
//    }
    

    func application(
      _ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?
    ) -> Void) -> Bool {
        
        
        
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL,
            let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }
      
        if let url = url,
           let decodedURL = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let gameID = decodedURL.queryItems?.first(where: {$0.name == "id"} )?.value{

            //find this game instance in database
            self.ref.child("GameInstance/\(gameID)").getData{ (error, snapshot) in
                if let error = error {
                    print("Error getting data \(error)")
                } else if snapshot.exists() {
                    
                    guard let GameInstanceDict = snapshot.value as? NSDictionary else { return }
                
                    //if user does not exist
                    
                    
                    
                    
                    //if user already exists
                    
                    
                    
                    
                    //become current player
                    
                    
                    
                    
                        
                    }
                }
            }
        }
        
      return false
        
    }
    
    
    // MARK: - Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                // Authorization NOT successful
                print("G authentication error \(error.localizedDescription)")
                return
            }
            //Authorization successful
            print("G Authorized correctly")
            
            NotificationCenter.default.post(name: Notification.Name("SuccessfulSignInNotification"), object: nil, userInfo: nil)
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Signed out of Google
    }
    
    // MARK: - FB and Google Sign In
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
    -> Bool {
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url)
        
        let facebookDidHandle : Bool = ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return googleDidHandle || facebookDidHandle
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        //Google Sign In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "triv_ioApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
      
