//
//  ViewController.swift
//  triv.ioApp
//
//  Created by Manprit Heer on 2/12/21.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func homeButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let homeViewController = storyboard.instantiateViewController(identifier: "HomeViewController") as? HomeViewController else {
            assertionFailure("Couldn't cast to HomeViewController")
            return
        }
        navigationController?.setViewControllers([homeViewController], animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // for testing, can be safely removed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
            assertionFailure("cannot instantiate categorySelectionViewController")
            return
        }
        self.navigationController?.pushViewController(categorySelectionViewController, animated: true)
    }


}

