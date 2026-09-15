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

enum FocusBlurAction: String {
    case focus = "field.focus"
    case blur = "field.blur"
}

// MARK: - Formulas

/// Forwarded so the views need not reach through `data` for a result.
extension TableCellModel {
    var isFormulaCell: Bool { data.isFormulaCell }
    var formulaValue: CellFormulaValue? { data.formulaValue }
    var formulaDisplayText: String { data.formulaDisplayText }
}
