//
//  PosterMessageViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SnapKit
import CoreText

class PosterMessageViewController: UIViewController {
    var recipient: Printer?

    var posterTextView: PosterTextView!
    var messageTextField: UITextField!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        posterTextView = PosterTextView()
        view.addSubview(posterTextView)
        posterTextView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view)
        }
        
        messageTextField = UITextField()
        view.addSubview(messageTextField)
        messageTextField.placeholder = "Enter your message"
        messageTextField.snp.makeConstraints { (make) in
            make.leftMargin.rightMargin.equalTo(view)
            make.top.equalTo(posterTextView.snp.bottom)
        }
        
        let keyboardLayoutView = KeyboardLayoutView()
        view.addSubview(keyboardLayoutView)
        keyboardLayoutView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.left.equalTo(view)
            make.top.equalTo(messageTextField.snp.bottom)
        }
        
        posterTextView.reactive.text <~ messageTextField.reactive.continuousTextValues.map({ $0 ?? ""})
    }
}

class PosterTextView: UIView {
    var text: String = "" {
        didSet {
            self.setNeedsDisplay()
            self.invalidateIntrinsicContentSize()
            print(text)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 384, height: 300)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.set()
        UIRectFill(bounds)
        
        let words = text.uppercased().split(separator: " ")
        var lineStrings: [String]
        if words.count < 3 {
            lineStrings = words.map(String.init)
        } else {
            let pairs: [String] = stride(from: 0, to: words.count, by: 2).map {
                let firstWord = words[$0]
                var secondWord = ""
                if $0 + 1 < words.count {
                    secondWord = " " + String(words[$0 + 1])
                }
                return firstWord + secondWord
            }
            lineStrings = pairs
        }
        
        var lines: [CTLine] = []
        let fontName = "AvenirNextCondensed-Bold"
        // fonts seem to give an exaggerated ascent value. here we adjust to exactly the height of an
        // uppercase character.
        let fontAscentAdjustmentFactor: CGFloat = 0.715
        let lineSeparation = bounds.size.width * 0.05
        
        for lineString in lineStrings {
            var lineAttributedString = NSAttributedString(string: String(lineString), attributes: [
                .font: UIFont(name: fontName, size: 10.0)!,
            ])
            var line = CTLineCreateWithAttributedString(lineAttributedString)
            let lineWidth: CGFloat = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
            
            lineAttributedString = NSAttributedString(string: String(lineString), attributes: [
                .font: UIFont(name: fontName, size: 10.0 * self.bounds.size.width / lineWidth)!,
            ])
            line = CTLineCreateWithAttributedString(lineAttributedString)
            lines.append(line)
        }
        
        var yPosition: CGFloat = 0.0
        let context = UIGraphicsGetCurrentContext()!
        
        for line in lines {
//            context.textMatrix = CGAffineTransform(translationX: 0, y: yPosition).scaledBy(x: 1, y: -1)
            var ascent: CGFloat = 0.0
            CTLineGetTypographicBounds(line, &ascent, nil, nil)
            yPosition += ascent * fontAscentAdjustmentFactor
//            let rect = CTLineGetImageBounds(line, nil)
//            print(line, rect)
//            yPosition += rect.height
            context.textMatrix = CGAffineTransform(scaleX: 1.0, y: -1.0).translatedBy(x: 0.0, y: -yPosition)
            CTLineDraw(line, context)
            yPosition += lineSeparation
        }
    }
}

extension Reactive where Base: PosterTextView {
    /// Sets the text of the text field.
    internal var text: BindingTarget<String> {
        return makeBindingTarget { $0.text = $1 }
    }
}
