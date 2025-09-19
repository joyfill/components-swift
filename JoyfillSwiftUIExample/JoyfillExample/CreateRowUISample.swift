//
//  CreateRowUISample.swift
//  JoyfillExample
//
//  Created by Vivek on 17/09/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

struct CreateRowUISample: View, FormChangeEvent {
    
    init() {
        let document = sampleJSONDocument(fileName: "FieldTemplate_TableCollection_Poplated")
        documentEditor = DocumentEditor(document: document, events: self, validateSchema: false, license: licenseKey)
    }
    
    var body: some View {
        VStack {
            NavigationView {
                Form(documentEditor: documentEditor)
                    .tint(.red)
            }
            
            Button("Add Nested Row") {
                let changes = [createRow(documentEditor: documentEditor)]
                
                documentEditor.change(changes: changes)
            }
        }
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        generateDeficiencySummary(document: document, documentEditor: documentEditor, changeEvent: changes.first!)
    }
    func onFocus(event: FieldIdentifier) { }
    func onBlur(event:  FieldIdentifier) { }
    func onCapture(event: CaptureEvent) { }
    func onUpload(event: UploadEvent) { }
    func onError(error: Joyfill.JoyfillError) { }
   
    func createRow(documentEditor: DocumentEditor) -> Change {
        let fieldId = "6857510fbfed1553e168161b"
        let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
        let field = documentEditor.field(fieldID: fieldId)
        
        var newRow = ValueElement(id: UUID().uuidString)
        newRow.cells = [:]
        newRow.childrens = [:]
        let schemas = field?.schema ?? [:]
        
        let rootSchemaKey = schemas.first(where: { $0.value.root == true })?.key ?? ""
        let targetSchemaID = schemas[rootSchemaKey]?.children?.first ?? "" // Add your target schema ID here
        
        let existingRows = field?.valueToValueElements ?? []
        let existingRowsInTargetSchema = existingRows.first?.childrens?[targetSchemaID]?.valueToValueElements ?? []
        let parentRowId = existingRows.first?.id ?? ""
        let parentPath = documentEditor.computeParentPath(targetParentId: parentRowId, nestedKey: targetSchemaID, in: [rootSchemaKey : existingRows]) ?? ""
        
        let newRowChange = addNestedRowChanges(newRow: newRow, targetRowIndex: existingRowsInTargetSchema.count, parentPath: parentPath, schemaId: targetSchemaID)
        
        return Change(v: 1,
                      sdk: "swift",
                      target: "field.value.rowCreate",
                      _id: documentEditor.documentID ?? "",
                      identifier: documentEditor.documentIdentifier,
                      fileId: fieldIdentifier.fileID ?? "",
                      pageId: fieldIdentifier.pageID ?? "",
                      fieldId: fieldId,
                      fieldIdentifier: field?.identifier ?? "",
                      fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
                      change: newRowChange,
                      createdOn: Date().timeIntervalSince1970
        )
    }
    
    private func addNestedRowChanges(newRow: ValueElement, targetRowIndex: Int, parentPath: String, schemaId: String) -> [String: Any] {
        var newRowChange: [String: Any] = ["row": newRow.anyDictionary]
        newRowChange["parentPath"] = parentPath
        newRowChange["schemaId"] = schemaId // The ID of the associated schema.
        newRowChange["targetRowIndex"] = targetRowIndex // New row index
        return newRowChange
    }

    public func generateDeficiencySummary(
        document: JoyDoc,
        documentEditor: DocumentEditor,
        changeEvent: Joyfill.Change
    ) {
        print("[TEST:] Starting generateDeficiencySummary...")

        let collectionsAndTables = collectAllCollectionsAndTables(from: document)
        print("[TEST:] Found \(collectionsAndTables.collections.count) collections and \(collectionsAndTables.tables.count) tables")

        var allDeficiencies: [[String: String]] = []

        for table in collectionsAndTables.tables {
            let tableDeficiencies = processTableDeficiencies(table: table)
            allDeficiencies.append(contentsOf: tableDeficiencies)
        }

        for collection in collectionsAndTables.collections {
            let collectionDeficiencies = processCollectionDeficiencies(collection: collection, document: document)
            allDeficiencies.append(contentsOf: collectionDeficiencies)
        }

        print("[TEST:] Total deficiencies found: \(allDeficiencies.count)")

        addDeficienciesToSummaryTable(
            deficiencies: allDeficiencies,
            document: document,
            documentEditor: documentEditor,
            changeEvent: changeEvent
        )

        print("[TEST:] generateDeficiencySummary completed")
    }

