import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Tests for `requiredLogic` (fields, columns) and `cellRequiredLogic` (per-cell).
///
/// Semantics under test (the action only changes required-ness when its conditions match,
/// otherwise it falls back to the static `required` flag — matches the Kotlin/JS reference):
///   - action == "enforce" -> required when conditions match, else static `required`
///   - action == "unenforce" -> optional when conditions match, else static `required`
final class RequiredLogicTests: XCTestCase {
    let fileID = "file-1"
    let pageID = "page-1"
    let dropdownFieldID = "dropdown1"
    let textFieldID = "text1"
    let tableFieldID = "table1"
    let optYes = "opt-yes"
    let optNo = "opt-no"

    // Column ids for the table fixtures
    let textColumnID = "col-text"
    let ddColumnID = "col-dd"

    // Option ids for the sample-JSON scenario (page dropdown vs table dropdown are distinct).
    let pageYes = "page-yes"
    let pageNo = "page-no"
    let tblYes = "tbl-yes"
    let tblNo = "tbl-no"
    let pageDropdownID = "dropdownPage"
    let numberFieldID = "number1"

    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    // MARK: - Builders

    private func requiredLogic(action: String, condField: String, value: Any, condition: String = "=") -> [String: Any] {
        [
            "action": action,
            "eval": "and",
            "conditions": [[
                "file": fileID, "page": pageID, "field": condField,
                "condition": condition, "value": value, "_id": UUID().uuidString
            ]],
            "_id": UUID().uuidString
        ]
    }

    /// Builds requiredLogic with multiple conditions and an explicit eval ("and" / "or").
    private func requiredLogicMulti(action: String, eval: String, conditions: [(field: String, value: Any, condition: String)]) -> [String: Any] {
        [
            "action": action,
            "eval": eval,
            "conditions": conditions.map { c in
                ["file": fileID, "page": pageID, "field": c.field,
                 "condition": c.condition, "value": c.value, "_id": UUID().uuidString] as [String: Any]
            },
            "_id": UUID().uuidString
        ]
    }

    /// Builds cellRequiredLogic whose single condition references a SIBLING column (via the `column`
    /// key), resolved against the same row's cells — mirrors show/hide logic and the sample JSON.
    private func cellRequiredLogic(action: String, condColumn: String, value: Any, condition: String = "=") -> [String: Any] {
        [
            "action": action,
            "eval": "and",
            "conditions": [[
                "column": condColumn,
                "condition": condition, "value": value, "_id": UUID().uuidString
            ]],
            "_id": UUID().uuidString
        ]
    }

