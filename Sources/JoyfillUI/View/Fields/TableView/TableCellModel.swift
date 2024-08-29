//
//  File.swift
//  
//
//  Created by Nand Kishore on 14/03/24.
//

import Foundation
import JoyfillModel

struct TableCellModel: Identifiable {
    let id = UUID()
    let rowID: String
    let data: FieldTableColumn
    let eventHandler: FieldChangeEvents
    let fieldData: JoyDocField?
    let viewMode: TableViewMode
    let editMode: Mode
    let didChange: ((_ cell: FieldTableColumn) -> Void)?
}
