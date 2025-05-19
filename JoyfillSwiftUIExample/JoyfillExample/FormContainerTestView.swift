//
//  FormContainerTestView.swift
//  JoyfillExample
//
//  Created by Vivek on 05/05/25.
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerTestView: View {
    let documentEditor: DocumentEditor
    let changeManager: TestChangeManager

    init(document: JoyDoc, pageID: String) {
        let changeManager = TestChangeManager()
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

class TestChangeManager: FormChangeEvent {
    func onCapture(event: JoyfillModel.CaptureEvent) {
        print(">>>>>>>>onCapture")
    }
    
    var documentEditor: DocumentEditor?
    let imagePicker = ImagePicker()

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
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
        imagePicker.showPickerOptions { urls in
            event.uploadHandler(urls)
            let newURLs = ["https://app.joyfill.io/static/img/joyfill_logo_w.png","https://picsum.photos/id/0/5000/3333", "https://picsum.photos/id/4/5000/3333","https://picsum.photos/id/10/2500/1667","https://picsum.photos/id/14/2500/1667","https://picsum.photos/id/15/2500/1667","https://picsum.photos/id/19/2500/1667", "https://picsum.photos/id/27/3264/1836"]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.documentEditor?.replaceImageURLs(newURLs: newURLs, oldURLs: urls, fieldIdentifier: event.fieldEvent)
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
    
    public func replaceImageURLs(
        newURLs: [String],
        oldURLs: [String],
        fieldIdentifier: FieldIdentifier
    ) {
        // 1) Safely grab the field and its existing images
        guard let field = field(fieldID: fieldIdentifier.fieldID),
              let existingImages = field.value?.valueElements else {
            return
        }

        // 2) Map each element to either a single new one or itself
        let updatedImages: [ValueElement] = existingImages.map { element in
            if let oldIndex = oldURLs.firstIndex(of: element.url ?? ""),
               oldIndex < newURLs.count
            {
                // Replace with exactly one new URL at the same position
                return ValueElement(
                    id: JoyfillModel.generateObjectId(),
                    url: newURLs[oldIndex]
                )
            } else {
                // Keep the original element
                return element
            }
        }

        // 3) Persist back and fire your change event
        let newValue = ValueUnion.valueElementArray(updatedImages)
        let changeData = FieldChangeData(
            fieldIdentifier: fieldIdentifier,
            updateValue: newValue
        )
        onChange(event: changeData)
    }
}
