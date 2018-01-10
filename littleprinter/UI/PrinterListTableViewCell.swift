//
//  PrinterListTableViewCell.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class PrinterListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var printer: Printer? {
        didSet {
            if let printer = printer {
                nameLabel.text = printer.name
                ownerLabel.text = "Owner: " + printer.owner
                statusLabel.text = "Status: " + printer.status.rawValue
            }
        }
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        
    }
    
}
