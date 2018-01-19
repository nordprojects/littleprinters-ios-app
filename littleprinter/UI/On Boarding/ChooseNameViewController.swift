//
//  ChooseNameViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ChooseNameViewController: UIViewController, UITextFieldDelegate {
    
    lazy var textField = UITextField()
    lazy var nextButton = ChunkyButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "static")
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        let attributedTitle = NSMutableAttributedString(string: "Choose a name")
        attributedTitle.addAttribute(.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: attributedTitle.length))
        titleLabel.attributedText = attributedTitle
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(38)
            make.centerX.equalToSuperview()
        }
        
        let messageLabel = UILabel()
        messageLabel.font = UIFont(name: "Avenir-Heavy", size: 17)
        messageLabel.numberOfLines = 3
        let attributedString = NSMutableAttributedString(string: "Hi. So you want to message a Little Printer? Choose a name so your friends know who you are.")
        let range = NSRange(location: 0, length: attributedString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.kern, value: CGFloat(-0.19), range: range)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        messageLabel.attributedText = attributedString
        view.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(72)
        }
        
        let container = UIView()
        view.addSubview(container)

        textField.placeholder = "yournamehere"
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.tintColor = .black
        textField.defaultTextAttributes = [NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleSingle.rawValue,
                                           NSAttributedStringKey.font.rawValue : UIFont(name: "Avenir-Heavy", size: 24)!]
        container.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(60)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(24)
            make.right.equalTo(container)
        }

        let atLabel = UILabel()
        atLabel.font = UIFont(name: "Avenir-Heavy", size: 24)
        let attributedAt = NSMutableAttributedString(string: "@")
        attributedAt.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedAt.length))
        atLabel.attributedText = attributedAt
        container.addSubview(atLabel)
        atLabel.snp.makeConstraints { (make) in
            make.right.equalTo(textField.snp.left)
            make.left.equalTo(container)
            make.firstBaseline.equalTo(textField)
        }
        
        container.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(textField)
        }
        
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        nextButton.isEnabled = false
        let attributedButtonTitle = NSMutableAttributedString(string: "Next")
        attributedButtonTitle.addAttribute(.kern, value: CGFloat(0.34), range: NSRange(location: 0, length: attributedButtonTitle.length))
        nextButton.setAttributedTitle(attributedButtonTitle, for: .normal)
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(55)
            make.centerX.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(44)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        nextButton.isEnabled = true
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    @objc func nextPressed() {
        User.shared.name = textField.text
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
