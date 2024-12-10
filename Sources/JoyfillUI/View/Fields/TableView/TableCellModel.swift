//
//  File.swift
//  
//
//  Created by Nand Kishore on 14/03/24.
//

import Foundation
import JoyfillModel

struct TableCellModel: Identifiable, Equatable {
    static func == (lhs: TableCellModel, rhs: TableCellModel) -> Bool {
        lhs.id == rhs.id
    }

    let id = UUID()
    let rowID: String
    var data: FieldTableColumnLocal
    let documentEditor: DocumentEditor?
    var fieldIdentifier: FieldIdentifier
    let viewMode: TableViewMode
    let editMode: Mode
    let didChange: ((_ cell: FieldTableColumnLocal, _ shouldChangeID: Bool) -> Void)?
}
