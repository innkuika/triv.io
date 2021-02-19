//
//  SpinWheelView.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/17/21.
//

import Foundation
import UIKit
import SwiftFortuneWheel

class SpinWheelViewController: UIViewController {

    @IBOutlet weak var fortuneWheelViewOutlet: SwiftFortuneWheel! 
    // pass in the category names here
    var SpinWheelTextArray: [String] = ["small KT", "middle KT", "big KT", "XL KT", "cute KT", "fat KT"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: query current game state from database and render accordingly
        var slices: [Slice] = []
        let textPreferences = TextPreferences(textColorType: SFWConfiguration.ColorType.evenOddColors(evenColor: .black, oddColor: .black), font: SFWFont.systemFont(ofSize: 15))
        
        SpinWheelTextArray.forEach {
            let textSliceContent = Slice.ContentType.text(text: $0, preferences: textPreferences)
            let slice = Slice(contents: [textSliceContent])
            slices.append(slice)
        }
        fortuneWheelViewOutlet.pinImage = "long-arrow-up"
        fortuneWheelViewOutlet.isSpinEnabled = true


//        let sliceColorType = SFWConfiguration.ColorType.evenOddColors(evenColor: .red, oddColor: .cyan)
        let pin = SFWConfiguration.PinImageViewPreferences(size: CGSize(width: 13, height: 40), position: .top, verticalOffset: -25)
        let spin = SFWConfiguration.SpinButtonPreferences(size: CGSize(width: 50, height: 20))
        let colorArray = [SFWColor.red, SFWColor.blue, SFWColor.yellow, SFWColor.purple, SFWColor.cyan, SFWColor.orange]
        let sliceColorType = SFWConfiguration.ColorType.customPatternColors(colors: colorArray, defaultColor: SFWColor.brown)
        let slicePreferences = SFWConfiguration.SlicePreferences(backgroundColorType: sliceColorType, strokeWidth: 1, strokeColor: .black)
        let circlePreferences = SFWConfiguration.CirclePreferences(strokeWidth: 10, strokeColor: .black)
        let wheelPreferences = SFWConfiguration.WheelPreferences(circlePreferences: circlePreferences, slicePreferences: slicePreferences, startPosition: .bottom)
        let configuration = SFWConfiguration(wheelPreferences: wheelPreferences, pinPreferences: pin, spinButtonPreferences: spin)
        
        fortuneWheelViewOutlet.configuration = configuration
        fortuneWheelViewOutlet.slices = slices
        
        let finishIndex = Int.random(in: 0 ..< SpinWheelTextArray.count)
        
        // get questionViewController and prepare navigation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let questionViewController = storyboard.instantiateViewController(identifier: "questionViewController") as? QuestionViewController else {
            assertionFailure("cannot instantiate questionViewController")
            return
        }

        fortuneWheelViewOutlet.startRotationAnimation(finishIndex: finishIndex, continuousRotationTime: 1) { (finished) in
            questionViewController.questionCategory = self.SpinWheelTextArray[finishIndex]
            self.navigationController?.pushViewController(questionViewController, animated: true)
                }
    }


}

