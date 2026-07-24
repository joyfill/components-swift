import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Tests for per-cell visibility logic on table fields.
///
/// A column can carry `cellVisibilityLogic` whose conditions reference *sibling column ids*
/// and resolve against the same row's cell values. Visibility is built once at load into
/// Map 1 (`cellVisibilityMap`), read through `shouldShowCell`, and refreshed on edit via the
/// column->column dependency graph (Map 2) exposed by `cellsNeedToBeRefreshed`.
final class CellVisibilityLogicTest: XCTestCase {
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"

    let tableFieldID = "cell_vis_table_001"

    // Column IDs
    let statusColumnID = "col_status"   // condition source (sibling)
    let reasonColumnID = "col_reason"   // dependent cell (carries cellVisibilityLogic)
    let noteColumnID = "col_note"       // independent, no logic

    let row1ID = "row_001"
    let row2ID = "row_002"

    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    // MARK: - Builders

    /// A logic dictionary (same shape as field/column logic) for cell visibility.
    func cellVisibilityLogicDictionary(isShow: Bool, conditions: [LogicConditionTest], eval: EvaluationType = .and) -> [String: Any] {
        let conditionsArray: [[String: Any]] = conditions.map { test in
            [
                "file": fileID,
                "page": pageID,
                "column": test.fieldID as Any,
                "condition": test.conditionType.rawValue,
                "value": test.value,
                "_id": UUID().uuidString
            ]
        }
        return [
            "action": isShow ? "show" : "hide",
            "eval": eval.rawValue,
            "conditions": conditionsArray,
            "_id": UUID().uuidString
        ]
    }

    func buildColumn(id: String, type: ColumnTypes, title: String, cellVisibilityLogic: [String: Any]? = nil) -> FieldTableColumn {
        var dict: [String: Any] = [
            "_id": id,
            "type": type.rawValue,
            "title": title,
            "width": 0,
            "identifier": "field_column_\(id)"
        ]
        if let cellVisibilityLogic = cellVisibilityLogic {
            dict["cellVisibilityLogic"] = cellVisibilityLogic
        }
        return FieldTableColumn(dictionary: dict)
    }

    func row(id: String, cells: [String: Any]) -> ValueElement {
        ValueElement(dictionary: ["_id": id, "cells": cells])
    }

