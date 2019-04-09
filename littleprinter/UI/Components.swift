//
//  Components.swift
//  littleprinter
//
//  Created by Michael Colville on 19/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ChunkyButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        contentEdgeInsets = UIEdgeInsets.init(top: -2, left: 2, bottom: 2, right: -2)
    }
    
    override var isHighlighted: Bool {
        didSet {
            contentEdgeInsets = isHighlighted ? .zero : UIEdgeInsets.init(top: -2, left: 2, bottom: 2, right: -2)
            setNeedsDisplay()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.15
        }
    }
    
    var topColor: UIColor = .white
    var borderColor: UIColor = .black
    var shadowColor: UIColor = .black
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: 2, dy: 2)
        let shadowRect = insetRect.offsetBy(dx: -2, dy: 2)
        let borderRect = (state == .highlighted) ? insetRect : insetRect.offsetBy(dx: 2, dy: -2)
        let topRect = borderRect.insetBy(dx: 2, dy: 2)
        
        shadowColor.set()
        UIBezierPath(rect: shadowRect).fill()
        
        borderColor.set()
        UIBezierPath(rect: borderRect).fill()

        topColor.set()
        UIBezierPath(rect: topRect).fill()
    }
}

protocol MessagingToolbarDelegate {
    func textFieldDidChange()
    func sendPressed()
}

class MessagingToolbar: UIView {
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your message"
        textField.autocapitalizationType = .allCharacters
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "send"), for: .normal)
        button.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var outline: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor(hex: 0xC8C8CD).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 18
        return view
    }()
    
    var delegate: MessagingToolbarDelegate?
    
    var text: String? {
        get {
            return messageTextField.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(outline)
        addSubview(messageTextField)
        addSubview(sendButton)
        
        outline.snp.makeConstraints { (make) in
            make.height.equalTo(34)
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
        }
        
        messageTextField.snp.makeConstraints { (make) in
            make.left.equalTo(outline).offset(12)
            make.centerY.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(messageTextField.snp.right).offset(12)
            make.width.height.equalTo(26)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldDidChange() {
        delegate?.textFieldDidChange()
    }
    
    @objc func sendPressed() {
        delegate?.sendPressed()
    }
    
    override var isFirstResponder: Bool {
        get {
            return messageTextField.isFirstResponder
        }
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
        return messageTextField.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
        return messageTextField.resignFirstResponder()
    }
}
