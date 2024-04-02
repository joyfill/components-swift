//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    @Binding var document: JoyDoc
    @State var pageID: String
    let changeManager: ChangeManager

    var body: some View {
        VStack {
            Form(document: $document, mode: .fill, events: changeManager, pageID: $pageID)
            SaveButtonView(changeManager: changeManager, document: $document)
        }
    }
}
