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
    public let columnId: String?
    public let value: ValueUnion?

    public init(status: ValidationStatus, columnId: String? = nil, value: ValueUnion? = nil) {
        self.status = status
        self.columnId = columnId
        self.value = value
    }
}

public struct RowValidity {
    public let status: ValidationStatus
    public let rowId: String?
    public let cellValidities: [CellValidity]
    public let schemaId: String?

    public init(status: ValidationStatus, cellValidities: [CellValidity], rowId: String? = nil, schemaId: String? = nil) {
        self.status = status
        self.rowId = rowId
        self.cellValidities = cellValidities
        self.schemaId = schemaId
    }
}

public struct FieldValidity {
    public let status: ValidationStatus
    public let fieldId: String?
    public let pageId: String?
    public let fieldPositionId: String?
    public let field: JoyDocField
    public let rowValidities: [RowValidity]?
    
    public init(field: JoyDocField, status: ValidationStatus, pageId: String?, fieldId: String? = nil, fieldPositionId: String? = nil, rowValidities: [RowValidity]? = nil) {
        self.fieldId = fieldId
        self.field = field
        self.status = status
        self.pageId = pageId
        self.fieldPositionId = fieldPositionId
        self.rowValidities = rowValidities
    }
}
