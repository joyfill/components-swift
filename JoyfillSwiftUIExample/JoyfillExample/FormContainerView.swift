//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    let documentEditor: DocumentEditor
    let changeManager: TestChnageMnager

    init(document: JoyDoc, pageID: String) {
        let changeManager = TestChnageMnager()
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeManager, pageID: pageID, navigation: true, isPageDuplicateEnabled: true)
        self.changeManager = changeManager
        self.changeManager.documentEditor = documentEditor
    }

    var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
        }
    }
}

class TestChnageMnager: FormChangeEvent {
    var documentEditor: DocumentEditor?

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        print(">>>>>>>>onChange", changes.first!.fieldId)
    }

    func onFocus(event: FieldIdentifier) {
        print(">>>>>>>>onFocus", event.fieldID)
    }

    func onBlur(event: FieldIdentifier) {
        print(">>>>>>>>onBlur", event.fieldID)
    }

    func onUpload(event: UploadEvent) {
        let imageURL = "https://img.freepik.com/premium-photo/side-view-woman-holding-hands_1048944-16242081.jpg?w=2000"
        let newURL: String = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhjQpwAgFXL5FumQEx3pgIH7ae7VXOI7OvS4M1tTE-zgtNTiwNjdeqlZdsfcr4xb-nQgkbUwOD8IIqyxmTs_qdLjIEnUV8Nh4ZX8vPJQQPTxn27f913P2hyphenhyphenVTIp6KMxq8XysrgRHd5A7AU/w474-h269-rw/Canon+EOS+RP+Official+Sample+Image+01.jpg"
        event.uploadHandler([imageURL])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.documentEditor?.replaceImageURL(newURL: newURL, url: imageURL, fieldIdentifier: event.fieldEvent)
        }
    }
}

extension DocumentEditor {
    func replaceImageURL(newURL: String, url: String, fieldIdentifier: FieldIdentifier) {
        let valueElements = [ValueElement(id: JoyfillModel.generateObjectId(), url: newURL)]
        let newImageValue = ValueUnion.valueElementArray(valueElements)
        let changeData = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: newImageValue)
        onChange(event: changeData)
    }

}
