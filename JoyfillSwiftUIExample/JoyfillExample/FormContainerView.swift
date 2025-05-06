//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    let documentEditor: DocumentEditor
    let changeManager: ChangeManager

    init(document: JoyDoc, pageID: String, changeManager: ChangeManager) {
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeManager, pageID: pageID, navigation: true, isPageDuplicateEnabled: true)
        self.changeManager = changeManager
    }

    var body: some View {
        VStack {
            Form(documentEditor: documentEditor)
            SaveButtonView(changeManager: changeManager, documentEditor: documentEditor)
        }
    }
}
