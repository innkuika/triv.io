//
//  GameInstanceMock.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

class GameInstanceModelMock: GameInstance {
    let id: Int
    
    var user1: User
    
    var user2: User
    
    var state: GameState
    
    init(id: Int, user1: User, user2: User, state: GameState) {
        self.id = id
        self.user1 = user1
        self.user2 = user2
        self.state = state
    }
}
