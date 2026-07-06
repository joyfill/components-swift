//
//  DecoratorRowUpdateDemoView.swift
//  JoyfillExample
//
//  Purpose
//  -------
//  Verify that the open row-edit form updates live when a row's cell is changed
//  via the Change API *while that row form is still open* — across every column
//  type, not just dropdown.
//
//  Scenario (no SDK change — app side only):
//    1. `DecoratorToRowUpdate.json` has one table with a column of each type
//       (dropdown, text, multiSelect, image, number, date, block, barcode,
//       signature). Every column carries its own column-level decorator
//       (Comment, Camera, Import, Image, File, Download, Claud, Filter, Share).
//    2. The user opens a row and taps one column's decorator.
//    3. The SDK fires `onFocus(event:)` with the decorator action in
//       `fieldEvent.target`, the open row in `fieldEvent.rowIds`, and the
//       tapped column in `fieldEvent.columnId`.
//    4. We catch it here and "call the API" — i.e. push a
//       `field.value.rowUpdate` Change that sets that column's cell with a
//       type-appropriate value (values vary per tap so the change is visible).
//    5. Watch the still-open row form: does that column's editor reflect it?
//
//  The Change-API usage mirrors `DeficiencyTableDemoView`.
//

import Foundation
import SwiftUI
import Joyfill
import JoyfillModel

struct DecoratorRowUpdateDemoView: View {
    @StateObject private var box = DecoratorRowUpdateBox()

    var body: some View {
        VStack(spacing: 0) {
            instructions
            Form(documentEditor: box.editor)
        }
        .navigationTitle("Decorator → Row Change")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let status = box.lastStatus {
                statusBanner(status).padding(.bottom, 24)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: box.lastStatus)
    }

    private var instructions: some View {
        Text("field.update repro: open the Table (or the Collection), tap a row’s decorator (the ‘Edit Row’ pencil). The app fires field.update replacing the WHOLE field value — the table with 5 brand-new rows, the collection with a fresh nested tree — every column’s cell populated. It also sets rowOrder to the new root row IDs (field.update alone won’t, and the table grid renders by rowOrder). The mounted quick view should refresh immediately, without reopening the page. (Column decorators inside a row still set that column’s cell live via field.value.rowUpdate too.)")
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
    }

