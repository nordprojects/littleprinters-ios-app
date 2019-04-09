//
//  AddPrinterViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class AddPrinterViewController: UIViewController {
    
    lazy var closeKeyboardControl = UIControl()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.numberOfLines = 2
        let attributedString = NSMutableAttributedString(string: "Paste the Printer Key\ninto the box below.")
        let range = NSRange(location: 0, length: attributedString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        label.attributedText = attributedString
        return label
    }()
    
    lazy var keyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "e.g littleprinter.nordprojects.co/printkey/acb123abc123abc123"
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 2
        textField.textAlignment = .center
        textField.font = UIFont(name: "Avenir-Medium", size: 19)
        textField.tintColor = .black
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    lazy var addButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        button.setTitle("Add printer", for: .normal)
        return button
    }()
    
    lazy var noKeyButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 15)
        let attr = NSMutableAttributedString(string: "Don’t have a Printer Key?")
        attr.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attr.length))
        attr.addAttribute(.foregroundColor, value: UIColor(hex: 0xFE7B17), range: NSRange(location: 0, length: attr.length))
        button.setAttributedTitle(attr, for: .normal)
        return button
    }()
    
    var printerKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        title = "Add a printer"
        
        closeKeyboardControl.addTarget(self, action: #selector(closeKeyboard), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addPrinterPressed(_:)), for: .touchUpInside)
        noKeyButton.addTarget(self, action: #selector(learnMorePressed(_:)), for: .touchUpInside)

        keyTextField.text = printerKey
        
        view.addSubview(closeKeyboardControl)
        view.addSubview(messageLabel)
        view.addSubview(keyTextField)
        view.addSubview(addButton)
        view.addSubview(noKeyButton)
        
        closeKeyboardControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
        }
        
        keyTextField.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(50)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.top.equalTo(keyTextField.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(134)
            make.height.equalTo(40)
        }
        
        noKeyButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(25)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
    }
    
    @objc func closeKeyboard() {
        keyTextField.resignFirstResponder()
    }
    
    @objc func addPrinterPressed(_ sender: Any) {
        guard let address = keyTextField.text,
            !address.isEmpty else {
            let alert = UIAlertController(title: "We need the adresss", message:"Please paste the printer key into the text field")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Print keys didn't used to be full urls, so to handle legacy keys check if not a URL and convert
        var convertedAddres: String
        if let url = URL(string: address),
            let _ = url.scheme {
            convertedAddres = address
        } else {
            convertedAddres = "https://littleprinter.nordprojects.co/printkey/" + address
        }
        
        PrinterManager.shared.addPrinterForAddress(convertedAddres) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Couldn't add that printer", error: error)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func learnMorePressed(_ sender: Any) {
        let url = URL(string: "http://littleprinter.nordprojects.co/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
