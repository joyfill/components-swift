//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

struct DocumentSubmissionsListView: View {
    var identifier: String
    var name: String
    @State var showForm: Bool = false
    @State var document: JoyDoc? = nil
    let apiService: APIService = APIService()
    
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
                    NavigationLink(destination: LazyView(isLoading: !showForm, content: {
                        JoyFillView(document: document!, mode: .readonly, events: nil)
                    }), isActive: $showForm) {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                    .onTapGesture {
                        // Make your API call here
                        makeAPICallForSubmission(submission)
                    }
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
                    // It will prevent tasks to perform on main thread
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

func testDocument() -> JoyDoc {
    if let url = Bundle.main.url(forResource: "RetriveDocument", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
            return joyDocStruct
        } catch {
            print("Error reading JSON file:", error)
        }
    } else {
        print("File not found")
    }
    fatalError()
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
