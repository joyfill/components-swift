//
//  File.swift
//
//
//  Created by Vishnu Dutt on 05/12/24.
//

import JoyfillModel
import Foundation

extension DocumentEditor {
    /// Deletes specified rows from a table field.
    /// - Parameters:
    ///   - rowIDs: An array of String identifiers for the rows to be deleted.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func deleteRows(rowIDs: [String], fieldIdentifier: FieldIdentifier) {
        guard !rowIDs.isEmpty else {
            Log("No rows to delete", type: .warning)
            return
        }
        
        let fieldId = fieldIdentifier.fieldID
        var field = fieldMap[fieldId]!
        var lastRowOrder = field.rowOrder ?? []
        guard var elements = field.valueToValueElements else { 
            Log("No elements found for field: \(fieldId)", type: .error)
            return 
        }

        for row in rowIDs {
            guard let index = elements.firstIndex(where: { $0.id == row }) else {
                Log("Row not found: \(row)", type: .error)
                return
            }
            var element = elements[index]
            element.setDeleted()
            elements[index] = element
            lastRowOrder.removeAll(where: { $0 == row })
        }
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        onChangeForDelete(fieldIdentifier: fieldIdentifier, rowIDs: rowIDs)
    }

    /// Duplicates specified rows in a table field.
    /// - Parameters:
    ///   - rowIDs: An array of String identifiers for the rows to be duplicated.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func duplicateRows(rowIDs: [String], fieldIdentifier: FieldIdentifier) -> [Int: ValueElement] {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            Log("No elements found for field: \(fieldId)", type: .error)
            return [:]
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        
        var changes = [Int: ValueElement]()

        rowIDs.forEach { rowID in
            guard let originalElement = elements.first(where: { $0.id == rowID }) else {
                Log("Original row not found: \(rowID)", type: .error)
                return
            }
            
            var element = originalElement
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            
            guard let lastRowIndex = lastRowOrder.firstIndex(of: rowID) else {
                Log("Row order index not found for: \(rowID)", type: .error)
                return
            }
            
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
            changes[lastRowIndex+1] = element
        }

        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder

        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        return changes
    }

    /// Moves a specified row up in a table field.
    /// - Parameters:
    ///   - rowID: The String identifier of the row to be moved up.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func moveRowUp(rowID: String, fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            Log("No elements found for field: \(fieldId)", type: .error)
            return
        }
        
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        guard let lastRowIndex = lastRowOrder.firstIndex(of: rowID) else {
            Log("Row index not found: \(rowID)", type: .error)
            return
        }

        guard lastRowIndex != 0 else {
            Log("Row already at the top, cannot move up", type: .warning)
            return
        }
        
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex-1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex-1)]
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
    }

    /// Moves a specified row down in a table field.
    /// - Parameters:
    ///   - rowID: The String identifier of the row to be moved down.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func moveRowDown(rowID: String, fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            Log("No elements found for field: \(fieldId)", type: .error)
            return
        }
        
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        guard let lastRowIndex = lastRowOrder.firstIndex(of: rowID) else {
            Log("Row index not found: \(rowID)", type: .error)
            return
        }

        guard (lastRowOrder.count - 1) != lastRowIndex else {
            Log("Row already at the bottom, cannot move down", type: .warning)
            return
        }
        
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex+1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex+1)]
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
    }

    /// Inserts a new row at the end of a table field.
    /// - Parameters:
    ///   - id: The String identifier for the new row.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func insertRowAtTheEnd(id: String, fieldIdentifier: FieldIdentifier) -> ValueElement {
        let fieldId = fieldIdentifier.fieldID
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []

        elements.append(ValueElement(id: id))
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder?.append(id)

        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
        
        return elements.last!
    }

    /// Inserts new rows below specified rows in a table field.
    /// - Parameters:
    ///   - selectedRows: An array of String identifiers for the rows below which new rows will be inserted.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func insertBelow(selectedRowID: String, fieldIdentifier: FieldIdentifier) -> (ValueElement, Int)? {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            Log("No elements found for field: \(fieldId)", type: .error)
            return nil
        }
        
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        
        let newRowID = generateObjectId()
        var element = ValueElement(id: newRowID)
        elements.append(element)
        
        guard let lastRowIndex = lastRowOrder.firstIndex(of: selectedRowID) else {
            Log("Selected row index not found: \(selectedRowID)", type: .error)
            return nil
        }
        
        lastRowOrder.insert(newRowID, at: lastRowIndex+1)
        targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder

        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)

        return (element, lastRowIndex+1)
        
    }

    /// Inserts a new row with specified filter conditions in a table field.
    /// - Parameters:
    ///   - id: The String identifier for the new row.
    ///   - filterModels: An array of `FilterModel` objects specifying the filter conditions.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    func insertRowWithFilter(id: String, filterModels: [FilterModel], fieldIdentifier: FieldIdentifier, tableDataModel: TableDataModel) -> ValueElement? {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
            Log("No elements found for field: \(fieldIdentifier.fieldID)", type: .error)
            return nil
        }

        var newRow = ValueElement(id: id)

        for filterModel in filterModels {
            let change = filterModel.filterText
            if var cells = newRow.cells {
                cells[filterModel.colID ?? ""] = ValueUnion.string(change)
                newRow.cells = cells
            } else {
                newRow.cells = [filterModel.colID ?? "" : ValueUnion.string(change)]
            }
        }
        elements.append(newRow)

        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldIdentifier.fieldID]?.rowOrder?.append(id)
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
      
        return newRow
    }

    /// Performs bulk editing on specified rows in a table field.
    /// - Parameters:
    ///   - changes: A dictionary of String keys and values representing the changes to be made.
    ///   - selectedRows: An array of String identifiers for the rows to be edited.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func bulkEdit(changes: [String: String], selectedRows: [String], fieldIdentifier: FieldIdentifier) {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
            Log("No elements found for field: \(fieldIdentifier.fieldID)", type: .error)
            return
        }
        for rowId in selectedRows {
            for cellDataModelId in changes.keys {
                if let change = changes[cellDataModelId] {
                    guard let index = elements.firstIndex(where: { $0.id == rowId }) else { return }
                    if var cells = elements[index].cells {
                        cells[cellDataModelId ?? ""] = ValueUnion.string(change)
                        elements[index].cells = cells
                    } else {
                        elements[index].cells = [cellDataModelId ?? "" : ValueUnion.string(change)]
                    }
                }
            }
        }

        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
    }

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }

        guard let rowIndex = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }

        switch cellDataModel.type {
        case "text":
            changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.title ?? ""), fieldId: fieldId)
        case "dropdown":
            changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? ""), fieldId: fieldId)
        case "image":
            changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.valueElementArray(cellDataModel.valueElements ?? []), fieldId: fieldId)
        default:
            return
        }
    }

    /// Handles changes in a specific field.
    /// - Parameter fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the changed field.
    public func onChange(fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        let currentField = field(fieldID: fieldId)!
        updateField(event: changeEvent, fieldIdentifier: fieldIdentifier)
        handleFieldsOnChange(event: changeEvent, currentField: currentField)
    }

    /// Handles changes based on a `FieldChangeData` event.
    /// - Parameter event: A `FieldChangeData` object representing the change event.
    public func onChange(event: FieldChangeData) {
        var currentField = field(fieldID: event.fieldIdentifier.fieldID)!
        guard currentField.value != event.updateValue || event.chartData != nil else { return }
        guard !((currentField.value == nil || currentField.value!.nullOrEmpty) && (event.updateValue == nil || event.updateValue!.nullOrEmpty) && (event.chartData == nil)) else { return }
        updateField(event: event, fieldIdentifier: event.fieldIdentifier)
        currentField = field(fieldID: event.fieldIdentifier.fieldID)!
        handleFieldsOnChange(event: event, currentField: currentField)
    }

    func onFocus(event: FieldIdentifier) {
        events?.onFocus(event: event)
    }

    func onBlur(event: FieldIdentifier) {
        events?.onBlur(event: event)
    }

    func onUpload(event: JoyfillModel.UploadEvent) {
        events?.onUpload(event: event)
    }
}

