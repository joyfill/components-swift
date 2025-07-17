import SwiftUI
import JoyfillModel
import Combine

struct NumberView: View {
    // Use a binding that we control rather than a State variable
    private let numberDataModel: NumberDataModel
    @FocusState private var isFocused: Bool
    let eventHandler: FieldChangeEvents

    // Use local state for value tracking instead of frequent model updates
    @State private var displayText: String = ""
    @State private var lastModelValue: Double?
    @State private var debounceTask: Task<Void, Never>?

    public init(numberDataModel: NumberDataModel, eventHandler: FieldChangeEvents) {
        self.numberDataModel = numberDataModel
        self.eventHandler = eventHandler
        // Don't initialize state variables here - moved to onAppear
    }

    private func formatNumber(_ number: Double?) -> String {
        guard let number = number else { return "" }

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false

        return formatter.string(from: NSNumber(value: number)) ?? ""
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
            FieldHeaderView(numberDataModel.fieldHeaderModel)

            // Use the custom binding for more controlled updates
            TextField("", text: textBinding)
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
                        eventHandler.onFocus(event: numberDataModel.fieldIdentifier)
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
                displayText = formatNumber(numberDataModel.number)
            }
            lastModelValue = numberDataModel.number
        }
        .onChange(of: numberDataModel.number) { newValue in
            // Only update if not focused and value has actually changed
            if !isFocused && lastModelValue != newValue {
                // Avoid the flicker by comparing actual numeric values, not string representation
                let newFormatted = formatNumber(newValue)
                if displayText != newFormatted {
                    displayText = newFormatted
                }
                lastModelValue = newValue
            }
        }
    }

    private func updateFieldValue() {
        let newValue: ValueUnion
        if !displayText.isEmpty, let doubleValue = Double(displayText) {
            newValue = ValueUnion.double(doubleValue)
        } else {
            newValue = ValueUnion.string("")
        }
        let event = FieldChangeData(fieldIdentifier: numberDataModel.fieldIdentifier, updateValue: newValue)
        eventHandler.onChange(event: event)
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