    public func handleDeficiencySummaryChange(
        document: JoyDoc,
        documentEditor: DocumentEditor,
        changeEvent: Joyfill.Change
    ) {
        guard let fieldIdentifier = changeEvent.fieldIdentifier,
              fieldIdentifier == Constants.generateDeficiencySummaryIdentifier else {
            return
        }

        print("🔍 generateDeficiencySummary: Looking for deficiency_summary table...")
        guard let deficienciesTable = document.fields.first(where: { $0.identifier == Constants.deficiencySummaryIdentifier }) else {
            print("❌ generateDeficiencySummary: deficiency_summary table not found!")
            return
        }
        print("✅ generateDeficiencySummary: Found deficiency_summary table")

        // Clear the deficiencies table first
        clearDeficiencySummaryTable(
            table: deficienciesTable,
            document: document,
            documentEditor: documentEditor,
            changeEvent: changeEvent
        )

        // Check if the trigger field is set to generate deficiencies
        print("🔍 Checking if should generate deficiencies...")
        if shouldGenerateDeficiencies(from: changeEvent) {
            print("✅ Should generate deficiencies - proceeding")
            generateDeficiencySummary(
                document: document,
                documentEditor: documentEditor,
                changeEvent: changeEvent
            )
            print("[TEST:] handleDeficiencySummaryChange completed")
        } else {
            print("❌ Should not generate deficiencies - stopping")
            print("[TEST:] handleDeficiencySummaryChange completed (clear only)")
        }
    }

    // MARK: - Private Methods
    private struct CollectionsAndTables {
        let collections: [JoyDocField]
        let tables: [JoyDocField]
    }

    private func collectAllCollectionsAndTables(from document: JoyDoc) -> CollectionsAndTables {
        print("[TEST:] collectAllCollectionsAndTables - starting")
        var collections: [JoyDocField] = []
        var tables: [JoyDocField] = []

        for field in document.fields {
            switch field.fieldType {
            case .collection:
                collections.append(field)
                print("[TEST:] Found collection: \(field.identifier ?? "nil")")
            case .table:
                tables.append(field)
                print("[TEST:] Found table: \(field.identifier ?? "nil")")
            default:
                break
            }
        }

        print("[TEST:] collectAllCollectionsAndTables - completed: \(collections.count) collections, \(tables.count) tables")
        return CollectionsAndTables(collections: collections, tables: tables)
    }

    private func processTableDeficiencies(table: JoyDocField) -> [[String: String]] {
        print("[TEST:] processTableDeficiencies - starting for: \(table.identifier ?? "nil")")

        guard let tableColumns = table.tableColumns,
              let valueElements = table.resolvedValue?.valueElements else {
            print("[TEST:] processTableDeficiencies - no columns or elements")
            return []
        }

        var deficiencies: [[String: String]] = []

        let deficiencyColumns = findDeficiencyColumns(in: tableColumns)
        print("[TEST:] processTableDeficiencies - found \(deficiencyColumns.count) deficiency columns")

        if deficiencyColumns.isEmpty {
            return []
        }

        for row in valueElements {
            if hasDeficiencyMarkers(cells: row.cells, deficiencyColumns: deficiencyColumns) {
                print("[TEST:] processTableDeficiencies - found deficiency in row: \(row.id ?? "nil")")
                let rowData = extractRowDataByIdentifier(row: row, columns: tableColumns)
                deficiencies.append(rowData)
            }
        }

        print("[TEST:] processTableDeficiencies - completed: \(deficiencies.count) deficiencies")
        return deficiencies
    }

    private func processCollectionDeficiencies(collection: JoyDocField, document: JoyDoc) -> [[String: String]] {
        print("[TEST:] processCollectionDeficiencies - starting for: \(collection.identifier ?? "nil")")

        guard let valueElements = collection.resolvedValue?.valueElements else {
            print("[TEST:] processCollectionDeficiencies - no elements")
            return []
        }

        let columns = collection.schema?[Constants.collectionSchemaIdKey]?.tableColumns ?? []
        let deficiencyColumns = findDeficiencyColumns(in: columns)
        print("[TEST:] processCollectionDeficiencies - found \(deficiencyColumns.count) deficiency columns")

        if deficiencyColumns.isEmpty {
            return []
        }

        var deficiencies: [[String: String]] = []

        for parentRow in valueElements {
            if hasDeficiencyMarkers(cells: parentRow.cells, deficiencyColumns: deficiencyColumns) {
                print("[TEST:] processCollectionDeficiencies - found deficiency in parent: \(parentRow.id ?? "nil")")

                let parentData = extractRowDataByIdentifier(row: parentRow, columns: columns)
                print("[TEST:] processCollectionDeficiencies - parent data: \(parentData)")

                let childRows = getChildrenForParent(parentRow: parentRow, document: document)
                print("[TEST:] processCollectionDeficiencies - found \(childRows.count) children")

                if childRows.isEmpty {
                    deficiencies.append(parentData)
                    print("[TEST:] processCollectionDeficiencies - added parent only")
                } else {
                    for (index, childRow) in childRows.enumerated() {
                        let childData = extractRowDataByIdentifier(row: childRow.row, columns: childRow.columns)
                        print("[TEST:] processCollectionDeficiencies - child \(index) data: \(childData)")

                        let mergedData = mergeParentAndChild(parent: parentData, child: childData)
                        print("[TEST:] processCollectionDeficiencies - merged data: \(mergedData)")

                        deficiencies.append(mergedData)
                    }
                }
            }
        }

        print("[TEST:] processCollectionDeficiencies - completed: \(deficiencies.count) deficiencies")
        return deficiencies
    }

