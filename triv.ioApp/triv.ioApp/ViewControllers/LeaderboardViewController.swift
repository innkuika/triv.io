//
//  LeaderboardViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/3/21.
//

import UIKit
import FirebaseDatabase

class LeaderboardViewController: UIViewController, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        ref = Database.database().reference()
        leaderboardTableView.dataSource = self
        getUserData {
            DispatchQueue.main.async {
                self.leaderboardTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "userCell")
        cell.textLabel?.text = String(indexPath.row + 1) + ". " + users[indexPath.row].name
        cell.detailTextLabel?.text = String(users[indexPath.row].streak_score) + " wins"
        cell.backgroundColor = trivioBackgroundColor
        cell.imageView?.tintColor = UIColor.white
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
    }
    
    
    @IBOutlet weak var leaderboardTableView: UITableView!
    var ref: DatabaseReference!
    let workerGroup = DispatchGroup()
    var users: [User] = []
    

    
    
    func getUserData(completion: @escaping () -> Void) {
        ref.child("User").queryOrdered(byChild: "Streak").ref.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                guard let resultDict = snapshot.value as? NSDictionary else {
                    self.workerGroup.leave()
                    return
                }
                let ids = resultDict.allKeys
                self.users = ids.compactMap { id in
                    UserModel(
                        name: (resultDict[id] as? NSDictionary)?["Name"] as? String,
                        streak_score: (resultDict[id] as? NSDictionary)?["Streak"] as? Int,
                        id: id as? String,
                        database: 0)
                }
            }
            completion()
        }
    }
}
