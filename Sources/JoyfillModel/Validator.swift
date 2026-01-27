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
    public let row: ValueElement
    public let column: FieldTableColumn
    public let reasons: [String]?
    
    public init(status: ValidationStatus, row: ValueElement, column: FieldTableColumn, reasons: [String]? = nil) {
        self.status = status
        self.row = row
        self.column = column
        self.reasons = reasons
    }
}

public struct RowValidity {
    public let status: ValidationStatus
    public let cellValidities: [CellValidity]
    
    public init(status: ValidationStatus, cellValidities: [CellValidity]) {
        self.status = status
        self.cellValidities = cellValidities
    }
}

public struct ColumnValidity {
    public let status: ValidationStatus
    public let cellValidities: [CellValidity]
    
    public init(status: ValidationStatus, cellValidities: [CellValidity]) {
        self.status = status
        self.cellValidities = cellValidities
    }
}

struct TableValidity {
    let status: ValidationStatus
    let rowValidities: [RowValidity]
    let columnValidities: [ColumnValidity]
}

public struct FieldValidity {
    public let status: ValidationStatus
    public let pageId: String?
    public let fieldPositionId: String?
    public let field: JoyDocField
//    public let children: [FieldValidity]? // For fields with nested structures
//    public let rowValidities: [RowValidity]? // Only available if field is a table
//    public let columnValidities: [ColumnValidity]? // Only available if field is a table
//    public let reasons: [String]? // Available only if status is invalid
    
    public init(field: JoyDocField, status: ValidationStatus, pageId: String?, fieldPositionId: String? = nil) {
        self.field = field
        self.status = status
//        self.children = children
//        self.rowValidities = rowValidities
//        self.columnValidities = columnValidities
//        self.reasons = reasons
        self.pageId = pageId
        self.fieldPositionId = fieldPositionId
    }
}
