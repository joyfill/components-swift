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
}
