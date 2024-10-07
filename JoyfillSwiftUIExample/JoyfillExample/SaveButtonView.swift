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
                let result = Validator.validate(document: document)
                print("Document status:", result.status)
                for fieldResult in result.fieldValidations {
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
