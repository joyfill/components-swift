import SwiftUI
import JoyfillModel

struct MultiLineTextView: View {
    @State var multilineText: String = ""
    @State private var debounceTask: Task<Void, Never>?
    private var multiLineDataModel: MultiLineDataModel
    @FocusState private var isFocused: Bool 
    let eventHandler: FieldChangeEvents

    public init(multiLineDataModel: MultiLineDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
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
                    if focused {
                        eventHandler.onFocus(event: multiLineDataModel.fieldIdentifier)
                    } else {
                        updateFieldValue()
                    }
                }
                .onChange(of: multilineText, perform: debounceTextChange)
        }
    }
    
    private func updateFieldValue() {
        let newValue = ValueUnion.string(multilineText)
        let fieldEvent = FieldChangeData(fieldIdentifier: multiLineDataModel.fieldIdentifier, updateValue: newValue)
        eventHandler.onChange(event: fieldEvent)
    }
    
    private func debounceTextChange(newValue: String) {
        debounceTask?.cancel() // Cancel any ongoing debounce task
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: Utility.DEBOUNCE_TIME_IN_NANOSECONDS) // 1 seconds
            if !Task.isCancelled {
                await MainActor.run {
                    updateFieldValue()
                }
            }
        }
    }
}

