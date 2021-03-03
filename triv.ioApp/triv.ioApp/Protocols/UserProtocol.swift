//
//  UserDataSourceProtocol.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

protocol User {
    var name: String {get set}
    var streak_score: Int {get set}
    var id: String {get}
    func promptForMove()
}
