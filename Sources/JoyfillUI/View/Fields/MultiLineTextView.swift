import SwiftUI
import JoyfillModel

struct MultiLineTextView: View {
    @State var multilineText: String = ""
    private var multiLineDataModel: MultiLineDataModel
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(multiLineDataModel: MultiLineDataModel) {
        self.multiLineDataModel = multiLineDataModel
        if let multilineText = multiLineDataModel.multilineText {
            _multilineText = State(initialValue: multilineText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(multiLineDataModel.fieldHeaderModel)
            TextEditor(text: $multilineText)
                .accessibilityIdentifier("MultilineTextFieldIdentifier")
                .disabled(multiLineDataModel.mode == .readonly)
                .padding(.horizontal, 10)
                .autocorrectionDisabled()
                .frame(minHeight: 200, maxHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )
                .cornerRadius(10)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    //TODO: Use MultiLineDataModel(instead of fieldDependency) for event handler
//                    if focused {
//                        let fieldEvent = FieldEventInternal(fieldID: fieldDependency.fieldData!.id!)
//                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
//                    } else {
//                        let newValue = ValueUnion.string(multilineText)
//                        guard fieldDependency.fieldData?.value != newValue else { return }
//                        guard var fieldData = fieldDependency.fieldData else {
//                            fatalError("FieldData should never be null")
//                        }
//                        fieldData.value = newValue
//                        let fieldEvent = FieldChangeEvent(fieldID: fieldDependency.fieldData!.id!, updateValue: newValue)
//                        fieldDependency.eventHandler.onChange(event: fieldEvent)
//                    }
                }
        }
    }
}

struct MultiLineDataModel {
    var multilineText: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}
