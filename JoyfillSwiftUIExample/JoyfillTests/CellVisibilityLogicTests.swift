import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Tests for per-row cell visibility (`cellVisibilityLogic`), evaluated against a row's sibling cells.
final class CellVisibilityLogicTests: XCTestCase {
    // Reuse the IDs the JoyDoc builder extensions expect.
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    let tableFieldID = "cell_vis_table_001"

    let nameColumnID = "col_name"
    let ageColumnID = "col_age"
    let statusColumnID = "col_status"

    // MARK: - Builders

    func buildColumn(id: String, type: ColumnTypes, title: String, cellVisibilityLogic: [String: Any]? = nil, hidden: Bool = false) -> FieldTableColumn {
        var dict: [String: Any] = [
            "_id": id,
            "type": type.rawValue,
            "title": title,
            "width": 0,
            "identifier": "field_column_\(id)"
        ]
        dict["hidden"] = hidden
        if let logic = cellVisibilityLogic {
            dict["cellVisilibiltyLogic"] = logic
        }
        return FieldTableColumn(dictionary: dict)
    }

    /// A cellVisibilityLogic dictionary. `field` references a sibling column in the same row.
    func visibilityLogic(action: String, conditions: [[String: Any]], eval: String = "and") -> [String: Any] {
        ["action": action, "eval": eval, "conditions": conditions, "_id": UUID().uuidString]
    }

    func condition(field: String, condition: String, value: ValueUnion) -> [String: Any] {
        ["file": fileID, "page": pageID, "field": field, "condition": condition, "value": value, "_id": UUID().uuidString]
    }

    func row(id: String, cells: [String: ValueUnion]) -> ValueElement {
        var element = ValueElement(dictionary: ["_id": id])
        element.cells = cells
        return element
    }

    /// Standard column set: name (text), age (number), status (text) with the supplied logic.
    func columns(statusLogic: [String: Any]?, statusHidden: Bool = false) -> [FieldTableColumn] {
        [
            buildColumn(id: nameColumnID, type: .text, title: "Name"),
            buildColumn(id: ageColumnID, type: .number, title: "Age"),
            buildColumn(id: statusColumnID, type: .text, title: "Status", cellVisibilityLogic: statusLogic, hidden: statusHidden)
        ]
    }

