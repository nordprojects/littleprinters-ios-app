//
//  ReceiptPreviewView.swift
//  littleprinter
//
//  Created by Joe Rickerby on 19/01/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import SnapKit

class ReceiptPreviewView: UIView {
    static let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm  |  dd—MMM-yyyy"
        return formatter
    }()

    init(innerView: UIView) {
        super.init(frame: CGRect.zero)
        setup(innerView: innerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(innerView: UIView())
    }
    
    private func setup(innerView: UIView) {
        let backgroundView = UIImageView(image: UIImage(named: "receipt-paper"))
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        let headerLabel = UILabel()
        addSubview(headerLabel)
        headerLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
        headerLabel.textAlignment = .center
        var headerText = ReceiptPreviewView.headerDateFormatter.string(from: Date())
        if let name = User.shared.name {
            headerText += "  |  " + name
        }
        headerLabel.text = headerText.uppercased()
        headerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(18).priority(.high)
            make.left.right.equalTo(self).inset(16)
        }
        
        addSubview(innerView)
        innerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerLabel.snp.bottom).offset(24)
            make.left.right.equalTo(self).inset(16)
            make.bottom.equalTo(self).inset(40)
        }
    }
}
