//
//  FriendListViewController.swift
//  triv.ioApp
//
//  Created by Jessica Ma on 3/4/21.
//

import UIKit

class FriendListViewController: UIViewController {

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var friendRequestView: UIView!
    @IBOutlet weak var friendRequestLabel: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

//        friendRequestView.layer.cornerRadius = 20
    }
    
    // MARK: -UI action handlers
    @IBAction func acceptButtonPress() {
    }
    @IBAction func declineButtonPress() {
    }
    @IBAction func addFriendButtonPress() {
    }
    
}
