//
//  SpinWheelView.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/17/21.
//

import Foundation
import UIKit
import SwiftFortuneWheel
import FirebaseDatabase
import FirebaseAuth


class SpinWheelViewController: UIViewController {

    @IBOutlet weak var scoreBoardUIViewOutlet: UIView!
    @IBOutlet weak var spinButtonOutlet: UIButton!
    @IBOutlet weak var fortuneWheelViewOutlet: SwiftFortuneWheel!
    // pass in the category names here
    var SpinWheelTextArray: [String] = ["small KT", "middle KT", "big KT", "XL KT", "cute KT", "fat KT"]
    var SpinWheelColorArray = [trivioRed, trivioBlue, trivioYellow, trivioPurple, trivioGreen, trivioOrange]
    var finishIndex: Int?
    
    // query from database
    var gameInstanceRef: DatabaseReference!
    var isUserTurn = true
    let userScore: [String] = ["small KT", "big KT"]
    let botScore: [String] = ["middle KT", "XL KT"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: query current game state (userScore, botScore, isUserTurn) from database and render accordingly
        
        renderWheel()
        renderScoreBoard(userScore: userScore, botScore: botScore)
        let finishIndex = Int.random(in: 0 ..< SpinWheelTextArray.count)
        
        // get questionViewController and prepare navigation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let questionViewController = storyboard.instantiateViewController(identifier: "questionViewController") as? QuestionViewController else {
            assertionFailure("cannot instantiate questionViewController")
            return
        }
        
        // if it's not user's turn, it's bot's turn and will spin automatically
        if !isUserTurn{
            spinButtonOutlet.isEnabled = false
            fortuneWheelViewOutlet.startRotationAnimation(finishIndex: finishIndex, continuousRotationTime: 1) { (finished) in
            questionViewController.questionCategory = self.SpinWheelTextArray[finishIndex]
            self.navigationController?.pushViewController(questionViewController, animated: true)
                }
        }
    }
    
    func renderWheel() {
        var slices: [Slice] = []
        // wheel customization
        SpinWheelTextArray.forEach {
            let textSliceContent = Slice.ContentType.text(text: $0, preferences: textPreference())
            let slice = Slice(contents: [textSliceContent])
            slices.append(slice)
        }
        fortuneWheelViewOutlet.spinImage = "redCenterImage"
        fortuneWheelViewOutlet.pinImage = "redArrow"
        fortuneWheelViewOutlet.isSpinEnabled = false
        fortuneWheelViewOutlet.pinImageViewCollisionEffect = CollisionEffect(force: 15, angle: 30)
        fortuneWheelViewOutlet.edgeCollisionDetectionOn = true
        fortuneWheelViewOutlet.slices = slices

        
        fortuneWheelViewOutlet.configuration = wheelConfiguration()
    }
    
    let scoreArcStartAngleArray = [180, 216, 252, 288, 324]
    func renderScoreBoard(userScore: [String], botScore: [String]){
        renderScore(playerScore: userScore, isUser: true)
        renderScore(playerScore: botScore, isUser: false)
    }
    
    func textPreference() -> TextPreferences{
        let font =  UIFont.systemFont(ofSize: 23, weight: .heavy)
        var textPreferences = TextPreferences(textColorType: SFWConfiguration.ColorType.customPatternColors(colors: nil, defaultColor: .white),font: font,verticalOffset: 5)
        
        textPreferences.orientation = .vertical
        textPreferences.alignment = .right
        return textPreferences
    }
    
    func wheelConfiguration () -> SFWConfiguration{
        // wheel customizations
        let pin = SFWConfiguration.PinImageViewPreferences(size: CGSize(width: 13, height: 40), position: .top, verticalOffset: -25)
        let spin = SFWConfiguration.SpinButtonPreferences(size: CGSize(width: 20, height: 20))
        let colorArray = SpinWheelColorArray
        let sliceColorType = SFWConfiguration.ColorType.customPatternColors(colors: colorArray, defaultColor: SFWColor.white)
        let slicePreferences = SFWConfiguration.SlicePreferences(backgroundColorType: sliceColorType, strokeWidth: 0, strokeColor: .black)
        let circlePreferences = SFWConfiguration.CirclePreferences(strokeWidth: 25, strokeColor: UIColor(red: 28/255, green: 71/255, blue: 126/255, alpha: 1.0))
        var wheelPreferences = SFWConfiguration.WheelPreferences(circlePreferences: circlePreferences, slicePreferences: slicePreferences, startPosition: .bottom)
        

        let centerAnchorImage = SFWConfiguration.AnchorImage(imageName: "blueAnchorImage", size: CGSize(width: 15, height: 15), verticalOffset: -6)
        wheelPreferences.centerImageAnchor = centerAnchorImage
//        let anchorImage = SFWConfiguration.AnchorImage(imageName: "circleGradient", size: CGSize(width: 50, height: 50))
//        wheelPreferences.imageAnchor = anchorImage
        let configuration = SFWConfiguration(wheelPreferences: wheelPreferences, pinPreferences: pin, spinButtonPreferences: spin)
        
        return configuration
    }
    
    
    
    func renderScore(playerScore: [String], isUser: Bool){
        // cast score into an array with length of 5
        var castedPlayerScore = playerScore
        while castedPlayerScore.count != 5 {
            castedPlayerScore.append("nil")
        }
        
        let radiusPercent: Float = isUser ? 0.9 :0.5
        Array(zip(castedPlayerScore, scoreArcStartAngleArray)).forEach {
            let index = SpinWheelTextArray.firstIndex(of: $0.0)
            if index != nil {
                let color = SpinWheelColorArray[index ?? 0]
                renderArc(startAngleRadius: CGFloat($0.1), radiusPercent: radiusPercent, color: color.cgColor)
            }
            else {
                renderArc(startAngleRadius: CGFloat($0.1), radiusPercent: radiusPercent, color: UIColor.gray.cgColor)
            }
        }
    }
    func renderArc(startAngleRadius: CGFloat, radiusPercent: Float, color: CGColor) {
        guard let parent = scoreBoardUIViewOutlet else { return }
        let circleColorPath = UIBezierPath(arcCenter: CGPoint.init(x: parent.frame.width/2, y: parent.frame.height), radius: parent.frame.width/2 * CGFloat(radiusPercent), startAngle: percentToRadians(percent: startAngleRadius), endAngle: percentToRadians(percent: startAngleRadius + 33), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circleColorPath.cgPath
        //change the fill with background color
        shapeLayer.fillColor = UIColor.white.cgColor
        //set arc color here
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 50.0
        parent.layer.insertSublayer(shapeLayer, at: 0)
    }

    func percentToRadians(percent: CGFloat) -> CGFloat {
        return (percent * CGFloat(Double.pi)) / 180
    }
    
    @IBAction func spinButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let questionViewController = storyboard.instantiateViewController(identifier: "questionViewController") as? QuestionViewController else {
            assertionFailure("cannot instantiate questionViewController")
            return
        }
        
        fortuneWheelViewOutlet.startRotationAnimation(finishIndex: finishIndex ?? 0, continuousRotationTime: 1) { (finished) in
            questionViewController.questionCategory = self.SpinWheelTextArray[self.finishIndex ?? 0]
        self.navigationController?.pushViewController(questionViewController, animated: true)
            }

    }
    
}

