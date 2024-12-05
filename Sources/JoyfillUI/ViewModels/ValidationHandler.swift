//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 05/12/24.
//

import Foundation
import JoyfillModel

class ValidationHandler {
    weak var documentEditor: DocumentEditor!

    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    func validate() -> Validation {
        var fieldValidations = [FieldValidation]()
        var isValid = true
        let fieldPositionIDs = documentEditor.document.fieldPositionsForCurrentView.map {  $0.field }
        for field in documentEditor.document.fields.filter { fieldPositionIDs.contains($0.id) } {
            if documentEditor.shouldShow(fieldID: field.id) {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }

            guard let required = field.required, required else {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }

            if let value = field.value, !value.isEmpty {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }
            isValid = false
            fieldValidations.append(FieldValidation(field: field, status: .invalid))
        }

        return Validation(status: isValid ? .valid: .invalid, fieldValidations: fieldValidations)
    }
}
