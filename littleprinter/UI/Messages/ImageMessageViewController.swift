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

class ImageMessageViewController: UIViewController, MessagingToolbarDelegate {
    
    var recipient: Printer?
    
    lazy var imageTemplateView: ImageTemplateView = {
        let view = ImageTemplateView()
        view.delegate = self
        return view
    }()
    
    lazy var receiptPreviewView: ReceiptPreviewView = {
        let view = ReceiptPreviewView(innerView: imageTemplateView)
        return view
    }()
    
    lazy var previewScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.isDirectionalLockEnabled = true
        scrollView.contentInset = UIEdgeInsets.zero
        return scrollView
    }()
    
    lazy var messagingToolbar: MessagingToolbar = {
        let toolBar = MessagingToolbar()
        toolBar.delegate = self
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        title = recipient?.info.name ?? ""
        
        view.addSubview(previewScrollView)
        previewScrollView.addSubview(receiptPreviewView)
        view.addSubview(messagingToolbar)

        
        previewScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
        }
        
        receiptPreviewView.snp.makeConstraints { (make) in
            make.top.equalTo(previewScrollView)
            make.left.right.equalTo(view).inset(24)
            make.bottom.equalTo(previewScrollView)
        }
        
        messagingToolbar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalTo(previewScrollView.snp.bottom)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom)
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
        if messagingToolbar.isFirstResponder {
            messagingToolbar.resignFirstResponder()
        } else {
            messagingToolbar.becomeFirstResponder()
            scrollToBottom()
        }
    }
    
    func textFieldDidChange() {
        imageTemplateView.caption = messagingToolbar.text ?? ""
        scrollToBottom()
    }
    
    func scrollToBottom() {
        let bottom = max(previewScrollView.contentSize.height - previewScrollView.bounds.size.height, 0)
        previewScrollView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
    }
    
    func sendPressed() {
        if imageTemplateView.image == nil {
            let alert = UIAlertController(title: "Missing Image", message: "You need to choose an image.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
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
                imageView.image = image.ditheredImage(withWidth: 384)
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
        
        if caption == "" {
            captionLabel.alpha = 0.0
        }
        
        // reset dither
        imageView.image = image
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {

            // Draw view into image
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            // Scale image to printer width
            let downsizeImage = image?.ditheredImage(withWidth: 384)
            
            return downsizeImage
        }
        return nil
    }
}
