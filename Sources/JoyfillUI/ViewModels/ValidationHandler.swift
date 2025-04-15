//
//  File.swift
//
//
//  Created by Vishnu Dutt on 05/12/24.
//

import Foundation
import JoyfillModel

class ValidationHandler {
    weak var documentEditor: DocumentEditor!

    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    func validate() -> Validation {
        var fieldValidities = [FieldValidity]()
        var isValid = true
        let fieldPositionIDs = documentEditor.allFieldPositions.map {  $0.field }
        for field in documentEditor.allFields.filter { fieldPositionIDs.contains($0.id) } {
            if !documentEditor.shouldShow(fieldID: field.id) {
                fieldValidities.append(FieldValidity(field: field, status: .valid))
                continue
            }
            
            guard let required = field.required, required else {
                fieldValidities.append(FieldValidity(field: field, status: .valid))
                continue
            }
            
            if field.fieldType == .table {
                let tableFieldValidity = validateTableField(id: field.id!)
                if tableFieldValidity.status == .invalid {
                    isValid = false
                }
                fieldValidities.append(tableFieldValidity)
            } else if field.fieldType == .collection {
                let collectionFieldValidity = validateCollectionField(id: field.id!)
                if collectionFieldValidity.status == .invalid {
                    isValid = false
                }
                fieldValidities.append(collectionFieldValidity)
            } else {
                if let value = field.value, !value.isEmpty {
                    fieldValidities.append(FieldValidity(field: field, status: .valid))
                    continue
                }
                isValid = false
                fieldValidities.append(FieldValidity(field: field, status: .invalid))
            }
        }

        return Validation(status: isValid ? .valid: .invalid, fieldValidities: fieldValidities)
    }
     
