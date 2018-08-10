//
//  ImageMessageViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

protocol PhotoPickerDelegate {
    func pickerDidReturn(_ image: UIImage)
}

class ImageMessageViewController: UIViewController {
    
    var recipient: Printer?
    
    lazy var imageTemplateView: ImageTemplateView = {
        let view = ImageTemplateView()
        return view
    }()
    
    lazy var receiptPreviewView: ReceiptPreviewView = {
        let view = ReceiptPreviewView(innerView: imageTemplateView)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        
        imageTemplateView.delegate = self
        
        view.addSubview(receiptPreviewView)
        
        receiptPreviewView.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.right.equalTo(view).inset(24)
        }
        
        if let printer = recipient {
            self.title = printer.info.name
        }
    }
    
    @objc func choosePressed() {
        PhotoPicker.shared.startMediaBrowserFromController(self)
    }
    
    @objc func sendPressed() {
        let fromName = User.shared.name ?? "App"

        if let printer = recipient,
            let image = imageTemplateView.imageView.image {
            do {
                let message = try SiriusMessage(image: image, to: printer.key, from: fromName)
                navigationController?.pushViewController(
                    MessageSendingViewController(message: message, printer: recipient!),
                    animated: true)
            }
            catch {
                let alert = UIAlertController(title: "Unable to send image to: \(recipient?.info.owner ?? "nil")", error: error)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension ImageMessageViewController: PhotoPickerDelegate {
    func pickerDidReturn(_ image: UIImage) {
        imageTemplateView.imageView.image = image
        imageTemplateView.hideChooseButton()
    }
}

class ImageTemplateView: UIView, UITextViewDelegate {
    
    lazy var fuzzImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "fuzz")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = "tap to add caption"
        textView.textAlignment = .center
        textView.font = UIFont(name: "Permanent Marker", size: 22)
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.textColor = UIColor(white: 0.0, alpha: 0.15)
        return textView
    }()
    
    lazy var chooseButton: ChunkyButton = {
        let button = ChunkyButton()
        button.topColor = UIColor(hex: 0x89BEFE)
        button.borderColor = UIColor(hex: 0x89BEFE)
        button.shadowColor = UIColor(hex: 0x4177AF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        button.setTitle("Choose image", for: .normal)
        return button
    }()
    
    var delegate: ImageMessageViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(fuzzImageView)
        addSubview(imageView)
        addSubview(textView)
        addSubview(chooseButton)
        
        fuzzImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(fuzzImageView.snp.width).multipliedBy(0.75)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(fuzzImageView)
        }
        
        textView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(fuzzImageView.snp.bottom).offset(6)
            make.height.greaterThanOrEqualTo(31)
        }
        
        chooseButton.snp.makeConstraints { (make) in
            make.center.equalTo(fuzzImageView)
            make.width.equalTo(143)
            make.height.equalTo(44)
        }
        
        chooseButton.addTarget(self, action: #selector(choosePressed), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func choosePressed() {
        delegate?.choosePressed()
    }
    
    // Public methods
    func hideChooseButton() {
        chooseButton.isHidden = true
    }
    
    // Hack in placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(white: 0.0, alpha: 0.15) {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "tap to add caption"
            textView.textColor = UIColor(white: 0.0, alpha: 0.15)
        }
    }
}

