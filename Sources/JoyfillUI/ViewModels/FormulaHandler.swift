// //
// //  File.swift
// //
// //
// //  Created by Vishnu Dutt on 05/12/24.
// //

// import Foundation
// import JoyfillModel


// class FormulaHandler {
//     weak var documentEditor: DocumentEditor!
    
//     init(documentEditor: DocumentEditor) {
//         self.documentEditor = documentEditor
//     }

//     func evaluateAllFormulas() {
//         let formulaFields = documentEditor.allFields.filter { $0.formula != nil }
//         for field in formulaFields {
//             evaluateFormula(field)
//         }
//     }

//     func evaluateFormula(_ field: JoyDocField) {
//         let formula = field.formula
//         let context = JoyfillDocContext(docProvider: documentEditor)
//         let result = formula?.evaluate(with: context)
//         print("Formula result for \(field.identifier ?? "unknown"): \(result ?? "nil")")
//     }

//     func valueUpdated() {
//         evaluateAllFormulas()
//     }
// }
