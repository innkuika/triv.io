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
    var categories: [String] = []
    var selectedCategories: [String] = []
    weak var delegate: GameModelUpdates?
    var currentTurn: String
    var playerIds: [String]
    var players: [Player]
    var ref = Database.database().reference()
    var gameInstanceRef: DatabaseReference!
    
    
    init(userId: String){
        self.currentTurn = userId
        self.playerIds = [userId, "bot"]
        let UserPlayer = Player(playerID: userId, streak: 0, score: [])
        let BotPlayer = Player(playerID: "bot", streak: 0, score: [])
        self.players = [UserPlayer, BotPlayer]
        
        // create a game instance and push to database
        self.gameInstanceRef = self.ref.child("GameInstance").childByAutoId()
        self.gameInstanceRef.setValue(["CurrentTurn": userId,
                                  "PlayerIds": [userId, "bot"],
                                  "Players": [userId: ["Score": [], "Streak": 0],
                                              "bot": ["Score": [], "Streak": 0]],
                                  "Categories": []])
    }
    
    func updateCategories(){
        if playerIds.contains("bot"){
            // FIXME: implement bot selection logic here later
            gameInstanceRef.child("Categories").setValue(categories)
        }
        else {
            gameInstanceRef.child("Categories").setValue(selectedCategories)
        }
    }
    
    func loadCategories() {
        categories = ["Art", "History", "Pop Culture", "Science", "Technology", "Video Games"]
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
