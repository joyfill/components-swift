import SwiftUI
import JoyfillModel

struct TextView: View {
    @State var enterText: String = ""
    @FocusState private var isFocused: Bool
    private var textDataModel: TextDataModel
    
    public init(textDataModel: TextDataModel) {
        self.textDataModel = textDataModel
        if let text = textDataModel.text {
            _enterText = State(initialValue: text)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(textDataModel.fieldHeaderModel)
            TextField("", text: $enterText)
                .accessibilityIdentifier("Text")
                .disabled(textDataModel.mode == .readonly)
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
                        textDataModel.eventHandler.onFocus(event: textDataModel.fieldIdentifier)
                    } else {
                        let newText = ValueUnion.string(enterText)
                        let fieldEvent = FieldChangeData(fieldIdentifier: textDataModel.fieldIdentifier, updateValue: newText)
                        textDataModel.eventHandler.onChange(event: fieldEvent)
                    }
                }
        }
    }
}

