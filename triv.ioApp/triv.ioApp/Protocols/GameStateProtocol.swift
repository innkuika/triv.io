//
//  GameStateProtocol.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

protocol GameState {
    var id: Int { get }
    var categories: [Category] { get set }
    var score: Int { get set }
    var streak: Int { get set }
    var currentTurn: Int { get set }
    var currentQuestion: Question { get set }
}
