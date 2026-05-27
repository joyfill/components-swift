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
}
