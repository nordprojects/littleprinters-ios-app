//
//  ViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 09/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class PrinterListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension PrinterListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PrinterManager.shared.printers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PrinterListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PrinterListTableViewCell")! as! PrinterListTableViewCell
        cell.printer = PrinterManager.shared.printers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            PrinterManager.shared.removePrinter(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}

extension PrinterListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}

