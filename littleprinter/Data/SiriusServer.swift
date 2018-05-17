//
//  SiriusServer.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

enum SiriusServerError: Error {
    case UnknownError
    case InvalidURL
    case InvalidData
    case NoDataInResponse
    case PrinterNotFound
    case HttpErrorCode(Int)
}

extension SiriusServerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .UnknownError:
            return "Something happened that isn't handled. Sorry about that."
        case .InvalidURL:
            return "Unable to create a valid URL with this key"
        case .InvalidData:
            return "Unable to create data with this message"
        case .NoDataInResponse:
            return "There was no data in the response"
        case .PrinterNotFound:
            return "This printer key cannot be found, it may have been removed"
        case .HttpErrorCode(let code):
            return "Server responded with error code \(code)"
        }
    }
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
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        if let data = data {
                            let string = String(data: data, encoding: String.Encoding.utf8) as String?
                            print("data: " + string!)
                            completion(Result.success(data))
                        } else {
                            completion(.failure(SiriusServerError.NoDataInResponse))
                        }
                    case 404:
                        completion(.failure(SiriusServerError.PrinterNotFound))
                    default:
                        completion(.failure(SiriusServerError.HttpErrorCode(httpResponse.statusCode)))
                    }
                } else {
                    completion(.failure(SiriusServerError.UnknownError))
                }
            }
        }.resume()
    }
    
    func sendPlainText(_ message: String, to key: String, from username: String, completion: @escaping (Error?) -> Void) {
        guard let data = message.data(using: .utf8) else {
            completion(SiriusServerError.InvalidData)
            return
        }
        
        sendData(data, to: key, from: username, contentType: "text/plain", completion: completion)
    }
    
    func sendHTML(_ html: String, to key: String, from username: String, completion: @escaping (Error?) -> Void) {
        guard let data = html.data(using: .utf8) else {
            completion(SiriusServerError.InvalidData)
            return
        }
        
        sendData(data, to: key, from: username, contentType: "text/html", completion: completion)
    }
    
    func sendImage(_ image: UIImage, to key: String, from username: String, completion: @escaping (Error?) -> Void) {
        guard let data = UIImageJPEGRepresentation(image, 1.0) else {
            completion(SiriusServerError.InvalidData)
            return
        }
        
        sendData(data, to: key, from: username, contentType: "image/jpeg", completion: completion)
    }
    
    // MARK: Private

    private func sendData(_ data: Data, to key: String, from username: String, contentType: String, completion: @escaping (Error?) -> Void) {
        guard let url = URL(string: "https://littleprinter.nordprojects.co/printkey/" + key + "?from=" + username) else {
            completion(SiriusServerError.InvalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data

        URLSession.shared.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        completion(nil)
                    case 404:
                        completion(SiriusServerError.PrinterNotFound)
                    default:
                        completion(SiriusServerError.HttpErrorCode(httpResponse.statusCode))
                    }
                } else {
                    completion(SiriusServerError.UnknownError)
                }
            }
        }.resume()
    }
}
