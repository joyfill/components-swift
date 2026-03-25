import SwiftUI
import JoyfillModel
import Joyfill

struct ValidationResultsView: View {
    let validation: Validation
    let documentEditor: DocumentEditor?
    let onGoToField: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(validation: Validation, documentEditor: DocumentEditor? = nil, onGoToField: (() -> Void)? = nil) {
        self.validation = validation
        self.documentEditor = documentEditor
        self.onGoToField = onGoToField
    }

    private var pageGroups: [(pageId: String, pageName: String, fields: [FieldValidity])] {
        let pages = documentEditor?.pagesForCurrentView ?? []
        var grouped: [String: [FieldValidity]] = [:]
        var pageOrder: [String] = []

        for fv in validation.fieldValidities {
            let pid = fv.pageId ?? "unknown"
            if grouped[pid] == nil {
                pageOrder.append(pid)
            }
            grouped[pid, default: []].append(fv)
        }

        return pageOrder.compactMap { pid in
            let pageName = pages.first(where: { $0.id == pid })?.name
            let displayName = pageName ?? "Page"
            return (pageId: pid, pageName: displayName, fields: grouped[pid] ?? [])
        }
    }

    private var invalidCount: Int {
        validation.fieldValidities.filter { $0.status == .invalid }.count
    }

    private var totalCount: Int {
        validation.fieldValidities.count
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    summaryCard
                    ForEach(Array(pageGroups.enumerated()), id: \.offset) { index, group in
                        pageSection(index: index + 1, group: group)
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Validation Results")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(spacing: 12) {
            Image(systemName: validation.status == .valid ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(validation.status == .valid ? .green : .orange)

            Text(validation.status == .valid ? "All fields valid" : "\(invalidCount) of \(totalCount) fields need attention")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    // MARK: - Page Section

    private func pageSection(index: Int, group: (pageId: String, pageName: String, fields: [FieldValidity])) -> some View {
        let pageInvalidCount = group.fields.filter { $0.status == .invalid }.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.accentColor)
                Text("\(group.pageName) \(index)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if pageInvalidCount > 0 {
                    Text("\(pageInvalidCount) invalid")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                } else {
                    Text("All valid")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 4)

            ForEach(Array(group.fields.enumerated()), id: \.offset) { _, fv in
                fieldCard(fv)
            }
        }
    }

    // MARK: - Field Card

    private func fieldCard(_ fv: FieldValidity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fv.field.title ?? (fv.field.id ?? "Untitled Field"))
                        .font(.subheadline.weight(.medium))

                }
                Spacer()
                StatusTag(status: fv.status)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Field ID: \(fv.fieldId ?? fv.field.id ?? "")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Page ID: \(fv.pageId ?? "")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()

                if fv.status == .invalid, documentEditor != nil {
                    goToFieldButton(fv)
                }
            }

            if let rows = fv.rowValidities, !rows.isEmpty {
                invalidRowsList(rows: rows, fieldValidity: fv)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(fv.status == .invalid ? Color.red.opacity(0.25) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - Invalid Rows List

    private func invalidRowsList(rows: [RowValidity], fieldValidity: FieldValidity) -> some View {
        let invalidRows = rows.filter { $0.status == .invalid }
        let totalRows = rows.count

        return VStack(alignment: .leading, spacing: 6) {
            Divider()

            HStack(spacing: 4) {
                Image(systemName: "tablecells")
                    .font(.caption2)
                    .foregroundColor(invalidRows.isEmpty ? .secondary : .red)
                Text(invalidRows.isEmpty
                     ? "\(totalRows) rows — all valid"
                     : "\(invalidRows.count) of \(totalRows) rows invalid")
                    .font(.caption)
                    .foregroundColor(invalidRows.isEmpty ? .secondary : .red)
            }

            ForEach(Array(invalidRows.enumerated()), id: \.offset) { index, row in
                invalidRowCard(row: row, index: index, fieldValidity: fieldValidity)
            }
        }
    }

    private func invalidRowCard(row: RowValidity, index: Int, fieldValidity: FieldValidity) -> some View {
        let invalidCells = row.cellValidities.filter { $0.status == .invalid }

        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Row \(row.rowId ?? "?")")
                    .font(.caption.weight(.medium))
                if !invalidCells.isEmpty {
                    Text("\(invalidCells.count) cell(s) invalid")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                if let schemaId = row.schemaId {
                    Text("Schema: \(schemaId)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if documentEditor != nil {
                goToRowButton(row: row, fieldValidity: fieldValidity)
            }
        }
        .padding(8)
        .background(Color.red.opacity(0.04))
        .cornerRadius(8)
    }

    // MARK: - Navigation Buttons

    private func goToFieldButton(_ fv: FieldValidity) -> some View {
        Button {
            navigateToField(fv)
        } label: {
            HStack(spacing: 4) {
                Text("Go to")
                Image(systemName: "arrow.right.circle.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.accentColor)
            .cornerRadius(8)
        }
    }

    private func goToRowButton(row: RowValidity, fieldValidity: FieldValidity) -> some View {
        Button {
            navigateToRow(row: row, fieldValidity: fieldValidity)
        } label: {
            HStack(spacing: 3) {
                Text("Go to row")
                Image(systemName: "arrow.right.circle")
            }
            .font(.caption2.weight(.semibold))
            .foregroundColor(.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.12))
            .cornerRadius(6)
        }
    }

    private func navigateToField(_ fv: FieldValidity) {
        guard let editor = documentEditor,
              let pageId = fv.pageId,
              let fieldPositionId = fv.fieldPositionId else { return }
        dismiss()
        onGoToField?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            _ = editor.goto("\(pageId)/\(fieldPositionId)")
        }
    }

    private func navigateToRow(row: RowValidity, fieldValidity: FieldValidity) {
        guard let editor = documentEditor,
              let pageId = fieldValidity.pageId,
              let fieldPositionId = fieldValidity.fieldPositionId,
              let rowId = row.rowId else { return }
        dismiss()
        onGoToField?()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            _ = editor.goto("\(pageId)/\(fieldPositionId)/\(rowId)", gotoConfig: GotoConfig(open: true))
        }
    }

}

// MARK: - Status Tag

private struct StatusTag: View {
    let status: ValidationStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status == .valid ? Color.green : Color.red)
                .frame(width: 6, height: 6)
            Text(status == .valid ? "Valid" : "Invalid")
                .font(.caption.weight(.medium))
                .foregroundColor(status == .valid ? .green : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((status == .valid ? Color.green : Color.red).opacity(0.1))
        .cornerRadius(6)
    }
}
