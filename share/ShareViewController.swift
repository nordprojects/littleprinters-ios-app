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
import HTMLString

class ShareViewController: SLComposeServiceViewController {
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    var page: [PageFragment] = []
    
    class PageFragment {
        var html: String = ""
        var loadingComplete = false

        init() {}

        init(text: String) {
            html = "<p>\(text.addingASCIIEntities)</p>"
            loadingComplete = true
        }
        init(header: String) {
            html = "<h1>\(header.addingASCIIEntities)</h1>"
            loadingComplete = true
        }
        init(html: String) {
            self.html = html
            loadingComplete = true
        }
    }
    var selectedPrinter: Printer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PrinterManager.shared.printers.count > 0 {
            selectedPrinter = PrinterManager.shared.lastUsedPrinter ?? PrinterManager.shared.printers.first
        }
        
        buildPageFromExtensionItems()
    }
    
    override func didSelectPost() {
        if contentText.count > 0 {
            page.append(PageFragment(text: contentText))
        }
        
        let html = page.map { $0.html }.joined(separator: "\n")
        
        guard let printer = selectedPrinter else {
            self.extensionContext!.cancelRequest(withError: ShareError.NoPrinterSelected)
            return
        }
        
        PrinterManager.shared.lastUsedPrinter = printer
        
        var message: SiriusMessage?
        do {
            message = try SiriusMessage(html: html, to: printer.key, from: User.shared.name ?? "anon")
        }
        catch {
            self.extensionContext!.cancelRequest(withError: error)
            return
        }
        
        
        retryUntilSuccessful(timeout: 60.0, retryDelay: 2.0, do: { (completion) in
            print("Share sheet message sending...")
            _ = SiriusServer.shared.sendMessage(message!, completion: completion)
        }, completion: { (error) in
            if let error = error {
                print("Share sheet message send failed!", error)
                self.extensionContext!.cancelRequest(withError: error)
                return
            }
            print("Share sheet message sent successfully.")
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        })

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
    
    private func buildPageFromExtensionItems() {
        guard let items = extensionContext?.inputItems else {
            return
        }
        
        for item in items {
            guard let item = item as? NSExtensionItem else { continue }
            
            if let title = item.attributedTitle {
                do {
                    page.append(PageFragment(html: "<h1>\(try title.htmlString())</h1>"))
                }
                catch {
                    print("html encoding of content failed.", error)
                    page.append(PageFragment(header: title.string))
                }
            }
            if let content = item.attributedContentText {
                do {
                    page.append(PageFragment(html: "<p>\(try content.htmlString())</p>"))
                }
                catch {
                    print("html encoding of content failed.", error)
                    page.append(PageFragment(text: content.string))
                }
            }
            
            if let attachments = item.attachments as? [NSItemProvider] {
                for attachment in attachments {
                    let imageType = kUTTypeImage as String
                    if attachment.hasItemConformingToTypeIdentifier(imageType) {
                        let pageFragment = PageFragment()
                        page.append(pageFragment)
                        
                        attachment.loadItem(forTypeIdentifier: imageType, options: [:]) { (data, error) in
                            pageFragment.loadingComplete = true
                            if let error = error {
                                print("Failed to load item in \(attachment). \(error)")
                                return
                            }
                            if error == nil {
                                var attachedImage: UIImage? = nil
                                
                                switch data {
                                case let image as UIImage:
                                    attachedImage = image
                                case let data as Data:
                                    attachedImage = UIImage(data: data)
                                case let url as URL:
                                    if let imageData = try? Data(contentsOf: url) {
                                        attachedImage = UIImage(data: imageData)
                                    }
                                default:
                                    //There may be other cases...
                                    print("Unexpected data:", type(of: data))
                                    return
                                }
                                
                                attachedImage = attachedImage?.ditheredImage(withWidth: 384)
                                
                                guard let data = UIImagePNGRepresentation(attachedImage!) else {
                                    print("failed to encode image")
                                    return
                                }
                                
                                let base64DataString = data.base64EncodedString()
                                
                                pageFragment.html = "<img src=\"data:image/jpeg;base64,\(base64DataString)\" style=\"width: 100%\">"
                            }
                        }
                    }
                    
                    let plainTextType = kUTTypePlainText as String
                    if attachment.hasItemConformingToTypeIdentifier(plainTextType) {
                        attachment.loadItem(forTypeIdentifier: plainTextType, options: [:]) { (data, error) in
                            switch data {
                            case let text as String:
                                self.page.append(PageFragment(text: text))
                            default:
                                print("Unexpected data:", type(of: data))
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    enum ShareError: Error {
        case NoPrinterSelected
    }
}

fileprivate extension String {
    static var propertyList: String {
        return kUTTypePropertyList as String
    }
}

extension NSAttributedString {
    func htmlString() throws -> String {
        let htmlData = try self.data(from: NSMakeRange(0, self.length),
                                     documentAttributes: [.documentType: NSAttributedString.DocumentType.html,
                                                          .characterEncoding: NSNumber(value: Int8(String.Encoding.utf8.rawValue))])
        
        guard let result = String(data: htmlData, encoding: .utf8) else {
            throw EncodingError.error
        }
        
        return result
    }
    
    enum EncodingError: Error {
        case error
    }
}
