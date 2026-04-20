//
//  DecoratorAPIDemoView.swift
//  JoyfillExample
//
//  Contains:
//    • DecoratorManagerView   — sheet listing all fields with their decorators; add / edit / delete
//    • DecoratorEditView      — add-or-edit sheet with icon grid, colour swatches and live preview
//    • DecoratorAPIDemoView   — standalone demo screen (entry in the option list)
//
//  DecoratorManagerView is also used directly by FormDestinationView so the same
//  UI works whether launched from the menu or from the changelogs toolbar.
//

import SwiftUI
import Joyfill
import JoyfillModel

// MARK: - Icon catalogue (matches DecoratorIcon mapping in the SDK)

private struct IconOption: Identifiable, Hashable {
    let id: String       // value stored in Decorator.icon
    let symbol: String   // SF Symbol name
}

private let iconCatalogue: [IconOption] = [
    .init(id: "camera",      symbol: "camera.fill"),
    .init(id: "upload",      symbol: "arrow.up.square.fill"),
    .init(id: "download",    symbol: "arrow.down.square.fill"),
    .init(id: "image",       symbol: "photo.fill"),
    .init(id: "file",        symbol: "doc.fill"),
    .init(id: "comment",     symbol: "message.fill"),
    .init(id: "comments",    symbol: "bubble.left.and.bubble.right.fill"),
    .init(id: "flag",        symbol: "flag.fill"),
    .init(id: "share",       symbol: "square.and.arrow.up.fill"),
    .init(id: "eye",         symbol: "eye.fill"),
    .init(id: "print",       symbol: "printer.fill"),
    .init(id: "folder",      symbol: "folder.fill"),
    .init(id: "paperclip",   symbol: "paperclip"),
    .init(id: "plus",        symbol: "plus.circle.fill"),
    .init(id: "cloud",       symbol: "cloud.fill"),
    .init(id: "circle-info", symbol: "info.circle.fill"),
    .init(id: "filter",      symbol: "line.3.horizontal.decrease.circle.fill"),
    .init(id: "paper-plane", symbol: "paperplane.fill"),
]

// MARK: - Colour presets

private struct ColourPreset: Identifiable, Hashable {
    let id: String   // hex used in Decorator.color
    let color: Color
}

private let colourPresets: [ColourPreset] = [
    .init(id: "#3B82F6", color: Color(red: 0.232, green: 0.510, blue: 0.965)),
    .init(id: "#10B981", color: Color(red: 0.063, green: 0.725, blue: 0.506)),
    .init(id: "#EF4444", color: Color(red: 0.937, green: 0.267, blue: 0.267)),
    .init(id: "#8B5CF6", color: Color(red: 0.545, green: 0.361, blue: 0.965)),
    .init(id: "#F97316", color: Color(red: 0.976, green: 0.451, blue: 0.086)),
    .init(id: "#14B8A6", color: Color(red: 0.078, green: 0.722, blue: 0.651)),
]

// MARK: - Helpers

private func resolvedColor(hex: String?) -> Color {
    colourPresets.first { $0.id.lowercased() == hex?.lowercased() }?.color
        ?? colourPresets[0].color
}

private func resolvedSymbol(iconKey: String?) -> String {
    iconCatalogue.first { $0.id == iconKey }?.symbol ?? "questionmark.circle"
}

private func fieldTypeMeta(_ type: String?) -> (label: String, color: Color) {
    switch type {
    case "text":       return ("Text",       .blue)
    case "number":     return ("Number",     .green)
    case "date":       return ("Date",       .orange)
    case "dropdown":   return ("Dropdown",   .purple)
    case "checkbox":   return ("Checkbox",   Color(red: 0.2, green: 0.7, blue: 0.6))
    case "table":      return ("Table",      .red)
    case "collection": return ("Collection", .red)
    case "image":      return ("Image",      .indigo)
    case "signature":  return ("Signature",  .pink)
    case "chart":      return ("Chart",      .cyan)
    default:
        let t = type ?? ""
        return (t.isEmpty ? "Field" : t.capitalized, .secondary)
    }
}

