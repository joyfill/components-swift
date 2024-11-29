//
//  SwiftUIView.swift
//  Joyfill
//
//  Created by Babblu Bhaiya on 13/11/24.
//

import SwiftUI

struct TableNumberView: View {
    var cellModel: TableCellModel
    @State var numberValue = ""

    public init(cellModel: TableCellModel) {
        self.cellModel = cellModel
        if let number = cellModel.data.number {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false

            let formattedNumberString = formatter.string(from: NSNumber(value: number)) ?? ""
            _numberValue = State(initialValue: formattedNumberString)
        }
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(numberValue)
                .font(.system(size: 15))
                .lineLimit(1)
        } else {
            TextEditor(text: $numberValue)
                .keyboardType(.decimalPad)
                .font(.system(size: 15))
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: numberValue) { newText in
                    if let doubleValue = Double(numberValue), cellModel.data.number != doubleValue {
                        var editedCell = cellModel.data
                        editedCell.number = doubleValue
                        cellModel.didChange?(editedCell)
                    }
                }
        }
    }
}

