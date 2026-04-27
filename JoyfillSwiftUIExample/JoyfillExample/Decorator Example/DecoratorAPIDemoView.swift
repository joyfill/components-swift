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

// MARK: - Hop step for unbounded-depth path chain

/// One descent step.
/// `schemaKey == nil` means root-level descent (table or collection root schema).
/// `schemaKey == "sk"` means we entered this row via `/schemas/sk/` from the parent row.
struct DecoratorHopStep: Hashable {
    let schemaKey: String?
    let rowID: String
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

    // Unbounded-depth path state — also lifted so it survives dismiss/re-open.
    //   hopChain       — descent chain (row-id plus optional schema-key entry prefix)
    //   pendingSchema  — child schema selected for the *next* descent (collection only)
    //   selectedColumnID — column used for column / cell / row-scoped-column paths
    @Binding var hopChain:         [DecoratorHopStep]
    @Binding var pendingSchema:    String
    @Binding var selectedColumnID: String

    @State private var draft: DecoratorDraft? = nil

    // Ad-hoc path tester — paste / type any path and exercise the four
    // decorator APIs against it. Useful for poking at edge cases (malformed
    // paths, deleted rows, schema-graph violations, …) without rebuilding
    // the whole picker chain.
    @State private var customPath: String = ""
    @State private var customPathReadResult: String = ""
    @State private var customPathActionInput: String = ""

    // MARK: Derived — pages

    private var sortedPages: [Page] {
        editor.pagesForCurrentView.filter { $0.id != nil }
    }

    private var selectedPage: Page? {
        sortedPages.first { $0.id == selectedPageID }
    }

    // MARK: Derived — field entries (loaded explicitly from the selected page)

    private var fieldEntries: [(fieldPositionId: String, field: JoyDocField)] {
        fieldEntriesForPage(selectedPageID)
    }

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
    private var isTabular:    Bool { isTable || isCollection }

    // MARK: Derived — schema helpers

    private var collectionRootSchemaKey: String? {
        selectedField?.schema?.first(where: { $0.value.root == true })?.key
    }

    /// Schema we're currently "inside" after walking the hop chain.
    /// - Table: always nil
    /// - Collection, empty chain: root schema key
    /// - Collection, after N hops: hopChain.last.schemaKey ?? root
    private var currentSchemaKey: String? {
        guard isCollection else { return nil }
        if hopChain.isEmpty { return collectionRootSchemaKey }
        return hopChain.last?.schemaKey ?? collectionRootSchemaKey
    }

    /// Effective schema for column lookup at the current level:
    /// pendingSchema overrides currentSchemaKey when the user is about to descend.
    private var effectiveSchemaKey: String? {
        if !pendingSchema.isEmpty { return pendingSchema }
        return currentSchemaKey
    }

    /// Child schemas that can be descended into from the current level.
    private var availableChildSchemas: [(key: String, schema: Schema)] {
        guard isCollection,
              let ck = currentSchemaKey,
              let current = selectedField?.schema?[ck]
        else { return [] }
        return (current.children ?? []).compactMap { key in
            guard let s = selectedField?.schema?[key] else { return nil }
            return (key, s)
        }
    }

    // MARK: Derived — walking the row tree

    /// Walks the hop chain and returns the ValueElement at the tip (nil if chain empty or broken).
    private func walkToChainTip() -> ValueElement? {
        guard let field = selectedField else { return nil }
        var list: [ValueElement] = field.valueToValueElements ?? []
        var tip: ValueElement? = nil
        for (idx, hop) in hopChain.enumerated() {
            if idx > 0 {
                guard let sk = hop.schemaKey,
                      let children = tip?.childrens?[sk]?.valueToValueElements else { return nil }
                list = children
            }
            guard let el = list.first(where: { $0.id == hop.rowID && !($0.deleted ?? false) }) else { return nil }
            tip = el
        }
        return tip
    }

