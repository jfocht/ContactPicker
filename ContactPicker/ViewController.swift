//
//  ViewController.swift
//  ContactPicker
//
//  Created by Jordan Focht on 3/24/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//

import UIKit

private let SubjectRow = 0
private let RecipientRow = 1

let People = ["Alex", "Arjun", "Claire", "Drew", "Isabella", "Jack", "James", "John",
    "Laurel", "Mei", "Nicole", "Oliver", "Peggy", "Sally", "Sam", "Sarah"]

class ViewController: UITableViewController {
    private var filteredPeople = People
    private var items = [String]()
    private var selectionView: ContactSelectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

/**

x Add name to table view when selected
x Auto completion
x Add check marks to names
* Scroll "To" to top

*/


/// MARK: - UITableViewDataSource

extension ViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + self.filteredPeople.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO scroll the text view to the top of the table view
        if indexPath.row == SubjectRow {
            let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell") as TextEntryTableViewCell
            cell.textField.delegate = self
            return cell
        } else if indexPath.row == RecipientRow {
            let cell = tableView.dequeueReusableCellWithIdentifier("toCell") as ContactSelectionView
            self.selectionView = cell
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("personTableViewCell") as DirectMessageTableViewCell
            let person = self.filteredPeople[indexPath.row - 2]
            cell.avatarView.image = UIImage(named: "\(person).png")
            cell.nameLabel.text = person
            if contains(self.items, person) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            return cell
            
        }
    }
}

/// MARK: - UITableViewDelegate

extension ViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == SubjectRow {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as TextEntryTableViewCell
            cell.textField.delegate = self
            cell.textField.becomeFirstResponder()
            // TODO collapse the recipient field
        } else if indexPath.row == RecipientRow {
            self.selectionView?.ingredientField.becomeFirstResponder()
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let selection =  self.filteredPeople[indexPath.row - 2]
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if contains(self.items, selection) {
                self.items = self.items.filter { $0 != selection }
            } else {
                self.items.append(selection)
            }
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.selectionView?.reloadData()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height: CGFloat = 45;
        if indexPath.row == RecipientRow {
            return CGFloat((self.selectionView?.lineCount ?? 1) - 1) * 26.5 + height
        } else {
            return height
        }
    }
    
}


/// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.selectionView?.ingredientField.becomeFirstResponder()
        return false
    }
    
}

/// MARK: - ContactSelectionViewDelegate

extension ViewController: ContactSelectionDataSource {

    func numberOfItemsSelectedInContactSelectionView(view: AnyObject) -> UInt {
        return UInt(self.items.count)
    }

    func contactSelectionView(view: AnyObject, itemAtIndex index: UInt) -> String {
        return self.items[Int(index)]
    }
}

/// MARK: - ContactSelectionViewDataSource

extension ViewController: ContactSelectionDelegate {
    
    func contactSelectionView(view: AnyObject, insertSelection selection: String) {
        if !contains(self.items, selection) {
            NSLog("append selection")
            self.items.append(selection)
            if let index = find(self.filteredPeople, selection) {
                let paths = [NSIndexPath(forRow: index + 2, inSection: 0)]
                self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
            }
        }
        self.updatePeople(People)
    }
    
    func updatePeople(people: [String]) {
        let previousPeople = self.filteredPeople
        self.filteredPeople = people
        self.tableView.beginUpdates()
        let reloadCount = min(previousPeople.count, self.filteredPeople.count)
        let needsUpdate =  Array(0..<reloadCount).filter { previousPeople[$0] != self.filteredPeople[$0] }
        let reloadPaths = needsUpdate.map { NSIndexPath(forRow: $0 + 2, inSection: 0) }
        self.tableView.reloadRowsAtIndexPaths(reloadPaths, withRowAnimation: .None)
        if previousPeople.count > self.filteredPeople.count {
            let deletedPaths = (self.filteredPeople.count..<previousPeople.count).map { NSIndexPath(forRow: $0 + 2, inSection: 0) }
            self.tableView.deleteRowsAtIndexPaths(deletedPaths, withRowAnimation: .None)
        }
        if self.filteredPeople.count > previousPeople.count {
            let insertedPaths = (previousPeople.count..<self.filteredPeople.count).map { NSIndexPath(forRow: $0 + 2, inSection: 0) }
            self.tableView.insertRowsAtIndexPaths(insertedPaths, withRowAnimation: .None)
        }
        self.tableView.endUpdates()
    }

    func contactSelectionView(view: AnyObject, removeSelection selection: String) {
        self.items = self.items.filter { $0 != selection }
        if let index = find(self.filteredPeople, selection) {
            let paths = [NSIndexPath(forRow: index + 2, inSection: 0)]
            self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
        }
    }

    func contactSelectionView(view: AnyObject, insertDictationResult dictationResult: [AnyObject]) {
        // not supported
    }

    func contactSelectionView(contactSelectionView: AnyObject!, didChangeLineCount count: UInt) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func contactSelectionView(contactSelectionView: AnyObject!, didChangeText text: NSString) {
        let trimmedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if trimmedText.isEmpty {
            self.updatePeople(People)
        } else {
            let newPeople = People.filter {
                $0.rangeOfString(text, options: .CaseInsensitiveSearch) != nil
            }
            self.updatePeople(newPeople)
        }
    }

}
