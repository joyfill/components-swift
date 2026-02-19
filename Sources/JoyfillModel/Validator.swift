//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 14/07/24.
//

import Foundation

public enum ValidationStatus: String {
    case valid
    case invalid
}

public struct Validation {
    public let status: ValidationStatus
    public let fieldValidities: [FieldValidity]

    public init(status: ValidationStatus, fieldValidities: [FieldValidity]) {
        self.status = status
        self.fieldValidities = fieldValidities
    }
}

public struct CellValidity {
    public let status: ValidationStatus
    public let column: FieldTableColumn
    public let value: ValueUnion?

    public init(status: ValidationStatus, column: FieldTableColumn, value: ValueUnion? = nil) {
        self.status = status
        self.column = column
        self.value = value
    }
}

public struct RowValidity {
    public let status: ValidationStatus
    public let row: ValueElement
    public let cellValidities: [CellValidity]
    public let schema: Schema?
    public let schemaId: String?

    public init(status: ValidationStatus, cellValidities: [CellValidity], row: ValueElement, schema: Schema? = nil, schemaId: String? = nil) {
        self.status = status
        self.cellValidities = cellValidities
        self.row = row
        self.schema = schema
        self.schemaId = schemaId
    }
}

public struct FieldValidity {
    public let status: ValidationStatus
    public let pageId: String?
    public let fieldPositionId: String?
    public let field: JoyDocField
    public let rowValidities: [RowValidity]?
    
    public init(field: JoyDocField, status: ValidationStatus, pageId: String?, fieldPositionId: String? = nil, rowValidities: [RowValidity]? = nil) {
        self.field = field
        self.status = status
        self.pageId = pageId
        self.fieldPositionId = fieldPositionId
        self.rowValidities = rowValidities
    }
}
