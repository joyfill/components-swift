import Foundation
import UIKit
import Combine
import JoyfillAPIService

public class JoyDocViewModel: ObservableObject {
    @Published var joyDocLoading = false
    @Published var joyDocError = ""
    let apiService: APIService
    public init(joyDocLoading: Bool = false, joyDocError: String = "") {
        self.joyDocLoading = joyDocLoading
        self.joyDocError = joyDocError
        self.apiService = APIService()
    }
    
    // Pulls in the JoyDoc raw JSON data for adding to our ViewController
    public func fetchJoyDoc(identifier: String, userAccessToken: String, completion: @escaping ((Any) -> Void)) {
        apiService.fetchJoyDoc(identifier: identifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.joyDocLoading = false
                    completion(data)
                case .failure(let error):
                    self.joyDocLoading = false
                    self.joyDocError = error.localizedDescription
                    print("Error fetching JoyDoc: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func updateDocumentChangelogs(identifier: String, userAccessToken: String, docChangeLogs: Any) {
        APIService.updateDocumentChangelogs(identifier: identifier, userAccessToken: userAccessToken, docChangeLogs: docChangeLogs) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let json):
                        print(json)
                    case .failure(let error):
                        print("Error updating changelogs: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    public func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            if let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
        
    /* Async alternative to loading JoyDoc JSON
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let _ = json as? NSDictionary
            self.joyDocJSON = json
        } catch {
            print("Error getting joydoc \(error)")
        }
     */
        
}