    // MARK: - Helper Methods

    private func findDeficiencyColumns(in columns: [FieldTableColumn]) -> [FieldTableColumn] {
        return columns.filter { column in
            // Try typed options first
            if let options = column.options {
                return options.contains { option in
                    if let metadata = option.dictionary["metadata"] as? [String: Any],
                       let isDeficiency = metadata[Constants.deficiencyKey] as? Bool {
                        return isDeficiency == true
                    }
                    return false
                }
            }
            // Fallback: parse options from dictionary
            if let optionsArray = column.dictionary["options"] as? [Any] {
                for case let optionDict as [String: Any] in optionsArray {
                    if let metadata = optionDict["metadata"] as? [String: Any],
                       let isDeficiency = metadata[Constants.deficiencyKey] as? Bool,
                       isDeficiency == true {
                        return true
                    }
                }
            }
            return false
        }
    }

    private func extractRowDataByIdentifier(row: ValueElement, columns: [FieldTableColumn]) -> [String: String] {
        print("[TEST:] extractRowDataByIdentifier - row: \(row.id ?? "nil")")
        var data: [String: String] = [:]

        guard let cells = row.cells else {
            print("[TEST:] extractRowDataByIdentifier - no cells")
            return data
        }

        for column in columns {
            if let columnId = column.id,
               let identifier = column.identifier,
               let cellValue = cells[columnId]?.text {
                data[identifier] = cellValue
                print("[TEST:] extractRowDataByIdentifier - \(identifier): \(cellValue)")
            }
        }

        return data
    }

    private struct ChildRowData {
        let row: ValueElement
        let columns: [FieldTableColumn]
    }

    private func getChildrenForParent(parentRow: ValueElement, document: JoyDoc) -> [ChildRowData] {
        print("[TEST:] getChildrenForParent - parent: \(parentRow.id ?? "nil")")
        var children: [ChildRowData] = []

        if let parentDict = parentRow.dictionary as? [String: Any],
           let childrenValue = parentDict["children"] as? ValueUnion,
           let childrenDict = childrenValue.dictionary as? [String: Any] {

            print("[TEST:] getChildrenForParent - found children keys: \(childrenDict.keys)")

            for (key, value) in childrenDict {
                if let nestedValue = value as? [String: Any],
                   let elementValue = nestedValue["value"] as? [[String: Any]] {

                    print("[TEST:] getChildrenForParent - processing key: \(key) with \(elementValue.count) elements")

                    let childColumns = findChildCollectionSchema(document: document, schemaKey: key)

                    for childElementDict in elementValue {
                        if let childId = childElementDict["_id"] as? String,
                           let childCells = childElementDict["cells"] as? [String: Any] {

                            let childRow = createValueElementFromDict(id: childId, cells: childCells)
                            children.append(ChildRowData(row: childRow, columns: childColumns))

                            print("[TEST:] getChildrenForParent - added child: \(childId)")
                        }
                    }
                }
            }
        }

        print("[TEST:] getChildrenForParent - found \(children.count) children")
        return children
    }

    private func mergeParentAndChild(parent: [String: String], child: [String: String]) -> [String: String] {
        print("[TEST:] mergeParentAndChild - parent: \(parent.count) fields, child: \(child.count) fields")

        var merged = parent

        // Child data overrides parent data for same identifiers
        for (identifier, value) in child {
            merged[identifier] = value
        }

        print("[TEST:] mergeParentAndChild - merged: \(merged.count) fields")
        return merged
    }

