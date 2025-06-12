//
//  LiveViewTest.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 21/04/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

var documentEditor: DocumentEditor!

struct ImageReplacementTest: View, FormChangeEvent {
    let imagePicker = ImagePicker()
    init() {
        let document = JoyDoc.addDocument()
            .addImageField(identifier: "image1")
            documentEditor = DocumentEditor(document: document, events: self)
    }
    
    var body: some View {
        Form(documentEditor: documentEditor)
                .tint(.red)
    }

    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: JoyfillModel.FieldIdentifier) { }
    func onBlur(event: JoyfillModel.FieldIdentifier) { }
    func onCapture(event: JoyfillModel.CaptureEvent) { }

    func onUpload(event: JoyfillModel.UploadEvent) {
        imagePicker.showPickerOptions { urls in
            let imageURL = urls.first!
            event.uploadHandler([imageURL])
            let newURL = "https://app.joyfill.io/static/img/joyfill_logo_w.png"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                documentEditor?.replaceImageURL(newURL: newURL, url: imageURL, fieldIdentifier: event.fieldEvent)
            }
        }
    }
}
