import SwiftUI
import JoyfillModel
import Combine

struct MultiLineTextView: View {
    @State private var displayText: String = ""
    @State private var lastModelText: String?
    @State private var debounceTask: Task<Void, Never>?
    private var multiLineDataModel: MultiLineDataModel
    @FocusState private var isFocused: Bool
    let eventHandler: FieldChangeEvents

    public init(multiLineDataModel: MultiLineDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.multiLineDataModel = multiLineDataModel
        // Don't initialize state variables here - moved to onAppear
    }

    var body: some View {
        // Create a custom binding that gives us more control
        let textBinding = Binding<String>(
            get: { displayText },
            set: { newValue in
                // Only update if really changing to avoid triggering unnecessary redraws
                if displayText != newValue {
                    displayText = newValue
                }
            }
        )
        return VStack(alignment: .leading) {
            FieldHeaderView(multiLineDataModel.fieldHeaderModel)
            TextEditor(text: textBinding)
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
                .onChange(of: displayText) { newValue in
                    if isFocused {
                        debounceTextChange(newValue: newValue)
                    }
                }
        }
        .onAppear {
            // Initialize on first appear
            if displayText.isEmpty {
                displayText = multiLineDataModel.multilineText ?? ""
            }
            lastModelText = multiLineDataModel.multilineText
        }
        .onChange(of: multiLineDataModel.multilineText) { newValue in
            // Only update if not focused and value has actually changed
            if !isFocused && lastModelText != newValue {
                if displayText != (newValue ?? "") {
                    displayText = newValue ?? ""
                }
                lastModelText = newValue
            }
        }
    }

    private func updateFieldValue() {
        let newValue = ValueUnion.string(displayText)
        let fieldEvent = FieldChangeData(fieldIdentifier: multiLineDataModel.fieldIdentifier, updateValue: newValue)
        eventHandler.onChange(event: fieldEvent)
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
}


