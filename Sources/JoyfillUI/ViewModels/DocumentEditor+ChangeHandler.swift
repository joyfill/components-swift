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
        guard var field = fieldMap[fieldId] else {
            Log("Field not found: \(fieldId)", type: .error)
            return
        }
        guard var lastRowOrder = field.rowOrder else {
            return
        }
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
    
    public func deleteNestedRows(rowIDs: [String], fieldIdentifier: FieldIdentifier, rootSchemaKey: String, nestedKey: String, parentRowId: String) -> [ValueElement] {
        guard !rowIDs.isEmpty else { return [] }
        let fieldId = fieldIdentifier.fieldID
        guard var field = fieldMap[fieldId] else {
            Log("Field not found: \(fieldId)", type: .error)
            return []
        }
        guard var elements = field.valueToValueElements else { return [] }
        
        for row in rowIDs {
            if let index = elements.firstIndex(where: { $0.id == row }) {
                var element = elements[index]
                element.setDeleted()
                elements[index] = element
            } else {
                _ = deleteRowRecursively(rowId: row, in: &elements)
            }
        }
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        onChangeForDelete(fieldIdentifier: fieldIdentifier, rowIDs: rowIDs)
        var parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        onChangeForDeleteNestedRow(fieldIdentifier: fieldIdentifier, rowIDs: rowIDs, parentPath: parentPath, schemaId: nestedKey)
        return elements
    }

    private func deleteRowRecursively(rowId: String, in elements: inout [ValueElement]) -> Bool {
        for i in 0..<elements.count {
            if elements[i].id == rowId {
                var element = elements[i]
                element.setDeleted()
                elements[i] = element
                return true
            }
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if deleteRowRecursively(rowId: rowId, in: &nestedElements) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return true
                        }
                    }
                }
            }
        }
        return false
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
        guard var lastRowOrder = fieldMap[fieldId]?.rowOrder else {
            return [:]
        }
        
        var changes = [Int: ValueElement]()

        for rowID in rowIDs {
            guard var element = elements.first(where: { $0.id == rowID }) else {
                Log("Original row not found: \(rowID)", type: .error)
                continue
            }
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            
            guard let lastRowIndex = lastRowOrder.firstIndex(of: rowID) else {
                Log("Row order index not found for: \(rowID)", type: .error)
                continue
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
    
    public func duplicateNestedRows(selectedRowIds: [String], fieldIdentifier: FieldIdentifier, rootSchemaKey: String, nestedKey: String, parentRowId: String) -> ([Int: ValueElement], [ValueElement]) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return ([:],[])
        }
        var targetRows = [TargetRowModel]()
        var changes = [Int: ValueElement]()
        
        for rowId in selectedRowIds {
            if let index = elements.firstIndex(where: { $0.id == rowId }) {
                let original = elements[index]
                let duplicate = duplicateValueElement(original)
                guard let duplicateID = duplicate.id else {
                    Log("Could not find id for duplicate row", type: .error)
                    continue
                }
                elements.insert(duplicate, at: index + 1)
                targetRows.append(TargetRowModel(id: duplicateID, index: index + 1))
                changes[index + 1] = duplicate
            } else {
                if let target = duplicateNestedRow(rowId: rowId, in: &elements, changes: &changes) {
                    targetRows.append(target)
                }
            }
        }
        
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        var parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        
        addNestedRowOnChange(event: changeEvent,
                             targetRowIndexes: targetRows,
                             valueElements: Array(changes.values),
                             parentPath: parentPath,
                             schemaKey: nestedKey)
        return (changes, elements)
    }

    private func duplicateNestedRow(rowId: String, in elements: inout [ValueElement], changes: inout [Int: ValueElement]) -> TargetRowModel? {
        for i in 0..<elements.count {
            if elements[i].id == rowId {
                let duplicate = duplicateValueElement(elements[i])
                elements.insert(duplicate, at: i + 1)
                changes[i + 1] = duplicate
                guard let duplicateID = duplicate.id else {
                    Log("Could not find id for duplicate row", type: .error)
                    continue
                }
                return TargetRowModel(id: duplicateID, index: i + 1)
            }
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if let target = duplicateNestedRow(rowId: rowId, in: &nestedElements, changes: &changes) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return target
                        }
                    }
                }
            }
        }
        return nil
    }

    func duplicateValueElement(_ element: ValueElement) -> ValueElement {
        var duplicate = element
        duplicate.id = generateObjectId()
        
        if var children = duplicate.childrens {
            for key in children.keys {
                if let nestedElements = children[key]?.valueToValueElements {
                    let newNestedElements = nestedElements.map { duplicateValueElement($0) }
                    children[key]?.value = ValueUnion.valueElementArray(newNestedElements)
                }
            }
            duplicate.childrens = children
        }
        
        return duplicate
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
        guard var lastRowOrder = fieldMap[fieldId]?.rowOrder else {
            return
        }
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
    
    func rowUpdateEvent(
        fieldIdentifier: FieldIdentifier,
        rowID: String,
        cellDataModel: CellDataModel
    ) {
        guard var rowOrder = fieldMap[fieldIdentifier.fieldID]?.rowOrder
        else { return }
        guard let rowIndex = rowOrder.firstIndex(of: rowID) else {
            Log("Row index not found: \(rowID)", type: .error)
            return
        }
        guard let newCell = getNewCellValue(for: cellDataModel) else {
            Log("New cell not found: \(rowID)", type: .error)
            return
        }
        guard let dictionary = newCell.dictionary else {
            Log("dictionary not found from new cell: \(rowID)", type: .error)
            return
        }
        
        let cells = [
            cellDataModel.id: dictionary
        ]
        let row: [String : Any] = [
            "_id" : rowID,
            "cells" : cells
        ]
        sendRowUpdateEvent(for: fieldIdentifier, with: [row])
    }
    
    public func moveNestedRowUp(rowID: String, fieldIdentifier: FieldIdentifier, rootSchemaKey: String, nestedKey: String, parentRowId: String) -> [ValueElement] {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else { return [] }
        var parentPath: String = ""
        var targetRows: [TargetRowModel] = []
        
        if let topIndex = elements.firstIndex(where: { $0.id == rowID }) {
            guard topIndex != 0 else { return [] }
            elements.swapAt(topIndex, topIndex - 1)
            fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
            targetRows = [TargetRowModel(id: rowID, index: topIndex - 1)]
        } else if let (success, newIndex) = moveRowUpRecursively(rowID: rowID, in: &elements) {
            if success {
                fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
                targetRows = [TargetRowModel(id: rowID, index: newIndex)]
            }
        }
        parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveNestedRowOnChange(event: changeEvent, targetRowIndexes: targetRows, parentPath: parentPath, schemaId: nestedKey)
        return elements
    }

    private func moveRowUpRecursively(rowID: String, in elements: inout [ValueElement]) -> (Bool, Int)? {
        for i in 0..<elements.count {
            if elements[i].id == rowID {
                elements.swapAt(i, i - 1)
                return (true, i - 1)
            }
            // Not found at this level; search recursively in nested children.
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if let result = moveRowUpRecursively(rowID: rowID, in: &nestedElements) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return result
                        }
                    }
                }
            }
        }
        return nil
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
        guard var lastRowOrder = fieldMap[fieldId]?.rowOrder else {
            return
        }
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
    
    public func moveNestedRowDown(rowID: String, fieldIdentifier: FieldIdentifier, rootSchemaKey: String, nestedKey: String, parentRowId: String) -> [ValueElement] {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else { return [] }
        var parentPath: String = ""
        var targetRows: [TargetRowModel] = []
        
        if let topIndex = elements.firstIndex(where: { $0.id == rowID }) {
            guard topIndex < elements.count - 1 else { return [] }
            elements.swapAt(topIndex, topIndex + 1)
            fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
            targetRows = [TargetRowModel(id: rowID, index: topIndex + 1)]
        } else if let (success, newIndex) = moveRowDownRecursively(rowID: rowID, in: &elements) {
            if success {
                fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
                targetRows = [TargetRowModel(id: rowID, index: newIndex)]
            }
        }
        parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        moveNestedRowOnChange(event: changeEvent, targetRowIndexes: targetRows, parentPath: parentPath, schemaId: nestedKey)
        return elements
    }

    private func moveRowDownRecursively(rowID: String, in elements: inout [ValueElement]) -> (Bool, Int)? {
        for i in 0..<elements.count {
            if elements[i].id == rowID {
                // If the row is found, ensure it's not the last row in this nested array.
                guard i < elements.count - 1 else { return nil }
                elements.swapAt(i, i + 1)
                return (true, i + 1)
            }
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if let result = moveRowDownRecursively(rowID: rowID, in: &nestedElements) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return result
                        }
                    }
                }
            }
        }
        return nil
    }


    ///Inserts a new row below a specified row in a table field.
    /// - Parameters:
    ///   - selectedRowID: The String identifier of the row below which the new row will be inserted.
    ///   - cellValues: A dictionary mapping column IDs to their values in ValueUnion format.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    /// - Returns: A tuple containing the newly created ValueElement and its insert index if successful, nil otherwise.
    public func insertBelow(selectedRowID: String, cellValues: [String: ValueUnion], fieldIdentifier: FieldIdentifier) -> (ValueElement, Int)? {
        let fieldId = fieldIdentifier.fieldID
        
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return nil
        }
        
        guard var lastRowOrder = fieldMap[fieldId]?.rowOrder,
              let selectedRowIndex = lastRowOrder.firstIndex(of: selectedRowID) else {
            return nil
        }
        
        let newRowID = generateObjectId()
        var newRow = ValueElement(id: newRowID)
        
        if newRow.cells == nil {
            newRow.cells = [:]
        }
        for cellValue in cellValues {
            newRow.cells![cellValue.key] = cellValue.value
        }
        
        elements.append(newRow)
        let insertIndex = selectedRowIndex + 1
        lastRowOrder.insert(newRowID, at: insertIndex)
        
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: newRowID, index: insertIndex)])
        
        return (newRow, insertIndex)
    }
    
    public func insertBelowNestedRow(selectedRowID: String,
                                     cellValues: [String: ValueUnion],
                                     fieldIdentifier: FieldIdentifier,
                                     childrenKeys: [String]? = nil,
                                     rootSchemaKey: String,
                                     nestedKey: String,
                                     parentRowId: String) -> (all: [ValueElement], inserted: ValueElement)? {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            Log("No elements found for field: \(fieldId)", type: .error)
            return nil
        }

        let newRowID = generateObjectId()
        var newRow = ValueElement(id: newRowID)
        newRow.cells = [:]
        for (key, value) in cellValues {
            newRow.cells?[key] = value
        }
        let children = getEmptyChildrenObject()
        var childrens: [String: Children] = [:]
        if let childrenKeys = childrenKeys, !childrenKeys.isEmpty {
            for childrenSchemaKey in childrenKeys {
                childrens[childrenSchemaKey] = children
            }
        }
        newRow.childrens = childrens

        if let (insertedRow, insertIndex) = insertBelowNestedRecursively(selectedRowID: selectedRowID,
                                                                         in: &elements,
                                                                         newRow: newRow) {
            fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)

            let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier,
                                              updateValue: ValueUnion.valueElementArray(elements))
            var parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
            addNestedRowOnChange(event: changeEvent,
                                 targetRowIndexes: [TargetRowModel(id: newRowID, index: insertIndex)],
                                 valueElements: [newRow],
                                 parentPath: parentPath,
                                 schemaKey: nestedKey)
            return (elements, insertedRow)
        }

        return nil
    }

    private func insertBelowNestedRecursively(selectedRowID: String,
                                              in elements: inout [ValueElement],
                                              newRow: ValueElement) -> (ValueElement, Int)? {
        for i in 0..<elements.count {
            if elements[i].id == selectedRowID {
                let insertIndex = i + 1
                elements.insert(newRow, at: insertIndex)
                return (newRow, insertIndex)
            }
            if var childrenDict = elements[i].childrens {
                for (key, var child) in childrenDict {
                    if var nestedElements = child.valueToValueElements {
                        if let (insertedRow, insertIndex) = insertBelowNestedRecursively(selectedRowID: selectedRowID, in: &nestedElements, newRow: newRow) {
                            child.value = ValueUnion.valueElementArray(nestedElements)
                            childrenDict[key] = child
                            elements[i].childrens = childrenDict
                            return (insertedRow, insertIndex)
                        }
                    }
                }
            }
        }
        return nil
    }

    
    /// Inserts a new row with specified cell values in a table field.
    /// - Parameters:
    ///   - id: The String identifier for the new row.
    ///   - cellValues: A dictionary mapping column IDs to their values in ValueUnion format.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    /// - Returns: The newly created ValueElement if successful, nil otherwise.
    public func insertRowWithFilter(id: String, cellValues: [String: ValueUnion], fieldIdentifier: FieldIdentifier) -> ValueElement? {
        var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements ?? []

        var newRow = ValueElement(id: id)
        if newRow.cells == nil {
            newRow.cells = [:]
        }
        for cellValue in cellValues {
            newRow.cells![cellValue.key] = cellValue.value
        }
        elements.append(newRow)
        
        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldIdentifier.fieldID]?.rowOrder?.append(id)
        
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: elements.count - 1)])
        return newRow
    }
    
    private func insertNestedRow(in elements: inout [ValueElement],
                                 targetParentId: String,
                                 nestedKey: String,
                                 newRow: ValueElement) -> Bool {
        for i in 0..<elements.count {
            // If this element is the target parent:
            if elements[i].id == targetParentId {
                var children = elements[i].childrens ?? [:]
                if children.isEmpty {
                    children = [nestedKey : getEmptyChildrenObject()]
                }
                
                if children[nestedKey] == nil {
                    children[nestedKey] = getEmptyChildrenObject()
                }
                var nestedElements = children[nestedKey]?.valueToValueElements ?? []
                nestedElements.append(newRow)
                children[nestedKey]?.value = ValueUnion.valueElementArray(nestedElements)
                elements[i].childrens = children
                return true
            }
            // Otherwise, search recursively in this element’s children.
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if insertNestedRow(in: &nestedElements, targetParentId: targetParentId, nestedKey: nestedKey, newRow: newRow) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    private func computeParentPath(targetParentId: String, nestedKey: String, in child: [String : [ValueElement]]) -> String? {
        for (parentKey,elements) in child {
            guard !elements.isEmpty else { continue }
            for i in 0..<elements.count {
                if elements[i].id == targetParentId {
                    return "\(i).\(parentKey)." + "0.\(nestedKey)"
                }
                
                if let children = elements[i].childrens {
                    for (key, child) in children {
                        if let nestedElements = child.valueToValueElements,
                           let subPath = computeParentPath(targetParentId: targetParentId, nestedKey: nestedKey, in: [key : nestedElements]) {
                            return "\(i).\(parentKey)." + subPath
                        }
                    }
                }
            }
            return nil
        }
        return nil
    }
    
    public func insertRowWithFilter(id: String,
                                    cellValues: [String: ValueUnion],
                                    fieldIdentifier: FieldIdentifier,
                                    parentRowId: String? = nil,
                                    schemaKey: String? = nil,
                                    childrenKeys: [String]? = nil,
                                    rootSchemaKey: String) -> (all: [ValueElement], inserted: ValueElement)? {
        var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements ?? []
        var parentPath = ""
        var newRow = ValueElement(id: id)
        if newRow.cells == nil {
            newRow.cells = [:]
        }

        for (key, value) in cellValues {
            newRow.cells![key] = value
        }
        let children = getEmptyChildrenObject()
        var childrens: [String: Children] = [:]
        if let childrenKeys = childrenKeys, !childrenKeys.isEmpty {
            for childrenSchemaKey in childrenKeys {
                childrens[childrenSchemaKey] = children
            }
        }
        newRow.childrens = childrens
        if let parentRowId = parentRowId, let nestedKey = schemaKey {
            // Attempt to insert recursively into the nested structure.
            let inserted = insertNestedRow(in: &elements, targetParentId: parentRowId, nestedKey: nestedKey, newRow: newRow)
            if !inserted {
                // Parent row not found—handle the error as needed.
                return nil
            }
            parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        } else {
            // Insert as a top-level row.
            elements.append(newRow)
        }
        
        // Update the field's stored value.
        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
        
        // Fire off a change event.
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: ValueUnion.valueElementArray(elements))
        
        addNestedRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: elements.count - 1)], valueElements: [newRow], parentPath: parentPath, schemaKey: schemaKey ?? "")
        
        return (elements, newRow)
    }

    fileprivate func updateValueElementsForBulk(_ changes: [String : ValueUnion], _ elements: inout [ValueElement], _ rowID: String) {
        for cellDataModelId in changes.keys {
            if let change = changes[cellDataModelId] {
                guard let index = elements.firstIndex(where: { $0.id == rowID }) else {
                    return
                }
                if var cells = elements[index].cells {
                    cells[cellDataModelId] = change
                    elements[index].cells = cells
                } else {
                    elements[index].cells = [cellDataModelId : change]
                }
            }
        }
    }
    
    /// Performs bulk editing on specified rows in a table field.
    /// - Parameters:
    ///   - changes: A dictionary of String keys and values representing the changes to be made.
    ///   - selectedRows: An array of String identifiers for the rows to be edited.
    ///   - fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the table field.
    public func bulkEdit(changes: [String: ValueUnion], selectedRows: [String], fieldIdentifier: FieldIdentifier) {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
            Log("No elements found for field: \(fieldIdentifier.fieldID)", type: .error)
            return
        }
        var rows: [[String : Any]] = []
        var changesToSend: [String: Any] = [:]
        
        for change in changes {
            changesToSend[change.key] = change.value.dictionary
        }
        
        for rowID in selectedRows {
            let row: [String : Any] = [
                "_id" : rowID,
                "cells" : changesToSend
            ]
            rows.append(row)
            
            updateValueElementsForBulk(changes, &elements, rowID)
        }

        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
        
        sendRowUpdateEvent(for: fieldIdentifier, with: rows)
    }
    
    public func bulkEditForNested(changes: [String: ValueUnion], selectedRows: [String], fieldIdentifier: FieldIdentifier, parentRowId: String,nestedKey: String, rootSchemaKey: String ) -> ([ValueElement], [String : ValueElement]) {
        guard var elements = field(fieldID: fieldIdentifier.fieldID)?.valueToValueElements else {
            return ([],[:])
        }
        var updatedElements: [String : ValueElement] = [:]
        var rows: [[String : Any]] = []
        var changesToSend: [String: Any] = [:]
        
        for change in changes {
            changesToSend[change.key] = change.value.dictionary
        }
        
        for rowId in selectedRows {
            let row: [String : Any] = [
                "_id" : rowId,
                "cells" : changesToSend
            ]
            rows.append(row)
            updatedElements[rowId] = updateCells(for: rowId, with: changes, in: &elements)
        }
        
        fieldMap[fieldIdentifier.fieldID]?.value = ValueUnion.valueElementArray(elements)
        
        let fieldID = fieldIdentifier.fieldID
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldID]?.value)

        guard let currentField = fieldMap[fieldID] else {
            Log("Failed to find field \(fieldID)", type: .error)
            return ([], [:])
        }
        let parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
        handleRowCellOnChange(event: changeEvent, currentField: currentField, rows: rows, parentPath: parentPath, schemaId: nestedKey)
        return (elements, updatedElements)
    }

    private func updateCells(for rowId: String, with changes: [String: ValueUnion], in elements: inout [ValueElement]) -> ValueElement? {
        for i in 0..<elements.count {
            if elements[i].id == rowId {
                var cells = elements[i].cells ?? [:]
                for (cellDataModelId, change) in changes {
                    cells[cellDataModelId] = change
                }
                elements[i].cells = cells
                return elements[i]
            }
            // If not found at this level, search recursively in children.
            if var children = elements[i].childrens {
                for key in children.keys {
                    if var nestedElements = children[key]?.valueToValueElements {
                        if let updated = updateCells(for: rowId, with: changes, in: &nestedElements) {
                            children[key]?.value = ValueUnion.valueElementArray(nestedElements)
                            elements[i].childrens = children
                            return updated
                        }
                    }
                }
            }
        }
        return nil
    }

    private func getEmptyChildrenObject() -> Children {
        return Children(dictionary: [
            "value": ValueUnion.valueElementArray([])
        ])
    }

    func cellDidChange(rowId: String, cellDataModel: CellDataModel, fieldIdentifier: FieldIdentifier) -> [ValueElement] {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return []
        }
        
        guard let rowIndex = elements.firstIndex(where: { $0.id == rowId }) else {
            return []
        }
        
        // Fire row update event
        rowUpdateEvent(fieldIdentifier: fieldIdentifier, rowID: rowId, cellDataModel: cellDataModel)

        switch cellDataModel.type {
        case .text:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.title ?? ""), fieldId: fieldId)
        case .dropdown:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? ""), fieldId: fieldId)
        case .image:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.valueElementArray(cellDataModel.valueElements ?? []), fieldId: fieldId)
        case .date:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: cellDataModel.date.map(ValueUnion.double), fieldId: fieldId)
        case .number:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: cellDataModel.number.map(ValueUnion.double), fieldId: fieldId)
        case .multiSelect:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: cellDataModel.multiSelectValues.map(ValueUnion.array), fieldId: fieldId)
        case .barcode:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.title ?? ""), fieldId: fieldId)
        case .table:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: cellDataModel.multiSelectValues.map(ValueUnion.array), fieldId: fieldId)
        case .signature:
            return changeCell(elements: elements, index: rowIndex, cellDataModelId: cellDataModel.id, newCell: ValueUnion.string(cellDataModel.title ?? ""), fieldId: fieldId)
        default:
            return []
        }
    }
    
    private func getNewCellValue(for cellDataModel: CellDataModel) -> ValueUnion? {
        var newCell: ValueUnion?
        switch cellDataModel.type {
        case .text:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
        case .dropdown:
            newCell = ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? "")
        case .image:
            newCell = ValueUnion.valueElementArray(cellDataModel.valueElements ?? [])
        case .date:
            newCell = cellDataModel.date.map(ValueUnion.double)
        case .number:
            newCell = cellDataModel.number.map(ValueUnion.double)
        case .multiSelect:
            newCell = cellDataModel.multiSelectValues.map(ValueUnion.array)
        case .barcode:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
        case .signature:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
        default:
            break
        }
        return newCell
    }
    
    func nestedCellDidChange(rowId: String, cellDataModel: CellDataModel, fieldIdentifier: FieldIdentifier, rootSchemaKey: String, nestedKey: String, parentRowId: String, callOnChange: Bool) -> ([ValueElement], ValueElement?) {
        let fieldId = fieldIdentifier.fieldID
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return ([], nil)
        }
        var newCell: ValueUnion?
        var updatedElement: ValueElement? = nil
        switch cellDataModel.type {
        case .text:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .dropdown:
            newCell = ValueUnion.string(cellDataModel.defaultDropdownSelectedId ?? "")
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .image:
            newCell = ValueUnion.valueElementArray(cellDataModel.valueElements ?? [])
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .date:
            newCell = cellDataModel.date.map(ValueUnion.double)
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .number:
            newCell = cellDataModel.number.map(ValueUnion.double)
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .multiSelect:
            newCell = cellDataModel.multiSelectValues.map(ValueUnion.array)
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .barcode:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        case .signature:
            newCell = ValueUnion.string(cellDataModel.title ?? "")
            updatedElement = recursiveChangeCell(in: &elements, rowId: rowId, cellDataModelId: cellDataModel.id, newCell: newCell)
        default:
            return ([], nil)
        }
                
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        if callOnChange {
            let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
            let cells = [
                cellDataModel.id: newCell?.dictionary!
            ]
            let row: [String : Any] = [
                "_id" : rowId,
                "cells" : cells
            ]
            guard let currentField = fieldMap[fieldId] else {
                Log("Failed to find field \(fieldId)", type: .error)
                return ([], nil)
            }
            let parentPath = computeParentPath(targetParentId: parentRowId, nestedKey: nestedKey, in: [rootSchemaKey : elements]) ?? ""
            handleRowCellOnChange(event: changeEvent, currentField: currentField, rows: [row], parentPath: parentPath, schemaId: nestedKey)
        }

        return (elements, updatedElement)
    }

    /// Handles changes in a specific field.
    /// - Parameter fieldIdentifier: A `FieldIdentifier` object that uniquely identifies the changed field.
    public func onChange(fieldIdentifier: FieldIdentifier) {
        let fieldId = fieldIdentifier.fieldID
        let changeEvent = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldId]?.value)
        guard let currentField = field(fieldID: fieldId) else {
            Log("Could not find field with ID: \(fieldId)", type: .error)
            return
        }
        updateField(event: changeEvent, fieldIdentifier: fieldIdentifier)
        handleFieldsOnChange(event: changeEvent, currentField: currentField)
    }

    /// Handles changes based on a `FieldChangeData` event.
    /// - Parameter event: A `FieldChangeData` object representing the change event.
    public func onChange(event: FieldChangeData) {
        guard var currentField = field(fieldID: event.fieldIdentifier.fieldID) else {
            Log("Could not find field with ID: \(event.fieldIdentifier.fieldID)", type: .error)
            return
        }
        guard currentField.value != event.updateValue || event.chartData != nil else {
            Log("Either no change or same value was received", type: .info)
            return
        }
        guard !((currentField.value == nil || currentField.value!.nullOrEmpty) && (event.updateValue == nil || event.updateValue!.nullOrEmpty) && (event.chartData == nil)) else {
            Log("Either no change or same value was received", type: .info)
            return
        }
        updateField(event: event, fieldIdentifier: event.fieldIdentifier)
        if let field = field(fieldID: event.fieldIdentifier.fieldID) {
            currentField = field
            handleFieldsOnChange(event: event, currentField: currentField)
        } else {
            Log("Could not find field with ID: \(event.fieldIdentifier.fieldID)", type: .error)
        }
        
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
    
    func onCapture(event: JoyfillModel.CaptureEvent) {
        events?.onCapture(event: event)
    }
}

