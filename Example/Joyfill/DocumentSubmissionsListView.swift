//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService
import JoyfillUI

struct DocumentSubmissionsListView: View {
    @State var template: Document
    @State var documents: [Document] = []
    var allDocuments: [Document] = []
    @State var document: JoyDoc? = nil
    @State private var showDocumentDetails = false
    let apiService: APIService = APIService()
    
    var body: some View {
        Group {
            List {
                VStack(alignment: .leading) {
                    Text(template.identifier)
                    Text(template.name)
                        .font(.system(size: 20, weight: .semibold))
                    Text("Submissions")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.gray)
                }
                
                ForEach(documents) { submission in
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
            .navigationDestination(isPresented: $showDocumentDetails, destination: {
                if showDocumentDetails {
                    JoyFillView(document: document!, mode: .fill, events: self)
                }
            })
        }
        .onAppear() {
            updateDocuments(template: template, allDocuments: allDocuments)
        }
    }
    
    func updateDocuments(template: Document, allDocuments: [Document]) {
        let documentsWithSourceAsTemplate =  allDocuments.filter { document in
            document.source == template.identifier
        }
        var documentsWithSourceAsDoc = [Document]()
        documentsWithSourceAsTemplate.forEach { document in
            documentsWithSourceAsDoc = allDocuments.filter {  $0.source?.contains(document.id) ?? false }
        }
        self.documents = documentsWithSourceAsDoc + documentsWithSourceAsTemplate
    }

    // Function to make the API call
    private func makeAPICallForSubmission(_ submission: Document) {
        apiService.fetchJoyDoc(identifier: submission.identifier) { result in
            switch result {
            case .success(let data):
                do {
                    let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
                    DispatchQueue.main.async {
                        self.document = joyDocStruct
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

extension DocumentSubmissionsListView: FormChangeEvent {
    func onChange(event: ChangeEvent) {
        print(">>>>>>>>onChange", event.field?.value)
    }
    
    func onFocus(event: FieldEvent) {
        print(">>>>>>>>onFocus", event.field!.identifier!)
    }
    
    func onBlur(event: FieldEvent) {
        print(">>>>>>>>onBlur", event.field!.identifier!)
    }
    
    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.field.identifier!)
        event.uploadHandler(["https://png.pngtree.com/png-vector/20191121/ourmid/pngtree-blue-bird-vector-or-color-illustration-png-image_2013004.jpg",
                             "https://png.pngtree.com/png-vector/20191121/ourmid/pngtree-blue-bird-vector-or-color-illustration-png-image_2013004.jpg"])
    }
}
