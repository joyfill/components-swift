import SwiftUI

struct DuplicateRowSheetView: View {
    @State private var quantity: Int = 1
    @State private var includeChildren: Bool = false
    @State private var addAtEnd: Bool = false
    var showIncludeChildrenOption: Bool = false
    var showAddAtEndOption: Bool = false
    /// Rows the level can still accept (`nil` = no limit).
    var remainingCapacity: Int? = nil
    let onApply: (Int, Bool, Bool) -> Void
    let onCancel: () -> Void

    private var quantityTextBinding: Binding<String> {
        Binding(
            get: { String(quantity) },
            set: { newValue in
                let digits = newValue.filter { $0.isNumber }
                if let typed = Int(digits) { quantity = typed }
            }
        )
    }

    private var exceedsCapacity: Bool {
        guard let remainingCapacity = remainingCapacity else { return false }
        return quantity > remainingCapacity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Duplicate")
                .font(.headline)
                .foregroundColor(Color(UIColor.label))

            VStack(alignment: .leading, spacing: 6) {
                Text("Number of duplicate rows")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.secondaryLabel))

                HStack(spacing: 0) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 44, height: 44)
                    }
                    .disabled(quantity <= 1)
                    .accessibilityIdentifier("DuplicateRowCounterMinus")

                    TextField("", text: quantityTextBinding)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(minWidth: 44)
                        .foregroundColor(Color(UIColor.label))
                        .accessibilityIdentifier("DuplicateRowCounterValue")

                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityIdentifier("DuplicateRowCounterPlus")
                }
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                )

                if exceedsCapacity, let remainingCapacity = remainingCapacity {
                    Text(remainingCapacity <= 0
                         ? "Row limit reached. You can't add any more rows."
                         : "You can add only \(remainingCapacity) more row\(remainingCapacity == 1 ? "" : "s").")
                        .font(.caption)
                        .foregroundColor(.red)
                        .accessibilityIdentifier("DuplicateRowLimitWarning")
                }
            }

            if showIncludeChildrenOption {
                Button {
                    includeChildren.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: includeChildren ? "checkmark.square.fill" : "square")
                        Text("Include child table(s)")
                            .foregroundColor(Color(UIColor.label))
                    }
                }
                .accessibilityIdentifier("DuplicateRowIncludeChildrenToggle")
            }

            if showAddAtEndOption {
                Button {
                    addAtEnd.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: addAtEnd ? "checkmark.square.fill" : "square")
                        Text("Add duplicated rows at the end")
                            .foregroundColor(Color(UIColor.label))
                    }
                }
                .accessibilityIdentifier("DuplicateRowAddAtEndToggle")
            }

            HStack(spacing: 12) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("DuplicateRowCancelButton")

                Button {
                    onApply(quantity, includeChildren, addAtEnd)
                } label: {
                    Text("Apply")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .disabled(exceedsCapacity)
                .accessibilityIdentifier("DuplicateRowApplyButton")
            }
        }
        .padding(16)
    }
}

/// Shared popover chrome for the per-row duplicate action (table + collection).
struct DuplicateRowPopover: View {
    var showIncludeChildrenOption: Bool = false
    var showAddAtEndOption: Bool = false
    var remainingCapacity: Int? = nil
    let onApply: (Int, Bool, Bool) -> Void
    let onCancel: () -> Void

    var body: some View {
        let content = DuplicateRowSheetView(
            showIncludeChildrenOption: showIncludeChildrenOption,
            showAddAtEndOption: showAddAtEndOption,
            remainingCapacity: remainingCapacity,
            onApply: onApply,
            onCancel: onCancel
        )
        .frame(width: 300)
        .fixedSize(horizontal: false, vertical: true)
        if #available(iOS 16.4, *) {
            content
                .presentationCompactAdaptation(.popover)
        } else {
            content
        }
    }
}
