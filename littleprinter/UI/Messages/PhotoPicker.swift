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
        if let image = info[.originalImage] as? UIImage {
            controller?.pickerDidReturn(image)
        }
        controller?.dismiss(animated: true, completion: nil)
    }
}

extension PhotoPicker: UINavigationControllerDelegate {
    
}
