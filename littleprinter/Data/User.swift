//
//  User.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

class User {
    
    var name: String? {
        didSet {
            saveName()
        }
    }
    
    static let shared = User()
    
    init() {
        loadName()
    }
    
    func loadName() {
        if let username = UserDefaults.standard.value(forKey: "username") as? String {
            self.name = username
        }
    }
    
    func saveName() {
        UserDefaults.standard.set(name, forKey: "username")
    }
}
