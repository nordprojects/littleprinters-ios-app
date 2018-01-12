//
//  ShareSelectPrinterViewController.swift
//  share
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ShareSelectPrinterViewController: UIViewController {
    
    var shareController: ShareViewController?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ShareSelectPrinterCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
    }
}

extension ShareSelectPrinterViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PrinterManager.shared.printers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareSelectPrinterCell", for: indexPath)
        cell.textLabel?.text =  PrinterManager.shared.printers[indexPath.row].info.name
        cell.backgroundColor = .clear
        return cell
    }

}

extension ShareSelectPrinterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shareController?.selectPrinter(PrinterManager.shared.printers[indexPath.row])
    }
}
