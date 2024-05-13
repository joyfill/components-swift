import SwiftUI
import JoyfillModel

struct TextView: View {
    @State var enterText: String = ""
    private var fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let text = fieldDependency.fieldData?.value?.text {
            _enterText = State(initialValue: text)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(fieldDependency)
            TextField("", text: $enterText)
                .accessibilityIdentifier("Text")
                .disabled(fieldDependency.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
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
                        let newText = ValueUnion.string(enterText)
                        guard fieldDependency.fieldData?.value != newText else { return }
                        guard !((fieldDependency.fieldData?.value == nil) && enterText.isEmpty) else { return }
                        guard var fieldData = fieldDependency.fieldData else {
                            fatalError("FieldData should never be null")
                        }
                        fieldData.value = newText
                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
                    }
                }
        }
    }
}
