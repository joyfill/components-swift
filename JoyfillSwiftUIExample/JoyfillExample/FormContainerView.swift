//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    @State var pageID: String
    let documentEditor: DocumentEditor
    let changeManager: ChangeManager

    init(document: JoyDoc, pageID: String, changeManager: ChangeManager) {
        self.documentEditor = DocumentEditor(document: document)
        self.pageID = pageID
        self.changeManager = changeManager
    }

    var body: some View {
        VStack {
            Form(documentEditor: documentEditor, mode: .fill, events: changeManager, pageID: pageID)
            SaveButtonView(changeManager: changeManager, documentEditor: documentEditor)
        }
    }
}
