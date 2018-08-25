//
//  Printer.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

enum PrinterStatus: String, Codable {
    case unknown
    case online
    case offline
    case error
}

class Printer: Codable {
    static let drawWidth = 384
    
    let key: String
    var info: PrinterInfo
    
    init(key: String, info: PrinterInfo) {
        self.key = key
        self.info = info
    }
}

struct PrinterInfo: Codable {
    let name: String
    let owner: String
    let status: PrinterStatus
    
    init(name: String, code: String, owner: String, status: PrinterStatus) {
        self.name = name
        self.owner = owner
        self.status = status
    }
}
