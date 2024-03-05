//
//  File.swift
//  
//
//  Created by Nand Kishore on 04/03/24.
//

import Foundation
import SwiftUI
import JoyfillModel

class TableViewModel: ObservableObject {
    private let mode: Mode
    private let joyDocModel: JoyDocField?
    
    @Published var isTableModalViewPresented = false
    @Published var shouldShowTableTitle = false
    @Published var shouldShowAddRowButton: Bool = false
    @Published var shouldShowDeleteRowButton: Bool = false
    @Published var tableViewTitle: String = ""
    @Published var viewMoreText: String = ""
    @Published var rows: [String] = []
    @Published var columns: [String] = []
    @Published var quickViewRowCount: Int = 0
    private var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
    private var columnIdToColumnMap: [String: FieldTableColumn] = [:]
    
    init(mode: Mode, joyDocModel: JoyDocField?) {
        self.mode = mode
        self.joyDocModel = joyDocModel
        setup()
    }
    
    private func setup() {
        setupColumns(joyDocModel: joyDocModel)
        setupRows(joyDocModel: joyDocModel)
        
        quickViewRowCount = rows.count >= 3 ? 3 : rows.count
        
        shouldShowTableTitle = !(joyDocModel?.title?.isEmpty ?? true)
        shouldShowAddRowButton = mode == .fill
        shouldShowDeleteRowButton = mode == .fill
        viewMoreText = rows.count > 1 ? "+\(rows.count)" : ""
        tableViewTitle = joyDocModel?.title ?? ""
    }
    
    func getFieldTableColumn(row: String, col: Int) -> FieldTableColumn? {
        return rowToCellMap[row]?[col]
    }
    
    func getColumnTitle(columnId: String) -> String {
        return columnIdToColumnMap[columnId]?.title ?? ""
    }
    
    func getColumnTitleAtIndex(index: Int) -> String {
        guard index < columns.count else { return "" }
        return columnIdToColumnMap[columns[index]]?.title ?? ""
    }
    
    
    
    private func setupColumns(joyDocModel: JoyDocField?) {
        guard let joyDocModel = joyDocModel else { return }
        
        for column in joyDocModel.tableColumnOrder ?? [] {
            columnIdToColumnMap[column] = joyDocModel.tableColumns?.first { $0.id == column }
        }
        
        self.columns = joyDocModel.tableColumnOrder ?? []
    }
    
    private func setupRows(joyDocModel: JoyDocField?) {
        guard let joyDocModel = joyDocModel else { return }
        guard let valueElements = joyDocModel.valueToValueElements, !valueElements.isEmpty else {
            // no row received
            // add at least one dummy row
            return
        }
        
        let nonDeletedRows = valueElements.filter { !($0.deleted ?? false) }
        
        guard !nonDeletedRows.isEmpty else {
            // this is the case when all the rows are deleted
            // add at least one dummy row
            return
        }
        
        let sortedRows = sortElementsByRowOrder(elements: nonDeletedRows, rowOrder: joyDocModel.rowOrder)
        
        var rowToCellMap: [String?: [FieldTableColumn?]] = [:]
        
        for row in sortedRows {
            var cells: [FieldTableColumn?] = []
            for column in joyDocModel.tableColumnOrder ?? [] {
                var cell = joyDocModel.tableColumns?.first { $0.id == column }
                cell?.title = ""
                if case .string(let str) = row.cells?.first { $0.key == column }?.value {
                    cell?.title = str
                    
                    if cell?.type == "dropdown" {
                        cell?.defaultDropdownSelectedId = str
                    }
                }
                cells.append(cell)
            }
            rowToCellMap[row.id] = cells
        }
        
        self.rows = sortedRows.map { $0.id ?? "" }
        self.rowToCellMap = rowToCellMap
    }
    
    func sortElementsByRowOrder(elements: [ValueElement], rowOrder: [String]?) -> [ValueElement] {
        guard let rowOrder = rowOrder else { return elements }
        let sortedRows = elements.sorted { (a, b) -> Bool in
            if let first = rowOrder.firstIndex(of: a.id ?? ""), let second = rowOrder.firstIndex(of: b.id ?? "") {
                return first < second
            }
            return false
        }
        return sortedRows
    }
}
