import XCTest
import JoyfillModel

/// Shared navigation helpers for the duplicate + bulk-edit decorator UI coverage
/// driven by DuplicatePerRow&HideDecorator.json. Has no `test*` methods itself,
/// so it contributes no test cases — the concrete subclasses below do.
class DuplicatePerRowBulkEditBaseUITests: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "DuplicatePerRow&HideDecorator"
    }

    // MARK: - Navigation helpers

    func openTableDetail() {
        let btn = app.buttons.matching(identifier: "TableDetailViewIdentifier").firstMatch
        var tries = 0
        while !btn.exists && tries < 6 {
            app.swipeUp()
            tries += 1
            _ = waitForAppStability(timeout: 2)
        }
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Table detail button should appear")
        btn.tap()
        _ = waitForAppStability(timeout: 5)
    }

    func openCollectionDetail() {
        let btn = app.buttons.matching(identifier: "CollectionDetailViewIdentifier").firstMatch
        var tries = 0
        // Swipe along the window's left edge so the gesture scrolls the outer
        // form, not the table quick-view's inner scrollable preview.
        let top = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.8))
        let bottom = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.2))
        while !btn.exists && tries < 10 {
            top.press(forDuration: 0, thenDragTo: bottom)
            tries += 1
            _ = waitForAppStability(timeout: 2)
        }
        XCTAssertTrue(btn.waitForExistence(timeout: 5), "Collection detail button should appear")
        btn.tap()
        _ = waitForAppStability(timeout: 5)
    }

    func tapMore() {
        let more = app.buttons["TableMoreButtonIdentifier"]
        XCTAssertTrue(more.waitForExistence(timeout: 5), "More button should appear after selecting a row")
        more.tap()
    }

    func selectTableRow(_ index: Int) {
        app.images.matching(identifier: "MyButton").element(boundBy: index).tap()
    }

    func selectCollectionRootRow(_ oneBasedIndex: Int) {
        app.images.matching(identifier: "selectRowItem\(oneBasedIndex)").element.tap()
    }

    func selectCollectionNestedRow(_ oneBasedIndex: Int) {
        app.images.matching(identifier: "selectNestedRowItem\(oneBasedIndex)").element.tap()
    }

    /// Expand a collection root row (1-based) to reveal its nested table.
    func expandCollectionRootRow(_ oneBasedIndex: Int) {
        let expand = app.images["CollectionExpandCollapseButton\(oneBasedIndex)"]
        XCTAssertTrue(expand.waitForExistence(timeout: 5), "Expand button for root row \(oneBasedIndex) should appear")
        expand.tap()
        _ = waitForAppStability(timeout: 2)
    }

    /// The nested-table "Add Row" button (first expanded nested schema).
    func nestedAddRowButton() -> XCUIElement {
        app.buttons.matching(identifier: "collectionSchemaAddRowButton").element(boundBy: 0)
    }

    /// Open the bulk-edit form for the table (2 rows selected) and confirm it rendered.
    func openTableBulkEdit() {
        openTableDetail()
        selectTableRow(0)
        selectTableRow(1)
        tapMore()
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit rows menu item should appear for 2 selected rows")
        edit.tap()
        XCTAssertTrue(app.buttons["ApplyAllButtonIdentifier"].waitForExistence(timeout: 5),
                      "Bulk-edit form should open with an Apply-all button")
    }

    /// Open the bulk-edit form for the collection (2 root rows selected) and confirm it rendered.
    func openCollectionBulkEdit() {
        openCollectionDetail()
        selectCollectionRootRow(1)
        selectCollectionRootRow(2)
        tapMore()
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit rows menu item should appear for 2 selected root rows")
        edit.tap()
        XCTAssertTrue(app.buttons["ApplyAllButtonIdentifier"].waitForExistence(timeout: 5),
                      "Collection bulk-edit form should open with an Apply-all button")
    }

    /// Open the single-row edit form for the table (1 row selected) and confirm it rendered.
    /// The single-row form uses the dismiss button as its anchor (Apply-all only renders for 2+ rows).
    func openTableSingleRowEdit() {
        openTableDetail()
        selectTableRow(0)
        tapMore()
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit row menu item should appear for 1 selected row")
        edit.tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5),
                      "Single-row edit form should open")
    }

    /// Open the single-row edit form for the collection (1 root row selected) and confirm it rendered.
    func openCollectionSingleRowEdit() {
        openCollectionDetail()
        selectCollectionRootRow(1)
        tapMore()
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit row menu item should appear for 1 selected root row")
        edit.tap()
        XCTAssertTrue(app.buttons["DismissEditSingleRowSheetButtonIdentifier"].waitForExistence(timeout: 5),
                      "Collection single-row edit form should open")
    }
}

