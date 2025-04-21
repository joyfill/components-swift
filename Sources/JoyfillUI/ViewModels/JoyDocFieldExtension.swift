import Foundation
import JoyfillModel

/// Extension to JoyDocField providing helper methods for handling formulas
extension JoyDocField {
    /// The formula expression associated with this field
    public var formula: String? {
        get {
            return dictionary["formula"] as? String
        }
        set {
            var newDict = dictionary
            newDict["formula"] = newValue
            dictionary = newDict
        }
    }
    
    /// Creates a field configured to hold a formula and its pre-calculated value
    /// - Parameters:
    ///   - identifier: The field identifier
    ///   - formula: The formula expression
    ///   - value: The pre-calculated value
    ///   - fieldType: The field type
    /// - Returns: A configured JoyDocField
    public static func createFormulaField(identifier: String, formula: String, value: Any, fieldType: JoyfillModel.FieldTypes) -> JoyDocField {
        var field = JoyDocField(field: [:])
        field.identifier = identifier
        field.fieldType = fieldType
        field.value = ValueUnion(value: value)!
        field.formula = formula
        return field
    }
    
    /// Creates a string formula field
    /// - Parameters:
    ///   - identifier: The field identifier
    ///   - formula: The formula expression
    ///   - value: The pre-calculated string value
    /// - Returns: A configured JoyDocField of text type
    public static func createStringFormulaField(identifier: String, formula: String, value: String) -> JoyDocField {
        return createFormulaField(identifier: identifier, formula: formula, value: value, fieldType: JoyfillModel.FieldTypes.text)
    }
    
    /// Creates a number formula field
    /// - Parameters:
    ///   - identifier: The field identifier
    ///   - formula: The formula expression
    ///   - value: The pre-calculated numeric value
    /// - Returns: A configured JoyDocField of number type
    public static func createNumberFormulaField(identifier: String, formula: String, value: Double) -> JoyDocField {
        return createFormulaField(identifier: identifier, formula: formula, value: value, fieldType: JoyfillModel.FieldTypes.number)
    }
    
    /// Creates a boolean formula field
    /// - Parameters:
    ///   - identifier: The field identifier
    ///   - formula: The formula expression
    ///   - value: The pre-calculated boolean value
    /// - Returns: A configured JoyDocField (uses text type since there's no direct boolean type)
    public static func createBooleanFormulaField(identifier: String, formula: String, value: Bool) -> JoyDocField {
        return createFormulaField(identifier: identifier, formula: formula, value: value, fieldType: JoyfillModel.FieldTypes.text)
    }
} 
