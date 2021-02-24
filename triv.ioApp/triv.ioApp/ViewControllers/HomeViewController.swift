//
//  HomeViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -UI action handlers
    @IBAction func startGameButtonPress() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
            assertionFailure("cannot instantiate categorySelectionViewController")
            return
        }
        navigationController?.pushViewController(categorySelectionViewController, animated: true)
    }
    
}
