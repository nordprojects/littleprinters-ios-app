//
//  SiriusServer.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

enum SiriusServerError: Error {
    case InvalidURL
    case NoDataInResponse
}

class SiriusServer {
    
    static let shared = SiriusServer()
    
    func getPrinterInfo(key: String, completion: @escaping (Result<Data>) -> Void) {
        guard let url = URL(string: "https://littleprinter.nordprojects.co/printkey/" + key) else {
            completion(.failure(SiriusServerError.InvalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    completion(Result.success(data))
                } else {
                    completion(.failure(SiriusServerError.NoDataInResponse))
                }
            }
        }.resume()
    }
    
    func sendMessage(_ message: String, from username: String, to code: String, completion: @escaping (Error?) -> Void) {
        
    }
}
