////
////  JoyfillViewController.swift
////  JoyfillExample
////
////  Created by ianmol's Macbook on 19/03/24.
////
//
//
//import SwiftUI
//import UIKit
//import Joyfill
//import JoyfillModel
//import JoyfillAPIService
//
//
//class ViewController: UIHostingController<JoyFillView> {
//     var documents: [Document] = []
//     var document: JoyDoc? = nil
//     private var showDocumentDetails = false
//     var currentPage: Int = 0
//     private var isloading = false
//   
//    private let apiService: APIService = APIService()
//    private var allDocuments: [Document] = []
//    
//    init(templateIdentifier: String, documents: [Document]) {
////        title = String(templateIdentifier.suffix(8))
//        let documentsWithSourceAsTemplate =  documents.filter { document in
//            document.source == templateIdentifier
//        }
//        var documentsWithSourceAsDoc = [Document]()
//        documentsWithSourceAsTemplate.forEach { document in
//            documentsWithSourceAsDoc = documents.filter {  $0.source?.contains(document.id) ?? false }
//        }
//        self.documents = documentsWithSourceAsDoc + documentsWithSourceAsTemplate
//        var currentPageBinding: Binding<Int>? {
//            return Binding(get: { self.currentPage }, set: { self.currentPage = $0 })
//        }
//        let changeHandler = ChangeHandler()
////        super.init(rootView: JoyFillView(document: document!, mode: .fill, events: changeHandler, currentPage: nil))
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        makeAPICallForSubmission("template_65f7e61a09ef457a44813e18")
//    }
//    
//    required init?(coder: NSCoder) {
//        let changeHandler = ChangeHandler()
////        super.init(coder: coder, rootView: JoyFillView(document: document!, mode: .fill, events: changeHandler))
//    }
//    
////    var currentPageBinding: Binding<Int>? {
////        return Binding(get: { self.currentPage }, set: { self.currentPage = $0 })
////    }
//    
//    private func makeAPICallForSubmission(_ identifier: String) {
//        apiService.fetchJoyDoc(identifier: identifier) { result in
//            DispatchQueue.main.async {
////                isloading = false
//                switch result {
//                case .success(let data):
//                    do {
//                        let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
//                        self.document = joyDocStruct
////                        showDocumentDetails = true
//                    } catch {
//                        print("Error decoding JSON: \(error)")
//                    }
//                case .failure(let error):
//                    print("error: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//class ChangeHandler: FormChangeEvent {
//    func onChange(change: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
//        print(">>>>>>>>onChange", change)
//    }
//    
//    func onChange(event: JoyfillModel.Change) {
//    }
//    
//    func onFocus(event: FieldEvent) {
//        print(">>>>>>>>onFocus", event.field!.identifier!)
//    }
//    
//    func onBlur(event: FieldEvent) {
//        print(">>>>>>>>onBlur", event.field!.identifier!)
//    }
//    
//    func onUpload(event: UploadEvent) {
//        print(">>>>>>>>onUpload", event.field.identifier!)
//        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
//    }
//}
