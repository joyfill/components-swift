//
//  DocumentEditor+Formulas.swift
//  Joyfill
//
//  Created by Vishnu Dutt on 21/04/25.
//
import JoyfillModel

extension DocumentEditor: JoyDocProvider {
    func currentFieldIdentifier() -> String? {
        nil
    }

    func formula(with id: String) -> JoyfillModel.Formula? {
        document.formulas.first { $0.id == id }
    }

    func allFormulsFields() -> [JoyfillModel.JoyDocField] {
        allFields.filter { $0.formulas != nil }
    }

    func setFieldHidden(_ hidden: Bool, for identifier: String) {
        print("setFieldHidden >>>>>", hidden, identifier)
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        conditionalLogicHandler.showFieldMap[field.id!] = hidden
        refreshField(fieldId: field.id!)
    }

    func updateValue(for identifier: String, value: JoyfillModel.ValueUnion) {
        print("updateValue called >>>>>>>", value)
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        guard let fieldID = field.id else { return }
        field.value = value
        fieldMap[fieldID] = field
        refreshField(fieldId: fieldID)
        refreshDependent(for: fieldID)
        // TODO: Neet to add pageid and cleanup here
        handleFieldsOnChange(fieldIdentifier: FieldIdentifier(fieldID: field.id!, pageID: "", fileID: document.files.first?.id), currentField: field)
    }
}