    /// Builds a document with a single table field carrying the given columns and rows.
    func buildDocument(columns: [FieldTableColumn], rows: [ValueElement]) -> JoyDoc {
        var field = JoyDocField()
        field.type = "table"
        field.id = tableFieldID
        field.identifier = "field_\(tableFieldID)"
        field.title = "Cell Visibility Table"
        field.file = fileID
        field.tableColumns = columns
        field.tableColumnOrder = columns.compactMap { $0.id }
        field.rowOrder = rows.compactMap { $0.id }
        field.value = .valueElementArray(rows)

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(field)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [tableFieldID: .table])
        return document
    }

    /// Convenience: table where `reason` shows/hides based on `status` equals "Rejected".
    func buildStatusReasonDocument(isShow: Bool, row1Status: String, row2Status: String) -> JoyDoc {
        let logic = cellVisibilityLogicDictionary(
            isShow: isShow,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic),
            buildColumn(id: noteColumnID, type: .text, title: "Note")
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: row1Status]),
            row(id: row2ID, cells: [statusColumnID: row2Status])
        ]
        return buildDocument(columns: columns, rows: rows)
    }

    func rowElement(_ editor: DocumentEditor, rowID: String) -> ValueElement {
        editor.field(fieldID: tableFieldID)!.valueToValueElements!.first(where: { $0.id == rowID })!
    }

    // MARK: - Static show/hide (built at load, read via shouldShowCell)

    /// action=show, condition met -> cell visible
    func testShowWhenConditionMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID))
        XCTAssertTrue(result, "Reason cell should show when status == Rejected (show action, condition met)")
    }

    /// action=show, condition not met -> cell hidden
    func testHiddenWhenShowConditionNotMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID))
        XCTAssertFalse(result, "Reason cell should hide when status != Rejected (show action, condition not met)")
    }

    /// action=hide, condition met -> cell hidden
    func testHideWhenConditionMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: false, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID))
        XCTAssertFalse(result, "Reason cell should hide when status == Rejected (hide action, condition met)")
    }

    /// action=hide, condition not met -> cell visible
    func testShownWhenHideConditionNotMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: false, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID))
        XCTAssertTrue(result, "Reason cell should stay visible when status != Rejected (hide action, condition not met)")
    }

    /// A column with no cellVisibilityLogic is always visible
    func testColumnWithoutLogicAlwaysVisible() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)))
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)))
    }

    /// Unknown column / field / row default to visible
    func testUnknownLookupsDefaultToVisible() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let row1 = rowElement(editor, rowID: row1ID)
        XCTAssertTrue(editor.shouldShowCell(columnID: "unknown_col", fieldID: tableFieldID, row: row1), "Unknown column defaults to visible")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: "unknown_field", row: row1), "Unknown field defaults to visible")
        let unknownRow = row(id: "unknown_row", cells: [statusColumnID: "Rejected"])
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: unknownRow), "Unknown row defaults to visible")
    }

    // MARK: - Multiple conditions (AND / OR)

    /// AND: visible only when both sibling conditions are met
    func testShowOnAndConditions() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected")),
                LogicConditionTest(fieldID: noteColumnID, conditionType: .contains, value: .string("urgent"))
            ],
            eval: .and
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: noteColumnID, type: .text, title: "Note"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Rejected", noteColumnID: "this is urgent"]),  // both met
            row(id: row2ID, cells: [statusColumnID: "Rejected", noteColumnID: "later"])             // one fails
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "Visible when both AND conditions met")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "Hidden when one AND condition fails")
    }

    /// OR: visible when either sibling condition is met
    func testShowOnOrConditions() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected")),
                LogicConditionTest(fieldID: noteColumnID, conditionType: .contains, value: .string("urgent"))
            ],
            eval: .or
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: noteColumnID, type: .text, title: "Note"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Approved", noteColumnID: "this is urgent"]), // second met
            row(id: row2ID, cells: [statusColumnID: "Approved", noteColumnID: "later"])           // neither met
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "Visible when one OR condition met")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "Hidden when no OR condition met")
    }

    // MARK: - Dependency-driven refresh (Map 2)

    /// Editing the sibling column that a dependent depends on returns the dependent when visibility flips
    func testRefreshReturnsDependentColumnOnFlip() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        // row2 currently Approved -> reason hidden. Edit status to Rejected -> reason should flip to visible.
        let editedRow = row(id: row2ID, cells: [statusColumnID: "Rejected"])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertEqual(flipped, [reasonColumnID], "Editing status should flip the dependent reason cell")
    }

    /// Editing the sibling but with no change in visibility returns empty
    func testRefreshReturnsEmptyWhenNoFlip() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        // row1 already Rejected -> reason visible. Edit status to another non-matching->matching? Keep Rejected: no flip.
        let editedRow = row(id: row1ID, cells: [statusColumnID: "Rejected"])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(flipped.isEmpty, "No flip should yield an empty refresh list")
    }

    /// Editing a column that nothing depends on returns empty
    func testRefreshReturnsEmptyForIndependentColumn() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let editedRow = row(id: row1ID, cells: [statusColumnID: "Rejected", noteColumnID: "changed"])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: noteColumnID, row: editedRow)
        XCTAssertTrue(flipped.isEmpty, "Editing an independent column should refresh nothing")
    }

    /// After a refresh, shouldShowCell reflects the new value (Map 1 was updated)
    func testShouldShowCellReflectsRefreshedValue() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let editedRow = row(id: row2ID, cells: [statusColumnID: "Rejected"])

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "Reason hidden before edit")
        _ = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: editedRow), "Reason visible after refreshing with status=Rejected")
    }

    // MARK: - Map 1 maintenance (insert / delete)

    /// addCellVisibilityForRow seeds Map 1 so a newly inserted row reads correctly
    func testAddCellVisibilityForNewRow() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let newRow = row(id: "row_new", cells: [statusColumnID: "Rejected"])
        editor.addCellVisibilityForRow(fieldID: tableFieldID, row: newRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: newRow), "New row's reason should be visible (status=Rejected)")
    }

    /// removeCellVisibilityForRow drops the row's entries; reads fall back to visible default
    func testRemoveCellVisibilityForRow() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let row2 = rowElement(editor, rowID: row2ID)
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: row2), "Reason hidden before removal")
        editor.removeCellVisibilityForRow(fieldID: tableFieldID, rowID: row2ID)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: row2), "After removal the entry is gone, defaulting to visible")
    }
}
