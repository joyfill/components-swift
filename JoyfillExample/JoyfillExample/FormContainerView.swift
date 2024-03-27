//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    @Binding var document: JoyDoc
    @State var currentPageID: String
    private let changeManager = ChangeManager()

    var body: some View {
        VStack {
            JoyFillView(document: $document, mode: .fill, events: changeManager, currentPageID: $currentPageID)
            SaveButtonView(changeManager: changeManager, document: $document)
        }
    }
    
    func showImagePicker() {
        
    }
}
