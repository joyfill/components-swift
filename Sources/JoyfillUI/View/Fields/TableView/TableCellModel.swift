//
//  File.swift
//  
//
//  Created by Nand Kishore on 14/03/24.
//

import Foundation
import JoyfillModel

struct TableCellModel: Identifiable, Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TableCellModel, rhs: TableCellModel) -> Bool {
        lhs.id == rhs.id
    }

    var id = UUID()
    let rowID: String
    var data: CellDataModel
    let documentEditor: DocumentEditor?
    var fieldIdentifier: FieldIdentifier
    let viewMode: TableViewMode
    let editMode: Mode
    let didChange: ((_ cell: CellDataModel) -> Void)?
}
