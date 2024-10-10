//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI

public class DocumentEngine {

    public static func shouldShowItem(fields: [JoyDocField], logic: Logic?, isItemHidden: Bool?) -> Bool {
        guard fields.count > 1 else {
            return true
        }
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
            
    public static func compareValue(fieldValue: ValueUnion?, condition: Condition, fieldType: FieldTypes) -> Bool {
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

   public enum ReusltType {
        case hide
        case show
        case ignore
    }
    
    
    public static func shoulTakeActionOnThisField(fields: [JoyDocField], logic: Logic) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }
        
        var conditionsResults: [Bool] = []
        
        for condition in conditions {
            guard let fieldID = condition.field else { continue }
            guard let field = getField(fields: fields, fieldID: fieldID) else { continue }
            
            let isValueMatching = compareValue(fieldValue: field.value, condition: condition, fieldType: field.fieldType)
            conditionsResults.append(isValueMatching)
        }
        
        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else {
            return conditionsResults.contains { $0 }
        }
        
    }
    
    public static func getField(fields: [JoyDocField], fieldID: String) -> JoyDocField? {
        guard let field = fields.first(where: { $0.id == fieldID }) else {
            return nil
        }
        return field
    }
}
