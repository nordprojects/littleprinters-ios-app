//
//  QuickDrawViewController.swift
//  littleprinter
//
//  Created by Joe Rickerby on 24/08/18.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class QuickDrawViewController: UIViewController {
    var recipient: Printer?
    
    lazy var quickDrawView: QuickDrawView = QuickDrawView()
    lazy var receiptPreviewView: ReceiptPreviewView = ReceiptPreviewView(innerView: quickDrawView)
    lazy var drawButton: UIButton = UIButton(type: .custom).also { view in
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.addTarget(self, action: #selector(drawButtonPressed), for: UIControl.Event.touchUpInside)
        view.snp.makeConstraints { make in
            make.width.equalTo(82)
            make.height.equalTo(41)
        }
    }
    lazy var eraseButton: UIButton = UIButton(type: .custom).also { view in
        view.contentVerticalAlignment = .center
        view.contentHorizontalAlignment = .center
        view.addTarget(self, action: #selector(eraseButtonPressed), for: UIControl.Event.touchUpInside)
        view.snp.makeConstraints { make in
            make.width.equalTo(82)
            make.height.equalTo(41)
        }
    }
    lazy var toolbar: UIView = UIView().also {
        $0.addSubview(drawButton)
        $0.addSubview(eraseButton)
        
        drawButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
        eraseButton.snp.makeConstraints { make in
            make.left.equalTo(drawButton.snp.right)
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
        //                                                            style: .plain,
        //                                                            target: self,
        //                                                            action: #selector(sendPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: UIButton().also {
                $0.setAttributedTitle(
                    NSAttributedString(
                        string: "Send",
                        attributes: [
                            .font: UIFont(name: "Avenir-Heavy", size: 20)!,
                            .foregroundColor: UIColor(hex: 0x89befe)
                        ]),
                    for: .normal)
                $0.addTarget(self, action: #selector(sendPressed), for: .touchUpInside)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "receipt-background")!)
        title = recipient?.info.name ?? ""
        
        view.addSubview(receiptPreviewView)
        view.addSubview(toolbar)
        
        receiptPreviewView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.right.equalTo(view).inset(24)
        }
        toolbar.snp.makeConstraints { make in
            make.top.equalTo(receiptPreviewView.snp.bottom).offset(5)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide).priority(.high)
            make.bottom.lessThanOrEqualTo(view).inset(10)
        }
        
        update()
    }
    
    @objc func sendPressed() {
        let image = quickDrawView.renderToImage().trimmingTopAndBottomPixels()
        
        guard let recipient = recipient else { return }
        let fromName = User.shared.name ?? "App"
        
        do {
            let message = try SiriusMessage(image: image, to: recipient.key, from: fromName)
            navigationController?.pushViewController(
                MessageSendingViewController(message: message, printer: recipient),
                animated: true)
        }
        catch {
            let alert = UIAlertController(title: "Unable to send image to: \(recipient.info.owner)", error: error)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func drawButtonPressed() {
        quickDrawView.mode = .draw
        update()
    }
    @objc func eraseButtonPressed() {
        quickDrawView.mode = .erase
        update()
    }
    
    private func update() {
        switch quickDrawView.mode {
        case .draw:
            drawButton.setImage(UIImage(named: "pencil-selected"), for: .normal)
            eraseButton.setImage(UIImage(named: "rubber"), for: .normal)
        case .erase:
            drawButton.setImage(UIImage(named: "pencil"), for: .normal)
            eraseButton.setImage(UIImage(named: "rubber-selected"), for: .normal)
        }
    }
}

class QuickDrawView: UIView {
    var lineColor = UIColor(white: 0.0, alpha: 1.0)
    enum Mode : String {
        case draw
        case erase
    }
    var mode = Mode.draw
    var strokesToDraw: [(CGPoint, CGPoint, Mode)] = []
    var activeTouches = NSMutableSet()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        isMultipleTouchEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeTouches.addObjects(from: Array(touches))
        setNeedsDisplay()
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            strokesToDraw.append((
                touch.previousLocation(in: self),
                touch.location(in: self),
                mode
            ))
        }
        setNeedsDisplay()
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.remove(touch)
        }
        setNeedsDisplay()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.remove(touch)
        }
        setNeedsDisplay()
    }
    
    private let drawDiameter: CGFloat = 4
    private let eraseDiameter: CGFloat = 50
    private let eraseCircleColor = UIColor(white: 0.0, alpha:  0.3)
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        UIColor.white.set()
        UIRectFill(rect)
        
        context.setLineCap(.round)
        
        for stroke in strokesToDraw {
            switch stroke.2 {
            case .draw:
                context.setStrokeColor(lineColor.cgColor)
                context.setLineWidth(drawDiameter)
            case .erase:
                context.setStrokeColor((backgroundColor ?? UIColor.white).cgColor)
                context.setLineWidth(eraseDiameter)
            }
            context.move(to: stroke.0)
            context.addLine(to: stroke.1)
            context.strokePath()
        }
        
        if mode == .erase {
            context.setLineWidth(2)
            context.setStrokeColor(eraseCircleColor.cgColor)
            
            for touch in activeTouches {
                context.addArc(center: (touch as! UITouch).location(in: self),
                               radius: eraseDiameter/2,
                               startAngle: 0,
                               endAngle: 2*CGFloat.pi,
                               clockwise: true)
                context.strokePath()
            }
        }
    }
}
