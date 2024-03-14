//
//  File.swift
//  
//
//

import Foundation
import UIKit
import JoyfillAPIService
public class ImageFieldViewModel: ObservableObject {
    public func loadImageFromURL(imageURLs: [String], completion: @escaping ([UIImage]) -> Void) {
        var loadedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for imageURL in imageURLs {
            group.enter()
            APIService().loadImage(from: imageURL) { imageData in
                defer { group.leave() }
                
                if let imageData = imageData, let image = UIImage(data: imageData) {
                    loadedImages.append(image)
                } else {
                    print("Failed to load image from URL: \(String(describing: imageURL))")
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(loadedImages)
        }
    }
    func loadSingleURL(imageURL: String, completion: @escaping (UIImage) -> Void) {
        APIService().loadImage(from: imageURL) { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                completion(image)
            } else {
                print("Failed to load image from URL: \(String(describing: imageURL))")
//                completion(nil)
            }
        }
    }
}
