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

    func addNumberField(identifier: String = "field_6629fb3fabb87e37c9578b8b", formula: String? = nil, id: String = UUID().uuidString, value: Double = 98789) -> JoyDoc {
        return self
            .setNumberFieldData(identifier: identifier, formula: formula, id: id, value: .double(value))
        .setNumberPosition(id: id)
    }

    func setNumberFieldData(identifier: String = "field_6629fb3fabb87e37c9578b8b", formula: String? = nil, id: String = "6629fb3df03de10b26270ab3", value: ValueUnion = .double(98789)) -> JoyDoc {
        var field = JoyDocField()
        field.type = "number"
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

    func setNumberPosition(id: String = "6629fb3df03de10b26270ab3") -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = id
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 63
        fieldPosition.id = "6629fb3f2eff74a9ca322bb5"
        fieldPosition.type = .number
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }

    /// Adds a text field to the document.
    func addTextField(identifier: String = "field_6629fb3fabb87e37c9578b8b", formula: String? = nil, id: String = UUID().uuidString, value: String = "Sample Text") -> JoyDoc {
        return self
            .setTextFieldData(identifier: identifier, formula: formula, id: id, value: .string(value))
            .setTextPosition(id: id)
    }

    /// Configures the data for a text field.
    func setTextFieldData(identifier: String = "field_6629fb3fabb87e37c9578b8b", formula: String? = nil, id: String = "6629fb3df03de10b26270ab3", value: ValueUnion = .string("Sample Text")) -> JoyDoc {
        var field = JoyDocField()
        field.type = "text"
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

    /// Configures the position for a text field.
    func setTextPosition(id: String = "6629fb3df03de10b26270ab3") -> JoyDoc {
        var fieldPosition = FieldPosition()
        fieldPosition.field = id
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 63
        fieldPosition.id = "6629fb3f2eff74a9ca322bb5"
        fieldPosition.type = .text
        var document = self
        document.files[0].pages?[0].fieldPositions?.append(fieldPosition)
        return document
    }

}