    private func findChildCollectionSchema(document: JoyDoc, schemaKey: String) -> [FieldTableColumn] {
        print("[TEST:] findChildCollectionSchema - searching for key: \(schemaKey)")

        for field in document.fields {
            if field.fieldType == .collection,
               let schema = field.schema,
               let schemaValue = schema[schemaKey] {
                let columns = schemaValue.tableColumns ?? []
                print("[TEST:] findChildCollectionSchema - found \(columns.count) columns for key: \(schemaKey)")
                return columns
            }
        }

        print("[TEST:] findChildCollectionSchema - no schema found for key: \(schemaKey)")
        return []
    }

    private func createValueElementFromDict(id: String, cells: [String: Any]) -> ValueElement {
        print("[TEST:] createValueElementFromDict - id: \(id), cells: \(cells.count)")

        var valueCells: [String: ValueUnion] = [:]
        for (key, value) in cells {
            if let stringValue = value as? String {
                valueCells[key] = ValueUnion.string(stringValue)
            }
        }

        // Create minimal ValueElement dictionary
        let elementDict: [String: Any] = [
            "_id": id,
            "cells": valueCells
        ]

        return ValueElement(dictionary: elementDict)
    }

    // MARK: - Step 3: Add to Summary Table

    private func addDeficienciesToSummaryTable(
        deficiencies: [[String: String]],
        document: JoyDoc,
        documentEditor: DocumentEditor,
        changeEvent: Joyfill.Change
    ) {
        print("[TEST:] addDeficienciesToSummaryTable - starting with \(deficiencies.count) deficiencies")

        guard let summaryTable = document.fields.first(where: { $0.identifier == Constants.deficiencySummaryIdentifier }),
              let summaryColumns = summaryTable.tableColumns,
              let tableFieldID = summaryTable.identifier else {
            print("[TEST:] addDeficienciesToSummaryTable - deficiency_summary table not found")
            return
        }

        print("[TEST:] addDeficienciesToSummaryTable - summary table has \(summaryColumns.count) columns")

        for (index, deficiency) in deficiencies.enumerated() {
            print("[TEST:] addDeficienciesToSummaryTable - processing deficiency \(index): \(deficiency)")

            let mappedData = mapDeficiencyToSummaryTable(
                deficiency: deficiency,
                summaryColumns: summaryColumns
            )

            if mappedData.isEmpty {
                print("[TEST:] addDeficienciesToSummaryTable - no matching columns for deficiency \(index), skipping")
                continue
            }

            // Create row in summary table
            let rowId = generateObjectId()
            let createRowChange = createRowCreateChange(
                from: changeEvent,
                document: document,
                targetFieldID: tableFieldID,
                rowID: rowId,
                cellValues: mappedData
            )
            documentEditor.change(changes: [createRowChange])
//            // Try using insertRow with shouldSendEvent: true to trigger onChange
//            let fieldIdentifier = FieldIdentifier(
//                fieldID: summaryTable.id ?? "",
//                pageID: changeEvent.pageId ?? "",
//                fileID: changeEvent.fileId ?? ""
//            )
//
//            // Convert [String: Any] to [String: ValueUnion] using dictionary approach
//            var cellValuesForInsert: [String: ValueUnion] = [:]
//            for (key, value) in mappedData {
//                if let stringValue = value as? String {
//                    // Create ValueUnion with text value using dictionary
//                    cellValuesForInsert[key] = ValueUnion(anyDictionary: ["text": stringValue])
//                }
//            }
//
//            print("[TEST:] addDeficienciesToSummaryTable - trying insertRow with shouldSendEvent=true")
//            print("[TEST:] addDeficienciesToSummaryTable - converting \(mappedData.count) values to ValueUnion")
//
//            let insertResult = documentEditor.insertRow(
//                at: index,
//                id: rowId,
//                cellValues: cellValuesForInsert,
//                fieldIdentifier: fieldIdentifier,
//                shouldSendEvent: true  // This should trigger onChange automatically!
//            )
//
//            if let result = insertResult {
//                print("[TEST:] addDeficienciesToSummaryTable - insertRow SUCCESS: got \(result.0.count) elements, added element: \(result.1.id ?? "unknown")")
//            } else {
//                print("[TEST:] addDeficienciesToSummaryTable - insertRow FAILED")
//            }
            print("[TEST:] addDeficienciesToSummaryTable - added row \(index) with ID: \(rowId)")

            // [TEST:] Debug: check documentEditor.document state
            print("[TEST:] addDeficienciesToSummaryTable - checking documentEditor.document state...")
            print("[TEST:] addDeficienciesToSummaryTable - documentEditor.document has \(documentEditor.document.fields.count) fields")

            let deficiencyField = documentEditor.document.fields.first(where: { $0.identifier == Constants.deficiencySummaryIdentifier })
            if deficiencyField == nil {
                print("[TEST:] addDeficienciesToSummaryTable - VERIFY: deficiency_summary field NOT FOUND in documentEditor.document")
            } else {
                print("[TEST:] addDeficienciesToSummaryTable - VERIFY: deficiency_summary field found")
                if let verifyRows = deficiencyField!.resolvedValue?.valueElements {
                    print("[TEST:] addDeficienciesToSummaryTable - VERIFY: documentEditor.document now has \(verifyRows.count) rows")
                } else {
                    print("[TEST:] addDeficienciesToSummaryTable - VERIFY: deficiency_summary field has NO resolvedValue or valueElements")
                }
            }
        }

        print("[TEST:] addDeficienciesToSummaryTable - completed")
    }

