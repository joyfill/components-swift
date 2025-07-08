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

var documentEditor2: DocumentEditor!

struct OnChangeHandlerTest: View, FormChangeEvent {
    let imagePicker = ImagePicker()
    init() {
            var document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Populated")
            document.id = UUID().uuidString
            documentEditor = DocumentEditor(document: document, events: self)
            document.id = UUID().uuidString
            documentEditor2 = DocumentEditor(document: document, events: self)
    }
    
    var body: some View {
        HStack {
            NavigationView {
                Form(documentEditor: documentEditor)
                    .tint(.red)
            }
            NavigationView {
                Form(documentEditor: documentEditor)
            }
        }
    }

    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        if document.id == documentEditor.documentID {
            // documentEditor changes
            documentEditor2.change(changes: changes)

        } else {
            // documentEditor2 changes
            documentEditor.change(changes: changes)
        }
    }

    func onFocus(event: JoyfillModel.FieldIdentifier) { }
    func onBlur(event: JoyfillModel.FieldIdentifier) { }
    func onCapture(event: JoyfillModel.CaptureEvent) { }
    func onUpload(event: JoyfillModel.UploadEvent) {}
}
