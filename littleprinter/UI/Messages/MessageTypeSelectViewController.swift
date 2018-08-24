//
//  MessageTypeSelectViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

enum MessageType {
    case poster
    case dithergram
    case selfie
    case quickDraw
    
    func imageName() -> String {
        switch self {
        case .poster: return "message-poster"
        case .dithergram: return "message-dithergram"
        case .selfie: return "message-selfie"
        case .quickDraw: return "message-quick-draw"
        }
    }
}

class MessageTypeSelectViewController: UIViewController {
    
    lazy var tableView = UITableView()
    
    let messageTypes: [MessageType] = [.poster, .dithergram]
    
    var recipient: Printer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor(patternImage: UIImage(named: "receipt-background")!)
        self.title = "New message"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.register(MessageTypeTableViewCell.self, forCellReuseIdentifier: "MessageTypeSelectCell")
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        tableView.alwaysBounceVertical = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func messageTypeSelected(_ messageType: MessageType) {
        switch messageType {
        case .poster:
            let messageViewController = PosterMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        case .dithergram:
            let messageViewController = ImageMessageViewController()
            messageViewController.recipient = recipient
            navigationController?.pushViewController(messageViewController, animated: true)
        default:
            let alert = UIAlertController(title:"Nope", message: "Message type not implemented yet")
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MessageTypeSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 286
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
        let cell: MessageTypeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MessageTypeSelectCell")! as! MessageTypeTableViewCell
        cell.messageType = messageTypes[indexPath.row]
        cell.controller = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTypeSelected(messageTypes[indexPath.row])
    }
    
    // TODO - hide html somewhere
    /*
     let messageViewController = HTMLMessageViewController()
     messageViewController.recipient = recipient
     navigationController?.pushViewController(messageViewController, animated: true)
     */
}

class MessageTypeTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor(hex: 0x8F8F8F).cgColor
        view.layer.shadowOpacity = 0.22
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowRadius = 4
        return view
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var useButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        button.setTitle("Use", for: .normal)
        return button
    }()
    
    var messageType: MessageType? {
        didSet {
            if let messageType = messageType {
                messageImageView.image = UIImage(named: messageType.imageName())
            }
        }
    }
    
    var controller: MessageTypeSelectViewController?
    
    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    
        contentView.addSubview(cardView)
        cardView.addSubview(messageImageView)
        contentView.addSubview(useButton)
        
        cardView.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(250)
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
        messageImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        useButton.snp.makeConstraints { (make) in
            make.width.equalTo(74)
            make.height.equalTo(36)
            make.centerX.equalToSuperview().offset(-2)
            make.centerY.equalTo(cardView.snp.bottom).offset(-2)
        }
        
        useButton.addTarget(self, action: #selector(usePressed), for: .touchUpInside)
    }
    
    @objc func usePressed() {
        if let messageType = messageType {
            controller?.messageTypeSelected(messageType)
        }
    }
}
