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

extension TableCellModel {

    /// Column types whose stored value is a string, and so can carry a formula.
    static let formulaCapableTypes: Set<ColumnTypes> = [.text, .barcode]

    private var context: JoyfillDocContext? {
        documentEditor?.joyDocContext
    }

    /// `true` when this cell's stored value is a formula.
    var isFormulaCell: Bool {
        guard let type = data.type, Self.formulaCapableTypes.contains(type) else { return false }
        return context?.isFormulaCell(fieldID: fieldIdentifier.fieldID, rowID: rowID, columnID: data.id) ?? false
    }

    /// The evaluated result to show while the cell is idle, or `"Error"` if it failed.
    var formulaDisplayText: String {
        context?.cellFormulaValue(fieldID: fieldIdentifier.fieldID, rowID: rowID, columnID: data.id)?.text ?? ""
    }

    /// `true` when the formula failed to evaluate.
    var isFormulaInError: Bool {
        context?.cellFormulaValue(fieldID: fieldIdentifier.fieldID, rowID: rowID, columnID: data.id)?.isError ?? false
    }
}


