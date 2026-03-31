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

    fileprivate func validatePage(_ page: Page, _ documentEditor: DocumentEditor, _ isValid: inout Bool, _ fieldValidities: inout [FieldValidity]) {
        let pageID = page.id
        let isPageVisible = documentEditor.shouldShow(page: page)
        
        let fieldPositions = documentEditor.mapWebViewToMobileViewIfNeeded(
            fieldPositions: page.fieldPositions ?? [],
            isMobileViewActive: false
        )
        
        for fieldPosition in fieldPositions {
            guard let id = fieldPosition.field,
                  let field = documentEditor.fieldMap[id] else {
                continue
            }
            
            guard field.fieldType != .unknown else {
                continue
            }
            
            if !isPageVisible {
                continue
            }
            if !documentEditor.shouldShow(fieldID: field.id) {
                continue
            }
            
            guard let fieldID = field.id else {
                Log("Missing field ID", type: .error)
                continue
            }
            
            guard let validity = validateField(field: field, fieldID: fieldID, fieldPosition: fieldPosition, pageId: pageID, fieldPositionId: fieldPosition.id) else {
                continue
            }
            if validity.status == .invalid { isValid = false }
            fieldValidities.append(validity)
        }
    }
    
    func validate() -> Validation {
        guard let documentEditor = documentEditor else {
            return Validation(status: .valid, fieldValidities: [])
        }
        var fieldValidities = [FieldValidity]()
        var isValid = true

        for page in documentEditor.pagesForCurrentView {
            validatePage(page, documentEditor, &isValid, &fieldValidities)
        }
        return Validation(status: isValid ? .valid : .invalid, fieldValidities: fieldValidities)
    }
    
    func validate(path: String) -> ComponentValidity {
        guard let documentEditor = documentEditor else {
            return .page(Validation(status: .valid, fieldValidities: []))
        }
        
        let parsedPath = documentEditor.parsePath(path)
        guard let pageID = parsedPath.pageId else {
            return .page(validate())
        }

        guard let fieldPositionID = parsedPath.fieldPositionId else {
            return .page(validate(pageID: pageID))
        }

        if parsedPath.rowId != nil || parsedPath.columnId != nil {
            return .page(validate(pageID: pageID))
        }

        if let fieldIdentifier = documentEditor.getFieldIdentifier(forFieldPositionID: fieldPositionID),
           fieldIdentifier.pageID == pageID,
           let fieldValidity = validate(fieldIdentifier: fieldIdentifier) {
            return .field(fieldValidity)
        }
        return .page(validate(pageID: pageID))
    }

    func validate(pageID: String) -> Validation {
        guard let documentEditor = documentEditor else {
            return Validation(status: .valid, fieldValidities: [])
        }

        guard let page = documentEditor.pagesForCurrentView.first(where: { $0.id == pageID }) else {
            return Validation(status: .valid, fieldValidities: [])
        }
        var fieldValidities = [FieldValidity]()
        var isValid = true
        validatePage(page, documentEditor, &isValid, &fieldValidities)
        return Validation(status: isValid ? .valid : .invalid, fieldValidities: fieldValidities)
    }

    func validate(fieldIdentifier: FieldIdentifier) -> FieldValidity? {
        guard let documentEditor = documentEditor else { return nil }

        let fieldID = fieldIdentifier.fieldID
        let pageID = fieldIdentifier.pageID

        guard let field = documentEditor.field(fieldID: fieldID),
              field.fieldType != .unknown,
              documentEditor.shouldShow(pageID: pageID),
              documentEditor.shouldShow(fieldID: fieldID),
              let fieldPosition = documentEditor.fieldPosition(fieldID: fieldID) else { return nil }

        return validateField(
            field: field,
            fieldID: fieldID,
            fieldPosition: fieldPosition,
            pageId: pageID,
            fieldPositionId: fieldIdentifier.fieldPositionId ?? fieldPosition.id
        )
    }

    // MARK: - Per-field validation helper

    private func validateField(field: JoyDocField, fieldID: String, fieldPosition: FieldPosition, pageId: String?, fieldPositionId: String?) -> FieldValidity? {
        guard let documentEditor = documentEditor else { return nil }
        let isRequired = field.required ?? false

        if field.fieldType == .table {
            return validateTableField(field: field, fieldID: fieldID, fieldPosition: fieldPosition, pageId: pageId, fieldPositionId: fieldPositionId, isFieldRequired: isRequired)
        } else if field.fieldType == .collection {
            guard documentEditor.isCollectionFieldEnabled else { return nil }
            return validateCollectionField(field: field, fieldID: fieldID, pageId: pageId, fieldPositionId: fieldPositionId, isFieldRequired: isRequired)
        } else if !isRequired {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId)
        } else {
            let status: ValidationStatus = (field.value.map { !$0.isEmpty } ?? false) ? .valid : .invalid
            return FieldValidity(field: field, status: status, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId)
        }
    }

    // MARK: - Table Validation

    private func validateTableField(field: JoyDocField, fieldID: String, fieldPosition: FieldPosition, pageId: String?, fieldPositionId: String?, isFieldRequired: Bool) -> FieldValidity {
        guard let documentEditor = documentEditor else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId)
        }

        let rows = field.valueToValueElements ?? []
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        let columnOrder = field.tableColumnOrder ?? []
        let allColumns = field.tableColumns ?? []

        let sortedColumns = sortColumns(allColumns, by: columnOrder)
        let visibleColumns = sortedColumns.filter { column in
            guard let columnID = column.id else { return false }
            return documentEditor.shouldShowColumn(columnID: columnID, fieldID: fieldID)
        }

        if nonDeletedRows.isEmpty {
            let emptyStatus: ValidationStatus = isFieldRequired ? .invalid : .valid
            return FieldValidity(field: field, status: emptyStatus, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId, rowValidities: [])
        }

        var rowValidities = [RowValidity]()
        var isTableValid = true

        for row in nonDeletedRows {
            let cells = row.cells ?? [:]

            var cellValidities = [CellValidity]()
            for column in visibleColumns {
                guard let columnID = column.id else { continue }
                let isRequired = column.required ?? false

                if !isRequired {
                    cellValidities.append(CellValidity(status: .valid, columnId: columnID, value: cells[columnID]))
                    continue
                }

                if let cellValue = cells[columnID], !cellValue.isEmpty {
                    cellValidities.append(CellValidity(status: .valid, columnId: columnID, value: cellValue))
                } else {
                    cellValidities.append(CellValidity(status: .invalid, columnId: columnID, value: cells[columnID]))
                    isTableValid = false
                }
            }

            let rowStatus: ValidationStatus = cellValidities.allSatisfy({ $0.status == .valid }) ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities, rowId: row.id))
        }

        let fieldStatus: ValidationStatus = isTableValid ? .valid : .invalid
        return FieldValidity(field: field, status: fieldStatus, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId, rowValidities: rowValidities)
    }

    // MARK: - Collection Validation

    private func validateCollectionField(field: JoyDocField, fieldID: String, pageId: String?, fieldPositionId: String?, isFieldRequired: Bool) -> FieldValidity {
        guard let documentEditor = documentEditor,
              let schema = field.schema else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId)
        }

        guard let rootEntry = schema.first(where: { $0.value.root == true }) else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId)
        }
        let rootSchemaId = rootEntry.key
        let rootSchema = rootEntry.value

        let rows = field.valueToValueElements ?? []
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }

        if nonDeletedRows.isEmpty {
            let emptyStatus: ValidationStatus = isFieldRequired ? .invalid : .valid
            return FieldValidity(field: field, status: emptyStatus, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId, rowValidities: [])
        }

        var allRowValidities = [RowValidity]()
        var isCollectionValid = true

        for row in nonDeletedRows {
            let cellValidities = validateCollectionRowCells(
                row: row, schema: rootSchema, schemaId: rootSchemaId,
                fieldID: fieldID, documentEditor: documentEditor
            )
            let cellsValid = cellValidities.allSatisfy({ $0.status == .valid })

            let (childRowValidities, hasRequiredEmptySchema) = validateCollectionChildren(
                parentRow: row, parentSchema: rootSchema,
                fullSchema: schema, fieldID: fieldID, documentEditor: documentEditor
            )

            let childrenValid = !hasRequiredEmptySchema && childRowValidities.allSatisfy({ $0.status == .valid })
            let rowStatus: ValidationStatus = (cellsValid && childrenValid) ? .valid : .invalid

            allRowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities, rowId: row.id, schemaId: rootSchemaId))
            allRowValidities.append(contentsOf: childRowValidities)

            if rowStatus == .invalid { isCollectionValid = false }
        }

        let status: ValidationStatus = isCollectionValid ? .valid : .invalid
        return FieldValidity(field: field, status: status, pageId: pageId, fieldId: fieldID, fieldPositionId: fieldPositionId, rowValidities: allRowValidities)
    }

    private func validateCollectionRowCells(
        row: ValueElement,
        schema: Schema,
        schemaId: String,
        fieldID: String,
        documentEditor: DocumentEditor
    ) -> [CellValidity] {
        let columns = schema.tableColumns ?? []
        let cells = row.cells ?? [:]
        var cellValidities = [CellValidity]()

        for column in columns {
            guard let columnID = column.id else { continue }

            if !documentEditor.shouldShowColumn(columnID: columnID, fieldID: fieldID, schemaKey: schemaId) {
                continue
            }

            let isRequired = column.required ?? false
            if !isRequired {
                cellValidities.append(CellValidity(status: .valid, columnId: columnID, value: cells[columnID]))
                continue
            }

            if let cellValue = cells[columnID], !cellValue.isEmpty {
                cellValidities.append(CellValidity(status: .valid, columnId: columnID, value: cellValue))
            } else {
                cellValidities.append(CellValidity(status: .invalid, columnId: columnID, value: cells[columnID]))
            }
        }

        return cellValidities
    }

    private func validateCollectionChildren(
        parentRow: ValueElement,
        parentSchema: Schema,
        fullSchema: [String: Schema],
        fieldID: String,
        documentEditor: DocumentEditor
    ) -> (rows: [RowValidity], hasRequiredEmptySchema: Bool) {
        guard let childrenIds = parentSchema.children else { return ([], false) }
        var results = [RowValidity]()
        var hasRequiredEmptySchema = false

        for childSchemaId in childrenIds {
            guard let childSchema = fullSchema[childSchemaId] else { continue }

            let parentRowId = parentRow.id ?? ""
            let isChildVisible = documentEditor.shouldShowSchema(
                for: fieldID,
                rowSchemaID: RowSchemaID(rowID: parentRowId, schemaID: childSchemaId)
            )
            if !isChildVisible { continue }

            let childRows = parentRow.childrens?[childSchemaId]?.valueToValueElements ?? []
            let nonDeletedChildRows = childRows.filter { !($0.deleted ?? false) }

            if childSchema.required == true && nonDeletedChildRows.isEmpty {
                hasRequiredEmptySchema = true
                continue
            }

            for childRow in nonDeletedChildRows {
                let cellValidities = validateCollectionRowCells(
                    row: childRow, schema: childSchema, schemaId: childSchemaId,
                    fieldID: fieldID, documentEditor: documentEditor
                )
                let cellsValid = cellValidities.allSatisfy({ $0.status == .valid })

                let (nestedResults, nestedHasEmpty) = validateCollectionChildren(
                    parentRow: childRow, parentSchema: childSchema,
                    fullSchema: fullSchema, fieldID: fieldID, documentEditor: documentEditor
                )

                let childrenValid = !nestedHasEmpty && nestedResults.allSatisfy({ $0.status == .valid })
                let rowStatus: ValidationStatus = (cellsValid && childrenValid) ? .valid : .invalid

                results.append(RowValidity(status: rowStatus, cellValidities: cellValidities, rowId: childRow.id, schemaId: childSchemaId))
                results.append(contentsOf: nestedResults)
            }
        }

        return (results, hasRequiredEmptySchema)
    }

    // MARK: - Helpers

    private func sortColumns(_ columns: [FieldTableColumn], by columnOrder: [String]) -> [FieldTableColumn] {
        guard !columnOrder.isEmpty else { return columns }
        return columns.sorted { a, b in
            let indexA = columnOrder.firstIndex(of: a.id ?? "") ?? Int.max
            let indexB = columnOrder.firstIndex(of: b.id ?? "") ?? Int.max
            return indexA < indexB
        }
    }
}
