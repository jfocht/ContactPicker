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

// TODO update bottom content inset for keyboard
// TODO iOS 7

class ViewController: UIViewController {
    @IBOutlet weak var fieldTableView: UITableView!
    @IBOutlet weak var completionTableView: UITableView!
    @IBOutlet weak var fieldTableViewHeightConstraint: NSLayoutConstraint!
    
    private var editingRecipients = false
    private var filteredPeople = People
    private var items: [String] = [String]() {
        didSet {
            self.deselectedRecipientCell?.names = items
        }
    }
    private var selectionView: ContactSelectionView?
    private var deselectedRecipientCell: DeselectedRecipientCell?
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("anyTextFieldDidBeginEditing:"), name: UITextFieldTextDidBeginEditingNotification, object: nil)
        center.addObserver(self, selector: Selector("keyboardWasShown:"), name: UIKeyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: Selector("keyboardWillBeHidden:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if let info = notification.userInfo {
            let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue
            if let kbRect = value?.CGRectValue() {
                let kbSize = kbRect.size
                let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
                self.completionTableView?.contentInset = contentInsets
                self.completionTableView?.scrollIndicatorInsets = contentInsets
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.completionTableView?.contentInset = contentInsets
        self.completionTableView?.scrollIndicatorInsets = contentInsets
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        self.fieldTableView?.contentInset = UIEdgeInsetsZero
    }
    
    func anyTextFieldDidBeginEditing(notification: NSNotification) {
        if let field = notification.object as? UITextField {
            if field != self.selectionView?.ingredientField {
                self.editingRecipients = false
                self.fieldTableView?.reloadRowsAtIndexPaths([NSIndexPath(forRow: RecipientRow, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
}


/// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.completionTableView {
            return self.filteredPeople.count
        } else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // TODO scroll the text view to the top of the table view
        if tableView == self.completionTableView {
            let cell = tableView.dequeueReusableCellWithIdentifier("personTableViewCell") as DirectMessageTableViewCell
            let person = self.filteredPeople[indexPath.row]
            cell.avatarView.image = UIImage(named: "\(person).png")
            cell.nameLabel.text = person
            if contains(self.items, person) {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            return cell
        } else {
            if indexPath.row == SubjectRow {
                let cell = tableView.dequeueReusableCellWithIdentifier("subjectCell") as TextEntryTableViewCell
                cell.textField.delegate = self
                return cell
            } else if self.editingRecipients {
                let cell = tableView.dequeueReusableCellWithIdentifier("toCell") as ContactSelectionView
                cell.selectionDataSource = self
                cell.selectionDelegate = self
                self.selectionView = cell
                self.selectionView?.ingredientField.becomeFirstResponder()
                return cell
            } else {
                self.selectionView = nil
                let cell = tableView.dequeueReusableCellWithIdentifier("toCellDeselected") as DeselectedRecipientCell
                self.deselectedRecipientCell = cell
                cell.names = self.items
                return cell
            }
        }
    }
}

/// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell == self.selectionView {
            self.selectionView?.ingredientField.becomeFirstResponder()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.completionTableView {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            let selection =  self.filteredPeople[indexPath.row]
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if contains(self.items, selection) {
                self.items = self.items.filter { $0 != selection }
            } else {
                self.items.append(selection)
            }
            self.completionTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.selectionView?.reloadData()
            self.completionTableView.beginUpdates()
            self.completionTableView.endUpdates()
            if self.selectionView == nil {
                let path = NSIndexPath(forRow: RecipientRow, inSection: 0)
                self.fieldTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .None)
            }
        } else if indexPath.row == SubjectRow {
            self.editingRecipients = false
            let cell = tableView.cellForRowAtIndexPath(indexPath) as TextEntryTableViewCell
            cell.textField.delegate = self
            cell.textField.becomeFirstResponder()
            self.updatePeople(People)
            self.completionTableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        } else if indexPath.row == RecipientRow {
            self.editingRecipients = true
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45
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
            self.items.append(selection)
            if let index = find(self.filteredPeople, selection) {
                let paths = [NSIndexPath(forRow: index, inSection: 0)]
                self.completionTableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
            }
            if self.selectionView == nil {
                let path = NSIndexPath(forRow: RecipientRow, inSection: 0)
                self.fieldTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .None)
            }
        }
        self.updatePeople(People)
    }
    
    func updatePeople(people: [String]) {
        let previousPeople = self.filteredPeople
        self.filteredPeople = people
        self.completionTableView.beginUpdates()
        let reloadCount = min(previousPeople.count, self.filteredPeople.count)
        let needsUpdate =  Array(0..<reloadCount).filter { previousPeople[$0] != self.filteredPeople[$0] }
        let reloadPaths = needsUpdate.map { NSIndexPath(forRow: $0, inSection: 0) }
        self.completionTableView.reloadRowsAtIndexPaths(reloadPaths, withRowAnimation: .None)
        if previousPeople.count > self.filteredPeople.count {
            let deletedPaths = (self.filteredPeople.count..<previousPeople.count).map { NSIndexPath(forRow: $0, inSection: 0) }
            self.completionTableView.deleteRowsAtIndexPaths(deletedPaths, withRowAnimation: .None)
        }
        if self.filteredPeople.count > previousPeople.count {
            let insertedPaths = (previousPeople.count..<self.filteredPeople.count).map { NSIndexPath(forRow: $0, inSection: 0) }
            self.completionTableView.insertRowsAtIndexPaths(insertedPaths, withRowAnimation: .None)
        }
        self.completionTableView.endUpdates()
    }
    
    func contactSelectionView(view: AnyObject, removeSelection selection: String) {
        self.items = self.items.filter { $0 != selection }
        if let index = find(self.filteredPeople, selection) {
            let paths = [NSIndexPath(forRow: index, inSection: 0)]
            self.completionTableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
        }
        if self.selectionView == nil {
            let path = NSIndexPath(forRow: RecipientRow, inSection: 0)
            self.fieldTableView.reloadRowsAtIndexPaths([path], withRowAnimation: .None)
        }
    }
    
    func contactSelectionView(view: AnyObject, insertDictationResult dictationResult: [AnyObject]) {
        // not supported
    }
    
    func contactSelectionView(contactSelectionView: AnyObject!, didChangeLineCount count: UInt) {
        self.fieldTableView.beginUpdates()
        self.fieldTableView.endUpdates()
        
        if let tableView = self.fieldTableView {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), atScrollPosition: .Bottom, animated: false)
        }
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
