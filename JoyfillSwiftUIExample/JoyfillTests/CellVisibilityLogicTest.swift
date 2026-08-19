import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Tests for per-cell visibility logic on table fields.
///
/// A column can carry `cellVisibilityLogic` whose conditions reference *sibling column ids*
/// and resolve against the same row's cell values. Visibility is built once at load into
/// Map 1 (`cellVisibilityMap`), read through `shouldShowCell`, and refreshed on edit via the
/// column->column dependency graph used by `cellDidChange`.
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

    func documentEditor(
        document: JoyDoc,
        mode: Mode = .fill,
        isPageDuplicateEnabled: Bool = false
    ) -> DocumentEditor {
        DocumentEditor(
            document: document,
            mode: mode,
            isPageDuplicateEnabled: isPageDuplicateEnabled,
            validateSchema: false,
            license: ProcessInfo.processInfo.environment["JOYFILL_TEST_LICENSE"] ?? licenseKey
        )
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

    private func waitForMainQueue(file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for change delivery")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1, enforceOrder: true)
    }

    private func externalRowUpdate(fieldID: String, rowID: String, cells: [String: Any], schemaID: String? = nil) -> Change {
        var payload: [String: Any] = [
            "rowId": rowID,
            "row": ["_id": rowID, "cells": cells] as [String: Any]
        ]
        if let schemaID { payload["schemaId"] = schemaID }
        return Change(dictionary: [
            "target": "field.value.rowUpdate",
            "fieldId": fieldID,
            "pageId": pageID,
            "fileId": fileID,
            "change": payload
        ])
    }

    private func externalFieldUpdate(fieldID: String, value: Any, pageID: String? = nil) -> Change {
        Change(dictionary: [
            "target": "field.update",
            "fieldId": fieldID,
            "pageId": pageID ?? self.pageID,
            "fileId": fileID,
            "change": ["value": value]
        ])
    }

    // MARK: - Static show/hide (built at load, read via shouldShowCell)

    /// action=show, condition met -> cell visible
    func testShowWhenConditionMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID)
        XCTAssertTrue(result, "Reason cell should show when status == Rejected (show action, condition met)")
    }

    /// action=show, condition not met -> cell hidden
    func testHiddenWhenShowConditionNotMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID)
        XCTAssertFalse(result, "Reason cell should hide when status != Rejected (show action, condition not met)")
    }

    /// action=hide, condition met -> cell hidden
    func testHideWhenConditionMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: false, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID)
        XCTAssertFalse(result, "Reason cell should hide when status == Rejected (hide action, condition met)")
    }

    /// action=hide, condition not met -> cell visible
    func testShownWhenHideConditionNotMet() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: false, row1Status: "Rejected", row2Status: "Approved"))
        let result = editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID)
        XCTAssertTrue(result, "Reason cell should stay visible when status != Rejected (hide action, condition not met)")
    }

    /// A column with no cellVisibilityLogic is always visible
    func testColumnWithoutLogicAlwaysVisible() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, rowID: row1ID))
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, rowID: row2ID))
    }

    /// Unknown column / field / row default to visible
    func testUnknownLookupsDefaultToVisible() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let row1 = rowElement(editor, rowID: row1ID)
        XCTAssertTrue(editor.shouldShowCell(columnID: "unknown_col", fieldID: tableFieldID, rowID: row1.id ?? ""), "Unknown column defaults to visible")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: "unknown_field", rowID: row1.id ?? ""), "Unknown field defaults to visible")
        let unknownRow = row(id: "unknown_row", cells: [statusColumnID: "Rejected"])
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: unknownRow.id ?? ""), "Unknown row defaults to visible")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: "col_hidden", fieldID: tableFieldID, rowID: r.id ?? ""), "cellsHidden:true with no logic -> hidden")
        XCTAssertTrue(editor.shouldShowCell(columnID: "col_shown", fieldID: tableFieldID, rowID: r.id ?? ""), "cellsHidden:false with no logic -> visible")
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, rowID: r.id ?? ""), "no cellsHidden, no logic -> visible")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "hide + condition met -> hidden")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hide + condition not met -> visible (cellsHidden:true ignored on a logic column)")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "show + condition not met -> hidden")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "Visible when both AND conditions met")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "Hidden when one AND condition fails")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "Visible when one OR condition met")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "Hidden when no OR condition met")
    }

    /// After a refresh, shouldShowCell reflects the new value (Map 1 was updated)
    func testShouldShowCellReflectsRefreshedValue() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let editedRow = row(id: row2ID, cells: [statusColumnID: "Rejected"])

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "Reason hidden before edit")
        editor.cellDidChange(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "Reason visible after refreshing with status=Rejected")
    }

    // MARK: - Map 1 maintenance (insert / delete)

    /// addCellLogicForNewRow seeds the logic maps so a newly inserted row reads correctly.
    func testAddCellVisibilityForNewRow() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let newRow = row(id: "row_new", cells: [statusColumnID: "Rejected"])
        editor.addCellLogicForNewRow(fieldID: tableFieldID, row: newRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: newRow.id ?? ""), "New row's reason should be visible (status=Rejected)")
    }

    /// removeCellLogicForRow drops the row's entries; reads fall back to the visible default.
    func testRemoveCellVisibilityForRow() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let row2 = rowElement(editor, rowID: row2ID)
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2.id ?? ""), "Reason hidden before removal")
        editor.removeCellLogicForRow(fieldID: tableFieldID, rowID: row2ID)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2.id ?? ""), "After removal the entry is gone, defaulting to visible")
    }

    // MARK: - View-layer add-row (repro: adding a row must not flip existing rows)

    private func tableViewModel(_ editor: DocumentEditor, fieldID: String? = nil, pageID: String? = nil) -> TableViewModel {
        let resolvedFieldID = fieldID ?? tableFieldID
        let field = editor.field(fieldID: resolvedFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible, visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(fieldHeaderModel: fieldHeaderModel, mode: .fill, documentEditor: editor, fieldIdentifier: FieldIdentifier(fieldID: resolvedFieldID, pageID: pageID ?? self.pageID, fileID: fileID))!
        return TableViewModel(tableDataModel: tableDataModel)
    }

    /// What the cell builder will render for this cell: the cell has to be present in the rendered
    /// models (else `nil`), and visibility is read live from the view model, exactly as the view does.
    private func renderedCellIsHidden(_ vm: TableViewModel, rowID: String, columnID: String) -> Bool? {
        guard isCellRendered(vm.tableDataModel.filteredcellModels, rowID: rowID, columnID: columnID) else { return nil }
        return !vm.shouldShowCell(columnID: columnID, rowID: rowID)
    }

    private func renderedCellIsHidden(_ vm: CollectionViewModel, rowID: String, columnID: String) -> Bool? {
        guard isCellRendered(vm.tableDataModel.filteredcellModels, rowID: rowID, columnID: columnID) else { return nil }
        return !vm.shouldShowCell(columnID: columnID, rowID: rowID)
    }

    private func isCellRendered(_ models: [RowDataModel], rowID: String, columnID: String) -> Bool {
        models.first(where: { $0.rowID == rowID })?
            .cells.contains(where: { $0.data.id == columnID }) ?? false
    }

    private func assertCellVisibility(
        _ vm: TableViewModel,
        editor: DocumentEditor,
        rowID: String,
        columnID: String,
        isHidden: Bool,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let row = vm.rowElement(forRowID: rowID) else {
            XCTFail("Missing table row \(rowID)", file: file, line: line)
            return
        }
        XCTAssertEqual(
            editor.shouldShowCell(columnID: columnID, fieldID: tableFieldID, rowID: row.id ?? ""),
            !isHidden,
            "Public API: \(message)",
            file: file,
            line: line
        )
        XCTAssertEqual(
            renderedCellIsHidden(vm, rowID: rowID, columnID: columnID),
            isHidden,
            "Rendered model: \(message)",
            file: file,
            line: line
        )
    }

    private func assertCellVisibility(
        _ vm: CollectionViewModel,
        editor: DocumentEditor,
        rowID: String,
        columnID: String,
        isHidden: Bool,
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let row = vm.rowToValueElementMap[rowID] else {
            XCTFail("Missing collection row \(rowID)", file: file, line: line)
            return
        }
        XCTAssertEqual(
            editor.shouldShowCell(columnID: columnID, fieldID: collectionFieldID, rowID: row.id ?? ""),
            !isHidden,
            "Public API: \(message)",
            file: file,
            line: line
        )
        XCTAssertEqual(
            renderedCellIsHidden(vm, rowID: rowID, columnID: columnID),
            isHidden,
            "Rendered model: \(message)",
            file: file,
            line: line
        )
    }

    /// Mirrors TableModalTopNavigationView's single-row hidden-cell gate.
    private func tableEditFormWouldHideCell(_ vm: TableViewModel, columnID: String) -> Bool {
        let singleRowID: String? = vm.tableDataModel.selectedRows.count == 1 ? vm.tableDataModel.selectedRows.first : nil
        return !(singleRowID.map { vm.shouldShowCell(columnID: columnID, rowID: $0) } ?? true)
    }

    // MARK: - Table edit-form gating (mirrors Collection's single-row/bulk-edit gate)

    /// Row-edit modal: single-row edit skips a table cell hidden by cellVisibilityLogic.
    func testTableSingleRowEditFormHidesHiddenCell() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "reason is hidden for status=Approved")
        XCTAssertTrue(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should skip hidden reason cell")
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: tableFieldID, rowID: row1ID))
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: noteColumnID), "single-row edit form should keep independent visible cells")
    }

    /// Row-edit modal: single-row edit keeps a table cell visible when its logic matches.
    func testTableSingleRowEditFormShowsVisibleCell() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "reason is visible for status=Rejected")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render visible reason cell")
    }

    /// Bulk edit: multiple selected rows do not use the single-row hidden-cell gate.
    func testTableBulkEditFormDoesNotHideColumnsForMultipleRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Rejected"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID, row2ID]

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "one selected row has reason hidden")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "bulk edit should still render the column because no single row owns the hidden-state decision")
    }

    /// Row-edit modal: after a sibling edit flips cell visibility, the single-row form gate follows it.
    func testTableSingleRowEditFormFollowsVisibilityFlip() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Approved", row2Status: "Approved"))
        let vm = tableViewModel(editor)
        vm.tableDataModel.selectedRows = [row1ID]

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "reason starts hidden in the single-row edit form")
        XCTAssertTrue(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "reason starts hidden in the single-row edit form")

        var editedStatus = vm.tableDataModel.filteredcellModels
            .first(where: { $0.rowID == row1ID })!
            .cells
            .first(where: { $0.data.id == statusColumnID })!
            .data
        editedStatus.title = "Rejected"
        vm.tableDataModel.valueToValueElements = vm.cellDidChange(rowId: row1ID, colIndex: 0, cellDataModel: editedStatus, isNestedCell: false, callOnChange: false)
        vm.refreshDependentCellLogic(rowId: row1ID, editedColumnID: statusColumnID)

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "reason flips visible after status=Rejected")
        XCTAssertFalse(tableEditFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render the cell after the flip")
    }

    func testExternalTableRowUpdateImmediatelyUpdatesConditionalCells() {
        let editor = documentEditor(document: buildStatusReasonDocument(
            isShow: true,
            row1Status: "Approved",
            row2Status: "Approved"
        ))
        let viewModel = tableViewModel(editor)

        XCTAssertEqual(
            editor.field(fieldID: tableFieldID)?
                .valueToValueElements?
                .first(where: { $0.id == row1ID })?
                .cells?[statusColumnID]?
                .text,
            "Approved",
            "Public document starts with the row status set to Approved"
        )
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == row1ID })?
                .cells.first(where: { $0.data.id == statusColumnID })?
                .data.title,
            "Approved",
            "Rendered table starts with the row status set to Approved"
        )
        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "reason is hidden while status is Approved")

        editor.change(changes: [externalRowUpdate(
            fieldID: tableFieldID,
            rowID: row1ID,
            cells: [statusColumnID: "Rejected"]
        )])
        waitForMainQueue()

        XCTAssertEqual(
            editor.field(fieldID: tableFieldID)?
                .valueToValueElements?
                .first(where: { $0.id == row1ID })?
                .cells?[statusColumnID]?
                .text,
            "Rejected",
            "Public document stores the externally updated status"
        )
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == row1ID })?
                .cells.first(where: { $0.data.id == statusColumnID })?
                .data.title,
            "Rejected",
            "Rendered table displays the externally updated status"
        )
        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "external update reveals reason like an on-screen edit")
    }

    func testExternalTablePartialUpdateHidesOnlyTargetRowAndPreservesOtherCells() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic),
            buildColumn(id: noteColumnID, type: .text, title: "Note")
        ]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: [
            row(id: row1ID, cells: [statusColumnID: "Rejected", reasonColumnID: "Keep reason", noteColumnID: "Keep note"]),
            row(id: row2ID, cells: [statusColumnID: "Rejected", reasonColumnID: "Other reason", noteColumnID: "Other note"])
        ]))
        let viewModel = tableViewModel(editor)

        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "target row starts visible")
        assertCellVisibility(viewModel, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "untouched row starts visible")

        editor.change(changes: [externalRowUpdate(
            fieldID: tableFieldID,
            rowID: row1ID,
            cells: [statusColumnID: "Approved"]
        )])
        waitForMainQueue()

        let updatedRow = rowElement(editor, rowID: row1ID)
        XCTAssertEqual(updatedRow.cells?[statusColumnID]?.text, "Approved",
                       "Public document stores the changed status")
        XCTAssertEqual(updatedRow.cells?[reasonColumnID]?.text, "Keep reason",
                       "A partial update must preserve an omitted reason")
        XCTAssertEqual(updatedRow.cells?[noteColumnID]?.text, "Keep note",
                       "A partial update must preserve an omitted note")
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == row1ID })?
                .cells.first(where: { $0.data.id == reasonColumnID })?.data.title,
            "Keep reason",
            "Rendered table keeps the omitted reason"
        )
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == row1ID })?
                .cells.first(where: { $0.data.id == noteColumnID })?.data.title,
            "Keep note",
            "Rendered table keeps the omitted note"
        )
        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "reverse transition hides the target row")
        assertCellVisibility(viewModel, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "targeted update does not change another row")
    }

    // MARK: - Duplicate row (shares addRow's rebuild-from-scratch path)

    /// Duplicating a row must only compute the duplicated row's cells; pre-existing rows keep their visibility.
    func testDuplicateRowDoesNotFlipExistingRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Rejected"))
        let vm = tableViewModel(editor)

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "row1 reason is visible before duplicate")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "row2 reason is visible before duplicate")

        vm.tableDataModel.selectedRows = [row2ID]
        vm.duplicateRow()

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "row1 reason stays visible after duplicate")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "row2 reason stays visible after duplicate")
    }

    // MARK: - Multiple dependents on one source column

    /// Two columns whose cellVisibilityLogic both key off the same sibling column are both
    /// refreshed when that sibling changes (Set-based fan-out in the dependency map).
    func testCellChangeRefreshesMultipleDependentColumns() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(
                    fieldID: statusColumnID,
                    conditionType: .equals,
                    value: .string("Rejected")
                )
            ]
        )

        let secondReasonColumnID = "col_reason2"
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(
                id: reasonColumnID,
                type: .text,
                title: "Reason",
                cellVisibilityLogic: logic
            ),
            buildColumn(
                id: secondReasonColumnID,
                type: .text,
                title: "Reason 2",
                cellVisibilityLogic: logic
            )
        ]

        let rows = [
            row(id: row1ID, cells: [statusColumnID: "Approved"])
        ]
        let editor = documentEditor(
            document: buildDocument(columns: columns, rows: rows)
        )

        XCTAssertFalse(
            editor.shouldShowCell(
                columnID: reasonColumnID,
                fieldID: tableFieldID,
                rowID: row1ID
            )
        )
        XCTAssertFalse(
            editor.shouldShowCell(
                columnID: secondReasonColumnID,
                fieldID: tableFieldID,
                rowID: row1ID
            )
        )

        let editedRow = row(
            id: row1ID,
            cells: [statusColumnID: "Rejected"]
        )

        editor.cellDidChange(
            fieldID: tableFieldID,
            editedColumnID: statusColumnID,
            row: editedRow
        )

        XCTAssertTrue(
            editor.shouldShowCell(
                columnID: reasonColumnID,
                fieldID: tableFieldID,
                rowID: row1ID
            ),
            "First dependent column should become visible"
        )
        XCTAssertTrue(
            editor.shouldShowCell(
                columnID: secondReasonColumnID,
                fieldID: tableFieldID,
                rowID: row1ID
            ),
            "Second dependent column should become visible"
        )
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

        XCTAssertFalse(editor.shouldShowCell(columnID: middleColumnID, fieldID: tableFieldID, rowID: row1ID), "middle hidden before edit (status != Rejected)")
        XCTAssertTrue(editor.shouldShowCell(columnID: chainedDependentColumnID, fieldID: tableFieldID, rowID: row1ID), "chained dependent already visible because middle's stored value is Ready, independent of middle's own visibility")

        let editedRow = row(id: row1ID, cells: [statusColumnID: "Rejected", middleColumnID: "Ready"])

        editor.cellDidChange(fieldID: tableFieldID, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: middleColumnID, fieldID: tableFieldID, rowID: editedRow.id ?? ""), "middle now visible (status=Rejected)")
        XCTAssertTrue(editor.shouldShowCell(columnID: chainedDependentColumnID, fieldID: tableFieldID, rowID: editedRow.id ?? ""), "chained dependent remains visible because its stored middle value is unchanged")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "visible when status != Approved")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hidden when status == Approved")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "visible when score > 50")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hidden when score <= 50")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "visible when score < 50")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hidden when score >= 50")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "visible when status is empty")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hidden when status is not empty")
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID), "visible when status is not empty")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row2ID), "hidden when status is empty")
    }

    /// `cellVisibilityLogic` without an action cannot be evaluated and falls back to `cellsHidden`.
    func testCellVisibilityLogicWithoutActionFallsBackToCellsHidden() {
        let logicWithoutAction: [String: Any] = [
            "eval": "and",
            "conditions": [
                ["column": statusColumnID, "condition": "=", "value": "Rejected", "_id": UUID().uuidString]
            ],
            "_id": UUID().uuidString
        ]
        let visibleFallbackColumnID = "col_visible_fallback"
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logicWithoutAction, cellsHidden: true),
            buildColumn(id: visibleFallbackColumnID, type: .text, title: "Visible fallback", cellVisibilityLogic: logicWithoutAction, cellsHidden: false)
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Rejected"])]
        let editor = documentEditor(document: buildDocument(columns: columns, rows: rows))

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: row1ID),
                       "Action-less logic falls back to cellsHidden:true")
        XCTAssertTrue(editor.shouldShowCell(columnID: visibleFallbackColumnID, fieldID: tableFieldID, rowID: row1ID),
                      "Action-less logic falls back to cellsHidden:false")
    }

    // MARK: - View-layer add-row (repro: adding a row must not flip existing rows)
    func testAddRowDoesNotFlipExistingRows() {
        let editor = documentEditor(document: buildStatusReasonDocument(isShow: true, row1Status: "Rejected", row2Status: "Rejected"))
        let vm = tableViewModel(editor)

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "row1 reason is visible before add")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "row2 reason is visible before add")

        // Matches the "Add Row +" button exactly: no explicit values, event sent, no full rebuild.
        vm.addRow()

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "row1 reason stays visible after add")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: reasonColumnID,
                             isHidden: false, "row2 reason stays visible after add")
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

    func testTable1AddRowDoesNotFlipExistingRows() {
        // rows 1 & 2 have a dropdown value (non-empty -> text1 visible); row 3 empty (hidden).
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: "6a634222bcd54de3258770c7", row2Dropdown: "6a634222bcd54de3258770c7", row3Dropdown: nil))
        let vm = tableViewModel(editor)

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 is visible before add")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: "text1",
                             isHidden: false, "row2 text1 is visible before add")
        assertCellVisibility(vm, editor: editor, rowID: "row_003", columnID: "text1",
                             isHidden: true, "row3 text1 is hidden before add")

        vm.addRow()

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 stays visible after add")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: "text1",
                             isHidden: false, "row2 text1 stays visible after add")
        assertCellVisibility(vm, editor: editor, rowID: "row_003", columnID: "text1",
                             isHidden: true, "row3 text1 stays hidden after add")
    }

    func testTable1DeleteRowDoesNotFlipRemainingRows() {
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: "6a634222bcd54de3258770c7", row2Dropdown: "6a634222bcd54de3258770c7", row3Dropdown: nil))
        let vm = tableViewModel(editor)

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 is visible before delete")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: "text1",
                             isHidden: false, "row2 text1 is visible before delete")

        // Delete the hidden (empty-dropdown) row, mirroring the row-select + delete UI action.
        vm.deleteSelectedRow(["row_003"])

        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 stays visible after delete")
        assertCellVisibility(vm, editor: editor, rowID: row2ID, columnID: "text1",
                             isHidden: false, "row2 text1 stays visible after delete")
    }

    /// The originally reported bug: a cell revealed by an in-modal edit reverted to hidden the moment a
    /// row was added, because the refresh wrote the new state only into `filteredcellModels` and
    /// `filterRowsIfNeeded()` (run on add) resets `filteredcellModels = cellModels`. Visibility is no
    /// longer stored on the cell models, so a rebuild has nothing to wipe — this guards the regression.
    func testEditRevealSurvivesAddRow() {
        // Every row loads with an empty dropdown -> text1 hidden.
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: nil, row2Dropdown: nil, row3Dropdown: nil))
        let vm = tableViewModel(editor)
        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: true, "row1 text1 is hidden at load")

        // User picks a dropdown value in row1 -> text1 is revealed via the dependency refresh.
        setDropdown(vm, rowID: row1ID, value: "6a634222bcd54de3258770c7")
        vm.refreshDependentCellLogic(rowId: row1ID, editedColumnID: "dropdown1")
        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 is revealed after picking dropdown")

        // Adding a row must NOT wipe the revealed state.
        vm.addRow()
        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 stays visible after add")
    }

    /// Same bug via delete instead of add.
    func testEditRevealSurvivesDeleteRow() {
        let editor = documentEditor(document: buildTable1Document(row1Dropdown: nil, row2Dropdown: nil, row3Dropdown: nil))
        let vm = tableViewModel(editor)

        setDropdown(vm, rowID: row1ID, value: "6a634222bcd54de3258770c7")
        vm.refreshDependentCellLogic(rowId: row1ID, editedColumnID: "dropdown1")
        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 is revealed after picking dropdown")

        vm.deleteSelectedRow(["row_003"])
        assertCellVisibility(vm, editor: editor, rowID: row1ID, columnID: "text1",
                             isHidden: false, "row1 text1 stays visible after delete")
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

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID, rowID: editedRow.id ?? ""), "reason hidden when status == Rejected")
        XCTAssertTrue(editor.isCellRequired(columnID: reasonColumnID, fieldID: tableFieldID, rowID: editedRow.id ?? ""), "reason is still required")

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

    private func collectionViewModel(_ editor: DocumentEditor, fieldID: String? = nil, pageID: String? = nil) -> CollectionViewModel {
        let resolvedFieldID = fieldID ?? collectionFieldID
        let field = editor.field(fieldID: resolvedFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title,
                                                required: field?.required,
                                                tipDescription: field?.tipDescription,
                                                tipTitle: field?.tipTitle,
                                                tipVisible: field?.tipVisible,
                                                visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let tableDataModel = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                            mode: .fill,
                                            documentEditor: editor,
                                            fieldIdentifier: FieldIdentifier(fieldID: resolvedFieldID, pageID: pageID ?? self.pageID, fileID: fileID))!
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
        return !(singleRowID.map { vm.shouldShowCell(columnID: columnID, rowID: $0) } ?? true)
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
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow1), "row1 reason visible (status=Rejected)")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow2), "row2 reason hidden (status=Approved)")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow1), "root reason hidden (status=Approved)")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collChildRow1), "nested child reason visible (status=Rejected)")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow1), "reason hidden before edit")

        let editedRow = ValueElement(dictionary: ["_id": collRootRow1, "cells": [statusColumnID: "Rejected"]])
        editor.cellDidChange(fieldID: collectionFieldID, schemaID: collRootSchema, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: editedRow.id ?? ""), "reason visible after status=Rejected")
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
        editor.addCellLogicForNewRow(fieldID: collectionFieldID, schemaID: collRootSchema, row: newRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: newRow.id ?? ""), "new row reason visible (status=Rejected)")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: row2.id ?? ""), "reason hidden before removal")
        editor.removeCellLogicForRow(fieldID: collectionFieldID, rowID: collRootRow2)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: row2.id ?? ""), "entry gone after removal -> defaults visible")
    }

    /// Page-field change: editing the referenced page field flips all dependent collection cells.
    func testCollectionPageFieldChangeFlipsCell() {
        let logic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")],
            pageValue: "No"
        ))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow1), "reason hidden while page field != Yes")

        let identifier = FieldIdentifier(fieldID: pageTextFieldID, pageID: pageID, fileID: fileID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: identifier, updateValue: .string("Yes")))

        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collRootRow1), "reason visible after page field -> Yes")
    }

    func testExternalPageFieldUpdateRefreshesTableConditionalCells() {
        let logic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))
        let columns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic),
            buildColumn(id: noteColumnID, type: .text, title: "Note")
        ]
        let rows = [row(id: row1ID, cells: [statusColumnID: "Approved"])]

        var tableField = JoyDocField()
        tableField.type = "table"
        tableField.id = tableFieldID
        tableField.identifier = "field_\(tableFieldID)"
        tableField.file = fileID
        tableField.tableColumns = columns
        tableField.tableColumnOrder = columns.compactMap(\.id)
        tableField.rowOrder = [row1ID]
        tableField.value = .valueElementArray(rows)

        var pageField = JoyDocField()
        pageField.type = "text"
        pageField.id = pageTextFieldID
        pageField.identifier = "field_\(pageTextFieldID)"
        pageField.file = fileID
        pageField.value = .string("No")

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(contentsOf: [pageField, tableField])
        document = document.setFieldPositionToPage(
            pageId: pageID,
            idAndTypes: [pageTextFieldID: .text, tableFieldID: .table]
        )

        let editor = documentEditor(document: document)
        let viewModel = tableViewModel(editor)
        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: true, "reason starts hidden while the page answer is No")

        editor.change(changes: [externalFieldUpdate(fieldID: pageTextFieldID, value: "Yes")])

        XCTAssertEqual(editor.field(fieldID: pageTextFieldID)?.value?.text, "Yes",
                       "Public document stores the externally updated page answer")
        assertCellVisibility(viewModel, editor: editor, rowID: row1ID, columnID: reasonColumnID,
                             isHidden: false, "external page update reveals the table reason")
    }

    func testExternalPageFieldUpdateRefreshesCollectionConditionalCells() {
        let logic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")],
            pageValue: "No"
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(viewModel)
        assertCellVisibility(viewModel, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: true, "reason starts hidden while the page answer is No")

        editor.change(changes: [externalFieldUpdate(fieldID: pageTextFieldID, value: "Yes")])

        XCTAssertEqual(editor.field(fieldID: pageTextFieldID)?.value?.text, "Yes",
                       "Public document stores the externally updated page answer")
        assertCellVisibility(viewModel, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: false, "external page update reveals the collection reason")
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collChildRow1), "child reason hidden while page field != Yes")

        let identifier = FieldIdentifier(fieldID: pageTextFieldID, pageID: pageID, fileID: fileID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: identifier, updateValue: .string("Yes")))

        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collChildRow1), "child reason visible after page field -> Yes")
    }

    /// Sibling edit: recomputing with a new sibling value flips a CHILD schema's dependent cell
    /// using the schema-scoped `cellDidChange` entry point.
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
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: collChildRow1), "child reason hidden before edit")

        let editedRow = ValueElement(dictionary: ["_id": collChildRow1, "cells": [statusColumnID: "Rejected"]])
        editor.cellDidChange(fieldID: collectionFieldID, schemaID: collChildSchema, editedColumnID: statusColumnID, row: editedRow)
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: editedRow.id ?? ""), "child reason visible after status=Rejected")
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

        assertCellVisibility(vm, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: true, "reason is hidden for status=Approved")
        XCTAssertTrue(editFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should skip hidden reason cell")
        XCTAssertTrue(editor.shouldShowCell(columnID: noteColumnID, fieldID: collectionFieldID,
                                            rowID: collRootRow1))
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

        assertCellVisibility(vm, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: false, "reason is visible for status=Rejected")
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

        assertCellVisibility(vm, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: true, "one selected row has reason hidden")
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

        assertCellVisibility(vm, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: true, "reason starts hidden in the single-row edit form")
        XCTAssertTrue(editFormWouldHideCell(vm, columnID: reasonColumnID), "reason starts hidden in the single-row edit form")

        var editedStatus = vm.tableDataModel.filteredcellModels
            .first(where: { $0.rowID == collRootRow1 })!
            .cells
            .first(where: { $0.data.id == statusColumnID })!
            .data
        editedStatus.title = "Rejected"
        vm.cellDidChange(rowId: collRootRow1, colIndex: 0, cellDataModel: editedStatus, isNestedCell: false, callOnChange: false)

        assertCellVisibility(vm, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: false, "reason flips visible after status=Rejected")
        XCTAssertFalse(editFormWouldHideCell(vm, columnID: reasonColumnID), "single-row edit form should render the cell after the flip")
    }

    func testExternalCollectionRowUpdateImmediatelyUpdatesConditionalCells() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(id: collRootRow1, status: "Approved")]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(viewModel)

        assertCellVisibility(viewModel, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: true, "reason is hidden while status is Approved")

        editor.change(changes: [externalRowUpdate(
            fieldID: collectionFieldID,
            rowID: collRootRow1,
            cells: [statusColumnID: "Rejected"],
            schemaID: collRootSchema
        )])
        waitForMainQueue()

        assertCellVisibility(viewModel, editor: editor, rowID: collRootRow1, columnID: reasonColumnID,
                             isHidden: false, "external update reveals reason like an on-screen edit")
    }

    func testExternalNestedCollectionRowUpdateReevaluatesConditionalCells() {
        let logic = cellVisibilityLogicDictionary(
            isShow: true,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        let editor = documentEditor(document: buildCollectionDocument(
            rootReasonLogic: logic,
            rootRows: [collRootRow(
                id: collRootRow1,
                status: "Approved",
                children: [collChildRow(id: collChildRow1, status: "Approved")]
            )]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionViewModelToLoad(viewModel)

        XCTAssertFalse(editor.shouldShowCell(
            columnID: reasonColumnID,
            fieldID: collectionFieldID,
            rowID: collChildRow1
        ), "Public API reports the nested reason hidden before the external update")
        XCTAssertEqual(viewModel.rowToValueElementMap[collChildRow1]?.cells?[statusColumnID]?.text, "Approved",
                       "Rendered collection starts with the nested status set to Approved")

        editor.change(changes: [externalRowUpdate(
            fieldID: collectionFieldID,
            rowID: collChildRow1,
            cells: [statusColumnID: "Rejected"],
            schemaID: collChildSchema
        )])
        waitForMainQueue()

        XCTAssertEqual(collRowElement(editor, rowID: collChildRow1).cells?[statusColumnID]?.text, "Rejected",
                       "Public document stores the externally updated nested status")
        XCTAssertEqual(viewModel.rowToValueElementMap[collChildRow1]?.cells?[statusColumnID]?.text, "Rejected",
                       "Rendered collection stores the externally updated nested status")
        XCTAssertTrue(editor.shouldShowCell(
            columnID: reasonColumnID,
            fieldID: collectionFieldID,
            rowID: collChildRow1
        ), "Public API reveals the nested reason after its sibling status changes")
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

        let editor = documentEditor(document: document)
        let editedRow = collRowElement(editor, rowID: collRootRow1)

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: editedRow.id ?? ""), "reason hidden when status == Rejected")
        XCTAssertTrue(editor.isCellRequired(columnID: reasonColumnID, fieldID: collectionFieldID, schemaKey: collRootSchema, rowID: editedRow.id ?? ""), "reason is still required")

        let status = editor.validate().fieldValidities
            .first(where: { $0.fieldId == collectionFieldID })?
            .rowValidities?.first(where: { $0.rowId == collRootRow1 })?
            .cellValidities.first(where: { $0.columnId == reasonColumnID })?.status
        XCTAssertEqual(status, .valid, "Required-but-hidden empty cell must validate as valid; the user can't fill what they can't see")
    }

    func testValidateTreatsHiddenRequiredNestedCollectionCellAsValid() {
        let childLogic = cellVisibilityLogicDictionary(
            isShow: false,
            conditions: [LogicConditionTest(fieldID: statusColumnID, conditionType: .equals, value: .string("Rejected"))]
        )
        var childReason = buildColumn(
            id: reasonColumnID,
            type: .text,
            title: "Reason",
            cellVisibilityLogic: childLogic
        ).dictionary
        childReason["required"] = true

        let rootSchemaDict: [String: Any] = [
            "title": "Root",
            "root": true,
            "children": [collChildSchema],
            "tableColumns": [buildColumn(id: noteColumnID, type: .text, title: "Note").dictionary]
        ]
        let childSchemaDict: [String: Any] = [
            "title": "Child",
            "root": false,
            "children": [String](),
            "tableColumns": [
                buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
                childReason
            ]
        ]
        let child = collChildRow(id: collChildRow1, status: "Rejected")
        let root = collRootRow(id: collRootRow1, status: "Approved", children: [child])

        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.file = fileID
        field.dictionary["schema"] = [collRootSchema: rootSchemaDict, collChildSchema: childSchemaDict]
        field.value = .valueElementArray([ValueElement(dictionary: root)])

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(field)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [collectionFieldID: .collection])

        let editor = documentEditor(document: document)
        let nestedRow = collRowElement(editor, rowID: collChildRow1)

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID, rowID: nestedRow.id ?? ""),
                       "Nested reason is hidden when status is Rejected")
        XCTAssertTrue(editor.isCellRequired(
            columnID: reasonColumnID,
            fieldID: collectionFieldID,
            schemaKey: collChildSchema,
            rowID: nestedRow.id ?? ""
        ), "Nested reason remains required according to its schema")

        let status = editor.validate().fieldValidities
            .first(where: { $0.fieldId == collectionFieldID })?
            .rowValidities?.first(where: { $0.rowId == collChildRow1 && $0.schemaId == collChildSchema })?
            .cellValidities.first(where: { $0.columnId == reasonColumnID })?.status
        XCTAssertEqual(status, .valid,
                       "An empty required nested cell must be valid while conditional logic hides it")
    }

    // MARK: - Page duplication

    private func buildPageDuplicationVisibilityDocument(pageValue: String) -> JoyDoc {
        let logic = pageFieldCellLogic(isShow: true, pageFieldID: pageTextFieldID, value: .string("Yes"))

        var pageField = JoyDocField()
        pageField.type = "text"
        pageField.id = pageTextFieldID
        pageField.identifier = "field_\(pageTextFieldID)"
        pageField.file = fileID
        pageField.value = .string(pageValue)

        let tableColumns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status"),
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic)
        ]
        var tableField = JoyDocField()
        tableField.type = "table"
        tableField.id = tableFieldID
        tableField.identifier = "field_\(tableFieldID)"
        tableField.file = fileID
        tableField.tableColumns = tableColumns
        tableField.tableColumnOrder = tableColumns.compactMap(\.id)
        tableField.rowOrder = [row1ID]
        tableField.value = .valueElementArray([
            row(id: row1ID, cells: [statusColumnID: "Pending", reasonColumnID: "Table reason"])
        ])

        let rootColumns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic).dictionary
        ]
        let childColumns = [
            buildColumn(id: statusColumnID, type: .text, title: "Status").dictionary,
            buildColumn(id: reasonColumnID, type: .text, title: "Reason", cellVisibilityLogic: logic).dictionary
        ]
        var collectionField = JoyDocField()
        collectionField.type = "collection"
        collectionField.id = collectionFieldID
        collectionField.identifier = "field_\(collectionFieldID)"
        collectionField.file = fileID
        collectionField.dictionary["schema"] = [
            collRootSchema: [
                "title": "Root",
                "root": true,
                "children": [collChildSchema],
                "tableColumns": rootColumns
            ] as [String: Any],
            collChildSchema: [
                "title": "Child",
                "root": false,
                "children": [String](),
                "tableColumns": childColumns
            ] as [String: Any]
        ]
        collectionField.value = .valueElementArray([ValueElement(dictionary: collRootRow(
            id: collRootRow1,
            status: "Pending",
            children: [collChildRow(id: collChildRow1, status: "Pending")]
        ))])

        return JoyDoc(dictionary: [
            "_id": "dup-visibility-doc",
            "files": [[
                "_id": fileID,
                "pageOrder": [pageID],
                "pages": [[
                    "_id": pageID,
                    "fieldPositions": [
                        ["_id": "fp-page-trigger", "field": pageTextFieldID, "type": "text"],
                        ["_id": "fp-table", "field": tableFieldID, "type": "table"],
                        ["_id": "fp-collection", "field": collectionFieldID, "type": "collection"]
                    ]
                ]]
            ]],
            "fields": [pageField.dictionary, tableField.dictionary, collectionField.dictionary]
        ])
    }

    private func duplicatedVisibilityFields(
        _ editor: DocumentEditor
    ) -> (pageID: String, pageField: JoyDocField, tableField: JoyDocField, collectionField: JoyDocField)? {
        guard let pageOrder = editor.document.files.first?.pageOrder,
              let originalIndex = pageOrder.firstIndex(of: pageID),
              pageOrder.indices.contains(originalIndex + 1) else {
            return nil
        }
        let duplicatedPageID = pageOrder[originalIndex + 1]
        guard let duplicatedPage = editor.document.files.first?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            return nil
        }
        let fieldIDs = Set(duplicatedPage.fieldPositions?.compactMap(\.field) ?? [])
        let fields = editor.document.fields.filter { fieldIDs.contains($0.id ?? "") }
        guard let pageField = fields.first(where: { $0.fieldType == .text }),
              let tableField = fields.first(where: { $0.fieldType == .table }),
              let collectionField = fields.first(where: { $0.fieldType == .collection }) else {
            return nil
        }
        return (duplicatedPageID, pageField, tableField, collectionField)
    }

    private func row(in field: JoyDocField, rowID: String) -> ValueElement? {
        func find(_ rows: [ValueElement]) -> ValueElement? {
            for row in rows {
                if row.id == rowID { return row }
                if let branches = row.childrens {
                    for children in branches.values {
                        if let result = find(children.valueToValueElements ?? []) { return result }
                    }
                }
            }
            return nil
        }
        return find(field.valueToValueElements ?? [])
    }

    func testDuplicatePageWithValuesUsesCopiedPageValuesForTableAndNestedCollectionVisibility() {
        let editor = documentEditor(
            document: buildPageDuplicationVisibilityDocument(pageValue: "Yes"),
            mode: .fill,
            isPageDuplicateEnabled: true
        )

        editor.duplicatePage(pageID: pageID, copyWithValues: true)

        guard let duplicated = duplicatedVisibilityFields(editor),
              let duplicatedTableID = duplicated.tableField.id,
              let duplicatedCollectionID = duplicated.collectionField.id,
              let duplicatedPageFieldID = duplicated.pageField.id,
              let tableRow = row(in: duplicated.tableField, rowID: row1ID),
              let rootRow = row(in: duplicated.collectionField, rowID: collRootRow1),
              let childRow = row(in: duplicated.collectionField, rowID: collChildRow1) else {
            XCTFail("Duplicating with values must copy the page field, table row, root row, and nested row")
            return
        }

        XCTAssertEqual(duplicated.pageField.value?.text, "Yes", "Page 2 starts with Page 1's copied trigger value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedTableID, rowID: tableRow.id ?? ""),
                      "Page 2 table visibility uses its copied page value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID, rowID: rootRow.id ?? ""),
                      "Page 2 collection root visibility uses its copied page value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID, rowID: childRow.id ?? ""),
                      "Page 2 nested visibility uses its copied page value")

        editor.change(changes: [externalFieldUpdate(
            fieldID: duplicatedPageFieldID,
            value: "No",
            pageID: duplicated.pageID
        )])

        let updatedTable = editor.field(fieldID: duplicatedTableID)!
        let updatedCollection = editor.field(fieldID: duplicatedCollectionID)!
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedTableID,
                                             rowID: row1ID),
                       "Changing Page 2 hides only Page 2's table reason")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID,
                                             rowID: collRootRow1),
                       "Changing Page 2 hides its collection root reason")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID,
                                             rowID: collChildRow1),
                       "Changing Page 2 hides its nested reason")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID,
                                            rowID: row1ID),
                      "Changing Page 2 must not affect Page 1's table")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID,
                                            rowID: collChildRow1),
                      "Changing Page 2 must not affect Page 1's nested collection row")

        editor.change(changes: [externalFieldUpdate(
            fieldID: duplicatedPageFieldID,
            value: "Yes",
            pageID: duplicated.pageID
        )])
        editor.change(changes: [externalFieldUpdate(fieldID: pageTextFieldID, value: "No")])

        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID,
                                             rowID: row1ID),
                       "Page 1 follows its own updated value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedTableID,
                                            rowID: row1ID),
                      "Changing Page 1 must not affect Page 2's table")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID,
                                            rowID: collChildRow1),
                      "Changing Page 1 must not affect Page 2's nested collection row")
        XCTAssertEqual(editor.validate().status, .valid, "Duplicated-page visibility changes must keep the document valid")
    }

    func testDuplicatePageWithoutValuesEvaluatesNewTableAndNestedCollectionRowsFromPageTwoValues() {
        let editor = documentEditor(
            document: buildPageDuplicationVisibilityDocument(pageValue: "No"),
            mode: .fill,
            isPageDuplicateEnabled: true
        )

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        guard let duplicated = duplicatedVisibilityFields(editor),
              let duplicatedTableID = duplicated.tableField.id,
              let duplicatedCollectionID = duplicated.collectionField.id,
              let duplicatedPageFieldID = duplicated.pageField.id else {
            XCTFail("Duplicating without values must still copy all page fields")
            return
        }
        XCTAssertNil(duplicated.pageField.value, "Page 2's trigger starts empty when values are not copied")
        XCTAssertTrue(duplicated.tableField.valueToValueElements?.isEmpty ?? true,
                      "Page 2's table starts without copied rows")
        XCTAssertTrue(duplicated.collectionField.valueToValueElements?.isEmpty ?? true,
                      "Page 2's collection starts without copied rows")

        let tableViewModel = tableViewModel(editor, fieldID: duplicatedTableID, pageID: duplicated.pageID)
        tableViewModel.addRow(
            with: "page_2_table_row",
            and: [statusColumnID: .string("Pending"), reasonColumnID: .string("")],
            shouldSendEvent: false
        )
        let collectionViewModel = collectionViewModel(editor, fieldID: duplicatedCollectionID, pageID: duplicated.pageID)
        waitForCollectionViewModelToLoad(collectionViewModel)
        collectionViewModel.addRow(
            with: "page_2_root_row",
            and: [statusColumnID: .string("Pending"), reasonColumnID: .string("")],
            shouldSendEvent: false
        )
        collectionViewModel.addRowWithIndex(
            with: "page_2_child_row",
            and: [statusColumnID: .string("Pending"), reasonColumnID: .string("")],
            metadata: nil,
            shouldSendEvent: false,
            index: nil,
            nestedKey: collChildSchema,
            parentRowID: "page_2_root_row"
        )

        guard let emptyTriggerTableRow = tableViewModel.rowElement(forRowID: "page_2_table_row"),
              let emptyTriggerRootRow = collectionViewModel.rowToValueElementMap["page_2_root_row"],
              let emptyTriggerChildRow = collectionViewModel.rowToValueElementMap["page_2_child_row"] else {
            XCTFail("New Page 2 rows must be available through the rendered models")
            return
        }
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedTableID, rowID: emptyTriggerTableRow.id ?? ""))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID, rowID: emptyTriggerRootRow.id ?? ""))
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID, rowID: emptyTriggerChildRow.id ?? ""))

        editor.change(changes: [externalFieldUpdate(
            fieldID: duplicatedPageFieldID,
            value: "Yes",
            pageID: duplicated.pageID
        )])

        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedTableID,
                                            rowID: "page_2_table_row"),
                      "A new Page 2 table row follows Page 2's newly entered trigger value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID,
                                            rowID: "page_2_root_row"),
                      "A new Page 2 collection row follows Page 2's newly entered trigger value")
        XCTAssertTrue(editor.shouldShowCell(columnID: reasonColumnID, fieldID: duplicatedCollectionID,
                                            rowID: "page_2_child_row"),
                      "A new Page 2 nested row follows Page 2's newly entered trigger value")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: tableFieldID,
                                             rowID: row1ID),
                       "Entering Page 2's value must not change Page 1's table")
        XCTAssertFalse(editor.shouldShowCell(columnID: reasonColumnID, fieldID: collectionFieldID,
                                             rowID: collChildRow1),
                       "Entering Page 2's value must not change Page 1's nested row")
        XCTAssertEqual(editor.validate().status, .valid, "Rows created on a without-values copy must validate after visibility changes")
    }

}
