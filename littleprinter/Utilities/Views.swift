//
//  Views.swift
//  littleprinter
//
//  Created by Joe Rickerby on 12/01/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit


class KeyboardLayoutView: UIView {
    var height: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWithKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWithKeyboardNotification(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0, height: height)
    }
    
    @objc func updateWithKeyboardNotification(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        guard let window = self.window else { return }
        
        let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardRect = CGRect(x: 0, y: 0, width: keyboardEndFrame.width, height: window.bounds.maxY - keyboardEndFrame.minY)
        let convertedKeyboardEndFrame = self.convert(keyboardRect, from: self.window)
        height = convertedKeyboardEndFrame.size.height
        
        self.invalidateIntrinsicContentSize()
        
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}

