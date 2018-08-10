//
//  PrinterListTableViewCell.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class PrinterListTableViewCell: UITableViewCell {
    
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "card")
        return imageView
    }()
    
    lazy var thumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "little-printer-graphic")
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        return label
    }()
    
    lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 13)
        return label
    }()
    
    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 13)
        return label
    }()
    
    lazy var messageButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        button.setTitle("Message", for: .normal)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "key"), for: .normal)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete"), for: .normal)
        button.alpha = 0
        return button
    }()
    
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        contentView.addGestureRecognizer(longGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPress))
        contentView.addGestureRecognizer(tapGesture)
        
        messageButton.addTarget(self, action: #selector(messagePressed(_:)), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(sharePressed(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deletePressed(_:)), for: .touchUpInside)
        
        contentView.addSubview(cardImageView)
        contentView.addSubview(thumbnail)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(messageButton)
        contentView.addSubview(shareButton)
        contentView.addSubview(deleteButton)
        
        cardImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(25)
            make.right.equalToSuperview().offset(-25)
            make.height.equalTo(109)
        }
        
        thumbnail.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView).offset(15)
            make.left.equalTo(cardImageView).offset(23)
            make.width.equalTo(56)
            make.height.equalTo(76)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView).offset(11)
            make.left.equalTo(thumbnail.snp.right).offset(30)
        }
        
        ownerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalTo(ownerLabel.snp.bottom).offset(2)
            make.left.equalTo(nameLabel)
        }
        
        messageButton.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView.snp.bottom).offset(-21)
            make.right.equalTo(cardImageView).offset(-12)
            make.width.equalTo(94)
            make.height.equalTo(36)
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(cardImageView)
            make.width.height.equalTo(40)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(cardImageView.snp.left)
            make.centerY.equalTo(cardImageView.snp.top)
            make.width.equalTo(46)
            make.height.equalTo(44)
        }
    }
    
    @objc func sharePressed(_ sender: Any) {
        guard let printer = printer else {
            print("WARNING: No printer object on cell")
            return
        }
        controller?.sharePrinterPressed(printer)
        hideDeleteButton()
    }
    
    @objc func messagePressed(_ sender: Any) {
        guard let printer = printer else {
            print("WARNING: No printer object on cell")
            return
        }
        controller?.newMessagePressed(printer)
        hideDeleteButton()
    }
    
    @objc func deletePressed(_ sender: Any) {
        controller?.deletePrinterPressed(cell: self)
        hideDeleteButton()
    }
    
    @objc func longPress() {
        UIView.animate(withDuration: 0.25) {
            self.deleteButton.alpha = 1.0
        }
    }

    @objc func tapPress() {
        hideDeleteButton()
    }
    
    func hideDeleteButton() {
        deleteButton.alpha = 0
    }
}