/// Default config (`showInBulkForm == true`): per-row duplicate adds a row, and
/// column decorators ARE shown inside the bulk-edit form.
final class DuplicatePerRowBulkEditUITests: DuplicatePerRowBulkEditBaseUITests {

    // MARK: - Per-row duplicate (table)

    /// Selecting a table row and applying a duplicate adds one row (table starts at 3 of maxRows 5).
    func testTableDuplicateRowAddsRow() {
        openTableDetail()

        XCTAssertTrue(app.images["SingleClickEditButton2"].waitForExistence(timeout: 5),
                      "Table should start with 3 rows")
        XCTAssertFalse(app.images["SingleClickEditButton3"].exists,
                       "Table should not yet have a 4th row")

        selectTableRow(0)
        tapMore()

        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.waitForExistence(timeout: 5), "Duplicate row menu item should appear")
        duplicate.tap()

        let apply = app.buttons["DuplicateRowApplyButton"]
        XCTAssertTrue(apply.waitForExistence(timeout: 5), "Duplicate sheet Apply button should appear")
        apply.tap()

        XCTAssertTrue(app.images["SingleClickEditButton3"].waitForExistence(timeout: 5),
                      "A new row should be added after applying duplicate")
    }

    // MARK: - Per-row duplicate (collection)

    /// Duplicating a collection root row adds one root row (collection starts at 5 of maxRows 8).
    func testCollectionDuplicateRowAddsRow() {
        openCollectionDetail()

        XCTAssertTrue(app.images.matching(identifier: "selectRowItem5").element.waitForExistence(timeout: 5),
                      "Collection should start with 5 root rows")
        XCTAssertFalse(app.images.matching(identifier: "selectRowItem6").element.exists,
                       "Collection should not yet have a 6th root row")

        selectCollectionRootRow(1)
        tapMore()

        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.waitForExistence(timeout: 5), "Duplicate row menu item should appear")
        duplicate.tap()

        let apply = app.buttons["DuplicateRowApplyButton"]
        XCTAssertTrue(apply.waitForExistence(timeout: 5), "Duplicate sheet Apply button should appear")
        apply.tap()

        XCTAssertTrue(app.images.matching(identifier: "selectRowItem6").element.waitForExistence(timeout: 5),
                      "A new root row should be added after applying duplicate")
    }

    // MARK: - Bulk-edit decorators shown (table)

    /// Column decorators render inside the table bulk-edit form (default showInBulkForm = true).
    func testTableBulkEditShowsColumnIcons() {
        openTableBulkEdit()

        XCTAssertTrue(app.buttons["decorator_button_Comment"].waitForExistence(timeout: 5),
                      "Text column's Comment icon should show in bulk edit")
        XCTAssertTrue(app.buttons["decorator_button_Camera"].exists,
                      "Dropdown column's Camera icon should show in bulk edit")
        XCTAssertTrue(app.buttons["decorator_button_Flag"].exists,
                      "Text column's Flag icon should show in bulk edit")
    }

    // MARK: - Bulk-edit decorators shown (collection)

    /// Root column decorators render inside the collection bulk-edit form (default showInBulkForm = true).
    func testCollectionBulkEditShowsColumnIcons() {
        openCollectionBulkEdit()

        XCTAssertTrue(app.buttons["decorator_button_Eye"].waitForExistence(timeout: 5),
                      "Text column's Eye icon should show in collection bulk edit")
        XCTAssertTrue(app.buttons["decorator_button_Info"].exists,
                      "Dropdown column's Info icon should show in collection bulk edit")
    }
}

/// maxRows coverage driven by the same fixture: the table field caps at 5 rows
/// (starts at 3), and the collection's root schema caps at 8 rows (starts at 5).
/// Once a level is at its limit the Add Row button disables, and the duplicate
/// popover refuses a quantity that would overflow the remaining capacity.
final class DuplicatePerRowMaxRowsUITests: DuplicatePerRowBulkEditBaseUITests {

    // MARK: - Table field-level maxRows (5)

