//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

class DocumentEngine {

    func shouldShowItem(fields: [JoyDocField], logic: Logic?, isItemHidden: Bool?) -> Bool {
        guard let logic = logic else { return !(isItemHidden ?? false) }
        
        if let hidden = isItemHidden {
            //Hidden is not nil
            if hidden && logic.action == "show" {
                //Hidden is true and action is show
                return self.shoulTakeActionOnThisField(fields: fields, logic: logic)
            } else if !hidden && logic.action == "show" {
                //Hidden is false and action is show
                return true
            } else if hidden && logic.action != "show" {
                //Hidden is true and action is hide
                return false
            } else {
                return !self.shoulTakeActionOnThisField(fields: fields, logic: logic)
            }
        } else {
            //Hidden is nil
            if logic.action == "show" {
                return true
            } else {
                return !self.shoulTakeActionOnThisField(fields: fields, logic: logic)
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
    
    
    func shoulTakeActionOnThisField(fields: [JoyDocField], logic: Logic) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }
        
        var conditionsResults: [Bool] = []
        
        for condition in conditions {
            guard let fieldID = condition.field else { continue }
            let field = getField(fields: fields, fieldID: fieldID)
            
            let isValueMatching = compareValue(fieldValue: field?.value, condition: condition)
            conditionsResults.append(isValueMatching)
        }
        
        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else {
            return conditionsResults.contains { $0 }
        }
        
    }
    
    private func getField(fields: [JoyDocField], fieldID: String) -> JoyDocField? {
        guard let field = fields.first(where: { $0.id == fieldID }) else {
            return nil
        }
        return field
    }
}
