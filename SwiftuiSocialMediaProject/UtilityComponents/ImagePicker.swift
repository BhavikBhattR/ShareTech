//
//  ImagePicker.swift
//  InstaFilter
//
//  Created by Bhavik Bhatt on 06/01/23.
//

import Foundation
import PhotosUI
import SwiftUI
import UIKit

extension UIImage {
func fixOrientation() -> UIImage {
    if self.imageOrientation == UIImage.Orientation.up {
return self

}

UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

    self.draw(in: CGRectMake(0, 0, self.size.width, self.size.height))

    let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()

UIGraphicsEndImageContext()

return normalizedImage;

}

}

struct ImagePicker : UIViewControllerRepresentable{
    
    @Binding var image : UIImage?
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        
        var parent: ImagePicker
        
        init(_  parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {return}
            
            if provider.canLoadObject(ofClass: UIImage.self){
                provider.loadObject(ofClass: UIImage.self){ image, _  in
                    self.parent.image = image as? UIImage
                    self.parent.image = self.parent.image?.fixOrientation()
                }
            }
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = context.coordinator
        
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
