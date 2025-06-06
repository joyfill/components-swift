//
//  FormContainerViewController.swift
//  JoyfillUIKitExample
//
//  Created by Vishnu Dutt on 02/04/24.
//


import SwiftUI
import UIKit
import Joyfill
import JoyfillModel

class FormContainerViewController: UIViewController {
    var document: JoyDoc!
    var currentPage: String? = nil
    var changeHandler = ChangeHandler()
    var documentEditor: DocumentEditor!

    init(document: JoyDoc? = nil, currentPage: String? = nil, changeHandler: ChangeHandler = ChangeHandler()) {
        self.document = document
        self.currentPage = currentPage
        self.changeHandler = changeHandler
        super.init(nibName: nil, bundle: nil)
        self.document = document ?? sampleJSONDocument()
        self.documentEditor = DocumentEditor(document: self.document!, mode: .fill, events: changeHandler, pageID: currentPage)
    }

    func sampleJSONDocument() -> JoyDoc {
        let path = Bundle.main.path(forResource: "sample-form", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = UIHostingController(rootView: joyFillView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }

    @ViewBuilder
    var joyFillView: some View {
        NavigationView {
            Form(documentEditor: self.documentEditor)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var documentBinding: Binding<JoyDoc> {
        return Binding(get: { self.document ?? self.sampleJSONDocument() }, set: { self.document = $0 })
    }

    var currentPageBinding: Binding<String>? {
        return Binding(get: { self.currentPage ?? "" }, set: { self.currentPage = $0 })
    }
}

class ChangeHandler: FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        if let firstChange = changes.first {
            print(">>>>>>>>onChange", firstChange.fieldId ?? "")
        } else {
            print(">>>>>>>>onChange: no changes")
        }
    }

    func onFocus(event: FieldIdentifier) {
        print(">>>>>>>>onFocus", event.fieldID)
    }

    func onBlur(event: FieldIdentifier) {
        print(">>>>>>>>onBlur", event.fieldID)
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.fieldEvent.fieldID)
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
}

