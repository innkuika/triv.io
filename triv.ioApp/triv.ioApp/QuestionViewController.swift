//
//  questionViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/18/21.
//

import Foundation
import UIKit

class QuestionViewController: UIViewController {
    // passed in from SpinWheelViewController
    var questionCategory: String?
    
    // init in viewDidLoad
    var key: String?
    
    @IBOutlet weak var questionLabelOutlet: UILabel!
    @IBOutlet weak var answerAButtonOutlet: UIButton!
    @IBOutlet weak var answerBButtonOutlet: UIButton!
    @IBOutlet weak var answerCButtonOutlet: UIButton!
    @IBOutlet weak var answerDButtonOutlet: UIButton!
    @IBOutlet weak var resultLabelOutlet: UILabel!
    
    override func viewDidLoad() {
        // TODO: query random question in questionCategory, answers and key from database
        let questionPrompt = "How tall is the space needle?"
        let answerArray = ["149 ft", "395 ft", "605 ft", "728 ft"]
        key = "605 ft"
        
        let answerButtonOutletArray = [answerAButtonOutlet, answerBButtonOutlet, answerCButtonOutlet, answerDButtonOutlet]
        
        questionLabelOutlet.text = questionPrompt
        Array(zip(answerButtonOutletArray, answerArray)).forEach {
            $0.0?.setTitle($0.1, for: .normal)
            $0.0?.addTarget(self, action: #selector(self.answerButtonClickHandler), for: .touchUpInside)
        }
        
        
    }
    
    @objc func answerButtonClickHandler(sender: UIButton) {
        guard let key = key else { return }
        guard let answer = sender.titleLabel?.text else { return }
        
        if key == answer {
            resultLabelOutlet.text = "correct"
        }
        else {
            resultLabelOutlet.text = "incorrect"
        }
        
        // TODO: push result to database
        
        // give user time to see the result
        sleep(2)
        
        // navigate back to spinWheelViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
            assertionFailure("cannot instantiate spinWheelViewController")
            return
        }
        navigationController?.pushViewController(spinWheelViewController, animated: true)
    }
}
