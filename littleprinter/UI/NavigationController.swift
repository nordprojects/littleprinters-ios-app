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
        super.viewDidLoad()
        
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font : UIFont(name: "Avenir-Heavy", size: 20)!,
            .kern : 0.4
        ]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = UIImage(named: "navbar")
            appearance.shadowImage = UIImage(named: "navshadow")
            appearance.titleTextAttributes = titleAttrs
            appearance.setBackIndicatorImage(UIImage(named: "back"), transitionMaskImage: UIImage(named: "back"))
            
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            if #available(iOS 15.0, *) {
                navigationBar.compactAppearance = appearance
                navigationBar.compactScrollEdgeAppearance = appearance
            }
        } else {
            navigationBar.setBackgroundImage(UIImage(named: "navbar"), for: .default)
            navigationBar.shadowImage = UIImage(named: "navshadow")
            navigationBar.titleTextAttributes = titleAttrs
            navigationBar.backIndicatorImage = UIImage(named: "back")
            navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back")
        }
        
        navigationBar.tintColor = .black
    }
}
