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
    convenience init(title: String, error: Error) {
        self.init(title: title, message: error.localizedDescription, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    convenience init(title: String, message: String) {
        self.init(title: title, message: message, preferredStyle: .alert)
        self.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}
