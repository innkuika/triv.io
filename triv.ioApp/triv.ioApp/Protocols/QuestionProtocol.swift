//
//  QuestionProtocol.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

import Foundation

protocol Question {
    var id: Int { get }
    var category: Category { get }
    var text: String { get }
    var answer: String { get }
}
