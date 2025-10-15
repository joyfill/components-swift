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

/// Lightweight Joyfill REST client that wraps `URLSession` and decodes responses into `JoyfillModel` types.
public class APIService {
    private let accessToken: String
    private let baseURL: String
    
    /// Creates a service instance configured with the caller's credentials.
    /// - Parameters:
    ///   - accessToken: Bearer token used to authenticate each request.
    ///   - baseURL: Base URL for the Joyfill API (e.g. `https://api.joyfill.io/v1`).
    public init(accessToken: String, baseURL: String) {
        self.accessToken = accessToken
        self.baseURL = baseURL
    }
    
    private func urlRequest(type: JoyfillAPI, method: String? = nil, httpBody: Data? = nil) -> URLRequest {
        var request = URLRequest(url: type.endPoint(baseURL: self.baseURL))
        request.httpMethod = method ?? "GET"
        request.httpBody = httpBody
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// Executes the provided request and returns the raw response via the completion handler.
    /// - Parameters:
    ///   - request: The fully-configured `URLRequest`.
    ///   - completionHandler: Closure invoked on the URLSession callback queue.
    public func makeAPICall(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
            .resume()
    }
    
    /// Retrieves documents for the specified template identifier.
    /// - Parameters:
    ///   - identifier: Template identifier to filter by.
    ///   - page: Page number (1-indexed) to request.
    ///   - limit: Maximum results per page.
    ///   - completion: Completion handler delivering either decoded documents or an error.
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
    
    /// Retrieves submission documents authored from a given template.
    /// - Parameters:
    ///   - identifier: Template identifier whose submissions should be listed.
    ///   - completion: Completion handler delivering either decoded submissions or an error.
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
    
    /// Retrieves template metadata.
    /// - Parameters:
    ///   - page: Page number (1-indexed) to request.
    ///   - limit: Maximum results per page.
    ///   - completion: Completion handler delivering either decoded templates or an error.
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
    
    /// Downloads a JoyDoc JSON payload for the specified submission identifier.
    /// - Parameters:
    ///   - identifier: Submission identifier to fetch.
    ///   - completion: Completion handler called on the main queue with the JoyDoc data or an error.
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
    
    /// Resolves an image string into raw data, supporting base64, file URLs, or remote URLs.
    /// - Parameters:
    ///   - urlString: Base64 string or URL pointing to the image resource.
    ///   - completion: Completion handler invoked with the loaded data or `nil` when resolution fails.
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
    
    
    /// Lists all groups available to the current token.
    /// - Parameter completion: Completion handler delivering either decoded groups or an error.
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
    
    /// Retrieves a single group's metadata.
    /// - Parameters:
    ///   - identifier: Group identifier to fetch.
    ///   - completion: Completion handler delivering the decoded group or an error.
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
    
    /// Lists all users for the current organisation.
    /// - Parameter completion: Completion handler delivering either decoded users or an error.
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
    
    /// Retrieves an individual user record.
    /// - Parameters:
    ///   - identifier: User identifier to fetch.
    ///   - completion: Completion handler delivering the decoded user or an error.
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
    
    /// Creates a submission document by cloning an existing JoyDoc template.
    /// - Parameters:
    ///   - identifier: Template identifier used as the source.
    ///   - completion: Completion handler delivering the API response or an error.
    public func createDocumentSubmission(identifier: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.fetchJoyDoc(identifier: identifier) { [self] joyDocJSON in
            createDocument(joyDocJSON: joyDocJSON, identifier: identifier) { result in
                completion(result)
            }
        }
    }
    
    /// Creates a submission document using a pre-fetched JoyDoc payload.
    /// - Parameters:
    ///   - joyDocJSON: Result containing the JoyDoc payload to submit.
    ///   - identifier: Template identifier that should be assigned to the new document.
    ///   - completion: Completion handler delivering the API response or an error.
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
    
    /// Persists changelog entries for an existing document.
    /// - Parameters:
    ///   - identifier: Document identifier to update.
    ///   - changeLogs: Changelog payload to submit.
    ///   - completion: Completion handler delivering the API response or an error.
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
    
    /// Persists a document by sending the current `files` and `fields` payload.
    /// - Parameters:
    ///   - identifier: Document identifier to update.
    ///   - document: The JoyDoc whose file and field arrays should be persisted.
    ///   - completion: Completion handler delivering the API response or an error.
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

/// Errors emitted by ``APIService``.
public enum APIError: Error {
    case invalidURL
    case unknownError
}
