//
//  File.swift
//  
//
//

import Foundation
import UIKit

class APIService {

    static func loadImage(from urlString: String, completion: @escaping (Data?) -> Void) {
        let base64String = String(urlString)
        if let data = Data(base64Encoded: base64String) {
            completion(data)
            return
        }

        guard let url = URL(string: base64String) else {
            completion(nil)
            return
        }

        if url.isFileURL {
            do {
                let imageData = try Data(contentsOf: url)
                completion(imageData)
            } catch {
                print("Error loading image from file URL: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading image from URL: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }
                completion(data)
            }
            task.resume()
        }
    }
}

public class ImageFieldViewModel: ObservableObject {
    public func loadImageFromURL(imageURLs: [String], completion: @escaping ([UIImage]) -> Void) {
        var loadedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for imageURL in imageURLs {
            group.enter()
            APIService.loadImage(from: imageURL) { imageData in
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

    func loadSingleURL(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        APIService.loadImage(from: imageURL) { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                completion(image)
            } else {
                print("Failed to load image from URL: \(String(describing: imageURL))")
                completion(nil)
            }
        }
    }
}
