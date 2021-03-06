//
//  ViewController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import Photos
import ImagePickerSheet

class ViewController: UIViewController, ImagePickerSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "presentImagePickerSheet:")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Other Methods
    
    func presentImagePickerSheet(gestureRecognizer: UITapGestureRecognizer) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentImagePickerSheet(gestureRecognizer)
                }
            }
            
            return
        }
        
        if authorization == .Authorized {
            let sheet = ImagePickerSheet()
            sheet.numberOfButtons = 3
            sheet.delegate = self
            sheet.showInView(view)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("ImagePickerSheet needs access to the camera roll", comment: "ImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    // MARK: ImagePickerSheetDelegate
    
    func imagePickerSheet(imagePickerSheet: ImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
        let photosSelected = (imagePickerSheet.numberOfSelectedPhotos > 0)
        
        if (buttonIndex == 0) {
            if photosSelected {
                return NSLocalizedString("Add comment", comment: "Add comment")
            }
            else {
                return NSLocalizedString("Take Photo Or Video", comment: "Take Photo Or Video")
            }
        }
        else {
            if photosSelected {
                return NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "The secondary title of the image picker sheet to send the photos"), imagePickerSheet.numberOfSelectedPhotos) as String
            }
            else {
                return NSLocalizedString("Photo Library", comment: "Photo Library")
            }
        }
    }
    
    func imagePickerSheet(imagePickerSheet: ImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != imagePickerSheet.cancelButtonIndex {
            if imagePickerSheet.numberOfSelectedPhotos > 0 {
                imagePickerSheet.getSelectedImagesWithCompletion() { images in
                    println(images)
                }
            }
            else {
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType: UIImagePickerControllerSourceType = (buttonIndex == 2) ? .PhotoLibrary : .Camera
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    println("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                controller.sourceType = sourceType
                
                presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
