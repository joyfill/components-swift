import SwiftUI

struct DuplicateRowTarget: Identifiable {
    let id: String
}

struct DuplicateRowSheetView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var quantity: Int = 1
    let onApply: (Int) -> Void
    let onCancel: () -> Void

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Duplicate")
                .font(.headline)
                .darkLightThemeColor()

            HStack(spacing: 0) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                }
                .disabled(quantity <= 1)
                .accessibilityIdentifier("DuplicateRowCounterMinus")

                Text("\(quantity)")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(minWidth: 44)
                    .darkLightThemeColor()
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
                    onApply(quantity)
                } label: {
                    Text("Apply")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("DuplicateRowApplyButton")
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(backgroundColor))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.allFieldBorderColor, lineWidth: 1))
    }
}
