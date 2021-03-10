//
//  questionViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/18/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class QuestionViewController: UIViewController {
    var ref: DatabaseReference!
    // passed in from SpinWheelViewController
    var questionCategory: String?
    var gameInstance: GameModel?
    
    // init in viewDidLoad
    var key: String?
    var answerArray: [String] = []
    var questionPrompt: String?
    
    @IBOutlet weak var questionLabelOutlet: UILabel!
    @IBOutlet weak var answerAButtonOutlet: UIButton!
    @IBOutlet weak var answerBButtonOutlet: UIButton!
    @IBOutlet weak var answerCButtonOutlet: UIButton!
    @IBOutlet weak var answerDButtonOutlet: UIButton!
    @IBOutlet weak var resultLabelOutlet: UILabel!
    
    let workerGroup = DispatchGroup()
    
    override func viewDidLoad() {
        navigationItem.hidesBackButton = true
        rendeUI()
        
        ref = Database.database().reference()
        workerGroup.enter()
        // query random question in questionCategory, answers and key from database
        getRandomQuestion()
        
        workerGroup.notify(queue: DispatchQueue.main) {
            self.questionDidLoad()
        }
    }
    
    func rendeUI() {
        styleButton(button: answerAButtonOutlet)
        styleButton(button: answerBButtonOutlet)
        styleButton(button: answerCButtonOutlet)
        styleButton(button: answerDButtonOutlet)
        
        resultLabelOutlet.text = ""
    }
    
    func questionDidLoad(){
        let answerButtonOutletArray = [answerAButtonOutlet, answerBButtonOutlet, answerCButtonOutlet, answerDButtonOutlet]
        
        questionLabelOutlet.text = questionPrompt
        Array(zip(answerButtonOutletArray, answerArray)).forEach {
            $0.0?.setTitle($0.1, for: .normal)
            $0.0?.addTarget(self, action: #selector(self.answerButtonClickHandler), for: .touchUpInside)
        }
    }
    
    func getRandomQuestion(){
        guard let unwrappedQuestionCategory = questionCategory else { return }
        let categoryRef = ref.child("Categories/\(unwrappedQuestionCategory)")
        categoryRef.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                let numberOfQuestions = snapshot.childrenCount
                var randomIndex = 0
                if numberOfQuestions != 1 {
                    randomIndex = Int.random(in: 0..<Int(numberOfQuestions)-1)
                }
                categoryRef.child(String(randomIndex)).getData{ (error, snapshot) in
                    if let error = error {
                        print("Error getting data \(error)")
                    }
                    else if snapshot.exists() {
                        guard let questionID = snapshot.value as? String else { return }
                        self.ref.child("Question").child(questionID).getData{ (error, snapshot) in
                            if let error = error {
                                print("Error getting data \(error)")
                            }
                            else if snapshot.exists() {
                                let questionDict = snapshot.value as? NSDictionary
                                guard let unwrappedPrompt = questionDict?["Prompt"] as? String else { return }
                                guard let unwrappedOption = questionDict?["Option"] as? [String] else { return }
                                guard let unwrappedKey = questionDict?["Key"] as? String else { return }
                                
                                self.questionPrompt = unwrappedPrompt
                                self.answerArray = unwrappedOption
                                self.key = unwrappedKey
                                
                                self.workerGroup.leave()
                            }
                            else { print("No question data available") }
                        }
                    }
                    else { print("No question id data available") }
                }
            }
            else { print("No category data available") }
        }
        
        
    }
    
    @objc func answerButtonClickHandler(sender: UIButton) {
        DispatchQueue.global().async(execute: {
            DispatchQueue.main.sync {
                guard let key = self.key else { return }
                guard let answer = sender.titleLabel?.text else { return }
        
                if key == answer {
                    self.resultLabelOutlet.text = "correct"
                    self.resultLabelOutlet.textColor = UIColor.white
                    self.resultLabelOutlet.backgroundColor = trivioGreen
                }
                else {
                    self.resultLabelOutlet.text = "incorrect"
                    self.resultLabelOutlet.textColor = UIColor.white
                    self.resultLabelOutlet.backgroundColor = trivioRed
                }
            }
            DispatchQueue.main.async {
                // give user time to see the result
                sleep(2)
            
//                let botAnswerCorrect = self.answerArray[2] == self.key
                let userAnswerCorrect = sender.titleLabel?.text == self.key
                guard let unwrappedGameInstanceID = self.gameInstance?.gameInstanceId else { return }
                guard let unwrappedQuestionCategory = self.questionCategory else { return }
                guard let user = Auth.auth().currentUser else {
                    assertionFailure("Unable to get current logged in user")
                    return
                }
                
//                if botAnswerCorrect {
//                    self.gameInstance?.getUserPlayer(id: "bot")?.updatePlayerScore(gameInstanceID: unwrappedGameInstanceID, newScore: unwrappedQuestionCategory)
//                }
                if userAnswerCorrect{
                    self.gameInstance?.getUserPlayer(id: user.uid)?.updatePlayerScore(gameInstanceID: unwrappedGameInstanceID, newScore: unwrappedQuestionCategory)
                    
                    // navigate back to spinWheelViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
                        assertionFailure("cannot instantiate spinWheelViewController")
                        return
                    }
                    spinWheelViewController.gameInstance = self.gameInstance
                    self.navigationController?.pushViewController(spinWheelViewController, animated: true)
                }
                
                // determine if we need to flip turn
//                guard let currentPlayer = self.gameInstance?.currentTurn else { return }
//                if (currentPlayer == user.uid && !userAnswerCorrect)||(currentPlayer != user.uid && !botAnswerCorrect) {
//                    self.gameInstance?.flipTurn()
//                }
                
                if (!userAnswerCorrect){
                    self.gameInstance?.flipTurn()
                    
                    // navigate to pendingMessageViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let pendingMessageViewController = storyboard.instantiateViewController(identifier: "pendingMessageViewController") as? PendingMessageViewController else {
                        assertionFailure("cannot instantiate pendingMessageViewController")
                        return
                    }
                    pendingMessageViewController.displayMessage = generateFlipTurnMessage()
                    
                    self.navigationController?.pushViewController(pendingMessageViewController, animated: true)
                    
                }
    
            }
        
        })

    }
}
