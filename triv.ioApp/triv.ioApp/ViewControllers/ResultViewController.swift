//
//  ResultViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/27/21.
//

import Foundation
import UIKit

class ResultViewController: UIViewController{
    var playerDidWin: Bool?
    @IBOutlet weak var winningStatusLabelOutlet: UILabel!
    @IBOutlet weak var goBacktoHomeButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: goBacktoHomeButtonOutlet)
        guard let unwrappedWinningStatus = playerDidWin else { return }
        winningStatusLabelOutlet.text = unwrappedWinningStatus ? "YOU WIN" : "YOU LOSE"
    }
    
    @IBAction func goBacktoHomeButtonPressed(_ sender: Any) {
        // navigate to homeView
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeViewController = storyboard.instantiateViewController(identifier: "homeViewController") as? HomeViewController else {
            assertionFailure("cannot instantiate homeViewController")
            return
        }
        
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
}
