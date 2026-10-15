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
