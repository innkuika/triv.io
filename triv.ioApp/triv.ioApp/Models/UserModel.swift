//
//  UserModel.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

class UserModel: User {
    var name: String {
        willSet {
            // Update name in database
        } didSet {
            // Check that name was updated successfully
        }
    }
    var streak_score: Int {
        willSet {
            // Update in database
        } didSet {
            
        }
    }
    let id: Int
    //FIXME: Create a database type for the models to communicate with.
    let database: Int
    
    //TODO: Figure out how to notify the device of the user associated with this id
    func promptForMove() {
        
    }
    
    init?(id: Int) {
        return nil
        // Use ID to fetch data from database and populate fields
    }
}
