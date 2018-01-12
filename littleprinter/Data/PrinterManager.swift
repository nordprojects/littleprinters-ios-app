//
//  PrinterManager.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let DidUpdatePrinters = Notification.Name("DidUpdatePrinters")
}

class PrinterManager {
    
    static let shared = PrinterManager()
    var printers: [Printer] = []
    
    init() {
        loadSavedPrinters()
        updatePrinters()
    }
    
    // MARK: Public

    func addPrinterForAddress(_ address: String, completion: @escaping (Error?) -> Void) {
        // TODO: get key from address
        let key = address
        
        SiriusServer.shared.getPrinterInfo(key: key) { (result) in
            
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let value):
                do {
                    let printerInfo = try JSONDecoder().decode(PrinterInfo.self, from: value)
                    let printer = Printer(key: key, info: printerInfo)
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
        printers.forEach { printer in
            SiriusServer.shared.getPrinterInfo(key: printer.key, completion: { (result) in
                switch result {
                case .failure(let error):
                    print("ERROR: Unable to update printer \(printer) - \(error.localizedDescription)")
                case .success(let value):
                    do {
                        let printerInfo = try JSONDecoder().decode(PrinterInfo.self, from: value)
                        printer.info = printerInfo
                        self.savePrinters()
                    } catch {
                        print("ERROR: Unable to parse printer update \(printer) - \(error.localizedDescription)")
                    }
                }
            })
        }
    }
    
    // MARK: Private
    
    private func loadSavedPrinters() {
        if let data = UserDefaults.group.value(forKey:"printers") as? Data,
            let printers = try? PropertyListDecoder().decode(Array<Printer>.self, from: data) {
            self.printers = printers
        }
    }
    
    private func savePrinters() {
        UserDefaults.group.set(try? PropertyListEncoder().encode(printers), forKey:"printers")
        NotificationCenter.default.post(Notification(name: .DidUpdatePrinters, object: self))
    }
}
