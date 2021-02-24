//
//  GameModel.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 2/17/21.
//

import Foundation

protocol GameModelUpdates: class {
    func categoriesDidLoad(_ categories: [String])
    func selectedCategoriesDidChange(_ selectedCategories: [String])
}

class GameModel {
    var categories: [String] = []
    var selectedCategories: [String] = []
    weak var delegate: GameModelUpdates?
    
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