// MARK: - Error alert model (Identifiable so .alert(item:) works)

struct DecoratorErrorAlert: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Draft model (Identifiable so .sheet(item:) works)

struct DecoratorDraft: Identifiable {
    let id:         UUID   = UUID()
    let path:       String  // full decorator path (field / row / column level)
    let editAction: String? // nil → adding new; non-nil → editing existing (matched by action)
    var icon:       String
    var label:      String
    var color:      String
    var action:     String
}

// MARK: - DecoratorManagerView

/// Full-screen decorator manager sheet.
/// Pass the live `DocumentEditor` — changes reflect immediately in the form.
struct DecoratorManagerView: View {
    @ObservedObject var editor: DocumentEditor
    @Environment(\.dismiss) private var dismiss

    // Lifted to the parent so selection survives sheet dismiss/re-open.
    @Binding var selectedPageID:          String
    @Binding var selectedFieldPositionID: String
    // Shared error alert state (alert attached here so it renders over this sheet)
    @Binding var decoratorError:          DecoratorErrorAlert?

    // Schema / column reset on each open — less critical to persist.
    @State private var draft:           DecoratorDraft? = nil
    @State private var selectedSchemaKey: String = ""
    @State private var selectedColumnID:  String = ""
    @State private var selectedRowID:     String? = nil

    // MARK: Derived — pages

    private var sortedPages: [Page] {
        editor.pagesForCurrentView.filter { $0.id != nil }
    }

    private var selectedPage: Page? {
        sortedPages.first { $0.id == selectedPageID }
    }

    // MARK: Derived — field entries (loaded explicitly from the selected page)

    /// (fieldPositionId, field) pairs for the selected page, in layout order.
    private var fieldEntries: [(fieldPositionId: String, field: JoyDocField)] {
        fieldEntriesForPage(selectedPageID)
    }

    /// Local helper: builds (fieldPositionId, field) pairs for any page using only
    /// public DocumentEditor APIs — no SDK-side method needed.
    private func fieldEntriesForPage(_ pageID: String) -> [(fieldPositionId: String, field: JoyDocField)] {
        guard !pageID.isEmpty,
              let page = editor.pagesForCurrentView.first(where: { $0.id == pageID })
        else { return [] }
        return (page.fieldPositions ?? []).compactMap { pos in
            guard let posID   = pos.id,
                  let fieldID = pos.field,
                  let field   = editor.field(fieldID: fieldID) else { return nil }
            return (posID, field)
        }
    }

    private var selectedField: JoyDocField? {
        fieldEntries.first { $0.fieldPositionId == selectedFieldPositionID }?.field
    }

    private var isCollection: Bool { selectedField?.fieldType == .collection }
    private var isTable:      Bool { selectedField?.fieldType == .table }

    // MARK: Derived — schemas (collection fields only)

    /// All schemas for the selected collection field, root first then children in declared order.
    private var sortedSchemas: [(key: String, schema: Schema)] {
        guard let schemas = selectedField?.schema else { return [] }
        var result: [(String, Schema)] = []
        if let rootEntry = schemas.first(where: { $0.value.root == true }) {
            result.append((rootEntry.key, rootEntry.value))
            for childKey in rootEntry.value.children ?? [] {
                if let child = schemas[childKey] { result.append((childKey, child)) }
            }
        }
        // Append any schemas not reachable from root's children list
        for (key, schema) in schemas where !result.contains(where: { $0.0 == key }) {
            result.append((key, schema))
        }
        return result
    }

    private var selectedSchema: Schema? {
        selectedField?.schema?[selectedSchemaKey]
    }

    // MARK: Derived — rows (table only, for row-specific decorators)

    private var tableRows: [ValueElement] {
        guard isTable else { return [] }
        return (selectedField?.valueToValueElements ?? []).filter { !($0.deleted ?? false) }
    }

    // MARK: Derived — columns

