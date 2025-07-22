import Foundation
import JoyfillModel
import JoyfillFormulas

/// Extension to JoyDocField to support formula handling
extension JoyDocField {
    /// Get the formula expression stored in the field's dictionary
    var formula: String? {
        get {
            return self.dictionary["formula"] as? String
        }
        set {
            if let newValue = newValue {
                var dict = self.dictionary
                dict["formula"] = newValue
                self.dictionary = dict
            }
        }
    }
    
    /// Helper to create a formula field with proper setup
    static func createFormulaField(identifier: String, fieldType: FieldTypes, formula: String, value: Any) -> JoyDocField {
        var field = JoyDocField(field: [:])
        field.identifier = identifier
        field.fieldType = fieldType
        field.formula = formula
        field.value = ValueUnion(value: value)!
        return field
    }
    
    /// Helper to create a formula field that returns a string
    static func createStringFormulaField(identifier: String, formula: String, value: String) -> JoyDocField {
        return createFormulaField(identifier: identifier, fieldType: .text, formula: formula, value: value)
    }
    
    /// Helper to create a formula field that returns a number
    static func createNumberFormulaField(identifier: String, formula: String, value: Double) -> JoyDocField {
        return createFormulaField(identifier: identifier, fieldType: .number, formula: formula, value: value)
    }
    
    /// Helper to create a formula field that returns a boolean
    static func createBooleanFormulaField(identifier: String, formula: String, value: Bool) -> JoyDocField {
        return createFormulaField(identifier: identifier, fieldType: .text, formula: formula, value: value)
    }
} 