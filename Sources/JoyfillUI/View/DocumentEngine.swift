//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

class DocumentEngine {

    func conditionalLogic(document: Binding<JoyDoc>) {
        // Conditions on items associated with deleted or non-existent fields will should be ignored.
        for i in 0..<document.wrappedValue.fields.count {
            if var logic = document.wrappedValue.fields[i].logic {
                let result = shoulTakeActionOnThisField(fields: document.wrappedValue.fields, logic: logic,currentField: document.wrappedValue.fields[i])
                switch result {
                case .hide:
                    var fields = document.wrappedValue.fields
                    if let hidden = fields[i].hidden, hidden {
                        return
                    }
                    fields[i].hidden = fields[i].isHidden
                    fields[i].isHidden = false
                    document.wrappedValue.fields = fields
                case .show:
                    var fields = document.wrappedValue.fields
                    if let hidden = fields[i].hidden, !hidden {
                        return
                    }
                    fields[i].hidden = fields[i].isHidden
                    fields[i].isHidden = true
                    document.wrappedValue.fields = fields
                case .ignore:
                    return
                }
            }
        }
    }
    func compareValue(fieldValue: ValueUnion?, condition: Condition) -> Bool {
        switch condition.condition {
        case "=":
            return fieldValue == condition.value
        case "!=":
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
            if let fieldValueText = fieldValue?.text {
                return fieldValueText.isEmpty
            } else if fieldValue?.number == nil{
                return true
            } else {
                return false
            }
        case "*=":
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

    enum ReusltType {
        case hide
        case show
        case ignore
    }

    func shoulHideThisField(fields: [JoyDocField], logic: Logic, currentField: JoyDocField) -> Bool {
        guard logic.action == "hide" else {
            return false
        }
        var conditionsResults: [Bool] = []
        for condition in logic.conditions! {
            guard let fieldID = condition.field else { continue }
            let field = getField(fields: fields, fieldID: fieldID)

            let isValueMatching = compareValue(fieldValue: field?.value, condition: condition)
            conditionsResults.append(isValueMatching)
        }

        if logic.isValid(conditionsResults: conditionsResults) {
            return true
        }
        return false
    }


    func shoulShowThisField(fields: [JoyDocField], logic: Logic, currentField: JoyDocField) -> Bool {
        guard logic.action == "show" else {
            return false
        }
        var conditionsResults: [Bool] = []
        for condition in logic.conditions! {
            guard let fieldID = condition.field else { continue }
            let field = getField(fields: fields, fieldID: fieldID)

            let isValueMatching = compareValue(fieldValue: field?.value, condition: condition)
            conditionsResults.append(isValueMatching)
        }

        if logic.isValid(conditionsResults: conditionsResults) {
            return true
        }
        return false
    }
    
    
    func shoulTakeActionOnThisField(fields: [JoyDocField], logic: Logic,currentField: JoyDocField?) -> ReusltType {
        guard let conditions = logic.conditions else {
            return .ignore
        }
        
        var conditionsResults: [Bool] = []
        
        for condition in conditions {
            guard let fieldID = condition.field else { continue }
            let field = getField(fields: fields, fieldID: fieldID)
            
            let isValueMatching = compareValue(fieldValue: field?.value, condition: condition)
            conditionsResults.append(isValueMatching)
        }
        
        if logic.eval == "and" {
            if conditionsResults.allSatisfy { $0 } {
                if logic.action == "hide" {
                    return .hide
                } else if logic.action == "show" {
                    return .show
                } else {
                    return .ignore
                }
            } else {
                if logic.action == "hide" {
                    guard let hidden =  currentField?.isHidden else {
                        return .ignore
                    }
                    if hidden {
                        return .ignore
                    } else {
                        return .show
                    }
                } else if logic.action == "show" {
                    guard let hidden = currentField?.isHidden else {
                        return .ignore
                    }

                    if hidden {
                        return .hide
                    } else {
                        return .ignore
                    }
                } else {
                    return .ignore
                }
            }
        } else if logic.eval == "or" {
            if conditionsResults.contains { $0 } {
                if logic.action == "hide" {
                    return .hide
                } else if logic.action == "show" {
                    return .show
                } else {
                    return .ignore
                }
            } else {
                if logic.action == "hide" {
                    guard let hidden =  currentField?.isHidden else {
                        return .ignore
                    }

                    if hidden {
                        return .show
                    } else {
                        return .ignore
                    }
                } else if logic.action == "show" {
                    guard let hidden =  currentField?.isHidden else {
                        return .ignore
                    }

                    if hidden {
                        return .hide
                    } else {
                        return .ignore
                    }
                } else {
                    return .ignore
                }
            }
        } else {
            return .ignore
        }
    }


//    func shoulTakeActionOnThisField(fields: [JoyDocField], logic: Logic, currentField: JoyDocField) -> ReusltType {
//        guard fields.count > 1 else {
//            return .ignore
//        }
//
//        guard let conditions = logic.conditions else {
//            return .ignore
//        }
//
//        // should hide
//        guard let hidden = currentField.hidden else {
//            if shoulHideThisField(fields: fields, logic: logic, currentField: currentField) {
//                return .hide
//            }
//            return .ignore
//        }
//
//        if hidden {
//            if shoulShowThisField(fields: fields, logic: logic, currentField: currentField) {
//                return .show
//            }
//        } else {
//            if shoulHideThisField(fields: fields, logic: logic, currentField: currentField) {
//                return .hide
//            }
//        }
//        return .ignore
//    }
    
    private func getField(fields: [JoyDocField], fieldID: String) -> JoyDocField? {
        guard let field = fields.first(where: { $0.id == fieldID }) else {
            return nil
        }
        return field
    }
}