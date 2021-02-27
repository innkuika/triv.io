//
//  PlayerModel.swift
//  triv.ioApp
//
//  Created by Jessica Wu on 2/26/21.
//

import Foundation

class Player {
    var playerID: String
    var streak: Int
    var score: [String]
    
    init(playerID: String, streak: Int, score: [String]) {
        self.playerID = playerID
        self.streak = streak
        self.score = score
    }
}
