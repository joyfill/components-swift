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

        for page in documentEditor.pagesForCurrentView {
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
                let fieldPositionId = fieldPosition.id

                if !isPageVisible {
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
                    let validity = validateTableField(field: field, fieldID: fieldID, fieldPosition: fieldPosition, pageId: pageID, fieldPositionId: fieldPositionId)
                    if validity.status == .invalid { isValid = false }
                    fieldValidities.append(validity)
                } else if field.fieldType == .collection {
                    let validity = validateCollectionField(field: field, fieldID: fieldID, pageId: pageID, fieldPositionId: fieldPositionId)
                    if validity.status == .invalid { isValid = false }
                    fieldValidities.append(validity)
                } else {
                    if let value = field.value, !value.isEmpty {
                        fieldValidities.append(FieldValidity(field: field, status: .valid, pageId: pageID, fieldPositionId: fieldPositionId))
                    } else {
                        isValid = false
                        fieldValidities.append(FieldValidity(field: field, status: .invalid, pageId: pageID, fieldPositionId: fieldPositionId))
                    }
                }
            }
        }
        return Validation(status: isValid ? .valid : .invalid, fieldValidities: fieldValidities)
    }

    // MARK: - Table Validation

    private func validateTableField(field: JoyDocField, fieldID: String, fieldPosition: FieldPosition, pageId: String?, fieldPositionId: String?) -> FieldValidity {
        guard let documentEditor = documentEditor else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }

        let rows = field.valueToValueElements ?? []
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }
        let columnOrder = field.tableColumnOrder ?? []
        let allColumns = field.tableColumns ?? []

        let sortedColumns = sortColumns(allColumns, by: columnOrder)
        let visibleColumns = sortedColumns.filter { column in
            guard let columnID = column.id else { return false }
            let isStaticHidden = fieldPosition.tableColumns?.first(where: { $0.id == columnID })?.hidden ?? false
            if isStaticHidden { return false }
            return documentEditor.shouldShowColumn(columnID: columnID, fieldID: fieldID)
        }

        if nonDeletedRows.isEmpty {
            return FieldValidity(field: field, status: .invalid, pageId: pageId, fieldPositionId: fieldPositionId, rows: [])
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
                    cellValidities.append(CellValidity(status: .valid, column: column, value: cells[columnID]))
                    continue
                }

                if let cellValue = cells[columnID], !cellValue.isEmpty {
                    cellValidities.append(CellValidity(status: .valid, column: column, value: cellValue))
                } else {
                    cellValidities.append(CellValidity(status: .invalid, column: column, value: cells[columnID]))
                    isTableValid = false
                }
            }

            let rowStatus: ValidationStatus = cellValidities.allSatisfy({ $0.status == .valid }) ? .valid : .invalid
            rowValidities.append(RowValidity(status: rowStatus, cellValidities: cellValidities, row: row))
        }

        let fieldStatus: ValidationStatus = isTableValid ? .valid : .invalid
        return FieldValidity(field: field, status: fieldStatus, pageId: pageId, fieldPositionId: fieldPositionId, rows: rowValidities)
    }

    // MARK: - Collection Validation

    private func validateCollectionField(field: JoyDocField, fieldID: String, pageId: String?, fieldPositionId: String?) -> FieldValidity {
        guard let documentEditor = documentEditor,
              let schema = field.schema else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }

        guard let rootEntry = schema.first(where: { $0.value.root == true }) else {
            return FieldValidity(field: field, status: .valid, pageId: pageId, fieldPositionId: fieldPositionId)
        }
        let rootSchemaId = rootEntry.key
        let rootSchema = rootEntry.value

        let rows = field.valueToValueElements ?? []
        let nonDeletedRows = rows.filter { !($0.deleted ?? false) }

        if nonDeletedRows.isEmpty {
            return FieldValidity(field: field, status: .invalid, pageId: pageId, fieldPositionId: fieldPositionId, rows: [])
        }

        var allRowValidities = [RowValidity]()
        var isCollectionValid = true

        for row in nonDeletedRows {
            let rootRowValidity = validateCollectionRow(
                row: row,
                schema: rootSchema,
                schemaId: rootSchemaId,
                fullSchema: schema,
                fieldID: fieldID,
                documentEditor: documentEditor
            )
            allRowValidities.append(rootRowValidity)
            if rootRowValidity.status == .invalid { isCollectionValid = false }

            let (childValidities, hasRequiredEmptySchema) = validateCollectionChildren(
                parentRow: row,
                parentSchema: rootSchema,
                fullSchema: schema,
                fieldID: fieldID,
                documentEditor: documentEditor
            )
            if hasRequiredEmptySchema { isCollectionValid = false }
            for childValidity in childValidities {
                allRowValidities.append(childValidity)
                if childValidity.status == .invalid { isCollectionValid = false }
            }
        }

        let status: ValidationStatus = isCollectionValid ? .valid : .invalid
        return FieldValidity(field: field, status: status, pageId: pageId, fieldPositionId: fieldPositionId, rows: allRowValidities)
    }

    private func validateCollectionRow(
        row: ValueElement,
        schema: Schema,
        schemaId: String,
        fullSchema: [String: Schema],
        fieldID: String,
        documentEditor: DocumentEditor
    ) -> RowValidity {
        let columns = schema.tableColumns ?? []
        let cells = row.cells ?? [:]

        var cellValidities = [CellValidity]()

        for column in columns {
            guard let columnID = column.id else { continue }

            let isColumnVisible = documentEditor.shouldShowColumn(columnID: columnID, fieldID: fieldID, schemaKey: schemaId)
            if !isColumnVisible {
                cellValidities.append(CellValidity(status: .valid, column: column, value: cells[columnID]))
                continue
            }

            let isRequired = column.required ?? false
            if !isRequired {
                cellValidities.append(CellValidity(status: .valid, column: column, value: cells[columnID]))
                continue
            }

            if let cellValue = cells[columnID], !cellValue.isEmpty {
                cellValidities.append(CellValidity(status: .valid, column: column, value: cellValue))
            } else {
                cellValidities.append(CellValidity(status: .invalid, column: column, value: cells[columnID]))
            }
        }

        let rowStatus: ValidationStatus = cellValidities.allSatisfy({ $0.status == .valid }) ? .valid : .invalid
        return RowValidity(status: rowStatus, cellValidities: cellValidities, row: row, schema: schema, schemaId: schemaId)
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
                let rowValidity = validateCollectionRow(
                    row: childRow,
                    schema: childSchema,
                    schemaId: childSchemaId,
                    fullSchema: fullSchema,
                    fieldID: fieldID,
                    documentEditor: documentEditor
                )
                results.append(rowValidity)

                let (nestedResults, nestedHasEmpty) = validateCollectionChildren(
                    parentRow: childRow,
                    parentSchema: childSchema,
                    fullSchema: fullSchema,
                    fieldID: fieldID,
                    documentEditor: documentEditor
                )
                results.append(contentsOf: nestedResults)
                if nestedHasEmpty { hasRequiredEmptySchema = true }
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
