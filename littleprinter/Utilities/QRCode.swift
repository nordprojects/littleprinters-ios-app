//
//  QRCode.swift
//  littleprinter
//
//  Created by Michael Colville on 10/04/2019.
//  Copyright © 2019 Nord Projects Ltd. All rights reserved.
//

import UIKit

func qrCodeFromText(_ text: String) -> UIImage? {
    let data = text.data(using: String.Encoding.ascii)
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    guard let qrImage = qrFilter.outputImage else { return nil }
    
    // Scale the image
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledQrImage = qrImage.transformed(by: transform)
    
    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil }
    let processedImage = UIImage(cgImage: cgImage)
    
    return processedImage
}