    /// Adding rows up to the table's maxRows (5) disables the Add Row button.
    func testTableAddRowDisablesAtMaxRows() {
        openTableDetail()

        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Add Row button should exist")
        XCTAssertTrue(addRow.isEnabled, "Add Row should be enabled at 3 of 5 rows")

        // 3 -> 4
        addRow.tap()
        XCTAssertTrue(app.images["SingleClickEditButton3"].waitForExistence(timeout: 5),
                      "A fourth row should be added")
        XCTAssertTrue(addRow.isEnabled, "Add Row should still be enabled at 4 of 5 rows")

        // 4 -> 5 (at the limit)
        addRow.tap()
        XCTAssertTrue(app.images["SingleClickEditButton4"].waitForExistence(timeout: 5),
                      "A fifth row should be added")
        XCTAssertFalse(addRow.isEnabled, "Add Row should be disabled once the table reaches maxRows (5)")
    }

    /// Near the limit, the duplicate popover warns and disables Apply for a quantity
    /// that would exceed the remaining capacity; reducing it to fit re-enables Apply.
    func testTableDuplicateBlockedBeyondCapacity() {
        openTableDetail() // 3 of 5 -> 2 free slots

        selectTableRow(0)
        tapMore()
        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.waitForExistence(timeout: 5), "Duplicate row menu item should appear")
        XCTAssertTrue(duplicate.isEnabled, "Duplicate should be enabled below the limit")
        duplicate.tap()

        let plus = app.buttons["DuplicateRowCounterPlus"]
        XCTAssertTrue(plus.waitForExistence(timeout: 5), "Duplicate counter should appear")
        let apply = app.buttons["DuplicateRowApplyButton"]

        // Quantity 3 against 2 free slots -> warning + Apply disabled.
        plus.tap() // 2
        plus.tap() // 3
        XCTAssertTrue(app.staticTexts["DuplicateRowLimitWarning"].waitForExistence(timeout: 3),
                      "A limit warning should show when the quantity exceeds the remaining capacity")
        XCTAssertFalse(apply.isEnabled, "Apply should be disabled when the quantity exceeds the remaining capacity")

        // Back down to 2 (exactly fills the limit) -> warning clears, Apply enabled.
        app.buttons["DuplicateRowCounterMinus"].tap() // 2
        XCTAssertFalse(app.staticTexts["DuplicateRowLimitWarning"].exists,
                       "Warning should clear once the quantity fits the remaining capacity")
        XCTAssertTrue(apply.isEnabled, "Apply should be enabled once the quantity fits")
        apply.tap()

