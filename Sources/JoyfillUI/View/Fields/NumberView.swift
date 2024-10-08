import SwiftUI
import JoyfillModel

struct NumberView: View {
    @State var number: String = ""
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let number = fieldDependency.fieldData?.value?.number {
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
            FieldHeaderView(fieldDependency)
            TextField("", text: $number)
                .accessibilityIdentifier("Number")
                .disabled(fieldDependency.mode == .readonly)
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
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    } else {
                        let newValue: ValueUnion
                        if !number.isEmpty, let doubleValue = Double(number) {
                            newValue = ValueUnion.double(doubleValue)
                        } else {
                            newValue = ValueUnion.string("")
                        }
                        guard fieldDependency.fieldData?.value != newValue else { return }
                        guard var fieldData = fieldDependency.fieldData else {
                            fatalError("FieldData should never be null")
                        }
                        fieldData.value = newValue
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
                    }
                }
        }
    }
}
