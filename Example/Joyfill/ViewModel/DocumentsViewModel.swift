import Foundation
import JoyfillModel
import Combine
import JoyfillAPIService

public class DocumentsViewModel: ObservableObject {
    var joyDocModel = JoyDocViewModel()
    let apiService: APIService
    
    // This @Published property stores the array of Document instances.
    // SwiftUI views can bind to thsi property and be notified when it changes.
    @Published var documents: [Document] = []
    @Published var documentsLoading = false
    @Published var error: String?
    
    @Published var documentsJoyDocJSON: Any?
    @Published var documentsJoyDocLoading = false
    
    @Published var submissions: [Document] = []
    @Published var submissionsLoading = false
    @Published var submissionsError: String?
    
    @Published var activeSubmissionIdentifier: String?
        
    @Published var userAccessToken = Constants.userAccessToken
    
    public init(joyDocModel: JoyDocViewModel = JoyDocViewModel(), documents: [Document] = [], documentsLoading: Bool = false, error: String? = nil, documentsJoyDocJSON: Any? = nil, documentsJoyDocLoading: Bool = false, submissions: [Document] = [], submissionsLoading: Bool = false, submissionsError: String? = nil, activeSubmissionIdentifier: String? = nil, userAccessToken: String = Constants.userAccessToken) {
        self.joyDocModel = joyDocModel
        self.apiService = APIService(accessToken: Constants.userAccessToken)
        self.documents = documents
        self.documentsLoading = documentsLoading
        self.error = error
        self.documentsJoyDocJSON = documentsJoyDocJSON
        self.documentsJoyDocLoading = documentsJoyDocLoading
        self.submissions = submissions
        self.submissionsLoading = submissionsLoading
        self.submissionsError = submissionsError
        self.activeSubmissionIdentifier = activeSubmissionIdentifier
        self.userAccessToken = userAccessToken
    }
    
    func setActiveSubmissionIdentifier(identifier: String) {
        self.activeSubmissionIdentifier = identifier
    }
    
    // MARK: - Templates (Fetches documents or templates from Joyfill API)
    func fetchDocuments() {
        apiService.fetchDocuments() { result in
            DispatchQueue.main.async {
                self.documentsLoading = false
                switch result {
                case .success(let documents):
                    print("Retrieved \(documents.count) documents")
                    self.documents = documents
                case .failure(let error):
                    print("Error fetching documents: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Submissions
    public func fetchDocumentSubmissions(identifier: String) {
        apiService.fetchDocumentSubmissions(identifier: identifier) { result in
            DispatchQueue.main.async {
                self.submissionsLoading = false
                switch result {
                case .success(let submissions):
                    print("Retrieved \(submissions.count) document submissions")
                    self.submissions = submissions
                case .failure(let error):
                    print("Error fetching document submissions: \(error.localizedDescription)")
                    self.submissionsError = error.localizedDescription
                }
            }
        }
    }
    
    public func createDocumentSubmission(identifier: String, completion: @escaping ((Any) -> Void)) {
        apiService.createDocumentSubmission(identifier: identifier) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let jsonRes):
                    print("COMPLETE CREATED DOC jsonRes: ", jsonRes)
                case .failure(let error):
                    print("Error creating submission: \(error.localizedDescription)")
                }
            }
        }
    }
}
