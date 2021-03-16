//
//  QuestionSubmissionViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/16/21.
//

import UIKit

class QuestionSubmissionViewController: UIViewController {
    
    var displayMessage: String? = "Your question was successfully submitted!"
    @IBOutlet weak var displayMessageOutlet: UILabel!
    @IBOutlet weak var goBackToHomeButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        renderUI()
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
