//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 14/07/24.
//

import Foundation

/// Outcome for a validation target.
public enum ValidationStatus: String {
    /// Value satisfied the validation rules.
    case valid
    /// Value failed at least one validation rule.
    case invalid
}

/// High-level validation result returned by `DocumentEditor.validate()`.
public struct Validation {
    /// Overall status across all validated fields.
    public let status: ValidationStatus
    /// Per-field validation details.
    public let fieldValidities: [FieldValidity]

    public init(status: ValidationStatus, fieldValidities: [FieldValidity]) {
        self.status = status
        self.fieldValidities = fieldValidities
    }
}

/// Validation output for a single table cell.
public struct CellValidity {
    /// Status for the cell.
    public let status: ValidationStatus
    /// Row that contains the cell.
    public let row: ValueElement
    /// Column metadata describing the cell.
    public let column: FieldTableColumn
    /// Optional reasons describing why a cell is invalid.
    public let reasons: [String]?
    
    public init(status: ValidationStatus, row: ValueElement, column: FieldTableColumn, reasons: [String]? = nil) {
        self.status = status
        self.row = row
        self.column = column
        self.reasons = reasons
    }
}

/// Aggregated validation output for a table row.
public struct RowValidity {
    /// Status for the row.
    public let status: ValidationStatus
    /// Validation result for each cell in the row.
    public let cellValidities: [CellValidity]
    
    public init(status: ValidationStatus, cellValidities: [CellValidity]) {
        self.status = status
        self.cellValidities = cellValidities
    }
}

/// Aggregated validation output for a table column.
public struct ColumnValidity {
    /// Status for the column.
    public let status: ValidationStatus
    /// Validation result for each cell that participates in the column.
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

/// Validation output for an individual field, optionally including nested results.
public struct FieldValidity {
    /// Status assigned to the field.
    public let status: ValidationStatus
    /// The field that was evaluated.
    public let field: JoyDocField
    /// Validation results for nested children (collections).
    public let children: [FieldValidity]? // For fields with nested structures
    /// Table row results (only populated for table or collection fields).
    public let rowValidities: [RowValidity]? // Only available if field is a table
    /// Table column results (only populated for table or collection fields).
    public let columnValidities: [ColumnValidity]? // Only available if field is a table
    /// Optional reasons explaining the invalid state.
    public let reasons: [String]? // Available only if status is invalid
    
    public init(field: JoyDocField, status: ValidationStatus, children: [FieldValidity]? = nil, rowValidities: [RowValidity]? = nil, columnValidities: [ColumnValidity]? = nil, reasons: [String]? = nil) {
        self.field = field
        self.status = status
        self.children = children
        self.rowValidities = rowValidities
        self.columnValidities = columnValidities
        self.reasons = reasons
    }
}
