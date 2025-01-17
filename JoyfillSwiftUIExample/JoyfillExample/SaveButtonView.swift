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
    let documentEditor: DocumentEditor
    
    var body: some View {
        VStack {
            Button(action: {
                changeManager.saveJoyDoc(document: documentEditor.document)
                let result = documentEditor.validate()
                print("Document status:", result.status)
                for fieldResult in result.fieldValidities {
                    print("Field status:", fieldResult.field.id!, ":", fieldResult.status)
                }
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
    }
}
