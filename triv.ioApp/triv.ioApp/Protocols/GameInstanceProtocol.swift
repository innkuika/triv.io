//
//  gameInstanceProtocol.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

protocol GameInstance {
    var id: Int { get }
    var user1: User { get }
    var user2: User { get }
    //TODO: Are we sure that state should be a separate object from a gameInstance?
    var state: GameState { get set }
}
