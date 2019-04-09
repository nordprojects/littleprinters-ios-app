//
//  PhotoPicker.swift
//  inspiral
//
//  Created by Michael Colville on 03/08/2018.
//

import UIKit

class PhotoPicker: NSObject {
    
    var controller: (UIViewController & PhotoPickerDelegate)?
    var mediaUI: UIImagePickerController?
    static let shared = PhotoPicker()

    func startMediaBrowserFromController(_ controller: (UIViewController & PhotoPickerDelegate)) {
        self.controller = controller
        
        mediaUI = UIImagePickerController()
        mediaUI?.sourceType = .photoLibrary
        mediaUI?.allowsEditing = false
        mediaUI?.delegate = self

        controller.present(mediaUI!, animated: true, completion: nil)
    }
    
    func exitPressed() {
        controller?.dismiss(animated: true, completion: nil)
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            controller?.pickerDidReturn(image)
        }
        controller?.dismiss(animated: true, completion: nil)
    }
}

extension PhotoPicker: UINavigationControllerDelegate {
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
