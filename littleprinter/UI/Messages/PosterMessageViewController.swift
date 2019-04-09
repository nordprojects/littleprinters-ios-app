//
//  PosterMessageViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import SnapKit
import CoreText

class PosterMessageViewController: UIViewController {
    var recipient: Printer!

    var posterTextView: PosterTextView!
    var messagingToolbar: MessagingToolbar!
    var previewScrollView: UIScrollView!
    var receiptPreviewView: ReceiptPreviewView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        if let printer = recipient {
            self.title = printer.info.name
        }
        
        previewScrollView = UIScrollView()
        view.addSubview(previewScrollView)
        previewScrollView.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        previewScrollView.isDirectionalLockEnabled = true
        previewScrollView.contentInset = UIEdgeInsets.zero
        previewScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(view)
        }
        
        posterTextView = PosterTextView()
        
        receiptPreviewView = ReceiptPreviewView(innerView: posterTextView)
        previewScrollView.addSubview(receiptPreviewView)
        receiptPreviewView.snp.makeConstraints { (make) in
            make.top.equalTo(previewScrollView)
            make.left.right.equalTo(view).inset(24)
            make.bottom.equalTo(previewScrollView).inset(10)
        }
        
        messagingToolbar = MessagingToolbar()
        messagingToolbar.delegate = self
        view.addSubview(messagingToolbar)
        messagingToolbar.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.height.equalTo(44)
            make.top.equalTo(previewScrollView.snp.bottom)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let keyboardLayoutView = KeyboardLayoutView()
        view.addSubview(keyboardLayoutView)
        keyboardLayoutView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.top.equalTo(messagingToolbar.snp.bottom)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        messagingToolbar.becomeFirstResponder()
    }
}

extension PosterMessageViewController: MessagingToolbarDelegate {
    func sendPressed() {
        let image = PosterTextView.renderText(text: posterTextView.text)
        let fromName = User.shared.name ?? "App"
        
        do {
            let message = try SiriusMessage(image: image, to: recipient.key, from: fromName)
            navigationController?.pushViewController(
                MessageSendingViewController(message: message, printer: recipient!),
                animated: true)
        }
        catch {
            let alert = UIAlertController(title: "Failed to send message", error: error)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldDidChange() {
        posterTextView.text = messagingToolbar.text ?? ""
        
        receiptPreviewView.setNeedsLayout()
        receiptPreviewView.layoutIfNeeded()
        
        let targetContentOffset = (self.receiptPreviewView.bounds.height + 10 - self.previewScrollView.bounds.size.height)
        // only scroll down, not up
        if targetContentOffset > self.previewScrollView.contentOffset.y {
            self.previewScrollView.setContentOffset(
                CGPoint(x: 0, y: targetContentOffset),
                animated: false)
        }
    }
}

@objc class PosterTextView: UIView {
    static func renderText(text: String) -> UIImage {
        let view = PosterTextView(frame: CGRect(x: 0, y: 0, width: 384, height: 100))
        view.text = text
        var size = view.intrinsicContentSize
        size.width = 384.0
        view.bounds = CGRect(origin: CGPoint.zero, size: size)

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: CGPoint.zero, size: size))
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    let font = UIFont(name: "Bebas Neue Whatever", size: 10.0)!
    
    var text: String = "" {
        didSet {
            self.invalidateLines()
            self.setNeedsDisplay()
            self.invalidateIntrinsicContentSize()
            print(text)
        }
    }
    let lineLengths: [Int] = {
        return (0...50).map { _ in
            let r = Double(arc4random()) / Double(UInt32.max)
            if r < 0.5 { return 2}
            return 3
        }
    }()
    var _lines: [CTLine] = []
    var _linesValid = false
    var lines: [CTLine] {
        if !_linesValid {
            _lines = linesForText(text)
        }
        return _lines
    }
    private func invalidateLines() {
        _linesValid = false
    }
    
    override var intrinsicContentSize: CGSize {
        var height: CGFloat = 0.0
        for line in lines {
            var ascent: CGFloat = 0.0
            CTLineGetTypographicBounds(line, &ascent, nil, nil)
            height += ascent * fontAscentAdjustmentFactor
            height += lineSeparation
        }
        height += 20 // Bottom margin
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal:
            return super.contentCompressionResistancePriority(for: axis)
        case .vertical:
            return .defaultHigh
        @unknown default:
            return super.contentCompressionResistancePriority(for: axis)
        }
    }
    
    let fontAscentAdjustmentFactor: CGFloat = 0.78
    var lineSeparation: CGFloat {
        return bounds.size.width * 0.03
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.set()
        UIRectFill(bounds)
        
        var yPosition: CGFloat = 0.0
        let context = UIGraphicsGetCurrentContext()!

        for line in linesForText(text) {
            var ascent: CGFloat = 0.0
            CTLineGetTypographicBounds(line, &ascent, nil, nil)

            yPosition += ascent * fontAscentAdjustmentFactor
            context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0).translatedBy(x: 0.0, y: -yPosition)
            CTLineDraw(line, context)
            yPosition += lineSeparation
        }
    }
    
    private func linesForText(_ text: String) -> [CTLine] {
        let lineStrings: [String] = lineStringsForText(text.uppercased())
        
        var lines: [CTLine] = []
        
        // fonts seem to give an exaggerated ascent value. here we adjust to exactly the height of an
        // uppercase character.
        
        for lineString in lineStrings {
            var lineAttributedString = NSAttributedString(string: String(lineString), attributes: [
                .font: font,
                ])
            var line = CTLineCreateWithAttributedString(lineAttributedString)
            let lineWidth: CGFloat = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
            
            lineAttributedString = NSAttributedString(string: String(lineString), attributes: [
                .font: font.withSize(font.pointSize * self.bounds.size.width / lineWidth),
                ])
            line = CTLineCreateWithAttributedString(lineAttributedString)
            lines.append(line)
        }

        return lines
    }
    
    private func lineStringsForText(_ text: String) -> [String] {
        let textAttributes = [
            NSAttributedString.Key.font: font
        ]
        
        // calculate line break width
        let textWidth = (text as NSString).size(withAttributes: textAttributes).width
//        let lineBreakWidth = textWidth * 0.12
//        let lineBreakWidth = textWidth * 0.06
//        let lineBreakWidth = sqrt(textWidth) * 2.5
        let lineBreakWidth = 0.15 * (1.0-exp(-0.002*textWidth)) / 0.002
        
        let words = text.split(separator: " ")
        let spaceWidth = (" " as NSString).size(withAttributes: textAttributes).width
        var lines: [String] = []
        var currentLine = ""
        var currentLineWidth: CGFloat = 0.0
        
        // group the words into lines. For more kookiness, the lines break after the word that
        // exceeds the line break width.
        for word in words {
            if word == "" { continue }
            
            let wordWidth = (word as NSString).size(withAttributes: textAttributes).width

            if currentLine == "" {
                currentLine = String(word)
                currentLineWidth = wordWidth
            } else {
                currentLine += " " + word
                currentLineWidth += spaceWidth + wordWidth
            }

            if currentLineWidth > lineBreakWidth {
                lines.append(currentLine)
                currentLine = ""
                currentLineWidth = 0.0
            }
        }
        
        if currentLine.count > 0 {
            lines.append(currentLine)
        }
        
        return lines
    }
}
