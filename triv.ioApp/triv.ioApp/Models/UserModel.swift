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
    var avatar_number: Int {
        willSet {
            // Update in database
        } didSet {
            
        }
    }
    let id: String
    
    //TODO: Figure out how to notify the device of the user associated with this id
    func promptForMove() {
        
    }
    
    init?(id: Int) {
        return nil
        // Use ID to fetch data from database and populate fields
    }
    
    init?(name: String?, streak_score: Int?, id: String?, avatar_number: Int?) {
        guard let name = name, let streak_score = streak_score,  let id = id, let avatar_number = avatar_number else {
            return nil
        }
        self.name = name
        self.streak_score = streak_score
        self.id = id
        self.avatar_number = avatar_number
    }

}
