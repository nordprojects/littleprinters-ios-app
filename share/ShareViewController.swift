//
//  ShareViewController.swift
//  share
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    var image: UIImage?
    
    var selectedPrinter: Printer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PrinterManager.shared.printers.count > 0 {
            selectedPrinter = PrinterManager.shared.printers[0] // TODO - remeber previous selection as default

        }
        
        let contentType = kUTTypeImage as String
        
        // TODO - handle text
        
        print("items: \(extensionContext!.inputItems)")
        
        // TODO - how to handle multiple items?
        if let item = extensionContext?.inputItems[0] as? NSExtensionItem,
            let attachments = item.attachments as? [NSItemProvider] {
            // TODO - how to handle multiple attachments?
            attachments.forEach { (attachment) in
                if attachment.hasItemConformingToTypeIdentifier(contentType) {
                    attachment.loadItem(forTypeIdentifier: contentType, options: [:], completionHandler: { (data, error) in
                        if error == nil {
                            
                            switch data {
                            case let image as UIImage:
                                self.image = image
                            case let data as Data:
                                self.image = UIImage(data: data)
                            case let url as URL:
                                if let imageData = try? Data(contentsOf: url) {
                                    self.image = UIImage(data: imageData)
                                }
                            default:
                                //There may be other cases...
                                print("Unexpected data:", type(of: data))
                            }
                        }
                    })
                }
            }
        }
        
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        if let image = image,
            let printer = selectedPrinter {
            SiriusServer.shared.sendImage(image, to: printer.key, from: User.shared.name ?? "anon") { (error) in
                
                if let error = error {
                    self.extensionContext!.cancelRequest(withError: error)
                    return
                }
                
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    func selectPrinter(_ printer: Printer) {
        selectedPrinter = printer
        reloadConfigurationItems()
        popConfigurationViewController()
    }
    
    override func configurationItems() -> [Any]! {
        
        let selectPrinter = SLComposeSheetConfigurationItem()!
        selectPrinter.title = "Select Printer"
        selectPrinter.value = selectedPrinter?.info.name ?? "none"
        selectPrinter.tapHandler = {
            let selectViewController = ShareSelectPrinterViewController()
            selectViewController.shareController = self
            self.pushConfigurationViewController(selectViewController)
        }
        return [selectPrinter]
    }

}
