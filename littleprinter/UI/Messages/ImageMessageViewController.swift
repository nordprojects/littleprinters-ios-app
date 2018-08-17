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

    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your message"
        textField.autocapitalizationType = .allCharacters
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(textFiedlDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var previewScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        //scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        scrollView.backgroundColor = .clear
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentInset = UIEdgeInsets.zero
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        
        imageTemplateView.delegate = self
        
        view.addSubview(previewScrollView)
        previewScrollView.addSubview(receiptPreviewView)
        
        previewScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
        }
        
        receiptPreviewView.snp.makeConstraints { (make) in
            make.top.equalTo(previewScrollView)
            make.left.right.equalTo(view).inset(24)
            make.bottom.equalTo(previewScrollView)
        }
        
        if let printer = recipient {
            self.title = printer.info.name
        }
        
        // MESSAGE TOOLBAR
        
        let messagingToolbar = UIView()
        view.addSubview(messagingToolbar)
        messagingToolbar.snp.makeConstraints { (make) in
            make.leftMargin.rightMargin.equalTo(view)
            make.top.equalTo(previewScrollView.snp.bottom)
        }

        messagingToolbar.addSubview(messageTextField)
        
        messageTextField.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(messagingToolbar)
        }
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("  Send  ", for: .normal)
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        messagingToolbar.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.left.equalTo(messageTextField.snp.right)
            make.width.equalTo(50)
            make.top.bottom.right.equalTo(messagingToolbar)
        }
        
        let keyboardLayoutView = KeyboardLayoutView()
        view.addSubview(keyboardLayoutView)
        keyboardLayoutView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.top.equalTo(messagingToolbar.snp.bottom)
        }
    }
    
    @objc func chooseImagePressed() {
        PhotoPicker.shared.startMediaBrowserFromController(self)
    }
    
    @objc func captionTapped() {
        if messageTextField.isFirstResponder {
            messageTextField.resignFirstResponder()
        } else {
            messageTextField.becomeFirstResponder()
            scrollToBottom()
        }
    }
    
    @objc func textFiedlDidChange() {
        imageTemplateView.caption = messageTextField.text ?? ""
        scrollToBottom()
    }
    
    func scrollToBottom() {
        let bottom = max(previewScrollView.contentSize.height - previewScrollView.bounds.size.height, 0)
        previewScrollView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
    }
    
    @objc func sendPressed() {
        guard let recipient = recipient else { return }
        guard let image = imageTemplateView.render() else { return }
        let fromName = User.shared.name ?? "App"
        
        do {
            let message = try SiriusMessage(image: image, to: recipient.key, from: fromName)
            navigationController?.pushViewController(
                MessageSendingViewController(message: message, printer: recipient),
                animated: true)
        }
        catch {
            let alert = UIAlertController(title: "Unable to send image to: \(recipient.info.owner)", error: error)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension ImageMessageViewController: PhotoPickerDelegate {
    func pickerDidReturn(_ image: UIImage) {
        imageTemplateView.image = image
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
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.text = "tap to add caption"
        label.textAlignment = .center
        label.font = UIFont(name: "Permanent Marker", size: 22)
        label.textColor = .black
        label.alpha = 0.15
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()
    
    lazy var chooseImageButton: ChunkyButton = {
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
    
    var caption = "" {
        didSet {
            if (caption == "") {
                captionLabel.text = "tap to add caption"
                captionLabel.alpha = 0.15
            } else {
                captionLabel.text = caption
                captionLabel.alpha = 1.0
            }
        }
    }
    
    var image: UIImage? = nil {
        didSet {
            if let image = image {
                imageView.image = image
                let aspect = image.size.height / image.size.width
                imageView.snp.makeConstraints { (make) in
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(imageView.snp.width).multipliedBy(aspect)
                }
                fuzzImageView.snp.remakeConstraints { (make) in
                    make.height.equalTo(0)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(fuzzImageView)
        addSubview(imageView)
        addSubview(captionLabel)
        addSubview(chooseImageButton)
        
        fuzzImageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(fuzzImageView.snp.width).multipliedBy(0.75)
        }
        
        imageView.snp.makeConstraints { (make) in
            //make.height.equalTo(fuzzImageView)
        }
        
        captionLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.greaterThanOrEqualTo(fuzzImageView.snp.bottom).offset(6)
            make.top.greaterThanOrEqualTo(imageView.snp.bottom).offset(6)
            make.height.greaterThanOrEqualTo(31)
        }
        
        chooseImageButton.snp.makeConstraints { (make) in
            make.center.equalTo(fuzzImageView)
            make.width.equalTo(143)
            make.height.equalTo(44)
        }
        
        chooseImageButton.addTarget(self, action: #selector(chooseImagePressed), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(captionTapped))
        captionLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func chooseImagePressed() {
        delegate?.chooseImagePressed()
    }
    
    @objc func captionTapped() {
        delegate?.captionTapped()
    }
    
    // Public methods
    func hideChooseButton() {
        chooseImageButton.isHidden = true
    }
    
    func render() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            let downsizeImage = image?.resizeWithWidth(width: 384)
            return downsizeImage
        }
        return nil
    }
}

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        // Create an ImageView to render into
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Nearest neighbour so nice and pixely
        context.interpolationQuality = .none
        imageView.layer.render(in: context)
        
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