        // Duplicating 2 rows fills the table to its 5-row limit: Add Row disables.
        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(app.images["SingleClickEditButton4"].waitForExistence(timeout: 5),
                      "Duplicating two rows should fill the table to its 5-row limit")
        XCTAssertFalse(addRow.isEnabled, "Add Row should be disabled once the table reaches maxRows")
    }

    // MARK: - Collection root schema-level maxRows (8)

    /// Adding root rows up to the collection root schema's maxRows (8) disables the Add Row button.
    func testCollectionRootAddRowDisablesAtMaxRows() {
        openCollectionDetail() // 5 of 8 -> 3 free slots

        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Collection root Add Row button should exist")
        XCTAssertTrue(addRow.isEnabled, "Add Row should be enabled at 5 of 8 root rows")

        addRow.tap() // 6
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem6").element.waitForExistence(timeout: 5),
                      "A sixth root row should be added")
        addRow.tap() // 7
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem7").element.waitForExistence(timeout: 5),
                      "A seventh root row should be added")
        XCTAssertTrue(addRow.isEnabled, "Add Row should still be enabled at 7 of 8 root rows")

        addRow.tap() // 8 (at the limit)
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem8").element.waitForExistence(timeout: 5),
                      "An eighth root row should be added")
        XCTAssertFalse(addRow.isEnabled, "Add Row should be disabled once the collection root reaches maxRows (8)")
    }

    // MARK: - Row-add affordances at the limit (More menu + row-form)

    /// At the table's maxRows, the More menu's Insert Below and Duplicate items and the
    /// row-form "+" (insert below) button are all disabled.
    func testTableRowAddAffordancesDisabledAtMaxRows() {
        openTableDetail()

        // Fill the table to its 5-row limit (3 -> 5).
        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Add Row button should exist")
        addRow.tap()
        XCTAssertTrue(app.images["SingleClickEditButton3"].waitForExistence(timeout: 5), "Fourth row should be added")
        addRow.tap()
        XCTAssertTrue(app.images["SingleClickEditButton4"].waitForExistence(timeout: 5), "Fifth row should be added")

        // More menu: Insert Below and Duplicate are present but disabled at the limit.
        selectTableRow(0)
        tapMore()
        let insert = app.buttons["TableInsertRowIdentifier"]
        XCTAssertTrue(insert.waitForExistence(timeout: 5), "Insert Below should be present")
        XCTAssertFalse(insert.isEnabled, "Insert Below should be disabled at maxRows")
        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.exists, "Duplicate row should be present")
        XCTAssertFalse(duplicate.isEnabled, "Duplicate row should be disabled at maxRows")

        // Row-form "+" (insert below) is disabled at the limit.
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit row should be available")
        edit.tap()
        let plus = app.buttons["PlusTheRowButtonIdentifier"]
        XCTAssertTrue(plus.waitForExistence(timeout: 5), "Row-form + button should be present")
        XCTAssertFalse(plus.isEnabled, "Row-form + button should be disabled at maxRows")
    }

    /// At the collection root's maxRows, the More menu's Insert Below and Duplicate items and the
    /// row-form "+" (insert below) button are all disabled.
    func testCollectionRowAddAffordancesDisabledAtMaxRows() {
        openCollectionDetail()

        // Fill the collection root to its 8-row limit (5 -> 8).
        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Collection root Add Row button should exist")
        addRow.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem6").element.waitForExistence(timeout: 5), "Sixth root row should be added")
        addRow.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem7").element.waitForExistence(timeout: 5), "Seventh root row should be added")
        addRow.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectRowItem8").element.waitForExistence(timeout: 5), "Eighth root row should be added")

        // More menu: Insert Below and Duplicate are present but disabled at the root limit.
        selectCollectionRootRow(1)
        tapMore()
        let insert = app.buttons["TableInsertRowIdentifier"]
        XCTAssertTrue(insert.waitForExistence(timeout: 5), "Insert Below should be present")
        XCTAssertFalse(insert.isEnabled, "Insert Below should be disabled at the root maxRows")
        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.exists, "Duplicate row should be present")
        XCTAssertFalse(duplicate.isEnabled, "Duplicate row should be disabled at the root maxRows")

        // Row-form "+" (insert below) is disabled at the limit.
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit row should be available")
        edit.tap()
        let plus = app.buttons["PlusTheRowButtonIdentifier"]
        XCTAssertTrue(plus.waitForExistence(timeout: 5), "Row-form + button should be present")
        XCTAssertFalse(plus.isEnabled, "Row-form + button should be disabled at the root maxRows")
    }

    // MARK: - Nested-schema maxRows

    /// The nested `level1Table1` schema has maxRows == 3 and starts empty. Adding three
    /// nested rows reaches the limit and disables the nested "Add Row" button.
    func testCollectionNestedAddRowDisablesAtMaxRows() {
        openCollectionDetail()
        expandCollectionRootRow(1)

        let nestedAdd = nestedAddRowButton()
        XCTAssertTrue(nestedAdd.waitForExistence(timeout: 5), "Nested Add Row button should appear once the root row is expanded")
        XCTAssertTrue(nestedAdd.isEnabled, "Nested Add Row should be enabled while the nested table is empty")

        nestedAdd.tap() // 1
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem1").element.waitForExistence(timeout: 5),
                      "A first nested row should be added")
        nestedAdd.tap() // 2
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem2").element.waitForExistence(timeout: 5),
                      "A second nested row should be added")
        XCTAssertTrue(nestedAdd.isEnabled, "Nested Add Row should still be enabled at 2 of 3 nested rows")

        nestedAdd.tap() // 3 (at the nested limit)
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem3").element.waitForExistence(timeout: 5),
                      "A third nested row should be added")
        XCTAssertFalse(nestedAdd.isEnabled, "Nested Add Row should be disabled once level1Table1 reaches maxRows (3)")
    }

    /// At the nested schema's maxRows, the More menu's Insert Below and Duplicate items and the
    /// row-form "+" (insert below) button are all disabled for a selected nested row.
    func testCollectionNestedRowAddAffordancesDisabledAtMaxRows() {
        openCollectionDetail()
        expandCollectionRootRow(1)

        // Fill the nested table to its 3-row limit (0 -> 3).
        let nestedAdd = nestedAddRowButton()
        XCTAssertTrue(nestedAdd.waitForExistence(timeout: 5), "Nested Add Row button should appear once the root row is expanded")
        nestedAdd.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem1").element.waitForExistence(timeout: 5), "First nested row should be added")
        nestedAdd.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem2").element.waitForExistence(timeout: 5), "Second nested row should be added")
        nestedAdd.tap()
        XCTAssertTrue(app.images.matching(identifier: "selectNestedRowItem3").element.waitForExistence(timeout: 5), "Third nested row should be added")

        // More menu: Insert Below and Duplicate are present but disabled at the nested limit.
        selectCollectionNestedRow(1)
        tapMore()
        let insert = app.buttons["TableInsertRowIdentifier"]
        XCTAssertTrue(insert.waitForExistence(timeout: 5), "Insert Below should be present")
        XCTAssertFalse(insert.isEnabled, "Insert Below should be disabled at the nested maxRows")
        let duplicate = app.buttons["TableDuplicateRowIdentifier"]
        XCTAssertTrue(duplicate.exists, "Duplicate row should be present")
        XCTAssertFalse(duplicate.isEnabled, "Duplicate row should be disabled at the nested maxRows")

        // Row-form "+" (insert below) is disabled at the nested limit.
        let edit = app.buttons["TableEditRowsIdentifier"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5), "Edit row should be available")
        edit.tap()
        let plus = app.buttons["PlusTheRowButtonIdentifier"]
        XCTAssertTrue(plus.waitForExistence(timeout: 5), "Row-form + button should be present")
        XCTAssertFalse(plus.isEnabled, "Row-form + button should be disabled at the nested maxRows")
    }
}

