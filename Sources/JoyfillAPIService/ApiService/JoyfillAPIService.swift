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
    case documents(identifier: String? = nil, page: Int = 1, limit: Int = 10)
    case templates(identifier: String? = nil, page: Int = 1, limit: Int = 10)
    case submissiondocuments(identifier: String? = nil)
    case groups(identifier: String? = nil)
    case users(identifier: String? = nil)
    case saveChangelog(identifier: String? = nil)
    case saveDocument(identifier: String? = nil)
    case convertPDFToPNGs
    
    func endPoint(baseURL: String) -> URL {
        switch self {
        case .documents(identifier: let identifier, page: let page, limit: let limit):
            if let identifier = identifier {
                return URL(string: "\(baseURL)/documents?template=\(identifier)&page=\(page)&limit=\(limit)")!
            }
            return URL(string: "\(baseURL)/documents?page=\(page)&limit=\(limit)")!
        case .submissiondocuments(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(baseURL)/documents/\(identifier)")!
            }
            return URL(string: "\(baseURL)/documents?page=1&limit=100")!
        case .templates(identifier: let identifier, page: let page, limit: let limit):
            if let identifier = identifier {
                return URL(string: "\(baseURL)/templates?template=\(identifier)&page=\(page)&limit=\(limit)")!
            }
            return URL(string: "\(baseURL)/templates?page=\(page)&limit=\(limit)")!
        case .groups(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(baseURL)/groups/\(identifier)")!
            }
            return URL(string: "\(baseURL)/groups?&page=1&limit=100")!
        case .users(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(baseURL)/users\(identifier)")!
            }
            return URL(string: "\(baseURL)/users?&page=1&limit=100")!
        case .convertPDFToPNGs:
            return URL(string: "\(baseURL)/documents?&page=1&limit=100")!
        case .saveChangelog(identifier: let identifier):
            return URL(string: "\(baseURL)/documents/\(identifier!)/changelogs")!
        case .saveDocument(identifier: let identifier):
            return URL(string: "\(baseURL)/documents/\(identifier!)")!
        }
    }
}

public class APIService {
    private let accessToken: String
    private let baseURL: String
    
    public init(accessToken: String, baseURL: String) {
        self.accessToken = accessToken
        self.baseURL = baseURL
    }
    
    /// Returns true if a valid access token is configured
    public var hasValidToken: Bool {
        return !accessToken.isEmpty
    }
    
    private func urlRequest(type: JoyfillAPI, method: String? = nil, httpBody: Data? = nil) -> URLRequest {
        var request = URLRequest(url: type.endPoint(baseURL: self.baseURL))
        request.httpMethod = method ?? "GET"
        request.httpBody = httpBody
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func makeAPICall(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
            .resume()
    }
    
    public func fetchDocuments(identifier: String, page: Int = 1, limit: Int = 10, completion: @escaping (Result<[Document], Error>) -> Void) {
        let request = urlRequest(type: .documents(identifier: identifier, page: page, limit: limit))
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
        let request = urlRequest(type: .submissiondocuments())
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
    
    public func fetchTemplates(page: Int = 1, limit: Int = 10, completion: @escaping (Result<[Document], Error>) -> Void) {
        let request = urlRequest(type: .templates(page: page, limit: limit))
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(DocumentListResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func fetchJoyDoc(identifier: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let request = urlRequest(type: .submissiondocuments(identifier: identifier))
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
    
    public func loadImage(from urlString: String, completion: @escaping (Data?) -> Void) {
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
    
    
    public func fetchGroups(completion: @escaping (Result<[GroupData], Error>) -> Void) {
        let request = urlRequest(type: .groups())
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(GroupResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    print(error)
                    completion(.failure(error))
                    
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func retrieveGroup(identifier: String,completion: @escaping (Result<RetrieveGroup, Error>) -> Void) {
        let request = urlRequest(type: .groups(identifier: identifier))
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(RetrieveGroup.self, from: data)
                    completion(.success(documents))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func fetchListAllUsers(completion: @escaping (Result<[ListAllUsers], Error>) -> Void) {
        let request = urlRequest(type: .users())
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(ListAllUsersResponse.self, from: data)
                    completion(.success(documents.data))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func retrieveUser(identifier: String,completion: @escaping (Result<RetrieveUsers, Error>) -> Void) {
        let request = urlRequest(type: .users(identifier: identifier))
        makeAPICall(with: request) { data, response, error in
            if let data = data, error == nil {
                do {
                    let documents = try JSONDecoder().decode(RetrieveUsers.self, from: data)
                    completion(.success(documents))
                } catch {
                    print(error)
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? APIError.unknownError))
            }
        }
    }
    
    public func createDocumentSubmission(identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.fetchJoyDoc(identifier: identifier) { [self] joyDocJSON in
            createDocument(joyDocJSON: joyDocJSON, identifier: identifier) { result in
                completion(result)
            }
        }
    }
    
    public func createDocument(joyDocJSON: Result<Data, any Error>, identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/documents") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        let data = try! joyDocJSON.get() as! Data
        
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
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionaryObject ?? [:], options: [])
        
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        makeAPICall(with: request) { data, response, error in
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
        }
    }
    
    public func updateDocument(identifier: String, changeLogs: [String: Any], completion: @escaping (Result<Any, Error>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: changeLogs, options: .fragmentsAllowed)
            let request = urlRequest(type: .saveChangelog(identifier: identifier), method: "POST", httpBody: jsonData)
            makeAPICall(with: request) { data, response, error in
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
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    public func updateDocument(identifier: String, document: JoyDoc, completion: @escaping (Result<Any, Error>) -> Void) {
        do {
            let updateDocumentDict = [
                "files": document.files.compactMap({ $0.dictionary}),
                "fields": document.fields.compactMap({ $0.dictionary})
            ]
            let jsonData = try JSONSerialization.data(withJSONObject: updateDocumentDict, options: .prettyPrinted)
            let request = urlRequest(type: .saveDocument(identifier: identifier), method: "POST", httpBody: jsonData)
            makeAPICall(with: request) { data, response, error in
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
            }
        } catch {
            completion(.failure(error))
        }
    }
}

public enum APIError: Error {
    case invalidURL
    case unknownError
}

