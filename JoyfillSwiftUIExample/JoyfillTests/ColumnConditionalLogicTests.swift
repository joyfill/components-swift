import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class ColumnConditionalLogicTests: XCTestCase {
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    
    // Field IDs
    let tableFieldID = "table_field_001"
    let numberFieldID = "number_field_001"
    let textFieldID = "66aa2865da10ac1c7b7acb1d" // Matches setTextField(hidden:value:) builder
    let dropdownFieldID = "dropdown_field_001"
    
    // Column IDs
    let textColumnID = "col_text_001"
    let numberColumnID = "col_number_001"
    let imageColumnID = "col_image_001"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }
    
    // MARK: - Builder Helpers
    
    /// Creates a table field with columns, some having conditional logic
    func buildTableFieldWithColumnLogic(
        tableFieldID: String,
        columns: [FieldTableColumn],
        columnOrder: [String]? = nil
    ) -> JoyDocField {
        var field = JoyDocField()
        field.type = "table"
        field.id = tableFieldID
        field.identifier = "field_\(tableFieldID)"
        field.title = "Table With Column Logic"
        field.description = ""
        field.required = false
        field.file = fileID
        field.tableColumns = columns
        field.tableColumnOrder = columnOrder ?? columns.compactMap { $0.id }
        field.rowOrder = ["row_001", "row_002"]
        return field
    }
    
    /// Creates a FieldTableColumn with optional conditional logic
    func buildColumn(
        id: String,
        type: ColumnTypes,
        title: String,
        hidden: Bool = false,
        logic: Logic? = nil,
        hiddenViews: [String]? = nil
    ) -> FieldTableColumn {
        var dict: [String: Any] = [
            "_id": id,
            "type": type.rawValue,
            "title": title,
            "width": 0,
            "identifier": "field_column_\(id)"
        ]
        dict["hidden"] = hidden
        if let logic = logic {
            dict["logic"] = logic.dictionary
        }
        if let hiddenViews = hiddenViews {
            dict["hiddenViews"] = hiddenViews
        }
        return FieldTableColumn(dictionary: dict)
    }
    
    /// Creates a column logic dictionary (same structure as field logic)
    func buildColumnLogicDictionary(
        isShow: Bool,
        fieldID: String,
        conditionType: ConditionType,
        value: ValueUnion,
        eval: EvaluationType = .and
    ) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": eval.rawValue,
            "conditions": [
                [
                    "file": fileID,
                    "page": pageID,
                    "field": fieldID,
                    "condition": conditionType.rawValue,
                    "value": value,
                    "_id": UUID().uuidString
                ]
            ],
            "_id": UUID().uuidString
        ]
    }
    
    /// Creates a column logic dictionary with multiple conditions
    func buildColumnLogicDictionary(
        isShow: Bool,
        conditions: [LogicConditionTest],
        eval: EvaluationType = .and
    ) -> [String: Any] {
        let conditionsArray: [[String: Any]] = conditions.map { test in
            [
                "file": fileID,
                "page": pageID,
                "field": test.fieldID as Any,
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
    
    /// Builds a complete document with a table that has column logic, plus a number field as the condition source
    func buildDocumentWithTableColumnLogic(
        numberValue: ValueUnion = .double(100),
        columnHidden: Bool = true,
        columnAction: Bool = true, // true = show, false = hide
        conditionType: ConditionType = .equals,
        conditionValue: ValueUnion = .double(100)
    ) -> JoyDoc {
        let logicDict = buildColumnLogicDictionary(
            isShow: columnAction,
            fieldID: numberFieldID,
            conditionType: conditionType,
            value: conditionValue
        )
        let textColumn = buildColumn(
            id: textColumnID,
            type: .text,
            title: "Text Column",
            hidden: columnHidden,
            logic: Logic(field: logicDict)
        )
        let numberColumn = buildColumn(
            id: numberColumnID,
            type: .number,
            title: "Number Column"
        )
        let imageColumn = buildColumn(
            id: imageColumnID,
            type: .image,
            title: "Image Column"
        )
        
        let tableField = buildTableFieldWithColumnLogic(
            tableFieldID: tableFieldID,
            columns: [textColumn, numberColumn, imageColumn]
        )
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: numberValue, id: numberFieldID)
        
        document.fields.append(tableField)
        
        document = document.setFieldPositionToPage(
            pageId: pageID,
            idAndTypes: [numberFieldID: .number, tableFieldID: .table]
        )
        
        return document
    }
    
    // MARK: - Column Show/Hide Tests
    
    /// Column hidden=true, action=show, condition met (number=100, condition equals 100) -> column should show
    func testColumnShowWhenConditionMet() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(100),
            columnHidden: true,
            columnAction: true, // show
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when condition is met (number=100, show when equals 100)")
    }
    
    /// Column hidden=true, action=show, condition NOT met (number=50, condition equals 100) -> column should stay hidden
    func testColumnHiddenWhenConditionNotMet() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(50),
            columnHidden: true,
            columnAction: true, // show
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when condition is not met (number=50, show when equals 100)")
    }
    
    /// Column hidden=false, action=hide, condition met (number=100, condition equals 100) -> column should hide
    func testColumnHideWhenConditionMet() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(100),
            columnHidden: false,
            columnAction: false, // hide
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should hide when hide condition is met (number=100, hide when equals 100)")
    }
    
    /// Column hidden=false, action=hide, condition NOT met (number=50, condition equals 100) -> column should stay shown
    func testColumnStaysShownWhenHideConditionNotMet() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(50),
            columnHidden: false,
            columnAction: false, // hide
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should stay shown when hide condition is not met (number=50, hide when equals 100)")
    }
    
    /// Column with no logic, hidden=false -> should show
    func testColumnWithNoLogicShown() {
        let document = buildDocumentWithTableColumnLogic(numberValue: .double(100))
        let editor = documentEditor(document: document)
        // numberColumn has no logic, hidden defaults to false
        let result = editor.shouldShowColumn(columnID: numberColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column with no logic and hidden=false should show")
    }
    
    /// Column with no logic, hidden=true -> should not show
    func testColumnWithNoLogicHidden() {
        let hiddenColumn = buildColumn(id: "col_hidden_nologic", type: .text, title: "Hidden No Logic", hidden: true)
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(
            tableFieldID: tableFieldID,
            columns: [hiddenColumn, normalColumn]
        )
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: "col_hidden_nologic", fieldID: tableFieldID)
        XCTAssertFalse(result, "Column with no logic and hidden=true should not show")
    }
    
    // MARK: - Condition Type Tests
    
    /// Show column when number > 50 (greaterThan condition)
    func testColumnShowOnGreaterThan() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(75),
            columnHidden: true,
            columnAction: true,
            conditionType: .greaterThan,
            conditionValue: .double(50)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when number (75) > 50")
    }
    
    /// Show column when number < 100 (lessThan condition)
    func testColumnShowOnLessThan() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(50),
            columnHidden: true,
            columnAction: true,
            conditionType: .lessThan,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when number (50) < 100")
    }
    
    /// Show column when number != 100 (notEquals condition)
    func testColumnShowOnNotEquals() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(50),
            columnHidden: true,
            columnAction: true,
            conditionType: .notEquals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when number (50) != 100")
    }
    
    /// Show column when field is null (isNull condition)
    func testColumnShowOnIsNull() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .null,
            columnHidden: true,
            columnAction: true,
            conditionType: .isNull,
            conditionValue: .null
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when number is null and condition is isNull")
    }
    
    /// Show column when field is not null (isNotNull condition)
    func testColumnShowOnIsNotNull() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(100),
            columnHidden: true,
            columnAction: true,
            conditionType: .isNotNull,
            conditionValue: .null
        )
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when number is not null and condition is isNotNull")
    }
    
    // MARK: - Multiple Conditions (AND/OR)
    
    /// Show column when BOTH conditions met (AND)
    func testColumnShowOnMultipleConditionsAnd() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: numberFieldID, conditionType: .greaterThan, value: .double(50)),
                LogicConditionTest(fieldID: textFieldID, conditionType: .equals, value: .string("Hello"))
            ],
            eval: .and
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
            .setTextField(hidden: false, value: .string("Hello"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when both AND conditions are met")
    }
    
    /// Column stays hidden when one AND condition fails
    func testColumnHiddenWhenOneAndConditionFails() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: numberFieldID, conditionType: .greaterThan, value: .double(50)),
                LogicConditionTest(fieldID: textFieldID, conditionType: .equals, value: .string("Hello"))
            ],
            eval: .and
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID) // passes > 50
            .setTextField(hidden: false, value: .string("World")) // fails equals "Hello"
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when one AND condition fails")
    }
    
    /// Show column when either OR condition is met
    func testColumnShowOnOrCondition() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: numberFieldID, conditionType: .equals, value: .double(999)),
                LogicConditionTest(fieldID: textFieldID, conditionType: .equals, value: .string("Hello"))
            ],
            eval: .or
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(50), id: numberFieldID) // fails equals 999
            .setTextField(hidden: false, value: .string("Hello")) // passes equals "Hello"
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when either OR condition is met")
    }
    
    // MARK: - HiddenViews Takes Precedence
    
    /// Column with hiddenViews=["mobile"] should always be hidden even if logic says show
    func testColumnHiddenViewsTakesPrecedence() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let forcedHiddenColumn = buildColumn(
            id: textColumnID,
            type: .text,
            title: "Force Hidden Column",
            hidden: true,
            logic: Logic(field: logicDict),
            hiddenViews: ["mobile"]
        )
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [forcedHiddenColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column with hiddenViews=['mobile'] should be hidden even when logic condition is met")
    }
    
    // MARK: - Fields Needs To Be Refreshed (Column Visibility Change)
    
    /// When number field changes and column visibility changes, the table field should be in the refresh list
    func testFieldsNeedsToBeRefreshedForColumnChange() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(50), // initially 50, condition equals 100 -> column hidden
            columnHidden: true,
            columnAction: true,
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        
        // Verify column is hidden initially
        let initialResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(initialResult, "Column should be hidden initially (number=50, show when =100)")
        
        // Update number field to 100 (condition now met)
        let fieldIdentifier = FieldIdentifier(fieldID: numberFieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .double(100))
        editor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        // After update, column should now show
        let afterResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(afterResult, "Column should show after number changed to 100")
    }
    
    /// When number field changes but column visibility doesn't change, table should NOT be refreshed
    func testNoRefreshWhenColumnVisibilityUnchanged() {
        let document = buildDocumentWithTableColumnLogic(
            numberValue: .double(100), // initially 100, condition equals 100 -> column shown
            columnHidden: true,
            columnAction: true,
            conditionType: .equals,
            conditionValue: .double(100)
        )
        let editor = documentEditor(document: document)
        
        // Verify column shows initially
        let initialResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(initialResult, "Column should show initially (number=100, show when =100)")
        
        // Update number to 100 again (same value, no change)
        let fieldIdentifier = FieldIdentifier(fieldID: numberFieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .double(100))
        editor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        // Column should still show
        let afterResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(afterResult, "Column should still show after setting same value")
    }
    
    // MARK: - Edge Cases
    
    /// Unknown column ID returns true (default show)
    func testUnknownColumnIDReturnsTrue() {
        let document = buildDocumentWithTableColumnLogic(numberValue: .double(100))
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: "unknown_column", fieldID: tableFieldID)
        XCTAssertTrue(result, "Unknown column ID should default to showing")
    }
    
    /// Unknown field ID returns true
    func testUnknownFieldIDReturnsTrue() {
        let document = buildDocumentWithTableColumnLogic(numberValue: .double(100))
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: "unknown_field")
        XCTAssertTrue(result, "Unknown field ID should default to showing")
    }
    
    /// Column with null condition field reference
    func testColumnLogicWithNullConditionField() {
        let logicDict: [String: Any] = [
            "action": "show",
            "eval": "and",
            "conditions": [
                [
                    "file": fileID,
                    "page": pageID,
                    "field": NSNull(),
                    "condition": "=",
                    "value": 100,
                    "_id": UUID().uuidString
                ]
            ],
            "_id": UUID().uuidString
        ]
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column with null condition field should stay hidden (fallback to hidden state)")
    }
    
    // MARK: - Page Duplication Tests
    
    /// After page duplication, column logic conditions should reference new field IDs (not original)
    func testPageDuplicationRemapsColumnLogicConditions() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        // Build document manually for page duplication scenario
        var document = JoyDoc()
        document.id = "test_doc"
        document.type = "document"
        document.identifier = "doc_test"
        document.name = "Test Document"
        document.fields = [numberField, tableField]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        
        var page = Page()
        page.id = pageID
        page.name = "Page 1"
        page.hidden = false
        
        var fp1 = FieldPosition()
        fp1.field = numberFieldID
        fp1.id = "fp_number"
        fp1.type = .number
        
        var fp2 = FieldPosition()
        fp2.field = tableFieldID
        fp2.id = "fp_table"
        fp2.type = .table
        
        page.fieldPositions = [fp1, fp2]
        file.pages = [page]
        file.views = []
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        
        // Duplicate the page
        editor.duplicatePage(pageID: pageID)
        
        let duplicatedFields = editor.document.fields
        let pageOrder = editor.document.files.first?.pageOrder ?? []
        
        // Find the duplicated page
        XCTAssertTrue(pageOrder.count > 1, "Should have at least 2 pages after duplication")
        let duplicatedPageID = pageOrder.last!
        XCTAssertNotEqual(duplicatedPageID, pageID, "Duplicated page should have a different ID")
        
        // Find the duplicated table field (it should have a new ID)
        let originalTableField = duplicatedFields.first(where: { $0.id == tableFieldID })
        XCTAssertNotNil(originalTableField, "Original table field should still exist")
        
        // The duplicated table field should have a new ID
        let duplicatedTableFields = duplicatedFields.filter { $0.id != tableFieldID && $0.type == "table" }
        XCTAssertEqual(duplicatedTableFields.count, 1, "Should have exactly one duplicated table field")
        let duplicatedTable = duplicatedTableFields.first!
        
        // Find the duplicated number field
        let duplicatedNumberFields = duplicatedFields.filter { $0.id != numberFieldID && $0.type == "number" }
        XCTAssertEqual(duplicatedNumberFields.count, 1, "Should have exactly one duplicated number field")
        let duplicatedNumber = duplicatedNumberFields.first!
        
        // Verify the duplicated table's column logic now references the duplicated number field ID
        let duplicatedColumns = duplicatedTable.tableColumns ?? []
        let duplicatedTextColumn = duplicatedColumns.first(where: { $0.id == textColumnID })
        XCTAssertNotNil(duplicatedTextColumn, "Duplicated table should have the text column")
        
        let columnLogic = duplicatedTextColumn?.logic
        XCTAssertNotNil(columnLogic, "Duplicated column should have logic")
        
        let columnConditions = columnLogic?.conditions ?? []
        XCTAssertEqual(columnConditions.count, 1, "Column logic should have 1 condition")
        
        let conditionFieldRef = columnConditions.first?.field
        XCTAssertNotEqual(conditionFieldRef, numberFieldID, "Column condition should NOT reference original number field ID")
        XCTAssertEqual(conditionFieldRef, duplicatedNumber.id, "Column condition should reference the duplicated number field ID")
    }
    
    /// After page duplication, column logic should evaluate correctly with the duplicated field's value
    func testPageDuplicationColumnLogicEvaluatesCorrectly() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        var document = JoyDoc()
        document.id = "test_doc"
        document.type = "document"
        document.identifier = "doc_test"
        document.name = "Test Document"
        document.fields = [numberField, tableField]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        
        var page = Page()
        page.id = pageID
        page.name = "Page 1"
        page.hidden = false
        
        var fp1 = FieldPosition()
        fp1.field = numberFieldID
        fp1.id = "fp_number"
        fp1.type = .number
        
        var fp2 = FieldPosition()
        fp2.field = tableFieldID
        fp2.id = "fp_table"
        fp2.type = .table
        
        page.fieldPositions = [fp1, fp2]
        file.pages = [page]
        file.views = []
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        
        // Verify original column shows (number=100, show when =100)
        let originalResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(originalResult, "Original column should show (number=100)")
        
        // Duplicate the page
        editor.duplicatePage(pageID: pageID)
        
        // Find duplicated table field ID
        let duplicatedTableFields = editor.document.fields.filter { $0.id != tableFieldID && $0.type == "table" }
        guard let duplicatedTable = duplicatedTableFields.first, let dupTableID = duplicatedTable.id else {
            XCTFail("Could not find duplicated table field")
            return
        }
        
        // The duplicated table's column should also show (duplicated number also has value 100)
        let dupResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: dupTableID)
        XCTAssertTrue(dupResult, "Duplicated column should show (duplicated number also has value 100)")
    }
    
    /// Verify columns without logic are preserved correctly after duplication
    func testPageDuplicationPreservesColumnsWithoutLogic() {
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column")
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        var document = JoyDoc()
        document.id = "test_doc"
        document.type = "document"
        document.identifier = "doc_test"
        document.name = "Test Document"
        document.fields = [numberField, tableField]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        
        var page = Page()
        page.id = pageID
        page.name = "Page 1"
        page.hidden = false
        
        var fp1 = FieldPosition()
        fp1.field = numberFieldID
        fp1.id = "fp_number"
        fp1.type = .number
        
        var fp2 = FieldPosition()
        fp2.field = tableFieldID
        fp2.id = "fp_table"
        fp2.type = .table
        
        page.fieldPositions = [fp1, fp2]
        file.pages = [page]
        file.views = []
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        editor.duplicatePage(pageID: pageID)
        
        let duplicatedTableFields = editor.document.fields.filter { $0.id != tableFieldID && $0.type == "table" }
        guard let duplicatedTable = duplicatedTableFields.first else {
            XCTFail("Could not find duplicated table field")
            return
        }
        
        let dupColumns = duplicatedTable.tableColumns ?? []
        XCTAssertEqual(dupColumns.count, 2, "Duplicated table should have 2 columns")
        XCTAssertNotNil(dupColumns.first(where: { $0.id == textColumnID }), "Text column should exist in duplicated table")
        XCTAssertNotNil(dupColumns.first(where: { $0.id == numberColumnID }), "Number column should exist in duplicated table")
    }
    
    // MARK: - Column Logic Based on Text Field
    
    /// Show column when text field equals "Hello"
    func testColumnShowOnTextFieldEquals() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: textFieldID,
            conditionType: .equals,
            value: .string("Hello")
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when text field equals 'Hello'")
    }
    
    /// Column stays hidden when text field does NOT match
    func testColumnHiddenOnTextFieldNotMatching() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: textFieldID,
            conditionType: .equals,
            value: .string("Hello")
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("World"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when text field does not match")
    }
    
    /// Show column when text field contains a substring
    func testColumnShowOnTextFieldContains() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: textFieldID,
            conditionType: .contains,
            value: .string("ello")
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello World"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when text field contains 'ello'")
    }
    
    /// Hide column when text field is null
    func testColumnHideOnTextFieldIsNull() {
        let logicDict = buildColumnLogicDictionary(
            isShow: false,
            fieldID: textFieldID,
            conditionType: .isNull,
            value: .null
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: false, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string(""))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should hide when text field is empty (isNull)")
    }
    
    // MARK: - Column Logic Based on Dropdown Field
    
    /// Show column when dropdown equals a specific option
    func testColumnShowOnDropdownEquals() {
        let dropdownID = "6781040987a55e48b4507a38"
        let yesOptionID = "677e2bfab0d5dce4162c36c1"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: dropdownID,
            conditionType: .equals,
            value: .string(yesOptionID)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string(yesOptionID))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when dropdown equals 'Yes'")
    }
    
    /// Column stays hidden when dropdown has different value
    func testColumnHiddenOnDropdownNotMatching() {
        let dropdownID = "6781040987a55e48b4507a38"
        let yesOptionID = "677e2bfab0d5dce4162c36c1"
        let noOptionID = "677e2bfaf81647d2f6a016a0"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: dropdownID,
            conditionType: .equals,
            value: .string(yesOptionID)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string(noOptionID)) // "No" selected
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when dropdown is 'No' but condition expects 'Yes'")
    }
    
    /// Hide column when dropdown is null
    func testColumnHideOnDropdownIsNull() {
        let dropdownID = "6781040987a55e48b4507a38"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: false,
            fieldID: dropdownID,
            conditionType: .isNull,
            value: .null
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: false, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .null) // null
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should hide when dropdown is null and condition is isNull")
    }
    
    // MARK: - Column Logic Based on MultiSelect Field
    
    /// Show column when multiselect equals a specific option
    func testColumnShowOnMultiSelectEquals() {
        let multiSelectID = "678104b387d3004e70120ac6"
        let yesOptionID = "677e2bfa1ff43cf15d159310"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: multiSelectID,
            conditionType: .equals,
            value: .string(yesOptionID)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultiSelectField(hidden: false, value: .array([yesOptionID]), multi: true)
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multiSelectID: .multiSelect, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when multiselect contains 'Yes'")
    }
    
    /// Column stays hidden when multiselect does not match
    func testColumnHiddenOnMultiSelectNotMatching() {
        let multiSelectID = "678104b387d3004e70120ac6"
        let yesOptionID = "677e2bfa1ff43cf15d159310"
        let noOptionID = "677e2bfa9c5249a2acd3644f"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: multiSelectID,
            conditionType: .equals,
            value: .string(yesOptionID)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultiSelectField(hidden: false, value: .array([noOptionID]), multi: true) // "No" selected
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multiSelectID: .multiSelect, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when multiselect does not contain 'Yes'")
    }
    
    /// Show column when multiselect is not null
    func testColumnShowOnMultiSelectIsNotNull() {
        let multiSelectID = "678104b387d3004e70120ac6"
        let yesOptionID = "677e2bfa1ff43cf15d159310"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: multiSelectID,
            conditionType: .isNotNull,
            value: .null
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultiSelectField(hidden: false, value: .array([yesOptionID]), multi: true)
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multiSelectID: .multiSelect, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when multiselect is not null")
    }
    
    // MARK: - Column Logic Based on Multiline/Textarea Field
    
    /// Show column when multiline text contains a substring
    func testColumnShowOnMultilineContains() {
        let multilineID = "6629fb2b9a487ce1c1f35f6c"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: multilineID,
            conditionType: .contains,
            value: .string("vivek")
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultilineTextField(hidden: false, value: .string("hello world vivek"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multilineID: .textarea, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when multiline text contains 'vivek'")
    }
    
    /// Column stays hidden when multiline does NOT contain substring
    func testColumnHiddenOnMultilineNotContaining() {
        let multilineID = "6629fb2b9a487ce1c1f35f6c"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: multilineID,
            conditionType: .contains,
            value: .string("vivek")
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultilineTextField(hidden: false, value: .string("hello world"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multilineID: .textarea, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when multiline text does not contain 'vivek'")
    }
    
    /// Hide column when multiline is not null (isNotNull)
    func testColumnHideOnMultilineIsNotNull() {
        let multilineID = "6629fb2b9a487ce1c1f35f6c"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: false,
            fieldID: multilineID,
            conditionType: .isNotNull,
            value: .null
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: false, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultilineTextField(hidden: false, value: .string("some text"))
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [multilineID: .textarea, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should hide when multiline is not null and condition is hide on isNotNull")
    }
    
    // MARK: - Column Logic with Mixed Field Types (AND conditions)
    
    /// Show column when dropdown=Yes AND number>50 (AND condition with two different field types)
    func testColumnShowOnDropdownAndNumberCondition() {
        let dropdownID = "6781040987a55e48b4507a38"
        let yesOptionID = "677e2bfab0d5dce4162c36c1"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: dropdownID, conditionType: .equals, value: .string(yesOptionID)),
                LogicConditionTest(fieldID: numberFieldID, conditionType: .greaterThan, value: .double(50))
            ],
            eval: .and
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string(yesOptionID)) // Yes
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID) // 100 > 50
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when dropdown=Yes AND number>50")
    }
    
    /// Column stays hidden when dropdown=Yes but number<=50 (one AND condition fails)
    func testColumnHiddenOnDropdownYesButNumberLow() {
        let dropdownID = "6781040987a55e48b4507a38"
        let yesOptionID = "677e2bfab0d5dce4162c36c1"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: dropdownID, conditionType: .equals, value: .string(yesOptionID)),
                LogicConditionTest(fieldID: numberFieldID, conditionType: .greaterThan, value: .double(50))
            ],
            eval: .and
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string(yesOptionID)) // Yes
            .setNumberField(hidden: false, value: .double(30), id: numberFieldID) // 30 NOT > 50
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertFalse(result, "Column should stay hidden when dropdown=Yes but number<=50 (AND fails)")
    }
    
    /// Show column when text contains OR multiline is not null (OR condition with two text-like fields)
    func testColumnShowOnTextOrMultilineCondition() {
        let multilineID = "6629fb2b9a487ce1c1f35f6c"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            conditions: [
                LogicConditionTest(fieldID: textFieldID, conditionType: .contains, value: .string("xyz")),
                LogicConditionTest(fieldID: multilineID, conditionType: .isNotNull, value: .null)
            ],
            eval: .or
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // does NOT contain "xyz"
            .setMultilineTextField(hidden: false, value: .string("some text")) // IS not null -> passes
        document.fields.append(tableField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, multilineID: .textarea, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(result, "Column should show when text fails but multiline passes (OR condition)")
    }
    
    // MARK: - Collection Column Show/Hide Tests
    
    let collectionFieldID = "collection_field_001"
    let collectionSchemaKey = "schema_root"
    let collectionColTextID = "col_coll_text_001"
    let collectionColNumberID = "col_coll_number_001"
    
    /// Builds a collection field with schema that has column logic
    func buildCollectionFieldWithColumnLogic(
        columns: [FieldTableColumn],
        schemaKey: String
    ) -> JoyDocField {
        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.title = "Collection With Column Logic"
        field.description = ""
        field.file = fileID
        
        // Build schema entry with tableColumns
        var schemaDict: [String: Any] = [
            "title": "Root Schema",
            "root": true,
            "children": [String](),
            "tableColumns": columns.map { $0.dictionary }
        ]
        
        let fullSchema: [String: Any] = [
            schemaKey: schemaDict
        ]
        
        field.dictionary["schema"] = fullSchema
        
        // Add a value row
        let valueElement = ValueElement(dictionary: [
            "_id": "row_001",
            "cells": [String: Any](),
            "children": [String: Any]()
        ])
        field.value = .valueElementArray([valueElement])
        
        return field
    }
    
    /// Show collection column when number field equals 100
    func testCollectionColumnShowOnNumberEquals() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertTrue(result, "Collection column should show when number equals 100")
    }
    
    /// Collection column stays hidden when condition not met
    func testCollectionColumnHiddenWhenConditionNotMet() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(50), id: numberFieldID) // 50, not 100
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertFalse(result, "Collection column should stay hidden when number is 50 (condition expects 100)")
    }
    
    /// Hide collection column when dropdown matches
    func testCollectionColumnHideOnDropdownEquals() {
        let dropdownID = "6781040987a55e48b4507a38"
        let yesOptionID = "677e2bfab0d5dce4162c36c1"
        
        let logicDict = buildColumnLogicDictionary(
            isShow: false,
            fieldID: dropdownID,
            conditionType: .equals,
            value: .string(yesOptionID)
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: false, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string(yesOptionID))
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [dropdownID: .dropdown, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertFalse(result, "Collection column should hide when dropdown equals 'Yes' and action is hide")
    }
    
    /// Show collection column when text field is not null
    func testCollectionColumnShowOnTextIsNotNull() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: textFieldID,
            conditionType: .isNotNull,
            value: .null
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [textFieldID: .text, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertTrue(result, "Collection column should show when text field is not null")
    }
    
    /// Collection column with no logic, hidden=false -> shows
    func testCollectionColumnWithNoLogicShown() {
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColNumberID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertTrue(result, "Collection column with no logic and hidden=false should show")
    }
    
    /// Collection column with hiddenViews=["mobile"] stays hidden even when logic says show
    func testCollectionColumnHiddenViewsTakesPrecedence() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let forcedHiddenColumn = buildColumn(
            id: collectionColTextID,
            type: .text,
            title: "Force Hidden Column",
            hidden: true,
            logic: Logic(field: logicDict),
            hiddenViews: ["mobile"]
        )
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [forcedHiddenColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID)
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        let result = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertFalse(result, "Collection column with hiddenViews=['mobile'] should be hidden even when condition is met")
    }
    
    /// Collection column refresh: value changes and column visibility updates
    func testCollectionColumnRefreshOnFieldChange() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(50), id: numberFieldID) // initially 50
        document.fields.append(collectionField)
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, collectionFieldID: .collection])
        
        let editor = documentEditor(document: document)
        
        // Initially hidden
        let initialResult = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertFalse(initialResult, "Collection column should be hidden initially (number=50)")
        
        // Change number to 100
        let fieldIdentifier = FieldIdentifier(fieldID: numberFieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .double(100))
        editor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        // Now should show
        let afterResult = editor.shouldShowColumn(columnID: collectionColTextID, fieldID: collectionFieldID, schemaKey: collectionSchemaKey)
        XCTAssertTrue(afterResult, "Collection column should show after number changed to 100")
    }
    
    // MARK: - Page Duplication with Mobile View (Alternate View Path)
    
    /// After mobile view page duplication, column logic conditions should reference new field IDs
    func testMobileViewPageDuplicationRemapsColumnLogicConditions() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        // Desktop page with field positions
        var fpDesktop1 = FieldPosition()
        fpDesktop1.id = "fp_d_number"
        fpDesktop1.field = numberFieldID
        fpDesktop1.type = .number
        var fpDesktop2 = FieldPosition()
        fpDesktop2.id = "fp_d_table"
        fpDesktop2.field = tableFieldID
        fpDesktop2.type = .table
        
        var desktopPage = Page()
        desktopPage.id = pageID
        desktopPage.name = "Page 1"
        desktopPage.hidden = false
        desktopPage.fieldPositions = [fpDesktop1, fpDesktop2]
        
        // Mobile page with same page ID and field positions
        var fpMobile1 = FieldPosition()
        fpMobile1.id = "fp_m_number"
        fpMobile1.field = numberFieldID
        fpMobile1.type = .number
        var fpMobile2 = FieldPosition()
        fpMobile2.id = "fp_m_table"
        fpMobile2.field = tableFieldID
        fpMobile2.type = .table
        
        var mobilePage = Page()
        mobilePage.id = pageID
        mobilePage.name = "Page 1 (mobile)"
        mobilePage.fieldPositions = [fpMobile1, fpMobile2]
        
        var mobileView = ModelView()
        mobileView.id = "view_mobile_1"
        mobileView.type = "mobile"
        mobileView.pages = [mobilePage]
        mobileView.pageOrder = [pageID]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        file.pages = [desktopPage]
        file.views = [mobileView]
        
        var document = JoyDoc()
        document.id = "test_doc_mobile"
        document.type = "document"
        document.identifier = "doc_test_mobile"
        document.name = "Test Document Mobile"
        document.fields = [numberField, tableField]
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        
        // Duplicate the page
        editor.duplicatePage(pageID: pageID)
        
        let duplicatedFields = editor.document.fields
        
        // Find the duplicated table field (new ID, type=table)
        let duplicatedTableFields = duplicatedFields.filter { $0.id != tableFieldID && $0.type == "table" }
        XCTAssertGreaterThanOrEqual(duplicatedTableFields.count, 1, "Should have at least one duplicated table field")
        let duplicatedTable = duplicatedTableFields.first!
        
        // Find the duplicated number field (new ID, type=number)
        let duplicatedNumberFields = duplicatedFields.filter { $0.id != numberFieldID && $0.type == "number" }
        XCTAssertGreaterThanOrEqual(duplicatedNumberFields.count, 1, "Should have at least one duplicated number field")
        let duplicatedNumber = duplicatedNumberFields.first!
        
        // Verify the duplicated table's column logic references the duplicated number field ID
        let duplicatedColumns = duplicatedTable.tableColumns ?? []
        let duplicatedTextColumn = duplicatedColumns.first(where: { $0.id == textColumnID })
        XCTAssertNotNil(duplicatedTextColumn, "Duplicated table should have the text column")
        
        let columnLogic = duplicatedTextColumn?.logic
        XCTAssertNotNil(columnLogic, "Duplicated column should have logic")
        
        let columnConditions = columnLogic?.conditions ?? []
        XCTAssertGreaterThanOrEqual(columnConditions.count, 1, "Column logic should have at least 1 condition")
        
        let conditionFieldRef = columnConditions.first?.field
        XCTAssertNotEqual(conditionFieldRef, numberFieldID, "Column condition should NOT reference original number field ID after mobile view duplication")
        XCTAssertEqual(conditionFieldRef, duplicatedNumber.id, "Column condition should reference the duplicated number field ID")
    }
    
    /// After mobile view page duplication, column logic should evaluate correctly on the duplicated page
    func testMobileViewPageDuplicationColumnLogicEvaluatesCorrectly() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        let tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        // Desktop page
        var fpDesktop1 = FieldPosition()
        fpDesktop1.id = "fp_d_number"
        fpDesktop1.field = numberFieldID
        fpDesktop1.type = .number
        var fpDesktop2 = FieldPosition()
        fpDesktop2.id = "fp_d_table"
        fpDesktop2.field = tableFieldID
        fpDesktop2.type = .table
        
        var desktopPage = Page()
        desktopPage.id = pageID
        desktopPage.name = "Page 1"
        desktopPage.hidden = false
        desktopPage.fieldPositions = [fpDesktop1, fpDesktop2]
        
        // Mobile page
        var fpMobile1 = FieldPosition()
        fpMobile1.id = "fp_m_number"
        fpMobile1.field = numberFieldID
        fpMobile1.type = .number
        var fpMobile2 = FieldPosition()
        fpMobile2.id = "fp_m_table"
        fpMobile2.field = tableFieldID
        fpMobile2.type = .table
        
        var mobilePage = Page()
        mobilePage.id = pageID
        mobilePage.name = "Page 1 (mobile)"
        mobilePage.fieldPositions = [fpMobile1, fpMobile2]
        
        var mobileView = ModelView()
        mobileView.id = "view_mobile_1"
        mobileView.type = "mobile"
        mobileView.pages = [mobilePage]
        mobileView.pageOrder = [pageID]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        file.pages = [desktopPage]
        file.views = [mobileView]
        
        var document = JoyDoc()
        document.id = "test_doc_mobile_eval"
        document.type = "document"
        document.identifier = "doc_test_mobile_eval"
        document.name = "Test Document Mobile Eval"
        document.fields = [numberField, tableField]
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        
        // Verify original column shows
        let originalResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID)
        XCTAssertTrue(originalResult, "Original column should show (number=100)")
        
        // Duplicate the page
        editor.duplicatePage(pageID: pageID)
        
        // Find duplicated table field
        let duplicatedTableFields = editor.document.fields.filter { $0.id != tableFieldID && $0.type == "table" }
        guard let duplicatedTable = duplicatedTableFields.first, let dupTableID = duplicatedTable.id else {
            XCTFail("Could not find duplicated table field")
            return
        }
        
        // Duplicated table's column should also show (duplicated number has value 100)
        let dupResult = editor.shouldShowColumn(columnID: textColumnID, fieldID: dupTableID)
        XCTAssertTrue(dupResult, "Duplicated column on mobile view page should show (duplicated number=100)")
    }
    
    // MARK: - Page Duplication with Collection Column Logic (schema.tableColumns path)
    
    /// After page duplication, collection schema tableColumns logic conditions should reference new field IDs
    func testPageDuplicationRemapsCollectionSchemaColumnLogicConditions() {
        let logicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(100)
        )
        let textColumn = buildColumn(id: collectionColTextID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: logicDict))
        let normalColumn = buildColumn(id: collectionColNumberID, type: .number, title: "Number Column")
        let collectionField = buildCollectionFieldWithColumnLogic(columns: [textColumn, normalColumn], schemaKey: collectionSchemaKey)
        
        var numberField = JoyDocField()
        numberField.type = "number"
        numberField.id = numberFieldID
        numberField.identifier = "field_\(numberFieldID)"
        numberField.title = "Number"
        numberField.value = .double(100)
        numberField.file = fileID
        
        var document = JoyDoc()
        document.id = "test_doc_collection_dup"
        document.type = "document"
        document.identifier = "doc_test_collection_dup"
        document.name = "Test Document Collection Dup"
        document.fields = [numberField, collectionField]
        
        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        
        var page = Page()
        page.id = pageID
        page.name = "Page 1"
        page.hidden = false
        
        var fp1 = FieldPosition()
        fp1.field = numberFieldID
        fp1.id = "fp_number"
        fp1.type = .number
        
        var fp2 = FieldPosition()
        fp2.field = collectionFieldID
        fp2.id = "fp_collection"
        fp2.type = .collection
        
        page.fieldPositions = [fp1, fp2]
        file.pages = [page]
        file.views = []
        document.files = [file]
        
        let editor = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        
        // Duplicate the page
        editor.duplicatePage(pageID: pageID)
        
        let duplicatedFields = editor.document.fields
        
        // Find the duplicated collection field
        let duplicatedCollectionFields = duplicatedFields.filter { $0.id != collectionFieldID && $0.type == "collection" }
        XCTAssertEqual(duplicatedCollectionFields.count, 1, "Should have exactly one duplicated collection field")
        let duplicatedCollection = duplicatedCollectionFields.first!
        
        // Find the duplicated number field
        let duplicatedNumberFields = duplicatedFields.filter { $0.id != numberFieldID && $0.type == "number" }
        XCTAssertEqual(duplicatedNumberFields.count, 1, "Should have exactly one duplicated number field")
        let duplicatedNumber = duplicatedNumberFields.first!
        
        // Get the schema tableColumns from the duplicated collection
        let dupSchema = duplicatedCollection.schema
        XCTAssertNotNil(dupSchema, "Duplicated collection should have schema")
        
        let dupSchemaEntry = dupSchema?[collectionSchemaKey]
        XCTAssertNotNil(dupSchemaEntry, "Duplicated collection should have schema entry for key '\(collectionSchemaKey)'")
        
        let dupSchemaColumns = dupSchemaEntry?.tableColumns ?? []
        let dupTextColumn = dupSchemaColumns.first(where: { $0.id == collectionColTextID })
        XCTAssertNotNil(dupTextColumn, "Duplicated collection schema should have the text column")
        
        let columnLogic = dupTextColumn?.logic
        XCTAssertNotNil(columnLogic, "Duplicated collection column should have logic")
        
        let columnConditions = columnLogic?.conditions ?? []
        XCTAssertEqual(columnConditions.count, 1, "Column logic should have 1 condition")
        
        let conditionFieldRef = columnConditions.first?.field
        XCTAssertNotEqual(conditionFieldRef, numberFieldID, "Collection column condition should NOT reference original number field ID after duplication")
        XCTAssertEqual(conditionFieldRef, duplicatedNumber.id, "Collection column condition should reference the duplicated number field ID")
    }
    
    // MARK: - No Duplicate Refresh When Both Column and Field Logic Depend on Same Field
    
    /// When a table field has both column-level logic and field-level logic depending on the same field,
    /// fieldsNeedsToBeRefreshed should only return the field ID once (not twice).
    func testNoDuplicateRefreshForColumnAndFieldLogicOnSameDependency() {
        // Column logic: show text column when number = 200
        let columnLogicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(200)
        )
        let textColumn = buildColumn(id: textColumnID, type: .text, title: "Text Column", hidden: true, logic: Logic(field: columnLogicDict))
        let normalColumn = buildColumn(id: numberColumnID, type: .number, title: "Number Column")
        var tableField = buildTableFieldWithColumnLogic(tableFieldID: tableFieldID, columns: [textColumn, normalColumn])
        tableField.hidden = true // Table field itself is hidden
        
        // Field-level logic: show table field when number = 200
        let fieldLogicDict = buildColumnLogicDictionary(
            isShow: true,
            fieldID: numberFieldID,
            conditionType: .equals,
            value: .double(200)
        )
        tableField.logic = Logic(field: fieldLogicDict)
        
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(100), id: numberFieldID) // initially 100
        document.fields.append(tableField)
        document = document
            .setFieldPositionToPage(pageId: pageID, idAndTypes: [numberFieldID: .number, tableFieldID: .table])
        
        let editor = documentEditor(document: document)
        
        // Verify initial state: table field hidden, column hidden
        XCTAssertFalse(editor.shouldShow(fieldID: tableFieldID), "Table field should be hidden initially (number=100, show when =200)")
        XCTAssertFalse(editor.shouldShowColumn(columnID: textColumnID, fieldID: tableFieldID), "Column should be hidden initially")
        
        // Directly update the number field value to 200 (bypass updateField/refreshDependent chain)
        editor.fieldMap[numberFieldID]?.value = .double(200)
        
        // Now call fieldsNeedsToBeRefreshed — both column and field visibility should change
        let refreshList = editor.conditionalLogicHandler.fieldsNeedsToBeRefreshed(fieldID: numberFieldID)
        
        // The table field ID should appear exactly once, not twice
        let occurrences = refreshList.filter { $0 == tableFieldID }.count
        XCTAssertEqual(occurrences, 1, "Table field ID should appear exactly once in refresh list, but appeared \(occurrences) times")
    }
}
