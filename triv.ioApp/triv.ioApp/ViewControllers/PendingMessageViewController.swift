//
//  PendingMessageViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 3/8/21.
//

import Foundation
import UIKit

class PendingMessageViewController: UIViewController{
    var displayMessage: String?
    var gameInstanceId: String?
    var displayCopyGameCodeButton: Bool?
    @IBOutlet weak var displayMessageOutlet: UILabel!
    @IBOutlet weak var goBackToHomeButtonOutlet: UIButton!
    @IBOutlet weak var copyGameCodeButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        renderUI()
    }
    
    func renderUI(){
        let willDisplayCopyGameCodeButton = displayCopyGameCodeButton ?? false
        if !willDisplayCopyGameCodeButton {
            copyGameCodeButtonOutlet.isHidden = true
        }
        
        styleButton(button: goBackToHomeButtonOutlet)
        guard let unwrappedDisplayMessage = displayMessage else { return }
        displayMessageOutlet.text = unwrappedDisplayMessage
    }
    
    @IBAction func copyGameCodeButtonPressed(_ sender: Any) {
        guard let unwrappedGameInstanceId = gameInstanceId else { return }
        UIPasteboard.general.string = unwrappedGameInstanceId   
    }
    
    @IBAction func goBackToHomeButtonPressed(_ sender: Any) {
        // navigate to homeView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeViewController = storyboard.instantiateViewController(identifier: "homeViewController") as? HomeViewController else {
            assertionFailure("cannot instantiate homeViewController")
            return
        }
        
        navigationController?.pushViewController(homeViewController, animated: true)
    }
}

