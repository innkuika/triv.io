//
//  CategoryModel.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/15/21.
//


class CategoryModel: Category {
    var id: String
    var name: String
    
    init?(id: String?, name: String?) {
        guard let id = id, let name = name else { return nil }
        self.id = id
        self.name = name
    }
}
