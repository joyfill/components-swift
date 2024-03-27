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
    private let apiService: APIService = APIService()
    
    var body: some View {
        if isloading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("", destination: FormContainerView(document: documentBinding, currentPageID: currentPageID, changeManager: changeManager), isActive: $showDocumentDetails)
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
    
    private var documentBinding: Binding<JoyDoc> {
        Binding(get: { document! }, set: { document = $0 })
    }
    
    private var currentPageID: String {
        document!.files[0].pages?[0].id ?? ""
    }
    
    private var changeManager: ChangeManager {
        ChangeManager(showImagePicker: showImagePicker)
    }
    
    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
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
