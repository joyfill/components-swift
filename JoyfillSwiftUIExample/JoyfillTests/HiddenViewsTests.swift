//
//  HiddenViewsTests.swift
//  JoyfillTests
//
//  Tests for view-based hiding (hiddenViews).
//  In the mobile SDK, if a field (or table column) has hiddenViews: ["mobile"], we never show it.
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

final class HiddenViewsTests: XCTestCase {

    private let textFieldID = "66aa2865da10ac1c7b7acb1d"
    private let tableFieldID = "67612793c4e6a5e6a05e64a3"
    private let tableColumn1ID = "676127938fb7c5fd4321a2f4"

    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    // MARK: - isMobileViewActive

    func testIsMobileViewActive_WhenNoMobileView_IsFalse() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        let editor = documentEditor(document: document)
        XCTAssertFalse(editor.isMobileViewActive)
    }

    func testIsMobileViewActive_WhenMobileViewExists_IsTrue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        let editor = documentEditor(document: document)
        XCTAssertTrue(editor.isMobileViewActive)
    }

    // MARK: - shouldShow with hiddenViews on field

    func testShouldShow_WhenHiddenViewsContainsMobile_AndMobileView_ReturnsFalse() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["mobile"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertFalse(result)
    }

    /// In the mobile SDK, if a field has hiddenViews: ["mobile"], we never show it (we're the mobile app).
    func testShouldShow_WhenHiddenViewsContainsMobile_NeverShownInMobileSDK() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["mobile"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertFalse(result, "Field with hiddenViews: [\"mobile\"] must not be shown in the mobile SDK")
    }

    func testShouldShow_WhenHiddenViewsContainsDesktop_AndNoMobileView_ReturnsTrue() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["desktop"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertTrue(result)
    }
    
    func testShouldShow_WhenHiddenViewsContainsDesktop_AndNoMobileView_Returnsfalse() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: true, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["desktop"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        // Should false because hidden is true
        XCTAssertFalse(result)
    }

    func testShouldShow_WhenHiddenViewsContainsDesktop_AndMobileView_ReturnsTrue() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["desktop"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertTrue(result)
    }

    func testShouldShow_WhenHiddenViewsNil_RespectsHiddenProperty() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string(""))
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertFalse(result)
    }

    func testShouldShow_WhenHiddenViewsEmpty_FieldShown() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = []
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertTrue(result)
    }

    func testShouldShow_WhenHiddenViewsContainsMobileAndDesktop_NeverShown() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["mobile", "desktop"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertFalse(result, "hiddenViews contains \"mobile\" so must not be shown in mobile SDK")
    }

    func testShouldShow_WhenHiddenViewsContainsOnlyPdf_Shown() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["pdf"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertTrue(result, "hiddenViews [\"pdf\"] only – we're mobile, so field is shown")
    }

    // MARK: - hiddenViews over conditional logic

    /// When a field has conditional logic that would show it (e.g. "show when number = 100") but also
    /// hiddenViews: ["mobile"], the field must stay hidden in the mobile SDK. hiddenViews wins over conditional logic.
    func testShouldShow_WhenConditionalLogicWouldShowButHiddenViewsMobile_ReturnsFalse() {
        let numberFieldID = "6629fb3df03de10b26270ab3"
        let logicDictionary: [String: Any] = [
            "action": "show",
            "eval": "and",
            "conditions": [
                [
                    "file": "66a0fdb2acd89d30121053b9",
                    "page": "66aa286569ad25c65517385e",
                    "field": numberFieldID,
                    "condition": "=",
                    "value": ValueUnion.double(100),
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["mobile"]
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: textFieldID)
        XCTAssertFalse(result, "hiddenViews: [\"mobile\"] must override conditional logic; field must not be shown")
    }

    func testShouldShow_WhenFieldIDNil_ReturnsTrue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: nil)
        XCTAssertTrue(result)
    }

    func testShouldShow_WhenFieldIDNonExistent_ReturnsTrue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        let editor = documentEditor(document: document)
        let result = editor.shouldShow(fieldID: "nonExistentFieldID")
        XCTAssertTrue(result)
    }

    // MARK: - shouldShowColumn (table column with hiddenViews: ["mobile"] never shown)

    func testShouldShowColumn_WhenColumnHiddenViewsContainsMobile_ReturnsFalse() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        if let idx = document.fields.firstIndex(where: { $0.id == tableFieldID }),
           var columns = document.fields[idx].tableColumns,
           let colIdx = columns.firstIndex(where: { $0.id == tableColumn1ID }) {
            columns[colIdx].hiddenViews = ["mobile"]
            document.fields[idx].tableColumns = columns
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: tableColumn1ID, fieldID: tableFieldID, schemaKey: nil)
        XCTAssertFalse(result, "Column with hiddenViews: [\"mobile\"] must not be shown in mobile SDK")
    }

    func testShouldShowColumn_WhenColumnHiddenViewsNil_ReturnsTrue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: tableColumn1ID, fieldID: tableFieldID, schemaKey: nil)
        XCTAssertTrue(result)
    }

    func testShouldShowColumn_WhenColumnHiddenViewsDesktopOnly_ReturnsTrue() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        if let idx = document.fields.firstIndex(where: { $0.id == tableFieldID }),
           var columns = document.fields[idx].tableColumns,
           let colIdx = columns.firstIndex(where: { $0.id == tableColumn1ID }) {
            columns[colIdx].hiddenViews = ["desktop"]
            document.fields[idx].tableColumns = columns
        }
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: tableColumn1ID, fieldID: tableFieldID, schemaKey: nil)
        XCTAssertTrue(result, "hiddenViews [\"desktop\"] only – we're mobile, so column is shown")
    }

    // MARK: - Validation (force-hidden field not validated)

    func testValidate_WhenFieldHasHiddenViewsMobile_ConsideredValid() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""), required: true)
            .setRequiredTextFieldInMobile()
        if let idx = document.fields.firstIndex(where: { $0.id == textFieldID }) {
            document.fields[idx].hiddenViews = ["mobile"]
        }
        let editor = documentEditor(document: document)
        let result = editor.validate()
        XCTAssertEqual(result.status, .valid, "Force-hidden required field must not trigger validation error")
    }
}
