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

    var SpinWheelColorArray = [trivioRed, trivioBlue, trivioYellow, trivioPurple, trivioGreen, trivioOrange]
    var finishIndex: Int?
    
    // passed in from OpponentSelectionViewController or HomeViewController
    var gameInstance: GameModel?
    
    // query from database
    var ref: DatabaseReference!
    var SpinWheelTextArray: [String] = []
    var isUserTurn = true
    var userScore: [String] = []
    var opponentScore: [String] = []
     
    override func viewDidLoad() {
        
        let workerGroup = DispatchGroup()
        super.viewDidLoad()
        ref = Database.database().reference()
        
        workerGroup.enter()
        // get latest data from database
        gameInstance?.updateGameInstance(workerGroup: workerGroup)

        workerGroup.notify(queue: DispatchQueue.main) {
            self.renderUI()
            self.checkWinningStatus()
        }
    }
    
    func checkWinningStatus() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let resultViewController = storyboard.instantiateViewController(identifier: "resultViewController") as? ResultViewController else {
            assertionFailure("cannot instantiate resultViewController")
            return
        }
        if userScore.count == 5 {
            resultViewController.playerDidWin = true
            gameInstance?.updateGameStatus(status: "finished")
            self.navigationController?.pushViewController(resultViewController, animated: true)
        }
//        else if opponentScore.count == 5 {
//            resultViewController.playerDidWin = false
//            self.navigationController?.pushViewController(resultViewController, animated: true)
//        }
    }
    
    func renderUI() {
        navigationItem.hidesBackButton = true
        
        // query current game state (userScore, botScore, isUserTurn) from database and render accordingly
//        gameInstance?.setCurrentGameCategories()
        print("current categories: \(gameInstance?.currentCategories)")
        guard let unwrappedSpinWheelTextArray = gameInstance?.currentCategories else { return }
        SpinWheelTextArray = unwrappedSpinWheelTextArray
        
        
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        
        guard let unwrappedUserScore = gameInstance?.getUserPlayer(id: user.uid) else { return }
        userScore = unwrappedUserScore.score
        
        guard let unwrappedOpponentScore = gameInstance?.getOpponentPlayer() else { return }
        opponentScore = unwrappedOpponentScore.score
        
//        if user.uid == gameInstance?.currentTurn {
//            isUserTurn = true
//        } else {
//            isUserTurn = false
//        }
        
        // style spin button
        spinButtonOutlet.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.7, height: 50)
        spinButtonOutlet.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.93)
        spinButtonOutlet.backgroundColor = trivioOrange
        styleButton(button: spinButtonOutlet)
        
        // position score board ui
        scoreBoardUIViewOutlet.frame = CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: view.frame.height * 0.4)
        scoreBoardUIViewOutlet.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.1)
        
        renderWheel()
        renderScoreBoard(userScore: userScore, botScore: opponentScore)
        let newFinishIndex = Int.random(in: 0 ..< SpinWheelTextArray.count)
        finishIndex = newFinishIndex
        
        // get questionViewController and prepare navigation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let questionViewController = storyboard.instantiateViewController(identifier: "questionViewController") as? QuestionViewController else {
            assertionFailure("cannot instantiate questionViewController")
            return
        }
        questionViewController.gameInstance = self.gameInstance
        
        // if it's not user's turn, it's bot's turn and will spin automatically
//        if !isUserTurn{
//            spinButtonOutlet.isEnabled = false
//            guard let unwrappedFinishedIndex = self.finishIndex else { return }
//            fortuneWheelViewOutlet.startRotationAnimation(finishIndex: unwrappedFinishedIndex, continuousRotationTime: 1) { (finished) in
//            questionViewController.questionCategory = self.SpinWheelTextArray[unwrappedFinishedIndex]
//            self.navigationController?.pushViewController(questionViewController, animated: true)
//                }
//        }
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
        
        let wheelRadius = view.frame.width * 0.9
        fortuneWheelViewOutlet.frame = CGRect(x: 0, y: 0, width: wheelRadius, height: wheelRadius)
        fortuneWheelViewOutlet.center = CGPoint(x: view.frame.width * 0.5, y: view.frame.height * 0.6)
        fortuneWheelViewOutlet.backgroundColor = trivioBackgroundColor
        

        
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
        var wheelPreferences = SFWConfiguration.WheelPreferences(circlePreferences: circlePreferences, slicePreferences: slicePreferences, startPosition: .top)
        

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
                renderArc(startAngleRadius: CGFloat($0.1), radiusPercent: radiusPercent, color: UIColor.lightGray.cgColor)
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
        questionViewController.gameInstance = self.gameInstance
        fortuneWheelViewOutlet.startRotationAnimation(finishIndex: finishIndex ?? 0, continuousRotationTime: 1) { (finished) in
            questionViewController.questionCategory = self.SpinWheelTextArray[self.finishIndex ?? 0]
        self.navigationController?.pushViewController(questionViewController, animated: true)
            }

    }
    
}

