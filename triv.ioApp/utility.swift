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
    func tapped()
    func buttonPressed()
}

class MessagePrompt {
    
    var parentViewController: UIViewController
    var delegate: MessagePromptDelegate?
    
    // Call within a view controller and pass in self
    init(parentView: UIViewController) {
        parentViewController = parentView
    }
    
    // with sub message and tap to continue function
    func displayMessage(view: UIView, messageText: String, heightPercentage: Float, subMessageText: String, promptView: UIView){
        // add subview to view
        promptView.frame = CGRect(x: 0, y: 0, width:  view.frame.width * 0.85, height: view.frame.height * CGFloat(heightPercentage))
        promptView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height * 0.80)
        promptView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
        promptView.layer.cornerRadius = 20
        // tap to continue
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        view.addGestureRecognizer(tap)

        // add shadow
        promptView.layer.shadowColor = UIColor.purple.cgColor
        promptView.layer.shadowRadius = 5
        promptView.layer.shadowOpacity = 1
        promptView.layer.shadowOffset = .zero
        UIView.transition(with: parentViewController.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
          view.addSubview(promptView)
        }, completion: nil)
        
        
        // add main message text
        let promptMessage = UILabel()
        promptMessage.frame = CGRect(x: 0, y: 0, width: promptView.frame.width * 0.9, height: promptView.frame.height * 0.3)
        promptMessage.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 0.20)
        promptMessage.text = messageText
        promptMessage.textAlignment = .center
        promptMessage.numberOfLines = 4
        promptMessage.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        promptView.addSubview(promptMessage)
        
        // add sub message text
        let subMessage = UILabel()
        subMessage.frame = CGRect(x: 0, y: 0, width: promptView.frame.width * 0.9, height: promptView.frame.height * 0.2)
        subMessage.center = CGPoint(x: promptView.frame.size.width / 2, y: promptView.frame.size.height * 0.80)
        subMessage.text = subMessageText
        subMessage.textAlignment = .center
        subMessage.textColor = UIColor.gray
        subMessage.numberOfLines = 3
        subMessage.font = UIFont(name: "PingFangSC-Semibold", size: 14)
        promptView.addSubview(subMessage)
    }
    
    
    func displayMessage(view: UIView, messageText: String, heightPercentage: Float, buttonText: String, promptView: UIView){
        // add subview to view
        promptView.frame = CGRect(x: 0, y: 0, width:  view.frame.width * 0.85, height: view.frame.height * CGFloat(heightPercentage))
        promptView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height * 0.85)
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
    
    @objc private func tapHandler() {
        self.delegate?.tapped()
    }
    
    @objc private func buttonPressedHandler() {
        self.delegate?.buttonPressed()
    }
}
