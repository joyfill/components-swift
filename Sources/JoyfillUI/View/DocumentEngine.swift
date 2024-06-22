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
    func compareValue(fieldValue: String, condition: Condition) -> Bool {
        switch condition.condition {
        case "=":
            return fieldValue == condition.value
        case "!=":
            return fieldValue != condition.value
        case "?=":
            return fieldValue.contains(condition.value ?? "")
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
    
    private func getFieldValue(fields: [JoyDocField], fieldID: String) -> String? {
        guard let field = fields.first(where: { $0.id == fieldID }) else {
            return nil
        }
        
        let fieldValue: String?
        switch field.value {
        case .string(let value):
            fieldValue = value
        case .none:
            fieldValue = nil
        case .double(let value):
            fieldValue = nil
        case .array(_):
            fieldValue = nil
        case .valueElementArray(_):
            fieldValue = nil
        case .dictionary(_):
            fieldValue = nil
        case .bool(let bool):
            fieldValue = nil
        case .null:
            fieldValue = nil
        }
        return fieldValue
    }
}

