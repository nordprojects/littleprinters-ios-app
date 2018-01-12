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
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        refreshControl = UIRefreshControl()
        if let refreshControl = refreshControl {
            refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
            tableView.addSubview(refreshControl)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .DidUpdatePrinters, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func reload() {
        self.tableView.reloadData()
    }
    
    @objc func refresh(sender:AnyObject) {
        PrinterManager.shared.updatePrinters() // TODO - make this have a completion block once all updated
        delay(1) {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func newMessagePressed(_ printer: Printer) {
        let messageViewController = MessageTypeSelectViewController()
        messageViewController.recipient = printer
        navigationController?.pushViewController(messageViewController, animated: true)
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
        cell.controller = self
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newMessagePressed(PrinterManager.shared.printers[indexPath.row])
    }
}

extension PrinterListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}

