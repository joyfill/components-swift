import SwiftUI
import JoyfillModel

struct TextView: View {
    @State var enterText: String = ""
    @State private var debounceTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    private var textDataModel: TextDataModel
    let eventHandler: FieldChangeEvents

    public init(textDataModel: TextDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
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
                        eventHandler.onFocus(event: textDataModel.fieldIdentifier)
                    } else {
                        updateFieldValue()
                    }
                }
                .onChange(of: enterText, perform: debounceTextChange)
        }
    }
    
    private func debounceTextChange(newValue: String) {
        debounceTask?.cancel() // Cancel any ongoing debounce task
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            if !Task.isCancelled {
                await MainActor.run {
                    updateFieldValue()
                }
            }
        }
    }
    
    private func updateFieldValue() {
        let newText = ValueUnion.string(enterText)
        let fieldEvent = FieldChangeData(fieldIdentifier: textDataModel.fieldIdentifier, updateValue: newText)
        eventHandler.onChange(event: fieldEvent)
    }
}

