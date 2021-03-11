//
//  HomeViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 2/18/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FBSDKLoginKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var leaderboardButtonOutlet: UIButton!
    @IBOutlet weak var startNewGameButtonOutlet: UIButton!
    @IBOutlet weak var joinGameViaCodeButtonOutlet: UIButton!
    @IBOutlet weak var userPreferenceButtonOutlet: UIButton!
    @IBOutlet weak var gameInstanceTableViewOutlet: UITableView!
    
    // query from db
    var ref: DatabaseReference!
    var avatarNumber: Int?
    var userName: String?
    var userId: String?
    var coinNumber: Int?
    var gameInstances: [[GameModel]] = [[], [], []] // holds active, pending, and finished
    var opponents: [String?: UserModel] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationItem.hidesBackButton = true
        getUserProfileData()
        loadGameInstances()
        
        renderUI()
        gameInstanceTableViewOutlet.dataSource = self
        
        gameInstanceTableViewOutlet.delegate = self
        
        let loadGameInstancesTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(loadGameInstances), userInfo: nil, repeats: true)
        }
    
    func renderUI(){
        styleButton(button: startNewGameButtonOutlet)
        styleButton(button: joinGameViaCodeButtonOutlet)
        styleCircleButton(button: leaderboardButtonOutlet)
    }
    
    @IBAction func joinGameViaCodeButtonPressed(_ sender: Any) {
        // navigate to joinGameViaCodeViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let joinGameViaCodeViewController = storyboard.instantiateViewController(identifier: "joinGameViaCodeViewController") as? JoinGameViaCodeViewController else {
            assertionFailure("cannot instantiate joinGameViaCodeViewController")
            return
        }
        
        navigationController?.pushViewController(joinGameViaCodeViewController, animated: true)
        
    }
    
    
    // MARK: -UI action handlers
    @IBAction func startGameButtonPress() {
        // create new game instance
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        let gameInstance = GameModel(userId: user.uid)
        
        // navigate to CategorySelectionViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let categorySelectionViewController = storyboard.instantiateViewController(identifier: "categorySelectionViewController") as? CategorySelectionViewController else {
            assertionFailure("cannot instantiate categorySelectionViewController")
            return
        }
        // pass game instance to categorySelectionViewController
        categorySelectionViewController.gameInstance = gameInstance
        
        navigationController?.pushViewController(categorySelectionViewController, animated: true)
    }
    
    @IBAction func leaderboardButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let leaderboardViewController = storyboard.instantiateViewController(identifier: "leaderboardViewController") as? LeaderboardViewController else {
            assertionFailure("cannot instantiate leaderboardViewController")
            return
        }
        self.navigationController?.pushViewController(leaderboardViewController, animated: true)
    }
    
    @IBAction func friendsButtonPressed() {
        // Navigate to Friend List View
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let friendListViewController = storyboard.instantiateViewController(identifier: "friendListViewController") as? FriendListViewController else {
            assertionFailure("cannot instantiate friendListViewController")
            return
        }
        self.navigationController?.pushViewController(friendListViewController, animated: true)
    }
    
    @IBAction func userPreferenceButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let userPreferenceViewController = storyboard.instantiateViewController(identifier: "userPreferenceViewController") as? UserPreferenceViewController else {
            assertionFailure("cannot instantiate userPreferenceViewController")
            return
        }
        self.navigationController?.pushViewController(userPreferenceViewController, animated: true)
    }
    
    @objc func loadGameInstances() {
        if !(navigationController?.topViewController?.isKind(of: HomeViewController.self) ?? false){
            // do nothing if player is not in homeViewController
            return
        }
        guard let unwrappedUserId = self.userId else { return }
        self.ref.child("User").child(unwrappedUserId).child("Game").observe(.value) { (snapshot) in
            self.gameInstances = [[], [], []]
            self.opponents = [:]
            if snapshot.exists(){
                guard let gameInstanceIds = snapshot.value as? [String] else { return }
                // Initialize semaphores for accessing gameInstance and opponent arrays and reloading data inside the table view
                let accessSem = DispatchSemaphore(value: 1)
                let opponentsAccessSem = DispatchSemaphore(value: 1)
                let waitSem = DispatchSemaphore(value: 0)
                
                // Retrieve user data of each gameInstance
                for gameInstanceId in gameInstanceIds {
                    DispatchQueue.global(qos: .default).async {
                        self.ref.child("GameInstance/\(gameInstanceId)").getData { (error, snapshot) in
                            if let error = error {
                                print("Error getting data \(error)")
                            } else if snapshot.exists() {
                                guard let GameInstanceDict = snapshot.value as? NSDictionary else { return }
                                
                                // get latest players info
                                var tempPlayers:[String:Player] = [:]
                                guard let unwrappedPlayersArray = GameInstanceDict["Players"] as? NSDictionary else { return }
                                for (playerId, playerDictStr) in unwrappedPlayersArray{
                                    guard let unwrappedPlayerId = playerId as? String else { return }
                                    let playerDict = playerDictStr as? NSDictionary
                                    let updatedStreak = playerDict?["Streak"] as? Int ?? 0
                                    let updatedScore: [String] = playerDict?["Score"] as? [String] ?? []
                                    tempPlayers[unwrappedPlayerId] = Player(playerID: unwrappedPlayerId, streak: updatedStreak, score: updatedScore)
                                    if unwrappedPlayerId != self.userId {
                                        // Add to opponent list
                                        self.ref.child("User/\(unwrappedPlayerId)").getData { (error, snapshot) in
                                            if let error = error {
                                                print("Error getting data \(error)")
                                            } else if snapshot.exists() {
                                                guard let userDict = snapshot.value as? NSDictionary else { return }
                                                opponentsAccessSem.wait()
                                                self.opponents[gameInstanceId] = UserModel(
                                                    name: userDict["Name"] as? String,
                                                    streak_score: userDict["Streak"] as? Int,
                                                    id: unwrappedPlayerId,
                                                    database: 0,
                                                    avatar_number: userDict["AvatarNumber"] as? Int
                                                )
                                                opponentsAccessSem.signal()
                                                waitSem.signal()
                                            }
                                        }
                                    }
                                }
                                
                                let tempGameInstance = GameModel(gameStatus: GameInstanceDict["GameStatus"] as? String,
                                                                 currentTurn: GameInstanceDict["CurrentTurn"] as? String,
                                                                 playerIds: GameInstanceDict["PlayerIds"] as? [String],
                                                                 players: tempPlayers,
                                                                 categories: GameInstanceDict["Categories"]  as?[String],
                                                                 gameInstanceId: gameInstanceId)
                                guard let unwrappedGameModel = tempGameInstance else { return }
                                accessSem.wait()
                                if unwrappedGameModel.gameStatus == "active" {
                                    self.gameInstances[0].append(unwrappedGameModel)
                                } else if unwrappedGameModel.gameStatus == "pending" {
                                    self.gameInstances[1].append(unwrappedGameModel)
                                } else {
                                    self.gameInstances[2].append(unwrappedGameModel)
                                }
                                accessSem.signal()
                            }
                            
                            waitSem.signal()
                        }
                    }
                }
                for _ in 1...(gameInstanceIds.count * 2) {
                    waitSem.wait()
                }
                for i in 1...self.gameInstances.count {
                    self.gameInstances[i-1].sort() { $0.gameInstanceId ?? "" < $1.gameInstanceId ?? "" }
                }
                self.gameInstanceTableViewOutlet.reloadData()
            }
        }
    }
    
    // MARK: -UITableViewDataSource implementation
    func numberOfSections(in tableView: UITableView) -> Int {
        return gameInstances.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInstances[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameInstanceCell") as? GameInstanceTableViewCell ?? GameInstanceTableViewCell(style: .value1, reuseIdentifier: "gameInstanceCell")
        
        let gameInstance = gameInstances[indexPath.section][indexPath.row]
        let gameInstanceId = gameInstance.gameInstanceId
        
        let username = opponents[gameInstanceId]?.name ?? "Guest"
        let uid = opponents[gameInstanceId]?.id ?? ""
        let avatarNumber = opponents[gameInstanceId]?.avatar_number ?? 1
        
        cell.usernameLabel.text = username
        cell.uidLabel.text = "ID: \(uid)"
        
        let userId = self.userId ?? ""
        let userScore = gameInstance.players[userId]?.score.count ?? 0
        let opponentScore = gameInstance.players[uid]?.score.count ?? 0
        cell.scoreLabel.text = "\(userScore)-\(opponentScore)"
        
        cell.avatarImageView.image = UIImage(named: "Robot Avatars_\(avatarNumber).png")
        
        cell.usernameLabel.textColor = UIColor.white
        cell.uidLabel.textColor = UIColor.white
        cell.avatarImageView.tintColor = UIColor.white
        cell.scoreLabel.textColor = trivioGreen
        
        cell.backgroundColor = trivioBackgroundColor
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = trivioBlue
        cell.selectedBackgroundView = backgroundView
        
//        cell.textLabel?.text = String(indexPath.row + 1) + ". " + gameInstances[indexPath.row].currentTurn
        return cell
    }
    
    // MARK: -UITableViewDelegate implementation
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = trivioBlue
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 50))
        if section == 0 {
            headerLabel.text = "Active Games"
        } else if section == 1 {
            headerLabel.text = "Pending Games"
        } else {
            headerLabel.text = "Finished Games"
        }
        headerLabel.textColor = trivioGreen
        headerLabel.backgroundColor = trivioBlue
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: check game status here
        let selectedGameInstance = gameInstances[indexPath.section][indexPath.row]
        if selectedGameInstance.gameStatus == "pending"{
            // if still waiting for response. navigate to pendingMessageViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let pendingMessageViewController = storyboard.instantiateViewController(identifier: "pendingMessageViewController") as? PendingMessageViewController else {
                assertionFailure("cannot instantiate pendingMessageViewController")
                return
            }
            pendingMessageViewController.displayMessage = pendingMessageShareGameLink(gameLink: selectedGameInstance.gameInstanceId ?? "")
            navigationController?.pushViewController(pendingMessageViewController, animated: true)
            
        }
        else if selectedGameInstance.gameStatus == "active" && selectedGameInstance.currentTurn != userId {
            // if not user's turn, navigate to pendingMessageViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let pendingMessageViewController = storyboard.instantiateViewController(identifier: "pendingMessageViewController") as? PendingMessageViewController else {
                assertionFailure("cannot instantiate pendingMessageViewController")
                return
            }
            pendingMessageViewController.displayMessage = generateNotYourTurnMessage()
            navigationController?.pushViewController(pendingMessageViewController, animated: true)
        } else if selectedGameInstance.gameStatus == "active" && selectedGameInstance.currentTurn == userId {
            // if user's turn, navigate to spinWheelViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
                assertionFailure("cannot instantiate spinWheelViewController")
                return
            }
            // pass game instance to spinWheelViewController
            spinWheelViewController.gameInstance = selectedGameInstance
            navigationController?.pushViewController(spinWheelViewController, animated: true)
        } else if selectedGameInstance.gameStatus == "finished" && selectedGameInstance.currentTurn != userId {
            // the user lost
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let resultViewController = storyboard.instantiateViewController(identifier: "resultViewController") as? ResultViewController else {
                assertionFailure("cannot instantiate resultViewController")
                return
            }
            resultViewController.playerDidWin = false
            self.navigationController?.pushViewController(resultViewController, animated: true)
            
        } else if selectedGameInstance.gameStatus == "finished" && selectedGameInstance.currentTurn == userId {
            // user win
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let resultViewController = storyboard.instantiateViewController(identifier: "resultViewController") as? ResultViewController else {
                assertionFailure("cannot instantiate resultViewController")
                return
            }
            resultViewController.playerDidWin = true
            self.navigationController?.pushViewController(resultViewController, animated: true)
        }
        
    }
    
    func getUserProfileData(){
        guard let user = Auth.auth().currentUser else {
            assertionFailure("Unable to get current logged in user")
            return
        }
        self.userId = user.uid

        self.ref.child("User/\(user.uid)").getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                let value = snapshot.value as? NSDictionary
                // get user profile info
                let unwrappedAvatarNumber = value?["AvatarNumber"] as? Int ?? 1
                guard let unwrappedUserName = value?["Name"] as? String else { return }
                let unwrappedCoinNumber = value?["CoinNumber"] as? Int ?? 0

                self.userName = unwrappedUserName
                self.avatarNumber = unwrappedAvatarNumber
                self.coinNumber = unwrappedCoinNumber
            }
            else {
                print("No data available")
            }


        }
    }
}
