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
                                   destination: FormContainer(document: SwiftUI.Binding(
                                    get: { 
                                        document!
                                    },
                                    set: { 
                                        document = $0
                                    })),
                                   isActive: $showDocumentDetails)
                }
                Text("Document List")
                    .padding()
                    .font(.title.bold())
                List(documents) { submission in
                    Button(action: {
                        makeAPICallForSubmission(submission)
                        isloading = true
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

struct FormContainer: View {
    @Binding var document: JoyDoc
    @State private var showDocumentDetails = false
    @State var currentPage: Int = 0
    @State private var isloading = true
    private let apiService: APIService = APIService()

    init(document: Binding<JoyDoc>) {
        _document = document
    }
    
    var body: some View {
        if isloading {
            ProgressView()
                .onAppear() { isloading = false }
        } else {
            VStack {
                JoyFillView(document: $document, mode: .fill, events: self, currentPage: $currentPage)
                Button(action: {
                    saveJoyDoc()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
            }
        }
    }
    
    @MainActor private func saveJoyDoc() {
        isloading = true
        apiService.updateDocument(identifier: document.identifier!, document: document) { result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success(let data):
                    print("success: \(data)")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func makeAPICallForSubmission(_ submission: Document) {
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
    
    func updateDocument(identifier: String, changeLogs: Changelog) {
        apiService.updateDocument(identifier: identifier, changeLogs: changeLogs) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("success: \(data)")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension FormContainer: FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        print(">>>>>>>>onChange", changes)
        let changeLogs = Changelog(changelogs: changes)
        updateDocument(identifier: document.identifier!, changeLogs: changeLogs)
    }
    
    func onFocus(event: FieldEvent) {
        print(">>>>>>>>onFocus", event.field!.identifier!)
    }
    
    func onBlur(event: FieldEvent) {
        print(">>>>>>>>onBlur", event.field!.identifier!)
    }
    
    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.field.identifier!)
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
}
