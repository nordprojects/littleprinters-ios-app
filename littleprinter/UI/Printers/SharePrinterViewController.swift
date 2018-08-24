//
//  SharePrinterViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 21/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class SharePrinterViewController: UIViewController {
    
    var printer: Printer?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.text = "Sharing your printer allows your friends to message it."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tellLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.text = "Tell your friends to paste in your Printer Key so they can message it:"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var keyTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(name: "Avenir-Heavy", size: 19)
        textView.isEditable = false
        textView.textAlignment = .center
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.textColor = UIColor(hex: 0x89BEFE)
        return textView
    }()
    
    lazy var keyControl: UIControl = {
        let control = UIControl()
        return control
    }()
    
    lazy var 👉Label: UILabel = {
        let label = UILabel()
        label.text = "👉"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var 👈Label: UILabel = {
        let label = UILabel()
        label.text = "👈"
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "dash")!)
        return view
    }()
    
    lazy var altLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.text = "Alternatively, send your Printer Key via your preferred app"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var shareButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        button.setTitle("Share now", for: .normal)
        return button
    }()
    
    lazy var carefulLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 13)
        label.text = "Careful who you share this with. Anyone with the link will be able to message your printer"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor(hex: 0x9C9C9C)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        title = printer!.info.name
        
        view.addSubview(titleLabel)
        view.addSubview(tellLabel)
        view.addSubview(keyTextView)
        view.addSubview(keyControl)
        view.addSubview(👉Label)
        view.addSubview(👈Label)
        view.addSubview(line)
        view.addSubview(altLabel)
        view.addSubview(shareButton)
        view.addSubview(carefulLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(300)
        }
        
        tellLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(66)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(300)
        }
        
        keyTextView.snp.makeConstraints { (make) in
            make.top.equalTo(tellLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        👉Label.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(keyTextView.snp.firstBaseline)
            make.right.equalTo(keyTextView.snp.left).offset(-12)
        }
        
        👈Label.snp.makeConstraints { (make) in
            make.firstBaseline.equalTo(keyTextView.snp.firstBaseline)
            make.left.equalTo(keyTextView.snp.right).offset(12)
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(keyTextView.snp.bottom).offset(60).priority(500)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(3)
        }
        
        altLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(60).priority(250)
            make.top.greaterThanOrEqualTo(line.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(280)
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.top.equalTo(altLabel.snp.bottom).offset(14)
            make.width.equalTo(124)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(carefulLabel.snp.top).offset(-20)
        }
        
        carefulLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-24)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(300)
        }
        
        let text = printer?.key ?? "hmmm.... no key found"
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        keyTextView.attributedText = NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                                                                                   .foregroundColor: keyTextView.textColor!,
                                                                                   .font: keyTextView.font!,
                                                                                   .paragraphStyle: style])
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tap)
        
        shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
    }
    
    @objc func backgroundTapped() {
        keyTextView.resignFirstResponder()
    }
    
    @objc func sharePressed() {
        let key = printer?.key ?? "hmmm.... no key found"
        let text = "Connect to my Little Printer! http://littleprinter.nordprojects.co/printkey/" + key
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}
