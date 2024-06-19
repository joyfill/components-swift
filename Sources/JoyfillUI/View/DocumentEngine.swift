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
                let condition = evaluateConditions(fields: document.wrappedValue.fields, logic: logic)
                if logic.action == "hide" {
                    document.wrappedValue.fields[i].hidden = condition
                } else if logic.action == "show" {
                    document.wrappedValue.fields[i].hidden = !condition
                }
            }
        }
    }
    func evaluateCondition(fieldValue: String, condition: Condition) -> Bool {
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
    func evaluateConditions(fields: [JoyDocField], logic: Logic) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }
        var conditionsResults: [Bool] = []
        
        for condition in conditions {
            guard let field = fields.first(where: { $0.id == condition.field }) else {
                conditionsResults.append(false)
                continue
            }
            
            let fieldValue: String
            switch field.value {
            case .string(let value):
                fieldValue = value
            case .none:
                fieldValue = ""
            case .double(let value):
                fieldValue = ""
            case .array(_):
                fieldValue = ""
            case .valueElementArray(_):
                fieldValue = ""
            case .dictionary(_):
                fieldValue = ""
            case .bool(let bool):
                fieldValue = ""
            case .null:
                fieldValue = ""
            }
            
            let conditionMet = evaluateCondition(fieldValue: fieldValue, condition: condition)
            conditionsResults.append(conditionMet)
        }
        
        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else if logic.eval == "or" {
            return conditionsResults.contains { $0 }
        } else {
            return false
        }
    }
}