    /// A page with a text field (carrying requiredLogic) and a dropdown field it depends on.
    private func makeFieldLevelDoc(action: String, staticRequired: Bool, textValue: String?, dropdownValue: String) -> JoyDoc {
        var textField: [String: Any] = [
            "_id": textFieldID, "file": fileID, "type": "text", "required": staticRequired,
            "requiredLogic": requiredLogic(action: action, condField: dropdownFieldID, value: optYes)
        ]
        if let textValue = textValue { textField["value"] = textValue }

        return JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": fileID, "pageOrder": [pageID],
                "pages": [[
                    "_id": pageID,
                    "fieldPositions": [
                        ["_id": "fp-text", "field": textFieldID, "type": "text"],
                        ["_id": "fp-dd", "field": dropdownFieldID, "type": "dropdown"],
                    ],
                ]],
            ]],
            "fields": [
                textField,
                ["_id": dropdownFieldID, "file": fileID, "type": "dropdown", "value": dropdownValue,
                 "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]],
            ],
        ])
    }

    private func textStatus(_ editor: DocumentEditor) -> ValidationStatus? {
        editor.validate().fieldValidities.first(where: { $0.fieldId == textFieldID })?.status
    }

    // MARK: - Field-level enforce / unenforce

    func testFieldEnforce_conditionsMatch_makesRequired() {
        // dropdown = Yes -> enforce matches -> required -> empty text is invalid
        let editor = documentEditor(document: makeFieldLevelDoc(action: "enforce", staticRequired: false, textValue: nil, dropdownValue: optYes))
        XCTAssertEqual(textStatus(editor), .invalid)
    }

    func testFieldEnforce_conditionsDoNotMatch_makesOptional() {
        // dropdown = No -> enforce does not match -> optional -> empty text is valid
        let editor = documentEditor(document: makeFieldLevelDoc(action: "enforce", staticRequired: false, textValue: nil, dropdownValue: optNo))
        XCTAssertEqual(textStatus(editor), .valid)
    }

    func testFieldUnenforce_conditionsMatch_makesOptional() {
        // dropdown = Yes -> unenforce matches -> optional -> empty text is valid
        let editor = documentEditor(document: makeFieldLevelDoc(action: "unenforce", staticRequired: true, textValue: nil, dropdownValue: optYes))
        XCTAssertEqual(textStatus(editor), .valid)
    }

    func testFieldUnenforce_conditionsDoNotMatch_fallsBackToStatic() {
        // dropdown = No -> unenforce does not match -> falls back to static required:false -> optional -> empty text is valid
        let editor = documentEditor(document: makeFieldLevelDoc(action: "unenforce", staticRequired: false, textValue: nil, dropdownValue: optNo))
        XCTAssertEqual(textStatus(editor), .valid)
    }

    func testFieldEnforce_conditionsDoNotMatch_fallsBackToStaticRequiredTrue() {
        // static required = true, enforce does not match -> falls back to static required:true -> required -> empty text is invalid.
        let editor = documentEditor(document: makeFieldLevelDoc(action: "enforce", staticRequired: true, textValue: nil, dropdownValue: optNo))
        XCTAssertEqual(textStatus(editor), .invalid)
    }

    // MARK: - Dynamic re-evaluation

    func testFieldEnforce_flipsWhenDependencyChanges() {
        // Start with dropdown = No -> optional -> valid.
        let editor = documentEditor(document: makeFieldLevelDoc(action: "enforce", staticRequired: false, textValue: nil, dropdownValue: optNo))
        XCTAssertEqual(textStatus(editor), .valid)
        XCTAssertFalse(editor.isFieldRequired(fieldID: textFieldID))

        // Change dropdown to Yes -> enforce now matches -> required -> invalid.
        let fi = FieldIdentifier(fieldID: dropdownFieldID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: fi, updateValue: .string(optYes)), fieldIdentifier: fi)

        XCTAssertTrue(editor.isFieldRequired(fieldID: textFieldID))
        XCTAssertEqual(textStatus(editor), .invalid)
    }

    // MARK: - Column-level requiredLogic (page-field conditions, column-wide)

    private func makeTableDoc(
        textColumn: [String: Any],
        rows: [[String: Any]],
        includePageDropdown: Bool,
        dropdownValue: String,
        fieldRequiredLogic: [String: Any]? = nil
    ) -> JoyDoc {
        var fieldPositions: [[String: Any]] = [["_id": "fp-table", "field": tableFieldID, "type": "table"]]
        var tableField: [String: Any] = [
            "_id": tableFieldID, "file": fileID, "type": "table", "required": false,
            "tableColumns": [
                textColumn,
                ["_id": ddColumnID, "type": "dropdown", "title": "DD",
                 "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]],
            ],
            "tableColumnOrder": [textColumnID, ddColumnID],
            "rowOrder": rows.compactMap { $0["_id"] as? String },
            "value": rows,
        ]
        if let fieldRequiredLogic = fieldRequiredLogic { tableField["requiredLogic"] = fieldRequiredLogic }
        var fields: [[String: Any]] = [tableField]

        if includePageDropdown {
            fieldPositions.append(["_id": "fp-dd", "field": dropdownFieldID, "type": "dropdown"])
            fields.append(["_id": dropdownFieldID, "file": fileID, "type": "dropdown", "value": dropdownValue,
                           "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]])
        }

        return JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": fileID, "pageOrder": [pageID],
                "pages": [["_id": pageID, "fieldPositions": fieldPositions]],
            ]],
            "fields": fields,
        ])
    }

    private func cellStatus(_ editor: DocumentEditor, rowId: String, columnId: String) -> ValidationStatus? {
        editor.validate().fieldValidities
            .first(where: { $0.fieldId == tableFieldID })?
            .rowValidities?.first(where: { $0.rowId == rowId })?
            .cellValidities.first(where: { $0.columnId == columnId })?.status
    }

    private func tableViewModel(_ editor: DocumentEditor) -> TableViewModel {
        let field = editor.field(fieldID: tableFieldID)
        let header = FieldHeaderModel(
            title: field?.title,
            required: field?.required,
            tipDescription: field?.tipDescription,
            tipTitle: field?.tipTitle,
            tipVisible: field?.tipVisible,
            visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields
        )
        let model = TableDataModel(
            fieldHeaderModel: header,
            mode: .fill,
            documentEditor: editor,
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        )!
        return TableViewModel(tableDataModel: model)
    }

    private func waitForMainQueue(file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for change delivery")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1, enforceOrder: true)
    }

    private func rowChange(target: String, rowID: String, cells: [String: Any]? = nil) -> Change {
        var payload: [String: Any] = ["rowId": rowID]
        if let cells {
            payload["row"] = ["_id": rowID, "cells": cells] as [String: Any]
        }
        return Change(dictionary: [
            "target": target,
            "fieldId": tableFieldID,
            "pageId": pageID,
            "fileId": fileID,
            "change": payload
        ])
    }

    private func fieldUpdate(fieldID: String, value: Any) -> Change {
        Change(dictionary: [
            "target": "field.update",
            "fieldId": fieldID,
            "pageId": pageID,
            "fileId": fileID,
            "change": ["value": value]
        ])
    }

    func testColumnEnforce_appliesToAllCells() {
        // Column text requiredLogic enforce on page dropdown = Yes. Two rows, both empty text cells.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let rows: [[String: Any]] = [
            ["_id": "row-1", "cells": [textColumnID: "", ddColumnID: optNo]],
            ["_id": "row-2", "cells": [textColumnID: "", ddColumnID: optYes]],
        ]

        // Page dropdown = Yes -> column required -> both empty cells invalid
        let matchEditor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optYes))
        XCTAssertEqual(cellStatus(matchEditor, rowId: "row-1", columnId: textColumnID), .invalid)
        XCTAssertEqual(cellStatus(matchEditor, rowId: "row-2", columnId: textColumnID), .invalid)

        // Page dropdown = No -> column optional -> both empty cells valid
        let noMatchEditor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optNo))
        XCTAssertEqual(cellStatus(noMatchEditor, rowId: "row-1", columnId: textColumnID), .valid)
        XCTAssertEqual(cellStatus(noMatchEditor, rowId: "row-2", columnId: textColumnID), .valid)
    }

    // MARK: - Cell-level cellRequiredLogic (sibling-cell conditions, per-row)

    func testCellRequiredLogic_resolvesAgainstSiblingCellPerRow() {
        // text column cellRequiredLogic enforce referencing sibling dropdown column = Yes.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: ddColumnID, value: optYes)
        ]
        let rows: [[String: Any]] = [
            ["_id": "row-match", "cells": [textColumnID: "", ddColumnID: optYes]],   // sibling matches -> required -> invalid
            ["_id": "row-nomatch", "cells": [textColumnID: "", ddColumnID: optNo]],  // sibling no match -> optional -> valid
        ]
        let editor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: false, dropdownValue: optNo))

        XCTAssertEqual(cellStatus(editor, rowId: "row-match", columnId: textColumnID), .invalid)
        XCTAssertEqual(cellStatus(editor, rowId: "row-nomatch", columnId: textColumnID), .valid)
    }

    // MARK: - Required behavior through public row workflows

    func testExternalRowUpdateImmediatelyReevaluatesRequiredCells() {
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: ddColumnID, value: optYes)
        ]
        let rows: [[String: Any]] = [[
            "_id": "row-1",
            "cells": [textColumnID: "", ddColumnID: optNo]
        ]]
        let editor = documentEditor(document: makeTableDoc(
            textColumn: textColumn,
            rows: rows,
            includePageDropdown: false,
            dropdownValue: optNo
        ))
        let viewModel = tableViewModel(editor)

        guard let initialRow = viewModel.rowElement(forRowID: "row-1") else {
            XCTFail("The table must render row row-1")
            return
        }
        XCTAssertFalse(editor.isCellRequired(
            columnID: textColumnID,
            fieldID: tableFieldID,
            row: initialRow
        ), "The public API reports the explanation optional before the controlling answer changes")
        XCTAssertFalse(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"),
                       "The rendered table reports the explanation optional before the controlling answer changes")
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .valid,
                       "An explanation is optional before the controlling answer changes")

        editor.change(changes: [rowChange(
            target: "field.value.rowUpdate",
            rowID: "row-1",
            cells: [ddColumnID: optYes]
        )])
        waitForMainQueue()

        guard let updatedRow = viewModel.rowElement(forRowID: "row-1") else {
            XCTFail("The updated table must retain row row-1")
            return
        }
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: updatedRow),
                      "The public API must apply the required rule after an external update")
        XCTAssertTrue(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"),
                      "The rendered table must apply the same required rule as an on-screen edit")
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid,
                       "The newly required empty explanation must block validation immediately")
    }

    func testExternalTablePartialUpdateMakesOnlyTargetRowOptionalAndPreservesOtherCells() {
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: ddColumnID, value: optYes)
        ]
        let editor = documentEditor(document: makeTableDoc(
            textColumn: textColumn,
            rows: [
                ["_id": "row-1", "cells": [textColumnID: "Keep explanation", ddColumnID: optYes]],
                ["_id": "row-2", "cells": [textColumnID: "", ddColumnID: optYes]]
            ],
            includePageDropdown: false,
            dropdownValue: optNo
        ))
        let viewModel = tableViewModel(editor)

        guard let initialRow1 = viewModel.rowElement(forRowID: "row-1"),
              let initialRow2 = viewModel.rowElement(forRowID: "row-2") else {
            XCTFail("The table must render both rows")
            return
        }
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: initialRow1))
        XCTAssertTrue(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"))
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: initialRow2))
        XCTAssertTrue(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-2"))

        editor.change(changes: [rowChange(
            target: "field.value.rowUpdate",
            rowID: "row-1",
            cells: [ddColumnID: optNo]
        )])
        waitForMainQueue()

        guard let updatedRow1 = viewModel.rowElement(forRowID: "row-1"),
              let updatedRow2 = viewModel.rowElement(forRowID: "row-2") else {
            XCTFail("The table must retain both rows")
            return
        }
        XCTAssertEqual(updatedRow1.cells?[ddColumnID]?.text, optNo,
                       "Public document stores the changed decision")
        XCTAssertEqual(updatedRow1.cells?[textColumnID]?.text, "Keep explanation",
                       "A partial update must preserve an omitted explanation")
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == "row-1" })?
                .cells.first(where: { $0.data.id == textColumnID })?.data.title,
            "Keep explanation",
            "Rendered table keeps the omitted explanation"
        )
        XCTAssertFalse(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: updatedRow1),
                       "Public API makes the target explanation optional")
        XCTAssertFalse(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"),
                       "Rendered table makes the target explanation optional")
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: updatedRow2),
                      "Public API keeps the untouched row required")
        XCTAssertTrue(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-2"),
                      "Rendered table keeps the untouched row required")
    }

    func testRequiredRulesFollowRowsThroughAddDuplicateAndDelete() {
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: ddColumnID, value: optYes)
        ]
        let rows: [[String: Any]] = [[
            "_id": "original-row",
            "cells": [textColumnID: "", ddColumnID: optNo]
        ]]
        let editor = documentEditor(document: makeTableDoc(
            textColumn: textColumn,
            rows: rows,
            includePageDropdown: false,
            dropdownValue: optNo
        ))
        let viewModel = tableViewModel(editor)

        viewModel.addRow(
            with: "added-row",
            and: [textColumnID: .string(""), ddColumnID: .string(optYes)],
            shouldSendEvent: false
        )
        let addedRow = viewModel.rowElement(forRowID: "added-row")!
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: addedRow),
                      "A newly added row must receive required rules based on its own answers")
        XCTAssertEqual(cellStatus(editor, rowId: "added-row", columnId: textColumnID), .invalid,
                       "A newly added row with a missing required answer must be invalid")

        let rowIDsBeforeDuplicate = Set(viewModel.tableDataModel.rowOrder)
        viewModel.tableDataModel.selectedRows = ["added-row"]
        viewModel.duplicateRow()
        let duplicatedRowID = Set(viewModel.tableDataModel.rowOrder)
            .subtracting(rowIDsBeforeDuplicate)
            .first
        XCTAssertNotNil(duplicatedRowID, "Duplicating a row must add one new row")
        if let duplicatedRowID,
           let duplicatedRow = viewModel.rowElement(forRowID: duplicatedRowID) {
            XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: duplicatedRow),
                          "A duplicated row must preserve the required behavior of the copied answers")
            XCTAssertEqual(cellStatus(editor, rowId: duplicatedRowID, columnId: textColumnID), .invalid,
                           "A duplicated empty required answer must remain invalid")
        }

        editor.change(changes: [rowChange(target: "field.value.rowDelete", rowID: "added-row")])
        XCTAssertFalse(viewModel.tableDataModel.rowOrder.contains("added-row"),
                       "Deleting a row must remove it from the rendered table")
        XCTAssertFalse(editor.field(fieldID: tableFieldID)?.rowOrder?.contains("added-row") ?? true,
                       "The public document must remove the deleted row from table order")
        XCTAssertFalse(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: addedRow),
                       "A deleted row must not retain required state")
    }

    // MARK: - Cell logic with mixed sibling-column + page-field conditions

    /// A table whose text column carries a `cellRequiredLogic` mixing a sibling-column condition
    /// (`column`) and a page-level field condition (`field`), plus a page number field it depends on.
    private func makeMixedCellDoc(
        cellAction: String,
        cellEval: String,
        siblingValue: String,
        conditionSiblingValue: String,
        pageNumberValue: Double,
        conditionPageNumberValue: Double,
        columnRequiredLogic: [String: Any]? = nil,
        columnStaticRequired: Bool = false,
        includePageDropdown: Bool = false,
        dropdownValue: String = ""
    ) -> JoyDoc {
        let numberFieldID = "number1"
        var textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "required": columnStaticRequired,
            "cellRequiredLogic": [
                "action": cellAction, "eval": cellEval, "_id": UUID().uuidString,
                "conditions": [
                    // sibling-column condition (resolved against the row's own cells)
                    ["column": ddColumnID, "condition": "=", "value": conditionSiblingValue, "_id": UUID().uuidString],
                    // page-field condition (resolved against the document)
                    ["field": numberFieldID, "condition": "=", "value": conditionPageNumberValue, "_id": UUID().uuidString],
                ] as [[String: Any]],
            ] as [String: Any],
        ]
        if let columnRequiredLogic = columnRequiredLogic { textColumn["requiredLogic"] = columnRequiredLogic }

        var fieldPositions: [[String: Any]] = [
            ["_id": "fp-table", "field": tableFieldID, "type": "table"],
            ["_id": "fp-num", "field": numberFieldID, "type": "number"],
        ]
        var fields: [[String: Any]] = [
            [
                "_id": tableFieldID, "file": fileID, "type": "table", "required": false,
                "tableColumns": [
                    textColumn,
                    ["_id": ddColumnID, "type": "text", "title": "Flag"],
                ] as [[String: Any]],
                "tableColumnOrder": [textColumnID, ddColumnID],
                "rowOrder": ["row-1"],
                "value": [["_id": "row-1", "cells": [textColumnID: "", ddColumnID: siblingValue]]] as [[String: Any]],
            ],
            ["_id": numberFieldID, "file": fileID, "type": "number", "value": pageNumberValue],
        ]
        if includePageDropdown {
            fieldPositions.append(["_id": "fp-dd", "field": dropdownFieldID, "type": "dropdown"])
            fields.append(["_id": dropdownFieldID, "file": fileID, "type": "dropdown", "value": dropdownValue,
                           "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]])
        }

        return JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": fileID, "pageOrder": [pageID],
                "pages": [["_id": pageID, "fieldPositions": fieldPositions]],
            ]],
            "fields": fields,
        ])
    }

    func testCellRequiredLogic_mixedSiblingAndPageField_bothMatch_makesRequired() {
        // enforce AND: sibling flag == "yes" AND page number1 == 100. Both true -> required -> empty cell invalid.
        let editor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "and",
            siblingValue: "yes", conditionSiblingValue: "yes",
            pageNumberValue: 100, conditionPageNumberValue: 100
        ))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    func testCellRequiredLogic_mixedSiblingAndPageField_pageFieldMissesUnderAnd_fallsBack() {
        // enforce AND: sibling flag == "yes" (true) AND page number1 == 100 (false, is 10).
        // AND fails -> falls back to column base (no column logic, static false) -> optional -> valid.
        let editor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "and",
            siblingValue: "yes", conditionSiblingValue: "yes",
            pageNumberValue: 10, conditionPageNumberValue: 100
        ))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .valid)
    }

    func testCellRequiredLogic_mixedConditions_fallBackToColumnStaticRequired() {
        // Mirrors the sample JSON: cell enforce-AND fails (number1 != 100), so we fall back to the
        // column base. Column requiredLogic is unenforce on page dropdown = Yes but dropdown = No, so
        // it also fails and falls back to the column's static required:true -> required -> invalid.
        let editor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "and",
            siblingValue: "No", conditionSiblingValue: "No",
            pageNumberValue: 10, conditionPageNumberValue: 100,
            columnRequiredLogic: requiredLogic(action: "unenforce", condField: dropdownFieldID, value: optYes),
            columnStaticRequired: true,
            includePageDropdown: true, dropdownValue: optNo
        ))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    func testCellRequiredLogic_pageFieldDependency_refreshesOwningTable() {
        // A change to the page field referenced by cellRequiredLogic must mark the table for refresh.
        let editor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "and",
            siblingValue: "yes", conditionSiblingValue: "yes",
            pageNumberValue: 10, conditionPageNumberValue: 100
        ))
        let refreshed = editor.requiredLogicHandler.fieldsNeedsToBeRefreshed(fieldID: "number1")
        XCTAssertTrue(refreshed.contains(tableFieldID))
    }

    func testCellRequiredLogic_mixedConditions_evalOr_anyMatches() {
        // enforce OR: sibling flag == "yes" (false, is "no") OR page number1 == 100 (true) -> matched -> required.
        let matchEditor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "or",
            siblingValue: "no", conditionSiblingValue: "yes",
            pageNumberValue: 100, conditionPageNumberValue: 100
        ))
        XCTAssertEqual(cellStatus(matchEditor, rowId: "row-1", columnId: textColumnID), .invalid)

        // enforce OR: neither matches -> falls back to column base (static false) -> optional.
        let noMatchEditor = documentEditor(document: makeMixedCellDoc(
            cellAction: "enforce", cellEval: "or",
            siblingValue: "no", conditionSiblingValue: "yes",
            pageNumberValue: 10, conditionPageNumberValue: 100
        ))
        XCTAssertEqual(cellStatus(noMatchEditor, rowId: "row-1", columnId: textColumnID), .valid)
    }

    func testCellRequiredLogic_unenforce_matchedMakesOptional_elseFallsBackToColumnStatic() {
        // Column is statically required. Cell unenforce AND [ sibling "yes", page number1 == 100 ].
        // Both match -> unenforce -> optional -> valid.
        let optionalEditor = documentEditor(document: makeMixedCellDoc(
            cellAction: "unenforce", cellEval: "and",
            siblingValue: "yes", conditionSiblingValue: "yes",
            pageNumberValue: 100, conditionPageNumberValue: 100,
            columnStaticRequired: true
        ))
        XCTAssertEqual(cellStatus(optionalEditor, rowId: "row-1", columnId: textColumnID), .valid)

        // One condition fails -> unenforce doesn't match -> falls back to column static required:true -> invalid.
        let requiredEditor = documentEditor(document: makeMixedCellDoc(
            cellAction: "unenforce", cellEval: "and",
            siblingValue: "yes", conditionSiblingValue: "yes",
            pageNumberValue: 10, conditionPageNumberValue: 100,
            columnStaticRequired: true
        ))
        XCTAssertEqual(cellStatus(requiredEditor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    // MARK: - Sample JSON use case (mixed cell logic + column unenforce + static required)

    /// Reproduces the provided template: `text1` has static `required:true`, column `requiredLogic`
    /// `unenforce` (page dropdown == Yes), and `cellRequiredLogic` `enforce` AND
    /// [ sibling `dropdown1` == "No", page `number1` == 100 ]. Three rows (row-1 has dropdown = No).
    private func makeSampleDoc(pageDropdownValue: String, number1Value: Double) -> JoyDoc {
        let textCol: [String: Any] = [
            "_id": "text1", "type": "text", "title": "Text Column", "required": true,
            "requiredLogic": [
                "action": "unenforce", "eval": "and", "_id": UUID().uuidString,
                "conditions": [["field": pageDropdownID, "condition": "=", "value": pageYes, "_id": UUID().uuidString]] as [[String: Any]],
            ] as [String: Any],
            "cellRequiredLogic": [
                "action": "enforce", "eval": "and", "_id": UUID().uuidString,
                "conditions": [
                    ["column": "dropdown1", "condition": "=", "value": tblNo, "_id": UUID().uuidString],
                    ["field": numberFieldID, "condition": "=", "value": number1Value, "_id": UUID().uuidString],
                ] as [[String: Any]],
            ] as [String: Any],
        ]
        let ddCol: [String: Any] = [
            "_id": "dropdown1", "type": "dropdown", "title": "Dropdown Column",
            "options": [["_id": tblYes, "value": "Yes"], ["_id": tblNo, "value": "No"]],
        ]
        let rows: [[String: Any]] = [
            ["_id": "row-1", "cells": ["dropdown1": tblNo]],
            ["_id": "row-2", "cells": [:]],
            ["_id": "row-3", "cells": [:]],
        ]
        return JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": fileID, "pageOrder": [pageID],
                "pages": [["_id": pageID, "fieldPositions": [
                    ["_id": "fp-table", "field": tableFieldID, "type": "table"],
                    ["_id": "fp-dd", "field": pageDropdownID, "type": "dropdown"],
                    ["_id": "fp-num", "field": numberFieldID, "type": "number"],
                ]]],
            ]],
            "fields": [
                ["_id": tableFieldID, "file": fileID, "type": "table", "required": false,
                 "tableColumns": [textCol, ddCol],
                 "tableColumnOrder": ["text1", "dropdown1"],
                 "rowOrder": ["row-1", "row-2", "row-3"],
                 "value": rows],
                ["_id": pageDropdownID, "file": fileID, "type": "dropdown", "value": pageDropdownValue,
                 "options": [["_id": pageYes, "value": "Yes"], ["_id": pageNo, "value": "No"]]],
                ["_id": numberFieldID, "file": fileID, "type": "number", "value": number1Value],
            ],
        ])
    }

    func testSampleJSON_text1RequiredInAllThreeRows() {
        // page dropdown = No, number1 = 100. Column unenforce doesn't match (dropdown != Yes) ->
        // column-effective falls back to static required:true.
        let editor = documentEditor(document: makeSampleDoc(pageDropdownValue: pageNo, number1Value: 100))
        XCTAssertTrue(editor.isColumnRequired(columnID: "text1", fieldID: tableFieldID))

        // row-1: cell enforce matches (sibling No + number 100) -> required.
        // row-2 / row-3: cell not matched (dropdown empty) -> fall back to column-effective (required).
        for rowId in ["row-1", "row-2", "row-3"] {
            XCTAssertEqual(cellStatus(editor, rowId: rowId, columnId: "text1"), .invalid,
                           "text1 should be required (empty -> invalid) in \(rowId)")
        }
    }

    func testSampleJSON_dynamicFlipAcrossResolutionOrder() {
        let editor = documentEditor(document: makeSampleDoc(pageDropdownValue: pageNo, number1Value: 100))
        // Baseline: every row required.
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: "text1"), .invalid)
        XCTAssertEqual(cellStatus(editor, rowId: "row-2", columnId: "text1"), .invalid)

        // Flip page dropdown -> Yes: column unenforce now matches -> column-effective becomes optional.
        let ddFI = FieldIdentifier(fieldID: pageDropdownID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: ddFI, updateValue: .string(pageYes)), fieldIdentifier: ddFI)
        // row-1: cell still matches (sibling No + number 100) -> required.
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: "text1"), .invalid)
        // row-2: cell not matched -> falls back to the now-optional column-effective -> valid.
        XCTAssertEqual(cellStatus(editor, rowId: "row-2", columnId: "text1"), .valid)

        // Change number1 -> 10: row-1 cell AND now fails -> falls back to optional column -> valid.
        let numFI = FieldIdentifier(fieldID: numberFieldID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: numFI, updateValue: .double(10)), fieldIdentifier: numFI)
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: "text1"), .valid)
    }

    // MARK: - Collection: mixed sibling + page-field cell logic, nested own-columns

    func testCollection_cellRequiredLogic_mixedSiblingAndPageField() {
        // Root text cellRequiredLogic enforce AND [ sibling rootDd == Yes, page dropdown == Yes ].
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Text",
            "cellRequiredLogic": [
                "action": "enforce", "eval": "and", "_id": UUID().uuidString,
                "conditions": [
                    ["column": rootDdCol, "condition": "=", "value": optYes, "_id": UUID().uuidString],
                    ["field": dropdownFieldID, "condition": "=", "value": optYes, "_id": UUID().uuidString],
                ] as [[String: Any]],
            ] as [String: Any],
        ]
        let rootDd: [String: Any] = ["_id": rootDdCol, "type": "dropdown", "title": "DD",
                                     "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]]
        let rows: [[String: Any]] = [["_id": "root-1", "cells": [rootTextCol: "", rootDdCol: optYes]]]

        // page dropdown = Yes -> both conditions match -> required.
        let matchEditor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText, rootDd], nestedColumns: minimalNestedColumns, rootRows: rows, includePageDropdown: true, dropdownValue: optYes))
        XCTAssertTrue(matchEditor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID, row: rootRow(matchEditor, id: "root-1")!))

        // page dropdown = No -> page half of the AND fails -> falls back to column base (static false) -> optional.
        let noMatchEditor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText, rootDd], nestedColumns: minimalNestedColumns, rootRows: rows, includePageDropdown: true, dropdownValue: optNo))
        XCTAssertFalse(noMatchEditor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID, row: rootRow(noMatchEditor, id: "root-1")!))
    }

    func testCollection_nestedCellLogic_referencesOwnColumnsNotParent() {
        // Both root and nested schemas carry a column with id `shared`. The nested notes column's
        // cellRequiredLogic references `shared` and must resolve against the NESTED row's own cell,
        // never the parent/root cell. Root's `shared` is empty in both cases, so a required result
        // can only come from the nested row's own value.
        let sharedID = "shared"
        let rootShared: [String: Any] = ["_id": sharedID, "type": "text", "title": "Root Shared"]
        let nestedShared: [String: Any] = ["_id": sharedID, "type": "text", "title": "Child Shared"]
        let nestedNotes: [String: Any] = [
            "_id": childNotesCol, "type": "text", "title": "Notes",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: sharedID, value: "", condition: "*=")
        ]
        let rootRows: [[String: Any]] = [[
            "_id": "root-1", "cells": [sharedID: ""],
            "children": [nestedSchemaID: ["value": [
                ["_id": "child-filled", "cells": [sharedID: "hi", childNotesCol: ""]],
                ["_id": "child-empty", "cells": [sharedID: "", childNotesCol: ""]],
            ]]],
        ]]
        let editor = documentEditor(document: makeCollectionDoc(rootColumns: [rootShared], nestedColumns: [nestedShared, nestedNotes], rootRows: rootRows))

        // Nested row whose OWN `shared` is filled -> notes required (proves it read the nested cell).
        XCTAssertTrue(editor.isCellRequired(columnID: childNotesCol, fieldID: collectionFieldID, schemaKey: nestedSchemaID, row: nestedRow(editor, parentID: "root-1", childID: "child-filled")!))
        // Nested row whose own `shared` is empty -> notes not required.
        XCTAssertFalse(editor.isCellRequired(columnID: childNotesCol, fieldID: collectionFieldID, schemaKey: nestedSchemaID, row: nestedRow(editor, parentID: "root-1", childID: "child-empty")!))
    }

    // MARK: - Table: additional column / cell coverage

    func testColumnUnenforce_conditionsMatch_makesOptional() {
        // Column is statically required; unenforce turns it optional only when the page dropdown = Yes.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text", "required": true,
            "requiredLogic": requiredLogic(action: "unenforce", condField: dropdownFieldID, value: optYes)
        ]
        let rows: [[String: Any]] = [["_id": "row-1", "cells": [textColumnID: "", ddColumnID: optNo]]]

        // dropdown = Yes -> unenforce matches -> optional -> empty cell valid
        let optionalEditor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optYes))
        XCTAssertEqual(cellStatus(optionalEditor, rowId: "row-1", columnId: textColumnID), .valid)

        // dropdown = No -> unenforce no match -> static required stays -> empty cell invalid
        let requiredEditor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optNo))
        XCTAssertEqual(cellStatus(requiredEditor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    func testColumnEnforce_cellFilled_isValid() {
        // Column required (enforce matches) but the cell is filled -> valid.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let rows: [[String: Any]] = [["_id": "row-1", "cells": [textColumnID: "filled", ddColumnID: optYes]]]
        let editor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optYes))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .valid)
    }

    func testColumnEnforce_flipsWhenPageDependencyChanges() {
        // Column enforce on page dropdown = Yes. Start with No -> optional; flip to Yes -> required.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let rows: [[String: Any]] = [["_id": "row-1", "cells": [textColumnID: "", ddColumnID: optNo]]]
        let editor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optNo))

        XCTAssertFalse(editor.isColumnRequired(columnID: textColumnID, fieldID: tableFieldID))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .valid)

        let fi = FieldIdentifier(fieldID: dropdownFieldID)
        editor.updateField(event: FieldChangeData(fieldIdentifier: fi, updateValue: .string(optYes)), fieldIdentifier: fi)

        XCTAssertTrue(editor.isColumnRequired(columnID: textColumnID, fieldID: tableFieldID))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    func testExternalPageFieldUpdateReevaluatesTableRequiredCells() {
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Explanation",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let editor = documentEditor(document: makeTableDoc(
            textColumn: textColumn,
            rows: [["_id": "row-1", "cells": [textColumnID: "", ddColumnID: optNo]]],
            includePageDropdown: true,
            dropdownValue: optNo
        ))
        let viewModel = tableViewModel(editor)
        guard let initialRow = viewModel.rowElement(forRowID: "row-1") else {
            XCTFail("The table must render row row-1")
            return
        }

        XCTAssertFalse(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: initialRow),
                       "Public API starts with the explanation optional")
        XCTAssertFalse(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"),
                       "Rendered table starts with the explanation optional")

        editor.change(changes: [fieldUpdate(fieldID: dropdownFieldID, value: optYes)])

        guard let updatedRow = viewModel.rowElement(forRowID: "row-1") else {
            XCTFail("The table must retain row row-1")
            return
        }
        XCTAssertEqual(editor.field(fieldID: dropdownFieldID)?.value?.text, optYes,
                       "Public document stores the external page-field value")
        XCTAssertTrue(editor.isCellRequired(columnID: textColumnID, fieldID: tableFieldID, row: updatedRow),
                      "Public API requires the explanation after the page answer changes")
        XCTAssertTrue(viewModel.isCellRequired(columnID: textColumnID, rowID: "row-1"),
                      "Rendered table requires the explanation after the page answer changes")
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid,
                       "The newly required empty explanation blocks validation")
    }

    func testCellLogicTakesPrecedenceOverColumnLogic_table() {
        // Column requiredLogic says optional (page dropdown = No), but cellRequiredLogic says required
        // (sibling dd cell = Yes). Cell logic wins -> empty cell invalid.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes),
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: ddColumnID, value: optYes)
        ]
        let rows: [[String: Any]] = [["_id": "row-1", "cells": [textColumnID: "", ddColumnID: optYes]]]
        let editor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: true, dropdownValue: optNo))

        XCTAssertFalse(editor.isColumnRequired(columnID: textColumnID, fieldID: tableFieldID))
        XCTAssertEqual(cellStatus(editor, rowId: "row-1", columnId: textColumnID), .invalid)
    }

    func testTableFieldLevelRequired_refreshesWhenTriggerChanges() {
        // Regression: field-level requiredLogic on a table must be refreshed when its trigger changes.
        let textColumn: [String: Any] = ["_id": textColumnID, "type": "text", "title": "Text"]
        let editor = documentEditor(document: makeTableDoc(
            textColumn: textColumn, rows: [], includePageDropdown: true, dropdownValue: optNo,
            fieldRequiredLogic: requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ))
        XCTAssertFalse(editor.isFieldRequired(fieldID: tableFieldID))

        // Mutate the trigger without triggering refresh, then ask which fields need refreshing.
        var dropdown = editor.field(fieldID: dropdownFieldID)
        dropdown?.value = .string(optYes)
        editor.updateField(field: dropdown)

        let refreshed = editor.requiredLogicHandler.fieldsNeedsToBeRefreshed(fieldID: dropdownFieldID)
        XCTAssertTrue(refreshed.contains(tableFieldID))
        XCTAssertTrue(editor.isFieldRequired(fieldID: tableFieldID))
    }

    // MARK: - eval "or"

    func testFieldEnforce_evalOr_anyConditionMatches() {
        let dropdown2ID = "dropdown2"
        func doc(dd1: String, dd2: String) -> JoyDoc {
            JoyDoc(dictionary: [
                "_id": "doc-1",
                "files": [[
                    "_id": fileID, "pageOrder": [pageID],
                    "pages": [["_id": pageID, "fieldPositions": [
                        ["_id": "fp-text", "field": textFieldID, "type": "text"],
                        ["_id": "fp-dd", "field": dropdownFieldID, "type": "dropdown"],
                        ["_id": "fp-dd2", "field": dropdown2ID, "type": "dropdown"],
                    ]]],
                ]],
                "fields": [
                    ["_id": textFieldID, "file": fileID, "type": "text", "required": false,
                     "requiredLogic": requiredLogicMulti(action: "enforce", eval: "or", conditions: [
                        (field: dropdownFieldID, value: optYes, condition: "="),
                        (field: dropdown2ID, value: optYes, condition: "="),
                     ])],
                    ["_id": dropdownFieldID, "file": fileID, "type": "dropdown", "value": dd1,
                     "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]],
                    ["_id": dropdown2ID, "file": fileID, "type": "dropdown", "value": dd2,
                     "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]],
                ],
            ])
        }
        // One condition matches (dd2 = Yes) -> or -> required -> empty text invalid
        XCTAssertEqual(textStatus(documentEditor(document: doc(dd1: optNo, dd2: optYes))), .invalid)
        // Neither matches -> optional -> empty text valid
        XCTAssertEqual(textStatus(documentEditor(document: doc(dd1: optNo, dd2: optNo))), .valid)
    }

    // MARK: - Collection: requiredLogic / cellRequiredLogic

    let collectionFieldID = "collection1"
    let rootSchemaID = "rootSchema"
    let nestedSchemaID = "childSchema"
    let rootTextCol = "root-text"
    let rootDdCol = "root-dd"
    let childTextCol = "child-text"
    let childNotesCol = "child-notes"

    private func makeCollectionDoc(
        rootColumns: [[String: Any]],
        nestedColumns: [[String: Any]],
        rootRows: [[String: Any]],
        fieldRequiredLogic: [String: Any]? = nil,
        includePageDropdown: Bool = false,
        dropdownValue: String = ""
    ) -> JoyDoc {
        var fieldPositions: [[String: Any]] = [["_id": "fp-collection", "field": collectionFieldID, "type": "collection"]]
        var collectionField: [String: Any] = [
            "_id": collectionFieldID, "file": fileID, "type": "collection", "required": false,
            "schema": [
                rootSchemaID: ["title": "Root", "root": true, "children": [nestedSchemaID], "tableColumns": rootColumns] as [String: Any],
                nestedSchemaID: ["title": "Child", "children": [], "tableColumns": nestedColumns] as [String: Any],
            ],
            "value": rootRows,
        ]
        if let fieldRequiredLogic = fieldRequiredLogic { collectionField["requiredLogic"] = fieldRequiredLogic }
        var fields: [[String: Any]] = [collectionField]

        if includePageDropdown {
            fieldPositions.append(["_id": "fp-dd", "field": dropdownFieldID, "type": "dropdown"])
            fields.append(["_id": dropdownFieldID, "file": fileID, "type": "dropdown", "value": dropdownValue,
                           "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]])
        }

        return JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": fileID, "pageOrder": [pageID],
                "pages": [["_id": pageID, "fieldPositions": fieldPositions]],
            ]],
            "fields": fields,
        ])
    }

    private func rootRow(_ editor: DocumentEditor, id: String) -> ValueElement? {
        editor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == id })
    }

    private func nestedRow(_ editor: DocumentEditor, parentID: String, childID: String) -> ValueElement? {
        rootRow(editor, id: parentID)?.childrens?[nestedSchemaID]?.valueToValueElements?.first(where: { $0.id == childID })
    }

    private var minimalNestedColumns: [[String: Any]] {
        [["_id": childTextCol, "type": "text", "title": "Child Text"]]
    }

    private func collectionViewModel(_ editor: DocumentEditor) -> CollectionViewModel {
        let field = editor.field(fieldID: collectionFieldID)
        let header = FieldHeaderModel(
            title: field?.title,
            required: field?.required,
            tipDescription: field?.tipDescription,
            tipTitle: field?.tipTitle,
            tipVisible: field?.tipVisible,
            visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields
        )
        let model = TableDataModel(
            fieldHeaderModel: header,
            mode: .fill,
            documentEditor: editor,
            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID)
        )!
        return CollectionViewModel(tableDataModel: model)
    }

    private func waitForCollectionToLoad(
        _ viewModel: CollectionViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let deadline = Date().addingTimeInterval(2)
        while viewModel.isLoading && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        XCTAssertFalse(viewModel.isLoading, "Collection did not finish loading", file: file, line: line)
    }

    private func collectionRowUpdate(rowID: String, cells: [String: Any], schemaID: String? = nil) -> Change {
        let targetSchemaID = schemaID ?? rootSchemaID
        return Change(dictionary: [
            "target": "field.value.rowUpdate",
            "fieldId": collectionFieldID,
            "pageId": pageID,
            "fileId": fileID,
            "change": [
                "rowId": rowID,
                "schemaId": targetSchemaID,
                "row": ["_id": rowID, "cells": cells] as [String: Any]
            ] as [String: Any]
        ])
    }

    func testCollection_columnEnforce_pageDependency() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let rows: [[String: Any]] = [["_id": "root-1", "cells": [rootTextCol: ""]]]

        let matchEditor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText], nestedColumns: minimalNestedColumns, rootRows: rows, includePageDropdown: true, dropdownValue: optYes))
        XCTAssertTrue(matchEditor.isColumnRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID))

        let noMatchEditor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText], nestedColumns: minimalNestedColumns, rootRows: rows, includePageDropdown: true, dropdownValue: optNo))
        XCTAssertFalse(noMatchEditor.isColumnRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID))
    }

    func testExternalPageFieldUpdateReevaluatesCollectionRequiredCells() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Explanation",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes)
        ]
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [rootText],
            nestedColumns: minimalNestedColumns,
            rootRows: [["_id": "root-1", "cells": [rootTextCol: ""]]],
            includePageDropdown: true,
            dropdownValue: optNo
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionToLoad(viewModel)
        guard let initialRow = viewModel.rowToValueElementMap["root-1"] else {
            XCTFail("The collection must render row root-1")
            return
        }

        XCTAssertFalse(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: initialRow
        ), "Public API starts with the explanation optional")
        XCTAssertFalse(viewModel.isCellRequired(
            columnID: rootTextCol,
            rowID: "root-1",
            schemaKey: rootSchemaID
        ), "Rendered collection starts with the explanation optional")

        editor.change(changes: [fieldUpdate(fieldID: dropdownFieldID, value: optYes)])

        guard let updatedRow = viewModel.rowToValueElementMap["root-1"] else {
            XCTFail("The collection must retain row root-1")
            return
        }
        XCTAssertEqual(editor.field(fieldID: dropdownFieldID)?.value?.text, optYes,
                       "Public document stores the external page-field value")
        XCTAssertTrue(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: updatedRow
        ), "Public API requires the collection explanation after the page answer changes")
        XCTAssertTrue(viewModel.isCellRequired(
            columnID: rootTextCol,
            rowID: "root-1",
            schemaKey: rootSchemaID
        ), "Rendered collection requires the explanation after the page answer changes")
    }

    func testCollection_cellRequiredLogic_siblingPerRow() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Text",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: rootDdCol, value: optYes)
        ]
        let rootDd: [String: Any] = ["_id": rootDdCol, "type": "dropdown", "title": "DD",
                                     "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]]
        let rows: [[String: Any]] = [
            ["_id": "root-match", "cells": [rootTextCol: "", rootDdCol: optYes]],
            ["_id": "root-nomatch", "cells": [rootTextCol: "", rootDdCol: optNo]],
        ]
        let editor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText, rootDd], nestedColumns: minimalNestedColumns, rootRows: rows))

        XCTAssertTrue(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID, row: rootRow(editor, id: "root-match")!))
        XCTAssertFalse(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID, row: rootRow(editor, id: "root-nomatch")!))
    }

    func testExternalCollectionRowUpdateImmediatelyReevaluatesRequiredCells() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: rootDdCol, value: optYes)
        ]
        let rootDropdown: [String: Any] = [
            "_id": rootDdCol, "type": "dropdown", "title": "Decision",
            "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]
        ]
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [rootText, rootDropdown],
            nestedColumns: minimalNestedColumns,
            rootRows: [["_id": "root-1", "cells": [rootTextCol: "", rootDdCol: optNo]]]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionToLoad(viewModel)

        guard let initialRow = viewModel.rowToValueElementMap["root-1"] else {
            XCTFail("The collection must render row root-1")
            return
        }
        XCTAssertFalse(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: initialRow
        ), "The public API reports the explanation optional before the controlling answer changes")
        XCTAssertFalse(viewModel.isCellRequired(
            columnID: rootTextCol,
            rowID: "root-1",
            schemaKey: rootSchemaID
        ), "The rendered collection reports the explanation optional before the controlling answer changes")

        editor.change(changes: [collectionRowUpdate(
            rowID: "root-1",
            cells: [rootDdCol: optYes]
        )])
        waitForMainQueue()

        guard let updatedRow = viewModel.rowToValueElementMap["root-1"] else {
            XCTFail("The updated collection must retain row root-1")
            return
        }
        XCTAssertTrue(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: updatedRow
        ), "The public API must apply the collection required rule after an external update")
        XCTAssertTrue(viewModel.isCellRequired(
            columnID: rootTextCol,
            rowID: "root-1",
            schemaKey: rootSchemaID
        ), "The rendered collection must apply the same required rule as an on-screen edit")
    }

    func testExternalCollectionPartialUpdateMakesOnlyTargetRowOptionalAndPreservesOtherCells() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: rootDdCol, value: optYes)
        ]
        let rootDropdown: [String: Any] = [
            "_id": rootDdCol, "type": "dropdown", "title": "Decision",
            "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]
        ]
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [rootText, rootDropdown],
            nestedColumns: minimalNestedColumns,
            rootRows: [
                ["_id": "root-1", "cells": [rootTextCol: "Keep explanation", rootDdCol: optYes]],
                ["_id": "root-2", "cells": [rootTextCol: "", rootDdCol: optYes]]
            ]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionToLoad(viewModel)

        guard let initialRow1 = viewModel.rowToValueElementMap["root-1"],
              let initialRow2 = viewModel.rowToValueElementMap["root-2"] else {
            XCTFail("The collection must render both rows")
            return
        }
        XCTAssertTrue(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID,
                                            schemaKey: rootSchemaID, row: initialRow1))
        XCTAssertTrue(viewModel.isCellRequired(columnID: rootTextCol, rowID: "root-1", schemaKey: rootSchemaID))
        XCTAssertTrue(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID,
                                            schemaKey: rootSchemaID, row: initialRow2))
        XCTAssertTrue(viewModel.isCellRequired(columnID: rootTextCol, rowID: "root-2", schemaKey: rootSchemaID))

        editor.change(changes: [collectionRowUpdate(
            rowID: "root-1",
            cells: [rootDdCol: optNo]
        )])
        waitForMainQueue()

        guard let updatedRow1 = viewModel.rowToValueElementMap["root-1"],
              let updatedRow2 = viewModel.rowToValueElementMap["root-2"] else {
            XCTFail("The collection must retain both rows")
            return
        }
        XCTAssertEqual(rootRow(editor, id: "root-1")?.cells?[rootDdCol]?.text, optNo,
                       "Public document stores the changed collection decision")
        XCTAssertEqual(rootRow(editor, id: "root-1")?.cells?[rootTextCol]?.text, "Keep explanation",
                       "A partial update must preserve an omitted collection explanation")
        XCTAssertEqual(
            viewModel.tableDataModel.filteredcellModels
                .first(where: { $0.rowID == "root-1" })?
                .cells.first(where: { $0.data.id == rootTextCol })?.data.title,
            "Keep explanation",
            "Rendered collection keeps the omitted explanation"
        )
        XCTAssertFalse(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID,
                                             schemaKey: rootSchemaID, row: updatedRow1),
                       "Public API makes the target collection explanation optional")
        XCTAssertFalse(viewModel.isCellRequired(columnID: rootTextCol, rowID: "root-1", schemaKey: rootSchemaID),
                       "Rendered collection makes the target explanation optional")
        XCTAssertTrue(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID,
                                            schemaKey: rootSchemaID, row: updatedRow2),
                      "Public API keeps the untouched collection row required")
        XCTAssertTrue(viewModel.isCellRequired(columnID: rootTextCol, rowID: "root-2", schemaKey: rootSchemaID),
                      "Rendered collection keeps the untouched row required")
    }

    func testExternalNestedCollectionRowUpdateReevaluatesRequiredCells() {
        let childText: [String: Any] = ["_id": childTextCol, "type": "text", "title": "Child answer"]
        let childNotes: [String: Any] = [
            "_id": childNotesCol, "type": "text", "title": "Child notes",
            "cellRequiredLogic": cellRequiredLogic(
                action: "enforce",
                condColumn: childTextCol,
                value: "",
                condition: "*="
            )
        ]
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [["_id": rootTextCol, "type": "text", "title": "Root text"]],
            nestedColumns: [childText, childNotes],
            rootRows: [[
                "_id": "root-1",
                "cells": [rootTextCol: ""],
                "children": [nestedSchemaID: ["value": [[
                    "_id": "child-1",
                    "cells": [childTextCol: "", childNotesCol: ""]
                ]]]]
            ]]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionToLoad(viewModel)
        guard let initialRow = viewModel.rowToValueElementMap["child-1"] else {
            XCTFail("The collection must load nested row child-1")
            return
        }

        XCTAssertFalse(editor.isCellRequired(
            columnID: childNotesCol,
            fieldID: collectionFieldID,
            schemaKey: nestedSchemaID,
            row: initialRow
        ), "Public API starts with child notes optional")
        XCTAssertFalse(viewModel.isCellRequired(
            columnID: childNotesCol,
            rowID: "child-1",
            schemaKey: nestedSchemaID
        ), "Rendered collection starts with child notes optional")

        editor.change(changes: [collectionRowUpdate(
            rowID: "child-1",
            cells: [childTextCol: "Needs notes"],
            schemaID: nestedSchemaID
        )])
        waitForMainQueue()

        guard let updatedRow = viewModel.rowToValueElementMap["child-1"] else {
            XCTFail("The collection must retain nested row child-1")
            return
        }
        XCTAssertEqual(nestedRow(editor, parentID: "root-1", childID: "child-1")?.cells?[childTextCol]?.text,
                       "Needs notes", "Public document stores the external nested answer")
        XCTAssertEqual(updatedRow.cells?[childTextCol]?.text, "Needs notes",
                       "Rendered collection stores the external nested answer")
        XCTAssertTrue(editor.isCellRequired(
            columnID: childNotesCol,
            fieldID: collectionFieldID,
            schemaKey: nestedSchemaID,
            row: updatedRow
        ), "Public API requires child notes after the nested answer changes")
        XCTAssertTrue(viewModel.isCellRequired(
            columnID: childNotesCol,
            rowID: "child-1",
            schemaKey: nestedSchemaID
        ), "Rendered collection requires child notes after the nested answer changes")
    }

    func testCollectionRequiredRulesFollowRowsThroughAddDuplicateAndDelete() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Explanation",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: rootDdCol, value: optYes)
        ]
        let rootDropdown: [String: Any] = [
            "_id": rootDdCol, "type": "dropdown", "title": "Decision",
            "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]
        ]
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [rootText, rootDropdown],
            nestedColumns: minimalNestedColumns,
            rootRows: [["_id": "original-root", "cells": [rootTextCol: "", rootDdCol: optNo]]]
        ))
        let viewModel = collectionViewModel(editor)
        waitForCollectionToLoad(viewModel)

        viewModel.addRow(
            with: "added-root",
            and: [rootTextCol: .string(""), rootDdCol: .string(optYes)],
            shouldSendEvent: false
        )
        let addedRow = viewModel.rowToValueElementMap["added-root"]!
        XCTAssertTrue(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: addedRow
        ), "A newly added collection row must receive required rules based on its own answers")

        let rowIDsBeforeDuplicate = Set(viewModel.rowToValueElementMap.keys)
        viewModel.tableDataModel.selectedRows = ["added-root"]
        viewModel.duplicateRow()
        let duplicatedRowID = Set(viewModel.rowToValueElementMap.keys)
            .subtracting(rowIDsBeforeDuplicate)
            .first
        XCTAssertNotNil(duplicatedRowID, "Duplicating a collection row must add one new row")
        if let duplicatedRowID,
           let duplicatedRow = viewModel.rowToValueElementMap[duplicatedRowID] {
            XCTAssertTrue(editor.isCellRequired(
                columnID: rootTextCol,
                fieldID: collectionFieldID,
                schemaKey: rootSchemaID,
                row: duplicatedRow
            ), "A duplicated collection row must preserve required behavior")
        }

        viewModel.tableDataModel.selectedRows = ["added-root"]
        viewModel.deleteSelectedRow()
        XCTAssertNil(viewModel.rowToValueElementMap["added-root"],
                     "Deleting a collection row must remove it from the rendered collection")
        XCTAssertFalse(editor.field(fieldID: collectionFieldID)?.valueToValueElements?.contains(where: {
            $0.id == "added-root" && $0.deleted != true
        }) ?? true, "The public document must remove the deleted collection row")
        XCTAssertFalse(editor.isCellRequired(
            columnID: rootTextCol,
            fieldID: collectionFieldID,
            schemaKey: rootSchemaID,
            row: addedRow
        ), "A deleted collection row must not retain required state")
    }

    func testCollection_nestedCellRequiredLogic() {
        let childText: [String: Any] = ["_id": childTextCol, "type": "text", "title": "Child Text"]
        let childNotes: [String: Any] = [
            "_id": childNotesCol, "type": "text", "title": "Notes",
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: childTextCol, value: "", condition: "*=")
        ]
        let rootRows: [[String: Any]] = [[
            "_id": "root-1", "cells": [:],
            "children": [nestedSchemaID: ["value": [
                ["_id": "child-filled", "cells": [childTextCol: "hi", childNotesCol: ""]],
                ["_id": "child-empty", "cells": [childTextCol: "", childNotesCol: ""]],
            ]]],
        ]]
        let editor = documentEditor(document: makeCollectionDoc(rootColumns: [["_id": rootTextCol, "type": "text", "title": "Text"]], nestedColumns: [childText, childNotes], rootRows: rootRows))

        XCTAssertTrue(editor.isCellRequired(columnID: childNotesCol, fieldID: collectionFieldID, schemaKey: nestedSchemaID, row: nestedRow(editor, parentID: "root-1", childID: "child-filled")!))
        XCTAssertFalse(editor.isCellRequired(columnID: childNotesCol, fieldID: collectionFieldID, schemaKey: nestedSchemaID, row: nestedRow(editor, parentID: "root-1", childID: "child-empty")!))
    }

    func testCollection_cellLogicTakesPrecedenceOverColumnLogic() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes),
            "cellRequiredLogic": cellRequiredLogic(action: "enforce", condColumn: rootDdCol, value: optYes)
        ]
        let rootDd: [String: Any] = ["_id": rootDdCol, "type": "dropdown", "title": "DD",
                                     "options": [["_id": optYes, "value": "Yes"], ["_id": optNo, "value": "No"]]]
        let rows: [[String: Any]] = [["_id": "root-1", "cells": [rootTextCol: "", rootDdCol: optYes]]]
        let editor = documentEditor(document: makeCollectionDoc(rootColumns: [rootText, rootDd], nestedColumns: minimalNestedColumns, rootRows: rows, includePageDropdown: true, dropdownValue: optNo))

        // Column-wide is optional (page dropdown = No) but the cell logic makes this row's cell required.
        XCTAssertFalse(editor.isColumnRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID))
        XCTAssertTrue(editor.isCellRequired(columnID: rootTextCol, fieldID: collectionFieldID, schemaKey: rootSchemaID, row: rootRow(editor, id: "root-1")!))
    }

    func testCollection_fieldLevelRequired_refreshesWhenTriggerChanges() {
        // Regression: field-level requiredLogic on a collection must be refreshed when its trigger changes.
        let editor = documentEditor(document: makeCollectionDoc(
            rootColumns: [["_id": rootTextCol, "type": "text", "title": "Text"]],
            nestedColumns: minimalNestedColumns, rootRows: [],
            fieldRequiredLogic: requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes),
            includePageDropdown: true, dropdownValue: optNo
        ))
        XCTAssertFalse(editor.isFieldRequired(fieldID: collectionFieldID))

        var dropdown = editor.field(fieldID: dropdownFieldID)
        dropdown?.value = .string(optYes)
        editor.updateField(field: dropdown)

        let refreshed = editor.requiredLogicHandler.fieldsNeedsToBeRefreshed(fieldID: dropdownFieldID)
        XCTAssertTrue(refreshed.contains(collectionFieldID))
        XCTAssertTrue(editor.isFieldRequired(fieldID: collectionFieldID))
    }
}
