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
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeHandler, pageID: "your_Page_Id", navigation: true, isPageDuplicateEnabled: true, validateSchema: true)
    }

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: Joyfill.FieldIdentifier) {}
    func onBlur(event: Joyfill.FieldIdentifier) {}
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
