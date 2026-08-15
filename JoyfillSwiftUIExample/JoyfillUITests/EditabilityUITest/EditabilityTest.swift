//
//  EditabilityTest.swift
//  JoyfillExample
//
//  Created by Vivek Mac on 14/08/26.
//

import Foundation
import XCTest
import JoyfillModel

final class EditabilityTest: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "EditabilityTest"
    }

    enum TableField: String {
        case inlineAndForm = "Table - inline + form"
        case inlineOnly = "Table - inline only"
        case formOnly = "Table - form only"
        case emptyDefaultsToBoth = "Table - empty defaults to both"
        case typesAFormOnly = "Table - types A form only"
        case typesAInlineOnly = "Table - types A inline only"
        case typesBFormOnly = "Table - types B form only"
        case typesBInlineOnly = "Table - types B inline only"
        case staticTypesFormOnly = "Table - static types form only"
        case uppercaseEditability = "Table - uppercase editability"
        case unrecognizedEditability = "Table - unrecognized editability"
        case duplicateInlineEditability = "Table - duplicate inline editability"
    }

    enum CollectionField: String {
        case perLevelMix = "Collection - per level mix (root both / L1 form / L2 inline)"
        case inlineOnly = "Collection - inline only (no form anywhere, icon gutter gone)"
        case formOnly = "Collection - form only (single schema)"
        case defaultsMixed = "Collection - defaults mixed with explicit (root empty / L1 absent / L2 inline / L3 form)"
        case fieldLevelVsSchemaLevel = "Collection - field level inline, schema level form"
    }

    private func detailViewButton(below fieldTitle: String, identifier: String) -> XCUIElement? {
        let title = app.staticTexts[fieldTitle]
        guard title.exists else { return nil }
        let titleBottom = title.frame.maxY
        let buttons = app.buttons.matching(identifier: identifier)
        var nearest: XCUIElement?
        for index in 0..<buttons.count {
            let candidate = buttons.element(boundBy: index)
            guard candidate.exists, candidate.frame.minY >= titleBottom else { continue }
            if nearest == nil || candidate.frame.minY < nearest!.frame.minY {
                nearest = candidate
            }
        }
        return nearest
    }

    private func nudge(up: Bool) {
        let from = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.7 : 0.5))
        let to = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: up ? 0.5 : 0.7))
        from.press(forDuration: 0.05, thenDragTo: to)
    }

    private func openDetailView(fieldTitle: String, identifier: String, maxAttempts: Int = 60) {
        var sawTitle = false
        for _ in 0..<maxAttempts {
            if app.staticTexts[fieldTitle].exists {
                sawTitle = true
                if let button = detailViewButton(below: fieldTitle, identifier: identifier), button.isHittable {
                    let frame = button.frame
                    app.coordinate(withNormalizedOffset: .zero)
                        .withOffset(CGVector(dx: frame.midX, dy: frame.midY))
                        .tap()
                    XCTAssertTrue(waitForAppStability(timeout: 5), "\"\(fieldTitle)\" did not settle after navigation")
                    if app.buttons.matching(identifier: identifier).count == 0 {
                        if app.staticTexts[fieldTitle].exists { return }
                        goBack()
                        _ = waitForAppStability(timeout: 5)
                    }
                }
                nudge(up: true)
            } else if sawTitle {
                nudge(up: false)
            } else {
                app.swipeUp()
            }
            _ = waitForAppStability(timeout: 3)
        }
        XCTFail("Never reached the detail-view button for \"\(fieldTitle)\"")
    }

    func navigateToTable(_ field: TableField) {
        openDetailView(fieldTitle: field.rawValue, identifier: "TableDetailViewIdentifier")
    }

    func navigateToCollection(_ field: CollectionField) {
        openDetailView(fieldTitle: field.rawValue, identifier: "CollectionDetailViewIdentifier")
    }

    private func selectSingleTableRow(number: Int) {
        app.images.matching(identifier: "MyButton").element(boundBy: number).tap()
    }

    private func selectSingleCollectionRow(number: Int) {
        app.images.matching(identifier: "selectRowItem\(number + 1)").element.tap()
    }

    private func selectNestedCollectionRow(index: Int, occurrence: Int = 0) {
        app.images.matching(identifier: "selectNestedRowItem\(index)").element(boundBy: occurrence).tap()
    }

    private func tapMoreButton() {
        app.buttons["TableMoreButtonIdentifier"].tap()
    }

    private var pencilPredicate: NSPredicate {
        NSPredicate(format: "identifier CONTAINS 'SingleClickEdit'")
    }

    private var nestedPencilPredicate: NSPredicate {
        NSPredicate(format: "identifier CONTAINS 'SingleClickEditNestedButton'")
    }

    private func replaceText(in element: XCUIElement, with text: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Field to replace text in never appeared")
        element.tap()
        element.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) {
            app.menuItems["Select All"].tap()
        }
        element.typeText(text)
    }

    private func goBackAndSettle() {
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
    }

    // MARK: - Launch arguments (goto / document mode)

    private static let pageID = "6a391e434954ed9d02ebbf70"

    private static let gotoRowTargets: [String: String] = [
        "testGotoOpenRowForm_TableFormOnly_OpensRowForm": "6a79ae71c2b2398a578f918f/6a797ced206e8afc73c971df",
        "testGotoOpenRowForm_TableInlineOnly_DoesNotOpenRowForm": "6a79ae70a67d8b4625abfac2/6a797ced206e8afc73c971df",
        "testGotoOpenRowForm_TableDefaults_OpensRowForm": "6a79ae73414740ff418bc250/6a797ced206e8afc73c971df",
        "testGotoOpenRowForm_CollectionFormOnly_OpensRowForm": "6a7b0855b3c8004574f756d1/6a7b0902cccc0000000000a1",
        "testGotoOpenRowForm_CollectionInlineOnly_DoesNotOpenRowForm": "6a7b0853a36150df0b8487c9/6a7b0901bbbb0000000000a1",
        "testGotoOpenRowForm_CollectionLevel1FormOnly_OpensRowForm": "6a7b084fe6d815149839fbb3/6a7b0900aaaa0000000000b1",
        "testGotoOpenRowForm_CollectionLevel2InlineOnly_DoesNotOpenRowForm": "6a7b084fe6d815149839fbb3/6a7b0900aaaa0000000000c1",
    ]

    private static let readonlyDocumentTests: Set<String> = [
        "testReadonlyDocument_InlineOnlyTableStaysReadonlyInGrid",
        "testReadonlyDocument_FormOnlyTableKeepsPencilButRowFormIsDisabled",
        "testReadonlyDocument_InlineOnlyCollectionStaysReadonly",
    ]

    /// Extracts the test method name from XCTest's `name` (e.g. "-[Module.Class methodName]" -> "methodName").
    private func currentTestSelector(from name: String) -> String {
        let trimmed = name.hasSuffix("]") ? String(name.dropLast()) : name
        return trimmed.split(separator: " ").last.map(String.init) ?? name
    }

    override func getGotoLaunchArguments() -> [(String, String?)] {
        let selector = currentTestSelector(from: self.name)
        var arguments: [(String, String?)] = []
        if let target = Self.gotoRowTargets[selector] {
            arguments.append(("--goto-path", "\(Self.pageID)/\(target)"))
            arguments.append(("--goto-open", nil))
        }
        if Self.readonlyDocumentTests.contains(selector) {
            arguments.append(("--mode", "readonly"))
        }
        return arguments
    }

    // MARK: - Table: inline + form

    func testTableInlineAndForm_GridEditableAndPencilOpensRowForm() throws {
        navigateToTable(.inlineAndForm)

        let cell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Grid text cell should be editable when inline is allowed")
        cell.tap()
        cell.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        cell.typeText("T1 R1 - inline + form edited")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["text1"]?.text, "T1 R1 - inline + form edited")

        navigateToTable(.inlineAndForm)
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertTrue(dropdownButtons.element(boundBy: 0).isEnabled, "Dropdown should be editable in the grid when inline is allowed")

        let pencil = app.images["SingleClickEditButton0"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "Pencil should be visible when form editing is allowed")
        pencil.tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5), "Pencil should open the single-row form")
        XCTAssertTrue(app.textFields["EditRowsTextFieldIdentifier"].firstMatch.exists)
    }

    // MARK: - Table: inline only

    func testTableInlineOnly_GridEditableAndPencilHidden() throws {
        navigateToTable(.inlineOnly)

        let cell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Grid text cell should still be editable when inline is allowed")

        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertTrue(dropdownButtons.element(boundBy: 0).isEnabled, "Dropdown should be editable in the grid")

        XCTAssertFalse(app.images["SingleClickEditButton0"].exists, "Pencil column must not render when form editing is disallowed")
    }

    func testTableInlineOnly_EditRowsMenuHiddenForSingleSelection() throws {
        navigateToTable(.inlineOnly)
        selectSingleTableRow(number: 0)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableMoveUpRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "Single-row form editing must be hidden when form is disallowed")
    }

    func testTableInlineOnly_EditRowsMenuVisibleForMultiSelection() throws {
        navigateToTable(.inlineOnly)
        selectSingleTableRow(number: 0)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "Bulk edit must remain available when inline is allowed")
    }

    // MARK: - Table: form only

    func testTableFormOnly_GridReadonlyDropdownDisabledAndScrollWrapperExists() throws {
        navigateToTable(.formOnly)

        XCTAssertFalse(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).exists, "Grid text cell must not be editable when inline is disallowed")

        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertTrue(readonlyCells.element(boundBy: 0).waitForExistence(timeout: 5), "Grid text cell should render read-only")

        let scrollWrapper = app.descendants(matching: .any).matching(identifier: "TableTextFieldReadonlyScrollView").firstMatch
        XCTAssertTrue(scrollWrapper.exists, "Read-only cell should still be wrapped in the scrollable container so long text can scroll")

        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertFalse(dropdownButtons.element(boundBy: 0).isEnabled, "Dropdown must be disabled in the grid when inline is disallowed")
    }

    func testTableFormOnly_PencilOpensRowFormAndEditWritesThroughToGrid() throws {
        navigateToTable(.formOnly)

        let pencil = app.images["SingleClickEditButton0"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "Pencil should be visible when form editing is allowed")
        pencil.tap()

        let textField = app.textFields["EditRowsTextFieldIdentifier"].firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        textField.typeText("Form only R1 updated via row form")

        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertTrue(dropdownButton.waitForExistence(timeout: 5))
        dropdownButton.tap()
        app.buttons.matching(identifier: "TableDropdownOptionsIdentifier").element(boundBy: 1).tap()

        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")

        let row0 = onChangeResultValue().valueElements?.first
        XCTAssertEqual(row0?.cells?["6a797cede3b86e6d6277b967"]?.text, "Form only R1 updated via row form")
        XCTAssertEqual(row0?.cells?["6a797ced6c81cf76ad5fe0c8"]?.text, "6a797ced010536d7c11f40b1")

        navigateToTable(.formOnly)
        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertEqual(readonlyCells.element(boundBy: 0).label, "Form only R1 updated via row form")
        XCTAssertEqual(app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0).label, "No")
    }

    func testTableFormOnly_EditRowsMenuVisibleForSingleSelection() throws {
        navigateToTable(.formOnly)
        selectSingleTableRow(number: 0)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "Single-row form editing must stay available when form is allowed")
    }

    func testTableFormOnly_EditRowsMenuHiddenForMultiSelection() throws {
        navigateToTable(.formOnly)
        selectSingleTableRow(number: 0)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        // Move Up/Down only render for single-row selection, so use Delete (always present) to
        // confirm the popover opened.
        XCTAssertTrue(app.buttons["TableDeleteRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "Bulk edit must be hidden when inline editing is disallowed")
    }

    func testTableFormOnly_RowStructuralOperationsStillWork() throws {
        navigateToTable(.formOnly)
        selectSingleTableRow(number: 0)
        tapMoreButton()
        app.buttons["TableDeleteRowIdentifier"].tap()
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        // Row deletion is a soft delete: the change event's value array retains all rows and
        // flags the removed one with `deleted: true` rather than shrinking the array.
        XCTAssertEqual(onChangeResultValue().valueElements?.filter { !($0.deleted ?? false) }.count, 2, "Row deletion must still work even though the grid is locked to form-only editing")
    }

    // MARK: - Table: empty array defaults to both

    func testTableEmptyDefaultsToBoth_BehavesLikeInlineAndForm() throws {
        navigateToTable(.emptyDefaultsToBoth)

        let cell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Grid text cell should be editable by default")

        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertTrue(dropdownButtons.element(boundBy: 0).isEnabled, "Dropdown should be editable by default")

        XCTAssertTrue(app.images["SingleClickEditButton0"].waitForExistence(timeout: 5), "Pencil should be visible by default")
    }

    // MARK: - Collection: per-level mix (root both / L1 form / L2 inline)

    func testCollectionPerLevelMix_RootEditableWithPencilOpensForm() throws {
        navigateToCollection(.perLevelMix)

        let cell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Root row should be editable when inline is allowed")

        // Collection root rows are 1-indexed (CollectionViewModel's displayIndex starts at 1).
        let pencil = app.images["SingleClickEditButton1"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "Root pencil should be visible when form editing is allowed")
        pencil.tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))
    }

    func testCollectionPerLevelMix_L1ReadonlyWithPencilOpensForm() throws {
        navigateToCollection(.perLevelMix)

        XCTAssertEqual(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").count, 0, "Nothing should be read-only before expanding")

        app.images["CollectionExpandCollapseButton1"].tap()

        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertTrue(readonlyCells.element(boundBy: 0).waitForExistence(timeout: 5), "L1 rows should render read-only since inline editing is disallowed at L1")
        XCTAssertEqual(readonlyCells.count, 2, "Both L1 rows should be read-only")

        let nestedPencilPredicate = NSPredicate(format: "identifier CONTAINS 'SingleClickEditNestedButton'")
        XCTAssertEqual(app.images.matching(nestedPencilPredicate).count, 2, "Both L1 rows should show a pencil since form editing is allowed at L1")

        app.images.matching(nestedPencilPredicate).element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5), "L1 pencil should open the row form")
    }

    func testCollectionPerLevelMix_L2EditableWithBlankPencilSlot() throws {
        navigateToCollection(.perLevelMix)

        app.images["CollectionExpandCollapseButton1"].tap()
        let nestedPencilPredicate = NSPredicate(format: "identifier CONTAINS 'SingleClickEditNestedButton'")
        XCTAssertEqual(app.images.matching(nestedPencilPredicate).count, 2, "L1 rows both have pencils before expanding L2")

        let editableCountBeforeL2 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").count

        // At this point only L1 rows exist as nested rows, so "...NestedButton1" unambiguously
        // refers to L1's own (first) row expand control.
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        let editableCountAfterL2 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").count
        XCTAssertEqual(editableCountAfterL2, editableCountBeforeL2 + 2, "The two L2 rows should render editable text cells since inline is allowed at L2")
        XCTAssertEqual(app.images.matching(nestedPencilPredicate).count, 2, "L2 rows must not add pencils since form editing is disallowed there, but the gutter stays reserved for L1")
    }

    // MARK: - Collection: inline only (no form anywhere)

    func testCollectionInlineOnly_NoPencilGutterAnywhere() throws {
        navigateToCollection(.inlineOnly)

        let pencilPredicate = NSPredicate(format: "identifier CONTAINS 'SingleClickEdit'")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 0, "No pencil gutter should render at root when no schema level allows form editing")
        XCTAssertEqual(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").count, 0, "Root row should be editable")

        app.images["CollectionExpandCollapseButton1"].tap()

        XCTAssertEqual(app.images.matching(pencilPredicate).count, 0, "No pencil gutter should render at L1 either")
        XCTAssertEqual(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").count, 0, "L1 rows should also be editable")
        XCTAssertGreaterThan(app.textViews.matching(identifier: "TabelTextFieldIdentifier").count, 1, "Root and L1 cells should both be editable")
    }

    func testCollectionInlineOnly_EditRowsMenuHiddenForSingleSelection() throws {
        navigateToCollection(.inlineOnly)
        selectSingleCollectionRow(number: 0)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableMoveUpRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "Single-row form editing must be hidden when form is disallowed")
    }

    func testCollectionInlineOnly_EditRowsMenuVisibleForMultiSelection() throws {
        navigateToCollection(.inlineOnly)
        selectSingleCollectionRow(number: 0)
        selectSingleCollectionRow(number: 1)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "Bulk edit must remain available when inline is allowed")
    }

    // MARK: - Collection: form only (single schema)

    func testCollectionFormOnly_RootReadonlyPencilWritesThroughToGrid() throws {
        navigateToCollection(.formOnly)

        XCTAssertFalse(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).exists, "Root row must not be editable in the grid")
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertFalse(dropdownButtons.element(boundBy: 0).isEnabled, "Dropdown must be disabled in the grid")

        let pencil = app.images["SingleClickEditButton1"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        pencil.tap()

        let textField = app.textFields["EditRowsTextFieldIdentifier"].firstMatch
        textField.waitAndClearAndTypeText("Row 1 updated via row form")

        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")

        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["6813008e76da519a97819c69"]?.text, "Row 1 updated via row form")

        navigateToCollection(.formOnly)
        XCTAssertEqual(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).label, "Row 1 updated via row form")
    }

    func testCollectionFormOnly_EditRowsMenuVisibleForSingleSelection() throws {
        navigateToCollection(.formOnly)
        selectSingleCollectionRow(number: 0)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "Single-row form editing must stay available when form is allowed")
    }

    func testCollectionFormOnly_EditRowsMenuHiddenForMultiSelection() throws {
        navigateToCollection(.formOnly)
        selectSingleCollectionRow(number: 0)
        selectSingleCollectionRow(number: 1)
        tapMoreButton()
        // Move Up/Down only render for single-row selection, so use Delete (always present) to
        // confirm the popover opened.
        XCTAssertTrue(app.buttons["TableDeleteRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "Bulk edit must be hidden when inline editing is disallowed")
    }

    func testCollectionFormOnly_RowStructuralOperationsStillWork() throws {
        navigateToCollection(.formOnly)
        selectSingleCollectionRow(number: 0)
        tapMoreButton()
        app.buttons["TableDeleteRowIdentifier"].tap()
        goBack()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        // Row deletion is a soft delete: the change event's value array retains all rows and
        // flags the removed one with `deleted: true` rather than shrinking the array.
        XCTAssertEqual(onChangeResultValue().valueElements?.filter { !($0.deleted ?? false) }.count, 2, "Row deletion must still work even though the grid is locked to form-only editing")
    }

    // MARK: - Collection: defaults mixed (root empty / L1 absent / L2 inline / L3 form)

    func testCollectionDefaultsMixed_EditabilityAcrossAllLevels() throws {
        navigateToCollection(.defaultsMixed)

        XCTAssertTrue(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5), "Root should default to editable when editability is an empty array")
        XCTAssertTrue(app.images["SingleClickEditButton1"].waitForExistence(timeout: 5), "Root should default to showing a pencil when editability is an empty array")

        app.images["CollectionExpandCollapseButton1"].tap()

        XCTAssertTrue(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1).waitForExistence(timeout: 5), "L1 should default to editable when the editability key is absent")
        XCTAssertTrue(app.images["SingleClickEditNestedButton1"].waitForExistence(timeout: 5), "L1 should default to showing a pencil when the editability key is absent")

        let pencilPredicate = NSPredicate(format: "identifier CONTAINS 'SingleClickEdit'")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 2, "Only root and L1 should show pencils so far")

        // Each parent row's nested-child index restarts at 1 (CollectionViewModel resets
        // displayIndex per parent), so at this point "...NestedButton1" unambiguously refers
        // to L1's own (only) row expand control -- no L2 rows exist yet to collide with it.
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        XCTAssertEqual(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").count, 0, "L2 rows should stay editable since L2 is inline-only")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 2, "L2 must not add pencils since form editing is disallowed at L2")

        // Now L2's first row ALSO restarts its local index at 1, so it shares the identifier
        // "CollectionExpandCollapseNestedButton1" with L1's own (already-expanded) button. Grab
        // the last match, which is L2's own not-yet-expanded control (it renders after its parent).
        let nestedExpandButtons1 = app.images.matching(identifier: "CollectionExpandCollapseNestedButton1")
        nestedExpandButtons1.element(boundBy: nestedExpandButtons1.count - 1).tap()

        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertEqual(readonlyCells.count, 2, "L3 rows should render read-only since inline editing is disallowed at L3")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 4, "L3 rows should each add a pencil since form editing is allowed at L3")

        app.images.matching(pencilPredicate).element(boundBy: 2).tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5), "L3 pencil should open the row form even at the deepest level")
    }

    // MARK: - Column types A (number / date / image)

    // Every interactive cell type is gated by the same `.disabled(cellModel.editMode == .readonly)`
    // in TableViewCellBuilder, so `editMode` has to reach each of them -- not just text and
    // dropdown, which the earlier tests already cover.

    func testTableTypesAFormOnly_NumberDateImageCellsDisabledInGrid() throws {
        navigateToTable(.typesAFormOnly)

        let number = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(number.waitForExistence(timeout: 5), "Number cell still renders when inline editing is disallowed")
        XCTAssertFalse(number.isEnabled, "Number cell must be disabled when inline editing is disallowed")

        let date = app.buttons.matching(identifier: "ChangeCellDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(date.waitForExistence(timeout: 5))
        XCTAssertFalse(date.isEnabled, "Date cell must be disabled when inline editing is disallowed")

        let image = app.buttons.matching(identifier: "TableImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        XCTAssertFalse(image.isEnabled, "Image cell must be disabled when inline editing is disallowed")
    }

    func testTableTypesAFormOnly_RowFormExposesNumberDateImageFields() throws {
        navigateToTable(.typesAFormOnly)

        let pencil = app.images["SingleClickEditButton0"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        pencil.tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))

        // The row form wraps each cell in a container carrying an `EditRows*FieldIdentifier`,
        // and a SwiftUI accessibility identifier on a wrapper replaces the identifiers of the
        // elements it contains -- so the grid-level names (`TabelNumberFieldIdentifier` etc.)
        // are not reachable in here.
        let number = app.textFields["EditRowsNumberFieldIdentifier"]
        XCTAssertTrue(number.waitForExistence(timeout: 5), "Row form should expose the number column")
        XCTAssertTrue(number.isEnabled, "Number field must stay editable inside the row form even though the grid is locked")

        let date = app.buttons["EditRowsDateFieldIdentifier"]
        XCTAssertTrue(date.exists, "Row form should expose the date column")
        XCTAssertTrue(date.isEnabled)

        let image = app.buttons["EditRowsImageFieldIdentifier"]
        XCTAssertTrue(image.exists, "Row form should expose the image column")
        XCTAssertTrue(image.isEnabled)
    }

    func testTableTypesAFormOnly_NumberEditInRowFormWritesThrough() throws {
        navigateToTable(.typesAFormOnly)

        app.images["SingleClickEditButton0"].tap()
        let number = app.textFields["EditRowsNumberFieldIdentifier"]
        replaceText(in: number, with: "915")

        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBackAndSettle()

        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["7b01a1000000000000000000"]?.number, 915)
    }

    func testTableTypesAInlineOnly_NumberDateImageCellsEnabledInGrid() throws {
        navigateToTable(.typesAInlineOnly)

        let number = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(number.waitForExistence(timeout: 5))
        XCTAssertTrue(number.isEnabled, "Number cell should be editable when inline editing is allowed")

        let date = app.buttons.matching(identifier: "ChangeCellDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(date.waitForExistence(timeout: 5))
        XCTAssertTrue(date.isEnabled, "Date cell should be editable when inline editing is allowed")

        let image = app.buttons.matching(identifier: "TableImageIdentifier").element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        XCTAssertTrue(image.isEnabled, "Image cell should be editable when inline editing is allowed")
    }

    func testTableTypesAInlineOnly_PencilHiddenAndSlotNotReserved() throws {
        navigateToTable(.typesAInlineOnly)
        XCTAssertTrue(app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 0, "No pencil should render when form editing is disallowed")
    }

    func testTableTypesAInlineOnly_NumberEditInGridWritesThrough() throws {
        navigateToTable(.typesAInlineOnly)

        let number = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        replaceText(in: number, with: "321")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["7b01a1000000000000000000"]?.number, 321)
    }

    // MARK: - Column types B (signature / barcode / multiSelect)

    func testTableTypesBFormOnly_SignatureBarcodeMultiSelectLockedInGrid() throws {
        navigateToTable(.typesBFormOnly)

        let barcodeReadonly = app.staticTexts.matching(identifier: "TableBarcodeFieldIdentifierReadonly").element(boundBy: 0)
        XCTAssertTrue(barcodeReadonly.waitForExistence(timeout: 5), "Barcode cell should take its read-only branch when inline editing is disallowed")
        XCTAssertFalse(app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0).exists, "Barcode cell must not render an editor")

        let signature = app.buttons.matching(identifier: "TableSignatureOpenSheetButton").element(boundBy: 0)
        XCTAssertTrue(signature.waitForExistence(timeout: 5))
        XCTAssertFalse(signature.isEnabled, "Signature cell must be disabled when inline editing is disallowed")

        let multiSelect = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(multiSelect.waitForExistence(timeout: 5))
        XCTAssertFalse(multiSelect.isEnabled, "MultiSelect cell must be disabled when inline editing is disallowed")
    }

    func testTableTypesBFormOnly_RowFormExposesSignatureBarcodeMultiSelectFields() throws {
        navigateToTable(.typesBFormOnly)

        app.images["SingleClickEditButton0"].tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))

        // The row form runs at the document mode, not the grid mode, so every cell takes its
        // editable branch here even though the same cells are locked in the grid. Cells are
        // addressed by their `EditRows*FieldIdentifier` wrapper, which replaces the grid-level
        // identifier of whatever it contains.
        let barcode = app.textViews["EditRowsBarcodeFieldIdentifier"]
        XCTAssertTrue(barcode.waitForExistence(timeout: 5), "Barcode must be editable inside the row form")
        XCTAssertEqual(barcode.value as? String, "BAR-111")

        let signature = app.buttons["EditRowsSignatureFieldIdentifier"]
        XCTAssertTrue(signature.exists, "Row form should expose the signature column")
        XCTAssertTrue(signature.isEnabled, "Signature must be enabled inside the row form")

        let multiSelect = app.buttons["EditRowsMultiSelecionFieldIdentifier"]
        XCTAssertTrue(multiSelect.exists, "Row form should expose the multiSelect column")
        XCTAssertTrue(multiSelect.isEnabled, "MultiSelect must be enabled inside the row form")
    }

    func testTableTypesBFormOnly_BarcodeEditInRowFormWritesThrough() throws {
        navigateToTable(.typesBFormOnly)

        app.images["SingleClickEditButton0"].tap()
        let barcode = app.textViews["EditRowsBarcodeFieldIdentifier"]
        replaceText(in: barcode, with: "BAR-ROWFORM")

        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBackAndSettle()

        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["7b02a2000000000000000000"]?.text, "BAR-ROWFORM")
    }

    func testTableTypesBInlineOnly_SignatureBarcodeMultiSelectEditableInGrid() throws {
        navigateToTable(.typesBInlineOnly)

        XCTAssertTrue(app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5), "Barcode cell should take its editable branch when inline editing is allowed")
        XCTAssertEqual(app.staticTexts.matching(identifier: "TableBarcodeFieldIdentifierReadonly").count, 0, "No barcode cell should be read-only")

        XCTAssertTrue(app.buttons.matching(identifier: "TableSignatureOpenSheetButton").element(boundBy: 0).isEnabled, "Signature cell should be enabled when inline editing is allowed")
        XCTAssertTrue(app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier").element(boundBy: 0).isEnabled, "MultiSelect cell should be enabled when inline editing is allowed")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 0, "No pencil should render when form editing is disallowed")
    }

    func testTableTypesBInlineOnly_BarcodeEditInGridWritesThrough() throws {
        navigateToTable(.typesBInlineOnly)

        let barcode = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        replaceText(in: barcode, with: "BAR-GRID")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        XCTAssertEqual(onChangeResultValue().valueElements?.first?.cells?["7b02a2000000000000000000"]?.text, "BAR-GRID")
    }

    // MARK: - Static column types (block / progress) and required columns

    func testTableStaticTypesFormOnly_BlockAndProgressRenderRegardlessOfEditability() throws {
        navigateToTable(.staticTypesFormOnly)

        // `block` and `progress` are the two cases TableViewCellBuilder deliberately leaves
        // un-disabled. Neither is interactive, so a locked grid must not blank them out.
        let blocks = app.staticTexts.matching(identifier: "TabelBlockFieldIdentifier")
        XCTAssertTrue(blocks.element(boundBy: 0).waitForExistence(timeout: 5), "Block cells must still render in a form-only grid")
        XCTAssertEqual(blocks.count, 2, "Both rows should render their block cell")
        XCTAssertEqual(blocks.element(boundBy: 0).label, "Static block copy R1")

        // One required column, filled in row 1 and empty in row 2.
        XCTAssertTrue(app.staticTexts["1/1"].exists, "Progress cell should report the filled required column for row 1")
        XCTAssertTrue(app.staticTexts["0/1"].exists, "Progress cell should report the empty required column for row 2")
    }

    func testTableStaticTypesFormOnly_RequiredTextReadonlyInGridButEditableInRowForm() throws {
        navigateToTable(.staticTypesFormOnly)

        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 5), "A required column is still subject to inline editability")
        XCTAssertFalse(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).exists)

        app.images["SingleClickEditButton1"].tap()
        let textField = app.textFields["EditRowsTextFieldIdentifier"].firstMatch
        replaceText(in: textField, with: "Required filled via row form")
        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")

        // Filling the required column flips row 2's progress cell.
        XCTAssertTrue(app.staticTexts["1/1"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["0/1"].exists, "Row 2's required column is now filled")

        goBackAndSettle()
        XCTAssertEqual(onChangeResultValue().valueElements?.last?.cells?["7b03a1000000000000000000"]?.text, "Required filled via row form")
    }

    func testTableStaticTypesFormOnly_BlockIsNeverEditableInTheRowForm() throws {
        navigateToTable(.staticTypesFormOnly)

        app.images["SingleClickEditButton0"].tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts.matching(identifier: "TabelBlockFieldIdentifier").firstMatch.exists, "Block should render as static copy inside the row form")
        // Only the required text column is editable; block and progress contribute no editors.
        XCTAssertEqual(app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").count, 1, "Only the text column should produce an editable row-form field")
    }

    // MARK: - Goto: openRowForm is gated by form editability

    // `goto(open: true)` reaches four call sites that all AND the request with `canOpenRowForm`.
    // The modal always opens; only the row-form sheet is gated.

    func testGotoOpenRowForm_TableFormOnly_OpensRowForm() throws {
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 15), "goto(open:) should open the row form when form editing is allowed")
    }

    func testGotoOpenRowForm_TableInlineOnly_DoesNotOpenRowForm() throws {
        XCTAssertTrue(app.buttons["TableMoreButtonIdentifier"].waitForExistence(timeout: 15), "goto should still open the table modal")
        XCTAssertFalse(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].exists, "goto(open:) must not open the row form when form editing is disallowed")
    }

    func testGotoOpenRowForm_TableDefaults_OpensRowForm() throws {
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 15), "goto(open:) should open the row form when editability defaults to both")
    }

    func testGotoOpenRowForm_CollectionFormOnly_OpensRowForm() throws {
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 15), "goto(open:) should open the row form for a form-only collection schema")
    }

    func testGotoOpenRowForm_CollectionInlineOnly_DoesNotOpenRowForm() throws {
        XCTAssertTrue(app.buttons["TableMoreButtonIdentifier"].waitForExistence(timeout: 15), "goto should still open the collection modal")
        XCTAssertFalse(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].exists, "goto(open:) must not open the row form for an inline-only collection schema")
    }

    func testGotoOpenRowForm_CollectionLevel1FormOnly_OpensRowForm() throws {
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 15), "goto(open:) should resolve the target row's own schema level, not the root's")
    }

    func testGotoOpenRowForm_CollectionLevel2InlineOnly_DoesNotOpenRowForm() throws {
        XCTAssertTrue(app.buttons["TableMoreButtonIdentifier"].waitForExistence(timeout: 15), "goto should still open the collection modal and expand to the nested row")
        XCTAssertFalse(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].exists, "goto(open:) must respect the nested row's own schema level")
    }

    // MARK: - Bulk edit sheet (multi-selection, gated on inlineAllowed)

    func testTableInlineOnly_BulkEditAppliesTextToAllSelectedRows() throws {
        navigateToTable(.inlineOnly)
        selectSingleTableRow(number: 0)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()

        let textField = app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Bulk applied text")

        let applyAll = app.buttons["ApplyAllButtonIdentifier"]
        XCTAssertTrue(applyAll.waitForExistence(timeout: 5), "Apply All should be available for a multi-row selection")
        applyAll.tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        let rows = onChangeResultValue().valueElements
        XCTAssertEqual(rows?[0].cells?["6a797cede3b86e6d6277b967"]?.text, "Bulk applied text")
        XCTAssertEqual(rows?[1].cells?["6a797cede3b86e6d6277b967"]?.text, "Bulk applied text")
        XCTAssertNotEqual(rows?[2].cells?["6a797cede3b86e6d6277b967"]?.text, "Bulk applied text", "Unselected rows must be left alone")
    }

    func testTableInlineOnly_BulkEditAppliesDropdownToAllSelectedRows() throws {
        navigateToTable(.inlineOnly)
        selectSingleTableRow(number: 0)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()

        let dropdown = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertTrue(dropdown.waitForExistence(timeout: 5))
        dropdown.tap()
        app.buttons.matching(identifier: "TableDropdownOptionsIdentifier").element(boundBy: 1).tap()

        app.buttons["ApplyAllButtonIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        let rows = onChangeResultValue().valueElements
        XCTAssertEqual(rows?[0].cells?["6a797ced6c81cf76ad5fe0c8"]?.text, "6a797ced010536d7c11f40b1")
        XCTAssertEqual(rows?[1].cells?["6a797ced6c81cf76ad5fe0c8"]?.text, "6a797ced010536d7c11f40b1")
    }

    func testTableFormOnly_SingleRowFormHasNoApplyAllButton() throws {
        navigateToTable(.formOnly)
        app.images["SingleClickEditButton0"].tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["ApplyAllButtonIdentifier"].exists, "A single-row form edits in place -- Apply All belongs to bulk edit only")
        XCTAssertTrue(app.buttons["UpperRowButtonIdentifier"].exists, "The single-row form should offer row stepping instead")
    }

    func testTableEmptyDefaultsToBoth_BulkEditIsAvailable() throws {
        navigateToTable(.emptyDefaultsToBoth)
        selectSingleTableRow(number: 0)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        XCTAssertTrue(app.buttons["ApplyAllButtonIdentifier"].waitForExistence(timeout: 5), "Bulk edit should be reachable when editability defaults to both")
    }

    func testCollectionInlineOnly_BulkEditAppliesTextToAllSelectedRows() throws {
        navigateToCollection(.inlineOnly)
        selectSingleCollectionRow(number: 0)
        selectSingleCollectionRow(number: 1)
        tapMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()

        let textField = app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Collection bulk text")

        app.buttons["ApplyAllButtonIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        let rows = onChangeResultValue().valueElements
        XCTAssertEqual(rows?[0].cells?["6813008e76da519a97819c69"]?.text, "Collection bulk text")
        XCTAssertEqual(rows?[1].cells?["6813008e76da519a97819c69"]?.text, "Collection bulk text")
    }

    // MARK: - Collection nested-row selection resolves the selection's own schema level

    func testCollectionPerLevelMix_NestedLevel1SingleSelectionShowsEditRows() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()

        selectNestedCollectionRow(index: 1)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "L1 is form-only, so a single nested selection can open the row form")
    }

    func testCollectionPerLevelMix_NestedLevel1MultiSelectionHidesEditRows() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()

        selectNestedCollectionRow(index: 1)
        selectNestedCollectionRow(index: 2)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableDeleteRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "L1 disallows inline editing, so bulk edit must be hidden there")
    }

    func testCollectionPerLevelMix_NestedLevel2SingleSelectionHidesEditRows() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        // L1's rows come first in document order, then L1 row 1's children, so the second
        // occurrence of "selectNestedRowItem1" is L2's first row.
        selectNestedCollectionRow(index: 1, occurrence: 1)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableMoveUpRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "L2 disallows form editing, so a single nested selection must not offer the row form")
    }

    func testCollectionPerLevelMix_NestedLevel2MultiSelectionShowsEditRows() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        selectNestedCollectionRow(index: 1, occurrence: 1)
        selectNestedCollectionRow(index: 2, occurrence: 0)
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "L2 allows inline editing, so bulk edit must stay available there")
    }

    // MARK: - Write-through at nested schema levels

    func testCollectionPerLevelMix_Level1RowFormEditWritesThrough() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()

        let pencil = app.images.matching(nestedPencilPredicate).element(boundBy: 0)
        XCTAssertTrue(pencil.waitForExistence(timeout: 5))
        pencil.tap()

        let textField = app.textFields["EditRowsTextFieldIdentifier"].firstMatch
        replaceText(in: textField, with: "L1 edited via row form")
        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBackAndSettle()

        let level1 = onChangeResultValue().valueElements?.first?.childrens?["level1Table1"]?.valueToValueElements
        XCTAssertEqual(level1?.first?.cells?["6a7b0860de34a60cf9608a49"]?.text, "L1 edited via row form")
    }

    func testCollectionPerLevelMix_Level2InlineEditWritesThrough() throws {
        navigateToCollection(.perLevelMix)
        app.images["CollectionExpandCollapseButton1"].tap()
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        // Root row 1 is editable too, so its cell is the first editable text view; L2's first
        // row supplies the next one.
        let cells = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        XCTAssertTrue(cells.element(boundBy: 1).waitForExistence(timeout: 5))
        replaceText(in: cells.element(boundBy: 1), with: "L2 edited inline")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        let level2 = onChangeResultValue().valueElements?.first?
            .childrens?["level1Table1"]?.valueToValueElements?.first?
            .childrens?["level2Table1"]?.valueToValueElements
        XCTAssertEqual(level2?.first?.cells?["6a7b0868bc5a64d240fbf627"]?.text, "L2 edited inline")
    }

    func testCollectionDefaultsMixed_Level2InlineEditWritesThrough() throws {
        navigateToCollection(.defaultsMixed)
        app.images["CollectionExpandCollapseButton1"].tap()
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        let cells = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        XCTAssertTrue(cells.element(boundBy: 2).waitForExistence(timeout: 5), "Root, L1 and L2 are all inline-editable here")
        replaceText(in: cells.element(boundBy: 2), with: "Defaults L2 edited inline")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()

        let level2 = onChangeResultValue().valueElements?.first?
            .childrens?["level1Table1"]?.valueToValueElements?.first?
            .childrens?["level2Table1"]?.valueToValueElements
        XCTAssertEqual(level2?.first?.cells?["6a7b087d42ffe316b3cb46ff"]?.text, "Defaults L2 edited inline")
    }

    func testCollectionDefaultsMixed_Level3RowFormEditWritesThrough() throws {
        navigateToCollection(.defaultsMixed)
        app.images["CollectionExpandCollapseButton1"].tap()
        app.images["CollectionExpandCollapseNestedButton1"].tap()

        let nestedExpandButtons = app.images.matching(identifier: "CollectionExpandCollapseNestedButton1")
        nestedExpandButtons.element(boundBy: nestedExpandButtons.count - 1).tap()

        // Root and L1 own the first two pencils; L3's two rows add the next two.
        let pencils = app.images.matching(pencilPredicate)
        XCTAssertTrue(pencils.element(boundBy: 2).waitForExistence(timeout: 5))
        pencils.element(boundBy: 2).tap()

        let textField = app.textFields["EditRowsTextFieldIdentifier"].firstMatch
        replaceText(in: textField, with: "L3 edited via row form")
        app.buttons["DismissEditSingleRowSheetButtonIdentifier"].tap()
        goBackAndSettle()

        let level3 = onChangeResultValue().valueElements?.first?
            .childrens?["level1Table1"]?.valueToValueElements?.first?
            .childrens?["level2Table1"]?.valueToValueElements?.first?
            .childrens?["level3Table1"]?.valueToValueElements
        XCTAssertEqual(level3?.first?.cells?["6a7b08855f9e0b380b8a58c4"]?.text, "L3 edited via row form")
    }

    // MARK: - Read-only text cells stay scrollable

    func testTableFormOnly_EveryReadonlyTextCellIsWrappedInAScrollView() throws {
        navigateToTable(.formOnly)

        let wrappers = app.descendants(matching: .any).matching(identifier: "TableTextFieldReadonlyScrollView")
        XCTAssertTrue(wrappers.firstMatch.waitForExistence(timeout: 5))
        // Two text columns over three rows. The count is against cells, not against visible
        // labels: an empty cell renders its wrapper but contributes no `StaticText`.
        XCTAssertEqual(wrappers.count, 6, "Every read-only text cell needs its own scroll wrapper so long content stays reachable")
    }

    func testCollectionFormOnly_ReadonlyTextCellIsWrappedInAScrollView() throws {
        navigateToCollection(.formOnly)

        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "TableTextFieldReadonlyScrollView").firstMatch.exists, "Collection read-only text cells need the same scroll wrapper")
    }

    func testQuickView_ReadonlyTextCellIsNotWrappedInAScrollView() throws {
        // The page-level quick view renders a truncated single-line preview, so it takes the
        // `.quickView` branch and must not pay for the scroll wrapper.
        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 15))
        XCTAssertEqual(app.descendants(matching: .any).matching(identifier: "TableTextFieldReadonlyScrollView").count, 0, "Quick view previews should not build scroll wrappers")
    }

    // MARK: - Structural row operations are independent of editability

    func testTableFormOnly_AddRowStillWorks() throws {
        navigateToTable(.formOnly)
        app.buttons["TableAddRowIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()
        XCTAssertEqual(onChangeResultValue().valueElements?.filter { !($0.deleted ?? false) }.count, 4, "Adding a row must not be gated on inline editability")
    }

    func testTableFormOnly_MoveRowStillWorks() throws {
        navigateToTable(.formOnly)
        selectSingleTableRow(number: 1)
        tapMoreButton()
        app.buttons["TableMoveUpRowIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")

        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertTrue(readonlyCells.element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(readonlyCells.element(boundBy: 0).label, "Form only R2", "Row 2 should now be first")
    }

    func testTableInlineOnly_InsertBelowStillWorks() throws {
        navigateToTable(.inlineOnly)
        selectSingleTableRow(number: 0)
        tapMoreButton()
        app.buttons["TableInsertRowIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()
        XCTAssertEqual(onChangeResultValue().valueElements?.filter { !($0.deleted ?? false) }.count, 4)
    }

    func testCollectionFormOnly_AddRowStillWorks() throws {
        navigateToCollection(.formOnly)
        app.buttons["TableAddRowIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
        goBackAndSettle()
        XCTAssertEqual(onChangeResultValue().valueElements?.filter { !($0.deleted ?? false) }.count, 4, "Adding a collection row must not be gated on inline editability")
    }

    // MARK: - Interaction with document mode and other table features

    func testReadonlyDocument_InlineOnlyTableStaysReadonlyInGrid() throws {
        navigateToTable(.inlineOnly)
        // `gridEditMode` short-circuits to readonly whenever the document isn't in fill mode,
        // so inline editability can never re-open a read-only document.
        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(app.textViews.matching(identifier: "TabelTextFieldIdentifier").count, 0, "A read-only document must not produce editable cells")
        XCTAssertEqual(app.images.matching(identifier: "MyButton").count, 0, "Row selectors are hidden outside fill mode")
    }

    func testReadonlyDocument_FormOnlyTableKeepsPencilButRowFormIsDisabled() throws {
        navigateToTable(.formOnly)

        let pencil = app.images["SingleClickEditButton0"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "The pencil is gated on form editability, not on document mode")
        pencil.tap()

        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5))
        // The row form takes the document mode directly, so a read-only document swaps the text
        // editor for static copy rather than rendering a disabled editor.
        XCTAssertEqual(app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").count, 0, "Row-form text cells must not be editable in a read-only document")
        let readonlyCopy = app.staticTexts.matching(identifier: "EditRowsTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(readonlyCopy.exists, "The row form should still show the cell's value as static copy")
        XCTAssertFalse(app.buttons["EditRowsDropdownFieldIdentifier"].isEnabled, "Row-form dropdowns must be disabled in a read-only document")
    }

    func testReadonlyDocument_InlineOnlyCollectionStaysReadonly() throws {
        navigateToCollection(.inlineOnly)
        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(app.textViews.matching(identifier: "TabelTextFieldIdentifier").count, 0, "A read-only document must not produce editable collection cells")
    }

    func testTableFormOnly_FilteringDoesNotUnlockTheGrid() throws {
        navigateToTable(.formOnly)

        // The header identifier sits on a tap-gesture HStack that is not itself an accessibility
        // element, so it propagates onto the children -- the title ScrollView and the filter
        // glyph. The glyph is the visible affordance; tapping it reveals the per-column search bar.
        let filterGlyph = app.images.matching(identifier: "Text Column/ColumnButtonIdentifier").element(boundBy: 0)
        XCTAssertTrue(filterGlyph.waitForExistence(timeout: 5))
        filterGlyph.tap()

        let searchField = app.textFields["TextFieldSearchBarIdentifier"].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Form only R2")
        XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")

        // Filtering rebuilds the cell models, so the grid edit mode has to survive the rebuild.
        let readonlyCells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertTrue(readonlyCells.element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertEqual(readonlyCells.element(boundBy: 0).label, "Form only R2", "Only the matching row should remain")
        XCTAssertEqual(app.textViews.matching(identifier: "TabelTextFieldIdentifier").count, 0, "Filtered rows must stay read-only")
    }

    func testTableInlineOnly_SelectAllThenBulkEditStaysAvailable() throws {
        navigateToTable(.inlineOnly)
        app.images["SelectAllRowSelectorButton"].tap()
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableEditRowsIdentifier"].waitForExistence(timeout: 5), "Select-all is a multi-row selection, so it follows inlineAllowed")
    }

    func testTableFormOnly_SelectAllHidesBulkEdit() throws {
        navigateToTable(.formOnly)
        app.images["SelectAllRowSelectorButton"].tap()
        tapMoreButton()
        XCTAssertTrue(app.buttons["TableDeleteRowIdentifier"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["TableEditRowsIdentifier"].exists, "Select-all is a multi-row selection, so it must be hidden when inline editing is disallowed")
    }

    // MARK: - Flag resolution edge cases

    // `EditabilityFlags.init(rawValues:)` matches "inline"/"form" case-sensitively and falls back
    // to `.default` when nothing in the array is recognized, so an unusable array behaves as if
    // editability were never specified rather than locking the field.

    func testTableUppercaseEditability_FallsBackToBothAllowed() throws {
        navigateToTable(.uppercaseEditability)
        XCTAssertTrue(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5), "\"INLINE\" is not recognized, so the field falls back to both")
        XCTAssertTrue(app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0).isEnabled)
        XCTAssertTrue(app.images["SingleClickEditButton0"].exists, "The fallback also restores form editing")
    }

    func testTableUnrecognizedEditability_FallsBackToBothAllowed() throws {
        navigateToTable(.unrecognizedEditability)
        XCTAssertTrue(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5))
        XCTAssertTrue(app.images["SingleClickEditButton0"].exists)
    }

    func testTableDuplicateInlineEditability_ResolvesToInlineOnly() throws {
        navigateToTable(.duplicateInlineEditability)
        XCTAssertTrue(app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).waitForExistence(timeout: 5), "A repeated value still resolves to inline")
        XCTAssertEqual(app.images.matching(pencilPredicate).count, 0, "\"form\" is still absent, so no pencil")
    }

    func testCollectionFieldLevelEditabilityIsIgnored_SchemaLevelWins() throws {
        navigateToCollection(.fieldLevelVsSchemaLevel)

        // The field carries `editability: ["inline"]`, but collections read editability only from
        // `schema[key].editability`, which is `["form"]` here.
        XCTAssertTrue(app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0).waitForExistence(timeout: 5), "Schema-level form-only must win over the field-level inline")
        XCTAssertEqual(app.textViews.matching(identifier: "TabelTextFieldIdentifier").count, 0)
        XCTAssertFalse(app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0).isEnabled)
        XCTAssertTrue(app.images["SingleClickEditButton1"].exists, "Form editing comes from the schema level")
    }
}
