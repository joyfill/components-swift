//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 05/12/24.
//

import JoyfillModel

extension DocumentEditor {
    func shouldShow(page: Page?) -> Bool {
        guard let page = page else { return true }
        let model = conditionalLogicModel(page: page)
        return shouldShowItem(model: model)
    }

    private func conditionalLogicModel(page: Page?) -> ConditionalLogicModel? {
        guard let page = page else { return nil }
        guard let logic = page.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition ->  ConditionModel? in
            guard let fieldID = condition.field else { return nil }
            guard let field = fieldMap[condition.field!] else { return nil }
            guard let conditionFieldID = condition.field else { return nil }
            let conditionField = fieldMap[conditionFieldID]!
            return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
        }
        let logicModel = LogicModel(id: logic.id, action: logic.action, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: page.hidden, itemCount: document.pagesForCurrentView.count)
        return conditionModel
    }

    private func conditionalLogicModel(field: JoyDocField?) -> ConditionalLogicModel? {
        guard let field = field else { return nil }
        guard let logic = field.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition -> ConditionModel?  in
            guard let fieldID = condition.field else { return nil }
            let dependentField = fieldMap[fieldID]!
            var allDependentFields = fieldConditionalDependencyMap[dependentField.id!] ?? []
            if !allDependentFields.contains(dependentField.id!) {
                fieldConditionalDependencyMap[dependentField.id!] = allDependentFields + [field.id!]
            }
            return ConditionModel(fieldValue: dependentField.value, fieldType: FieldTypes(dependentField.type), condition: condition.condition, value: condition.value)
        }

        let logicModel = LogicModel(id: field.logic?.id, action: logic.action, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: field.hidden, itemCount: fieldMap.count)
        return conditionModel
    }

    private func conditionalLogicModels() -> [ConditionalLogicModel] {
        let fields = document.fields
        return fields.flatMap(conditionalLogicModel)
    }

    private func shouldShowItem(model: ConditionalLogicModel?) -> Bool {
        guard let model = model else {
            return true
        }
        guard model.itemCount > 1 else {
            return true
        }
        guard let logic = model.logic else { return !(model.isItemHidden ?? false) }

        if let hidden = model.isItemHidden {
            //Hidden is not nil
            if hidden && logic.action == "show" {
                //Hidden is true and action is show
                return self.shoulTakeActionOnThisField(logic: logic)
            } else if !hidden && logic.action == "show" {
                //Hidden is false and action is show
                return true
            } else if hidden && logic.action != "show" {
                //Hidden is true and action is hide
                return false
            } else {
                return !self.shoulTakeActionOnThisField(logic: logic)
            }
        } else {
            //Hidden is nil
            if logic.action == "show" {
                return true
            } else {
                return !self.shoulTakeActionOnThisField(logic: logic)
            }
        }
    }

    private func compareValue(fieldValue: ValueUnion?, condition: ConditionModel, fieldType: FieldTypes) -> Bool {
        switch condition.condition {
        case "=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String],
                   let conditionText = condition.value?.text {
                    return selectedArray.contains { $0 == conditionText }
                }
            }
            return fieldValue == condition.value
        case "!=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String],
                   let conditionText = condition.value?.text {
                    return !selectedArray.contains { $0 == conditionText }
                }
            }
            return fieldValue != condition.value
        case "?=":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueText = fieldValue.text, let conditionValueText = condition.value?.text {
                return fieldValueText.contains(conditionValueText)
            } else {
                return false
            }
        case ">":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber > conditionValueNumber
            } else {
                return false
            }
        case "<":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber < conditionValueNumber
            } else {
                return false
            }
        case "null=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String] {
                    return selectedArray.isEmpty || selectedArray.allSatisfy { $0.isEmpty }
                }
            }
            if let fieldValueText = fieldValue?.text {
                return fieldValueText.isEmpty
            } else if fieldValue?.number == nil {
                return true
            } else {
                return false
            }
        case "*=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String] {
                    return !(selectedArray.isEmpty || selectedArray.allSatisfy { $0.isEmpty })
                }
            }
            if let fieldValueText = fieldValue?.text {
                return !fieldValueText.isEmpty
            } else if fieldValue?.number == nil{
                return false
            } else {
                return true
            }

        default:
            return false
        }
    }

    private func shoulTakeActionOnThisField(logic: LogicModel) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }

        var conditionsResults: [Bool] = []

        for condition in conditions {
            let isValueMatching = compareValue(fieldValue: condition.fieldValue, condition: condition, fieldType: condition.fieldType)
            conditionsResults.append(isValueMatching)
        }

        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else {
            return conditionsResults.contains { $0 }
        }
    }

    func shouldShowLocal(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        let model = conditionalLogicModel(field: fieldMap[fieldID])
        return shouldShowItem(model: model)
    }
}
