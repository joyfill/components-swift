//
//  SaveButtonView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService

struct SaveButtonView: View {
    let changeManager: ChangeManager
    @Binding var document: JoyDoc
    
    var body: some View {
        VStack {
            Button(action: {
                changeManager.saveJoyDoc(document: document)
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
        }
    }
}
