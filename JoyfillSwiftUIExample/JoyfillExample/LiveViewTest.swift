//
//  LiveViewTest.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 21/04/25.
//

import Foundation
import JoyfillModel
import Joyfill
import JoyfillFormulas
import SwiftUI

struct LiveViewTest: View {
    let documentEditor: DocumentEditor

    init() {
        let document = JoyDoc
            .addDocument()
//            .addNumberField(identifier: "num1", formula: "{num3} + {num2}")
//            .addNumberField(identifier: "num2", formula: "{num4} + 5")
//            .addNumberField(identifier: "num3", value: 500)
            .addNumberField(identifier: "num4", value: 133)
//            .addTextField(identifier: "text1", formula: "if({num4} > 3, \"yes\", \"no\")", value: "Hello, World!")
//            .addDateField(identifier: "due_date", formula: "", date: Date())
            .addTextareaField(formula: "if({num4} > 3, \"yes\", \"no\")")

        self.documentEditor = DocumentEditor(document: document)
    }

    var body: some View {
        NavigationView {
            Form(documentEditor: documentEditor)
        }
    }
}

#Preview {
    LiveViewTest()
}
