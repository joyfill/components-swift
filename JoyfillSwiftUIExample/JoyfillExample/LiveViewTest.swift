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
        let document = JoyDoc.addDocument()
            .addFormula(id: "f1", formula: "if({num1} > 3, true, false)")
            .addNumberField(identifier: "num2", formulaRef: "f1", formulaKey: "hidden")
            .addNumberField(identifier: "num1", value: 20)
            .addTextField(identifier: "text1", formulaRef: "f1", formulaKey: "value")
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
