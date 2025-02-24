//
//  File.swift
//  Joyfill
//
//  Created by Vivek on 14/02/25.
//

import Foundation
import SwiftUI
import JoyfillModel

class CollectionViewModel: ObservableObject {
    @Published var tableDataModel: TableDataModel
    
    @Published var shouldShowAddRowButton: Bool = false
    @Published var showRowSelector: Bool = false
    @Published var nestedTableCount: Int = 0
    private var requiredColumnIds: [String] = []

    @Published var uuid = UUID()
    
    init(tableDataModel: TableDataModel) {
        self.tableDataModel = tableDataModel
        self.showRowSelector = tableDataModel.mode == .fill
        self.shouldShowAddRowButton = tableDataModel.mode == .fill
        self.nestedTableCount = tableDataModel.childrens.count
        setupCellModels()
        self.tableDataModel.filterRowsIfNeeded()
        self.requiredColumnIds = tableDataModel.tableColumns
            .filter { $0.required == true }
            .map { $0.id! }
    }

    func addCellModel(rowID: String, index: Int, valueElement: ValueElement) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForRow(tableColumns: tableDataModel.tableColumns, valueElement)
            for rowDataModel in rowDataModels {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let colIndex = self.tableDataModel.tableColumns.firstIndex( where: { fieldTableColumn in
                        fieldTableColumn.id == cellDataModel.id
                    })!
                    self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            self.tableDataModel.cellModels.insert(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: index)), at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: self.tableDataModel.cellModels.count)))
        }
    }
    
    func addNestedCellModel(rowID: String, index: Int, valueElement: ValueElement, columns: [FieldTableColumn], level: Int, childrens: [String : Children] = [:], rowType: RowType) {
        var rowCellModels = [TableCellModel]()
        let rowDataModels = tableDataModel.buildAllCellsForRow(tableColumns: columns, valueElement)
            for rowDataModel in rowDataModels {
                let cellModel = TableCellModel(rowID: rowID,
                                               data: rowDataModel,
                                               documentEditor: tableDataModel.documentEditor,
                                               fieldIdentifier: tableDataModel.fieldIdentifier,
                                               viewMode: .modalView,
                                               editMode: tableDataModel.mode) { cellDataModel in
                    let columnIndex = columns.firstIndex(where: { column in
                        column.id == cellDataModel.id
                    })
                    self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: rowID, colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                }
                rowCellModels.append(cellModel)
            }
        if self.tableDataModel.cellModels.count > (index - 1) {
            let rowDataModel = RowDataModel(rowID: rowID,
                                            cells: rowCellModels,
                                            rowType: rowType,
                                            childrens: childrens)
            
            self.tableDataModel.cellModels.insert(rowDataModel, at: index)
        } else {
            self.tableDataModel.cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .nestedRow(level: rowType.level, index: self.tableDataModel.cellModels.count, parentID: rowType.parentID), childrens: childrens))
        }
    }
    
    func getProgress(rowId: String) -> (Int, Int) {
        guard let rowCells = tableDataModel.cellModels
            .first(where: { $0.rowID == rowId })?.cells else {
            return (0,0)
        }
        
        let filledCount = rowCells.filter { cellModel in
            requiredColumnIds.contains(cellModel.data.id) && cellModel.data.isCellFilled
        }.count
        
        return (filledCount, requiredColumnIds.count)
    }
    
    func isColumnFilled(columnId: String) -> Bool {
        for rowDataModel in tableDataModel.cellModels {
            if let cellDataModel = rowDataModel.cells.first(where: { $0.data.id == columnId }) {
                if !cellDataModel.data.isCellFilled {
                    return false
                }
            }
        }
        return true
    }
    
    func setupCellModels() {
        var cellModels = [RowDataModel]()
        let rowDataMap = setupRows()
        let rowToChildrenMap = setupRowsChildrens()
        tableDataModel.rowOrder.enumerated().forEach { rowIndex, rowID in
            var rowCellModels = [TableCellModel]()
            let childrens = rowToChildrenMap[rowID] ?? [:]
            tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
                let columnModel = rowDataMap[rowID]?[colIndex]
                if let columnModel = columnModel {
                    let cellModel = TableCellModel(rowID: rowID,
                                                   data: columnModel,
                                                   documentEditor: tableDataModel.documentEditor,
                                                   fieldIdentifier: tableDataModel.fieldIdentifier,
                                                   viewMode: .modalView,
                                                   editMode: tableDataModel.mode) { cellDataModel in
                        self.cellDidChange(rowId: rowID, colIndex: colIndex, cellDataModel: cellDataModel, isNestedCell: false)
                    }
                    rowCellModels.append(cellModel)
                }
            }
            cellModels.append(RowDataModel(rowID: rowID, cells: rowCellModels, rowType: .row(index: cellModels.count), childrens: childrens))
        }
        tableDataModel.cellModels = cellModels
        tableDataModel.filteredcellModels = cellModels
    }

    private func setupRows() -> [String: [CellDataModel]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = tableDataModel.sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: tableDataModel.rowOrder)
        let tableColumns = tableDataModel.tableColumns
        var rowToCellMap = [String: [CellDataModel]]()
        for row in sortedRows {
            let cellRowModel = tableDataModel.buildAllCellsForRow(tableColumns: tableColumns, row)
            rowToCellMap[row.id!] = cellRowModel
        }
        return rowToCellMap
    }
    
    private func setupRowsChildrens() -> [String: [String : Children]] {
        guard let valueElements = tableDataModel.valueToValueElements, !valueElements.isEmpty else {
            return [:]
        }

        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        let sortedRows = tableDataModel.sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: tableDataModel.rowOrder)
        var rowToChildrenMap = [String: [String : Children]]()
        for row in sortedRows {
            rowToChildrenMap[row.id!] = row.childrens
        }
        return rowToChildrenMap
    }

    var rowTitle: String {
        "\(tableDataModel.selectedRows.count) " + (tableDataModel.selectedRows.count > 1 ? "rows": "row")
    }
    
    func getChildren(forRowId rowId: String, in elements: [ValueElement]) -> [String: Children]? {
        for element in elements {
            // If this element matches the rowId, return its children (if any)
            if element.id == rowId {
                return element.childrens
            }
            // Otherwise, if the element has nested children, search them recursively.
            if let childrenDict = element.childrens {
                for (_, child) in childrenDict {
                    if let nestedElements = child.valueToValueElements,
                       let found = getChildren(forRowId: rowId, in: nestedElements) {
                        return found
                    }
                }
            }
        }
        return nil
    }
        
    fileprivate func collapseATable(_ index: Int, _ rowDataModel: RowDataModel) {
        // Close all the nested rows for a particular row
        var indicesToRemoveArray: [Int] = childrensForASpecificRow(index, rowDataModel)
        
        for i in indicesToRemoveArray.reversed() {
            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.cellModels.remove(at: i)
        }
    }
    
    func expendSpecificTable(rowDataModel: RowDataModel, parentID: (columnID: String, rowID: String), level: Int) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            collapseATable(index, rowDataModel)
        } else {
            var cellModels = [RowDataModel]()
            
            switch rowDataModel.rowType {
            case .tableExpander(schemaValue: let schemaValue, level: let level, parentID: let parentID, _):
                cellModels.append(RowDataModel(rowID: UUID().uuidString,
                                               cells: [],
                                               rowType: .header(level: level + 1, tableColumns: schemaValue?.1.tableColumns ?? [])))
                let childrens = getChildren(forRowId: parentID?.rowID ?? "", in: tableDataModel.valueToValueElements ?? []) ?? [:]
                
                let valueToValueElements = childrens[schemaValue?.0 ?? ""]?.valueToValueElements?.filter { valueElement in
                    !(valueElement.deleted ?? false)
                } ?? []
                
                for row in valueToValueElements {
                    let cellDataModels = tableDataModel.buildAllCellsForRow(tableColumns: schemaValue?.1.tableColumns ?? [], row)
                    var subCells: [TableCellModel] = []
                    for cellDataModel in cellDataModels {
                        let cellModel = TableCellModel(rowID: row.id ?? "",
                                                       data: cellDataModel,
                                                       documentEditor: tableDataModel.documentEditor,
                                                       fieldIdentifier: tableDataModel.fieldIdentifier,
                                                       viewMode: .modalView,
                                                       editMode: tableDataModel.mode) { cellDataModel in
                            let columnIndex = schemaValue?.1.tableColumns?.firstIndex(where: { column in
                                column.id == cellDataModel.id
                            })
                            self.tableDataModel.valueToValueElements = self.cellDidChange(rowId: row.id ?? "", colIndex: columnIndex ?? 0, cellDataModel: cellDataModel, isNestedCell: true)
                            
                        }
                        subCells.append(cellModel)
                    }
                    
                    cellModels.append(RowDataModel(rowID: row.id ?? "",
                                                   cells: subCells,
                                                   rowType: .nestedRow(level: level + 1, index: index+1,
                                                                       parentID: parentID),
                                                   childrens: row.childrens ?? [:]
                                                  ))
                }
            default:
                break
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    fileprivate func collapseTables(_ index: Int, _ rowDataModel: RowDataModel, _ level: Int) {
        var indicesToRemove: [Int] = childrensForRows(index, rowDataModel, level)
                
        for i in indicesToRemove.reversed() {
            tableDataModel.filteredcellModels.remove(at: i)
            tableDataModel.cellModels.remove(at: i)
        }
    }
    
    func childrensForRows(_ index: Int, _ rowDataModel: RowDataModel, _ level: Int) -> [Int] {
        var indices: [Int] = []
        for i in index + 1..<tableDataModel.cellModels.count {
            let nextRow = tableDataModel.cellModels[i]
            if rowDataModel.rowType == .nestedRow(level: level, index: rowDataModel.rowType.index) {
                //Stop at same level but next index of current nested row
                if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index + 1) {
                    break
                }
                //Stop if there is an tableExpander of low level
                if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level - 1) {
                    break
                }
                switch nextRow.rowType {
                case .header, .tableExpander:
                    indices.append(i)
                case .nestedRow(level: let nestedLevel, index: _, _):
                    let level = rowDataModel.rowType.level
                    if nestedLevel < level {
                        break
                    } else {
                        indices.append(i)
                    }
                case .row:
                    break
                }
            } else {
                if nextRow.rowType == .row(index: index + 1) {
                    break
                }
                switch nextRow.rowType {
                case .header, .nestedRow, .tableExpander:
                    indices.append(i)
                case .row:
                    break
                }
            }
        }
        return indices
    }
    
    fileprivate func childrensForASpecificRow(_ index: Int, _ rowDataModel: RowDataModel) -> [Int] {
        // Close all the nested rows for a particular row
        var indices: [Int] = []
        
        for i in index + 1..<tableDataModel.cellModels.count {
            let nextRow = tableDataModel.cellModels[i]
            
            //Stop if find another table expander of same level
            if nextRow.rowType == .tableExpander(level: rowDataModel.rowType.level) {
                break
            }
            //Stop if find nested row of same level
            if nextRow.rowType == .nestedRow(level: rowDataModel.rowType.level, index: rowDataModel.rowType.index) {
                break
            }
            switch nextRow.rowType {
            case .header, .tableExpander:
                indices.append(i)
            case .nestedRow(level: let nestedLevel, index: _, _):
                let level = rowDataModel.rowType.level
                if nestedLevel < level {
                    break
                } else {
                    indices.append(i)
                }
            case .row:
                break
            }
        }
        
        return indices
    }
    
    func expandTables(rowDataModel: RowDataModel, level: Int) {
        guard let index = tableDataModel.cellModels.firstIndex(of: rowDataModel) else { return }
        if rowDataModel.isExpanded {
            collapseTables(index, rowDataModel, level)
        } else {
            var cellModels = [RowDataModel]()

            for (id, children) in rowDataModel.childrens {
                let newRowID = UUID().uuidString
                if let schemaValue = tableDataModel.schema[id] {
                    cellModels.append(RowDataModel(rowID: newRowID,
                                                   cells: rowDataModel.cells,
                                                   rowType: .tableExpander(schemaValue: (id, schemaValue),
                                                                           level: level,
                                                                           parentID: (columnID: "", rowID: rowDataModel.rowID),
                                                                           rowWidth: Utility.getWidthForExpanderRow(columns: schemaValue.tableColumns ?? [])),
                                                   childrens: [id : children]
                                                  ))
                }
            }
            tableDataModel.filteredcellModels.insert(contentsOf: cellModels, at: index+1)
            tableDataModel.cellModels.insert(contentsOf: cellModels, at: index+1)
        }
    }
    
    func deleteSelectedRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            tableDataModel.documentEditor?.deleteRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
            for rowID in tableDataModel.selectedRows {
                if let index = tableDataModel.rowOrder.firstIndex(of: rowID) {
                    deleteRow(at: index, rowID: rowID, isNested: false)
                }
            }
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            deleteSelectedNestedRow()
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func deleteSelectedNestedRow() {
        let valueToValueElements = tableDataModel.documentEditor?.deleteNestedRows(rowIDs: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        self.tableDataModel.valueToValueElements = valueToValueElements
        for rowID in tableDataModel.selectedRows {
            if let index = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID }) {
                deleteRow(at: index, rowID: rowID, isNested: true)
            }
        }
    }
    
    func duplicateRow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            duplicateNestedRow(parentID: ("",""), level: 0, isNested: false, tableColumns: tableDataModel.tableColumns)
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            let indexOfFirstSelectedRow = tableDataModel.cellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows.first!} )
            var headerTableColumns: [FieldTableColumn] = []
            for indexOfCurrentRow in stride(from: indexOfFirstSelectedRow ?? 0, through: 0, by: -1) {
                switch tableDataModel.cellModels[indexOfCurrentRow].rowType {
                case .header(level: _, tableColumns: let tableColumns):
                    headerTableColumns = tableColumns
                    break
                default:
                    continue
                }
                break
            }
            duplicateNestedRow(parentID: parentID, level: level, isNested: true, tableColumns: headerTableColumns)
        default:
            return
        }
        
        tableDataModel.emptySelection()
    }
    
    func duplicateNestedRow(parentID: (columnID: String, rowID: String)?, level: Int, isNested: Bool, tableColumns: [FieldTableColumn]) {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let result = tableDataModel.documentEditor?.duplicateNestedRows(selectedRowIds: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        
        self.tableDataModel.valueToValueElements = result.1
        
        let sortedChanges = result.0.sorted { $0.key < $1.key }
        
        let sortedSelectedRows = tableDataModel.selectedRows.sorted { (rowID1, rowID2) in
            guard let index1 = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID1 }),
                  let index2 = tableDataModel.cellModels.firstIndex(where: { $0.rowID == rowID2 }) else {
                return false
            }
            return index1 < index2
        }
        
        for (offset, change) in sortedChanges.enumerated() {
            let startingIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == sortedSelectedRows[offset] }) ?? 0
            let rowDataModel = tableDataModel.cellModels[startingIndex]
            let atIndex = startingIndex + 1 + childrensForRows(startingIndex, rowDataModel, rowDataModel.rowType.level).count
            let valueElement = change.value
            let childrens = change.value.childrens ?? [:]
            if isNested {
                addNestedCellModel(rowID: valueElement.id ?? "",
                                   index: atIndex,
                                   valueElement: valueElement,
                                   columns: tableColumns,
                                   level: level,
                                   childrens: childrens,
                                   rowType: .nestedRow(level: level,index: startingIndex + 1,parentID: parentID))
            } else {
                addNestedCellModel(rowID: valueElement.id ?? "",
                                   index: atIndex,
                                   valueElement: valueElement,
                                   columns: tableColumns,
                                   level: level,
                                   childrens: childrens,
                                   rowType: .row(index: atIndex))
            }
            tableDataModel.filterRowsIfNeeded()
        }
        
        tableDataModel.emptySelection()
    }

    func insertBelow() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        let cellValues = getCellValues()
        guard let targetRows = tableDataModel.documentEditor?.insertBelow(selectedRowID: tableDataModel.selectedRows[0], cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) else { return }
        let lastRowIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows[0])!
        updateRow(valueElement: targetRows.0, at: lastRowIndex+1)
        tableDataModel.emptySelection()
    }

    func moveUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveRowUp()
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            moveNestedUP()
        default:
            return
        }
    }
    
    func moveRowUp() {
        tableDataModel.documentEditor?.moveRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { rowDataModel in
            rowDataModel.rowID == tableDataModel.selectedRows.first!
        })!
        //update Row order
        let rowOrderIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
        tableDataModel.rowOrder.swapAt(rowOrderIndex, rowOrderIndex-1)
        moveNestedUP(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!, isNested: false)
    }
    
    func moveNestedUP() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowUp(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows.first! })!
        moveNestedUP(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!, isNested: true)
    }

    func moveDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        
        guard let firstSelectedRow = tableDataModel.cellModels.first(where: { $0.rowID == tableDataModel.selectedRows.first! }) else {
            return
        }
        switch firstSelectedRow.rowType {
        case .row(index: let index):
            moveRowDown()
        case .nestedRow(level: let level, index: let index, parentID: let parentID):
            moveNestedDown()
        default:
            return
        }
    }
    
    func moveRowDown() {
        tableDataModel.documentEditor?.moveRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { rowDataModel in
            rowDataModel.rowID == tableDataModel.selectedRows.first!
        })!
        let rowOrderIndex = tableDataModel.rowOrder.firstIndex(of: tableDataModel.selectedRows.first!)!
        tableDataModel.rowOrder.swapAt(rowOrderIndex, rowOrderIndex+1)
        moveNestedDown(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
    }
    
    func moveNestedDown() {
        guard !tableDataModel.selectedRows.isEmpty else { return }
        self.tableDataModel.valueToValueElements = tableDataModel.documentEditor?.moveNestedRowDown(rowID: tableDataModel.selectedRows.first!, fieldIdentifier: tableDataModel.fieldIdentifier)
        let lastRowIndex = tableDataModel.cellModels.firstIndex(where: { $0.rowID == tableDataModel.selectedRows.first! })!
        moveNestedDown(at: lastRowIndex, rowID: tableDataModel.selectedRows.first!)
    }
    
    fileprivate func updateRow(valueElement: ValueElement, at index: Int) {
        if tableDataModel.rowOrder.count > (index - 1) {
            tableDataModel.rowOrder.insert(valueElement.id!, at: index)
        } else {
            tableDataModel.rowOrder.append(valueElement.id!)
        }
        addCellModel(rowID: valueElement.id!, index: index, valueElement: valueElement)
        tableDataModel.filterRowsIfNeeded()
    }
    
    fileprivate func deleteRow(at index: Int, rowID: String, isNested: Bool) {
        if !isNested {
            tableDataModel.rowOrder.remove(at: index)
        }
        let currentRow = tableDataModel.cellModels[index]
        if currentRow.isExpanded {
            collapseTables(index, currentRow, currentRow.rowType.level)
        }
        self.tableDataModel.cellModels.remove(at: index)
        tableDataModel.filterRowsIfNeeded()
    }
    
    func getUpperRowIndex(startingIndex: Int) -> Int {
        var upperRowIndex = 0
        for i in stride(from: startingIndex, through: 0, by: -1) {
            switch tableDataModel.cellModels[i].rowType {
            case .row:
                upperRowIndex = i
                break
            default:
                continue
            }
            break
        }
        return upperRowIndex
    }
    
    func getUpperNestedRowIndex(startingIndex: Int, level: Int) -> Int {
        var upperRowIndex = 0
        for i in stride(from: startingIndex, through: 0, by: -1) {
            switch tableDataModel.cellModels[i].rowType {
            case .nestedRow(level: let nestedLevel, index: let index, parentID: _):
                if nestedLevel != level {
                    continue
                } else {
                    upperRowIndex = i
                    break
                }
            default:
                continue
            }
            break
        }
        return upperRowIndex
    }
    
    fileprivate func moveNestedUP(at index: Int, rowID: String, isNested: Bool) {
        let currentRow = tableDataModel.cellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var upperRowIndicesToMove: [Int] = []
        //we need to count the upper row childrens if upper row is aslo expanded
        var upperRowIndex = 0
        
        if isNested {
            upperRowIndex = getUpperNestedRowIndex(startingIndex: index - 1, level: currentRow.rowType.level)
        } else {
            upperRowIndex = getUpperRowIndex(startingIndex: index - 1)
        }
        
        upperRowIndicesToMove = childrensForRows(upperRowIndex, tableDataModel.cellModels[upperRowIndex], tableDataModel.cellModels[upperRowIndex].rowType.level)
        upperRowIndicesToMove.append(upperRowIndex)
        
        if currentRow.isExpanded {
            currentRowIndicesToMove = childrensForRows(index, currentRow, currentRow.rowType.level)
            currentRowIndicesToMove.append(index)
            self.tableDataModel.cellModels.moveItems(from: currentRowIndicesToMove.sorted(), to: upperRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.cellModels.moveItems(from: [index], to: upperRowIndicesToMove.sorted())
        }
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    fileprivate func moveNestedDown(at index: Int, rowID: String) {
        let currentRow = tableDataModel.cellModels[index]
        var currentRowIndicesToMove: [Int] = []
        var lowerRowIndicesToMove: [Int] = []
        
        currentRowIndicesToMove = childrensForRows(index, currentRow, currentRow.rowType.level)
        currentRowIndicesToMove.append(index)
        
        let lowerRow = tableDataModel.cellModels[index + currentRowIndicesToMove.count]
        lowerRowIndicesToMove = childrensForRows(index + currentRowIndicesToMove.count, lowerRow, lowerRow.rowType.level)
        lowerRowIndicesToMove.append(index + currentRowIndicesToMove.count)
        
        if currentRow.isExpanded {
            self.tableDataModel.cellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: currentRowIndicesToMove.sorted())
        } else {
            self.tableDataModel.cellModels.moveItems(from: lowerRowIndicesToMove.sorted(), to: [index])
        }
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }

    func addRow() {
        let id = generateObjectId()
        let cellValues = getCellValues()

        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier) {
            updateRow(valueElement: rowData, at: tableDataModel.cellModels.count)
        }
    }
    
    func addNestedRow(schemaKey: String, level: Int, startingIndex: Int, parentID: (columnID: String, rowID: String), childrenSchemaKey: String? = nil) {
        let id = generateObjectId()
        let tableColumns = tableDataModel.schema[schemaKey]?.tableColumns ?? []
        let cellValues = getCellValuesForNested(columns: tableColumns)
                
        if let rowData = tableDataModel.documentEditor?.insertRowWithFilter(id: id, cellValues: cellValues, fieldIdentifier: tableDataModel.fieldIdentifier, parentRowId: parentID.rowID, schemaKey: schemaKey, childrenSchemaKey: childrenSchemaKey) {
            //Update valueToValueElements
            self.tableDataModel.valueToValueElements = rowData.all
            
            //Index where we append new row in tableDataModel.filteredcellModels
            var atNestedIndex = 0
            let rowDataModel = tableDataModel.cellModels[startingIndex]
            var placeAtIndex: Int = childrensForASpecificRow(startingIndex, rowDataModel).count
            
            var childrens: [String : Children] = [:]
            if let childrenSchemaKey = childrenSchemaKey, !childrenSchemaKey.isEmpty {
                childrens = [childrenSchemaKey : Children()]
            }
            addNestedCellModel(rowID: rowData.inserted.id!,
                               index: placeAtIndex + startingIndex + 1,
                               valueElement: rowData.inserted,
                               columns: tableColumns,
                               level: level + 1,
                               childrens: childrens, rowType: .nestedRow(level: level + 1,
                                                                         index: atNestedIndex,
                                                                         parentID: parentID))
            self.tableDataModel.filterRowsIfNeeded()
        }
    }
    
    func getCellValuesForNested(columns: [FieldTableColumn]) -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        for column in columns {
            if let defaultValue = column.value {
                cellValues[column.id!] = defaultValue
            }
        }
        return cellValues
    }
    
    func getCellValues() -> [String: ValueUnion] {
        var cellValues: [String: ValueUnion] = [:]
        
        for filterModel in tableDataModel.filterModels {
            let change = filterModel.filterText
            let columnId = filterModel.colID ?? ""
            
            if change.isEmpty {
                // No filter Applied, Extract default value if present
                if let defaultValue = tableDataModel.tableColumns.first(where: { $0.id == columnId })?.value {
                    cellValues[columnId] = defaultValue
                }
            } else {
                // Filter Applied based on column type
                switch filterModel.type {
                case .text:
                    cellValues[columnId] = ValueUnion.string(change)
                case .dropdown:
                    cellValues[columnId] = ValueUnion.string(change)
                case .number:
                    if let doubleChange = Double(change) {
                        cellValues[columnId] = ValueUnion.double(doubleChange)
                    } else {
                        cellValues[columnId] = ValueUnion.null
                    }
                case .multiSelect:
                    cellValues[columnId] = ValueUnion.array([change])
                case .barcode:
                    cellValues[columnId] = ValueUnion.string(change)
                default:
                    break
                }
            }
        }
        return cellValues
    }

    func cellDidChange(rowId: String, colIndex: Int, cellDataModel: CellDataModel, isNestedCell: Bool) -> [ValueElement] {
        if isNestedCell {
            tableDataModel.updateCellModelForNested(rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        } else {
            tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: false)
        }
        return tableDataModel.documentEditor?.nestedCellDidChange(rowId: rowId, cellDataModel: cellDataModel, fieldId: tableDataModel.fieldIdentifier.fieldID) ?? []
    }

    func bulkEdit(changes: [Int: ValueUnion]) {
        var columnIDChanges = [String: ValueUnion]()
        changes.forEach { (colIndex: Int, value: ValueUnion) in
            guard let cellDataModelId = tableDataModel.getColumnIDAtIndex(index: colIndex) else { return }
            columnIDChanges[cellDataModelId] = value
        }
        tableDataModel.documentEditor?.bulkEdit(changes: columnIDChanges, selectedRows: tableDataModel.selectedRows, fieldIdentifier: tableDataModel.fieldIdentifier)
        for rowId in tableDataModel.selectedRows {
            let rowIndex = tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0
            tableDataModel.tableColumns.enumerated().forEach { colIndex, column in
                var cellDataModel = tableDataModel.cellModels[rowIndex].cells[colIndex].data
                guard let change = changes[colIndex] else { return }
                
                switch cellDataModel.type {
                case .dropdown:
                    cellDataModel.selectedOptionText =  cellDataModel.options?.filter { $0.id == change.text }.first?.value ?? ""
                    cellDataModel.defaultDropdownSelectedId = change.text
                case .text:
                    cellDataModel.title = change.text ?? ""
                case .date:
                    cellDataModel.date = change.number
                case .number:
                    cellDataModel.number = change.number
                case .multiSelect:
                    cellDataModel.multiSelectValues = change.stringArray
                case .barcode:
                    cellDataModel.title = change.text ?? ""
                default:
                    break
                }
                
                tableDataModel.updateCellModel(rowIndex: tableDataModel.rowOrder.firstIndex(of: rowId) ?? 0, rowId: rowId, colIndex: colIndex, cellDataModel: cellDataModel, isBulkEdit: true)
            }
        }
        tableDataModel.filterRowsIfNeeded()
        tableDataModel.emptySelection()
    }
    
    func sendEventsIfNeeded() {
        tableDataModel.documentEditor?.onChange(fieldIdentifier: tableDataModel.fieldIdentifier)
    }
}

extension Array {
    mutating func moveItems(from sourceIndices: [Int], to destinationIndices: [Int]) {
        guard !sourceIndices.isEmpty,
              !destinationIndices.isEmpty,
              sourceIndices.allSatisfy({ 0 <= $0 && $0 < count }) else {
            return
        }

        let sortedSource = sourceIndices.sorted()
        let elements = sortedSource.map { self[$0] }

        for idx in sortedSource.reversed() {
            remove(at: idx)
        }

        let minCount = Swift.min(elements.count, destinationIndices.count)

        for i in 0..<minCount {
            let dest = destinationIndices[i]
            let safeDest = dest < count ? dest : count
            insert(elements[i], at: safeDest)
        }

        if elements.count > destinationIndices.count {

            var insertionIndex = destinationIndices[minCount - 1]
            if insertionIndex >= count { insertionIndex = count - 1 }

            for i in minCount..<elements.count {
                insertionIndex += 1
                if insertionIndex > count { insertionIndex = count }
                insert(elements[i], at: insertionIndex)
            }
        }
    }
}
