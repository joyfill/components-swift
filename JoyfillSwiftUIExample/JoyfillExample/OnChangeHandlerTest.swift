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
    func onError(error: Joyfill.JoyfillError) {
    }
    
    let imagePicker = ImagePicker()
    init() {
        //
        var document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        document.id = UUID().uuidString
        print("documentEditor1", document.id)
        documentEditor = DocumentEditor(document: document, events: self)
        document.id = UUID().uuidString
        print("documentEditor2", document.id)
        documentEditor2 = DocumentEditor(document: document, events: self)
    }
    
    var body: some View {
        HStack {
            NavigationView {
                Form(documentEditor: documentEditor)
                    .tint(.red)
            }
            NavigationView {
                Form(documentEditor: documentEditor2)
            }
        }
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        print("onChange documentID:", document.id)
        if document.id == documentEditor.documentID {
            // documentEditor changes
            documentEditor2.change(changes: changes)

        } else {
            // documentEditor2 changes
            documentEditor.change(changes: changes)
        }
    }

    func onFocus(event: FieldIdentifier) { }
    func onBlur(event:  FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) {
        event.uploadHandler(["https://app.joyfill.io/static/img/joyfill_logo_w.png"])
    }
}
