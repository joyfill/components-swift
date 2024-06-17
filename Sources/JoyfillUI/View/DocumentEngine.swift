//
//  File.swift
//  
//

import Foundation
import JoyfillModel
import SwiftUI
struct ConditionalLogicData: Codable {
    let logic: Logic
}

struct Logic: Codable {
    let action: String
    let eval: String
    let conditions: [Condition]
}

struct Condition: Codable {
    let field: String
    let value: String
    let condition: String
}

class DocumentEngine {
    var json = """
                 {
                 "logic": {
                   "action": "hide",
                   "eval": "and",
                   "conditions": [
                                    {
                                        "field": "6669447405cd60da9dd34c5a",
                                        "value": "show",
                                        "condition": "="
                                    },
                                    {
                                        "field": "66694489b664fbc6e038f3ed",
                                        "value": "Hello",
                                        "condition": "="
                                    }
                   ]
                 }
                 }
                 """
    
    func conditionalLogic(document: Binding<JoyDoc>) {
        guard let logicData = parseConditionalLogicJSON(json) else {
            return
        }
        
        let condition = evaluateConditions(document: document.wrappedValue, logic: logicData)
        
        for i in 0..<(document.wrappedValue.pages?[0].fieldPositions?.count ?? 0) {
            if let logicField = logicData.logic.conditions.first(where: { $0.field == document.wrappedValue.pages?[0].fieldPositions?[i].field }) {
                if condition {
                    if logicData.logic.action == "show" {
                        
                        if document.wrappedValue.pages?[0].fieldPositions?[i].isHidden == nil,document.wrappedValue.pages?[0].fieldPositions?[i].isHidden == false {
                            return
                        }else {
//                            document.wrappedValue.fields[i].isHidden = false
                            document.wrappedValue.pages?[0].fieldPositions?[i].isHidden = false
                        }
                    } else if logicData.logic.action == "hide" {
                        if document.wrappedValue.pages?[0].fieldPositions?[i].isHidden == nil,document.wrappedValue.pages?[0].fieldPositions?[i].isHidden == true {
                            return
                        }else {
//                            document.wrappedValue.fields[i].isHidden = true
                            document.wrappedValue.pages?[0].fieldPositions?[i].isHidden = true
                        }
                        print("heloooo\(document.wrappedValue.pages?[0].fieldPositions?[i].isHidden)")
                        
                    }
                }
            }
        }
    }
    
    func parseConditionalLogicJSON(_ jsonString: String) -> ConditionalLogicData? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let logicData = try JSONDecoder().decode(ConditionalLogicData.self, from: data)
            return logicData
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
    
    func evaluateCondition(fieldValue: String, condition: Condition) -> Bool {
        switch condition.condition {
        case "=":
            return fieldValue == condition.value
        case "!=":
            return fieldValue != condition.value
        case "?=":
            return fieldValue.contains(condition.value)
        default:
            return false
        }
    }

    func evaluateConditions(document: JoyDoc, logic: ConditionalLogicData) -> Bool {
        let conditionsResults = logic.logic.conditions.map { condition -> Bool in
            guard let field = document.fields.first(where: { $0.id == condition.field }) else {
                return false
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
            
            return evaluateCondition(fieldValue: fieldValue, condition: condition)
        }
        
        if logic.logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else if logic.logic.eval == "or" {
            return conditionsResults.contains { $0 }
        } else {
            return false
        }
    }
}

