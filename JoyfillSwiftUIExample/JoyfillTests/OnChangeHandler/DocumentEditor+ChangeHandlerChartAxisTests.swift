//
//  DocumentEditor+ChangeHandlerChartAxisTests.swift
//  JoyfillTests
//
//  Regression coverage for chart-axis parsing in DocumentEditor.handleFieldUpdate.
//  JSON numerics deserialize as Int when written without a decimal point
//  (e.g. {"xMin": 5}), and an `as? Double` cast against that value returns nil.
//  These tests lock in correct coercion so axis updates from realistic JSON
//  payloads are not silently dropped.
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DocumentEditorChangeHandlerChartAxisTests: XCTestCase {

    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "68e34182e45b28674c6ad43d"
    private let chartFieldID = "68e34195ee0d17e732680fea"
    private let chartFieldPositionId = "68e341974a34abc01483c864"

    private let datePageID = "68e33b5fc6fe3e7ece654f4d"
    private let dateFieldID = "68e34146988ec973ec893816"
    private let dateFieldPositionId = "68e3414d0318c1bd80740d93"

    private func makeEditor() -> DocumentEditor {
        DocumentEditor(document: sampleJSONDocument(fileName: "OnChangeHandler"), validateSchema: false)
    }

    private func makeChange(_ payload: [String: Any], editor: DocumentEditor) -> Change {
        Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: chartFieldID,
            fieldIdentifier: editor.field(fieldID: chartFieldID)?.identifier,
            fieldPositionId: chartFieldPositionId,
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }

    private func makeDateChange(_ payload: [String: Any], editor: DocumentEditor) -> Change {
        Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: datePageID,
            fieldId: dateFieldID,
            fieldIdentifier: editor.field(fieldID: dateFieldID)?.identifier,
            fieldPositionId: dateFieldPositionId,
            change: payload,
            createdOn: Date().timeIntervalSince1970
        )
    }

    // Sanity: Double-typed JSON payload still works (no regression on the happy path).
    func testChartAxisUpdate_DoublePayload_AppliesValues() {
        let editor = makeEditor()
        editor.change(changes: [makeChange([
            "xMin": 5.0,
            "xMax": 95.0,
            "yMin": 1.0,
            "yMax": 99.0
        ], editor: editor)])

        let field = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(field?.xMin, 5.0)
        XCTAssertEqual(field?.xMax, 95.0)
        XCTAssertEqual(field?.yMin, 1.0)
        XCTAssertEqual(field?.yMax, 99.0)
    }

    // Regression: when JSON arrives with integer literals (`{"xMin": 5}`),
    // JSONSerialization bridges to Int — an `as? Double` cast silently fails.
    // Axis updates from this realistic payload shape must still apply.
    func testChartAxisUpdate_IntegerPayload_AppliesValues() {
        let editor = makeEditor()
        editor.change(changes: [makeChange([
            "xMin": 5,
            "xMax": 95,
            "yMin": 1,
            "yMax": 99
        ], editor: editor)])

        let field = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(field?.xMin, 5.0, "Int xMin must be coerced to Double, not dropped")
        XCTAssertEqual(field?.xMax, 95.0, "Int xMax must be coerced to Double, not dropped")
        XCTAssertEqual(field?.yMin, 1.0, "Int yMin must be coerced to Double, not dropped")
        XCTAssertEqual(field?.yMax, 99.0, "Int yMax must be coerced to Double, not dropped")
    }

    // Regression: JSONSerialization commonly bridges JSON numbers to NSNumber
    // (not raw Int/Double). Coercion must handle that path too.
    func testChartAxisUpdate_NSNumberIntegerPayload_AppliesValues() {
        let editor = makeEditor()
        editor.change(changes: [makeChange([
            "xMin": NSNumber(value: 5),
            "xMax": NSNumber(value: 95),
            "yMin": NSNumber(value: 1),
            "yMax": NSNumber(value: 99)
        ], editor: editor)])

        let field = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(field?.xMin, 5.0)
        XCTAssertEqual(field?.xMax, 95.0)
        XCTAssertEqual(field?.yMin, 1.0)
        XCTAssertEqual(field?.yMax, 99.0)
    }

    // Regression: a partial payload (one axis key) must NOT wipe the other
    // axis fields. The OnChangeHandler fixture seeds the chart field with all
    // six axis values populated; updating only xMax should leave the other
    // five untouched.
    func testChartAxisUpdate_PartialPayload_DoesNotWipeOtherFields() {
        let editor = makeEditor()

        let before = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(before?.xTitle, "Horizontal")
        XCTAssertEqual(before?.yTitle, "Vertical")
        XCTAssertEqual(before?.xMin, 0)
        XCTAssertEqual(before?.xMax, 100)
        XCTAssertEqual(before?.yMin, 0)
        XCTAssertEqual(before?.yMax, 100)

        editor.change(changes: [makeChange(["xMax": 50], editor: editor)])

        let after = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(after?.xMax,   50,           "xMax should be updated")
        XCTAssertEqual(after?.xTitle, "Horizontal", "xTitle absent from payload must be preserved")
        XCTAssertEqual(after?.yTitle, "Vertical",   "yTitle absent from payload must be preserved")
        XCTAssertEqual(after?.xMin,   0,            "xMin absent from payload must be preserved")
        XCTAssertEqual(after?.yMin,   0,            "yMin absent from payload must be preserved")
        XCTAssertEqual(after?.yMax,   100,          "yMax absent from payload must be preserved")
    }

    // Regression: an explicit null at one key must not wipe the other five
    // axis fields. Behavior of `null` for the targeted key depends on
    // contract (no-op vs. explicit clear); either way, untouched fields
    // must survive.
    func testChartAxisUpdate_ExplicitNullPayload_DoesNotWipeOtherFields() {
        let editor = makeEditor()

        editor.change(changes: [makeChange(["xMin": NSNull()], editor: editor)])

        let after = editor.field(fieldID: chartFieldID)
        XCTAssertEqual(after?.xTitle, "Horizontal", "xTitle absent from payload must be preserved")
        XCTAssertEqual(after?.yTitle, "Vertical",   "yTitle absent from payload must be preserved")
        XCTAssertEqual(after?.xMax,   100,          "xMax absent from payload must be preserved")
        XCTAssertEqual(after?.yMin,   0,            "yMin absent from payload must be preserved")
        XCTAssertEqual(after?.yMax,   100,          "yMax absent from payload must be preserved")
    }

    // MARK: - Date field clear via change API
    //
    // An incoming `{"value": null}` becomes ValueUnion.null on the field, NOT nil.
    // DateTimeView observes `dateTimeDataModel.value` and resets its dateString
    // only when the new value is null-or-empty — if the field were left holding
    // a previous double, the cleared state would never reach the UI (especially
    // on mirrored views, where the clear only arrives via the change API).

    // Sanity: a numeric payload populates the date field.
    func testDateFieldUpdate_NumericPayload_SetsFieldValue() {
        let editor = makeEditor()
        let timestampMs: Int64 = 1_700_000_000_000

        editor.change(changes: [makeDateChange(["value": NSNumber(value: timestampMs)], editor: editor)])

        let field = editor.field(fieldID: dateFieldID)
        XCTAssertNotNil(field?.value, "date field value should be populated after numeric change")
        XCTAssertFalse(field?.value?.nullOrEmpty ?? true, "populated date value must not report null-or-empty")
    }

    // Regression: clearing a previously-set date via `{"value": null}` must leave
    // the field in a null-or-empty state. This pins the data-layer contract the
    // DateTimeView guard depends on (check `nullOrEmpty`, not just `if let`).
    func testDateFieldClearViaChangeAPI_NullPayload_ClearsFieldValue() {
        let editor = makeEditor()
        let timestampMs: Int64 = 1_700_000_000_000

        editor.change(changes: [makeDateChange(["value": NSNumber(value: timestampMs)], editor: editor)])
        XCTAssertFalse(editor.field(fieldID: dateFieldID)?.value?.nullOrEmpty ?? true,
                       "precondition: date field must hold a value before the clear")

        editor.change(changes: [makeDateChange(["value": NSNull()], editor: editor)])

        let cleared = editor.field(fieldID: dateFieldID)?.value
        XCTAssertTrue(cleared == nil || cleared!.nullOrEmpty,
                      "date field value must be null-or-empty after change-API null update")
    }
}
