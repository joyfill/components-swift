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
    let imagePicker = ImagePicker()

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
        imagePicker.showPickerOptions { urls in
            let imageURL = urls.first!
            event.uploadHandler([imageURL])
            let newURL = "https://app.joyfill.io/static/img/joyfill_logo_w.png"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.documentEditor?.replaceImageURL(newURL: newURL, url: imageURL, fieldIdentifier: event.fieldEvent)
            }
        }
    }
}

extension DocumentEditor {
    func replaceImageURL(newURL: String, url: String, fieldIdentifier: FieldIdentifier) {
        guard let existingImages = field(fieldID: fieldIdentifier.fieldID)?.value?.valueElements else {
            return
        }

        let updatedImages = existingImages.compactMap { element -> ValueElement in
            if element.url == url {
                return ValueElement(id: JoyfillModel.generateObjectId(), url: newURL)
            }
            return element
        }
        let newImageValue = ValueUnion.valueElementArray(updatedImages)
        let changeData = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: newImageValue)
        onChange(event: changeData)
    }

}
