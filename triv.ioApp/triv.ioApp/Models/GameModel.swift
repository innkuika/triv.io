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
    // reserved History, Pop Culture and UC Davis category for bot to pick, can fix this later
    var categories: [String] =  ["Art and Literature", "Sports", "Technology", "Video Games", "History", "Pop Culture", "UC Davis"]
    var currentCategories: [String]?
    
    var selectedCategories: [String] = []
    weak var delegate: GameModelUpdates?
    var currentTurn: String
    var playerIds: [String]
    var players: [String: Player]
    var ref = Database.database().reference()
    var gameInstanceId: String?
    var gameStatus: String
    
    
    init?(userId: String){
        self.currentTurn = userId
        //        self.playerIds = [userId, "bot"]
        self.playerIds = [userId]
        let UserPlayer = Player(playerID: userId, streak: 0, score: [])
        //        let BotPlayer = Player(playerID: "bot", streak: 0, score: [])
        self.players = [userId: UserPlayer]
        //        self.players = [userId: UserPlayer, "bot": BotPlayer]
        self.gameStatus = "init"
        
        // create a game instance and push to database
        let gameInstanceRef = self.ref.child("GameInstance").childByAutoId()
        guard let unwrappedKey = gameInstanceRef.key else { return }
        self.gameInstanceId = unwrappedKey
        gameInstanceRef.setValue(["GameStatus": "init",
                                  "CurrentTurn": userId,
                                  //                                  "PlayerIds": [userId, "bot"],
                                  "PlayerIds": [userId],
                                  "Players": [userId: ["Score": [], "Streak": 0]],
                                  //                                              "bot": ["Score": [], "Streak": 0]],
                                  "Categories": []])
        
        userGameInstanceUpdate(userId: userId, gameInstanceId: unwrappedKey)
    }
    
    init?(gameStatus: String?, currentTurn: String?, playerIds: [String]?, players: [String:Player]?, categories: [String]?, gameInstanceId: String?){
        guard let gameStatus = gameStatus, let currentTurn = currentTurn, let playerIds = playerIds, let players = players, let gameInstanceId = gameInstanceId else { return nil }
        
        let categories = categories ?? [] // categories may not be set yet
        
        self.currentCategories = categories
        self.currentTurn = currentTurn
        self.playerIds = playerIds
        self.players = players
        self.gameInstanceId = gameInstanceId
        self.gameStatus = gameStatus
    }
    
    func userGameInstanceUpdate(userId: String, gameInstanceId: String){
        // update user's game instance
        var gameInstanceIds: [String] = []
        let workerGroup = DispatchGroup()
        workerGroup.enter()
        workerGroup.notify(queue: DispatchQueue.main) {
            self.ref.child("User/\(userId)/Game").setValue(gameInstanceIds)
        }
        
        self.ref.child("User/\(userId)/Game").getData{ (error, snapshot) in
            let unwrappedGameInstanceIds = snapshot.value as? [String] ?? []
            gameInstanceIds = unwrappedGameInstanceIds
            gameInstanceIds.append(gameInstanceId)
            workerGroup.leave()
        }
    }
    
    // push next player info to database
    func flipTurn() {
        guard let currentPlayerIndex = playerIds.firstIndex(of: currentTurn) else { return }
        var nextPlayerIndex = currentPlayerIndex + 1
        if nextPlayerIndex == playerIds.count {
            nextPlayerIndex = 0
        }
        currentTurn = playerIds[nextPlayerIndex]
        guard let unwrappedInstanceId = gameInstanceId else { return }
        ref.child("GameInstance/\(unwrappedInstanceId)/CurrentTurn").setValue(currentTurn)
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
            guard let unwrappedCurrentTurn = value?["CurrentTurn"] as? String else { return }
            self.currentTurn = unwrappedCurrentTurn
            
            // get latest game status
            guard let unwrappedGameStatus = value?["GameStatus"] as? String else { return }
            self.gameStatus = unwrappedGameStatus
            
            // get current category
            self.currentCategories = value?["Categories"] as? [String]
            
        })
        workerGroup.leave()
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
    
    func getOpponentPlayer() -> Player?{
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return nil
        }
        let currentUserId = user.uid
        for (playerId, player) in players{
            print("playerid\(playerId)")
            if playerId != currentUserId {
                return player
            }
        }
        assertionFailure("cannot find current user in game instance")
        return nil
    }
    
    func addNewPlayer(newPlayerId: String){
        // updates playerIds and players
        playerIds.append(newPlayerId)
        players[newPlayerId] = Player(playerID: newPlayerId, streak: 0, score: [])
        currentTurn = newPlayerId
        
        guard let unwrappedInstanceId = gameInstanceId else { return }
        ref.child("GameInstance/\(unwrappedInstanceId)/PlayerIds").setValue(self.playerIds)
        
        var playersDict: [String : Any] = [:]
        playersDict[playerIds[0]] = ["Score": [], "Streak": 0]
        playersDict[playerIds[1]] = ["Score": [], "Streak": 0]
        ref.child("GameInstance/\(unwrappedInstanceId)/Players").setValue(playersDict)
        
        ref.child("GameInstance/\(unwrappedInstanceId)/CurrentTurn").setValue(newPlayerId)
        
    }
    
    //    // set before using
    //    func setCurrentGameCategories(){
    //        var categories: [String] = []
    //        guard let unwrappedGameInstanceId = gameInstanceId else { return }
    //        let workerGroup = DispatchGroup()
    //        workerGroup.enter()
    //
    //        self.ref.child("GameInstance/\(unwrappedGameInstanceId)/Categories").getData{ (error, snapshot) in
    //            if snapshot.exists(){
    //                let unwrappedCategories = snapshot.value as? [String] ?? []
    //                categories = unwrappedCategories
    //                print("categories in db: \(categories)")
    //                workerGroup.leave()
    //            }
    //        }
    //
    //        workerGroup.notify(queue: DispatchQueue.main) {
    //            self.currentCategories = categories
    //        }
    //    }
    
    func updateGameStatus(status: String){
        guard let unwrappedGameInstanceId = gameInstanceId else { return }
        self.ref.child("GameInstance/\(unwrappedGameInstanceId)/GameStatus").setValue(status)
    }
    
    func updateCategories(syncWorkerGroup: DispatchGroup){
        guard let unwrappedGameInstanceId = gameInstanceId else { return }
        let unwrappedCurrentCategories = currentCategories ?? []
        currentCategories = unwrappedCurrentCategories + selectedCategories
        
        print("all categories: \(currentCategories)")
        self.ref.child("GameInstance/\(unwrappedGameInstanceId)/Categories").setValue(currentCategories)
        syncWorkerGroup.leave()
        
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

