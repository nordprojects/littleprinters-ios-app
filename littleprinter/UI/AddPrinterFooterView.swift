//
//  AddPrinterFooterView.swift
//  littleprinter
//
//  Created by Michael Colville on 20/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class AddPrinterFooterView: UIView {
    
    weak var delegate: PrinterListViewController?
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "dash")!)
        return view
    }()
    
    lazy var addPrinterButton: ChunkyButton = {
        let button = ChunkyButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 14)
        button.setTitle("Add a printer", for: .normal)
        button.addTarget(self, action: #selector(addPrinterPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(line)
        addSubview(addPrinterButton)
        line.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview().inset(25).priority(500)
            make.height.equalTo(3)
        }
        addPrinterButton.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(38)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(132)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addPrinterPressed() {
        delegate?.addPrinterPressed()
    }
}
