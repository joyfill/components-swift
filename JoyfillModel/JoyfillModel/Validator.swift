//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 14/07/24.
//

import Foundation

public class Validator {
    public static func validate(document: JoyDoc) -> Validation {
        var fieldValidations = [FieldValidation]()
        var isValid = true
        for field in document.fields {
            if !DocumentEngine.shouldShowItem(fields: document.fields, logic: field.logic,isItemHidden: field.hidden) {
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

public enum ValidationStatus: String {
    case valid
    case invalid
}

public struct Validation {
    public let status: ValidationStatus
    public let fieldValidations: [FieldValidation]
}

public struct FieldValidation {
    public let field: JoyDocField
    public let status: ValidationStatus
}
