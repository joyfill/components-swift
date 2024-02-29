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
    var identifier: String
    var name: String
    @State var showForm: Bool = false
    @State var document: JoyDoc? = nil
    let apiService: APIService = APIService()
    @State private var showDocumentDetails = false
    
    @ObservedObject var documentsViewModel = DocumentsViewModel()
    
    var body: some View {
        Group {
            List {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 20, weight: .semibold))
                    Text("Submissions")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.gray)
                }
                Button(action: {
                    documentsViewModel.createDocumentSubmission(identifier: identifier, completion: { joyDocJSON in
                        documentsViewModel.fetchDocumentSubmissions(identifier: identifier)
                    })
                }, label: {
                    Text("Fill New +")
                })
                
                ForEach(documentsViewModel.submissions) { submission in
                    Button(action: {
                        makeAPICallForSubmission(submission)
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                }
                NavigationLink(destination: LazyView(isLoading: !showForm, content: {
                    JoyFillView(document: document!, mode: .readonly, events: self)
                }), isActive: $showForm) {
                    EmptyView()
                }
            }
        }
        .onAppear() {
            documentsViewModel.fetchDocumentSubmissions(identifier: identifier)
        }
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
                        showForm = true
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

#Preview {
    DocumentSubmissionsListView(identifier: "sadfsedf efe  e erdocuments", name: "New Document", document: testDocument())
}

struct LazyView<Content: View>: View {
    let isLoading: Bool
    let content: () -> Content
    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            content()
        }
    }
}

extension DocumentSubmissionsListView: Events {
    func onChange(event: ChangeEvent) {
        print(">>>>>>>>onChange", event.changes)
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
