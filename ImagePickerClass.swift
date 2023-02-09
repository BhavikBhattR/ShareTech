//
//  ImagePickerClass.swift
//  ShareTech
//
//  Created by Bhavik Bhatt on 07/02/23.
//

import Foundation
import PhotosUI
import _PhotosUI_SwiftUI

@MainActor
class ImagePickerClass: ObservableObject{
    @Published var image: UIImage?
    @Published var images: [UIImage] = []
    @Published var imageSelections: [PhotosPickerItem] = []{
        didSet{
            Task{
                if !imageSelections.isEmpty{
                    try await loadTransferable(from: imageSelections)
                    await MainActor.run {
                        imageSelections = []
                    }
                }
            }
        }
    }
    @Published var imageSelection: PhotosPickerItem?{
        didSet{
            if let imageSelection{
                Task{
                    try await loadTransferable(from: imageSelection)
                }
            }
        }
    }
    
    func loadTransferable(from imageSelection: PhotosPickerItem?)async throws{
        do{
            if let image = try await imageSelection?.loadTransferable(type: Data.self){
                    self.image = UIImage(data: image)
            }
        }catch{
            print(error.localizedDescription)
            image = nil
        }
    }
    
    func loadTransferable(from imageSelection: [PhotosPickerItem])async throws{
        do{
            for selection in imageSelection {
                if let data = try await selection.loadTransferable(type: Data.self){
                    if let uiImage = UIImage(data: data){
                        images.append(uiImage)
                    }
                }
            }
        }catch{
            print(error.localizedDescription)
            image = nil
        }
    }
}
