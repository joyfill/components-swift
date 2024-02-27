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
    case documents(identifier: String? = nil)
    case templates(identifier: String? = nil)
    case groups(identifier: String? = nil)
    case users(identifier: String? = nil)
    case saveForm(identifier: String? = nil)
    case convertPDFToPNGs
    
    var endPoint: URL {
        switch self {
        case .documents(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.documentsBaseURL)/\(identifier)")!
            }
            return URL(string: "\(Constants.documentsBaseURL)?&page=1&limit=25")!
        case .templates(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.documentsBaseURL)?template=\(identifier)&page=1&limit=25")!
            }
            return URL(string: "\(Constants.documentsBaseURL)?&page=1&limit=25")!
        case .groups(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.groupsBaseURL)/\(identifier)")!
            }
            return URL(string: "\(Constants.groupsBaseURL)?&page=1&limit=25")!
        case .users(identifier: let identifier):
            if let identifier = identifier {
                return URL(string: "\(Constants.usersBaseURL)/\(identifier)")!
            }
            return URL(string: "\(Constants.usersBaseURL)?&page=1&limit=25")!
        case .convertPDFToPNGs:
            return URL(string: "\(Constants.documentsBaseURL)?&page=1&limit=25")!
        case .saveForm(identifier: let identifier):
            return URL(string: "\(Constants.saveFormBaseURL)/\(identifier)")!
        }
    }
}

public class APIService {
    private let accessToken: String
    var debugEnabled = true
    
    public init(accessToken: String = Constants.userAccessToken) {
        self.accessToken = accessToken
    }
    
    private func urlRequest(type: JoyfillAPI, method: String? = nil, httpBody: Data? = nil) -> URLRequest {
        var request = URLRequest(url: type.endPoint)
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
        
        let request = urlRequest(type: .documents())
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
        
        let request = urlRequest(type: .templates(identifier: identifier))
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
        let request = urlRequest(type: .documents(identifier: identifier))
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
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
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
    
    public func updateDocumentChangelogs(identifier: String, docChangeLogs: Any, completion: @escaping (Result<Any, Error>) -> Void) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: docChangeLogs, options: [])
            let request = urlRequest(type: .saveForm(identifier: identifier), method: "POST", httpBody: jsonData)
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
    
    public func createDocumentSubmission(identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.fetchJoyDoc(identifier: identifier) { [self] joyDocJSON in
            createDocument(joyDocJSON: joyDocJSON, identifier: identifier) { result in
                completion(result)
            }
        }
    }
    
    public func createDocument(joyDocJSON: Result<Data, any Error>, identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        var jsonData: Data?
        do {
            let data = try joyDocJSON.get() as! Data
            var dictionaryObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
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
            
            let request = urlRequest(type: .documents(), method: "POST", httpBody: jsonData)
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
        } catch {
            completion(.failure(error))
        }
    }
}

public enum APIError: Error {
    case invalidURL
    case unknownError
}

