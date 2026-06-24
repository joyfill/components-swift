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

    public func updateValue(for identifier: String, value: JoyfillModel.ValueUnion) {
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        var value = value
        if field.fieldType == .dropdown {
            if let optionID = field.options?.first(where: { $0.value == value.text })?.id {
                value = .string(optionID)
            }
        }
        if field.fieldType == .multiSelect {
            if let multiselectValues = value.multiSelector {
                var optionIDs: [String] = []
                for value in multiselectValues {
                    if let optionID = field.options?.first(where: { $0.value == value })?.id {
                        optionIDs.append(optionID)
                    }
                }
                if !optionIDs.isEmpty {
                    value = .array(optionIDs)
                }
            }
        }
        updateValue(for: identifier, value: value, shouldCallOnChange: true)
    }
    
    func updateValue(for identifier: String, value: JoyfillModel.ValueUnion? = nil, shouldCallOnChange: Bool, chartData: ChartData? = nil) {
        guard var field = allFields.first(where: { $0.id == identifier }) else {
            return
        }
        guard let fieldID = field.id else { return }
        if let value = value {
            field.value = value
        }
        if let chartData = chartData {
            if let v = chartData.xTitle { field.xTitle = v }
            if let v = chartData.yTitle { field.yTitle = v }
            if let v = chartData.xMin   { field.xMin   = v }
            if let v = chartData.xMax   { field.xMax   = v }
            if let v = chartData.yMin   { field.yMin   = v }
            if let v = chartData.yMax   { field.yMax   = v }
        }
        fieldMap[fieldID] = field
        refreshField(fieldId: fieldID)
        refreshDependent(for: fieldID)
        
        if shouldCallOnChange {
            handleFieldsOnChange(fieldIdentifier: getFieldIdentifier(for: fieldID), currentField: field)
        }

        if joyDocContext != nil {
            self.joyDocContext.updateDependentFormulas(forFieldIdentifier: identifier)
        }
    }
}
