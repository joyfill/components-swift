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
    var timezoneId: String?
    var data: CellDataModel
    let documentEditor: DocumentEditor?
    var fieldIdentifier: FieldIdentifier
    let viewMode: TableViewMode
    let editMode: Mode
    let didFocusBlur: ((_ action: FocusBlurAction, _ cell: CellDataModel) -> Void)?
    let didChange: ((_ cell: CellDataModel) -> Void)?
}

extension TableCellModel {
    var isFilled: Bool {
        // A cell a formula applies to is judged by what it computes, never by the fact
        // that it holds formula text: `=A *` is stored and non-empty but shows Error.
        // `Error` is not a value, so a cell showing one is not filled and a required
        // column still marks it.
        if let computed = documentEditor?.cellFormulaValue(columnID: data.id,
                                                           fieldID: fieldIdentifier.fieldID,
                                                           rowID: rowID) {
            return !computed.isError && !computed.text.isEmpty
        }
        return data.isCellFilled
    }
}

enum FocusBlurAction: String {
    case focus = "field.focus"
    case blur = "field.blur"
}
