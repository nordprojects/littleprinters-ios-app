//
//  MessageSendingViewController.swift
//  littleprinter
//
//  Created by Joe Rickerby on 10/08/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit
import SnapKit

class MessageSendingViewController: UIViewController {
    let loadingIndicator = UIImageView(image: UIImage(named: "sending-hourglass")).also {
        $0.layer.compositingFilter = "multiplyBlendMode";
    }
    let sentIndicator = UIImageView(image: UIImage(named: "sending-done-tick"))
    let errorIndicator = UIImageView(image: UIImage(named: "fail-cross"))
    let littlePrinterGraphic = UIImageView(image: UIImage(named: "little-printer-graphic"))
    let statusText = UILabel().also {
        $0.font = UIFont(name: "Avenir-Heavy", size: 17)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    let printer: Printer
    let message: SiriusMessage
    enum State : String {
        case sending
        case sent
        case error
    }
    var state = State.sending
    var networkTask: URLSessionTask?
    
    init(message: SiriusMessage, printer: Printer) {
        self.message = message
        self.printer = printer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView().also {
            $0.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        }
        self.view = view
        
        navigationItem.hidesBackButton = true;
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonPressed))
        
        view.addSubview(loadingIndicator)
        view.addSubview(sentIndicator)
        view.addSubview(errorIndicator)
        view.addSubview(littlePrinterGraphic)
        view.addSubview(statusText)
        
        littlePrinterGraphic.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-120)
        }
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(littlePrinterGraphic.snp.top).offset(-10)
        }
        sentIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(loadingIndicator)
        }
        errorIndicator.snp.makeConstraints { make in
            make.center.equalTo(loadingIndicator)
        }
        statusText.snp.makeConstraints { make in
            make.top.equalTo(littlePrinterGraphic.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(40)
        }
        
        update()
    }

    override func viewDidAppear(_ animated: Bool) {
        sendMessage()
    }
    
    @objc private func cancelButtonPressed() {
        if let networkTask = networkTask {
            networkTask.cancel()
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func sendMessage() {
        networkTask = SiriusServer.shared.sendMessage(message) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Failed to send message", error: error, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.state = .error
                self.update()
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.state = .sent
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.update()
            
            delay(2.0) {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func update() {
        loadingIndicator.alpha = (state == .sending ? 1.0 : 0.0)
        sentIndicator.alpha = (state == .sent ? 1.0 : 0.0)
        errorIndicator.alpha = (state == .error ? 1.0 : 0.0)
        
        statusText.text = {
            switch state {
            case .sending:
                return "Sending…"
            case .sent:
                return "Message sent to \n\(printer.info.name)!"
            case .error:
                return "Failed to send\nmessage!"
            }
        }()
        
        littlePrinterGraphic.image = {
            if state == .error {
                return UIImage(named: "little-printer-graphic-sad")
            } else {
                return UIImage(named: "little-printer-graphic")
            }
        }()
        
        
    }
}
