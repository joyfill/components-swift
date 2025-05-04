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
    init() {
        let document = JoyDoc.addDocument()
            .addImageField(identifier: "image1")
            documentEditor = DocumentEditor(document: document, events: self)
    }
    
    var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
                .tint(.red)
        }
    }

    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        print(">>>>>>>>onChange", changes.first?.change!)
    }

    func onFocus(event: JoyfillModel.FieldIdentifier) { }

    func onBlur(event: JoyfillModel.FieldIdentifier) { }

    func onUpload(event: JoyfillModel.UploadEvent) {
        let imageURL = "https://img.freepik.com/premium-photo/side-view-woman-holding-hands_1048944-16242081.jpg?w=2000"
        let newURL: String = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhjQpwAgFXL5FumQEx3pgIH7ae7VXOI7OvS4M1tTE-zgtNTiwNjdeqlZdsfcr4xb-nQgkbUwOD8IIqyxmTs_qdLjIEnUV8Nh4ZX8vPJQQPTxn27f913P2hyphenhyphenVTIp6KMxq8XysrgRHd5A7AU/w474-h269-rw/Canon+EOS+RP+Official+Sample+Image+01.jpg"
        event.uploadHandler([imageURL])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            documentEditor?.replaceImageURL(newURL: newURL, url: imageURL, fieldIdentifier: event.fieldEvent)
        }
    }
}
