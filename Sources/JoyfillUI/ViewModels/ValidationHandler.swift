//
//  File.swift
//
//
//  Created by Vishnu Dutt on 05/12/24.
//

import Foundation
import JoyfillModel

class ValidationHandler {
    weak var documentEditor: DocumentEditor?

    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    func validate() -> Validation {
        guard let documentEditor = documentEditor else {
            return Validation(status: .valid, fieldValidities: [])
        }
        var fieldValidities = [FieldValidity]()
        var isValid = true
        var pageID: String?
        for pagesForCurrentView in documentEditor.pagesForCurrentView {
            pageID = pagesForCurrentView.id
            let fieldPositions = documentEditor.mapWebViewToMobileViewIfNeeded(fieldPositions: pagesForCurrentView.fieldPositions ?? [], isMobileViewActive: false)
        for fieldPosition in fieldPositions {
            guard let id = fieldPosition.field, let field = documentEditor.fieldMap[id] else {
                continue
            }
            let fieldPositionId = fieldPosition.id
            
            if !documentEditor.shouldShow(page: pagesForCurrentView) {
                fieldValidities.append(FieldValidity(field: field, status: .valid, pageId: pageID, fieldPositionId: fieldPositionId))
                continue
            }
            if !documentEditor.shouldShow(fieldID: field.id) {
                fieldValidities.append(FieldValidity(field: field, status: .valid, pageId: pageID, fieldPositionId: fieldPositionId))
                continue
            }
            
            guard let required = field.required, required else {
                fieldValidities.append(FieldValidity(field: field, status: .valid, pageId: pageID, fieldPositionId: fieldPositionId))
                continue
            }
            guard let fieldID = field.id else {
                Log("Missing field ID", type: .error)
                continue
            }
            
            if field.fieldType == .table {
                let tableFieldValidity = validateTableField(id: fieldID, pageId: pageID, fieldPositionId: fieldPositionId)
                if tableFieldValidity.status == .invalid {
                    isValid = false
                }
                fieldValidities.append(tableFieldValidity)
            } else if field.fieldType == .collection {
                let collectionFieldValidity = validateCollectionField(id: fieldID, pageId: pageID, fieldPositionId: fieldPositionId)
                if collectionFieldValidity.status == .invalid {
                    isValid = false
                }
                fieldValidities.append(collectionFieldValidity)
            } else {
                if let value = field.value, !value.isEmpty {
                    fieldValidities.append(FieldValidity(field: field, status: .valid, pageId: pageID, fieldPositionId: fieldPositionId))
                    continue
                }
                isValid = false
                fieldValidities.append(FieldValidity(field: field, status: .invalid, pageId: pageID, fieldPositionId: fieldPositionId))
            }
        }
        }
        return Validation(status: isValid ? .valid: .invalid, fieldValidities: fieldValidities)
    }
     
