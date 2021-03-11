//
//  JoinGameViaCodeViewController.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 3/9/21.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class JoinGameViaCodeViewController: UIViewController{
    @IBOutlet weak var gameCodeTextFieldOutlet: UITextField!
    @IBOutlet weak var errorMessageLabelOutlet: UILabel!
    @IBOutlet weak var joinButtonOutlet: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        renderUI()
    }
    
    func renderUI(){
        styleButton(button: joinButtonOutlet)
        errorMessageLabelOutlet.text = ""
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        //try to get game instance
        guard let gameInstanceId = gameCodeTextFieldOutlet.text else { return }
        self.ref.child("GameInstance/\(gameInstanceId)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                guard let GameInstanceDict = snapshot.value as? NSDictionary else { return }
                
                // get latest players info
                var tempPlayers:[String:Player] = [:]
                guard let unwrappedPlayersArray = GameInstanceDict["Players"] as? NSDictionary else { return }
                for (playerId, playerDictStr) in unwrappedPlayersArray{
                    guard let unwrappedPlayerId = playerId as? String else { return }
                    let playerDict = playerDictStr as? NSDictionary
                    let updatedStreak = playerDict?["Streak"] as? Int ?? 0
                    let updatedScore: [String] = playerDict?["Score"] as? [String] ?? []
                    tempPlayers[unwrappedPlayerId] = Player(playerID: unwrappedPlayerId, streak: updatedStreak, score: updatedScore)
                }
                
                let tempGameInstance = GameModel(gameStatus: GameInstanceDict["GameStatus"] as? String,
                                                 currentTurn: GameInstanceDict["CurrentTurn"] as? String,
                                                 playerIds: GameInstanceDict["PlayerIds"] as? [String],
                                                 players: tempPlayers,
                                                 categories: GameInstanceDict["Categories"] as? [String],
                                                 gameInstanceId: gameInstanceId)
                guard let unwrappedGameModel = tempGameInstance else { return }
                
                //                // update user's game
                //                guard let user = Auth.auth().currentUser else {
                //                    assertionFailure("Unable to get current logged in user")
                //                    return
                //                }
                //                unwrappedGameModel.userGameInstanceUpdate(userId: user.uid, gameInstanceId: gameInstanceId)
                //
                //                // update playerIds, players in game instance, set current turn to new player
                //                unwrappedGameModel.addNewPlayer(newPlayerId: user.uid)
                
                DispatchQueue.main.sync {
                    // pass game instance to categorySelectionViewController and navigate
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
                        assertionFailure("cannot instantiate categorySelectionViewController")
                        return
                    }
                    // pass game instance to categorySelectionViewController
                    categorySelectionViewController.gameInstance = unwrappedGameModel
                    
                    self.navigationController?.pushViewController(categorySelectionViewController, animated: true)
                }  
            }
            else {
                print("No data available")
                DispatchQueue.main.sync {
                    self.errorMessageLabelOutlet.text = "Oops, game not found, please try again."
                }
            }
        }
        
    }
}
