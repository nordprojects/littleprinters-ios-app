//
//  ChooseNameViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController {
    
    lazy var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Whats yo name?"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.left.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        view.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.width.equalTo(view).offset(-40)
            make.height.equalTo(40)
            make.centerX.equalTo(view)
        }
        
        let sendButton = UIButton()
        sendButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        sendButton.setTitle("Next", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(20)
            make.left.equalTo(textField)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
    }
    
    @objc func nextPressed() {
        User.shared.name = textField.text
        dismiss(animated: true, completion: nil)
    }
    
}
