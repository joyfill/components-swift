//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService
import Joyfill

struct DocumentSubmissionsListView: View {
    @State var documents: [Document] = []
    @State var document: JoyDoc?
    @State private var showDocumentDetails = false
    @State private var isloading = true
    @State var fetchSubmissions = true
    @State var identifier: String
    @State private var currentDocumentPage: Int = 1
    @State private var isLoadingMoreDocuments: Bool = false
    @State private var hasMoreDocuments: Bool = true
    
    let title: String
    private let apiService: APIService
    
    init(apiService: APIService, identifier: String, title: String) {
        self.apiService = apiService
        self.title = title
        self.identifier = identifier
    }
    
    var body: some View {
        if isloading {
            ProgressView()
                .onAppear {
                    if fetchSubmissions {
                        fetchData()
                    }
                }
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("", destination: FormContainerView(document: document!, pageID: pageID, changeManager: changeManager), isActive: $showDocumentDetails)
                }
                List {
                    Section(header: Text("Documents")
                        .font(.title.bold())) {
                            ForEach(documents) { submission in
                                Button(action: {
                                    fetchDocument(submission)
                                }) {
                                    HStack {
                                        Image(systemName: "doc")
                                        Text(submission.name)
                                    }
                                }
                                .onAppear {
                                    if submission == documents.last && documents.count >= 20 {
                                        loadMoreDocuments()
                                    }
                                }
                            }
                        }
                }
            }
            .navigationTitle(title)
            
            if isLoadingMoreDocuments {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    private var pageID: String {
        return ""
    }
    
    private var changeManager: ChangeManager {
        ChangeManager(apiService: apiService, showImagePicker: showImagePicker)
    }
    
    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
    }
    
    private func fetchLocalDocument() {
        isloading = true
        DispatchQueue.global().async {
            self.document = sampleJSONDocument(fileName: "3000-fields")
            DispatchQueue.main.async {
                showDocumentDetails = true
                isloading = false
            }
        }
    }
    
    private func fetchDocument(_ submission: Document) {
        isloading = true
        apiService.fetchJoyDoc(identifier: submission.identifier) { result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success(let data):
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            self.document = JoyDoc(dictionary: dictionary)
                            showDocumentDetails = true
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchDocuments(identifier: String, completion: @escaping (() -> Void)) {
        apiService.fetchDocuments(identifier: identifier, page: 1, limit: 20) { result in
            DispatchQueue.main.async {
                self.fetchSubmissions = false
                self.isloading = false
                switch result {
                case .success(let documents):
                    self.documents = documents
                    completion()
                case .failure(let error):
                    print("Error fetching documents: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchData() {
        fetchDocuments(identifier: identifier){}
    }
    
    private func loadMoreDocuments() {
        guard !isLoadingMoreDocuments, hasMoreDocuments else { return }
        isLoadingMoreDocuments = true
        let nextPage = currentDocumentPage + 1
        
        apiService.fetchDocuments(identifier: identifier, page: nextPage, limit: 20) { result in
            DispatchQueue.main.async {
                isLoadingMoreDocuments = false
                switch result {
                case .success(let newDocuments):
                    if newDocuments.isEmpty {
                        hasMoreDocuments = false
                    } else {
                        documents.append(contentsOf: newDocuments)
                        currentDocumentPage = nextPage
                    }
                case .failure(let error):
                    print("Error loading more templates: \(error.localizedDescription)")
                }
            }
        }
    }
}
