import SwiftUI

struct TableNumberView: View {
    @State private var number: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @Binding var cellModel: TableCellModel
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    public init(cellModel: Binding<TableCellModel>, isUsedForBulkEdit: Bool = false, number: String? = nil) {
        _cellModel = cellModel
        
        let cellNumber = cellModel.wrappedValue.data.number ?? 0.0
        let formattedCellNumber = numberFormatter.string(from: NSNumber(value: cellNumber)) ?? "0"
        
//        if let providedNumber = number {
//            _number = State(initialValue: providedNumber)
//        } else if !isUsedForBulkEdit {
//            _number = State(initialValue: formattedCellNumber)
//        }
        _number = State(initialValue: formattedCellNumber)
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            if let numberValue = cellModel.data.number {
                Text(numberFormatter.string(from: NSNumber(value: numberValue)) ?? "")
                    .font(.system(size: 15))
                    .lineLimit(1)
            }
            
        } else {
            TextField("", text: $number)
                .padding(.leading, 8)
                .keyboardType(.decimalPad)
                .font(.system(size: 15))
                .accessibilityIdentifier("TabelTextFieldIdentifier")
                .onChange(of: number) { newText in
                    updateNumberValue(newText)
                }
                .focused($isTextFieldFocused)
        }
    }
    
    private func updateNumberValue(_ newText: String) {
        var cellModelData = cellModel.data
        if !number.isEmpty, let doubleValue = Double(number) {
            cellModelData.number = doubleValue
        } else {
            cellModelData.number = nil
        }
        cellModel.data = cellModelData
        cellModel.didChange?(cellModelData)
    }
}

