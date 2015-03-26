//
//  TwoLabelCell.swift
//  ContactPicker
//
//  Created by Jordan Focht on 3/26/15.
//  Copyright (c) 2015 Jordan Focht. All rights reserved.
//


class DeselectedRecipientCell: UITableViewCell {
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var recipientLabel: UILabel!
    
    var names: [String] = [] {
        didSet {
            self.recipientLabel.text = shortenNamesToFit(recipientLabel, self.names)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.recipientLabel.text = shortenNamesToFit(recipientLabel, self.names)
    }
}

func shortenNamesToFit(label: UILabel, names: [String]) -> String {
    let attributes: [String: AnyObject] = [NSFontAttributeName: label.font]
    let boundSize = CGSizeMake(CGFloat.max, label.frame.size.height);
    var bestSoFar = shortenNames(names, 1)
    if names.count >= 2 {
        for i in 2...names.count {
            let newCandidate = shortenNames(names, i)
            let boundingRect = newCandidate.boundingRectWithSize(boundSize, options:.UsesLineFragmentOrigin, attributes: attributes, context: nil)
            if boundingRect.width < label.frame.size.width {
                bestSoFar = newCandidate
            } else {
                break
            }
        }
    }
    return bestSoFar
}

func shortenNames(names: [String], numberOfNamesShown: Int) -> String {
    var shortened = ""
    for (i, name) in enumerate(names) {
        if i >= numberOfNamesShown {
            shortened += "\(names.count - numberOfNamesShown) more"
            break
        }
        shortened += name
        if i < names.count - 2 && i < numberOfNamesShown - 1 {
            shortened += ", "
        } else if i == numberOfNamesShown - 1 && i != names.count - 1 || i == names.count - 2 {
            shortened += " & "
        }
    }
    return shortened
}
