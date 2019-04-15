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
        label.text = "Share this key so friends can message this printer!"
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
        textView.isSelectable = false
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
    
    lazy var copiedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.text = "Copied"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0;
        return label
    }()
    
    lazy var shareButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        button.setTitle("Share now", for: .normal)
        return button
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "dash")!)
        return view
    }()
    
    lazy var qrLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Heavy", size: 17)
        label.text = "Or print out a QR code to share with people nearby"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0.7
        return label
    }()
    
    lazy var qrButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0xDBEBFF)
        button.borderColor = UIColor(hex: 0xDBEBFF)
        button.shadowColor = UIColor(hex: 0x7295BA)
        button.setTitleColor(UIColor(hex: 0x597FA7), for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 15)
        button.setTitle("Print code", for: .normal)
        button.setImage(UIImage(named: "mini-qr"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.adjustsImageWhenHighlighted = false
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
        view.addSubview(keyTextView)
        view.addSubview(keyControl)
        view.addSubview(👉Label)
        view.addSubview(👈Label)
        view.addSubview(copiedLabel)
        view.addSubview(shareButton)
        view.addSubview(line)
        view.addSubview(qrLabel)
        view.addSubview(qrButton)
        view.addSubview(carefulLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualToSuperview().offset(10).priority(1000)
            make.top.equalToSuperview().offset(60).priority(250)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(280)
        }
    
        keyTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-140)
        }
        
        keyControl.snp.makeConstraints { (make) in
            make.edges.equalTo(keyTextView)
        }

        👉Label.snp.makeConstraints { (make) in
            make.centerY.equalTo(keyTextView)
            make.right.equalTo(keyTextView.snp.left).offset(-12)
        }
        
        👈Label.snp.makeConstraints { (make) in
            make.centerY.equalTo(keyTextView)
            make.left.equalTo(keyTextView.snp.right).offset(12)
        }
        
        copiedLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(keyTextView.snp.top).offset(-6)
            make.centerX.equalToSuperview()
        }
        
        shareButton.snp.makeConstraints { (make) in
            make.top.equalTo(keyTextView.snp.bottom).offset(34)
            make.width.equalTo(124)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(shareButton.snp.bottom).offset(80).priority(250)
            make.top.greaterThanOrEqualTo(shareButton.snp.bottom).offset(10).priority(1000)
            make.left.right.equalToSuperview().inset(25)
            make.height.equalTo(3)
        }
        
        qrLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(54).priority(250)
            make.top.greaterThanOrEqualTo(line.snp.bottom).offset(10).priority(1000)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(230)
        }
        
        qrButton.snp.makeConstraints { (make) in
            make.top.equalTo(qrLabel.snp.bottom).offset(14)
            make.width.equalTo(140)
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
        
        var text = printer?.key ?? "hmmm.... no key found"
        text = text.replacingOccurrences(of: "https://", with: "", options: [], range: nil)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        keyTextView.attributedText = NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                                                   .foregroundColor: keyTextView.textColor!,
                                                                                   .font: keyTextView.font!,
                                                                                   .paragraphStyle: style])
        
        shareButton.addTarget(self, action: #selector(sharePressed), for: .touchUpInside)
        keyControl.addTarget(self, action: #selector(copyTapped), for: .touchDown)
        qrButton.addTarget(self, action: #selector(printQRPressed), for: .touchUpInside)

    }
    
    @objc func copyTapped() {
        if let key = printer?.key {
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = key

            UIView.animate(withDuration: 0.25, animations: {
                self.copiedLabel.alpha = 1.0;
            }, completion: { (true) in
                UIView.animate(withDuration: 0.5, delay: 1.5, options: [], animations: {
                    self.copiedLabel.alpha = 0.0;
                }, completion: nil)
            })
        }
    }
    
    @objc func sharePressed() {
        let key = printer?.key ?? "hmmm.... no key found"
        let text = "Connect to my Little Printer! " + key
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func printQRPressed() {
        let fromName = User.shared.name ?? "App"

        if let printer = printer,
            let qrCode = qrCodeFromText(printer.key) {
            do {
                let message = try SiriusMessage(image: qrCode, to: printer.key, from: fromName)
                navigationController?.pushViewController(
                    MessageSendingViewController(message: message, printer: printer),
                    animated: true)
            }
            catch {
                let alert = UIAlertController(title: "Unable to send QR Code to: \(printer.info.owner)", error: error)
                self.present(alert, animated: true, completion: nil)
            }
    
        }
    }
}
