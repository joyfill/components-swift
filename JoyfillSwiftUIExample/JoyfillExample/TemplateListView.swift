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
    @State var showNewSubmission = false
    private var apiService: APIService
    @State var document: JoyDoc?
    @State var showCameraScannerView: Bool = false
    @State var scanResults: String = ""

    init(userAccessToken: String) {
        self.apiService = APIService(accessToken: userAccessToken,
                                     baseURL: "https://api-joy.joyfill.io/v1")
    }

    private var changeManager: ChangeManager {
        ChangeManager(apiService: apiService, showImagePicker: showImagePicker, showScan: showScan)
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

                            if showNewSubmission {
                                NavigationLink("", destination: FormContainerView(document: document!, pageID: "", changeManager: changeManager), isActive: $showNewSubmission)
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

    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
    }
    
    private func showScan(captureHandler: (ValueUnion) -> Void) {
        showCameraScannerView = true
        captureHandler(.string(scanResults))
    }
}

extension TemplateListView {

    func fetchData() {
        fetchTemplates() { 
            fetchDocuments() {

            }
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
    
    private func fetchDocuments(completion: @escaping (() -> Void)) {
        apiService.fetchDocuments() { result in
            DispatchQueue.main.async {
                self.fetchSubmissions = false
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
                switch result {
                case .success(let jsonRes):
                    let dictionary = (jsonRes as! [String: Any])
                    self.document = JoyDoc(dictionary: dictionary)
                    fetchDocuments() {
                        self.createSubmission = false
                        showNewSubmission = true
                    }
                    break
                case .failure(let error):
                    print("Error creating submission: \(error.localizedDescription)")
                }
            }


        }
    }
}