extension DocumentEditor {
    private func addRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        guard let documentID = documentID else {
            Log("DocumentID is missing", type: .error)
            return
        }
        
        guard let fileID = event.fieldIdentifier.fileID else {
            Log("FileID is missing for document", type: .error)
            return
        }
        
        guard let pageID = event.fieldIdentifier.pageID else {
            Log("PageID is missing for document", type: .error)
            return
        }
        
        guard let field = field(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field not found: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldIdentifier = field.identifier else {
            Log("Field identifier is missing for field: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field position not found for field: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldPositionID = fieldPosition.id else {
            Log("Field position ID is missing for field: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                              sdk: "swift",
                              target: "field.value.rowCreate",
                              _id: documentID,
                              identifier: documentIdentifier,
                              fileId: fileID,
                              pageId: pageID,
                              fieldId: event.fieldIdentifier.fieldID,
                              fieldIdentifier: fieldIdentifier,
                              fieldPositionId: fieldPositionID,
                              change: addRowChanges(fieldData: field, targetRow: targetRow),
                              createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    private func onChangeForDelete(fieldIdentifier: FieldIdentifier, rowIDs: [String]) {
        guard let documentID = documentID else {
            Log("DocumentID is missing for delete operation", type: .error)
            return
        }
        
        guard let fileID = fieldIdentifier.fileID else {
            Log("FileID is missing for delete operation", type: .error)
            return
        }
        
        guard let pageID = fieldIdentifier.pageID else {
            Log("PageID is missing for delete operation", type: .error)
            return
        }
        
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldIdentifier.fieldID]?.value)
        let targetRowIndexes = rowIDs.map { TargetRowModel(id: $0, index: 0)}
        var changes = [Change]()
        
        guard let field = field(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field not found for delete operation: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field position not found for delete operation: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldIdentifier = field.identifier else {
            Log("Field identifier is missing for delete operation", type: .error)
            return
        }
        
        guard let fieldPositionID = fieldPosition.id else {
            Log("Field position ID is missing for delete operation", type: .error)
            return
        }
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                              sdk: "swift",
                              target: "field.value.rowDelete",
                              _id: documentID,
                              identifier: documentIdentifier,
                              fileId: fileID,
                              pageId: pageID,
                              fieldId: event.fieldIdentifier.fieldID,
                              fieldIdentifier: fieldIdentifier,
                              fieldPositionId: fieldPositionID,
                              change: ["rowId": targetRow.id],
                              createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
//        refreshField(fieldId: fieldIdentifier.fieldID, fieldIdentifier: fieldIdentifier)
    }

    private func moveRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        guard let documentID = documentID else {
            Log("DocumentID is missing for move operation", type: .error)
            return
        }
        
        guard let fileID = event.fieldIdentifier.fileID else {
            Log("FileID is missing for move operation", type: .error)
            return
        }
        
        guard let pageID = event.fieldIdentifier.pageID else {
            Log("PageID is missing for move operation", type: .error)
            return
        }
        
        guard let field = field(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field not found for move operation: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field position not found for move operation: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldIdentifier = field.identifier else {
            Log("Field identifier is missing for move operation", type: .error)
            return
        }
        
        guard let fieldPositionID = fieldPosition.id else {
            Log("Field position ID is missing for move operation", type: .error)
            return
        }
        
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                              sdk: "swift",
                              target: "field.value.rowMove",
                              _id: documentID,
                              identifier: documentIdentifier,
                              fileId: fileID,
                              pageId: pageID,
                              fieldId: event.fieldIdentifier.fieldID,
                              fieldIdentifier: fieldIdentifier,
                              fieldPositionId: fieldPositionID,
                              change: [
                                "rowId": targetRow.id,
                                "targetRowIndex": targetRow.index,
                              ],
                              createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
    }

    private func handleFieldsOnChange(event: FieldChangeData, currentField: JoyDocField) {
        guard let documentID = documentID else {
            Log("DocumentID is missing for field update", type: .error)
            return
        }
        
        guard let fileID = event.fieldIdentifier.fileID else {
            Log("FileID is missing for field update", type: .error)
            return
        }
        
        guard let pageID = event.fieldIdentifier.pageID else {
            Log("PageID is missing for field update", type: .error)
            return
        }
        
        guard let fieldIdentifier = currentField.identifier else {
            Log("Field identifier is missing for field update", type: .error)
            return
        }
        
        guard let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Field position not found for field update: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        
        guard let fieldPositionID = fieldPosition.id else {
            Log("Field position ID is missing for field update", type: .error)
            return
        }
        
        var change = Change(v: 1,
                          sdk: "swift",
                          target: "field.update",
                          _id: documentID,
                          identifier: documentIdentifier,
                          fileId: fileID,
                          pageId: pageID,
                          fieldId: event.fieldIdentifier.fieldID,
                          fieldIdentifier: fieldIdentifier,
                          fieldPositionId: fieldPositionID,
                          change: changes(fieldData: currentField),
                          createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: document)
    }

    private func changes(fieldData: JoyDocField) -> [String: Any] {
        switch fieldData.type {
        case "chart":
            return chartChanges(fieldData: fieldData)
        default:
            return ["value": fieldData.value!.dictionary]
        }
    }

    private func chartChanges(fieldData: JoyDocField) -> [String: Any] {
        var valueDict = ["value": fieldData.value!.dictionary]
        valueDict["yTitle"] = fieldData.yTitle
        valueDict["yMin"] = fieldData.yMin
        valueDict["yMax"] = fieldData.yMax
        valueDict["xTitle"] = fieldData.xTitle
        valueDict["xMin"] = fieldData.xMin
        valueDict["xMax"] = fieldData.xMax
        return valueDict
    }

    private func addRowChanges(fieldData: JoyDocField, targetRow: TargetRowModel) -> [String: Any] {
        let lastValueElement = fieldData.value!.valueElements?.first(where: { valueElement in
            valueElement.id == targetRow.id
        })
        var valueDict: [String: Any] = ["row": lastValueElement?.anyDictionary]
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }

    private func changeCell(elements: [ValueElement], index: Int, cellDataModelId: String, newCell: ValueUnion, fieldId: String) {
        var elements = elements
        if var cells = elements[index].cells {
            cells[cellDataModelId] = newCell
            elements[index].cells = cells
        } else {
            elements[index].cells = [cellDataModelId ?? "" : newCell]
        }
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
    }
    
    func onChangeDuplicatePage(view: ModelView? = nil,viewId: String, page: Page, fields: [JoyDocField], fileId: String, targetIndex: Int, newFields: [JoyDocField], viewPage: Page? = nil) {
        var newFieldsArray: [Change] = []
        guard let documentID = documentID else {
            Log("DocumentID is missing for duplicate page on change", type: .error)
            return
        }
        guard let documentIdentifier = documentIdentifier else {
            Log("DocumentIdentifier is missing for duplicate page on change", type: .error)
            return
        }
        
        if newFields.count > 0 {
            for field in newFields {
                newFieldsArray.append(
                    Change(v: 1,
                           sdk: "swift",
                           id: documentID,
                           identifier: documentIdentifier,
                           target: "field.create",
                           fileId: fileId,
                           change: field.dictionary,
                           createdOn: Date().timeIntervalSince1970)
                )
            }
        }
        
        if !viewId.isEmpty {
            newFieldsArray.append(Change(v: 1,
                                         sdk: "swift",
                                         id: documentID,
                                         identifier: documentIdentifier,
                                         target: "page.create",
                                         fileId: fileId,
                                         viewType: "mobile",
                                         viewId: viewId,
                                         change: [
                                            "page": viewPage!.dictionary,
                                            "targetIndex": targetIndex
                                         ],
                                         createdOn: Date().timeIntervalSince1970)
            )
        }
        newFieldsArray.append(Change(v: 1,
                                     sdk: "swift",
                                     id: documentID,
                                     identifier: documentIdentifier,
                                     target: "page.create",
                                     fileId: fileId,
                                     change: [
                                        "page": page.dictionary,
                                        "targetIndex": targetIndex
                                     ],
                                     createdOn: Date().timeIntervalSince1970)
        )
        events?.onChange(changes: newFieldsArray, document: document)
    }
}
