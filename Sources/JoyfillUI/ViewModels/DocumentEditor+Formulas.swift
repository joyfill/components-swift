//
//  DocumentEditor+Formulas.swift
//  Joyfill
//
//  Created by Vishnu Dutt on 21/04/25.
//
import JoyfillModel

extension DocumentEditor: JoyDocProvider {
    func formula(with id: String) -> JoyfillModel.Formula? {
        document.formulas.first { $0.id == id }
    }

    func allFormulsFields() -> [JoyfillModel.JoyDocField] {
        allFields.filter { $0.formulas != nil }
    }

    func setFieldHidden(_ hidden: Bool, for identifier: String) {
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        conditionalLogicHandler.showFieldMap[field.id!] = hidden
        refreshField(fieldId: field.id!)
    }

    func updateValue(for identifier: String, value: JoyfillModel.ValueUnion) {
        updateValue(for: identifier, value: value, shouldCallOnChange: true)
    }
    
    func updateValue(for identifier: String, value: JoyfillModel.ValueUnion, shouldCallOnChange: Bool) {
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        guard let fieldID = field.id else { return }
        field.value = value
        fieldMap[fieldID] = field
        refreshField(fieldId: fieldID)
        refreshDependent(for: fieldID)
        
        if shouldCallOnChange {
            handleFieldsOnChange(fieldIdentifier: getFieldIdentifier(for: fieldID), currentField: field)
        }
    }
}
