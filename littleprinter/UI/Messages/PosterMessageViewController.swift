//
//  PosterMessageViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class PosterMessageViewController: UIViewController {
    
    var recipient: Printer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let printer = recipient {
            self.title = "@" + printer.info.owner
        }
        
        let label = UILabel()
        label.text = "Poster"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.left.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
    }
}
