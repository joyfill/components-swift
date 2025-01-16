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
    @State private var isloading = false

    let title: String
    private let apiService: APIService

    init(apiService: APIService, documents: [Document], title: String) {
        self.apiService = apiService
        self.documents = documents
        self.title = title
    }

    var body: some View {
        if isloading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("", destination: FormContainerView(document: document!, pageID: pageID, changeManager: changeManager), isActive: $showDocumentDetails)
                }
                Text("Document List")
                    .padding()
                    .font(.title.bold())
                List(documents) { submission in
                    Button(action: {
                        fetchDocument(submission)
//                        fetchLocalDocument()
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                }
            }
            .navigationTitle(title)
        }
    }

    private var pageID: String {
        return ""
    }

    private var changeManager: ChangeManager {
        ChangeManager(apiService: apiService, showImagePicker: showImagePicker, showScan: showScan)
    }

    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
    }
    
    private func showScan(captureHandler: (ValueUnion) -> Void) {
        captureHandler(.string("Hello sir."))
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
}
