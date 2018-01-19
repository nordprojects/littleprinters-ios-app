//
//  Components.swift
//  littleprinter
//
//  Created by Michael Colville on 19/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ChunkyButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        contentEdgeInsets = UIEdgeInsetsMake(-2, 2, 2, -2)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            } else {
                contentEdgeInsets = UIEdgeInsetsMake(-2, 2, 2, -2)
            }
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: 2, dy: 2)
        let shadowRect = insetRect.offsetBy(dx: -2, dy: 2)
        let borderRect = (state == .highlighted) ? insetRect : insetRect.offsetBy(dx: 2, dy: -2)
        let topRect = borderRect.insetBy(dx: 2, dy: 2)
        
        UIColor.black.set()
        UIBezierPath(rect: shadowRect).fill()
        UIBezierPath(rect: borderRect).fill()

        UIColor.white.set()
        UIBezierPath(rect: topRect).fill()
    }
}
