//
//  AddPrinterViewController.swift
//  littleprinter
//
//  Created by Michael Colville on 10/01/2018.
//  Copyright © 2018 Nord Projects Ltd. All rights reserved.
//

import UIKit

class AddPrinterViewController: UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addPrinterPressed(_ sender: Any) {
        
        guard let address = addressTextField.text,
            !address.isEmpty else {
            let alert = UIAlertController(title: "We need the adresss", message:"Please paste the printer key into the text field")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        PrinterManager.shared.addPrinterForAddress(address) { (error) in
            if let error = error {
                let alert = UIAlertController(title: "Couldn't add that printer :/", error: error)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func learnMorePressed(_ sender: Any) {
        let url = URL(string: "http://littleprinter.nordprojects.co/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

