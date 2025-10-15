//
//  File.swift
//
//
//
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
public typealias UIImage = NSImage
#endif

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
                Log("Error loading image from file URL: \(error.localizedDescription)", type: .warning)
                completion(nil)
            }
        } else {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    Log("Error loading image from URL: \(error?.localizedDescription ?? "Unknown error")", type: .warning)
                    completion(nil)
                    return
                }
                completion(data)
            }
            task.resume()
        }
    }
}

/// View model responsible for downloading images referenced by image fields.
public class ImageFieldViewModel: ObservableObject {
    /// Loads all images for the provided URLs (base64 strings or remote/local URLs) and returns the decoded `UIImage` instances on the main queue.
    /// - Parameters:
    ///   - imageURLs: Collection of image identifiers/URLs.
    ///   - completion: Completion handler invoked on the main queue with the successfully decoded images.
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
                    Log("Failed to load image from URL: \(String(describing: imageURL))", type: .warning)
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(loadedImages)
        }
    }

    /// Loads a single image and returns it on the main queue.
    /// - Parameters:
    ///   - imageURL: Base64 string or remote/local URL pointing to the image.
    ///   - completion: Completion handler invoked with the decoded image, or `nil` if decoding failed.
    func loadSingleURL(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        APIService.loadImage(from: imageURL) { imageData in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                completion(image)
            } else {
                Log("Failed to load image from URL: \(String(describing: imageURL))", type: .warning)
                completion(nil)
            }
        }
    }
}