    private func mapDeficiencyToSummaryTable(
        deficiency: [String: String],
        summaryColumns: [FieldTableColumn]
    ) -> [String: Any] {
        print("[TEST:] mapDeficiencyToSummaryTable - mapping \(deficiency.count) fields to \(summaryColumns.count) columns")

        var mappedData: [String: Any] = [:]

        for summaryColumn in summaryColumns {
            if let summaryColumnId = summaryColumn.id,
               let summaryIdentifier = summaryColumn.identifier,
               let deficiencyValue = deficiency[summaryIdentifier] {

                mappedData[summaryColumnId] = deficiencyValue
                print("[TEST:] mapDeficiencyToSummaryTable - mapped '\(summaryIdentifier)' to column \(summaryColumnId): \(deficiencyValue)")
            }
        }

        print("[TEST:] mapDeficiencyToSummaryTable - result: \(mappedData.count) mapped fields")
        return mappedData
    }

    private func getCellValue(column: FieldTableColumn?, cellValue: String?) -> String? {
        guard let column = column,
              let cellValue = cellValue,
              let options = column.options else {
            return cellValue
        }

        let option = options.first { $0.id == cellValue }
        return option?.value ?? cellValue
    }

    private func convertRowToDeficiency(row: ValueElement, columns: [FieldTableColumn]) -> [String: Any] {
        var deficiency: [String: Any] = [:]

        if let rowId = row.id {
            deficiency[Constants.idKey] = rowId
        }

        guard let cells = row.cells else { return deficiency }

        for (cellId, cellValue) in cells {
            if let column = columns.first(where: { $0.id == cellId }),
               let identifier = column.identifier {
                let convertedValue = getCellValue(column: column, cellValue: cellValue.text)
                deficiency[identifier] = convertedValue
            }
        }

        return deficiency
    }

    private func hasDeficiencyMarkers(cells: [String: ValueUnion]?, deficiencyColumns: [FieldTableColumn]) -> Bool {
        guard let cells = cells else { return false }

        for cellId in cells.keys {
            guard let column = deficiencyColumns.first(where: { $0.id == cellId }),
                  let cellValue = cells[cellId]?.text else {
                continue
            }

            print("🔍 Checking cell \(cellId) with value: \(cellValue)")

            // Try typed options first
            if let options = column.options {
                let option = options.first { $0.id == cellValue }
                print("�� Found typed option: \(option?.id ?? "nil")")

                if let metadata = option?.dictionary["metadata"] as? [String: Any],
                   let result = metadata[Constants.deficiencyKey] as? Bool,
                   result == true {
                    print("✅ Found deficiency marker via typed options!")
                    return true
                }
            }

            // Fallback: parse options from dictionary
            if let optionsArray = column.dictionary["options"] as? [Any] {
                print("📋 Trying fallback dictionary options, count: \(optionsArray.count)")
                print("🔍 Looking for cellValue: '\(cellValue)'")

                for (index, element) in optionsArray.enumerated() {
                    guard let optionDict = element as? [String: Any] else { continue }

                    let optionId = optionDict["_id"] as? String ?? "nil"
                    let optionValue = optionDict["value"] as? String ?? "nil"
                    print("📋 Option \(index): _id='\(optionId)', value='\(optionValue)'")

                    // Try matching by _id first
                    if optionId == cellValue {
                        print("📋 Found matching option by _id: \(optionId)")
                        print("🔍 Option metadata: \(optionDict["metadata"] ?? "nil")")

                        if let metadata = optionDict["metadata"] as? [String: Any] {
                            print("📋 Metadata found: \(metadata)")
                            if let isDeficiency = metadata[Constants.deficiencyKey] as? Bool {
                                print("📋 _deficiency value: \(isDeficiency)")
                                if isDeficiency == true {
                                    print("✅ Found deficiency marker via dictionary options (_id)!")
                                    return true
                                } else {
                                    print("❌ _deficiency is false, not a deficiency marker")
                                }
                            } else {
                                print("❌ _deficiency key not found or not a Bool")
                            }
                        } else {
                            print("❌ No metadata found for this option")
                        }
                    }

                    // Try matching by value as fallback
                    if optionValue == cellValue {
                        print("📋 Found matching option by value: \(optionValue)")
                        print("🔍 Option metadata: \(optionDict["metadata"] ?? "nil")")

                        if let metadata = optionDict["metadata"] as? [String: Any] {
                            print("📋 Metadata found: \(metadata)")
                            if let isDeficiency = metadata[Constants.deficiencyKey] as? Bool {
                                print("📋 _deficiency value: \(isDeficiency)")
                                if isDeficiency == true {
                                    print("✅ Found deficiency marker via dictionary options (value)!")
                                    return true
                                } else {
                                    print("❌ _deficiency is false, not a deficiency marker")
                                }
                            } else {
                                print("❌ _deficiency key not found or not a Bool")
                            }
                        } else {
                            print("❌ No metadata found for this option")
                        }
                    }
                }
            }
        }

        return false
    }