/// `showInBulkForm == false` (driven by the `--show-in-bulk-form false` launch arg):
/// column decorators are hidden inside the bulk-edit form for multi-row selections.
final class DuplicatePerRowBulkEditHiddenUITests: DuplicatePerRowBulkEditBaseUITests {

    override func getGotoLaunchArguments() -> [(String, String?)] {
        return [("--show-in-bulk-form", "false")]
    }

    /// Table bulk-edit form hides every column decorator when showInBulkForm = false.
    func testTableBulkEditHidesColumnIcons() {
        openTableBulkEdit()

        XCTAssertFalse(app.buttons["decorator_button_Comment"].waitForExistence(timeout: 3),
                       "Comment icon should be hidden in bulk edit when showInBulkForm = false")
        XCTAssertFalse(app.buttons["decorator_button_Camera"].exists,
                       "Camera icon should be hidden in bulk edit when showInBulkForm = false")
        XCTAssertFalse(app.buttons["decorator_button_Flag"].exists,
                       "Flag icon should be hidden in bulk edit when showInBulkForm = false")
    }

    /// Collection bulk-edit form hides every root column decorator when showInBulkForm = false.
    func testCollectionBulkEditHidesColumnIcons() {
        openCollectionBulkEdit()

        XCTAssertFalse(app.buttons["decorator_button_Eye"].waitForExistence(timeout: 3),
                       "Eye icon should be hidden in collection bulk edit when showInBulkForm = false")
        XCTAssertFalse(app.buttons["decorator_button_Info"].exists,
                       "Info icon should be hidden in collection bulk edit when showInBulkForm = false")
    }

    /// showInBulkForm = false only gates multi-row selections: a single-row table edit
    /// still shows its column decorators.
    func testTableSingleRowEditShowsColumnIcons() {
        openTableSingleRowEdit()

        XCTAssertTrue(app.buttons["decorator_button_Comment"].waitForExistence(timeout: 5),
                      "Comment icon should still show in single-row edit when showInBulkForm = false")
        XCTAssertTrue(app.buttons["decorator_button_Camera"].exists,
                      "Camera icon should still show in single-row edit when showInBulkForm = false")
        XCTAssertTrue(app.buttons["decorator_button_Flag"].exists,
                      "Flag icon should still show in single-row edit when showInBulkForm = false")
    }

    /// A single-row collection edit still shows its root column decorators when showInBulkForm = false.
    func testCollectionSingleRowEditShowsColumnIcons() {
        openCollectionSingleRowEdit()

        XCTAssertTrue(app.buttons["decorator_button_Eye"].waitForExistence(timeout: 5),
                      "Eye icon should still show in single-row collection edit when showInBulkForm = false")
        XCTAssertTrue(app.buttons["decorator_button_Info"].exists,
                      "Info icon should still show in single-row collection edit when showInBulkForm = false")
    }
}