    func validateTableField(id: String, pageId: String?, fieldPositionId: String? = nil) -> FieldValidity {
        guard let documentEditor = documentEditor,
              let field = documentEditor.field(fieldID: id),
              let fieldPosition = documentEditor.fieldPosition(fieldID: id) else {
            return FieldValidity(field: JoyDocField(), status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        var fieldValidities = [FieldValidity]()
        var isTableValid = true
        let rows = field.valueToValueElements ?? []
        let columns = (field.tableColumns ?? []).filter { column in
            guard let columnID = column.id else { return false }
            let isHidden = fieldPosition.tableColumns?.first(where: { $0.id == columnID })?.hidden ?? false
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
        return FieldValidity(field: field, status: fieldStatus, pageId: pageId, fieldPositionId: fieldPositionId)
    }

    func validateCollectionField(id: String, pageId: String?, fieldPositionId: String? = nil) -> FieldValidity {
        guard let documentEditor = documentEditor,
              let field = documentEditor.field(fieldID: id),
              let schema = field.schema else {
            return FieldValidity(field: JoyDocField(), status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }

        var isCollectionValid = true
        let rows = field.valueToValueElements ?? []
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }

        var rowValidities: [RowValidity] = []
        var columnValidities: [ColumnValidity] = []
        var childrenValidities: [FieldValidity] = []

        // Identify root schema and columns
        guard let rootSchema = schema.first(where: { $0.value.root == true })?.value else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        let columns = rootSchema.tableColumns ?? []

        if let fieldRequired = field.required {
            if !fieldRequired {
                return FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
            }
        } else {
            FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        if nonDeletedRows.count == 0 {
            return FieldValidity(field: field, status: .invalid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        // Validate each row's cells
        for row in nonDeletedRows {
            var cellValidities: [CellValidity] = []

            for column in columns {
                guard let columnID = column.id else { continue }
                let required = column.required ?? false
                let cellValue = row.cells?[columnID]

                if required && (cellValue?.isEmpty ?? true) {
                    cellValidities.append(CellValidity(status: .invalid, row: row, column: column, reasons: ["Required value is missing"]))
                    isCollectionValid = false
                } else {
                    cellValidities.append(CellValidity(status: .valid, row: row, column: column))
                }
            }

            let rowStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities))
        }

        // Validate columns
        for column in columns {
            guard let columnID = column.id else { continue }
            var cellValidities: [CellValidity] = []

            for rowValidity in rowValidities {
                if let cell = rowValidity.cellValidities.first(where: { $0.column.id == columnID }) {
                    cellValidities.append(cell)
                }
            }

            let columnStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            columnValidities.append(ColumnValidity(status: columnStatus, cellValidities: cellValidities))
        }

        // Validate nested children schemas recursively
        for (schemaID, schemaValue) in schema where schemaValue.root == true {
            if let children = schemaValue.children {
                for childID in children {
                    if let childSchema = schema[childID] {
                        for row in nonDeletedRows {
                            let isChildVisible = documentEditor.shouldShowSchema(for: id, rowSchemaID: RowSchemaID(rowID: row.id ?? "", schemaID: childID))
                            let childRows = row.childrens?[childID]?.valueToValueElements ?? []
                            if isChildVisible {
                                if childSchema.required == true {
                                    
                                    if childRows.isEmpty {
                                        isCollectionValid = false
                                        continue
                                    }
                                }
                                // Recurse into children validation
                                let nestedValidity = validateCollectionFieldChild(fieldID: id, rows: childRows, schema: childSchema, pageId: pageId, fieldPositionId: fieldPositionId)
                                if nestedValidity.status == .invalid {
                                    isCollectionValid = false
                                }
                                childrenValidities.append(nestedValidity)
                            }
                        }
                    }
                }
            }
        }

        let status: ValidationStatus = isCollectionValid ? .valid : .invalid
        return FieldValidity(field: field, status: status, pageId: pageId, fieldPositionId: fieldPositionId)
    }
    
    private func validateCollectionFieldChild(fieldID: String, rows: [ValueElement], schema: Schema, pageId: String?, fieldPositionId: String? = nil) -> FieldValidity {
        guard let documentEditor = documentEditor else {
            return FieldValidity(field: JoyDocField(), status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        var isValid = true
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        let columns = schema.tableColumns ?? []

        var rowValidities: [RowValidity] = []
        var columnValidities: [ColumnValidity] = []

        for row in nonDeletedRows {
            var cellValidities: [CellValidity] = []

            for column in columns {
                guard let columnID = column.id else { continue }
                let required = column.required ?? false
                let cellValue = row.cells?[columnID]

                if required && (cellValue?.isEmpty ?? true) {
                    cellValidities.append(CellValidity(status: .invalid, row: row, column: column, reasons: ["Required value is missing"]))
                    isValid = false
                } else {
                    cellValidities.append(CellValidity(status: .valid, row: row, column: column))
                }
            }

            let rowStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities))

            if let children = schema.children {
                for childID in children {
                    if let childSchema = documentEditor.field(fieldID: fieldID)?.schema?[childID] {
                        let isChildVisible = documentEditor.shouldShowSchema(for: fieldID, rowSchemaID: RowSchemaID(rowID: row.id ?? "", schemaID: childID))
                        let childRows = row.childrens?[childID]?.valueToValueElements ?? []
                        
                        if isChildVisible {
                            if childSchema.required == true {
                                if childRows.isEmpty {
                                    isValid = false
                                    continue
                                }
                            }
                            let nested = validateCollectionFieldChild(fieldID: fieldID, rows: childRows, schema: childSchema, pageId: pageId, fieldPositionId: fieldPositionId)
                            if nested.status == .invalid {
                                isValid = false
                            }
                        }
                    }
                }
            }
        }

        for column in columns {
            guard let columnID = column.id else { continue }
            let cellValidities = rowValidities.compactMap { $0.cellValidities.first(where: { $0.column.id == columnID }) }
            let colStatus: ValidationStatus = cellValidities.allSatisfy { $0.status == .valid } ? .valid : .invalid
            columnValidities.append(ColumnValidity(status: colStatus, cellValidities: cellValidities))
        }

        guard let field = documentEditor.field(fieldID: fieldID) else {
            return FieldValidity(field: JoyDocField(), status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        return FieldValidity(field: field, status: isValid ? .valid : .invalid, pageId: pageId, fieldPositionId: fieldPositionId)
    }
}