    private func generateDeficiencies(from document: JoyDoc) -> [[String: Any]] {
        var deficiencies: [[String: Any]] = []

        for field in document.fields {
            guard field.fieldType == .collection || field.fieldType == .table else { continue }

            let columns: [FieldTableColumn]
            if field.fieldType == .table {
                columns = field.tableColumns ?? []
            } else {
                columns = field.schema?[Constants.collectionSchemaIdKey]?.tableColumns ?? []
            }

            let deficiencyColumns: [FieldTableColumn] = columns.filter { column in
                // Try typed options first
                if let options = column.options {
                    return options.contains { option in
                        if let metadata = option.dictionary["metadata"] as? [String: Any],
                           let isDeficiency = metadata[Constants.deficiencyKey] as? Bool {
                            return isDeficiency == true
                        }
                        return false
                    }
                }
                // Fallback: parse options from dictionary
                if let optionsArray = column.dictionary["options"] as? [Any] {
                    for case let optionDict as [String: Any] in optionsArray {
                        if let metadata = optionDict["metadata"] as? [String: Any],
                           let isDeficiency = metadata[Constants.deficiencyKey] as? Bool,
                           isDeficiency == true {
                            return true
                        }
                    }
                }
                return false
            }

            print("✅ Found deficiency columns: \(deficiencyColumns.count)")

            guard !deficiencyColumns.isEmpty,
                  let fieldValue = field.resolvedValue?.valueElements else { continue }

            for row in fieldValue {
                guard hasDeficiencyMarkers(cells: row.cells, deficiencyColumns: deficiencyColumns) else { continue }

                let parentDeficiency = convertRowToDeficiency(row: row, columns: columns)

                // Note: Child deficiencies processing is not supported in current JoyFill Swift SDK
                // as ValueElement doesn't have children property like in JavaScript version
                deficiencies.append(parentDeficiency)
            }
        }

        return deficiencies
    }

    private func findSourceRow(document: JoyDoc, rowId: String) -> ValueElement? {
        for field in document.fields {
            if let valueElements = field.resolvedValue?.valueElements {
                if let foundRow = valueElements.first(where: { $0.id == rowId }) {
                    return foundRow
                }
            }
        }
        return nil
    }