    /// Columns for the currently active scope:
    /// - Collection: columns from the selected schema entry
    /// - Table:      columns directly on the field
    private var sortedColumns: [FieldTableColumn] {
        let cols: [FieldTableColumn]?
        if isCollection {
            cols = selectedSchema?.tableColumns
        } else {
            cols = selectedField?.tableColumns
        }
        return (cols ?? []).filter { $0.id != nil }
    }

    private var selectedColumn: FieldTableColumn? {
        sortedColumns.first { $0.id == selectedColumnID }
    }

    // MARK: Path helpers

    /// "pageId/fieldPositionId"
    private var fieldPath: String? {
        guard !selectedPageID.isEmpty, !selectedFieldPositionID.isEmpty else { return nil }
        return "\(selectedPageID)/\(selectedFieldPositionID)"
    }

    /// "pageId/fieldPositionId/rows" for table common row decorators,
    /// or "pageId/fieldPositionId/{rowId}" for collection (uses first row of selected schema).
    private var rowPath: String? {
        guard let base = fieldPath else { return nil }
        if isTable { return "\(base)/rows" }
        guard let rowID = firstRowID(forSchemaKey: selectedSchemaKey, in: selectedField) else { return nil }
        return "\(base)/\(rowID)"
    }

    /// "pageId/fieldPositionId/{rowId}" — row-specific decorators (table only).
    private var rowSpecificPath: String? {
        guard isTable, let base = fieldPath,
              let rowID = selectedRowID ?? tableRows.first?.id else { return nil }
        return "\(base)/\(rowID)"
    }

    /// "pageId/fieldPositionId/columns/columnId" for tables (common column decorators),
    /// or "pageId/fieldPositionId/{rowId}/{columnId}" for collections (rowId resolves schemaKey).
    private func columnPath(columnID: String) -> String? {
        guard let base = fieldPath else { return nil }
        if isCollection {
            guard let rowID = firstRowID(forSchemaKey: selectedSchemaKey, in: selectedField)
            else { return nil }
            return "\(base)/\(rowID)/\(columnID)"
        }
        // Tables: "columns" keyword routes to common column decorators
        return "\(base)/columns/\(columnID)"
    }

    /// "pageId/fieldPositionId/{rowId}/{columnId}" — cell-specific decorators (table only).
    private func cellSpecificPath(columnID: String) -> String? {
        guard isTable, let base = fieldPath,
              let rowID = selectedRowID ?? tableRows.first?.id else { return nil }
        return "\(base)/\(rowID)/\(columnID)"
    }

    /// Returns the first rowId that belongs to the given schemaKey in a field's value tree.
    /// - Root schema: first root-level row.
    /// - Child schema: first child row found under any parent that has that schema.
    private func firstRowID(forSchemaKey schemaKey: String, in field: JoyDocField?) -> String? {
        guard let field = field else { return nil }
        let rootSchemaKey = field.schema?.first { $0.value.root == true }?.key
        if schemaKey == rootSchemaKey {
            return field.valueToValueElements?.first?.id
        }
        return findFirstChildRow(forSchemaKey: schemaKey, in: field.valueToValueElements ?? [])
    }

    private func findFirstChildRow(forSchemaKey targetKey: String, in rows: [ValueElement]) -> String? {
        for row in rows {
            if let children = row.childrens?[targetKey],
               let firstID  = children.valueToValueElements?.first?.id {
                return firstID
            }
            if let childrens = row.childrens {
                for (_, childGroup) in childrens {
                    if let found = findFirstChildRow(forSchemaKey: targetKey, in: childGroup.valueToValueElements ?? []) {
                        return found
                    }
                }
            }
        }
        return nil
    }

    // MARK: Body

