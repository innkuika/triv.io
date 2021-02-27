//
//  GameModel.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 2/17/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

protocol GameModelUpdates: class {
    func categoriesDidLoad(_ categories: [String])
    func selectedCategoriesDidChange(_ selectedCategories: [String])
}

class GameModel {
    var categories: [String] =  ["Art Literature", "History", "Pop Culture", "Science", "Technology", "Video Games"]
    var selectedCategories: [String] = []
    weak var delegate: GameModelUpdates?
    var currentTurn: String
    var playerIds: [String]
    var players: [String: Player]
    var ref = Database.database().reference()
    var gameInstanceRef: DatabaseReference!
    
    
    init(userId: String){
        self.currentTurn = userId
        self.playerIds = [userId, "bot"]
        let UserPlayer = Player(playerID: userId, streak: 0, score: [])
        let BotPlayer = Player(playerID: "bot", streak: 0, score: [])
        self.players = [userId: UserPlayer, "bot": BotPlayer]
        
        // create a game instance and push to database
        self.gameInstanceRef = self.ref.child("GameInstance").childByAutoId()
        self.gameInstanceRef.setValue(["CurrentTurn": userId,
                                  "PlayerIds": [userId, "bot"],
                                  "Players": [userId: ["Score": [], "Streak": 0],
                                              "bot": ["Score": [], "Streak": 0]],
                                  "Categories": []])
    }
    
    // get latest data from database
    func updateGameInstance(){
        gameInstanceRef.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                print("Got data \(snapshot.value!)")
                let value = snapshot.value as? NSDictionary
                
                // get latest players info
                guard let unwrappedPlayersArray = value?["Players"] as? NSDictionary else { return }
                for (playerId, playerDictStr) in unwrappedPlayersArray{
                    guard let unwrappedPlayerId = playerId as? String else { return }
                    let playerDict = playerDictStr as? NSDictionary
                    let updatedStreak = playerDict?["Streak"] as? Int ?? 0
                    let updatedScore: [String] = playerDict?["Score"] as? [String] ?? []
                    self.players[unwrappedPlayerId] = Player(playerID: unwrappedPlayerId, streak: updatedStreak, score: updatedScore)
                }
                
                // get latest currentTurn
                guard let unwrappedCurrentTurn = value?["CurrentTurn"] as? String else {
                    return
                }
                self.currentTurn = unwrappedCurrentTurn
            }
            else {
                print("No data available")

            }
        }
    }
    
    func getUserPlayer(id: String) -> Player?{
        for (playerId, player) in players{
            if playerId == id {
                return player
            }
        }
        assertionFailure("cannot find current user in game instance")
        return nil
    }
    
    func updateCategories(){
        if playerIds.contains("bot"){
            // FIXME: implement bot selection logic here later
            selectedCategories = categories
        }
        gameInstanceRef.child("Categories").setValue(selectedCategories)
    
    }
    
    func loadCategories() {
        delegate?.categoriesDidLoad(categories)
    }
    
    func selectCategory(_ category: String) {
        selectedCategories.append(category)
        delegate?.selectedCategoriesDidChange(selectedCategories)
    }
    
    func deselectCategory(_ category: String) {
        guard let index = selectedCategories.firstIndex(of: category) else { return }
        selectedCategories.remove(at: index)
        delegate?.selectedCategoriesDidChange(selectedCategories)
    }
    
}
