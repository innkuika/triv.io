//
//  ViewController.swift
//  triv.ioApp
//
//  Created by Manprit Heer on 2/12/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // for testing, can be safely removed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
            assertionFailure("cannot instantiate spinWheelViewController")
            return
        }
        self.navigationController?.pushViewController(spinWheelViewController, animated: true)
    }


}