    var body: some View {
        NavigationView {
            Group {
                if sortedPages.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No pages in this document.")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        // ── Page picker ──────────────────────────────────────
                        Section {
                            pagePickerRow
                        } header: { Text("Select Page").textCase(nil) }

                        // ── Field picker — only shown once a page is selected ─
                        if !selectedPageID.isEmpty {
                            Section {
                                fieldPickerRow
                            } header: { Text("Select Field").textCase(nil) }
                        }

                        if let path = fieldPath {

                            // ── Field-level decorators ───────────────────────
                            let fieldDecs = editor.getDecorators(path: path)
                            Section {
                                ForEach(fieldDecs, id: \.action) { decoratorRow($0, path: path) }
                                if fieldDecs.isEmpty { emptyHint("No decorators — tap + to add one") }
                                addButton(badge: .blue) {
                                    draft = DecoratorDraft(path: path, editAction: nil,
                                                          icon: "camera", label: "", color: "#3B82F6", action: "")
                                }
                            } header: {
                                decoratorSectionHeader(title: "Field Decorators", symbol: "tag.fill",
                                                       count: fieldDecs.count, badge: .blue, path: path)
                            }

                            // ── Table / Collection only ──────────────────────
                            if isTable || isCollection {

                                // Schema picker (collection only)
                                if isCollection {
                                    Section {
                                        schemaPickerRow
                                    } header: { Text("Select Schema").textCase(nil) }
                                }

                                // Common row decorators
                                if let rPath = rowPath {
                                    let rowDecs = editor.getDecorators(path: rPath)
                                    Section {
                                        ForEach(rowDecs, id: \.action) { decoratorRow($0, path: rPath) }
                                        if rowDecs.isEmpty { emptyHint("No common row decorators — tap + to add one") }
                                        addButton(badge: .orange) {
                                            draft = DecoratorDraft(path: rPath, editAction: nil,
                                                                   icon: "flag", label: "", color: "#F97316", action: "")
                                        }
                                    } header: {
                                        decoratorSectionHeader(title: isTable ? "Common Row Decorators" : "Row Decorators",
                                                               symbol: "list.bullet.rectangle",
                                                               count: rowDecs.count, badge: .orange, path: rPath)
                                    }
                                } else {
                                    Section {
                                        emptyHint("Add at least one row to manage row decorators.")
                                    } header: {
                                        decoratorSectionHeader(title: "Row Decorators", symbol: "list.bullet.rectangle",
                                                               count: 0, badge: .orange)
                                    }
                                }

                                // Row-specific decorators (table only)
                                if isTable, !tableRows.isEmpty {
                                    Section {
                                        rowPickerRow
                                    } header: { Text("Select Row").textCase(nil) }

                                    if let rsPath = rowSpecificPath {
                                        let rowSpecDecs = editor.getDecorators(path: rsPath)
                                        Section {
                                            ForEach(rowSpecDecs, id: \.action) { decoratorRow($0, path: rsPath) }
                                            if rowSpecDecs.isEmpty { emptyHint("No row-specific decorators — tap + to add one (copies common decorators first)") }
                                            addButton(badge: .red) {
                                                draft = DecoratorDraft(path: rsPath, editAction: nil,
                                                                       icon: "flag", label: "", color: "#EF4444", action: "")
                                            }
                                        } header: {
                                            decoratorSectionHeader(title: "Row-Specific Decorators", symbol: "person.text.rectangle",
                                                                   count: rowSpecDecs.count, badge: .red, path: rsPath)
                                        }
                                    }
                                }

                                // Column picker + column decorators
                                if !sortedColumns.isEmpty {
                                    Section {
                                        columnPickerRow
                                    } header: { Text("Select Column").textCase(nil) }

                                    if let col = selectedColumn, let colID = col.id,
                                       let cPath = columnPath(columnID: colID) {
                                        let colDecs = editor.getDecorators(path: cPath)
                                        Section {
                                            ForEach(colDecs, id: \.action) { decoratorRow($0, path: cPath) }
                                            if colDecs.isEmpty { emptyHint("No column decorators — tap + to add one") }
                                            addButton(badge: .purple) {
                                                draft = DecoratorDraft(path: cPath, editAction: nil,
                                                                       icon: "circle-info", label: "", color: "#8B5CF6", action: "")
                                            }
                                        } header: {
                                            decoratorSectionHeader(title: isTable ? "Common Column Decorators" : "Column Decorators",
                                                                   symbol: "tablecells",
                                                                   count: colDecs.count, badge: .purple, path: cPath)
                                        }

                                        // Cell-specific decorators (table only)
                                        if isTable, !tableRows.isEmpty,
                                           let csPath = cellSpecificPath(columnID: colID) {
                                            let cellDecs = editor.getDecorators(path: csPath)
                                            Section {
                                                ForEach(cellDecs, id: \.action) { decoratorRow($0, path: csPath) }
                                                if cellDecs.isEmpty { emptyHint("No cell-specific decorators — tap + to add one (copies common column decorators first)") }
                                                addButton(badge: .pink) {
                                                    draft = DecoratorDraft(path: csPath, editAction: nil,
                                                                           icon: "circle-info", label: "", color: "#F97316", action: "")
                                                }
                                            } header: {
                                                decoratorSectionHeader(title: "Cell-Specific Decorators", symbol: "rectangle.split.3x1",
                                                                       count: cellDecs.count, badge: .pink, path: csPath)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .onAppear {
                        // Do not auto-select page — user must pick explicitly so
                        // paths are always built from a deliberate page choice.
                        if selectedSchemaKey.isEmpty { selectedSchemaKey = sortedSchemas.first?.key ?? "" }
                        if selectedColumnID.isEmpty  { selectedColumnID  = sortedColumns.first?.id  ?? "" }
                    }
                    .onChange(of: selectedPageID) { _ in
                        // Page changed: clear field selection so user explicitly picks from fresh list
                        selectedFieldPositionID = ""
                        selectedSchemaKey       = ""
                        selectedColumnID        = ""
                    }
                    .onChange(of: selectedFieldPositionID) { _ in
                        selectedSchemaKey = sortedSchemas.first?.key ?? ""
                        selectedColumnID  = sortedColumns.first?.id ?? ""
                        selectedRowID     = nil
                    }
                    .onChange(of: selectedSchemaKey) { _ in
                        selectedColumnID = sortedColumns.first?.id ?? ""
                    }
                }
            }
            .navigationTitle("Decorator Manager")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } }
            }
        }
        .sheet(item: $draft) { d in
            DecoratorEditView(draft: d, decoratorError: $decoratorError, onSave: applyDraft(_:))
        }
        .alert(item: $decoratorError) { err in
            Alert(title: Text("Decorator Error"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: Pickers

    private var pagePickerRow: some View {
        Menu {
            ForEach(sortedPages, id: \.id) { page in
                Button {
                    let pageID = page.id ?? ""
                    // Reset all downstream selections when page changes
                    selectedPageID          = pageID
                    selectedFieldPositionID = ""
                    selectedSchemaKey       = ""
                    selectedColumnID        = ""
                } label: {
                    Label(page.name ?? page.id ?? "",
                          systemImage: selectedPageID == page.id ? "checkmark" : "doc.text")
                }
            }
        } label: {
            pickerLabel(icon: "doc.text", color: .blue, text: selectedPage?.name ?? "Select a page")
        }
    }

    private var fieldPickerRow: some View {
        let meta = fieldTypeMeta(selectedField?.type)
        return Menu {
            ForEach(fieldEntries, id: \.fieldPositionId) { entry in
                Button {
                    selectedFieldPositionID = entry.fieldPositionId
                } label: {
                    Label(entry.field.title ?? entry.field.id ?? "",
                          systemImage: selectedFieldPositionID == entry.fieldPositionId ? "checkmark" : "rectangle.and.pencil.and.ellipsis")
                }
            }
        } label: {
            HStack(spacing: 10) {
                Text(meta.label)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(meta.color.opacity(0.15))
                    .foregroundColor(meta.color)
                    .cornerRadius(5)
                Text(selectedField?.title ?? "Select a field")
                    .font(.subheadline).foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
    }

    private var schemaPickerRow: some View {
        Menu {
            ForEach(sortedSchemas, id: \.key) { entry in
                Button {
                    selectedSchemaKey = entry.key
                } label: {
                    Label(entry.schema.title ?? entry.key,
                          systemImage: selectedSchemaKey == entry.key ? "checkmark" : "square.stack.3d.up")
                }
            }
        } label: {
            pickerLabel(
                icon:  "square.stack.3d.up",
                color: .teal,
                text:  selectedSchema?.title ?? (selectedSchemaKey.isEmpty ? "Select a schema" : selectedSchemaKey)
            )
        }
    }

    private var rowPickerRow: some View {
        let rows = tableRows
        let currentID = selectedRowID ?? rows.first?.id
        return Menu {
            ForEach(rows, id: \.id) { row in
                Button {
                    selectedRowID = row.id
                } label: {
                    Label(row.id ?? "", systemImage: currentID == row.id ? "checkmark" : "list.bullet")
                }
            }
        } label: {
            pickerLabel(icon: "list.bullet", color: .red, text: currentID ?? "Select a row")
        }
    }

    private var columnPickerRow: some View {
        Menu {
            ForEach(sortedColumns, id: \.id) { col in
                Button {
                    selectedColumnID = col.id ?? ""
                } label: {
                    Label(col.title.isEmpty ? (col.id ?? "") : col.title,
                          systemImage: selectedColumnID == col.id ? "checkmark" : "tablecells")
                }
            }
        } label: {
            pickerLabel(
                icon:  "tablecells",
                color: .purple,
                text:  selectedColumn.map { $0.title.isEmpty ? ($0.id ?? "Column") : $0.title } ?? "Select a column"
            )
        }
    }

    /// Shared chevron-picker label layout.
    private func pickerLabel(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.caption.weight(.semibold)).foregroundColor(color)
            Text(text).font(.subheadline).foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }

    // MARK: Section header / row helpers

    private func decoratorSectionHeader(title: String, symbol: String, count: Int, badge: Color, path: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Label(title, systemImage: symbol).textCase(nil)
                Spacer()
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.bold)).foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(badge).clipShape(Capsule())
                }
            }
            if let path = path {
                Text(path)
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }

    private func addButton(badge: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label("Add Decorator", systemImage: "plus.circle.fill")
                .foregroundColor(badge).font(.subheadline.weight(.medium))
        }
    }

    private func emptyHint(_ text: String) -> some View {
        Text(text).font(.caption).foregroundColor(.secondary).padding(.vertical, 2)
    }

    // MARK: Decorator row

    private func decoratorRow(_ deco: Decorator, path: String) -> some View {
        let accent    = resolvedColor(hex: deco.color)
        let symbol    = resolvedSymbol(iconKey: deco.icon)
        let hasAction = !(deco.action ?? "").isEmpty

        return HStack(spacing: 12) {
            ZStack {
                Circle().fill(accent.opacity(0.15)).frame(width: 38, height: 38)
                Image(systemName: symbol).foregroundColor(accent).font(.system(size: 16))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(deco.label ?? "(no label)").font(.subheadline.weight(.medium))
                if let action = deco.action, !action.isEmpty {
                    Text(action).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
            Button {
                draft = DecoratorDraft(path: path, editAction: deco.action,
                                       icon: deco.icon ?? "camera", label: deco.label ?? "",
                                       color: deco.color ?? "#3B82F6", action: deco.action ?? "")
            } label: {
                Image(systemName: "pencil.circle").font(.title3)
                    .foregroundColor(hasAction ? .blue : .secondary)
            }
            .buttonStyle(.plain).disabled(!hasAction)

            Button(role: .destructive) {
                if let action = deco.action { editor.removeDecorator(path: path, action: action) }
            } label: {
                Image(systemName: "trash.circle").font(.title3)
                    .foregroundColor(hasAction ? .red : .secondary)
            }
            .buttonStyle(.plain).disabled(!hasAction)
        }
        .padding(.vertical, 4)
    }

    // MARK: Mutations

    private func applyDraft(_ d: DecoratorDraft) {
        var deco = Decorator()
        deco.icon   = d.icon
        deco.label  = d.label.isEmpty  ? nil : d.label
        deco.color  = d.color
        deco.action = d.action.isEmpty ? nil : d.action

        if let existingAction = d.editAction {
            editor.updateDecorator(path: d.path, action: existingAction, decorator: deco)
        } else {
            editor.addDecorators(path: d.path, decorators: [deco])
        }
    }
}

// MARK: - DecoratorEditView

struct DecoratorEditView: View {
    let draft:  DecoratorDraft
    @Binding var decoratorError: DecoratorErrorAlert?
    let onSave: (DecoratorDraft) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var icon:   String
    @State private var label:  String
    @State private var color:  String
    @State private var action: String

    init(draft: DecoratorDraft,
         decoratorError: Binding<DecoratorErrorAlert?>,
         onSave: @escaping (DecoratorDraft) -> Void) {
        self.draft  = draft
        self._decoratorError = decoratorError
        self.onSave = onSave
        _icon   = State(initialValue: draft.icon)
        _label  = State(initialValue: draft.label)
        _color  = State(initialValue: draft.color)
        _action = State(initialValue: draft.action)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Preview") { previewCard }
                Section("Icon")    { iconGrid    }
                Section("Label")   { labelField  }
                Section("Colour")  { colourRow   }
                Section {
                    actionField
                } header: {
                    Text("Action")
                } footer: {
                    Text("Sent via onFocus(event:) when the decorator button is tapped.")
                }
            }
            .navigationTitle(draft.editAction == nil ? "Add Decorator" : "Edit Decorator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
//                        .fontWeight(.bold)
                        .disabled(icon.isEmpty)
                }
            }
            .alert(item: $decoratorError) { err in
                Alert(title: Text("Decorator Error"),
                      message: Text(err.message),
                      dismissButton: .default(Text("OK")))
            }
        }
    }

    // MARK: Live Preview

    private var previewCard: some View {
        let accent = resolvedColor(hex: color)
        let sym    = resolvedSymbol(iconKey: icon)

        return HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accent.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: sym)
                    .foregroundColor(accent)
                    .font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label.isEmpty ? "Label" : label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(label.isEmpty ? .secondary : .primary)
                if !action.isEmpty {
                    Text(action)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Capsule()
                .fill(accent)
                .frame(width: 4, height: 32)
        }
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.15), value: icon)
        .animation(.easeInOut(duration: 0.15), value: color)
        .animation(.easeInOut(duration: 0.15), value: label)
    }

    // MARK: Icon grid

    private var iconGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
            spacing: 10
        ) {
            ForEach(iconCatalogue) { opt in
                let selected = icon == opt.id
                let accent   = resolvedColor(hex: color)

                Button { icon = opt.id } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selected ? accent.opacity(0.18) : Color(.systemGray6))
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selected ? accent : Color.clear, lineWidth: 2)
                            )
                        Image(systemName: opt.symbol)
                            .foregroundColor(selected ? accent : .secondary)
                            .font(.system(size: 18))
                    }
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.12), value: selected)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: Label

    private var labelField: some View {
        TextField("e.g. Take Photo, Flag Row", text: $label)
    }

    // MARK: Colour swatches

    private var colourRow: some View {
        HStack(spacing: 14) {
            ForEach(colourPresets) { preset in
                let selected = color.lowercased() == preset.id.lowercased()
                Button { color = preset.id } label: {
                    ZStack {
                        Circle().fill(preset.color).frame(width: 32, height: 32)
                        if selected {
                            Circle()
                                .stroke(Color.primary, lineWidth: 2.5)
                                .frame(width: 40, height: 40)
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: 0.12), value: selected)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: Action

    private var actionField: some View {
        TextField("e.g. open_camera, flag_row", text: $action)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }

    // MARK: Save

    private func save() {
        let saved = DecoratorDraft(
            path:       draft.path,
            editAction: draft.editAction,
            icon:       icon,
            label:      label,
            color:      color,
            action:     action
        )
        onSave(saved)
        dismiss()
    }
}

// MARK: - DecoratorAPIDemoView  (standalone entry from the option list)

private class DecoratorEventHandler: FormChangeEvent {
    weak var editor: DocumentEditor?
    var onDecoratorAction: ((String, String) -> Void)? // (action, path)
    var onDecoratorError: ((String) -> Void)?

    func onFocus(event: Event) {
        guard let fieldEvent = event.fieldEvent,
              let action = fieldEvent.type, !action.isEmpty else { return }

        // Build the decorator path from the event
        guard let editor = editor,
              let pageID = fieldEvent.pageID,
              let fieldPositionId = fieldEvent.fieldPositionId else { return }

        let basePath = "\(pageID)/\(fieldPositionId)"
        let path: String
        if let columnID = fieldEvent.columnId {
            let rowID = fieldEvent.rowIds?.first ?? "-"
            path = "\(basePath)/\(rowID)/\(columnID)"
        } else if let rowID = fieldEvent.rowIds?.first {
            path = "\(basePath)/\(rowID)"
        } else {
            path = basePath
        }

        onDecoratorAction?(action, path)

        // Update the tapped decorator to show it was viewed
        var updated = Decorator()
        updated.action = action
        updated.icon   = "eye"
        updated.label  = "Viewed"
        updated.color  = "#10B981"
        editor.updateDecorator(path: path, action: action, decorator: updated)
    }

    func onChange(changes: [Change], document: JoyDoc) { }
    func onBlur(event: Event) { }
    func onUpload(event: UploadEvent) { }
    func onCapture(event: CaptureEvent) { }
    func onError(error: JoyfillError) {
        if case .decoratorError(let e) = error {
            DispatchQueue.main.async { [weak self] in
                self?.onDecoratorError?(e.message)
            }
        }
    }
}

struct DecoratorAPIDemoView: View {
    @StateObject private var editor: DocumentEditor

    @State private var showDecoratorManager      = false
    @State private var lastAction: String        = ""
    @State private var lastPath:   String        = ""
    @State private var showBanner: Bool          = false
    @State private var decoratorError: DecoratorErrorAlert? = nil
    // Persisted across sheet dismissals so the user doesn't have to re-select
    @State private var decoratorPageID:          String = ""
    @State private var decoratorFieldPositionID: String = ""

    init() {
        let handler = DecoratorEventHandler()
        let editor = DocumentEditor(
            document: sampleJSONDocument(fileName: "Navigation"),
            events: handler,
            validateSchema: false,
            license: licenseKey
        )
        handler.editor = editor
        _editor = StateObject(wrappedValue: editor)
    }

    /// The event handler stored inside the editor, cast back to our concrete type.
    private var eventHandler: DecoratorEventHandler? {
        editor.events as? DecoratorEventHandler
    }

    var body: some View {
        VStack(spacing: 0) {
            // Floating action banner
            ZStack(alignment: .bottom) {
                Form(documentEditor: editor)
                    .tint(.blue)

                if showBanner {
                    bannerView
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 28)
                        .zIndex(1)
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: showBanner)
        }
        .navigationTitle("Decorator API Demo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDecoratorManager = true
                } label: {
                    Label("Decorators", systemImage: "paintbrush.pointed.fill")
                }
            }
        }
        .sheet(isPresented: $showDecoratorManager) {
            DecoratorManagerView(
                editor: editor,
                selectedPageID: $decoratorPageID,
                selectedFieldPositionID: $decoratorFieldPositionID,
                decoratorError: $decoratorError
            )
        }
        .onAppear {
            eventHandler?.onDecoratorAction = { action, path in
                lastAction = action
                lastPath   = path
                showBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showBanner = false }
            }
            eventHandler?.onDecoratorError = { message in
                decoratorError = DecoratorErrorAlert(message: message)
            }
        }
        .alert(item: $decoratorError) { err in
            Alert(title: Text("Decorator Error"),
                  message: Text(err.message),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: Banner

    private var bannerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "cursorarrow.rays")
                Text("Action: \"\(lastAction)\"")
                    .font(.subheadline.weight(.medium))
            }
            Text("Path: \(lastPath)")
                .font(.caption.monospaced())
                .opacity(0.85)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.black.opacity(0.82))
        .cornerRadius(16)
    }

}