    private func statusBanner(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.triangle.2.circlepath")
            Text(text).font(.subheadline.weight(.medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.black.opacity(0.82))
        .cornerRadius(14)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Editor box (owns the DocumentEditor + the change handler)

private final class DecoratorRowUpdateBox: ObservableObject {
    let editor: DocumentEditor
    @Published var lastStatus: String?

    private let handler = DecoratorRowUpdateHandler()

    init() {
        let document = DecoratorRowUpdateBox.loadDoc(named: "DecoratorToRowUpdate")
        editor = DocumentEditor(
            document: document,
            mode: .fill,
            events: handler,
            validateSchema: false,
            license: licenseKey,
            singleClickRowEdit: true
        )
        handler.editor = editor
        handler.onStatus = { [weak self] text in
            self?.lastStatus = text
        }
    }

    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}

// MARK: - Change handler: onFocus(decorator) -> Change API rowUpdate, any column type

private final class DecoratorRowUpdateHandler: FormChangeEvent {
    weak var editor: DocumentEditor?
    var onStatus: ((String) -> Void)?

    // Per-column tap counter so repeated taps produce a visibly different value.
    private var tapCounts: [String: Int] = [:]

    func onFocus(event: Event) {
        guard let editor = editor, let f = event.fieldEvent else { return }
        // A decorator tap arrives via onFocus with the action in `target` and the
        // tapped cell's row + column. Ordinary cell focus uses target "focus"/"blur",
        // which won't match any column decorator, so those are ignored below.
        guard let action = f.target,
              let rowIDs = f.rowIds, !rowIDs.isEmpty else { return }

        // Row decorator: carries rowIds but NO columnId. Replace the whole field
        // value via `field.update` — table and collection use separate builders.
        guard let columnID = f.columnId else {
            if editor.field(fieldID: f.fieldID)?.fieldType == .collection {
                handleCollectionRowDecorator(editor: editor, event: f, action: action, rowIDs: rowIDs)
            } else {
                handleRowDecorator(editor: editor, event: f, action: action, rowIDs: rowIDs)
            }
            return
        }

        // Resolve the column — and, for collection fields, the schema it lives in.
        guard let resolved = Self.resolveColumn(editor: editor, fieldID: f.fieldID, columnID: columnID) else {
            return
        }
        let column = resolved.column

        // Confirm this column actually carries a decorator with this action.
        guard (column.decorators ?? []).contains(where: { $0.action == action }) else { return }

        let tap = tapCounts[columnID] ?? 0
        tapCounts[columnID] = tap + 1

        guard let (cellValue, summary) = cellPayloadValue(for: column, tap: tap) else {
            report("“\(action)” — \(column.type?.rawValue ?? "?") column not supported here")
            return
        }

        let target = ChangeTarget(
            fieldID: f.fieldID,
            fieldIdentifier: f.fieldIdentifier,
            fileID: f.fileID ?? "",
            pageID: f.pageID ?? "",
            fieldPositionID: f.fieldPositionId ?? "",
            rowIDs: rowIDs,
            columnID: columnID,
            columnTitle: column.title.isEmpty ? (column.type?.rawValue ?? "column") : column.title,
            schemaKey: resolved.schemaKey
        )

        report("“\(action)” on \(target.columnTitle) — calling Change API…")

        // Simulate the round-trip of "calling an API" that returns the new
        // value, then applying it via the Change API. The async hop also keeps
        // us out of the SDK's focus-dispatch call stack.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.applyChange(target: target, cellValue: cellValue, summary: summary)
        }
    }

    // MARK: Row decorator: replace the WHOLE table value with 5 fresh, fully-populated rows

    /// Handles a row-level decorator tap by replacing the entire table with 5 brand-new rows,
    /// every column's cell populated, via a single `field.update`.
    ///
    /// Important: `field.update` only sets `field.value` — it does NOT touch `field.rowOrder`,
    /// and the grid renders rows by iterating `rowOrder`. So new row IDs that aren't already in
    /// `rowOrder` would render as nothing. We therefore set the field's `rowOrder` to the new
    /// row IDs (via `updateField`) *before* sending the change, so the refresh that `field.update`
    /// triggers rebuilds the grid from the matching value + rowOrder.
    private func handleRowDecorator(editor: DocumentEditor, event f: FieldIdentifier, action: String, rowIDs: [String]) {
        guard let field = editor.field(fieldID: f.fieldID),
              let columns = field.tableColumns, !columns.isEmpty else {
            report("\"\(action)\" - table has no columns")
            return
        }

        report("\"\(action)\" row decorator - replacing table with 5 full rows via field.update...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            guard var field = editor.field(fieldID: f.fieldID) else { return }

            let doc = editor.document

            // Build 5 brand-new rows, each with every column's cell populated.
            var newRowIDs: [String] = []
            let valueArray: [[String: Any]] = (0..<5).map { rowIndex in
                let rowID = Self.randomObjectID()
                newRowIDs.append(rowID)
                var cells: [String: Any] = [:]
                for column in columns {
                    guard let columnID = column.id else { continue }
                    if let (cellValue, _) = self.cellPayloadValue(for: column, tap: rowIndex) {
                        cells[columnID] = cellValue
                    }
                }
                return ["_id": rowID, "deleted": false, "cells": cells]
            }

            // rowOrder must list the new row IDs or the grid renders nothing (field.update
            // never updates rowOrder itself). Set it before the change so the refresh sees it.
            field.rowOrder = newRowIDs
            editor.updateField(field: field)

            let change = Change(
                v: 1,
                sdk: "swift",
                target: "field.update",
                _id: doc.id ?? "",
                identifier: doc.identifier ?? "",
                fileId: f.fileID ?? "",
                pageId: f.pageID ?? "",
                fieldId: f.fieldID,
                fieldIdentifier: f.fieldIdentifier ?? field.identifier,
                fieldPositionId: f.fieldPositionId ?? "",
                change: ["value": valueArray],
                createdOn: Date().timeIntervalSince1970
            )

            editor.change(changes: [change])
            self.report("Replaced table -> 5 rows, all cells set")
        }
    }

    // MARK: Collection row decorator: replace the WHOLE collection value with a fresh nested tree

    /// Handles a collection row-level decorator tap by replacing the entire collection
    /// with a freshly built nested tree via a single `field.update`. Mirrors the table
    /// path: `field.update` only sets `field.value`, so we also set `field.rowOrder` to
    /// the new root row IDs before sending the change.
    private func handleCollectionRowDecorator(editor: DocumentEditor, event f: FieldIdentifier, action: String, rowIDs: [String]) {
        guard let rootKey = editor.field(fieldID: f.fieldID)?.schema?
            .first(where: { $0.value.root == true })?.key else {
            report("\"\(action)\" - collection has no root schema")
            return
        }

        report("\"\(action)\" collection row decorator - replacing collection via field.update...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self else { return }
            guard var field = editor.field(fieldID: f.fieldID), let schema = field.schema else { return }
            let doc = editor.document

            var rootRowIDs: [String] = []
            let valueArray = self.buildCollectionRows(
                schema: schema,
                schemaKey: rootKey,
                rowCount: 3,
                seed: 0,
                isRoot: true,
                rootRowIDs: &rootRowIDs
            )

            // rowOrder lists the new root row IDs (field.update never sets it itself).
            field.rowOrder = rootRowIDs
            editor.updateField(field: field)

            let change = Change(
                v: 1,
                sdk: "swift",
                target: "field.update",
                _id: doc.id ?? "",
                identifier: doc.identifier ?? "",
                fileId: f.fileID ?? "",
                pageId: f.pageID ?? "",
                fieldId: f.fieldID,
                fieldIdentifier: f.fieldIdentifier ?? field.identifier,
                fieldPositionId: f.fieldPositionId ?? "",
                change: ["value": valueArray],
                createdOn: Date().timeIntervalSince1970
            )

            editor.change(changes: [change])
            self.report("Replaced collection -> \(rootRowIDs.count) root rows + nested")
        }
    }

    /// Recursively builds collection rows for `schemaKey`, populating each column's cell
    /// and one branch of children per schema `children` entry. Children are nested under
    /// `children[childSchemaKey].value`, matching the collection value shape.
    private func buildCollectionRows(schema: [String: Schema], schemaKey: String, rowCount: Int, seed: Int, isRoot: Bool, rootRowIDs: inout [String]) -> [[String: Any]] {
        guard let node = schema[schemaKey] else { return [] }
        let columns = node.tableColumns ?? []
        let childKeys = node.children ?? []

        var rows: [[String: Any]] = []
        for i in 0..<rowCount {
            let rowID = Self.randomObjectID()
            if isRoot { rootRowIDs.append(rowID) }

            var cells: [String: Any] = [:]
            for column in columns {
                guard let colID = column.id else { continue }
                if let (cellValue, _) = self.cellPayloadValue(for: column, tap: seed + i) {
                    cells[colID] = cellValue
                }
            }

            var row: [String: Any] = ["_id": rowID, "deleted": false, "cells": cells]

            if !childKeys.isEmpty {
                var children: [String: Any] = [:]
                for childKey in childKeys {
                    let nested = buildCollectionRows(
                        schema: schema,
                        schemaKey: childKey,
                        rowCount: 2,
                        seed: i,
                        isRoot: false,
                        rootRowIDs: &rootRowIDs
                    )
                    children[childKey] = ["value": nested]
                }
                row["children"] = children
            }
            rows.append(row)
        }
        return rows
    }

    // MARK: Value generation per column type

    /// Builds a `cells` payload value (already in the dictionary form the SDK
    /// emits) plus a short human summary for the status banner. Returns nil for
    /// column types that have no editable cell in the row form.
    private func cellPayloadValue(for column: FieldTableColumn, tap n: Int) -> (value: Any, summary: String)? {
        switch column.type ?? .unknown {
        case .text, .barcode:
            let v = "Updated #\(n + 1)"
            return (v, "“\(v)”")

        case .signature:
            // Signature cell value is a string (image URL / data URL).
            let v = "https://picsum.photos/seed/sig\(n + 1)/300/120"
            return (v, "sample signature image")

        case .number:
            let v = Double((n + 1) * 10)
            return (v, "\(Int(v))")

        case .date:
            // Date cells store epoch milliseconds as a Double.
            let millis = Date().timeIntervalSince1970 * 1000
            return (millis, "today")

        case .dropdown:
            guard let opt = nextOption(column, tap: n) else { return nil }
            return (opt.id, "“\(opt.value)”")

        case .multiSelect:
            guard let opt = nextOption(column, tap: n) else { return nil }
            return ([opt.id], "“\(opt.value)”")

        case .image:
            let element: [String: Any] = [
                "_id": Self.randomObjectID(),
                "url": "https://picsum.photos/seed/img\(n + 1)/300/200"
            ]
            return ([element], "1 image")

        case .block:
            // Block columns are display-only — no editor in the row form, so this
            // won't visibly refresh; included so the action is still acknowledged.
            let v = "Block #\(n + 1)"
            return (v, "“\(v)” (block is display-only)")

        case .progress, .table, .unknown:
            return nil
        }
    }

    private func nextOption(_ column: FieldTableColumn, tap n: Int) -> (id: String, value: String)? {
        let opts = (column.options ?? []).filter { !($0.deleted ?? false) }
        guard !opts.isEmpty else { return nil }
        let o = opts[n % opts.count]
        return (o.id ?? "", o.value ?? "")
    }

    // MARK: Change application

    private func applyChange(target: ChangeTarget, cellValue: Any, summary: String) {
        guard let editor = editor else { return }
        let doc = editor.document

        // One rowUpdate per selected row — covers single edit (1 row) and bulk edit (N rows).
        let changes: [Change] = target.rowIDs.map { rowID in
            var payload: [String: Any] = [
                "rowId": rowID,
                "row": [
                    "_id": rowID,
                    "cells": [target.columnID: cellValue]
                ]
            ]
            // Collection rows carry their schema id so the change resolves to the right schema.
            if let schemaKey = target.schemaKey {
                payload["schemaId"] = schemaKey
            }
            return Change(
                v: 1,
                sdk: "swift",
                target: "field.value.rowUpdate",
                _id: doc.id ?? "",
                identifier: doc.identifier ?? "",
                fileId: target.fileID,
                pageId: target.pageID,
                fieldId: target.fieldID,
                fieldIdentifier: target.fieldIdentifier,
                fieldPositionId: target.fieldPositionID,
                change: payload,
                createdOn: Date().timeIntervalSince1970
            )
        }

        editor.change(changes: changes)
        let scope = target.rowIDs.count == 1 ? "" : " (\(target.rowIDs.count) rows)"
        report("Set \(target.columnTitle) → \(summary)\(scope)")
    }

    // MARK: Helpers

    private struct ChangeTarget {
        let fieldID: String
        let fieldIdentifier: String?
        let fileID: String
        let pageID: String
        let fieldPositionID: String
        let rowIDs: [String]
        let columnID: String
        let columnTitle: String
        let schemaKey: String?   // nil for table fields; schema key for collection rows
    }

    /// Resolves the tapped column and, for collection fields, the schema key it lives in.
    private static func resolveColumn(editor: DocumentEditor, fieldID: String, columnID: String) -> (column: FieldTableColumn, schemaKey: String?)? {
        guard let field = editor.field(fieldID: fieldID) else { return nil }
        if field.fieldType == .collection {
            for (key, schema) in field.schema ?? [:] {
                if let col = schema.tableColumns?.first(where: { $0.id == columnID }) {
                    return (col, key)
                }
            }
            return nil
        }
        if let col = field.tableColumns?.first(where: { $0.id == columnID }) {
            return (col, nil)
        }
        return nil
    }

    private static func randomObjectID() -> String {
        let chars = Array("0123456789abcdef")
        return String((0..<24).map { _ in chars.randomElement()! })
    }

    private func report(_ text: String) {
        DispatchQueue.main.async { [weak self] in self?.onStatus?(text) }
    }

    func onChange(changes: [Change], document: JoyDoc) {}
    func onBlur(event: Event) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) {}
}
