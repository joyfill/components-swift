//
//  JoyDoc+helper.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 22/04/25.
//
import JoyfillModel
import Foundation


extension JoyDoc {

    static func addDocument() -> JoyDoc {
        return JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
    }
    
    // MARK: - Generic Field Creation
    
    /// Adds a field of specified type to the document
    func addField(type: FieldTypes, 
                  identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                  formula: String? = nil,
                  id: String = UUID().uuidString, 
                  value: ValueUnion) -> JoyDoc {
        return self
            .setFieldData(type: type, identifier: identifier, formula: formula, id: id, value: value)
            .setFieldPosition(type: type, id: id)
    }
    
    /// Sets field data for any field type
    func setFieldData(type: FieldTypes,
                     identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                     formula: String? = nil,
                     id: String = UUID().uuidString,
                     value: ValueUnion) -> JoyDoc {
        var field = JoyDocField()
        field.type = type.rawValue
        field.id = id
        field.identifier = identifier
        field.title = identifier
        field.description = ""
        field.value = value
        field.required = false
        field.tipTitle = ""
        field.formula = formula
        field.tipDescription = ""
        field.tipVisible = false
        field.file = "6629fab3c0ba3fb775b4a55c"
        
        var document = self
        document.fields.append(field)
        return document
    }
    
    /// Sets field position for any field type
    func setFieldPosition(type: FieldTypes,
                        id: String,
                        x: Double = 0,
                        y: Double = 63,
                        width: Double = 12,
                        height: Double = 8) -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = id
        fieldPosition.displayType = "original"
        fieldPosition.width = width
        fieldPosition.height = height
        fieldPosition.x = x
        fieldPosition.y = y
        fieldPosition.id = UUID().uuidString
        fieldPosition.type = type
        
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }
    
    // MARK: - Convenience Methods
    
    /// Adds a number field to the document
    func addNumberField(identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                      formula: String? = nil, 
                      id: String = UUID().uuidString, 
                      value: Double = 98789) -> JoyDoc {
        return addField(type: .number, 
                       identifier: identifier, 
                       formula: formula, 
                       id: id, 
                       value: .double(value))
    }
    
    /// Adds a text field to the document
    func addTextField(identifier: String = "field_6629fb3fabb87e37c9578b8b", 
                    formula: String? = nil, 
                    id: String = UUID().uuidString, 
                    value: String = "Sample Text") -> JoyDoc {
        return addField(type: .text, 
                       identifier: identifier, 
                       formula: formula, 
                       id: id, 
                       value: .string(value))
    }
    
    /// Adds a date field to the document
    func addDateField(identifier: String = "field_6629fb3fabb87e37c9578b8b",
                    formula: String? = nil,
                    id: String = UUID().uuidString,
                    date: Date = Date()) -> JoyDoc {
        // Convert Date to timestamp (milliseconds since epoch)
        let timestamp = date.timeIntervalSince1970 * 1000
        
        return addField(type: .date,
                       identifier: identifier,
                       formula: formula,
                       id: id,
                       value: .double(timestamp))
    }

}
