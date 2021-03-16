//
//  CQCreationViewController.swift
//  triv.ioApp
//
//  Created by Donald Lieu on 3/9/21.
//

import UIKit
import FirebaseDatabase

class CQCreationViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var categoryTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") ?? UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = trivioBackgroundColor
        cell.imageView?.tintColor = UIColor.white
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        return cell
    }
    
    
    var categories: [Category] = []
    var selectedCategory: Category?
    var activeTextField: UITextField?
    @IBOutlet weak var questionText: UITextField!
    
    @IBOutlet weak var answerText: UITextField!
    @IBOutlet var incorrectFields: [UITextField]!
    @IBOutlet weak var errorLabel: UILabel!
    
    @objc func doneTapped() {
        self.view.endEditing(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        categorySearchBar.delegate = self
        categorySearchBar.backgroundColor = trivioBackgroundColor
        categorySearchBar.tintColor = trivioBackgroundColor
        categorySearchBar.barTintColor = trivioBackgroundColor
        categoryTable.dataSource = self
        categoryTable.delegate = self
        categoryTable.backgroundColor = trivioBackgroundColor
        ref = Database.database().reference()
        let bar = UIToolbar()
        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        bar.items = [reset]
        bar.sizeToFit()
        questionText.tag = 0
        questionText.delegate = self
        questionText.inputAccessoryView = bar
        answerText.tag = 1
        answerText.delegate = self
        answerText.inputAccessoryView = bar
        incorrectFields[0].tag = 2
        incorrectFields[1].tag = 3
        incorrectFields[2].tag = 4
        for field in incorrectFields {
            field.delegate = self
            field.inputAccessoryView = bar
        }
        errorLabel.text = ""
        NotificationCenter.default.addObserver(self, selector: #selector(CQCreationViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CQCreationViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
        ref.child("Categories").queryLimited(toFirst: 100).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.categories = snapshot.children.compactMap { childSnapshot in
                    guard let childSnapshot = (childSnapshot as? DataSnapshot) else {
                        return nil
                    }
                    print(childSnapshot.key)
                    
                    return CategoryModel(id: childSnapshot.key, name: childSnapshot.key)
                }
                print(self.categories.count)
                self.categoryTable.reloadData()
            }
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        // move the root view up by the distance of keyboard height
        if let activeTextField = activeTextField {

            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            
            let topOfKeyboard = self.view.frame.height - keyboardSize.height

            // if the bottom of Textfield is below the top of keyboard, move up
            if bottomOfTextField > topOfKeyboard {
                self.view.frame.origin.y = 0 - keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    @IBOutlet weak var categorySearchBar: UISearchBar!
    var ref: DatabaseReference!
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ : UISearchBar, textDidChange: String) {
        if textDidChange.isEmpty {
            ref.child("Categories").queryLimited(toFirst: 100).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    self.categories = snapshot.children.compactMap { childSnapshot in
                        guard let childSnapshot = (childSnapshot as? DataSnapshot) else {
                            return nil
                        }
                        print(childSnapshot.key)
                        return CategoryModel(id: childSnapshot.key, name: childSnapshot.key)
                    }
                    self.categoryTable.reloadData()
                }
            }
        } else {
            self.categories = []
            ref.child("Categories").queryOrderedByKey().queryStarting(atValue: textDidChange).queryEnding(atValue: textDidChange + "\u{F8FF}").observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    self.categories = snapshot.children.compactMap { childSnapshot in
                        guard let childSnapshot = (childSnapshot as? DataSnapshot) else {
                            return nil
                        }
                        print(childSnapshot.key)
                        return CategoryModel(id: childSnapshot.key, name: childSnapshot.key)
                    }
                    self.categoryTable.reloadData()
                }
            }
            if self.categories.isEmpty {
                guard let newCategory = CategoryModel(id: textDidChange, name: textDidChange) else { return }
                self.categories = [newCategory]
                self.categoryTable.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
    }

    @IBAction func submitQuestionPressed(_ sender: Any) {
        guard let selectedCategory = selectedCategory else {
            errorLabel.text = "You must select a category for the question!"
            return
        }
        // Create the new question
        guard let question = self.questionText.text,
              let answer = self.answerText.text,
              let incorrect1 = self.incorrectFields[0].text,
              let incorrect2 = self.incorrectFields[1].text,
              let incorrect3 = self.incorrectFields[2].text else {
            return
        }
        guard !question.isEmpty,
              !answer.isEmpty,
              !incorrect1.isEmpty,
              !incorrect2.isEmpty,
              !incorrect3.isEmpty else {
            errorLabel.text = "You must fill out all the fields!"
            return
        }
        let questionRef = self.ref.child("Question")
        questionRef.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            } else if snapshot.exists() {
                let questionKey = String(snapshot.childrenCount + 1)
                questionRef.child(questionKey).setValue(
                    [
                        "Key": answer,
                        "Option": [
                            "0": answer,
                            "1": incorrect1,
                            "2": incorrect2,
                            "3": incorrect3
                        ],
                        "Prompt": question
                    ]
                )
//                self.ref.child("Categories").child(selectedCategory.name).childByAutoId().setValue(questionKey)
                self.ref.child("Categories").child(selectedCategory.name).getData { (error, snapshot) in
                    if let error = error {
                        print("Error getting data \(error)")
                    } else if snapshot.exists() {
                        self.ref.child("Categories").child(selectedCategory.name).child(String(snapshot.childrenCount)).setValue(String(questionKey))
                    } else {
                        self.ref.child("Categories").child(selectedCategory.name).child("0").setValue(String(questionKey))
                    }
                    // Present success VC
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let questionSubmissionViewController = storyboard.instantiateViewController(identifier: "questionSubmissionViewController") as? QuestionSubmissionViewController else {
                            assertionFailure("cannot instantiate questionSubmissionViewController")
                            return
                        }
                        self.navigationController?.setViewControllers([questionSubmissionViewController], animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        // Try to find next responder
        guard let nextResponder: UIResponder = self.view.viewWithTag(nextTag) as? UITextField else {
            textField.resignFirstResponder()
            return false
        }
        nextResponder.becomeFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
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
