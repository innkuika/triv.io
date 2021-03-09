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
    @IBOutlet weak var displayMessageOutlet: UILabel!
    @IBOutlet weak var goBackToHomeButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }
    
    func renderUI(){
        styleButton(button: goBackToHomeButtonOutlet)
        guard let unwrappedDisplayMessage = displayMessage else { return }
        displayMessageOutlet.text = unwrappedDisplayMessage
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