    private func populateDeficiencySummary(
        deficiencies: [[String: Any]],
        document: JoyDoc,
        documentEditor: DocumentEditor,
        changeEvent: Joyfill.Change,
        pageID: String,
        fileID: String,
        fieldID: String
    ) {
        print("🔍 Looking for deficiency_summary field...")
        print("📄 Available fields in document:")
        for (index, field) in document.fields.enumerated() {
            print("   \(index): identifier='\(field.identifier ?? "nil")', type=\(field.fieldType)")
        }

        guard let table = document.fields.first(where: { $0.identifier == Constants.deficiencySummaryIdentifier }),
              let tableColumns = table.tableColumns,
              let tableFieldID = table.identifier else {
            print("❌ deficiency_summary field not found!")
            return
        }

        for deficiency in deficiencies {
            var cellValues: [String: Any] = [:]

            if let sourceRowId = deficiency[Constants.idKey] as? String,
               let sourceRow = findSourceRow(document: document, rowId: sourceRowId) {
                for summaryColumn in tableColumns {
                    if let summaryColumnId = summaryColumn.id,
                       let sourceCells = sourceRow.cells,
                       let sourceValue = sourceCells[summaryColumnId] {
                        switch sourceValue {
                        case .string(let stringValue):
                            cellValues[summaryColumnId] = stringValue
                        default:
                            break // TODO: should we handle?
                        }
                    }
                }
            }

            // Convert [String: Any] to [String: ValueUnion]
            var convertedCellValues: [String: ValueUnion] = [:]
            for (key, value) in cellValues {
                if let stringValue = value as? String {
                    convertedCellValues[key] = ValueUnion.string(stringValue)
                } else {
                    // For other types, convert to string representation
                    convertedCellValues[key] = ValueUnion.string(String(describing: value))
                }
            }

            // Generate unique ID for the new row
            let rowId = generateObjectId()

            // Use the same approach as FormsHintController - create Change event
            let createRowChange = createRowCreateChange(
                from: changeEvent,
                document: document,
                targetFieldID: tableFieldID,
                rowID: rowId,
                cellValues: cellValues
            )

            print("🔍 Change event details:")
            print("   target: \(createRowChange.target ?? "nil")")
            print("   fieldId: \(createRowChange.fieldId ?? "nil")")
            print("   pageId: \(createRowChange.pageId ?? "nil")")
            print("   fileId: \(createRowChange.fileId ?? "nil")")
            print("   payload: \(createRowChange.change ?? [:])")

            documentEditor.change(changes: [createRowChange])
            print("✅ Row added via Change event: \(rowId)")
        }

        print("📊 Completed processing \(deficiencies.count) deficiencies via Change events")
    }

    private func clearDeficiencySummaryTable(
        table: JoyDocField,
        document: JoyDoc,
        documentEditor: DocumentEditor,
        changeEvent: Joyfill.Change
    ) {
        print("[TEST:] clearDeficiencySummaryTable - starting")

        guard let tableFieldID = table.identifier else {
            print("[TEST:] clearDeficiencySummaryTable - missing tableFieldID")
            return
        }

        // CRITICAL: Use the ORIGINAL documentEditor to see manually edited rows
        // Fresh DocumentEditor might not see UI changes that user made manually
        print("[TEST:] clearDeficiencySummaryTable - using original documentEditor to get current table state")

        guard let liveTable = documentEditor.field(fieldID: table.id ?? ""),
              let existingRows = liveTable.resolvedValue?.valueElements else {
            print("[TEST:] clearDeficiencySummaryTable - no existing rows found in original documentEditor")
            return
        }

        print("[TEST:] clearDeficiencySummaryTable - found \(existingRows.count) existing rows to delete")

        var deletedRowIds: [String] = []

        // Remove all existing rows using Change events
        for (index, row) in existingRows.enumerated() {
            if let rowId = row.id {
                print("[TEST:] clearDeficiencySummaryTable - deleting row \(index): \(rowId)")

                // Log row content for debugging
                if let cells = row.cells {
                    print("[TEST:] clearDeficiencySummaryTable - row \(index) content: \(cells.count) cells")
                    for (cellKey, cellValue) in cells {
                        print("[TEST:] clearDeficiencySummaryTable - row \(index) cell[\(cellKey)]: \(cellValue.text ?? "nil")")
                    }
                }

                if let deleteRowChange = createRowDeleteChange(
                    from: changeEvent,
                    document: document,
                    targetFieldID: tableFieldID,
                    rowID: rowId
                ) {

                    // Use ORIGINAL documentEditor for actual deletion (it's connected to UI)
                    documentEditor.change(changes: [deleteRowChange])
                    deletedRowIds.append(rowId)
                    print("[TEST:] clearDeficiencySummaryTable - deleted row \(index): \(rowId)")
                }
            }
        }

        print("[TEST:] clearDeficiencySummaryTable - SUMMARY: deleted \(deletedRowIds.count) rows with IDs: \(deletedRowIds)")

        print("[TEST:] clearDeficiencySummaryTable - completed")

        // Verify what remains after clearing - use the SAME documentEditor that was used for deletion
        if let verifyTable = documentEditor.field(fieldID: table.id ?? ""),
           let remainingRows = verifyTable.resolvedValue?.valueElements {
            print("[TEST:] clearDeficiencySummaryTable - VERIFICATION: \(remainingRows.count) rows remaining after clearing")
            for (index, row) in remainingRows.enumerated() {
                print("[TEST:] clearDeficiencySummaryTable - REMAINING row \(index): id=\(row.id ?? "nil")")
            }
        } else {
            print("[TEST:] clearDeficiencySummaryTable - VERIFICATION: Table is now empty or cannot be accessed")
        }
    }

