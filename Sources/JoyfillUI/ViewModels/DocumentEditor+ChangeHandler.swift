//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 05/12/24.
//

import JoyfillModel
import Foundation

extension DocumentEditor {
    func deleteRows(rowIDs: [String], tableDataModel: TableDataModel) {
        guard !rowIDs.isEmpty else {
            return
        }
        let fieldId = tableDataModel.fieldId
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
        onChangeForDelete(tableDataModel: tableDataModel, rowIDs: rowIDs)
    }

    func duplicateRow(selectedRows: [String], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []

        selectedRows.forEach { rowID in
            var element = elements.first(where: { $0.id == rowID })!
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder

        let changeEvent = FieldChangeData(fieldID: tableDataModel.fieldId, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
    }

    func moveUP(rowID: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
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
        let changeEvent = FieldChangeData(fieldID: tableDataModel.fieldId, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    func moveDown(rowID: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
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
        let changeEvent = FieldChangeData(fieldID: tableDataModel.fieldId, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: fieldMap[fieldId]?.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    func insertLastRow(id: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []

        elements.append(ValueElement(id: id))
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder?.append(id)

        let changeEvent = FieldChangeData(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
        refreshField(fieldId: fieldId)
    }

    func addRow(selectedRows: [String], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []

        selectedRows.forEach { rowID in
            let newRowID = generateObjectId()
            var element = ValueElement(id: newRowID)
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder

        let changeEvent = FieldChangeData(fieldID: tableDataModel.fieldId, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    func addRowWithFilter(id: String, filterModels: [FilterModel], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []

        var newRow = ValueElement(id: id)
        elements.append(newRow)
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder?.append(id)
        for filterModel in filterModels {
            cellDidChange(rowId: id, colIndex: filterModel.colIndex, editedCellId: filterModel.colID, value: filterModel.filterText, fieldId: fieldId)
        }

        let changeEvent = FieldChangeData(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumnLocal, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }

        switch editedCell.type {
        case "text":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.title ?? ""), fieldId: fieldId)
        case "dropdown":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.defaultDropdownSelectedId ?? ""), fieldId: fieldId)
        case "image":
            let convertedImages = editedCell.valueElements?.map { $0.toValueElement() } ?? []
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.valueElementArray(convertedImages), fieldId: fieldId)
        default:
            return
        }
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCellId: String, value: String, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }

        changeCell(elements: elements, index: index, editedCellId: editedCellId, newCell: ValueUnion.string(value), fieldId: fieldId)
    }

    func sendEventsIfNeeded(tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId
        let changeEvent = FieldChangeData(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: fieldMap[fieldId]?.value)
        let currentField = field(fieldID: fieldId)!
        handleFieldsOnChange(event: changeEvent, currentField: currentField)
        refreshField(fieldId: tableDataModel.fieldId)
    }

    func onChange(event: FieldChangeData) {
        var currentField = field(fieldID: event.fieldID)!
        guard currentField.value != event.updateValue || event.chartData != nil else { return }
        guard !((currentField.value == nil || currentField.value!.nullOrEmpty) && (event.updateValue == nil || event.updateValue!.nullOrEmpty) && (event.chartData == nil)) else { return }
        updateField(event: event)
        currentField = field(fieldID: event.fieldID)!
        handleFieldsOnChange(event: event, currentField: currentField)
    }

    func onFocus(event: FieldEvent) {
        events?.onFocus(event: event)
    }

    func onBlur(event: FieldEvent) {
        events?.onBlur(event: event)
    }

    func onUpload(event: JoyfillModel.UploadEvent) {
        events?.onUpload(event: event)
    }
}


extension DocumentEditor {
    private func addRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: addRowChanges(fieldData: field, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    private func onChangeForDelete(tableDataModel: TableDataModel, rowIDs: [String]) {
        let event = FieldChangeData(fieldID: tableDataModel.fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: fieldMap[tableDataModel.fieldId]?.value)
        let targetRowIndexes = rowIDs.map { TargetRowModel.init(id: $0, index: 0)}
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
        refreshField(fieldId: tableDataModel.fieldId)
    }

    private func moveRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
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
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: documentID!,
                            identifier: documentIdentifier,
                            fileId: event.fileID!,
                            pageId: event.pageID!,
                            fieldId: event.fieldID,
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

    private func changeCell(elements: [ValueElement], index: Int, editedCellId: String?, newCell: ValueUnion, fieldId: String) {
        var elements = elements
        if var cells = elements[index].cells {
            cells[editedCellId ?? ""] = newCell
            elements[index].cells = cells
        } else {
            elements[index].cells = [editedCellId ?? "" : newCell]
        }
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
    }
}
