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
//                    if focused {
//                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
//                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
//                    } else {
//                        let newText = ValueUnion.string(enterText)
//                        guard fieldDependency.fieldData?.value != newText else { return }
//                        guard !((fieldDependency.fieldData?.value == nil) && enterText.isEmpty) else { return }
//                        guard var fieldData = fieldDependency.fieldData else {
//                            fatalError("FieldData should never be null")
//                        }
//                        fieldData.value = newText
//                        fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
//                    }
                }
        }
    }
}

struct TextDataModel {
    var text: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel
}
