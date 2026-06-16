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
        Text("Open a row, then tap any column’s decorator (Comment, Camera, Import, Image, File, Download, Claud, Filter, Share). The app catches onFocus and sets that column’s cell for the open row via the Change API — watch the editor update.")
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

    // Valid decorator action strings in the doc (built once). Lets us react to
    // decorator taps and ignore ordinary cell focus/blur (target == "focus"/"blur").
    private var decoratorActions: Set<String>?

    // Per-column tap counter so repeated taps produce a visibly different value.
    private var tapCounts: [String: Int] = [:]

    func onFocus(event: Event) {
        guard let editor = editor, let f = event.fieldEvent else { return }

        if decoratorActions == nil {
            decoratorActions = Self.collectDecoratorActions(editor: editor, fieldID: f.fieldID)
        }
        // Only react to decorator taps, not normal cell focus/blur events.
        guard let action = f.target, decoratorActions?.contains(action) == true else { return }

        guard let rowID = f.rowIds?.first, let columnID = f.columnId else {
            report("“\(f.target ?? "?")” fired but event lacked rowId/columnId")
            return
        }
        guard let column = (editor.field(fieldID: f.fieldID)?.tableColumns ?? [])
            .first(where: { $0.id == columnID }) else {
            report("Column \(columnID) not found")
            return
        }

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
            rowID: rowID,
            columnID: columnID,
            columnTitle: column.title.isEmpty ? (column.type?.rawValue ?? "column") : column.title
        )

        report("“\(action)” on \(target.columnTitle) — calling Change API…")

        // Simulate the round-trip of "calling an API" that returns the new
        // value, then applying it via the Change API. The async hop also keeps
        // us out of the SDK's focus-dispatch call stack.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.applyChange(target: target, cellValue: cellValue, summary: summary)
        }
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

        let payload: [String: Any] = [
            "rowId": target.rowID,
            "row": [
                "_id": target.rowID,
                "cells": [target.columnID: cellValue]
            ]
        ]

        let change = Change(
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

        editor.change(changes: [change])
        report("Set \(target.columnTitle) → \(summary)")
    }

    // MARK: Helpers

    private struct ChangeTarget {
        let fieldID: String
        let fieldIdentifier: String?
        let fileID: String
        let pageID: String
        let fieldPositionID: String
        let rowID: String
        let columnID: String
        let columnTitle: String
    }

    private static func collectDecoratorActions(editor: DocumentEditor, fieldID: String) -> Set<String> {
        let columns = editor.field(fieldID: fieldID)?.tableColumns ?? []
        return Set(columns.flatMap { $0.decorators ?? [] }.compactMap { $0.action })
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
