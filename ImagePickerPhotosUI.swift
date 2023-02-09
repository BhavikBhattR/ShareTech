//
//  ImagePickerPhotosUI.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 07/02/23.
//

import PhotosUI
import SwiftUI

struct ImagePickerPhotosUI: View {
    
@StateObject var imagePicker = ImagePickerClass()
    
    var body: some View {
        VStack{
            ScrollView{
                if !imagePicker.images.isEmpty{
                    ForEach(0..<imagePicker.images.count, id: \.self) { index in
                        Image(uiImage: imagePicker.images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                    }
                }
            }
            Spacer()
            PhotosPicker(
                selection: $imagePicker.imageSelections,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Text("pic your photo")
            }
        }
    }
    
}

struct ImagePickerPhotosUI_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerPhotosUI()
    }
}
