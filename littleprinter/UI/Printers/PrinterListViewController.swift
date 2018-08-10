//
//  ViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 09/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import SnapKit

class PrinterListViewController: UIViewController {

    lazy var tableView = UITableView()
    lazy var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        title = "Little Printers"
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        let footer =  AddPrinterFooterView(frame: CGRect(x: 0, y: 0, width: 100, height: 140))
        footer.delegate = self
        tableView.tableFooterView = footer
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(PrinterListTableViewCell.self, forCellReuseIdentifier: "PrinterListTableViewCell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: public delegate methods
    
    func newMessagePressed(_ printer: Printer) {
        let messageViewController = MessageTypeSelectViewController()
        messageViewController.recipient = printer
        navigationController?.pushViewController(messageViewController, animated: true)
    }
    
    func sharePrinterPressed(_ printer: Printer) {
        let sharePrinterViewController = SharePrinterViewController()
        sharePrinterViewController.printer = printer
        navigationController?.pushViewController(sharePrinterViewController, animated: true)
    }
    
    func addPrinterPressed() {
        let addPrinterViewController = AddPrinterViewController()
        navigationController?.pushViewController(addPrinterViewController, animated: true)
    }
    
    func deletePrinterPressed(cell: PrinterListTableViewCell) {
        if let indexPath = self.tableView.indexPath(for: cell) {
            let alert = UIAlertController(title: "Remove \"" + ((cell.printer?.info.name) ?? "printer") + "\"?",
                                          message: "Removing this printer cannot be undone and you will no longer be able to send it messages.",
                                          preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let delete = UIAlertAction(title: "Remove", style: .destructive) { (action) in
                PrinterManager.shared.removePrinter(at: indexPath.row)
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
        }
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
        cell.hideDeleteButton()
        return cell
    }
}

extension PrinterListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
