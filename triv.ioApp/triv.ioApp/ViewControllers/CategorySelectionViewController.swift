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
    
    let gameModel = GameModel()
    var gameInstanceRef: DatabaseReference!
    var categories: [String] = []
    var selectedCategories: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryLabel1.text = ""
        categoryLabel2.text = ""
        categoryLabel3.text = ""
        
        gameModel.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        gameModel.loadCategories()
    }
    
    // MARK: -GameModelUpdates protocol implementation
    func categoriesDidLoad(_ categories: [String]) {
        self.categories = categories
        categoriesTableView.reloadData()
    }
    
    func selectedCategoriesDidChange(_ selectedCategories: [String]) {
        self.selectedCategories = selectedCategories
        categoryLabel1.text = selectedCategories.count > 0 ? selectedCategories[0] : ""
        categoryLabel2.text = selectedCategories.count > 1 ? selectedCategories[1] : ""
        categoryLabel3.text = selectedCategories.count > 2 ? selectedCategories[2] : ""
        
        if selectedCategories.count == 3 {
            startButton.backgroundColor = UIColor(red: 0.51, green: 0.65, blue: 1.00, alpha: 1.00)
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
        gameModel.selectCategory(categories[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        gameModel.deselectCategory(categories[indexPath.row])
    }

    // MARK: -UI action handlers
    @IBAction func cancelButtonPress(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func startButtonPress() {
        // push selected categories to database
        self.gameInstanceRef.child("Categories").setValue(self.selectedCategories)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let spinWheelViewController = storyboard.instantiateViewController(identifier: "spinWheelViewController") as? SpinWheelViewController else {
            assertionFailure("cannot instantiate spinWheelViewController")
            return
        }
        let viewControllers = [spinWheelViewController]
        // pass game instance to categorySelectionViewController
        spinWheelViewController.gameInstanceRef = gameInstanceRef
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
}
