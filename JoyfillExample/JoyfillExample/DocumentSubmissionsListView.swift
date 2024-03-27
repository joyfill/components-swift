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
    @State var currentPage: Int = 0
    @State private var isloading = false
    
    private let title: String
    private let apiService: APIService = APIService()
    private var allDocuments: [Document] = []
    
    init(templateIdentifier: String, documents: [Document]) {
        title = String(templateIdentifier.suffix(8))
        let documentsWithSourceAsTemplate =  documents.filter { document in
            document.source == templateIdentifier
        }
        var documentsWithSourceAsDoc = [Document]()
        documentsWithSourceAsTemplate.forEach { document in
            documentsWithSourceAsDoc = documents.filter {  $0.source?.contains(document.id) ?? false }
        }
        _documents = State(initialValue: documentsWithSourceAsDoc + documentsWithSourceAsTemplate)
    }
    
    var body: some View {
        if isloading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("",
                                   destination: FormContainerView(document: Binding(
                                                                    get: { document! },
                                                                    set: { document = $0 }),
                                                              currentPageID: document!.files[0].pages?[0].id ?? ""),
                                   isActive: $showDocumentDetails)
                }
                Text("Document List")
                    .padding()
                    .font(.title.bold())
                List(documents) { submission in
                    Button(action: {
                        makeAPICallForSubmission(submission)
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                }
            }
            .navigationTitle(self.title)
        }
    }
    
    private func makeAPICallForSubmission(_ submission: Document) {
        isloading = true
        apiService.fetchJoyDoc(identifier: submission.identifier) { result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success(let data):
                    do {
                        let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
                        self.document = joyDocStruct
                        showDocumentDetails = true
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}
