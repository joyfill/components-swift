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
            "cellRequiredLogic": requiredLogic(action: "enforce", condField: ddColumnID, value: optYes)
        ]
        let rows: [[String: Any]] = [
            ["_id": "row-match", "cells": [textColumnID: "", ddColumnID: optYes]],   // sibling matches -> required -> invalid
            ["_id": "row-nomatch", "cells": [textColumnID: "", ddColumnID: optNo]],  // sibling no match -> optional -> valid
        ]
        let editor = documentEditor(document: makeTableDoc(textColumn: textColumn, rows: rows, includePageDropdown: false, dropdownValue: optNo))

        XCTAssertEqual(cellStatus(editor, rowId: "row-match", columnId: textColumnID), .invalid)
        XCTAssertEqual(cellStatus(editor, rowId: "row-nomatch", columnId: textColumnID), .valid)
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

    func testCellLogicTakesPrecedenceOverColumnLogic_table() {
        // Column requiredLogic says optional (page dropdown = No), but cellRequiredLogic says required
        // (sibling dd cell = Yes). Cell logic wins -> empty cell invalid.
        let textColumn: [String: Any] = [
            "_id": textColumnID, "type": "text", "title": "Text",
            "requiredLogic": requiredLogic(action: "enforce", condField: dropdownFieldID, value: optYes),
            "cellRequiredLogic": requiredLogic(action: "enforce", condField: ddColumnID, value: optYes)
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

    func testCollection_cellRequiredLogic_siblingPerRow() {
        let rootText: [String: Any] = [
            "_id": rootTextCol, "type": "text", "title": "Text",
            "cellRequiredLogic": requiredLogic(action: "enforce", condField: rootDdCol, value: optYes)
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

    func testCollection_nestedCellRequiredLogic() {
        let childText: [String: Any] = ["_id": childTextCol, "type": "text", "title": "Child Text"]
        let childNotes: [String: Any] = [
            "_id": childNotesCol, "type": "text", "title": "Notes",
            "cellRequiredLogic": requiredLogic(action: "enforce", condField: childTextCol, value: "", condition: "*=")
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
            "cellRequiredLogic": requiredLogic(action: "enforce", condField: rootDdCol, value: optYes)
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
