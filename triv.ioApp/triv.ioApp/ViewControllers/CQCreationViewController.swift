//
//  CQCreationViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/9/21.
//

import UIKit
import FirebaseDatabase

class CQCreationViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
    var categories: [Category] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        categorySearchBar.delegate = self
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        ref.child("Category").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.categories
            }
            
        }
    }
    
    @IBOutlet weak var categorySearchBar: UISearchBar!
    var ref: DatabaseReference!
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ : UISearchBar, textDidChange: String) {
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
