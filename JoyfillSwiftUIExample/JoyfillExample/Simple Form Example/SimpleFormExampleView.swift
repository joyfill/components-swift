//
//  SimpleFormExampleView.swift
//  JoyfillExample
//
//  Created by Vivek on 25/09/25.
//

import SwiftUI
import Joyfill
import JoyfillModel

struct SimpleFormExampleView: View {
    let documentEditor: DocumentEditor
    let changeHandler = ChangeHandler()
    let document = loadDoc(named: "first-form")

    init() {
        self.documentEditor = DocumentEditor(
            document: document,
            config: DocumentEditorConfig(
                mode: .fill,
                events: changeHandler,
                validateSchema: true,
                page: PageConfig(
                    navigation: true,
                    enableDuplicates: true,
                    enableDeletes: true,
                    currentPageID: "your_Page_Id"
                ),
                display: DisplayConfig(singleClickRowEdit: true)
            )
        )
    }

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: Joyfill.Event) {}
    func onBlur(event: Joyfill.Event) {}
    func onUpload(event: Joyfill.UploadEvent) {}
    func onCapture(event: Joyfill.CaptureEvent) {}
    func onError(error: Joyfill.JoyfillError) {}
}

private extension SimpleFormExampleView {
    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}
