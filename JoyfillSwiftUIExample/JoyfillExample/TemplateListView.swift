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
    @State var fetchSubmissions = true
    @State var createSubmission = false
    private var apiService: APIService

    init(userAccessToken: String) {
        self.apiService = APIService(accessToken: userAccessToken,
                                     baseURL: "https://api-joy.joyfill.io/v1")
    }

    public var body: some View {
            if fetchSubmissions || createSubmission {
                ProgressView()
                    .onAppear {
                        if fetchSubmissions {
                            fetchData()
                        }
                    }
            } else {
                List {
                    Text("Templates List")
                        .font(.title.bold())
                    ForEach(templates) { template in
                        VStack(alignment: .trailing) {
                            NavigationLink {
                                DocumentSubmissionsListView(apiService: apiService, documents: allDocuments(for: template.identifier),
                                                            title: String(template.identifier.suffix(8)))
                            } label: {
                                HStack {
                                    Image(systemName: "doc")
                                        .padding(5)
                                    Text(template.name)
                                }
                            }
                            Button(action: {
                                createDocumentSubmission(identifier: template.identifier, completion: { _ in })
                            }, label: {
                                Text("Fill New +")
                            })
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(20)
                    .border(Color.gray, width: 2)
                    .cornerRadius(2)
                }
                .refreshable {
                    fetchSubmissions = true
                }
            }
        }
}

extension TemplateListView {

    func fetchData() {
        fetchTemplates() { 
            fetchDocuments()
        }
    }
    
    private func allDocuments(for templateIdentifier: String) -> [Document] {
        let documentsWithSourceAsTemplate =  documents.filter { document in
            document.source == templateIdentifier
        }
        var documentsWithSourceAsDoc = [Document]()
        documentsWithSourceAsTemplate.forEach { document in
            documentsWithSourceAsDoc = documents.filter {  $0.source?.contains(document.id) ?? false }
        }
       return documentsWithSourceAsDoc + documentsWithSourceAsTemplate
    }
    
    private func fetchDocuments() {
        apiService.fetchDocuments() { result in
            DispatchQueue.main.async {
                self.fetchSubmissions = false
                switch result {
                case .success(let documents):
                    self.documents = documents
                case .failure(let error):
                    print("Error fetching documents: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchTemplates(completion:  @escaping () -> Void) {
        apiService.fetchTemplates { result in
            switch result {
            case .success(let templates):
                self.templates = templates
            case .failure(let error):
                print("Error fetching templates: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    private func createDocumentSubmission(identifier: String, completion: @escaping ((Any) -> Void)) {
        self.createSubmission = true
        apiService.createDocumentSubmission(identifier: identifier) { result in
            DispatchQueue.main.async {
                self.createSubmission = false
                DispatchQueue.main.async {
                    self.fetchSubmissions = true
                }
            }

            switch result {
            case .success(let jsonRes):
                let id = (jsonRes as! [String: Any])["_id"] as! String
                print("Created document submission: \(id)")
                break
            case .failure(let error):
                print("Error creating submission: \(error.localizedDescription)")
            }
        }
    }
}
