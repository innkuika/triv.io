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
