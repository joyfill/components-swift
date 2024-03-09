//
//  DocumentListView.swift
//  JoyFill
//

import SwiftUI
import JoyfillAPIService
import JoyfillModel

public struct TemplateListView: View {
    @State var documents: [Document] = []
    @State var templates: [Document] = []
    @State var isLoading = true
    @State var error: String?
    let apiService: APIService = APIService()
    @State private var showDocuments = false
    @State private var path: [Document] = []
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    public var body: some View {
        NavigationStack(path: $path) {
        if isLoading {
           ProgressView()
                .onAppear() {
                    fetchTemplates() {
                        fetchDocuments() {
                        }
                    }
                }
        } else {
                VStack {
                    Text("Templates List")
                        .font(.title.bold())
                    List {
                        ForEach(templates) { template in
                            NavigationLink(value: template, label: {
                                HStack {
                                    Image(systemName: "doc")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                                    Text(template.name)
                                }
                            })
                            Button(action: {
                                createDocumentSubmission(identifier: template.identifier, completion: { joyDocJSON in
                                    fetchDocumentSubmissions(identifier: template.identifier)
                                })
                            }, label: {
                                Text("Fill New +")
                                    .padding(.leading, screenWidth * 0.6)
                            })
                        }
                    }
                    .navigationDestination(for: Document.self) { template in
                        DocumentSubmissionsListView(template: template, allDocuments: documents)
                    }
                }
            }
        }
    }
    
    // MARK: - Templates (Fetches documents or templates from Joyfill API)
        func fetchDocuments(completion: @escaping () -> Void) {
            self.isLoading = true
            apiService.fetchDocuments() { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let documents):
                        print("Retrieved \(documents.count) documents")
                        self.documents = documents
                    case .failure(let error):
                        print("Error fetching documents: \(error.localizedDescription)")
                        self.error = error.localizedDescription
                    }
                    completion()
                }
            }
    }
    
    func fetchTemplates(completion:  @escaping () -> Void) {
        self.isLoading = true
        apiService.fetchTemplates { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let templates):
                    print("Retrieved \(templates.count) documents")
                    self.templates = templates
                case .failure(let error):
                    print("Error fetching templates: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                }
                completion()
            }
            
        }
    }
    
    
    // MARK: - Submissions
    public func fetchDocumentSubmissions(identifier: String) {
        self.isLoading = true
        apiService.fetchDocumentSubmissions(identifier: identifier) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let submissions):
                    self.documents = submissions
                    print("Retrieved \(submissions.count) document submissions")
                case .failure(let error):
                    print("Error fetching document submissions: \(error.localizedDescription)")
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    public func createDocumentSubmission(identifier: String, completion: @escaping ((Any) -> Void)) {
        self.isLoading = true
        apiService.createDocumentSubmission(identifier: identifier) { result in
            self.isLoading = false
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
