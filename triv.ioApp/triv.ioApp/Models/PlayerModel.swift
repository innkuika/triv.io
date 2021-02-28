//
//  PlayerModel.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/26/21.
//

import Foundation
import FirebaseDatabase

class Player {
    var playerID: String
    var streak: Int
    var score: [String]
    
    init(playerID: String, streak: Int, score: [String]) {
        self.playerID = playerID
        self.streak = streak
        self.score = score
    }
    
    // push new player score to database
    func updatePlayerScore(gameInstanceID: String, newScore: String){
        if !score.contains(newScore) {
            score.append(newScore)
            let ref = Database.database().reference()
            ref.child("GameInstance/\(gameInstanceID)/Players/\(playerID)/Score").setValue(score)
        }
    
        
    }
}
