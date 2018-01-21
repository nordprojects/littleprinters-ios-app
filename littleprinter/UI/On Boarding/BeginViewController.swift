//
//  BeginViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 19/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class BeginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash")
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        let beginButton = ChunkyButton()
        beginButton.addTarget(self, action: #selector(beginPressed), for: .touchUpInside)
        beginButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        let attributedString = NSMutableAttributedString(string: "Begin")
        attributedString.addAttribute(.kern, value: CGFloat(0.34), range: NSRange(location: 0, length: attributedString.length))
        beginButton.setAttributedTitle(attributedString, for: .normal)
        beginButton.setTitleColor(.black, for: .normal)
        view.addSubview(beginButton)
        beginButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(104)
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-66)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc func beginPressed() {
        let chooseNameViewController = ChooseNameViewController()
        navigationController?.pushViewController(chooseNameViewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

