//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 05/12/24.
//

import JoyfillModel
import Foundation

extension DocumentEditor {
    public func deleteRows(rowIDs: [String], fieldIdentifier: FieldIdentifier) {
        guard !rowIDs.isEmpty else {
            return
        }
        let fieldId = fieldIdentifier.fieldID
        var field = fieldMap[fieldId]!
        var lastRowOrder = field.rowOrder ?? []
        guard var elements = field.valueToValueElements else { return }

        for row in rowIDs {
            guard let index = elements.firstIndex(where: { $0.id == row }) else {
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

    public func duplicateRows(rowIDs: [String], fieldIdentifier: FieldIdentifier) -> [Int: ValueElement]{
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return [:]
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        
        var changes = [Int: ValueElement]()

        rowIDs.forEach { rowID in
            var element = elements.first(where: { $0.id == rowID })!
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
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

    public func moveRowUp(rowID: String, fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard lastRowIndex != 0 else {
            return
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex-1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex-1)]
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
    }

    public func moveRowDown(rowID: String, fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard (lastRowOrder.count - 1) != lastRowIndex else {
            return
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex+1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex+1)]
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
    }

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

    public func insertBelow(selectedRowID: String, fieldIdentifier: FieldIdentifier) -> (ValueElement, Int)? {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return nil
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        
        let newRowID = generateObjectId()
        var element = ValueElement(id: newRowID)
        elements.append(element)
        let lastRowIndex = lastRowOrder.firstIndex(of: selectedRowID)!
        lastRowOrder.insert(newRowID, at: lastRowIndex+1)
        targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder

        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)

        return (element, lastRowIndex+1)
        
    }

    func insertRowWithFilter(id: String, filterModels: [FilterModel], fieldIdentifier: FieldIdentifier, tableDataModel: TableDataModel) -> ValueElement? {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
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

    public func bulkEdit(changes: [String: String], selectedRows: [String], fieldIdentifier: FieldIdentifier) {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
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

    public func onChange(fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        let currentField = field(fieldID: fieldId)!
        handleFieldsOnChange(event: changeEvent, currentField: currentField)
    }

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
        var changes = [Change]()
        let field = field(fieldID: event.fieldIdentifier.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fieldIdentifier.fileID!,
                                pageId: event.fieldIdentifier.pageID!,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: addRowChanges(fieldData: field, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    private func onChangeForDelete(fieldIdentifier: FieldIdentifier, rowIDs: [String]) {
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldIdentifier.fieldID]?.value)
        let targetRowIndexes = rowIDs.map { TargetRowModel.init(id: $0, index: 0)}
        var changes = [Change]()
        let field = field(fieldID: event.fieldIdentifier.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fieldIdentifier.fileID!,
                                pageId: event.fieldIdentifier.pageID!,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
//        refreshField(fieldId: fieldIdentifier.fieldID, fieldIdentifier: fieldIdentifier)
    }

    private func moveRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldIdentifier.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fieldIdentifier.fileID!,
                                pageId: event.fieldIdentifier.pageID!,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
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
        let fieldPosition = fieldPosition(fieldID: event.fieldIdentifier.fieldID)!
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: documentID!,
                            identifier: documentIdentifier,
                            fileId: event.fieldIdentifier.fileID!,
                            pageId: event.fieldIdentifier.pageID!,
                            fieldId: event.fieldIdentifier.fieldID,
                            fieldIdentifier: currentField.identifier!,
                            fieldPositionId: fieldPosition.id!,
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
}