    private func shouldGenerateDeficiencies(from changeEvent: Joyfill.Change) -> Bool {
        // JavaScript logic: Array.isArray(change?.change?.value) && change.change.value[0]
        guard let changeValue = changeEvent.change?[Constants.valueKey] as? [Any],
              !changeValue.isEmpty else {
            return false
        }

        // Return true if first element exists (equivalent to change.change.value[0] in JS)
        return changeValue.first != nil
    }

    private func createRowCreateChange(
        from originalChange: Change,
        document: JoyDoc,
        targetFieldID: String,
        rowID: String,
        cellValues: [String: Any]
    ) -> Change {
        print("[TEST:] createRowCreateChange - targetFieldID: \(targetFieldID)")

        var newRow: [String: Any] = [:]
        newRow[Constants.idKey] = rowID
        newRow[Constants.cellsKey] = cellValues

        // FIXED: Use the same payload structure as FormsHintController and createRowDeleteChange
        let payload: [String: Any] = [
            Constants.rowIdKey: rowID,
            Constants.schemaIdKey: originalChange.change?[Constants.schemaIdKey] as? String ?? "",
            Constants.parentPathKey: originalChange.change?[Constants.parentPathKey] as? String ?? "",
            Constants.rowKey: newRow
        ]

        guard let targetField = document.fields.first(where: { $0.identifier == targetFieldID }),
              let actualFieldId = targetField.id else {
            print("[TEST:] createRowCreateChange - ERROR: Cannot find field with identifier: \(targetFieldID)")
            print("[TEST:] createRowCreateChange - Available fields:")
            for field in document.fields {
                print("[TEST:] - identifier: '\(field.identifier ?? "nil")', id: '\(field.id ?? "nil")'")
            }
            fatalError("Field not found: \(targetFieldID)")
        }

        print("[TEST:] createRowCreateChange - using actualFieldId: \(actualFieldId), pageId: \(originalChange.pageId ?? "")")

        return Change(
            v: 1,
            sdk: Constants.sdkName,
            target: "field.value.rowCreate",
            _id: document.id ?? "",
            identifier: document.identifier ?? "",
            fileId: originalChange.fileId ?? "",
            pageId: originalChange.pageId ?? "",
            fieldId: actualFieldId,
            fieldIdentifier: targetFieldID,
            fieldPositionId: originalChange.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }

    private func createRowDeleteChange(
        from originalChange: Change,
        document: JoyDoc,
        targetFieldID: String,
        rowID: String
    ) -> Change? {
        print("[TEST:] createRowDeleteChange - creating delete change for row: \(rowID)")

        // FIXED: Use the same payload structure as FormsHintController
        let payload: [String: Any] = [
            Constants.rowIdKey: rowID,
            Constants.schemaIdKey: originalChange.change?[Constants.schemaIdKey] as? String ?? "",
            Constants.parentPathKey: originalChange.change?[Constants.parentPathKey] as? String ?? "",
            Constants.rowKey: [
                Constants.idKey: rowID,
                Constants.cellsKey: [:]  // Empty cells for delete
            ]
        ]

        guard let targetField = document.fields.first(where: { $0.identifier == targetFieldID }),
              let actualFieldId = targetField.id else {
            print("[TEST:] createRowDeleteChange - ERROR: Cannot find field with identifier: \(targetFieldID)")
            return nil
        }

        print("[TEST:] createRowDeleteChange - using actualFieldId: \(actualFieldId)")

        // FIXED: Use document.id instead of originalChange.id (same as create and FormsHintController)
        return Change(
            v: 1,
            sdk: Constants.sdkName,
            target: "field.value.rowDelete",
            _id: document.id ?? "",
            identifier: document.identifier ?? "",
            fileId: originalChange.fileId ?? "",
            pageId: originalChange.pageId ?? "",
            fieldId: actualFieldId,
            fieldIdentifier: targetFieldID,
            fieldPositionId: originalChange.fieldPositionId ?? "",
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }
}


private struct Constants {
    static let deficiencySummaryIdentifier = "deficiency_summary"
    static let generateDeficiencySummaryIdentifier = "generate_deficiency_summary"
    static let deficienciesIdentifier = "deficiencies"
    static let collectionSchemaIdKey = "collectionSchemaId"
    static let deficiencyKey = "_deficiency"
    static let idKey = "_id"
    static let valueKey = "value"
    static let rowIdKey = "rowId"
    static let rowKey = "row"
    static let cellsKey = "cells"
    static let schemaIdKey = "schemaId"
    static let parentPathKey = "parentPath"
    static let sdkName = "swift"
}
