//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

class DocumentEngine {
    
    func conditionalLogic(document: Binding<JoyDoc>) {
        for i in 0..<document.wrappedValue.fields.count {
            if let logic = document.wrappedValue.fields[i].logic {
                guard shoulTakeActionOnThisField(fields: document.wrappedValue.fields, logic: logic) else {
                    if document.wrappedValue.fields[i].hidden {
                        document.wrappedValue.fields[i].hidden = false
                    }
                    return 
                }
                
                if logic.action == "hide" {
                    if !document.wrappedValue.fields[i].hidden {
                        document.wrappedValue.fields[i].hidden = true
                    }
                } else if logic.action == "show" {
                    if document.wrappedValue.fields[i].hidden {
                        document.wrappedValue.fields[i].hidden = false
                    }
                }
            }
        }
    }
    func compareValue(fieldValue: ValueUnion, condition: Condition) -> Bool {
        switch condition.condition {
        case "=":
            return fieldValue == condition.value
        case "!=":
            return fieldValue != condition.value
        case "?=":
            if let fieldValueText = fieldValue.text, let conditionValueText = condition.value?.text {
                return fieldValueText.contains(conditionValueText)
            } else {
                return false
            }
        case ">":
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber > conditionValueNumber
            } else {
                return false
            }
        case "<":
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber < conditionValueNumber
            } else {
                return false
            }
        case "null=":
            if let fieldValueText = fieldValue.text {
                return fieldValueText.isEmpty
            } else if fieldValue.number == nil{
                return true
            } else {
                return false
            }
        case "*=":
            if let fieldValueText = fieldValue.text {
                return !fieldValueText.isEmpty
            } else if fieldValue.number == nil{
                return false
            } else {
                return true
            }
            
        default:
            return false
        }
    }
    func shoulTakeActionOnThisField(fields: [JoyDocField], logic: Logic) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }
        
        var conditionsResults: [Bool] = []
        
        for condition in conditions {
            guard let fieldID = condition.field else { continue }
            guard let value = getFieldValue(fields: fields, fieldID: fieldID) else
            { continue }
            let isValueMatching = compareValue(fieldValue: value, condition: condition)
            conditionsResults.append(isValueMatching)
        }
        
        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else if logic.eval == "or" {
            return conditionsResults.contains { $0 }
        } else {
            return false
        }
    }
    
    private func getFieldValue(fields: [JoyDocField], fieldID: String) -> ValueUnion? {
        guard let field = fields.first(where: { $0.id == fieldID }) else {
            return nil
        }
        return field.value
    }
}

