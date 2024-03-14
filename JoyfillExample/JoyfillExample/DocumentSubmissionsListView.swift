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
    @State var template: Document
    @State var documents: [Document] = []
    @State var document: JoyDoc? = nil
    @State private var showDocumentDetails = false
    let apiService: APIService = APIService()
    var allDocuments: [Document] = []
    @State var currentPage: Int
    @State private var isloading = true


    var body: some View {
        if isloading {
            ProgressView()
                .onAppear() {
                    updateDocuments(template: template, allDocuments: allDocuments)
                    isloading = false
                }
        } else {
            Group {
                List {
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.system(size: 20, weight: .semibold))
                        Text("Submissions")
                            .font(.system(size: 16, weight: .semibold)).foregroundStyle(.gray)
                    }
                    
                    ForEach(documents) { submission in
                        NavigationLink(destination:
                                        LazyView(isLoading: $showDocumentDetails, content: {
                            JoyFillView(document: document!, mode: .fill, events: self, currentPage: $currentPage)
                        }), isActive: $showDocumentDetails) {
                                        
                        }
                        Button(action: {
                            makeAPICallForSubmission(submission)
                        }) {
                            HStack {
                                Image(systemName: "doc")
                                Text(submission.name)
                            }
                        } 
                        
                       
                    }
                    .navigationTitle("...\(template.title)")
                }
                .onAppear() {
                }
            }
        }
//            .onChange(showDocumentDetails) { value in
//                if value == false {
//                    updateDocuments(template: template, allDocuments: allDocuments)
//                }
//            }
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
    func onChange(event: JoyfillModel.Change) {
        print(">>>>>>>>onChange", event)
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

extension Document {
    public var title: String {
        String(_id.suffix(8))
    }
}


//struct NavigationLazyView<Content: View>: View {
//    let build: () -> Content
//    @Binding var isLoading: Bool
//    
////    init(build: @autoclosure  @escaping () -> Content, isLoading: Binding<Bool>) {
////        self.isLoading = isLoading
////        self.build = build
////    }
//
////    init(_ build: @autoclosure @escaping () -> Content, isLoading: Binding<Bool>) {
////        self.build = build
////        self.isLoading = isLoading
////    }
//    var body: some View {
//        if isLoading {
//            Text("Loading....")
//        } else {
//            build()
//        }
//    }

//}



struct LazyView<Content: View>: View {
    @Binding var isLoading: Bool
    let content: () -> Content
    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            content()
        }
    }
}