    func validateTableField(id: String) -> FieldValidity {
        var fieldValidities = [FieldValidity]()
        let field = documentEditor.field(fieldID: id)
        let fieldPosition = documentEditor.fieldPosition(fieldID: id)!
        var isTableValid = true
        let rows = field?.valueToValueElements ?? []
        let columns = (field?.tableColumns ?? []).filter { column in
            let isHidden = fieldPosition.tableColumns?.first(where: { $0.id == column.id! })?.hidden ?? false
            return !isHidden
        }
        var rowValidities = [RowValidity]()
        var columnValidities = [ColumnValidity]()
        
        for row in rows {
            if row.deleted == true {
                continue
            }
            
            var cellValidities = [CellValidity]()
            guard let cells = row.cells else { continue }
            
            for (index, column) in columns.enumerated() {
                guard let columnID = column.id else { continue }
                let isRequired = column.required ?? false
                
                // Non-required columns are valid
                if !isRequired {
                    let cellValidity = CellValidity(status: .valid, row: row, column: column)
                    cellValidities.append(cellValidity)
                    continue
                }
                
                // Validate the cell value if required
                if let cellValue = cells[columnID], !cellValue.isEmpty {
                    let cellValidity = CellValidity(status: .valid, row: row, column: column)
                    cellValidities.append(cellValidity)
                } else {
                    let cellValidity = CellValidity(status: .invalid, row: row, column: column)
                    cellValidities.append(cellValidity)
                    isTableValid = false
                }
            }
            
            // Add row validity
            let rowStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities))
            
        }
        // Add column Validity
        for (index,column) in columns.enumerated() {
            var cellValidities = [CellValidity]()
            for rowValidity in rowValidities {
                cellValidities.append(rowValidity.cellValidities[index])
            }
            
            let columnStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            columnValidities.append(ColumnValidity(status: columnStatus, cellValidities: cellValidities))
        }
        
        let fieldStatus: ValidationStatus = isTableValid ? .valid : .invalid
        return FieldValidity(field: field!, status: fieldStatus, rowValidities: rowValidities, columnValidities: columnValidities)
    }

    func validateCollectionField(id: String) -> FieldValidity {
        let field = documentEditor.field(fieldID: id)!
        let schema = field.schema
        let fieldPosition = documentEditor.fieldPosition(fieldID: id)!
        var isCollectionValid = true
        let rows = field.valueToValueElements ?? []
        
        // Get root schema and its columns
        let rootSchema = schema?.first(where: { (key: String, value: Schema) in
            value.root == true
        })?.value
        let columns = rootSchema?.tableColumns ?? []
        
        var rowValidities = [RowValidity]()
        var columnValidities = [ColumnValidity]()
        
        // Filter non-deleted rows
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        
        // Validate each row
        for row in nonDeletedRows {
            var cellValidities = [CellValidity]()
            guard let cells = row.cells else { continue }
            
            // Validate each cell in the row
            for column in columns {
                guard let columnID = column.id else { continue }
                let isRequired = column.required ?? false
                
                if !isRequired {
                    let cellValidity = CellValidity(status: .valid, row: row, column: column)
                    cellValidities.append(cellValidity)
                    continue
                }
                
                if let cellValue = cells[columnID], !cellValue.isEmpty {
                    let cellValidity = CellValidity(status: .valid, row: row, column: column)
                    cellValidities.append(cellValidity)
                } else {
                    let cellValidity = CellValidity(status: .invalid, row: row, column: column)
                    cellValidities.append(cellValidity)
                    isCollectionValid = false
                }
            }
            
            // Add row validity
            let rowStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities))
        }
        
        // Validate each column
        for (index, column) in columns.enumerated() {
            var cellValidities = [CellValidity]()
            for rowValidity in rowValidities {
                cellValidities.append(rowValidity.cellValidities[index])
            }
            
            let columnStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            columnValidities.append(ColumnValidity(status: columnStatus, cellValidities: cellValidities))
        }
        
        // Validate nested schemas
        if let schema = field.schema {
            for (schemaID, schemaValue) in schema {
                if schemaValue.root == true {
                    // Check if schema is visible for each row
                    let isSchemaVisible = nonDeletedRows.allSatisfy { row in
                        documentEditor.shouldShowSchema(for: id, rowSchemaID: RowSchemaID(rowID: row.id ?? "", schemaID: schemaID))
                    }
                    
                    // If schema is visible and required, check for at least one row
                    if isSchemaVisible && schemaValue.required == true && nonDeletedRows.isEmpty {
                        isCollectionValid = false
                    }
                    
                    // Validate child schemas
                    if let children = schemaValue.children {
                        for childID in children {
                            if let childSchema = field.schema?[childID] {
                                // Check each row individually for child schema visibility and requirements
                                for row in nonDeletedRows {
                                    let isChildVisible = documentEditor.shouldShowSchema(for: id, rowSchemaID: RowSchemaID(rowID: row.id ?? "", schemaID: childID))
                                    
                                    // If child schema is visible and required, check for at least one row
                                    if isChildVisible && childSchema.required == true {
                                        let childRows = row.childrens?[childID]?.valueToValueElements ?? []
                                        if childRows.isEmpty {
                                            isCollectionValid = false
                                            break
                                        }
                                        
                                        // Recursively validate child rows and their nested schemas
                                        if !validateNestedRows(rows: childRows, schema: childSchema, fieldID: id) {
                                            isCollectionValid = false
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        let fieldStatus: ValidationStatus = isCollectionValid ? .valid : .invalid
        return FieldValidity(field: field, status: fieldStatus, rowValidities: rowValidities, columnValidities: columnValidities)
    }
    
    private func validateNestedRows(rows: [ValueElement], schema: Schema, fieldID: String) -> Bool {
        var isValid = true
        
        // Filter non-deleted rows
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        
        // Get columns from schema
        let columns = schema.tableColumns ?? []
        
        // Validate each row's cells
        for row in nonDeletedRows {
            guard let cells = row.cells else { continue }
            
            // Validate cells for current schema
            for column in columns {
                guard let columnID = column.id else { continue }
                let isRequired = column.required ?? false
                
                if !isRequired {
                    continue
                }
                
                if let cellValue = cells[columnID], !cellValue.isEmpty {
                    continue
                } else {
                    isValid = false
                    break
                }
            }
            
            if !isValid {
                break
            }
            
            // Recursively validate child schemas
            if let children = schema.children {
                for childID in children {
                    if let childSchema = documentEditor.field(fieldID: fieldID)?.schema?[childID] {
                        let isChildVisible = documentEditor.shouldShowSchema(for: fieldID, rowSchemaID: RowSchemaID(rowID: row.id ?? "", schemaID: childID))
                        
                        if isChildVisible && childSchema.required == true {
                            let childRows = row.childrens?[childID]?.valueToValueElements ?? []
                            if childRows.isEmpty {
                                isValid = false
                                break
                            }
                            
                            // Recursively validate deeper nested rows
                            if !validateNestedRows(rows: childRows, schema: childSchema, fieldID: fieldID) {
                                isValid = false
                                break
                            }
                        }
                    }
                }
            }
        }
        
        return isValid
    }

    private func validateSchema(schemaID: String, schema: Schema, rows: [ValueElement], fieldID: String) -> SchemaValidity {
        var isSchemaValid = true
        var columnValidities: [ColumnValidity] = []
        
        // Filter non-deleted rows
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        
        // Check if schema is required and has at least one row
        if schema.required == true && nonDeletedRows.isEmpty {
            isSchemaValid = false
        }
        
        // Validate each column in the schema
        if let columns = schema.tableColumns {
            for column in columns {
                var cellValidities: [CellValidity] = []
                let isRequired = column.required ?? false
                
                for row in nonDeletedRows {
                    guard let cells = row.cells,
                          let columnID = column.id else { continue }
                    
                    if !isRequired {
                        let cellValidity = CellValidity(status: .valid, row: row, column: column)
                        cellValidities.append(cellValidity)
                        continue
                    }
                    
                    if let cellValue = cells[columnID], !cellValue.isEmpty {
                        let cellValidity = CellValidity(status: .valid, row: row, column: column)
                        cellValidities.append(cellValidity)
                    } else {
                        let cellValidity = CellValidity(status: .invalid, row: row, column: column)
                        cellValidities.append(cellValidity)
                        isSchemaValid = false
                    }
                }
                
                let columnStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
                columnValidities.append(ColumnValidity(status: columnStatus, cellValidities: cellValidities))
            }
        }
        
        // Validate child schemas
        if let children = schema.children {
            for childID in children {
                if let childSchema = documentEditor.field(fieldID: fieldID)?.schema?[childID] {
                    let childValidity = validateSchema(schemaID: childID, schema: childSchema, rows: rows, fieldID: fieldID)
                    if childValidity.status == .invalid {
                        isSchemaValid = false
                    }
                }
            }
        }
        
        return SchemaValidity(schemaID: schemaID, status: isSchemaValid ? .valid : .invalid, columnValidities: columnValidities)
    }
}
