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
                                   destination: FormContainer(document: $document),
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
    @Binding var document: JoyDoc?
    @State private var showDocumentDetails = false
    @State var currentPage: Int = 0
    @State private var isloading = true
    private let apiService: APIService = APIService()
    private var changelogs: ChangeDelta? = nil

    init(document: Binding<JoyDoc?>) {
        _document = document
    }
    
    var body: some View {
        if isloading {
            ProgressView()
                .onAppear() { isloading = false }
        } else {
            VStack {
                JoyFillView(document: document!, mode: .fill, events: self, currentPage: $currentPage)
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
//        updateDocumentChangelogs(identifier: (document?.identifier)!, docChangeLogs: [:])
//        apiService.saveJoyDoc(joyDoc: document!) { result in
//            DispatchQueue.main.async {
//                isloading = false
//                switch result {
//                case .success(let data):
//                    print("success: \(data)")
//                case .failure(let error):
//                    print("error: \(error.localizedDescription)")
//                }
//            }
//        }
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
    
    func updateDocumentChangelogs(identifier: String, docChangeLogs: ChangeDelta) {
        do {
            let baseURL = "https://api-joy.joyfill.io/v1"
            let userAccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk"

            guard let url = URL(string: "\(baseURL)/\(identifier)/changelogs") else {
                print("Invalid json url")
                return
            }

            let jsonData = try JSONEncoder().encode(docChangeLogs)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("Bearer \(userAccessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating changelogs: \(error)")
                } else if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
                    let _ = json as? NSDictionary
                }
            }.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
}

extension FormContainer: FormChangeEvent {
    func onChange(change: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        print(">>>>>>>>onChange", change)
//        let docChangeLogs = ["changelogs": change.toDict()]
        let changeDelta = ChangeDelta(changelogs: change)
        updateDocumentChangelogs(identifier: document.identifier!, docChangeLogs: changeDelta)
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

struct ChangeDelta: Codable {
    let changelogs: [JoyfillModel.Change]
}

//
//
//protocol JSONAble {}
//
//extension JoyfillModel.Change: JSONAble {
//    
//}
//
//extension JSONAble {
//    func toDict() -> [String:Any] {
//        var dict = [String: Any]()
//        let otherSelf = Mirror(reflecting: self)
//        for child in otherSelf.children {
//            if let key = child.label {
//                dict[key] = child.value
//            }
//        }
//        return dict
//    }
//}
//
//extension Encodable {
//    /// Converting object to postable dictionary
//    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
//        let data = try encoder.encode(self)
//        let object = try JSONSerialization.jsonObject(with: data)
//        if let json = object as? [String: Any]  { return json }
//        
//        let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
//        throw DecodingError.typeMismatch(type(of: object), context)
//    }
//}