    func makeEditor(columns: [FieldTableColumn]) -> DocumentEditor {
        var tableField = JoyDocField()
        tableField.type = "table"
        tableField.id = tableFieldID
        tableField.identifier = "field_\(tableFieldID)"
        tableField.title = "Cell Visibility Table"
        tableField.file = fileID
        tableField.tableColumns = columns
        tableField.tableColumnOrder = columns.compactMap { $0.id }
        tableField.rowOrder = []

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [tableFieldID: .table])
        return DocumentEditor(document: document, validateSchema: false)
    }

    func statusColumn(in columns: [FieldTableColumn]) -> FieldTableColumn {
        columns.first { $0.id == statusColumnID }!
    }

    // MARK: - Hide action

    /// action=hide: hide status when age < 25. Row age=23 -> cell hidden.
    func testHideActionConditionMet() {
        let logic = visibilityLogic(action: "hide", conditions: [condition(field: ageColumnID, condition: "<", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let row = row(id: "row_1", cells: [nameColumnID: .string("John"), ageColumnID: .double(23)])
        XCTAssertFalse(editor.shouldShowCell(row: row, column: statusColumn(in: cols), columns: cols),
                       "Status should hide when age < 25 (age=23)")
    }

    /// action=hide: hide status when age < 25. Row age=29 -> cell shown.
    func testHideActionConditionNotMet() {
        let logic = visibilityLogic(action: "hide", conditions: [condition(field: ageColumnID, condition: "<", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let row = row(id: "row_1", cells: [nameColumnID: .string("Jeff"), ageColumnID: .double(29)])
        XCTAssertTrue(editor.shouldShowCell(row: row, column: statusColumn(in: cols), columns: cols),
                      "Status should show when age is not < 25 (age=29)")
    }

    // MARK: - Show action

    /// action=show: show status only when age > 25. Row age=29 -> shown.
    func testShowActionConditionMet() {
        let logic = visibilityLogic(action: "show", conditions: [condition(field: ageColumnID, condition: ">", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let row = row(id: "row_1", cells: [ageColumnID: .double(29)])
        XCTAssertTrue(editor.shouldShowCell(row: row, column: statusColumn(in: cols), columns: cols),
                      "Status should show when age > 25 (age=29)")
    }

    /// action=show: show status only when age > 25. Row age=23 -> hidden.
    func testShowActionConditionNotMet() {
        let logic = visibilityLogic(action: "show", conditions: [condition(field: ageColumnID, condition: ">", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let row = row(id: "row_1", cells: [ageColumnID: .double(23)])
        XCTAssertFalse(editor.shouldShowCell(row: row, column: statusColumn(in: cols), columns: cols),
                       "Status should hide when age is not > 25 (age=23)")
    }

    // MARK: - eval and / or

    func testEvalAndRequiresAllConditions() {
        let logic = visibilityLogic(action: "hide", conditions: [
            condition(field: ageColumnID, condition: "<", value: .double(25)),
            condition(field: nameColumnID, condition: "=", value: .string("John"))
        ], eval: "and")
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        // Only one condition met (age<25 true, name!=John) -> not hidden.
        let partial = row(id: "row_1", cells: [nameColumnID: .string("Jeff"), ageColumnID: .double(23)])
        XCTAssertTrue(editor.shouldShowCell(row: partial, column: statusColumn(in: cols), columns: cols),
                      "AND: partial match should not hide")
        // Both met -> hidden.
        let full = row(id: "row_2", cells: [nameColumnID: .string("John"), ageColumnID: .double(23)])
        XCTAssertFalse(editor.shouldShowCell(row: full, column: statusColumn(in: cols), columns: cols),
                       "AND: full match should hide")
    }

    func testEvalOrRequiresAnyCondition() {
        let logic = visibilityLogic(action: "hide", conditions: [
            condition(field: ageColumnID, condition: "<", value: .double(25)),
            condition(field: nameColumnID, condition: "=", value: .string("John"))
        ], eval: "or")
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        // One condition met (name=John) -> hidden.
        let one = row(id: "row_1", cells: [nameColumnID: .string("John"), ageColumnID: .double(40)])
        XCTAssertFalse(editor.shouldShowCell(row: one, column: statusColumn(in: cols), columns: cols),
                       "OR: any match should hide")
        // None met -> shown.
        let none = row(id: "row_2", cells: [nameColumnID: .string("Jeff"), ageColumnID: .double(40)])
        XCTAssertTrue(editor.shouldShowCell(row: none, column: statusColumn(in: cols), columns: cols),
                      "OR: no match should show")
    }

    // MARK: - No logic / independence

    func testColumnWithoutLogicAlwaysVisible() {
        let logic = visibilityLogic(action: "hide", conditions: [condition(field: ageColumnID, condition: "<", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let nameCol = cols.first { $0.id == nameColumnID }!
        let row = row(id: "row_1", cells: [ageColumnID: .double(10)])
        XCTAssertTrue(editor.shouldShowCell(row: row, column: nameCol, columns: cols),
                      "Column without cellVisibilityLogic is always visible")
    }

    /// Same column, different rows -> independent visibility.
    func testPerRowIndependence() {
        let logic = visibilityLogic(action: "hide", conditions: [condition(field: ageColumnID, condition: "<", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let statusCol = statusColumn(in: cols)
        let john = row(id: "row_1", cells: [ageColumnID: .double(23)])
        let jeff = row(id: "row_2", cells: [ageColumnID: .double(29)])
        XCTAssertFalse(editor.shouldShowCell(row: john, column: statusCol, columns: cols))
        XCTAssertTrue(editor.shouldShowCell(row: jeff, column: statusCol, columns: cols))
    }

    /// Evaluating visibility must not mutate the row's stored values.
    func testEvaluationPreservesRowValue() {
        let logic = visibilityLogic(action: "hide", conditions: [condition(field: ageColumnID, condition: "<", value: .double(25))])
        let cols = columns(statusLogic: logic)
        let editor = makeEditor(columns: cols)
        let row = row(id: "row_1", cells: [statusColumnID: .string("Active"), ageColumnID: .double(23)])
        _ = editor.shouldShowCell(row: row, column: statusColumn(in: cols), columns: cols)
        XCTAssertEqual(row.cells?[statusColumnID]?.text, "Active",
                       "Hidden cell keeps its stored value")
    }
}
