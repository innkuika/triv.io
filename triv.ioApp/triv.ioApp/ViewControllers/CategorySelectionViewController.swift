//
//  CategorySelectionViewController.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 2/17/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CategorySelectionViewController: UIViewController, GameModelUpdates, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var categoryLabel1: UILabel!
    @IBOutlet weak var categoryLabel2: UILabel!
    @IBOutlet weak var categoryLabel3: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    
    var gameInstance: GameModel?
    var categories: [String] = []
    var selectedCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderUI()
        
        gameInstance?.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        gameInstance?.loadCategories()
        print("finished init")
    }
    
    func renderUI() {
        print("render UI")
        styleButton(button: startButton)
        styleSectionLabel(label: categoryLabel1)
        styleSectionLabel(label: categoryLabel2)
        styleSectionLabel(label: categoryLabel3)
    }
    
    func styleSectionLabel(label: UILabel) {
        label.text = ""
        label.layer.cornerRadius = 10
        label.textColor = UIColor.white
        label.layer.masksToBounds = true
    }
    
    // MARK: -GameModelUpdates protocol implementation
    func categoriesDidLoad(_ categories: [String]) {
        self.categories = categories
        categoriesTableView.reloadData()
    }
    
    func selectedCategoriesDidChange(_ selectedCategories: [String]) {
        self.selectedCategories = selectedCategories
        categoryLabel1.text = selectedCategories.count > 0 ? selectedCategories[0] : ""
        categoryLabel1.backgroundColor = selectedCategories.count > 0 ? trivioYellow : trivioBackgroundColor
        
        categoryLabel2.text = selectedCategories.count > 1 ? selectedCategories[1] : ""
        categoryLabel2.backgroundColor = selectedCategories.count > 1 ? trivioYellow : trivioBackgroundColor
        
        categoryLabel3.text = selectedCategories.count > 2 ? selectedCategories[2] : ""
        categoryLabel3.backgroundColor = selectedCategories.count > 2 ? trivioYellow : trivioBackgroundColor
        
        if selectedCategories.count == 3 {
            startButton.backgroundColor = trivioOrange
            startButton.isUserInteractionEnabled = true
        } else {
            startButton.backgroundColor = UIColor.systemGray3
            startButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: -UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") ?? UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        cell.textLabel?.text = categories[indexPath.row]
        cell.imageView?.image = UIImage(systemName: "plus.circle")
        cell.imageView?.tintColor = UIColor.white
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = trivioBackgroundColor
        
        // style selected Cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = trivioBlue
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK: -UITableViewDelegate implementation
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if selectedCategories.count == 3 {
            return nil
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gameInstance?.selectCategory(categories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        gameInstance?.deselectCategory(categories[indexPath.row])
    }
    
    // MARK: -UI action handlers
    @IBAction func cancelButtonPress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func startButtonPress() {
        let categorySelectionWorkerGroup = DispatchGroup()
        categorySelectionWorkerGroup.enter()
        // push selected categories to database
        gameInstance?.updateCategories(syncWorkerGroup: categorySelectionWorkerGroup)
        
        categorySelectionWorkerGroup.notify(queue: DispatchQueue.main) {
            // if there are two players, go straight to the spinWheelView
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if self.gameInstance?.currentCategories?.count == 6 {
                // update user's game
                guard let user = Auth.auth().currentUser else {
                    assertionFailure("Unable to get current logged in user")
                    return
                }
                
                guard let unwrappedGameInstanceId = self.gameInstance?.gameInstanceId else { return }
                self.gameInstance?.userGameInstanceUpdate(userId: user.uid, gameInstanceId: unwrappedGameInstanceId)
                
                // update playerIds, players in game instance, set current turn to new player
                self.gameInstance?.addNewPlayer(newPlayerId: user.uid)
                
                // update game status to active
                self.gameInstance?.updateGameStatus(status: "active")
                guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
                    assertionFailure("cannot instantiate spinWheelViewController")
                    return
                }
                let viewControllers = [spinWheelViewController]
                // pass game instance to spinWheelViewController
                spinWheelViewController.gameInstance = self.gameInstance
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            }
            else {
                guard let opponentSelectionViewController = storyboard.instantiateViewController(identifier: "opponentSelectionViewController") as? OpponentSelectionViewController else {
                    assertionFailure("cannot instantiate opponentSelectionViewController")
                    return
                }
                let viewControllers = [opponentSelectionViewController]
                // pass game instance to opponentSelectionViewController
                opponentSelectionViewController.gameInstance = self.gameInstance
                self.navigationController?.setViewControllers(viewControllers, animated: true)
            }
        }
    }
    
}
