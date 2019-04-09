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
        migratePrinters()
        loadSavedPrinters()
        updatePrinters()
    }
    
    // MARK: Public

    func addPrinterForAddress(_ address: String, completion: @escaping (Error?) -> Void) {
        SiriusServer.shared.getPrinterInfo(key: address) { (result) in
            
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let value):
                do {
                    let printerInfo = try JSONDecoder().decode(PrinterInfo.self, from: value)
                    let printer = Printer(key: address, info: printerInfo)
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
    
    var lastUsedPrinter: Printer? {
        get {
            guard let key = UserDefaults.group.string(forKey: "lastUsedPrinterKey") else {
                return nil
            }
            
            return printer(withKey: key)
        }
        set {
            UserDefaults.group.set(newValue?.key, forKey: "lastUsedPrinterKey")
        }
    }
    
    func printer(withKey key: String) -> Printer? {
        return printers.first(where: { $0.key == key })
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
    
    private func migratePrinters() {
        // Printer keys were originally stored as 'abc123abc123abc' but are now stored as urls, 'https://server.co/abc123abc123abc'
        // migratePrinters() converts any old keys to urls
        if let data = UserDefaults.group.value(forKey:"printers") as? Data,
            let printers = try? PropertyListDecoder().decode(Array<Printer>.self, from: data) {
            let migratedPrinters = printers.map { (printer) -> Printer in
                if let potentialURL = URL(string: printer.key),
                    let _ = potentialURL.scheme {
                    return printer
                } else {
                    print("Migrating printer: \(printer.key)")
                    return Printer(key: "https://littleprinter.nordprojects.co/printkey/" + printer.key, info: printer.info)
                }
            }
            UserDefaults.group.set(try? PropertyListEncoder().encode(migratedPrinters), forKey:"printers")
        }
    }
}
