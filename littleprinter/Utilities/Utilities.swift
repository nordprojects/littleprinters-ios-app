//
//  Utilities.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

extension UIAlertController {
    convenience init(title: String, error: Error, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, message: error.localizedDescription, handler: handler)
    }
    
    convenience init(title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
    }
}

extension UserDefaults {
    static let group = UserDefaults(suiteName: "group.co.nordprojects.littleprinter")!
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF)
    }
    
    convenience init(red: Int, green: Int, blue: Int, hexAlpha: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: hexAlpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat) {
        self.init(red: (hex >> 16) & 0xFF, green: (hex >> 8) & 0xFF, blue: hex & 0xFF, hexAlpha: alpha)
    }
}

protocol HasAlso { }
extension HasAlso {
    func also(closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
}
extension NSObject: HasAlso { }

/**
 * Calls `inner` repeatedly until the callback is called without an error.
 *
 * After the timeout expires, the next failure will be passed back to `completion`.
 */
func retryUntilSuccessful(timeout: TimeInterval,
                          retryDelay: TimeInterval = 0.5,
                          do inner: @escaping (_ completion: @escaping (Error?) -> Void) -> Void,
                          completion: @escaping (Error?) -> Void) {
    let giveUpTime = DispatchTime.now() + timeout
    
    var innerCompletion: ((Error?) -> Void)? = nil
    
    innerCompletion = { (error: Error?) in
        if error == nil {
            // success
            completion(nil)
            return
        } else {
            if DispatchTime.now() > giveUpTime {
                // give up
                completion(error)
            } else {
                // retry
                delay(retryDelay) {
                    inner(innerCompletion!)
                }
            }
        }
    }
    
    inner(innerCompletion!)
}

extension UIView {
    func renderToImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!

        // Draw view into image
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
