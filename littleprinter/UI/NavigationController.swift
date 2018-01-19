//
//  NavigationController.swift
//  littleprinter
//
//  Created by Michael Colville on 19/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        navigationBar.setBackgroundImage(UIImage(named: "navbar"), for: .default)
        navigationBar.shadowImage = UIImage(named: "navshadow")
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont(name: "Avenir-Heavy", size: 20)!,
                                             NSAttributedStringKey.kern : 0.4]
        navigationBar.tintColor = .black
        navigationBar.backIndicatorImage = #imageLiteral(resourceName: "back")
        navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back")
    }
}
