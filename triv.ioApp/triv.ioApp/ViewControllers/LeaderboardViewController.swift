//
//  LeaderboardViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/3/21.
//

import UIKit
import FirebaseDatabase

class LeaderboardViewController: UIViewController, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "userCell")
        cell.textLabel?.text = String(indexPath.row + 1) + ". " + users[indexPath.row].name
        cell.detailTextLabel?.text = String(users[indexPath.row].streak_score) + " wins"
        cell.backgroundColor = trivioBackgroundColor
        return cell
    }
    
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    var ref: DatabaseReference!
    var users: [User] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        leaderboardTableView.dataSource = self
        getUserData { result in
            if case .failure(let error) = result { print("Error getting data \(error)") }
            DispatchQueue.main.async {
                self.leaderboardTableView.reloadData()
            }
        }
    }
    
    func getUserData(completion: @escaping (Result<Void, Error>) -> Void) {
        ref.child("User").queryOrdered(byChild: "Streak").observeSingleEvent(
            of: .value,
            with: { (snapshot) in
            if snapshot.exists() {
                self.users = snapshot.children.compactMap { childSnapshot in
                    guard let childSnapshot = (childSnapshot as? DataSnapshot),
                          let resultDict = childSnapshot.value as? NSDictionary else {
                        return nil
                    }
                    return UserModel(
                        name: resultDict["Name"] as? String,
                        streak_score: resultDict["Streak"] as? Int,
                        id: childSnapshot.key,
                        database: 0
                    )
                }.reversed()
                completion(Result<Void,Error>.success(()))
            }
        }) { (error) in
            completion(Result<Void, Error>.failure(error))
        }
    }
}
