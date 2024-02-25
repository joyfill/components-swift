//
//  ApiService.swift
//  JoyfillExample
//
//
//
import Foundation
import Combine
import JoyfillModel

enum JoyfillAPI {
    case document(identifier: String? = nil)
    case template(identifier: String? = nil)
    
    var endPoint: URL {
        switch self {
        case .document(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.documentsBaseURL)/\(identifier)")!
            }
            return URL(string: "\(Constants.documentsBaseURL)?&page=1&limit=25")!
        case .template(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.documentsBaseURL)?template=\(identifier)&page=1&limit=25")!
            }
            return URL(string: "\(Constants.documentsBaseURL)?&page=1&limit=25")!
        }
        
    }
}

public class APIService {
    private let accessToken: String
    var debugEnabled = true
    
    public init(accessToken: String = Constants.userAccessToken) {
        self.accessToken = accessToken
    }
    
    private func urlRequest(type: JoyfillAPI) -> URLRequest {
        var request = URLRequest(url: type.endPoint)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func makeAPICall(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
            .resume()
    }
    
    public func fetchDocuments(completion: @escaping (Result<[Document], Error>) -> Void) {
        if debugEnabled {
            if let url = Bundle.main.url(forResource: "FetchDocument", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let documents = try! JSONDecoder().decode(DocumentListResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    print("Error reading JSON file:", error)
                }
            } else {
                print("File not found")
            }
            return
        }
        
        let request = urlRequest(type: .document())
        makeAPICall(with: request) { data, response, error in
            
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(DocumentListResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func fetchDocumentSubmissions(identifier: String, completion: @escaping (Result<[Document], Error>) -> Void) {
        
        if debugEnabled {
            if let url = Bundle.main.url(forResource: "FetchDocumentSubmission", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let documents = try! JSONDecoder().decode(DocumentListResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    print("Error reading JSON file:", error)
                }
            } else {
                print("File not found")
            }
            return
        }
        
        let request = urlRequest(type: .template(identifier: identifier))
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(DocumentListResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func createDocumentSubmission(identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        
        self.fetchJoyDoc(identifier: identifier) { [self] joyDocJSON in
            
            guard let url = URL(string: "\(Constants.documentsBaseURL)") else {
                completion(.failure(APIError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            var jsonData: Data?
            do {
                let data = try joyDocJSON.get() as Data
                var dictionaryObject = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                // We remove some of the uneeded keys, specifically changing the "type" to "document"

                dictionaryObject?.removeValue(forKey: "_id")
                dictionaryObject?.removeValue(forKey: "createdOn")
                dictionaryObject?.removeValue(forKey: "deleted")
                dictionaryObject?.removeValue(forKey: "categories")
                dictionaryObject?.removeValue(forKey: "stage")
                dictionaryObject?.removeValue(forKey: "identifier")
                dictionaryObject?.removeValue(forKey: "metadata")
                dictionaryObject?.updateValue("document", forKey: "type")
                dictionaryObject?.updateValue(identifier, forKey: "template")
                dictionaryObject?.updateValue(identifier, forKey: "source")
                
                let jsonData = try JSONSerialization.data(withJSONObject: dictionaryObject ?? [:], options: [])
            } catch {
                print("Error in preparing post document request")
            }

            request.httpBody = jsonData
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                        completion(.success(jsonRes))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    public func fetchJoyDoc(identifier: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if debugEnabled {
            if let url = Bundle.main.url(forResource: "RetriveDocument", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    completion(.success(data))
                } catch {
                    print("Error reading JSON file:", error)
                }
            } else {
                print("File not found")
            }
            return
        }
        let request = urlRequest(type: .document(identifier: identifier))
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error ?? APIError.unknownError))
                }
            }
        }
    }
    
    public static func updateDocumentChangelogs(identifier: String, userAccessToken: String, docChangeLogs: Any, completion: @escaping (Result<Any, Error>) -> Void) {
        do {
            guard let url = URL(string: "\(Constants.documentsBaseURL)/\(identifier)/changelogs") else {
                completion(.failure(APIError.invalidURL))
                return
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: docChangeLogs, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("Bearer \(userAccessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                        completion(.success(json))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    static func getDocumentsRequest(path: String, _ method: String = "GET") -> URLRequest? {
        var request = URLRequest(url: URL(string: "\(Constants.documentsBaseURL)/\(path)")!)
        request.httpMethod = method
        request.setValue("Bearer \(Constants.userAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

public enum APIError: Error {
    case invalidURL
    case unknownError
}

