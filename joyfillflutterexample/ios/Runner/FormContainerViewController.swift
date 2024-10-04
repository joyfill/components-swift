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
    var document: JoyDoc?
    var currentPage: String? = nil
    var changeHandler = ChangeHandler()

    init(document: JoyDoc? = nil, currentPage: String? = nil, changeHandler: ChangeHandler = ChangeHandler()) {
        self.currentPage = currentPage
        self.changeHandler = changeHandler
        super.init(nibName: nil, bundle: nil)
        self.document = document ?? sampleJSONDocument()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func sampleJSONDocument() -> JoyDoc {
        let path = Bundle.main.path(forResource: "sample-form", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: joyFillView)
        vc.view.frame = self.view.bounds
        self.view.addSubview(vc.view)
        addChild(vc)
    }

    @ViewBuilder
    var joyFillView: some View {
        NavigationView {
            Form(document: documentBinding , mode: .fill, events: changeHandler, pageID: currentPage)
        }
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
        print(">>>>>>>>onChange", changes.first!.identifier)
    }

    func onFocus(event: FieldEvent) {
        print(">>>>>>>>onFocus", event.field!.id!)
    }

    func onBlur(event: FieldEvent) {
        print(">>>>>>>>onBlur", event.field!.id!)
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.field.id!)
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
}