extension DocumentEditor {
    private func addRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }

        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: context.documentID,
                                identifier: context.documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: addRowChanges(fieldData: context.field, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }
    
    private func addNestedRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel], valueElements: [ValueElement], parentPath: String, schemaKey: String) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }
        
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            guard let valueElement = valueElements.first(where: { $0.id == targetRow.id }) else {
                Log("Value element not found for row: \(targetRow.id)", type: .error)
                continue
            }
            
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: context.documentID,
                                identifier: context.documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: addNestedRowChanges(valueElement: valueElement, targetRow: targetRow, parentPath: parentPath, schemaId: schemaKey),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    private func onChangeForDelete(fieldIdentifier: FieldIdentifier, rowIDs: [String]) {
        guard let context = makeFieldChangeContext(for: fieldIdentifier) else { return }
        
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldIdentifier.fieldID]?.value)
        let targetRowIndexes = rowIDs.map { TargetRowModel(id: $0, index: 0)}
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: context.documentID,
                                identifier: context.documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
//        refreshField(fieldId: fieldIdentifier.fieldID, fieldIdentifier: fieldIdentifier)
    }
    
    private func onChangeForDeleteNestedRow(fieldIdentifier: FieldIdentifier, rowIDs: [String], parentPath: String, schemaId: String) {
        guard let context = makeFieldChangeContext(for: fieldIdentifier) else { return }
        
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: fieldMap[fieldIdentifier.fieldID]?.value)
        let targetRowIndexes = rowIDs.map { TargetRowModel.init(id: $0, index: 0)}
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: context.documentID,
                                identifier: documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: ["parentPath": parentPath,
                                         "schemaId": schemaId,
                                         "rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
    }

    private func moveRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel]) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }
        
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: context.documentID,
                                identifier: context.documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: [
                                    "rowId": targetRow.id,
                                    "targetRowIndex": targetRow.index,
                                ],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
    }
    
    private func sendRowUpdateEvent(
        for fieldIdentifier: FieldIdentifier,
        with rows: [[String : Any]]
    ) {
        guard let context = makeFieldChangeContext(for: fieldIdentifier) else { return }
        var changes: [Change] = []
        for row in rows {
            changes.append(Change(v: 1,
                                  sdk: "swift",
                                  target: "field.value.rowUpdate",
                                  _id: context.documentID,
                                  identifier: context.documentIdentifier,
                                  fileId: context.fileID,
                                  pageId: context.pageID,
                                  fieldId: fieldIdentifier.fieldID,
                                  fieldIdentifier: context.fieldIdentifier,
                                  fieldPositionId: context.fieldPositionID,
                                  change: [
                                    "rowId": row["_id"],
                                    "row": row,
                                  ],
                                  createdOn: Date().timeIntervalSince1970)
            )
        }
        events?.onChange(changes: changes, document: document)
    }
    
    private func moveNestedRowOnChange(event: FieldChangeData, targetRowIndexes: [TargetRowModel], parentPath: String, schemaId: String) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }
        
        var changes = [Change]()
        
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: context.documentID,
                                identifier: context.documentIdentifier,
                                fileId: context.fileID,
                                pageId: context.pageID,
                                fieldId: event.fieldIdentifier.fieldID,
                                fieldIdentifier: context.fieldIdentifier,
                                fieldPositionId: context.fieldPositionID,
                                change: [
                                    "parentPath": parentPath,
                                    "schemaId": schemaId,
                                    "rowId": targetRow.id,
                                    "targetRowIndex": targetRow.index,
                                ],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
    }
    
    private func handleRowCellOnChange(event: FieldChangeData, currentField: JoyDocField, rows: [[String: Any]], parentPath: String, schemaId: String) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }
        var changes = [Change]()
        for row in rows {
            guard let rowId = row["_id"] else {
                Log("Row ID is missing for row cell change", type: .error)
                return
            }
            changes.append(
                Change(v: 1,
                       sdk: "swift",
                       target: "field.value.rowUpdate",
                       _id: context.documentID,
                       identifier: context.documentIdentifier,
                       fileId: context.fileID,
                       pageId: context.pageID,
                       fieldId: event.fieldIdentifier.fieldID,
                       fieldIdentifier: context.fieldIdentifier,
                       fieldPositionId: context.fieldPositionID,
                       change: [
                        "parentPath": parentPath,
                        "schemaId": schemaId,
                        "rowId": rowId,
                        "row": row // Row object with only changed cell
                       ],
                       createdOn: Date().timeIntervalSince1970)
            )
        }
        events?.onChange(changes: changes, document: document)
    }

    private func handleFieldsOnChange(event: FieldChangeData, currentField: JoyDocField) {
        guard let context = makeFieldChangeContext(for: event.fieldIdentifier) else { return }
        
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: context.documentID,
                            identifier: context.documentIdentifier,
                            fileId: context.fileID,
                            pageId: context.pageID,
                            fieldId: event.fieldIdentifier.fieldID,
                            fieldIdentifier: context.fieldIdentifier,
                            fieldPositionId: context.fieldPositionID,
                            change: changes(fieldData: currentField),
                            createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: document)
    }

    private func changes(fieldData: JoyDocField) -> [String: Any] {
        guard let value = fieldData.value else {
            return [:]
        }
        switch fieldData.type {
        case "chart":
            return chartChanges(fieldData: fieldData)
        default:
            return ["value": value.dictionary]
        }
    }

    private func chartChanges(fieldData: JoyDocField) -> [String: Any] {
        guard let value = fieldData.value?.dictionary else {
            Log("Chart field value dictionary is missing", type: .error)
            return [:]
        }
        
        var valueDict = ["value": value]
        valueDict["yTitle"] = fieldData.yTitle
        valueDict["yMin"] = fieldData.yMin
        valueDict["yMax"] = fieldData.yMax
        valueDict["xTitle"] = fieldData.xTitle
        valueDict["xMin"] = fieldData.xMin
        valueDict["xMax"] = fieldData.xMax
        return valueDict
    }

    private func addRowChanges(fieldData: JoyDocField, targetRow: TargetRowModel) -> [String: Any] {
        guard let value = fieldData.value else {
            Log("Field value is missing", type: .error)
            return [:]
        }
        
        let lastValueElement = value.valueElements?.first(where: { valueElement in
            valueElement.id == targetRow.id
        })
        var valueDict: [String: Any] = ["row": lastValueElement?.anyDictionary]
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }
    
    private func addNestedRowChanges(valueElement: ValueElement, targetRow: TargetRowModel, parentPath: String, schemaId: String) -> [String: Any] {
        var valueDict: [String: Any] = ["row": valueElement.anyDictionary]
        valueDict["parentPath"] = parentPath
        valueDict["schemaId"] = schemaId // The ID of the associated schema.
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }

    private func changeCell(elements: [ValueElement], index: Int, cellDataModelId: String, newCell: ValueUnion?, fieldId: String) -> [ValueElement] {
        var elements = elements
        
        if var cells = elements[index].cells {
            if let newCell = newCell {
                cells[cellDataModelId] = newCell
            } else {
                cells.removeValue(forKey: cellDataModelId)
            }
            elements[index].cells = cells
        } else if let newCell = newCell {
            elements[index].cells = [cellDataModelId: newCell]
        }
        
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        return elements
    }

    private func recursiveChangeCell(in elements: inout [ValueElement], rowId: String, cellDataModelId: String, newCell: ValueUnion?) -> ValueElement? {
        for i in 0..<elements.count {
            if elements[i].id == rowId {
                if var cells = elements[i].cells {
                    if let newCell = newCell {
                        cells[cellDataModelId] = newCell
                    } else {
                        cells.removeValue(forKey: cellDataModelId)
                    }
                    elements[i].cells = cells
                } else if let newCell = newCell {
                    elements[i].cells = [cellDataModelId: newCell]
                }
                return elements[i]
            }
            if var childrenDict = elements[i].childrens {
                for (key, var child) in childrenDict {
                    if var nestedElements = child.valueToValueElements {
                        if let updated = recursiveChangeCell(in: &nestedElements, rowId: rowId, cellDataModelId: cellDataModelId, newCell: newCell) {
                            child.value = ValueUnion.valueElementArray(nestedElements)
                            childrenDict[key] = child
                            elements[i].childrens = childrenDict
                            return updated
                        }
                    }
                }
            }
        }
        return nil
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
            guard let viewPage = viewPage else {
                Log(" viewPage is missing for duplicate page on change", type: .error)
                return
            }
            newFieldsArray.append(Change(v: 1,
                                         sdk: "swift",
                                         id: documentID,
                                         identifier: documentIdentifier,
                                         target: "page.create",
                                         fileId: fileId,
                                         viewType: "mobile",
                                         viewId: viewId,
                                         change: [
                                            "page": viewPage.dictionary,
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
extension DocumentEditor {
    func makeFieldChangeContext(for fieldIdentifier: FieldIdentifier) -> FieldChangeContext? {
        guard let documentID = documentID else {
            Log("DocumentID is missing", type: .error)
            return nil
        }
        guard let fileID = fieldIdentifier.fileID else {
            Log("FileID is missing", type: .error)
            return nil
        }
        guard let pageID = fieldIdentifier.pageID else {
            Log("PageID is missing", type: .error)
            return nil
        }
        guard let field = field(fieldID: fieldIdentifier.fieldID) else {
            Log("Field not found: \(fieldIdentifier.fieldID)", type: .error)
            return nil
        }
        guard let fieldPosition = fieldPosition(fieldID: fieldIdentifier.fieldID),
              let fieldPositionID = fieldPosition.id else {
            Log("Field position ID is missing for field: \(fieldIdentifier.fieldID)", type: .error)
            return nil
        }

        return FieldChangeContext(
            documentID: documentID,
            documentIdentifier: documentIdentifier,
            fileID: fileID,
            pageID: pageID,
            field: field,
            fieldIdentifier: field.identifier,
            fieldPositionID: fieldPositionID
        )
    }
}

struct FieldChangeContext {
    let documentID: String
    let documentIdentifier: String?
    let fileID: String
    let pageID: String
    let field: JoyDocField
    let fieldIdentifier: String?
    let fieldPositionID: String
}
