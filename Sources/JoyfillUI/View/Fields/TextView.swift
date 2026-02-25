import SwiftUI
import JoyfillModel
import Combine

struct TextView: View {
    @State private var displayText: String = ""
    @State private var lastModelText: String?
    @State private var debounceTask: Task<Void, Never>?
    @FocusState private var isFocused: Bool
    @Environment(\.navigationFocusFieldId) private var navigationFocusFieldId
    private var textDataModel: TextDataModel
    let eventHandler: FieldChangeEvents

    public init(textDataModel: TextDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.textDataModel = textDataModel
    }

    var body: some View {
        let textBinding = Binding<String>(
            get: { displayText },
            set: { newValue in
                if displayText != newValue {
                    displayText = newValue
                }
            }
        )
        return VStack(alignment: .leading) {
            FieldHeaderView(textDataModel.fieldHeaderModel, isFilled: !displayText.isEmpty)
            TextField("", text: textBinding)
                .accessibilityIdentifier("Text")
                .disabled(textDataModel.mode == .readonly)
                .padding(.horizontal, 10)
                .frame(height: 40)
                .cornerRadius(10)
                .fieldBorder(isFocused: navigationFocusFieldId == textDataModel.fieldIdentifier.fieldID)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    if focused {
                        eventHandler.onFocus(event: textDataModel.fieldIdentifier)
                    } else {
                        updateFieldValue()
                    }
                }
                .onChange(of: displayText) { newValue in
                    if isFocused {
                        debounceTextChange(newValue: newValue)
                    }
                }
        }
        .onAppear {
            if displayText.isEmpty {
                displayText = textDataModel.text ?? ""
            }
            lastModelText = textDataModel.text
        }
        .onChange(of: navigationFocusFieldId) { newValue in
            if newValue == textDataModel.fieldIdentifier.fieldID {
                isFocused = true
            }
        }
        .onChange(of: textDataModel.text) { newValue in
            if !isFocused && lastModelText != newValue {
                if displayText != (newValue ?? "") {
                    displayText = newValue ?? ""
                }
                lastModelText = newValue
            }
        }
    }

    private func debounceTextChange(newValue: String) {
        debounceTask?.cancel()
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: Utility.DEBOUNCE_TIME_IN_NANOSECONDS)
            if !Task.isCancelled {
                await MainActor.run {
                    updateFieldValue()
                }
            }
        }
    }

    private func updateFieldValue() {
        let newText = ValueUnion.string(displayText)
        let fieldEvent = FieldChangeData(fieldIdentifier: textDataModel.fieldIdentifier, updateValue: newText)
        eventHandler.onChange(event: fieldEvent)
    }
}
