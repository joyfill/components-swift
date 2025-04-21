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
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setNumberFieldWithFormula(identifier: "num1", formula: "{num3} + {num2}")
            .setNumberFieldWithFormula(identifier: "num3", value: .double(500))
            .setNumberFieldWithFormula(identifier: "num2", value: .double(133))
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: nil, navigation: true, isPageDuplicateEnabled: true)
    }

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

#Preview {
    LiveViewTest()
}
