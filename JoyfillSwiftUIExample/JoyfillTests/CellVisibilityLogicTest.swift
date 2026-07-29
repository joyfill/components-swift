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

    func buildColumn(id: String, type: ColumnTypes, title: String, cellVisibilityLogic: [String: Any]? = nil, cellsHidden: Bool? = nil) -> FieldTableColumn {
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
        if let cellsHidden = cellsHidden {
            dict["cellsHidden"] = cellsHidden
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

    // MARK: - cellsHidden baseline (mirrors a field's static `hidden` flag)

    /// cellsHidden with no logic behaves like a field's static `hidden`: true -> hidden, false/absent -> visible
    func testCellsHiddenBaselineWithoutLogic() {
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: "col_hidden", type: .text, title: "Hidden", cellsHidden: true),
            buildColumn(id: "col_shown", type: .text, title: "Shown", cellsHidden: false),
            buildColumn(id: noteColumnID, type: .text, title: "Note")
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Rejected"])]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        let r = rowElement(editor, rowID: row1ID)
        XCTAssertFalse(editor.shouldShowCell(columnID: "col_hidden", fieldID: tableFieldID, row: r), "cellsHidden:true with no logic -> hidden")
        XCTAssertTrue(editor.shouldShowCell(columnID: "col_shown", fieldID: tableFieldID, row: r), "cellsHidden:false with no logic -> visible")
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, row: r), "no cellsHidden, no logic -> visible")
    }

    /// A `hide`-action column shows non-matching rows and hides matching rows; `cellsHidden` on a
    /// logic column is ignored (the action drives each row).
    func testHideActionShowsNonMatchingRowsIgnoringCellsHidden() {
        let logic = cellVisibilityLogicDictionary(
            isShow: false,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic, cellsHidden: true)
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Rejected"]),  // met -> hide
            row(id: row2ID, cells: [statusColumnID: "Approved"])   // not met -> show
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "hide + condition met -> hidden")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hide + condition not met -> visible (cellsHidden:true ignored on a logic column)")
    }

    /// A `show`-action column hides non-matching rows; `cellsHidden` on a logic column is ignored.
    func testShowActionHidesNonMatchingRowsIgnoringCellsHidden() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic, cellsHidden: false)
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Approved"])] // condition not met
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "show + condition not met -> hidden")
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

    // MARK: - View-layer add-row (repro: adding a row must not flip existing rows)

    private func tableViewModel(_ editor: DocumentEditor) -> TableViewModel {
        let field = editor.field(fieldID: tableFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible, visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(fieldHeaderModel: fieldHeaderModel, mode: .fill, documentEditor: editor, fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))!
        return TableViewModel(tableDataModel: tableDataModel)
    }

    /// Reads what the view actually renders: `filteredcellModels`, the source of truth for each cell's `isHidden`.
    private func reasonHidden(_ vm: TableViewModel, rowID: String) -> Bool? {
        vm.tableDataModel.filteredcellModels.first(where: { $0.rowID == rowID })?.cells.first(where: { $0.data.id == reasonColumnID })?.isHidden
    }

    /// Mirrors TableModalTopNavigationView's single-row hidden-cell gate.
    private func tableEditFormWouldHideCell(_ vm: TableViewModel, columnID: String) -> Bool {
        let singleRowID: String? = vm.tableDataModel.selectedRows.count == 1 ? vm.tableDataModel.selectedRows.first : nil
        return singleRowID.map { vm.isCellHidden(columnID: columnID, row: vm.rowElement(forRowID: $0)) } ?? false
    }

    // MARK: - Table edit-form gating (mirrors Collection's single-row/bulk-edit gate)

    /// Row-edit modal: single-row edit skips a table cell hidden by cellVisibilityLogic.
    func testTableSingleRowEditFormHidesHiddenCell() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        XCTAssertTrue(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowElement(forRowID: row1ID)), "reason cell is hidden for status=Approved")
        XCTAssertTrue(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should skip hidden reason cell")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: noteColumnID), "single-row edit form should keep independent visible cells")
    }

    /// Row-edit modal: single-row edit keeps a table cell visible when its logic matches.
    func testTableSingleRowEditFormShowsVisibleCell() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        XCTAssertFalse(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowElement(forRowID: row1ID)), "reason cell is visible for status=Rejected")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render visible reason cell")
    }

    /// Bulk edit: multiple selected rows do not use the single-row hidden-cell gate.
    func testTableBulkEditFormDoesNotHideColumnsForMultipleRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Rejected"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID, row2ID]

        XCTAssertTrue(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowElement(forRowID: row1ID)), "one selected row has reason hidden")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "bulk edit should still render the column because no single row owns the hidden-state decision")
    }

    /// Row-edit modal: after a sibling edit flips cell visibility, the single-row form gate follows it.
    func testTableSingleRowEditFormFollowsVisibilityFlip() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        XCTAssertTrue(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "reason starts hidden in the single-row edit form")

        var editedStatus = vm.tableDataModel.filteredcellModels
            .first(where: { $0.rowID == row1ID })!
            .cells
            .first(where: { $0.data.id == statusColumnID })!
            .data
        editedStatus.title = "Rejected"
        vm.tableDataModel.valueToValueElements = vm.cellDidChange(rowId: row1ID, colIndex: 0, cellDataModel: editedStatus, isNestedCell: false, callOnChange: false)
        vm.applyCellVisibilityRefresh(rowId: row1ID, editedColumnID: statusColumnID)

        XCTAssertFalse(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowElement(forRowID: row1ID)), "reason flips visible after status=Rejected")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render the cell after the flip")
    }

    // MARK: - Duplicate row (shares addRow's rebuild-from-scratch path)

    /// Duplicating a row must only compute the duplicated row's cells; pre-existing rows keep their visibility.
    func testDuplicateRowDoesNotFlipExistingRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Rejected"))
        let vm = tableViewModel(editor)

        XCTAssertEqual(reasonHidden(vm, rowID: row1ID), false, "row1 reason visible before duplicate")
        XCTAssertEqual(reasonHidden(vm, rowID: row2ID), false, "row2 reason visible before duplicate")

        vm.tableDataModel.selectedRows = [row2ID]
        vm.duplicateRow()

        XCTAssertEqual(reasonHidden(vm, rowID: row1ID), false, "row1 reason must stay visible after duplicate")
        XCTAssertEqual(reasonHidden(vm, rowID: row2ID), false, "row2 reason must stay visible after duplicate")
    }

    // MARK: - Multiple dependents on one source column

    /// Two columns whose cellVisibilityLogic both key off the same sibling column both get
    /// reported as flipped when that sibling changes (Set-based fan-out in the dependency map).
    func testRefreshReturnsMultipleDependentColumnsOnFlip() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let secondReasonColumnID = "col_reason2"
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic),
            buildColumn(id: secondReasonColumnID, type: .text, title: "Reason 2", cellVisibilityLogic: logic)
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Approved"])]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))

        let editedRow = row(id: row1ID, cells: [statusColumnID: "Rejected"])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertEqual(Set(flipped), Set([reasonColumnID, secondReasonColumnID]), "both dependents sharing the same source column are reported as flipped")
    }

    // MARK: - Chained dependency (documents current single-hop behavior; no automatic cascade)

    /// `middle`'s cellVisibilityLogic depends on `status`; `chainedDependent`'s cellVisibilityLogic
    /// depends on `middle`. Editing `status` only reports `middle` as flipped -- there is no
    /// automatic re-evaluation of columns that depend on `middle` as a side effect of its own
    /// visibility changing. `chainedDependent`'s visibility is driven purely by `middle`'s stored
    /// cell value, which is untouched by this edit.
    func testChainedDependencyDoesNotCascadeAutomatically() {
        let middleColumnID = "col_middle"
        let chainedDependentColumnID = "col_chained_dependent"
        let middleLogic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let chainedLogic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: middleColumnID, conditionType: .equals, value: .string("Ready"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: middleColumnID, type: .text, title: "Middle", cellVisibilityLogic: middleLogic),
            buildColumn(id: chainedDependentColumnID, type: .text, title: "Chained", cellVisibilityLogic: chainedLogic)
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Approved", middleColumnID: "Ready"])]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))

        XCTAssertFalse(editor.shouldShowCell(columnID: middleColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "middle hidden before edit (status != Rejected)")
        XCTAssertTrue(editor.shouldShowCell(columnID: chainedDependentColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "chained dependent already visible because middle's stored value is Ready, independent of middle's own visibility")

        let editedRow = row(id: row1ID, cells: [statusColumnID: "Rejected", middleColumnID: "Ready"])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertEqual(flipped, [middleColumnID], "only the direct dependent (middle) is reported; chainedDependent is not re-evaluated as a side effect")
        XCTAssertTrue(editor.shouldShowCell(columnID: middleColumnID, fieldID: tableFieldID, row: editedRow), "middle now visible (status=Rejected)")
    }

    // MARK: - Additional condition operators

    /// `!=`: visible when the sibling value differs from the condition value.
    func testHideOnNotEqualsCondition() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .notEquals, value: .string("Approved"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Rejected"]),
            row(id: row2ID, cells: [statusColumnID: "Approved"])
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "visible when status != Approved")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hidden when status == Approved")
    }

    /// `>`: visible when the sibling numeric value exceeds the condition value.
    func testShowOnGreaterThanCondition() {
        let scoreColumnID = "col_score"
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: scoreColumnID, conditionType: .greaterThan, value: .double(50))]
        )
        let columns = [
            buildColumn(id: scoreColumnID, type: .number, title: "Score"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [scoreColumnID: 75]),
            row(id: row2ID, cells: [scoreColumnID: 20])
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "visible when score > 50")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hidden when score <= 50")
    }

    /// `<`: visible when the sibling numeric value is below the condition value.
    func testShowOnLessThanCondition() {
        let scoreColumnID = "col_score"
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: scoreColumnID, conditionType: .lessThan, value: .double(50))]
        )
        let columns = [
            buildColumn(id: scoreColumnID, type: .number, title: "Score"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [scoreColumnID: 20]),
            row(id: row2ID, cells: [scoreColumnID: 75])
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "visible when score < 50")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hidden when score >= 50")
    }

    /// `null=`: visible when the sibling value is empty/missing.
    func testShowOnIsEmptyCondition() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .isNull, value: .string(""))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [:]),
            row(id: row2ID, cells: [statusColumnID: "Approved"])
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "visible when status is empty")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hidden when status is not empty")
    }

    /// `*=`: visible when the sibling value is non-empty.
    func testShowOnIsNotEmptyCondition() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .isNotNull, value: .string(""))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Approved"]),
            row(id: row2ID, cells: [:])
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row1ID)), "visible when status is not empty")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: rowElement(editor, rowID: row2ID)), "hidden when status is empty")
    }

    // MARK: - View-layer add-row (repro: adding a row must not flip existing rows)
    func testAddRowDoesNotFlipExistingRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Rejected"))
        let vm = tableViewModel(editor)

        XCTAssertEqual(reasonHidden(vm, rowID: row1ID), false, "row1 reason visible before add")
        XCTAssertEqual(reasonHidden(vm, rowID: row2ID), false, "row2 reason visible before add")

        // Matches the "Add Row +" button exactly: no explicit values, event sent, no full rebuild.
        vm.addRow()

        XCTAssertEqual(reasonHidden(vm, rowID: row1ID), false, "row1 reason must stay visible after add")
        XCTAssertEqual(reasonHidden(vm, rowID: row2ID), false, "row2 reason must stay visible after add")
    }

    // MARK: - Real-doc repro (table1: cellsHidden:true + show `*=` on sibling dropdown)

    /// Mirrors the user's `table1`: Text Column carries `cellsHidden:true` AND a `show` logic
    /// whose only usable condition is "sibling dropdown1 is not empty" (`*=`, no value). A second
    /// condition references `field` instead of `column` and must be ignored.
    private func buildTable1Document(row1Dropdown: String?, row2Dropdown: String?, row3Dropdown: String?) -> JoyDoc {
        let text1Logic: [String: Any] = [
            "action": "show",
            "eval": "and",
            "conditions": [
                ["column": "dropdown1", "condition": "*="],
                ["file": fileID, "page": pageID, "field": "dropdown1", "condition": "*="]
            ],
            "_id": UUID().uuidString
        ]
        let columns = [
            buildColumn(id: "text1", type: .text, title: "Text Column", cellVisibilityLogic: text1Logic, cellsHidden: true),
            buildColumn(id: "dropdown1", type: .dropdown, title: "Dropdown Column"),
            buildColumn(id: "text2", type: .text, title: "Text Column")
        ]
        func cells(_ dropdown: String?) -> [String: Any] {
            guard let dropdown else { return [:] }
            return ["dropdown1": dropdown]
        }
        let rows = [
            row(id: row1ID, cells: cells(row1Dropdown)),
            row(id: row2ID, cells: cells(row2Dropdown)),
            row(id: "row_003", cells: cells(row3Dropdown))
        ]
        return buildDocument(columns: columns, rows: rows)
    }

    /// Simulates the user selecting a dropdown option in a row (updates the model the way an edit would).
    private func setDropdown(_ vm: TableViewModel, rowID: String, value: String) {
        guard var elements = vm.tableDataModel.valueToValueElements,
              let idx = elements.firstIndex(where: { $0.id == rowID }) else {
            XCTFail("row \(rowID) not found")
            return
        }
        var cells = elements[idx].cells ?? [:]
        cells["dropdown1"] = ValueUnion.string(value)
        elements[idx].cells = cells
        vm.tableDataModel.valueToValueElements = elements
    }

    private func text1Hidden(_ vm: TableViewModel, rowID: String) -> Bool? {
        vm.tableDataModel.filteredcellModels.first(where: { $0.rowID == rowID })?.cells.first(where: { $0.data.id == "text1" })?.isHidden
    }

    func testTable1AddRowDoesNotFlipExistingRows() {
        // rows 1 & 2 have a dropdown value (non-empty -> text1 visible); row 3 empty (hidden).
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: "6a634222bcd54de3258770c7", row2Dropdown: "6a634222bcd54de3258770c7", row3Dropdown: nil))
        let vm = tableViewModel(editor)

        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 visible before add (dropdown non-empty)")
        XCTAssertEqual(text1Hidden(vm, rowID: row2ID), false, "row2 text1 visible before add (dropdown non-empty)")
        XCTAssertEqual(text1Hidden(vm, rowID: "row_003"), true, "row3 text1 hidden before add (dropdown empty)")

        vm.addRow()

        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 MUST stay visible after add")
        XCTAssertEqual(text1Hidden(vm, rowID: row2ID), false, "row2 text1 MUST stay visible after add")
        XCTAssertEqual(text1Hidden(vm, rowID: "row_003"), true, "row3 text1 stays hidden after add")
    }

    func testTable1DeleteRowDoesNotFlipRemainingRows() {
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: "6a634222bcd54de3258770c7", row2Dropdown: "6a634222bcd54de3258770c7", row3Dropdown: nil))
        let vm = tableViewModel(editor)

        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 visible before delete")
        XCTAssertEqual(text1Hidden(vm, rowID: row2ID), false, "row2 text1 visible before delete")

        // Delete the hidden (empty-dropdown) row, mirroring the row-select + delete UI action.
        vm.deleteSelectedRow(["row_003"])

        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 MUST stay visible after delete")
        XCTAssertEqual(text1Hidden(vm, rowID: row2ID), false, "row2 text1 MUST stay visible after delete")
    }

    /// The reported bug: a cell revealed by an in-modal edit reverts to hidden the moment a row is
    /// added, because `applyCellVisibilityRefresh` wrote the new state only into `filteredcellModels`
    /// and `filterRowsIfNeeded()` (run on add) resets `filteredcellModels = cellModels`.
    func testEditRevealSurvivesAddRow() {
        // Every row loads with an empty dropdown -> text1 hidden.
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: nil, row2Dropdown: nil, row3Dropdown: nil))
        let vm = tableViewModel(editor)
        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), true, "row1 text1 hidden at load (empty dropdown)")

        // User picks a dropdown value in row1 -> text1 is revealed via the dependency refresh.
        setDropdown(vm, rowID: row1ID, value: "6a634222bcd54de3258770c7")
        vm.applyCellVisibilityRefresh(rowId: row1ID, editedColumnID: "dropdown1")
        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 revealed after picking dropdown")

        // Adding a row must NOT wipe the revealed state.
        vm.addRow()
        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 MUST stay visible after add")
    }

    /// Same bug via delete instead of add.
    func testEditRevealSurvivesDeleteRow() {
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: nil, row2Dropdown: nil, row3Dropdown: nil))
        let vm = tableViewModel(editor)

        setDropdown(vm, rowID: row1ID, value: "6a634222bcd54de3258770c7")
        vm.applyCellVisibilityRefresh(rowId: row1ID, editedColumnID: "dropdown1")
        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 revealed after picking dropdown")

        vm.deleteSelectedRow(["row_003"])
        XCTAssertEqual(text1Hidden(vm, rowID: row1ID), false, "row1 text1 MUST stay visible after delete")
    }

    // MARK: - Validation gating (hidden-but-required cells must not block submission)

    /// A cell hidden by `cellVisibilityLogic` but required (the required-logic fallback chain
    /// resolves a plain static `required: true` with no cellRequiredLogic/requiredLogic present)
    /// must NOT be reported `.invalid` when empty by `validate()` — the user has no way to fill a
    /// cell they can't see. Exercises the `shouldShowCell` gate added to ValidationHandler's table path.
    func testValidateTreatsHiddenRequiredTableCellAsValid() {
        let logic = cellVisibilityLogicDictionary(
            isShow: false,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        var reasonDict = buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic).dictionary
        reasonDict["required"] = true
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            FieldTableColumn(dictionary: reasonDict),
            buildColumn(id: noteColumnID, type: .text, title: "Note")
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Rejected"])] // reason left empty
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))
        let editedRow = rowElement(editor, rowID: row1ID)

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, row: editedRow), "reason hidden when status == Rejected")
        XCTAssertTrue(editor.isCellRequired(columnID: reasonColumnID, fieldID: tableFieldID, row: editedRow), "reason is still required")

        let status = editor.validate().fieldValidities
            .first(where: { $0.fieldId == tableFieldID })?
            .rowValidities?.first(where: { $0.rowId == row1ID })?
            .cellValidities.first(where: { $0.columnId == reasonColumnID })?.status
        XCTAssertEqual(status, .valid, "Required-but-hidden empty cell must validate as valid; the user can't fill what they can't see")
    }

    // MARK: - Collection cell visibility (schema-aware; mirrors the table paths)

    let collectionFieldID = "cell_vis_collection_001"
    let collRootSchema = "coll_root_schema"
    let collChildSchema = "coll_child_schema"
    let pageTextFieldID = "66aa2865da10ac1c7b7acb1d" // matches setTextField's fixed id

    let collRootRow1 = "coll_root_row_001"
    let collRootRow2 = "coll_root_row_002"
    let collChildRow1 = "coll_child_row_001"

    /// A page-field-driven cell logic dict: condition references a page field's `_id` via `field`.
    private func pageFieldCellLogic(isShow: Bool, pageFieldID: String, value: ValueUnion) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": "and",
            "conditions": [
                ["file": fileID, "page": pageID, "field": pageFieldID, "condition": "=", "value": value, "_id": UUID().uuidString]
            ],
            "_id": UUID().uuidString
        ]
    }

    /// Builds a two-level collection: root schema (Status/Reason/Note) with a child schema (Status/Reason).
    /// `reason` in each schema carries `cellVisibilityLogic`. `pageValue` seeds the page text field.
    private func buildCollectionDocument(rootReasonLogic: [String: Any],
                                         childReasonLogic: [String: Any]? = nil,
                                         rootRows: [[String: Any]],
                                         pageValue: String = "Approved") -> JoyDoc {
        let rootColumns: [[String: Any]] = [
            buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: rootReasonLogic).dictionary,
            buildColumn(id: noteColumnID, type: .text, title: "Note").dictionary
        ]
        let childColumns: [[String: Any]] = [
            buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: childReasonLogic ?? rootReasonLogic).dictionary
        ]
        let rootSchemaDict: [String: Any] = [
            "title": "Root",
            "root": true,
            "children": [collChildSchema],
            "tableColumns": rootColumns
        ]
        let childSchemaDict: [String: Any] = [
            "title": "Child",
            "root": false,
            "children": [String](),
            "tableColumns": childColumns
        ]

        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.title = "Cell Visibility Collection"
        field.file = fileID
        field.dictionary["schema"] = [collRootSchema: rootSchemaDict, collChildSchema: childSchemaDict]
        field.value = .valueElementArray(rootRows.map { ValueElement(dictionary: $0) })

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(pageValue))
        document.fields.append(field)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [pageTextFieldID: .text, collectionFieldID: .collection])
        return document
    }

    private func collRootRow(id: String, status: String, children: [[String: Any]] = []) -> [String: Any] {
        var dict: [String: Any] = ["_id": id, "cells": [statusColumnID: status]]
        if !children.isEmpty {
            dict["children"] = [collChildSchema: ["value": children]]
        }
        return dict
    }

    private func collChildRow(id: String, status: String) -> [String: Any] {
        ["_id": id, "cells": [statusColumnID: status]]
    }

    private func collRowElement(_ editor: DocumentEditor, rowID: String) -> ValueElement {
        func find(_ elements: [ValueElement]) -> ValueElement? {
            for element in elements {
                if element.id == rowID { return element }
                for (_, child) in element.childrens ?? [:] {
                    if let hit = find(child.valueToValueElements ?? []) { return hit }
                }
            }
            return nil
        }
        return find(editor.field(fieldID: collectionFieldID)!.valueToValueElements ?? [])!
    }

    private func collectionViewModel(_ editor: DocumentEditor) -> CollectionViewModel {
        let field = editor.field(fieldID: collectionFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title,
                                                required: field?.required,
                                                tipDescription: field?.tipDescription,
                                                tipTitle: field?.tipTitle,
                                                tipVisible: field?.tipVisible,
                                                visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                            mode: .fill,
                                            documentEditor: editor,
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID))!
        return CollectionViewModel(tableDataModel: tableDataModel)
    }

    private func waitForCollectionViewModelToLoad(_ vm: CollectionViewModel,
                                                  file: StaticString = #filePath,
                                                  line: UInt = #line) {
        let deadline = Date().addingTimeInterval(2)
        while vm.isLoading && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        XCTAssertFalse(vm.isLoading, "CollectionViewModel did not finish loading", file: file, line: line)
    }

    /// Mirrors CollectionEditMultipleRowsSheetView's single-row hidden-cell gate.
    private func editFormWouldHideCell(_ vm: CollectionViewModel, columnID: String) -> Bool {
        let singleRowID: String? = vm.tableDataModel.selectedRows.count == 1 ? vm.tableDataModel.selectedRows.first : nil
        return singleRowID.map { vm.isCellHidden(columnID: columnID, row: vm.rowToValueElementMap[$0]) } ?? false
    }

    /// Load: sibling condition met on a root row -> reason visible; not met -> hidden.
    func testCollectionLoadShowWhenSiblingMatches() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Rejected"),
                       collRootRow(id: collRootRow2, status: "Approved")]
        ))
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow1)), "row1 reason visible (status=Rejected)")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow2)), "row2 reason hidden (status=Approved)")
    }

    /// Load: nested child rows get their own cell visibility computed from their own cells.
    func testCollectionLoadComputesNestedRows() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved",
                                   children: [collChildRow(id: collChildRow1, status: "Rejected")])]
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow1)), "root reason hidden (status=Approved)")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collChildRow1)), "nested child reason visible (status=Rejected)")
    }

    /// Sibling edit: recomputing with a new sibling value flips the dependent cell (schema-aware refresh).
    func testCollectionSiblingEditFlipsCell() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")]
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow1)), "reason hidden before edit")

        let editedRow = ValueElement(dictionary: ["_id": collRootRow1, "cells": [statusColumnID: "Rejected"]])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: collectionFieldID, schemaID: collRootSchema, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertEqual(flipped, [reasonColumnID], "reason column reported as flipped")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: editedRow), "reason visible after status=Rejected")
    }

    /// Add-row: schema-aware seeding makes a newly inserted row read correctly.
    func testCollectionAddCellVisibilityForNewRow() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")]
        ))
        let newRow = ValueElement(dictionary: ["_id": "coll_root_new", "cells": [statusColumnID: "Rejected"]])
        editor.addCellVisibilityForRow(fieldID: collectionFieldID, schemaID: collRootSchema, row: newRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: newRow), "new row reason visible (status=Rejected)")
    }

    /// Delete-row: removal drops the row's entries; subsequent reads fall back to the visible default.
    func testCollectionRemoveCellVisibilityForRow() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow2, status: "Approved")]
        ))
        let row2 = collRowElement(editor, rowID: collRootRow2)
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: row2), "reason hidden before removal")
        editor.removeCellVisibilityForRow(fieldID: collectionFieldID, rowID: collRootRow2)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: row2), "entry gone after removal -> defaults visible")
    }

    /// Page-field change: editing the referenced page field flips all dependent collection cells.
    func testCollectionPageFieldChangeFlipsCell() {
        let logic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")],
            pageValue: "No"
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow1)), "reason hidden while page field != Yes")

        let identifier = FieldIdentifier(fieldID: pageTextFieldID, pageID: pageID, fileID: fileID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: identifier, updateValue: .string("Yes")), fieldIdentifier: identifier)

        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collRootRow1)), "reason visible after page field -> Yes")
    }

    /// Page-field change: the page-field dependency is schema-aware -- a CHILD schema's cell
    /// (not just the root schema) flips when the referenced page field changes.
    func testCollectionChildSchemaPageFieldChangeFlipsCell() {
        let rootLogic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let childLogic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: rootLogic,
            childReasonLogic: childLogic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved",
                                   children: [collChildRow(id: collChildRow1, status: "Approved")])],
            pageValue: "No"
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collChildRow1)), "child reason hidden while page field != Yes")

        let identifier = FieldIdentifier(fieldID: pageTextFieldID, pageID: pageID, fileID: fileID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: identifier, updateValue: .string("Yes")), fieldIdentifier: identifier)

        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collChildRow1)), "child reason visible after page field -> Yes")
    }

    /// Sibling edit: recomputing with a new sibling value flips a CHILD schema's dependent cell
    /// (not just root), using the schema-scoped `cellsNeedToBeRefreshed(schemaID:)` overload.
    func testCollectionChildSchemaSiblingEditFlipsCell() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved",
                                   children: [collChildRow(id: collChildRow1, status: "Approved")])]
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: collRowElement(editor, rowID: collChildRow1)), "child reason hidden before edit")

        let editedRow = ValueElement(dictionary: ["_id": collChildRow1, "cells": [statusColumnID: "Rejected"]])
        let flipped = editor.cellsNeedToBeRefreshed(fieldID: collectionFieldID, schemaID: collChildSchema, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertEqual(flipped, [reasonColumnID], "child reason column reported as flipped")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: editedRow), "child reason visible after status=Rejected")
    }

    /// Row-edit modal: single-row edit skips a collection cell hidden by cellVisibilityLogic.
    func testCollectionSingleRowEditFormHidesHiddenCell() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")]
        ))
        let vm = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(vm)

        vm.tableDataModel.selectedRows = [collRootRow1]

        XCTAssertTrue(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowToValueElementMap[collRootRow1]), "reason cell is hidden for status=Approved")
        XCTAssertTrue(editFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should skip hidden reason cell")
        XCTAssertFalse(editFormWouldHideCell(vm, columnID: noteColumnID), "single-row edit form should keep independent visible cells")
    }

    /// Row-edit modal: single-row edit keeps a collection cell visible when its logic matches.
    func testCollectionSingleRowEditFormShowsVisibleCell() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Rejected")]
        ))
        let vm = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(vm)

        vm.tableDataModel.selectedRows = [collRootRow1]

        XCTAssertFalse(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowToValueElementMap[collRootRow1]), "reason cell is visible for status=Rejected")
        XCTAssertFalse(editFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render visible reason cell")
    }

    /// Bulk edit: multiple selected rows do not use the single-row hidden-cell gate.
    func testCollectionBulkEditFormDoesNotHideColumnsForMultipleRows() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved"),
                       collRootRow(id: collRootRow2, status: "Rejected")]
        ))
        let vm = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(vm)

        vm.tableDataModel.selectedRows = [collRootRow1, collRootRow2]

        XCTAssertTrue(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowToValueElementMap[collRootRow1]), "one selected row has reason hidden")
        XCTAssertFalse(editFormWouldHideCell(vm, columnID: reasonColumnID), "bulk edit should still render the column because no single row owns the hidden-state decision")
    }

    /// Row-edit modal: after a sibling edit flips cell visibility, the single-row form gate follows it.
    func testCollectionSingleRowEditFormFollowsVisibilityFlip() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")]
        ))
        let vm = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(vm)
        vm.tableDataModel.selectedRows = [collRootRow1]

        XCTAssertTrue(editFormWouldHideCell(vm, columnID: reasonColumnID), "reason starts hidden in the single-row edit form")

        var editedStatus = vm.tableDataModel.filteredcellModels
            .first(where: { $0.rowID == collRootRow1 })!
            .cells
            .first(where: { $0.data.id == statusColumnID })!
            .data
        editedStatus.title = "Rejected"
        vm.cellDidChange(rowId: collRootRow1, colIndex: 0, cellDataModel: editedStatus, isNestedCell: false, callOnChange: false)

        XCTAssertFalse(vm.isCellHidden(columnID: reasonColumnID, row: vm.rowToValueElementMap[collRootRow1]), "reason flips visible after status=Rejected")
        XCTAssertFalse(editFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render the cell after the flip")
    }

    /// Collection counterpart of `testValidateTreatsHiddenRequiredTableCellAsValid`: a root-schema
    /// cell hidden by `cellVisibilityLogic` but required must not be reported `.invalid` by
    /// `validate()`. Exercises the `shouldShowCell` gate added to ValidationHandler's collection path.
    func testValidateTreatsHiddenRequiredCollectionCellAsValid() {
        let logic = cellVisibilityLogicDictionary(
            isShow: false,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        var reasonDict = buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic).dictionary
        reasonDict["required"] = true
        let rootColumns: [[String: Any]] = [
            buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
            reasonDict,
            buildColumn(id: noteColumnID, type: .text, title: "Note").dictionary
        ]
        let rootSchemaDict: [String: Any] = [
            "title": "Root",
            "root": true,
            "children": [String](),
            "tableColumns": rootColumns
        ]

        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.title = "Cell Visibility Collection"
        field.file = fileID
        field.dictionary["schema"] = [collRootSchema: rootSchemaDict]
        field.value = .valueElementArray([ValueElement(dictionary: collRootRow(id: collRootRow1, status: "Rejected"))])

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(field)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [collectionFieldID: .collection])

        // validate() gates collection fields behind `isCollectionFieldEnabled` (license-derived);
        // the plain `documentEditor(document:)` helper has no license, so this needs the same
        // license-bearing DocumentEditor init ValidationTestCase.swift uses for collection validation.
        let editor = DocumentEditor(document: document, validateSchema: false, license: licenseKey)
        let editedRow = collRowElement(editor, rowID: collRootRow1)

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, row: editedRow), "reason hidden when status == Rejected")
        XCTAssertTrue(editor.isCellRequired(columnID: reasonColumnID, fieldID: collectionFieldID, schemaKey: collRootSchema, row: editedRow), "reason is still required")

        let status = editor.validate().fieldValidities
            .first(where: { $0.fieldId == collectionFieldID })?
            .rowValidities?.first(where: { $0.rowId == collRootRow1 })?
            .cellValidities.first(where: { $0.columnId == reasonColumnID })?.status
        XCTAssertEqual(status, .valid, "Required-but-hidden empty cell must validate as valid; the user can't fill what they can't see")
    }
}
