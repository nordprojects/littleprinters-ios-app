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
    
    weak var controller: PrinterListViewController?
    
    var printer: Printer? {
        didSet {
            if let info = printer?.info {
                nameLabel.text = info.name
                ownerLabel.text = "Owner: @" + info.owner
                statusLabel.text = "Status: " + info.status.rawValue
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        selectionStyle = .none
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
    }
    
    @IBAction func messagePressed(_ sender: Any) {
        guard let printer = printer else {
            print("WARNING: No printer object on cell")
            return
        }
        controller?.newMessagePressed(printer)
    }
    
}
