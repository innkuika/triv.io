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
    var gameInstanceId: String?
    
    
    init(userId: String){
        self.currentTurn = userId
        self.playerIds = [userId, "bot"]
        let UserPlayer = Player(playerID: userId, streak: 0, score: [])
        let BotPlayer = Player(playerID: "bot", streak: 0, score: [])
        self.players = [userId: UserPlayer, "bot": BotPlayer]
        
        // create a game instance and push to database
        let gameInstanceRef = self.ref.child("GameInstance").childByAutoId()
        guard let unwrappedKey = gameInstanceRef.key else { return }
        self.gameInstanceId = unwrappedKey
        gameInstanceRef.setValue(["CurrentTurn": userId,
                                  "PlayerIds": [userId, "bot"],
                                  "Players": [userId: ["Score": [], "Streak": 0],
                                              "bot": ["Score": [], "Streak": 0]],
                                  "Categories": []])
        
    }
    
    // get latest data from database
    func updateGameInstance(workerGroup: DispatchGroup){
        self.ref.child("GameInstance/\(self.gameInstanceId ?? "")").observe(DataEventType.value, with: { (snapshot) in
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
                
                

        })
        print("before leave group")
        workerGroup.leave()
    print("after leave group")
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
        
        self.ref.child("GameInstance/\(self.gameInstanceId ?? "")/Categories").setValue(selectedCategories)
    
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
