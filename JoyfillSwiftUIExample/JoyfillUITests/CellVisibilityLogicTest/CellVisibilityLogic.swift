//
//  CellVisibilityLogic.swift
//  JoyfillExample
//
//  Created by Vivek's Mac on 28/07/26.
//

import XCTest

final class CellVisibilityLogic: JoyfillUITestsBaseClass {

    private typealias S = DecoratorUITestSupport

    override func getJSONFileNameForTest() -> String {
        return "CellVisibilityLogic"
    }

    func testTableRowTextCellShowsOnlyWhenSiblingDropdownHasValue() throws {
        S.openTableDetailView(in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)

        assertRowFormTextFieldCount(1, "Only text2 should render while text1 is hidden by empty sibling dropdown")
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForExistence(timeout: 3))

        selectFirstDropdownOption()

        assertRowFormTextFieldCount(2, "text1 should render after sibling dropdown receives a value")
    }

    func testCollectionRootTextCellShowsOnlyWhenSiblingDropdownHasValue() throws {
        S.openCollectionDetailView(in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)

        assertRowFormTextFieldCount(0, "Root text should be hidden while root dropdown is empty")
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["EditRowsImageFieldIdentifier"].waitForExistence(timeout: 3))

        selectFirstDropdownOption()

        assertRowFormTextFieldCount(1, "Root text should render after root dropdown receives a value")
    }

    func testCollectionSecondRootRowKeepsTextHiddenWhenSiblingDropdownMissing() throws {
        S.openCollectionDetailView(in: app)
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app)

        assertRowFormTextFieldCount(0, "Root text should stay hidden when the row has no sibling dropdown value")
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["EditRowsImageFieldIdentifier"].waitForExistence(timeout: 3))
    }

    func testCollectionNestedRowHidesTextWhenMultiselectHasValueAndKeepsStaticDropdownHidden() throws {
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, in: app)

        assertRowFormTextFieldCount(0, "Nested text should be hidden by hide logic while multiselect has a value")
        XCTAssertTrue(app.buttons["EditRowsMultiSelecionFieldIdentifier"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForNonExistence(timeout: 3),
                      "Nested dropdown should remain hidden because cellsHidden is true")
    }

    func testTableRowFormVisibilityDoesNotLeakAcrossRows() throws {
        S.openTableDetailView(in: app)
        openTableRowForm(1)
        assertRowFormTextFieldCount(1, "Row 1 should start with text1 hidden")

        selectFirstDropdownOption()
        assertRowFormTextFieldCount(2, "Row 1 should show text1 after dropdown selection")
        closeRowForm()

        openTableRowForm(2)
        assertRowFormTextFieldCount(1, "Row 2 should stay hidden and not inherit row 1 visibility")
        closeRowForm()

        openTableRowForm(1)
        assertRowFormTextFieldCount(2, "Row 1 should keep its own visible state after visiting row 2")
    }

    func testTableRowFormChevronNavigationKeepsVisibilityPerRow() throws {
        S.openTableDetailView(in: app)
        openTableRowForm(1)

        selectFirstDropdownOption()
        assertRowFormTextFieldCount(2, "Row 1 should show text1 before navigating")

        tapRowFormButton("LowerRowButtonIdentifier")
        assertRowFormTextFieldCount(1, "Row 2 should stay hidden when navigating forward inside row form")

        tapRowFormButton("UpperRowButtonIdentifier")
        assertRowFormTextFieldCount(2, "Row 1 should keep visible state when navigating back inside row form")
    }

    func testTableRowFormPlusButtonInsertsRowWithFreshVisibility() throws {
        S.openTableDetailView(in: app)
        openTableRowForm(1)

        selectFirstDropdownOption()
        assertRowFormTextFieldCount(2, "Source row should be visible before using row-form plus")

        tapRowFormButton("PlusTheRowButtonIdentifier")

        assertRowFormTextFieldCount(1, "Row inserted from row-form plus should start hidden")
    }

    func testTableBulkEditDropdownReevaluatesVisibilityForEverySelectedRow() throws {
        S.openTableDetailView(in: app)
        selectAllTableRows()
        tapMoreAction("TableEditRowsIdentifier")

        assertRowFormTextFieldCount(2, "Bulk edit should expose both text columns before applying changes")
        selectFirstDropdownOption()
        tapApplyAll()

        for rowIndex in 1...3 {
            openTableRowForm(rowIndex)
            assertRowFormTextFieldCount(2, "Bulk dropdown update should make text1 visible for table row \(rowIndex)")
            closeRowForm()
        }
    }

    func testTablePartialBulkEditOnlyUpdatesSelectedRows() throws {
        S.openTableDetailView(in: app)
        selectTableRow(0)
        selectTableRow(1)
        tapMoreAction("TableEditRowsIdentifier")

        selectFirstDropdownOption()
        tapApplyAll()

        openTableRowForm(1)
        assertRowFormTextFieldCount(2, "Partial bulk edit should make selected row 1 visible")
        closeRowForm()

        openTableRowForm(2)
        assertRowFormTextFieldCount(2, "Partial bulk edit should make selected row 2 visible")
        closeRowForm()

        openTableRowForm(3)
        assertRowFormTextFieldCount(1, "Partial bulk edit should leave unselected row 3 hidden")
    }

    func testTableBulkEditDismissWithoutApplyDoesNotChangeVisibility() throws {
        S.openTableDetailView(in: app)
        selectTableRow(0)
        selectTableRow(1)
        tapMoreAction("TableEditRowsIdentifier")

        selectFirstDropdownOption()
        dismissBulkEditForm()

        openTableRowForm(1)
        assertRowFormTextFieldCount(1, "Dismissed bulk edit should not update row 1")
        closeRowForm()

        openTableRowForm(2)
        assertRowFormTextFieldCount(1, "Dismissed bulk edit should not update row 2")
    }

    func testTableInsertBelowAndAddRowUseFreshVisibilityState() throws {
        S.openTableDetailView(in: app)
        openTableRowForm(1)
        selectFirstDropdownOption()
        assertRowFormTextFieldCount(2, "Selected source row should be visible before insert below")
        closeRowForm()

        tapMoreAction("TableInsertRowIdentifier")

        openTableRowForm(2)
        assertRowFormTextFieldCount(1, "Inserted table row should start hidden instead of copying source row visibility")
        closeRowForm()

        tapAddRow()

        openTableRowForm(5)
        assertRowFormTextFieldCount(1, "Added table row should start with hidden visibility logic")
    }

    func testTableDeleteKeepsVisibilityAttachedToRemainingRows() throws {
        S.openTableDetailView(in: app)
        openTableRowForm(2)
        selectFirstDropdownOption()
        assertRowFormTextFieldCount(2, "Row 2 should be visible before deleting row 1")
        closeRowForm()

        clearTableSelection()
        selectTableRow(0)
        tapMoreAction("TableDeleteRowIdentifier")

        openTableRowForm(1)
        assertRowFormTextFieldCount(2, "Former row 2 should keep visible state after row 1 is deleted")
        closeRowForm()

        openTableRowForm(2)
        assertRowFormTextFieldCount(1, "Former row 3 should remain hidden after row indexes shift")
    }

    func testCollectionRowFormChevronNavigationKeepsVisibilityPerRootRow() throws {
        S.openCollectionDetailView(in: app)
        openCollectionRootRowForm(1)

        selectFirstDropdownOption()
        assertRowFormTextFieldCount(1, "Root row 1 should show text before navigating")

        tapRowFormButton("LowerRowButtonIdentifier")
        assertRowFormTextFieldCount(0, "Root row 2 should stay hidden when navigating forward inside row form")

        tapRowFormButton("UpperRowButtonIdentifier")
        assertRowFormTextFieldCount(1, "Root row 1 should keep visible state when navigating back inside row form")
    }

    func testCollectionRowFormPlusButtonInsertsRootRowWithFreshVisibility() throws {
        S.openCollectionDetailView(in: app)
        openCollectionRootRowForm(1)

        selectFirstDropdownOption()
        assertRowFormTextFieldCount(1, "Source root row should be visible before using row-form plus")

        tapRowFormButton("PlusTheRowButtonIdentifier")

        assertRowFormTextFieldCount(0, "Root row inserted from row-form plus should start hidden")
    }

    func testCollectionBulkEditDropdownReevaluatesRootRowsAndAddRowStartsHidden() throws {
        S.openCollectionDetailView(in: app)
        selectAllCollectionRootRows()
        tapMoreAction("TableEditRowsIdentifier")

        assertRowFormTextFieldCount(1, "Collection root bulk edit should expose root text for editing")
        selectFirstDropdownOption()
        tapApplyAll()

        for rowIndex in 1...2 {
            openCollectionRootRowForm(rowIndex)
            assertRowFormTextFieldCount(1, "Bulk dropdown update should make root text visible for collection row \(rowIndex)")
            closeRowForm()
        }

        tapAddRow()

        openCollectionRootRowForm(3)
        assertRowFormTextFieldCount(0, "Added collection root row should start with text hidden")
    }

    func testCollectionInsertBelowAndDeleteKeepRootVisibilityAttachedToRows() throws {
        S.openCollectionDetailView(in: app)
        openCollectionRootRowForm(2)
        selectFirstDropdownOption()
        assertRowFormTextFieldCount(1, "Root row 2 should be visible before insert and delete")
        closeRowForm()

        tapMoreAction("TableInsertRowIdentifier")

        openCollectionRootRowForm(3)
        assertRowFormTextFieldCount(0, "Inserted collection root row should start hidden")
        closeRowForm()

        clearCollectionRootSelection()
        selectCollectionRootRow(1)
        tapMoreAction("TableDeleteRowIdentifier")

        openCollectionRootRowForm(1)
        assertRowFormTextFieldCount(1, "Former root row 2 should keep visible state after root row 1 is deleted")
        closeRowForm()

        openCollectionRootRowForm(2)
        assertRowFormTextFieldCount(0, "Inserted blank root row should remain hidden after delete shifts indexes")
    }

    func testCollectionNestedAddRowStartsVisibleAndKeepsStaticDropdownHidden() throws {
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)

        tapNestedSchemaAddRow()
        openCollectionNestedRowForm(2)

        assertRowFormTextFieldCount(1, "Added nested row should show text because multiselect starts empty")
        XCTAssertTrue(app.buttons["EditRowsMultiSelecionFieldIdentifier"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForNonExistence(timeout: 3),
                      "Static hidden nested dropdown should remain hidden for added row")
    }

    func testCollectionNestedRowFormPlusButtonInsertsRowWithFreshVisibility() throws {
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)
        openCollectionNestedRowForm(1)

        assertRowFormTextFieldCount(0, "Source nested row should be hidden before using row-form plus")

        tapRowFormButton("PlusTheRowButtonIdentifier")

        assertRowFormTextFieldCount(1, "Nested row inserted from row-form plus should show text because multiselect starts empty")
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForNonExistence(timeout: 3),
                      "Static hidden nested dropdown should remain hidden after row-form plus")
    }

    func testCollectionNestedDeleteKeepsVisibilityAttachedToRemainingRows() throws {
        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)
        tapNestedSchemaAddRow()

        openCollectionNestedRowForm(2)
        assertRowFormTextFieldCount(1, "New nested row should show text before deleting original nested row")
        closeRowForm()

        clearCollectionNestedSelection()
        selectCollectionNestedRow(1)
        tapMoreAction("TableDeleteRowIdentifier")

        openCollectionNestedRowForm(1)
        assertRowFormTextFieldCount(1, "Former nested row 2 should keep visible state after nested row 1 is deleted")
        XCTAssertTrue(app.buttons["EditRowsDropdownFieldIdentifier"].waitForNonExistence(timeout: 3),
                      "Static hidden nested dropdown should remain hidden after nested delete")
    }

    private func openTableRowForm(_ rowIndex: Int, file: StaticString = #file, line: UInt = #line) {
        S.openTableRowEditForm(rowIndex: rowIndex, in: app)
        assertRowFormOpened(file: file, line: line)
    }

    private func openCollectionRootRowForm(_ rowIndex: Int, file: StaticString = #file, line: UInt = #line) {
        S.openCollectionRootRowEditForm(rowIndex: rowIndex, in: app)
        assertRowFormOpened(file: file, line: line)
    }

    private func openCollectionNestedRowForm(_ rowIndex: Int, boundBy: Int = 0, file: StaticString = #file, line: UInt = #line) {
        S.openCollectionNestedRowEditForm(rowIndex: rowIndex, boundBy: boundBy, in: app)
        assertRowFormOpened(file: file, line: line)
    }

    private func assertRowFormOpened(file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(waitUntil(5) {
            self.app.buttons["DismissEditSingleRowSheetButtonIdentifier"].exists ||
            self.app.buttons["ApplyAllButtonIdentifier"].exists
        }, "Row edit form did not open", file: file, line: line)
    }

    private func closeRowForm() {
        let dismissButton = app.buttons["DismissEditSingleRowSheetButtonIdentifier"]
        if dismissButton.waitForExistence(timeout: 3) {
            dismissButton.tap()
            spinRunloop(0.4)
        }
    }

    private func tapRowFormButton(_ identifier: String, file: StaticString = #file, line: UInt = #line) {
        let button = app.buttons[identifier]
        XCTAssertTrue(button.waitForExistence(timeout: 3), "\(identifier) did not appear", file: file, line: line)
        button.tap()
        spinRunloop(0.5)
    }

    private func assertRowFormTextFieldCount(_ expected: Int, _ message: String, file: StaticString = #file, line: UInt = #line) {
        let query = app.textFields.matching(identifier: "EditRowsTextFieldIdentifier")
        XCTAssertTrue(waitUntil(5) { query.count == expected },
                      "\(message). Expected \(expected), found \(query.count)",
                      file: file,
                      line: line)
    }

    private func selectFirstDropdownOption(file: StaticString = #file, line: UInt = #line) {
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertTrue(dropdownButton.waitForExistence(timeout: 3), file: file, line: line)
        dropdownButton.tap()

        let options = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertTrue(waitUntil(5) { options.count > 0 }, "Dropdown options did not appear", file: file, line: line)
        options.element(boundBy: 0).tap()
        spinRunloop(0.3)
    }

    private func tapApplyAll(file: StaticString = #file, line: UInt = #line) {
        let applyButton = app.buttons["ApplyAllButtonIdentifier"]
        XCTAssertTrue(applyButton.waitForExistence(timeout: 3), "Apply All button did not appear", file: file, line: line)
        applyButton.tap()
        XCTAssertTrue(waitUntil(5) { !applyButton.exists }, "Bulk edit sheet did not dismiss", file: file, line: line)
        spinRunloop(0.5)
    }

    private func dismissBulkEditForm(file: StaticString = #file, line: UInt = #line) {
        S.dismissRowEditForm(in: app)
        if app.buttons["ApplyAllButtonIdentifier"].exists {
            swipeSheetDown()
        }
        XCTAssertTrue(waitUntil(5) { !self.app.buttons["ApplyAllButtonIdentifier"].exists },
                      "Bulk edit sheet did not dismiss",
                      file: file,
                      line: line)
        spinRunloop(0.5)
    }

    private func tapMoreAction(_ identifier: String, file: StaticString = #file, line: UInt = #line) {
        let moreButton = app.buttons["TableMoreButtonIdentifier"]
        XCTAssertTrue(moreButton.waitForExistence(timeout: 3), "More button did not appear", file: file, line: line)
        moreButton.tap()

        let actionButton = app.buttons[identifier].firstMatch
        XCTAssertTrue(actionButton.waitForExistence(timeout: 3), "\(identifier) did not appear", file: file, line: line)
        actionButton.tap()
        spinRunloop(0.4)
    }

    private func tapAddRow(file: StaticString = #file, line: UInt = #line) {
        let addRowButton = app.buttons["TableAddRowIdentifier"].firstMatch
        XCTAssertTrue(addRowButton.waitForExistence(timeout: 3), "Add row button did not appear", file: file, line: line)
        addRowButton.tap()
        spinRunloop(0.5)
    }

    private func selectAllTableRows(file: StaticString = #file, line: UInt = #line) {
        let selectAllButton = app.images["SelectAllRowSelectorButton"]
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Table select all button did not appear", file: file, line: line)
        selectAllButton.tap()
        spinRunloop(0.3)
    }

    private func clearTableSelection(file: StaticString = #file, line: UInt = #line) {
        let selectAllButton = app.images["SelectAllRowSelectorButton"]
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Table select all button did not appear", file: file, line: line)
        selectAllButton.tap()
        spinRunloop(0.2)
        selectAllButton.tap()
        spinRunloop(0.3)
    }

    private func selectTableRow(_ zeroBasedIndex: Int, file: StaticString = #file, line: UInt = #line) {
        let rowSelector = app.images.matching(identifier: "MyButton").element(boundBy: zeroBasedIndex)
        XCTAssertTrue(rowSelector.waitForExistence(timeout: 3), "Table row selector \(zeroBasedIndex) did not appear", file: file, line: line)
        rowSelector.tap()
        spinRunloop(0.3)
    }

    private func selectAllCollectionRootRows(file: StaticString = #file, line: UInt = #line) {
        let selectAllButton = app.images["SelectParentAllRowSelectorButton"]
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Collection select all button did not appear", file: file, line: line)
        selectAllButton.tap()
        spinRunloop(0.3)
    }

    private func clearCollectionRootSelection(file: StaticString = #file, line: UInt = #line) {
        let selectAllButton = app.images["SelectParentAllRowSelectorButton"]
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Collection select all button did not appear", file: file, line: line)
        selectAllButton.tap()
        spinRunloop(0.2)
        selectAllButton.tap()
        spinRunloop(0.3)
    }

    private func selectCollectionRootRow(_ oneBasedIndex: Int, file: StaticString = #file, line: UInt = #line) {
        let rowSelector = app.images["selectRowItem\(oneBasedIndex)"].firstMatch
        XCTAssertTrue(rowSelector.waitForExistence(timeout: 3), "Collection root row selector \(oneBasedIndex) did not appear", file: file, line: line)
        rowSelector.tap()
        spinRunloop(0.3)
    }

    private func tapNestedSchemaAddRow(boundBy: Int = 0, file: StaticString = #file, line: UInt = #line) {
        let addRowButton = app.buttons.matching(identifier: "collectionSchemaAddRowButton").element(boundBy: boundBy)
        XCTAssertTrue(addRowButton.waitForExistence(timeout: 3), "Nested add row button did not appear", file: file, line: line)
        addRowButton.tap()
        spinRunloop(0.5)
    }

    private func selectCollectionNestedRow(_ oneBasedIndex: Int, boundBy: Int = 0, file: StaticString = #file, line: UInt = #line) {
        let rowSelector = app.images.matching(identifier: "selectNestedRowItem\(oneBasedIndex)").element(boundBy: boundBy)
        XCTAssertTrue(rowSelector.waitForExistence(timeout: 3), "Collection nested row selector \(oneBasedIndex) did not appear", file: file, line: line)
        rowSelector.tap()
        spinRunloop(0.3)
    }

    private func clearCollectionNestedSelection(boundBy: Int = 0, file: StaticString = #file, line: UInt = #line) {
        let selectAllButton = app.images.matching(identifier: "selectAllNestedRows").element(boundBy: boundBy)
        XCTAssertTrue(selectAllButton.waitForExistence(timeout: 3), "Collection nested select all button did not appear", file: file, line: line)
        selectAllButton.tap()
        spinRunloop(0.2)
        selectAllButton.tap()
        spinRunloop(0.3)
    }
}
