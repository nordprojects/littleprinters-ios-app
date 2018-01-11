//
//  MockSiriusServer.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

class StubSiriusServer: SiriusServer {
    
    override func getPrinterInfo(key: String, completion: @escaping (Result<Data>) -> Void) {
        let printerDict = [
            "name" : "minterprinter: \(arc4random())",
            "owner" : "@benpawle",
            "status" : "online"
        ]
        
        let data = try! JSONSerialization.data(withJSONObject: printerDict, options: [])
        
        delay (1) {
            completion(Result.success(data))
        }
    }
    
    override func sendMessage(_ message: String, from username: String, to code: String, completion: @escaping (Error?) -> Void) {
        delay (2) {
            completion(nil)
        }
    }
}
