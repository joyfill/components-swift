import SwiftUI
import JoyfillModel
import UIKit

struct MultiLineTextView: View {
    private let multiLineDataModel: MultiLineDataModel
    let eventHandler: FieldChangeEvents
    @Environment(\.navigationFocusFieldId) private var navigationFocusFieldId
    @State private var isFilled: Bool

    public init(multiLineDataModel: MultiLineDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.multiLineDataModel = multiLineDataModel
        _isFilled = State(initialValue: !(multiLineDataModel.multilineText ?? "").isEmpty)
    }

    var body: some View {
        let isReadonly = multiLineDataModel.mode == .readonly
        VStack(alignment: .leading) {
            FieldHeaderView(multiLineDataModel.fieldHeaderModel, isFilled: isFilled) { decorator in
                eventHandler.onDecoratorAction(event: multiLineDataModel.fieldIdentifier, action: decorator.action ?? "")
            }
            Group {
                if isReadonly {
                    ScrollView {
                        Text(multiLineDataModel.multilineText ?? "")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    .accessibilityIdentifier("MultilineReadonlyTextIdentifier")
                } else {
                    MultiLineUITextView(
                        text: multiLineDataModel.multilineText ?? "",
                        shouldFocus: navigationFocusFieldId == multiLineDataModel.fieldIdentifier.fieldID,
                        onFocus: {
                            eventHandler.onFocus(event: multiLineDataModel.fieldIdentifier)
                        },
                        onCommit: { text in
                            commit(text: text)
                        },
                        onFilledChange: { filled in
                            if isFilled != filled { isFilled = filled }
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
            .frame(minHeight: 200, maxHeight: 200)
            .cornerRadius(10)
            .fieldBorder(isFocused: navigationFocusFieldId == multiLineDataModel.fieldIdentifier.fieldID)
        }
        .onChange(of: multiLineDataModel.multilineText) { newValue in
            let filled = !(newValue ?? "").isEmpty
            if isFilled != filled { isFilled = filled }
        }
    }

    private func commit(text: String) {
        let newValue = ValueUnion.string(text)
        let fieldEvent = FieldChangeData(fieldIdentifier: multiLineDataModel.fieldIdentifier, updateValue: newValue)
        eventHandler.onChange(event: fieldEvent)
    }
}

private struct MultiLineUITextView: UIViewRepresentable {
    let text: String
    let shouldFocus: Bool
    let onFocus: () -> Void
    let onCommit: (String) -> Void
    let onFilledChange: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = .no
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.accessibilityIdentifier = "MultilineTextFieldIdentifier"
        textView.text = text
        context.coordinator.lastShouldFocus = shouldFocus
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        if !uiView.isFirstResponder && uiView.text != text {
            uiView.text = text
        }
        let didRequestFocus = shouldFocus && !context.coordinator.lastShouldFocus
        context.coordinator.lastShouldFocus = shouldFocus
        if didRequestFocus && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultiLineUITextView
        var lastShouldFocus: Bool = false
        private var debounceWorkItem: DispatchWorkItem?
        private var lastFilled: Bool?

        init(_ parent: MultiLineUITextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocus()
        }

        func textViewDidChange(_ textView: UITextView) {
            let text = textView.text ?? ""

            let filled = !text.isEmpty
            if lastFilled != filled {
                lastFilled = filled
                parent.onFilledChange(filled)
            }

            debounceWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.parent.onCommit(text)
            }
            debounceWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            debounceWorkItem?.cancel()
            debounceWorkItem = nil
            parent.onCommit(textView.text ?? "")
        }
    }
}
