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
    
    var pageFragments: [String] = []
    var selectedPrinter: Printer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PrinterManager.shared.printers.count > 0 {
            selectedPrinter = PrinterManager.shared.lastUsedPrinter ?? PrinterManager.shared.printers.first
        }
        
        guard let items = extensionContext?.inputItems else {
            return
        }
        
        print("items: \(items)")
        
        for item in items {
            guard let item = item as? NSExtensionItem else { continue }
            
            if let title = item.attributedTitle {
                do {
                    pageFragments.append("<h1>\(try title.htmlString())</h1>")
                }
                catch {
                    print("html encoding of content failed.", error)
                    pageFragments.append("<h1>\(title.string)</h1>")
                }
            }
            if let content = item.attributedContentText {
                do {
                    pageFragments.append("<p>\(try content.htmlString())</p>")
                }
                catch {
                    print("html encoding of content failed.", error)
                    pageFragments.append("<p>\(content.string)</p>")
                }
            }
            
            if let attachments = item.attachments as? [NSItemProvider] {
                for attachment in attachments {
                    let imageType = kUTTypeImage as String
                    if attachment.hasItemConformingToTypeIdentifier(imageType) {
                        attachment.loadItem(forTypeIdentifier: imageType, options: [:]) { (data, error) in
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
                                
                                // resize image to 384 width
                                attachedImage = attachedImage?.scaledImage(toWidth: 384)
                                
                                guard let data = UIImageJPEGRepresentation(attachedImage!, 0.7) else {
                                    print("failed to encode image")
                                    return
                                }
                                
                                let base64DataString = data.base64EncodedString()
                                
                                self.pageFragments.append("<img src=\"data:image/jpeg;base64,\(base64DataString)\" style=\"width: 100%\">")
                            }
                        }
                    }
                    
                    let plainTextType = kUTTypePlainText as String
                    if attachment.hasItemConformingToTypeIdentifier(plainTextType) {
                        attachment.loadItem(forTypeIdentifier: plainTextType, options: [:]) { (data, error) in
                            switch data {
                            case let text as String:
                                self.pageFragments.append("<p>\(text)</p>")
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
    
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        guard let items = extensionContext?.inputItems else {
            return
        }
        
        if contentText.count > 0 {
            pageFragments.insert("<p>\(contentText!)</p>", at: 0)
        }
        
        let html = pageFragments.joined()
        
        if let printer = selectedPrinter {
            PrinterManager.shared.lastUsedPrinter = printer

            SiriusServer.shared.sendHTML(html, to: printer.key, from: User.shared.name ?? "anon") { (error) in
                if let error = error {
                    self.extensionContext!.cancelRequest(withError: error)
                    return
                }
                
                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
            }
        } else {
            self.extensionContext!.cancelRequest(withError: ShareError.NoPrinterSelected)
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

extension UIImage {
    func scaledImage(toWidth width: CGFloat) -> UIImage {
        let scaleFactor = width / size.width
        
        let newHeight = size.height * scaleFactor
        let newWidth = size.width * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight));
        
        draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let result = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return result!;
        
    }
}
