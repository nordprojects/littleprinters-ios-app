//
//  MessageTypeSelectViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class MessageTypeSelectViewController: UIViewController {
    
    lazy var tableView = UITableView()
    
    let messageTypes = ["Poster", "Plain Text", "HTML", "Image"]
    
    var recipient: Printer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let printer = recipient {
            self.title = printer.info.name
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageTypeSelectCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

extension MessageTypeSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension MessageTypeSelectViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTypeSelectCell")!
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.text = messageTypes[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch messageTypes[indexPath.row] {
        case "Poster":
            let messageViewController = PosterMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        case "Plain Text":
            let messageViewController = PlainTextMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        case "HTML":
            let messageViewController = HTMLMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        case "Image":
            let messageViewController = ImageMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        default:
            let alert = UIAlertController(title:"Nope", message: "Message type not implemented yet")
            self.present(alert, animated: true, completion: nil)
        }

    }
}

