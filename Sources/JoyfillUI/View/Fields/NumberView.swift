import SwiftUI
import JoyfillModel

struct NumberView: View {
    @State var number: String = ""
    private let numberDataModel: NumberDataModel
    @FocusState private var isFocused: Bool
    
    public init(numberDataModel: NumberDataModel) {
        self.numberDataModel = numberDataModel
        if let number = numberDataModel.number {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 10
            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false

            let formattedNumberString = formatter.string(from: NSNumber(value: number)) ?? ""
            _number = State(initialValue: formattedNumberString)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(numberDataModel.fieldHeaderModel)
            TextField("", text: $number)
                .accessibilityIdentifier("Number")
                .disabled(numberDataModel.mode == .readonly)
                .padding(.horizontal, 10)
                .keyboardType(.decimalPad)
                .frame(minHeight: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    if focused {
                        let fieldEvent = FieldEvent(fieldID: numberDataModel.fieldId, pageID: numberDataModel.pageId, fileID: numberDataModel.fileId)
                        numberDataModel.eventHandler.onFocus(event: fieldEvent)
                    } else {
                        let newValue: ValueUnion
                        if !number.isEmpty, let doubleValue = Double(number) {
                            newValue = ValueUnion.double(doubleValue)
                        } else {
                            newValue = ValueUnion.string("")
                        }
                        let event = FieldChangeData(fieldID: numberDataModel.fieldId, pageID: numberDataModel.pageId, fileID: numberDataModel.fileId, updateValue: newValue)
                        numberDataModel.eventHandler.onChange(event: event)
                    }
                }
        }
    }
}
