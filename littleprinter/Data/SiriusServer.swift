//
//  SiriusServer.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

class SiriusServer {
    
    //static let shared = SiriusServer()
    static let shared = StubSiriusServer()
    
    func getPrinterInfo(code: String, completion: @escaping (Result<Data>) -> Void) {
        
    }
    
    func sendMessage(_ message: String, from username: String, to code: String, completion: @escaping (Error?) -> Void) {
        
    }
}