    /// Rows available for descent at the current level.
    private var availableRows: [ValueElement] {
        if hopChain.isEmpty {
            // Root-level rows (table or collection root schema)
            guard isTabular else { return [] }
            return (selectedField?.valueToValueElements ?? []).filter { !($0.deleted ?? false) }
        }
        // Inside a row — need a pending schema to know which child list to show
        guard isCollection, !pendingSchema.isEmpty, let tip = walkToChainTip() else { return [] }
        return (tip.childrens?[pendingSchema]?.valueToValueElements ?? []).filter { !($0.deleted ?? false) }
    }

    // MARK: Derived — columns for the current level

    private var sortedColumns: [FieldTableColumn] {
        let cols: [FieldTableColumn]?
        if isTable {
            cols = selectedField?.tableColumns
        } else if isCollection, let sk = effectiveSchemaKey {
            cols = selectedField?.schema?[sk]?.tableColumns
        } else {
            cols = nil
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

    /// Path built by walking every hop — this is the row-self path when chain is non-empty.
    private var chainRowPath: String? {
        guard let base = fieldPath else { return nil }
        var p = base
        for hop in hopChain {
            if let sk = hop.schemaKey { p += "/schemas/\(sk)" }
            p += "/\(hop.rowID)"
        }
        return p
    }

    /// Prefix at the current "level" — chainRowPath + optional `/schemas/{pending}`.
    private var currentLevelPrefix: String? {
        guard let row = chainRowPath else { return nil }
        if !pendingSchema.isEmpty { return "\(row)/schemas/\(pendingSchema)" }
        return row
    }

    /// Common-rows path at the current level.
    /// Only valid at a level boundary: root (chain empty) OR after a pendingSchema.
    /// A nested collection row without pendingSchema has no common-rows path because
    /// the parser requires `/schemas/{sk}/rows` to disambiguate the child list.
    /// Table never nests, so rows path exists only when chain is empty.
    private var rowsPath: String? {
        guard let prefix = currentLevelPrefix else { return nil }
        if hopChain.isEmpty { return isTabular ? "\(prefix)/rows" : nil }
        guard isCollection, !pendingSchema.isEmpty else { return nil }
        return "\(prefix)/rows"
    }

    /// Row-self path (chain must be non-empty, no pending schema).
    private var rowSelfPath: String? {
        guard !hopChain.isEmpty, pendingSchema.isEmpty else { return nil }
        return chainRowPath
    }

    /// Common-column path at the current level (for a given column).
    /// Same level-boundary rule as `rowsPath` — inside a nested collection row
    /// without pendingSchema, emit nothing (the user would just be looking at
    /// a row-scoped column, which aliases the cell path).
    private func commonColumnPath(columnID: String) -> String? {
        guard let prefix = currentLevelPrefix else { return nil }
        if hopChain.isEmpty { return isTabular ? "\(prefix)/columns/\(columnID)" : nil }
        guard isCollection, !pendingSchema.isEmpty else { return nil }
        return "\(prefix)/columns/\(columnID)"
    }

    /// Cell-specific path (chain non-empty, pending schema cleared).
    private func cellPath(columnID: String) -> String? {
        guard !hopChain.isEmpty, pendingSchema.isEmpty, let row = chainRowPath else { return nil }
        return "\(row)/\(columnID)"
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

                        // ── Custom path tester ───────────────────────────────
                        customPathSection

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
                            if isTabular {

                                // Path chain navigator
                                Section {
                                    chainNavigator
                                } header: {
                                    Text("Path Chain").textCase(nil)
                                } footer: {
                                    Text("Descend into rows (and child schemas for collections) to build arbitrary-depth paths.")
                                        .font(.caption)
                                }

                                // Common row decorators at current level
                                if let rPath = rowsPath {
                                    let rowDecs = editor.getDecorators(path: rPath)
                                    Section {
                                        ForEach(rowDecs, id: \.action) { decoratorRow($0, path: rPath) }
                                        if rowDecs.isEmpty { emptyHint("No common row decorators — tap + to add one") }
                                        addButton(badge: .orange) {
                                            draft = DecoratorDraft(path: rPath, editAction: nil,
                                                                   icon: "flag", label: "", color: "#F97316", action: "")
                                        }
                                    } header: {
                                        decoratorSectionHeader(title: "Common Row Decorators",
                                                               symbol: "list.bullet.rectangle",
                                                               count: rowDecs.count, badge: .orange, path: rPath)
                                    }
                                }

                                // Row-self decorators (when chain is non-empty)
                                if let rsPath = rowSelfPath, pendingSchema.isEmpty {
                                    let rowSelfDecs = editor.getDecorators(path: rsPath)
                                    Section {
                                        ForEach(rowSelfDecs, id: \.action) { decoratorRow($0, path: rsPath) }
                                        if rowSelfDecs.isEmpty { emptyHint("No row-specific decorators — tap + to add one (copies common row decorators first)") }
                                        addButton(badge: .red) {
                                            draft = DecoratorDraft(path: rsPath, editAction: nil,
                                                                   icon: "flag", label: "", color: "#EF4444", action: "")
                                        }
                                    } header: {
                                        decoratorSectionHeader(title: "Row-Specific Decorators",
                                                               symbol: "person.text.rectangle",
                                                               count: rowSelfDecs.count, badge: .red, path: rsPath)
                                    }
                                }

                                // Column picker + column / cell decorators
                                if !sortedColumns.isEmpty {
                                    Section {
                                        columnPickerRow
                                    } header: { Text("Select Column").textCase(nil) }

                                    if let col = selectedColumn, let colID = col.id {
                                        // Common column
                                        if let cPath = commonColumnPath(columnID: colID) {
                                            let colDecs = editor.getDecorators(path: cPath)
                                            Section {
                                                ForEach(colDecs, id: \.action) { decoratorRow($0, path: cPath) }
                                                if colDecs.isEmpty { emptyHint("No common column decorators — tap + to add one") }
                                                addButton(badge: .purple) {
                                                    draft = DecoratorDraft(path: cPath, editAction: nil,
                                                                           icon: "circle-info", label: "", color: "#8B5CF6", action: "")
                                                }
                                            } header: {
                                                decoratorSectionHeader(title: "Common Column Decorators",
                                                                       symbol: "tablecells",
                                                                       count: colDecs.count, badge: .purple, path: cPath)
                                            }
                                        }

                                        // Cell-specific (chain non-empty, pending schema cleared)
                                        if let csPath = cellPath(columnID: colID) {
                                            let cellDecs = editor.getDecorators(path: csPath)
                                            Section {
                                                ForEach(cellDecs, id: \.action) { decoratorRow($0, path: csPath) }
                                                if cellDecs.isEmpty { emptyHint("No cell-specific decorators — tap + to add one (copies common column decorators first)") }
                                                addButton(badge: .pink) {
                                                    draft = DecoratorDraft(path: csPath, editAction: nil,
                                                                           icon: "circle-info", label: "", color: "#F97316", action: "")
                                                }
                                            } header: {
                                                decoratorSectionHeader(title: "Cell-Specific Decorators",
                                                                       symbol: "rectangle.split.3x1",
                                                                       count: cellDecs.count, badge: .pink, path: csPath)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .onChange(of: selectedPageID) { _ in
                        selectedFieldPositionID = ""
                        resetChain()
                    }
                    .onChange(of: selectedFieldPositionID) { _ in
                        resetChain()
                    }
                    .onChange(of: pendingSchema) { _ in
                        selectedColumnID = sortedColumns.first?.id ?? ""
                    }
                    // Selection state (hopChain / selectedColumnID) survives sheet
                    // dismiss/re-open. If the user deletes a row outside this
                    // sheet and reopens it, the saved chain may point at a row
                    // that no longer exists. Without this trim, every body
                    // pass would call getDecorators on the stale row-self /
                    // cell paths, the SDK would emit `onError` on each call,
                    // the alert would pop, dismissing the alert would trigger
                    // another redraw, and we'd loop. Trim back to the last
                    // reachable prefix on appear and on editor changes.
                    .onAppear { trimStaleChainIfNeeded() }
                    .onReceive(editor.objectWillChange) { _ in
                        DispatchQueue.main.async { trimStaleChainIfNeeded() }
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

    private func resetChain() {
        hopChain = []
        pendingSchema = ""
        selectedColumnID = sortedColumns.first?.id ?? ""
    }

    // MARK: Custom path tester

    @ViewBuilder
    private var customPathSection: some View {
        Section {
            if #available(iOS 16.0, *) {
                TextField("page-id/field-position-id/...", text: $customPath, axis: .vertical)
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(2...5)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                TextField("page-id/field-position-id/...", text: $customPath)
                    .font(.system(.footnote, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }

            HStack {
                Button {
                    runCustomGet()
                } label: {
                    Label("Get", systemImage: "magnifyingglass")
                }
                .buttonStyle(.bordered)
                .disabled(customPath.trimmingCharacters(in: .whitespaces).isEmpty)

                Button {
                    runCustomAdd()
                } label: {
                    Label("Add", systemImage: "plus.circle")
                }
                .buttonStyle(.bordered)
                .disabled(customPath.trimmingCharacters(in: .whitespaces).isEmpty)

                Spacer()

                Button(role: .destructive) {
                    customPath = ""
                    customPathReadResult = ""
                    customPathActionInput = ""
                } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
                .buttonStyle(.borderless)
            }

            HStack {
                TextField("action (for remove)", text: $customPathActionInput)
                    .font(.system(.footnote, design: .monospaced))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button {
                    runCustomRemove()
                } label: {
                    Label("Remove", systemImage: "minus.circle")
                }
                .buttonStyle(.bordered)
                .disabled(customPath.trimmingCharacters(in: .whitespaces).isEmpty
                          || customPathActionInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !customPathReadResult.isEmpty {
                Text(customPathReadResult)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } header: {
            Text("Custom Path Tester").textCase(nil)
        } footer: {
            Text("Paste any path and call Get / Add / Remove against it. SDK errors surface in the shared alert.")
                .font(.caption)
        }
    }

    private var trimmedCustomPath: String {
        customPath.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func runCustomGet() {
        let path = trimmedCustomPath
        let decs = editor.getDecorators(path: path)
        if decs.isEmpty {
            customPathReadResult = "→ [] (path resolved or didn't — check error alert)"
        } else {
            let summary = decs.map { d in
                "\(d.action ?? "?") (\(d.label ?? "")\(d.icon.map { " \($0)" } ?? ""))"
            }.joined(separator: ", ")
            customPathReadResult = "→ \(decs.count): \(summary)"
        }
    }

    private func runCustomAdd() {
        let path = trimmedCustomPath
        draft = DecoratorDraft(path: path, editAction: nil,
                               icon: "flag", label: "Custom", color: "#3B82F6",
                               action: "custom-\(Int(Date().timeIntervalSince1970) % 10_000)")
    }

    private func runCustomRemove() {
        let path = trimmedCustomPath
        let action = customPathActionInput.trimmingCharacters(in: .whitespacesAndNewlines)
        editor.removeDecorator(path: path, action: action)
        runCustomGet()
    }

    /// Walks `hopChain` against the currently selected field's value tree and
    /// drops any trailing hops whose row is missing or soft-deleted. Cheap —
    /// O(chain depth × siblings per level). Called on appear and after every
    /// editor publish so the demo never builds a path that points at a row
    /// the user has just deleted.
    private func trimStaleChainIfNeeded() {
        guard let field = selectedField, !hopChain.isEmpty else { return }
        var current = field.valueToValueElements ?? []
        var validPrefix: [DecoratorHopStep] = []
        for (i, hop) in hopChain.enumerated() {
            guard let row = current.first(where: { $0.id == hop.rowID && $0.deleted != true }) else {
                break
            }
            validPrefix.append(hop)
            if i == hopChain.count - 1 { return } // whole chain still reachable
            let nextHop = hopChain[i + 1]
            guard let sk = nextHop.schemaKey,
                  let children = row.childrens?[sk]?.valueToValueElements else { break }
            current = children
        }
        guard validPrefix.count != hopChain.count else { return }
        hopChain = validPrefix
        pendingSchema = ""
    }

    // MARK: Chain navigator UI

    @ViewBuilder
    private var chainNavigator: some View {
        // Breadcrumb
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "location.fill").font(.caption2).foregroundColor(.secondary)
                Text("root")
                    .font(.caption.monospaced())
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.12))
                    .cornerRadius(4)
                ForEach(Array(hopChain.enumerated()), id: \.offset) { _, hop in
                    Image(systemName: "chevron.right").font(.caption2).foregroundColor(.secondary)
                    if let sk = hop.schemaKey {
                        Text("sk:\(sk)")
                            .font(.caption.monospaced())
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.teal.opacity(0.15)).foregroundColor(.teal)
                            .cornerRadius(4)
                        Image(systemName: "chevron.right").font(.caption2).foregroundColor(.secondary)
                    }
                    Text(shortID(hop.rowID))
                        .font(.caption.monospaced())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.orange.opacity(0.15)).foregroundColor(.orange)
                        .cornerRadius(4)
                }
                if !pendingSchema.isEmpty {
                    Image(systemName: "chevron.right").font(.caption2).foregroundColor(.secondary)
                    Text("sk:\(pendingSchema)")
                        .font(.caption.monospaced())
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.teal.opacity(0.15)).foregroundColor(.teal)
                        .cornerRadius(4)
                }
            }
        }

        // Descend into a child schema (collection only)
        if isCollection, !availableChildSchemas.isEmpty {
            Menu {
                Button("(none)") { pendingSchema = "" }
                ForEach(availableChildSchemas, id: \.key) { entry in
                    Button {
                        pendingSchema = entry.key
                    } label: {
                        Label(entry.schema.title ?? entry.key,
                              systemImage: pendingSchema == entry.key ? "checkmark" : "square.stack.3d.up")
                    }
                }
            } label: {
                pickerLabel(icon: "square.stack.3d.up", color: .teal,
                            text: pendingSchema.isEmpty ? "Pick child schema (optional)" : "sk: \(pendingSchema)")
            }
        }

        // Descend into a row
        if !availableRows.isEmpty {
            Menu {
                ForEach(availableRows, id: \.id) { row in
                    Button {
                        descend(into: row)
                    } label: {
                        Label(shortID(row.id ?? ""), systemImage: "arrow.down.forward")
                    }
                }
            } label: {
                pickerLabel(icon: "arrow.down.forward.circle", color: .orange,
                            text: hopChain.isEmpty ? "Descend into row…" : "Descend further into row…")
            }
        } else if isCollection && !hopChain.isEmpty && pendingSchema.isEmpty && !availableChildSchemas.isEmpty {
            Text("Pick a child schema above to list nested rows.")
                .font(.caption).foregroundColor(.secondary)
        }

        // Go up
        if !hopChain.isEmpty || !pendingSchema.isEmpty {
            Button {
                goUp()
            } label: {
                Label("Go up one level", systemImage: "arrow.up.left.circle")
                    .foregroundColor(.blue)
            }
        }
    }

    private func descend(into row: ValueElement) {
        guard let rid = row.id else { return }
        let sk: String? = hopChain.isEmpty ? nil : (pendingSchema.isEmpty ? nil : pendingSchema)
        // Root-level descent must have nil schemaKey; nested descent requires pendingSchema.
        if !hopChain.isEmpty && pendingSchema.isEmpty { return }
        hopChain.append(DecoratorHopStep(schemaKey: sk, rowID: rid))
        pendingSchema = ""
        selectedColumnID = sortedColumns.first?.id ?? ""
    }

    private func goUp() {
        if !pendingSchema.isEmpty {
            pendingSchema = ""
        } else if !hopChain.isEmpty {
            hopChain.removeLast()
        }
        selectedColumnID = sortedColumns.first?.id ?? ""
    }

    private func shortID(_ s: String) -> String {
        s.count <= 10 ? s : String(s.prefix(6)) + "…" + String(s.suffix(3))
    }

    // MARK: Pickers

    private var pagePickerRow: some View {
        Menu {
            ForEach(sortedPages, id: \.id) { page in
                Button {
                    let pageID = page.id ?? ""
                    selectedPageID          = pageID
                    selectedFieldPositionID = ""
                    resetChain()
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
                    .lineLimit(3)
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

private class EditorBox: ObservableObject {
    let editor: DocumentEditor

    var onAction: ((String, String) -> Void)?
    var onError:  ((String) -> Void)?

    init() {
        let handler = DecoratorEventHandler()
        let ed = DocumentEditor(
            document: sampleJSONDocument(fileName: "Navigation"),
            events: handler,
            validateSchema: false,
            license: licenseKey
        )
        handler.editor = ed
        self.editor = ed
    }

    func wire() {
        guard let h = editor.events as? DecoratorEventHandler else { return }
        h.onDecoratorAction = onAction
        h.onDecoratorError  = onError
    }
}

private class DecoratorEventHandler: FormChangeEvent {
    weak var editor: DocumentEditor?
    var onDecoratorAction: ((String, String) -> Void)? // (action, path)
    var onDecoratorError: ((String) -> Void)?

    func onFocus(event: Event) {}
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
    @StateObject private var box              = EditorBox()
    @Environment(\.dismiss) private var dismiss

    @State private var showDecoratorManager      = false
    @State private var lastAction: String        = ""
    @State private var lastPath:   String        = ""
    @State private var showBanner: Bool          = false
    @State private var decoratorError: DecoratorErrorAlert? = nil
    // Persisted across sheet dismissals so the user doesn't have to re-select
    @State private var decoratorPageID:          String = ""
    @State private var decoratorFieldPositionID: String = ""
    @State private var decoratorHopChain:        [DecoratorHopStep] = []
    @State private var decoratorPendingSchema:   String = ""
    @State private var decoratorColumnID:        String = ""

    private var editor: DocumentEditor { box.editor }

    private func cleanupEventCallbacks() {
        box.onAction = nil
        box.onError = nil
        if let h = box.editor.events as? DecoratorEventHandler {
            h.onDecoratorAction = nil
            h.onDecoratorError = nil
        }
    }

    private func closeOverlaysBeforeExit() {
        showDecoratorManager = false
        decoratorError = nil
    }

    private func handleBackTap() {
        closeOverlaysBeforeExit()
        DispatchQueue.main.async {
            dismiss()
        }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: handleBackTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showDecoratorManager = true } label: {
                    Label("Decorators", systemImage: "paintbrush.pointed.fill")
                }
            }
        }
        .sheet(isPresented: $showDecoratorManager) {
            DecoratorManagerView(
                editor: editor,
                selectedPageID: $decoratorPageID,
                selectedFieldPositionID: $decoratorFieldPositionID,
                decoratorError: $decoratorError,
                hopChain: $decoratorHopChain,
                pendingSchema: $decoratorPendingSchema,
                selectedColumnID: $decoratorColumnID
            )
        }
        .onAppear {
            box.onAction = { action, path in
                lastAction = action
                lastPath   = path
                showBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { showBanner = false }
            }
            box.onError = { message in
                decoratorError = DecoratorErrorAlert(message: message)
            }
            box.wire()
        }
        .onDisappear {
            closeOverlaysBeforeExit()
            cleanupEventCallbacks()
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
