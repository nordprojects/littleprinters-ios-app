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
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWithKeyboardNotification(_:)),
                                               name: .UIKeyboardWillHide,
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
        
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardRect = CGRect(x: 0, y: 0, width: keyboardEndFrame.width, height: window.bounds.maxY - keyboardEndFrame.minY)
        let convertedKeyboardEndFrame = self.convert(keyboardRect, from: self.window)
        height = convertedKeyboardEndFrame.size.height
        
        self.invalidateIntrinsicContentSize()
        
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}

