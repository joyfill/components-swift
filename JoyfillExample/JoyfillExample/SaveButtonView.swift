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
//                changeManager.saveJoyDoc(document: document)
                let result = Validator.validate(document: document)
                for result2 in result.fieldValidations {
                    print(result2.field.id!, ":", result2.status)
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
