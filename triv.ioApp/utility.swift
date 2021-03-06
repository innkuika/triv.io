//
//  utility.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/23/21.
//

import Foundation
import UIKit
import SwiftFortuneWheel
import Firebase
import FirebaseDatabase

let trivioRed = UIColor(red: 233/255, green: 70/255, blue: 60/255, alpha: 1.0)
let trivioOrange = UIColor(red: 239/255, green: 135/255, blue: 57/255, alpha: 1.0)
let trivioYellow = UIColor(red: 240/255, green: 192/255, blue: 66/255, alpha: 1.0)
let trivioGreen = UIColor(red: 117/255, green: 252/255, blue: 151/255, alpha: 1.0)
let trivioBlue = UIColor(red: 37/255, green: 90/255, blue: 246/255, alpha: 1.0)
let trivioPurple = UIColor(red: 92/255, green: 61/255, blue: 245/255, alpha: 1.0)
let trivioBackgroundColor = UIColor(red: 12/255, green: 25/255, blue: 54/255, alpha: 1.0)

let userNameCharacterLimit = 20


func styleButton(button: UIButton){
    button.layer.cornerRadius = 10
    button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: 25)
    button.titleLabel?.textColor = trivioBackgroundColor
}

func styleCircleButton(button: UIButton){
    button.layer.cornerRadius =  button.frame.size.width / 2
    button.clipsToBounds = true
}

func generateFriendMessage(uid: String) -> String{
    return "[triv.io] Add me as a friend in triv.io! Copy this whole message and go to add new friend page. \(uid)."
}


@objc protocol MessagePromptDelegate {
    // implement if using displayMessageWithButton
    @objc optional func buttonPressed()
    
    // implement if using displayMessageWithTextField
    @objc optional func textFieldLeftButtonPressed()
    @objc optional func textFieldRightButtonPressed()
}


class MessagePrompt {
    
    var parentViewController: UIViewController
    var delegate: MessagePromptDelegate?
    
    // Call within a view controller and pass in self
    init(parentView: UIViewController) {
        parentViewController = parentView
    }
    
    
    func displayMessageWithButton(view: UIView, messageText: String, heightPercentage: Float, buttonText: String, promptView: UIView){
        
        basicSetup(view: view, messageText: messageText, heightPercentage: heightPercentage, yPosition: 0.85, promptView: promptView)

        // add button
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: promptView.frame.width * 0.8, height: promptView.frame.height * 0.2)
        button.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 0.80)
        button.setTitle(buttonText, for: .normal)
        button.backgroundColor = trivioPurple
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(self.buttonPressedHandler), for: .touchUpInside)
        promptView.addSubview(button)
    }
    
    func displayMessageWithTextField(view: UIView, messageText: String, heightPercentage: Float, promptView: UIView, textField: UITextField, textFieldPlaceHolder: String, errorMessageLabel: UILabel){
        
        basicSetup(view: view, messageText: messageText, heightPercentage: heightPercentage, yPosition: 0.4, promptView: promptView)
        
        // create textfield and add to popup view
        textField.frame = CGRect(x: 5, y: 5, width: promptView.frame.size.width - 60, height: 40)
        textField.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 0.4)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.placeholder = textFieldPlaceHolder
        promptView.addSubview(textField)
        
        // create left button and add to popup view
        let leftButton = UIButton()
        leftButton.frame = CGRect(x: 40, y: 100, width: promptView.frame.size.width * 0.3, height: 50)
        leftButton.setTitle("Cancel", for: .normal)
        leftButton.backgroundColor = trivioRed
        leftButton.addTarget(self, action: #selector(self.textFieldLeftButtonPressedHandler), for:.touchUpInside)
        leftButton.center = CGPoint(x: promptView.frame.size.width * 0.25, y: promptView.frame.size.height * 4 / 5)
        leftButton.layer.cornerRadius = 20
        promptView.addSubview(leftButton)

        // create right button and add to popup view
        let rightButton = UIButton()
        rightButton.frame = CGRect(x: 40, y: 100, width: promptView.frame.size.width * 0.35, height: 50)
        rightButton.setTitle("OK", for: .normal)
        rightButton.backgroundColor = trivioBlue
        rightButton.addTarget(self, action: #selector(self.textFieldRightButtonPressedHandler), for:.touchUpInside)
        rightButton.center = CGPoint(x: promptView.frame.size.width * 0.75, y: promptView.frame.size.height * 4 / 5)
        rightButton.layer.cornerRadius = 20
        promptView.addSubview(rightButton)
        
        //   create error message label and add to popup view
        errorMessageLabel.frame = CGRect(x: 5, y: 5, width: promptView.frame.size.width - 60, height: 60)
        errorMessageLabel.textColor = trivioRed
        errorMessageLabel.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 3 / 5)
        promptView.addSubview(errorMessageLabel)
    }
    
    func basicSetup(view: UIView, messageText: String, heightPercentage: Float, yPosition: Float, promptView: UIView){
        // add subview to view
        promptView.frame = CGRect(x: 0, y: 0, width:  view.frame.width * 0.85, height: view.frame.height * CGFloat(heightPercentage))
        promptView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height * CGFloat(yPosition))
        promptView.backgroundColor = trivioYellow
        promptView.layer.cornerRadius = 20
        UIView.transition(with: parentViewController.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
          view.addSubview(promptView)
        }, completion: nil)
        
        // add shadow
        promptView.layer.shadowColor = UIColor.purple.cgColor
        promptView.layer.shadowRadius = 5
        promptView.layer.shadowOpacity = 1
        promptView.layer.shadowOffset = .zero

        // add main message text
        let promptMessage = UILabel()
        promptMessage.frame = CGRect(x: 0, y: 0, width: promptView.frame.width * 0.9, height: promptView.frame.height * 0.3)
        promptMessage.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 0.20)
        promptMessage.text = messageText
        promptMessage.textAlignment = .center
        promptMessage.numberOfLines = 4
        promptMessage.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        promptView.addSubview(promptMessage)
    }
    
    @objc private func buttonPressedHandler() {
        self.delegate?.buttonPressed?()
    }
    @objc private func textFieldLeftButtonPressedHandler() {
        self.delegate?.textFieldLeftButtonPressed?()
    }
    @objc private func textFieldRightButtonPressedHandler() {
        self.delegate?.textFieldRightButtonPressed?()
    }
    
}
