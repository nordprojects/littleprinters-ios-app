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
}

struct Printer: Codable {
    let name: String;
    let code: String;
    let owner: String;
    let status: PrinterStatus;
    
    init(name: String, code: String, owner: String, status: PrinterStatus) {
        self.name = name
        self.code = code
        self.owner = owner
        self.status = status
    }
}
