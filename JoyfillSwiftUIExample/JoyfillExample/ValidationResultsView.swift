import SwiftUI
import JoyfillModel

struct ValidationResultsView: View {
    let validation: Validation

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    Divider()
                    ForEach(Array(validation.fieldValidities.enumerated()), id: \.offset) { _, fv in
                        FieldValidityView(fieldValidity: fv)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.06))
                            .cornerRadius(12)
                    }
                }
                .padding(16)
            }
            .navigationTitle("Validation Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: validation.status == .valid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(validation.status == .valid ? .green : .orange)
            Text(validation.status == .valid ? "All fields valid" : "Some fields need attention")
                .font(.headline)
        }
    }
}

private struct FieldValidityView: View {
    let fieldValidity: FieldValidity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(fieldTitle)
                    .font(.subheadline).bold()
                Spacer()
                StatusTag(status: fieldValidity.status)
            }
        }
    }

    private var fieldTitle: String {
        fieldValidity.field.title ?? (fieldValidity.field.id ?? "Untitled Field")
    }
}

private struct StatusTag: View {
    let status: ValidationStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .foregroundColor(status == .valid ? .green : .red)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background((status == .valid ? Color.green : Color.red).opacity(0.12))
            .cornerRadius(6)
    }
}


