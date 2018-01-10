//
//  PrinterManager.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

class PrinterManager {
    
    static let shared = PrinterManager()
    var printers: [Printer] = []
    
    init() {
        loadSavedPrinters()
    }
    
    // MARK: Public

    func addPrinterForAddress(_ address: String, completion: @escaping (Error?) -> Void) {
        // TODO: get code from address
        
        let code = address
        SiriusServer.shared.getPrinterInfo(code: code) { (result) in
            
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let value):
                do {
                    let printer = try JSONDecoder().decode(Printer.self, from: value)
                    self.printers.append(printer)
                    self.savePrinters()
                    completion(nil)
                } catch {
                    completion(error)
                }
            }
        }
    }
    
    func removePrinter(at index: Int) {
        printers.remove(at: index)
        savePrinters()
    }
    
    func updatePrinters() {
        // TODO
        // For each printer - get latest info
        // Save priters
    }
    
    // MARK: Private
    
    private func loadSavedPrinters() {
        if let data = UserDefaults.standard.value(forKey:"printers") as? Data,
            let printers = try? PropertyListDecoder().decode(Array<Printer>.self, from: data) {
            self.printers = printers
        }
    }
    
    private func savePrinters() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(printers), forKey:"printers")
    }
}
