//
//  ImageMessageViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 12/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class ImageMessageViewController: UIViewController {
    
    var recipient: Printer?
    
    lazy var imageView = UIImageView()
    lazy var sendButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Select Image"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.left.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "a7bA03H")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.width.equalTo(view).offset(-40)
            make.height.equalTo(imageView.snp.width)
            make.centerX.equalTo(view)
        }
        
        sendButton.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.layer.borderColor = UIColor.black.cgColor
        sendButton.layer.borderWidth = 1
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.right.equalTo(imageView)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        if let printer = recipient {
            self.title = printer.info.name
        }
    }
    
    @objc func sendPressed() {
        let fromName = User.shared.name ?? "App"

        if let printer = recipient,
            let image = imageView.image {
            do {
                let message = try SiriusMessage(image: image, to: printer.key, from: fromName)
                navigationController?.pushViewController(
                    MessageSendingViewController(message: message, printer: recipient!),
                    animated: true)
            }
            catch {
                let alert = UIAlertController(title: "Unable to send image to: \(recipient?.info.owner ?? "nil")", error: error)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
