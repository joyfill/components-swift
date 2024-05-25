//
//  File.swift
//  
//
//  Created by Nand Kishore on 14/03/24.
//

import Foundation
import JoyfillModel

struct PDFTableCellModel {
    let data: FieldTableColumn
    let eventHandler: FieldChangeEvents
    let fieldData: JoyDocField?
    let viewMode: PDFTableViewMode
    let editMode: Mode
    let didChange: ((_ cell: FieldTableColumn) -> Void)?
}
