//
//  FormulaInCell.swift
//  JoyfillExample
//
//  Created by Vivek's Mac on 16/09/26.
//

import XCTest
import JoyfillModel

/// UI coverage for Excel-style formulas in table and collection cells.
///
/// The fixture `FormulaInCell.json` is built so every expected result is a unique string,
/// which lets a test assert "this result is on screen" without depending on how many rows
/// the grid happened to render.
///
/// Table columns, in the order that fixes their spreadsheet letters:
///
///     A Qty (number)  B Price (number)  C Total (text, `=A * B`)  D Summary (text, `=CONCAT("T", C)`)
///
/// | row | Qty | Price | Total cell           | Total | Summary |
/// |-----|-----|-------|----------------------|-------|---------|
/// |  1  |  2  |   3   | —                    | 6     | T6      |
/// |  2  |  5  |   4   | —                    | 20    | T20     |
/// |  3  |  —  |   —   | —                    | 0     | T0      |
/// |  4  | 10  |   7   | `=A + B`             | 17    | T17     |
/// |  5  |  1  |   1   | `MANUAL`             | —     | TMANUAL |
/// |  6  |  8  |   2   | `=NOSUCH(A)`         | Error | Error   |
/// |  7  |  6  |   5   | `=Qty * Price`       | 30    | T30     |
/// |  8  |  3  |   9   | `=<colId> + <colId>` | 12    | T12     |
/// |  9  |  4  |   2   | `=<ident> * <ident>` | 8     | T8      |
/// | 10  |  5  |   0   | `=A * taxRate`       | 10    | T10     |
final class FormulaInCell: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "FormulaInCell"
    }

    // MARK: - Fixture constants

    private enum TableColumn {
        static let qty = "6aaa3c25766e371e368282c2"
        static let price = "6aaa3c266dd2f692c4aaf941"
        static let total = "6aa91ddd08ef14e356a4b465"
        static let summary = "6aaa3c990000000000000001"
    }

    private enum CollectionColumn {
        static let qty = "6aaa3c3b34d6a895befea8a6"
        static let price = "6aaa3c3d81a2e4bdada17994"
        static let total = "6813008e76da519a97819c69"
    }

    /// Identifier carried by the overlay that renders a formula result.
    private static let formulaCellID = "TableFormulaCellIdentifier"

    // MARK: - Locating formula results

    /// Every formula result currently in the accessibility tree.
    ///
    /// Matched against `descendants(matching: .any)` rather than `staticTexts`: the overlay
    /// sits on top of a `TextEditor` in the grid and a `TextField` in the row form, and the
    /// two surfaces do not always expose it as the same element type.
    private func formulaCells() -> XCUIElementQuery {
        return app.descendants(matching: .any).matching(identifier: Self.formulaCellID)
    }

    private func formulaCell(_ text: String) -> XCUIElement {
        let predicate = NSPredicate(format: "identifier == %@ AND label == %@", Self.formulaCellID, text)
        return app.descendants(matching: .any).matching(predicate).firstMatch
    }

    private func gridScrollView() -> XCUIElement {
        let named = app.scrollViews["TableScrollView"]
        return named.exists ? named : app.scrollViews.firstMatch
    }

    /// Waits for a formula result, swiping the grid when it does not turn up.
    ///
    /// The grid is a lazy stack, so a column or row that is off-screen is absent from the
    /// accessibility tree entirely rather than merely un-hittable. How far right the fourth
    /// column sits depends on the device width, so the swipes are not optional on a phone.
    @discardableResult
    private func waitForFormulaCell(_ text: String, timeout: TimeInterval = 4) -> Bool {
        if formulaCell(text).waitForExistence(timeout: timeout) { return true }

        let grid = gridScrollView()
        for _ in 0..<4 {
            grid.swipeLeft()
            spinRunloop(0.3)
            if formulaCell(text).exists { return true }
        }
        for _ in 0..<3 {
            app.swipeUp()
            spinRunloop(0.3)
            if formulaCell(text).exists { return true }
        }
        return false
    }

    private func assertFormulaCell(_ text: String,
                                   _ message: String,
                                   file: StaticString = #file,
                                   line: UInt = #line) {
        XCTAssertTrue(waitForFormulaCell(text), message, file: file, line: line)
    }

    // MARK: - Navigation

    private func openTable() {
        let button = app.buttons["TableDetailViewIdentifier"]
        for _ in 0..<6 where !button.exists {
            app.swipeUp()
            spinRunloop(0.2)
        }
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Table quick-view button never appeared")
        button.tap()
        XCTAssertTrue(waitForAppStability(timeout: 10), "Table modal did not settle")
    }

    private func openCollection() {
        let button = app.buttons["CollectionDetailViewIdentifier"]
        for _ in 0..<8 where !button.exists {
            app.swipeUp()
            spinRunloop(0.2)
        }
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Collection quick-view button never appeared")
        button.tap()
        XCTAssertTrue(waitForAppStability(timeout: 10), "Collection modal did not settle")
    }

    /// `rowIndex` is 1-based; the table's pencil identifiers are 0-based.
    private func openTableRowForm(_ rowIndex: Int) {
        let pencil = app.images["SingleClickEditButton\(rowIndex - 1)"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "Pencil for table row \(rowIndex) not found")
        pencil.tap()
        spinRunloop(0.4)
    }

    /// `rowIndex` is 1-based, and so are the collection's pencil identifiers.
    private func openCollectionRootRowForm(_ rowIndex: Int) {
        let pencil = app.images["SingleClickEditButton\(rowIndex)"]
        XCTAssertTrue(pencil.waitForExistence(timeout: 5), "Pencil for collection row \(rowIndex) not found")
        pencil.tap()
        spinRunloop(0.4)
    }

    private func closeRowForm() {
        let dismiss = app.buttons["DismissEditSingleRowSheetButtonIdentifier"]
        if dismiss.waitForExistence(timeout: 2) {
            dismiss.tap()
        } else {
            swipeSheetDown()
        }
        spinRunloop(0.3)
    }

    private func expandCollectionRootRow(_ index: Int) {
        let expander = app.images["CollectionExpandCollapseButton\(index)"]
        XCTAssertTrue(expander.waitForExistence(timeout: 5), "Expander for collection row \(index) not found")
        expander.tap()
        spinRunloop(0.5)
    }

    // MARK: - Row-form field access

    /// Row-form fields follow column order, so Qty is 0 and Price is 1.
    private func rowFormNumberField(_ index: Int) -> XCUIElement {
        return app.textFields.matching(identifier: "EditRowsNumberFieldIdentifier").element(boundBy: index)
    }

    /// Row-form text fields follow column order, so Total is 0 and Summary is 1.
    private func rowFormTextField(_ index: Int) -> XCUIElement {
        return app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").element(boundBy: index)
    }

    private func setRowFormNumber(_ index: Int, to text: String) {
        let field = rowFormNumberField(index)
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Row-form number field \(index) not found")
        field.tap()
        field.clearText()
        field.typeText(text)
        app.dismissKeyboardIfVisible()
        spinRunloop(0.5)
    }

    /// `clearText()` reads the value once and sends that many backspaces in a single burst, so
    /// keystrokes are lost while the keyboard is still animating in and the caret only deletes
    /// what sits to its left. Wait for the keyboard, retype the caret to the trailing edge, and
    /// delete until the field really is empty.
    private func clearRowFormField(_ field: XCUIElement) {
        field.tap()
        _ = app.keyboards.element.waitForExistence(timeout: 5)
        for _ in 0..<5 {
            let value = field.value as? String ?? ""
            if value.isEmpty { break }
            field.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
            field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
            spinRunloop(0.3)
        }
        XCTAssertEqual(field.value as? String ?? "", "", "Row-form field did not clear")
    }

    private func setRowFormText(_ index: Int, to text: String) {
        let field = rowFormTextField(index)
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Row-form text field \(index) not found")
        field.tap()
        field.clearText()
        field.typeText(text)
        app.dismissKeyboardIfVisible()
        spinRunloop(0.5)
    }

    // MARK: - onChange inspection

    /// Cells carried by the most recent `rowUpdate`, which holds only the cells that changed.
    private func lastChangedRowCells() -> [String: Any] {
        for change in onChangeOptionalResults().reversed() {
            if let row = change.change?["row"] as? [String: Any],
               let cells = row["cells"] as? [String: Any] {
                return cells
            }
        }
        return [:]
    }

    // MARK: - Table: column formulas

    func testColumnFormula_computesIndependentlyPerRow() {
        openTable()
        assertFormulaCell("6", "Row 1 Total should be 2 * 3")
        assertFormulaCell("20", "Row 2 Total should be 5 * 4")
    }

    func testBlankCells_evaluateAsZero() {
        openTable()
        assertFormulaCell("0", "A row with no Qty or Price should read both as 0, giving 0")
    }

    func testChainedColumnFormula_readsAnotherFormulaColumn() {
        openTable()
        assertFormulaCell("T6", "Summary should read Total's computed 6")
        assertFormulaCell("T20", "Summary should read Total's computed 20")
    }

    func testFormulaResult_rendersOnQuickViewWithoutOpeningTheModal() {
        // The quick view renders cells read-only, so the result arrives as its own static text
        // rather than as an overlay on an editor.
        let readonly = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertTrue(readonly.element(boundBy: 0).waitForExistence(timeout: 5),
                      "Quick view should render read-only table cells")

        let sixOnQuickView = app.staticTexts
            .matching(NSPredicate(format: "identifier == %@ AND label == %@",
                                  "TableTextFieldIdentifierReadonly", "6"))
            .firstMatch
        XCTAssertTrue(sixOnQuickView.waitForExistence(timeout: 5),
                      "Row 1's computed Total should already be visible on the form's quick view")
    }

    // MARK: - Table: cell formulas beat column formulas

    func testCellFormula_overridesColumnFormula() {
        openTable()
        // The column would give 10 * 7 = 70; the cell's `=A + B` gives 17.
        assertFormulaCell("17", "Row 4's cell formula should win over the column's")
        XCTAssertFalse(formulaCell("70").exists, "The column formula must not also be applied")
    }

    func testChainedColumnFormula_followsACellFormula() {
        openTable()
        // Summary is declared against the column, but Total is overridden on this row, so the
        // chain has to pick up the cell's result rather than the column's.
        assertFormulaCell("T17", "Summary should read the cell formula's 17, not the column's 70")
    }

    func testLiteralValue_overridesColumnFormula() {
        openTable()
        let manual = app.textViews
            .matching(NSPredicate(format: "identifier == %@ AND value == %@",
                                  "TabelTextFieldIdentifier", "MANUAL"))
            .firstMatch
        XCTAssertTrue(manual.waitForExistence(timeout: 5),
                      "A literal cell should stay editable and keep its own text")
        XCTAssertFalse(formulaCell("MANUAL").exists,
                       "A literal is not computed, so it should carry no formula overlay")
        assertFormulaCell("TMANUAL", "Summary should read the literal straight through")
    }

    // MARK: - Table: errors

    func testInvalidFormula_rendersError() {
        openTable()
        assertFormulaCell("Error", "An unknown function should render as Error")
    }

    func testError_propagatesToTheDependentColumn() {
        openTable()

        let errors = gridScrollView().descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ AND label == %@",
                                  Self.formulaCellID, "Error"))

        var found = waitUntil(5) { errors.count == 2 }
        for _ in 0..<4 where !found {
            gridScrollView().swipeLeft()
            spinRunloop(0.3)
            found = errors.count == 2
        }
        XCTAssertTrue(found, "Both Total and Summary should read Error, got \(errors.count)")
    }

    // MARK: - Table: reference resolution tiers

    func testReference_byColumnTitle() {
        openTable()
        assertFormulaCell("30", "`=Qty * Price` should resolve both columns by title")
    }

    func testReference_byColumnId() {
        openTable()
        // Column ids are ObjectIds and so begin with a digit; this only resolves because the
        // parser escapes them first.
        assertFormulaCell("12", "A formula written against raw column ids should resolve")
    }

    func testReference_byColumnIdentifier() {
        openTable()
        assertFormulaCell("8", "A formula written against column identifiers should resolve")
    }

    func testReference_toADocumentField() {
        openTable()
        // `taxRate` is not a column, so the row scope hands it to the document.
        assertFormulaCell("10", "`=A * taxRate` should read the page's Rate field, which is 2")
    }

    // MARK: - Table: recalculation

    func testEditingQtyInTheGrid_recomputesTotalAndSummary() {
        openTable()
        assertFormulaCell("6", "Row 1 should start at 2 * 3")

        let qty = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(qty.waitForExistence(timeout: 5), "Row 1's Qty cell not found")
        qty.tap()
        qty.clearText()
        qty.typeText("7")
        app.dismissKeyboardIfVisible()
        spinRunloop(0.6)

        assertFormulaCell("21", "Total should recompute to 7 * 3")
        assertFormulaCell("T21", "Summary should follow Total to T21")
        XCTAssertFalse(formulaCell("6").exists, "The stale 6 should be gone")
    }

    func testEditingQtyInTheRowForm_recomputesTotalAndSummary() {
        openTable()
        openTableRowForm(2)

        XCTAssertTrue(formulaCell("20").waitForExistence(timeout: 5),
                      "Row 2's form should open showing 5 * 4")
        setRowFormNumber(0, to: "9")

        XCTAssertTrue(formulaCell("36").waitForExistence(timeout: 5),
                      "Total should recompute to 9 * 4")
        XCTAssertTrue(formulaCell("T36").waitForExistence(timeout: 5),
                      "Summary should follow to T36")
        closeRowForm()
    }

    func testEditingAnInputOfACellFormula_recomputesIt() {
        openTable()
        openTableRowForm(4)
        XCTAssertTrue(formulaCell("17").waitForExistence(timeout: 5),
                      "Row 4's form should open on its cell formula's 10 + 7")

        setRowFormNumber(0, to: "2")

        // The refresh set is built from the column definitions, which cannot see a formula
        // that belongs to a row, so a cell formula is seeded separately. This is that path.
        XCTAssertTrue(formulaCell("9").waitForExistence(timeout: 5),
                      "The cell formula should recompute to 2 + 7")
        XCTAssertTrue(formulaCell("T9").waitForExistence(timeout: 5),
                      "Summary should follow the cell formula to T9")
        XCTAssertFalse(formulaCell("14").exists, "The column's 2 * 7 must not take over")
        closeRowForm()
    }

    func testClearingACellFormula_handsTheRowBackToTheColumnFormula() {
        openTable()
        openTableRowForm(4)
        XCTAssertTrue(formulaCell("17").waitForExistence(timeout: 5),
                      "Row 4's form should open on its cell formula's 10 + 7")

        let total = rowFormTextField(0)
        XCTAssertTrue(total.waitForExistence(timeout: 5), "Total field not found in the row form")
        clearRowFormField(total)
        app.dismissKeyboardIfVisible()

        // The row form hides the result overlay while its field holds focus, so the fallback is
        // read off the grid rather than the form.
        closeRowForm()
        spinRunloop(0.6)

        // An empty cell carries no formula, so the column's `=A * B` takes the row back.
        assertFormulaCell("70", "Total should fall back to the column's 10 * 7")
        assertFormulaCell("T70", "Summary should follow the fallback to T70")
        XCTAssertFalse(formulaCell("17").exists, "The cleared cell formula's result should be gone")
    }

    func testRowFormNavigation_showsEachRowsOwnResult() {
        openTable()
        openTableRowForm(1)
        XCTAssertTrue(formulaCell("6").waitForExistence(timeout: 5), "Row 1's form should show 6")

        let next = app.buttons["LowerRowButtonIdentifier"]
        XCTAssertTrue(next.waitForExistence(timeout: 5), "Row-form next-row chevron not found")
        next.tap()
        spinRunloop(0.5)

        XCTAssertTrue(formulaCell("20").waitForExistence(timeout: 5), "Row 2's form should show 20")
        closeRowForm()
    }

    // MARK: - Table: what reaches the document

    func testFocusingAFormulaCell_revealsTheCellIsEmpty() {
        openTable()
        openTableRowForm(1)

        XCTAssertTrue(formulaCell("6").waitForExistence(timeout: 5), "Row 1's form should show 6")
        let total = rowFormTextField(0)
        XCTAssertTrue(total.waitForExistence(timeout: 5), "Total field not found in the row form")
        total.tap()
        spinRunloop(0.4)

        // The result is display-only: a column-driven cell holds nothing at all.
        XCTAssertEqual(total.value as? String, "",
                       "A column-driven cell should be empty once its overlay is out of the way")
        app.dismissKeyboardIfVisible()
        closeRowForm()
    }

    func testFocusingACellFormula_revealsTheFormulaAndBlurRestoresTheResult() {
        openTable()
        openTableRowForm(4)

        XCTAssertTrue(formulaCell("17").waitForExistence(timeout: 5), "Row 4's form should show 17")
        let total = rowFormTextField(0)
        total.tap()
        spinRunloop(0.4)
        XCTAssertEqual(total.value as? String, "=A + B",
                       "Focusing should expose the formula the author typed")

        app.dismissKeyboardIfVisible()
        spinRunloop(0.5)
        XCTAssertTrue(formulaCell("17").waitForExistence(timeout: 5),
                      "Blurring should put the result back")
        closeRowForm()
    }

    func testEditingACell_neverWritesAFormulaResultToTheDocument() {
        openTable()
        openTableRowForm(1)
        setRowFormNumber(0, to: "7")

        let cells = lastChangedRowCells()
        XCTAssertNotNil(cells[TableColumn.qty], "The edited Qty should be in the change payload")
        XCTAssertNil(cells[TableColumn.total],
                     "A computed Total must never be written back to the document")
        XCTAssertNil(cells[TableColumn.summary],
                     "A computed Summary must never be written back to the document")
        closeRowForm()
    }

    func testTypingAFormula_storesTheFormulaRatherThanItsResult() {
        openTable()
        openTableRowForm(3)

        setRowFormText(0, to: "=A + B")

        let cells = lastChangedRowCells()
        XCTAssertEqual(cells[TableColumn.total] as? String, "=A + B",
                       "The cell should hold the formula text the author typed")
        closeRowForm()
    }

    // MARK: - Table: row lifecycle

    func testAddingARow_computesItsFormulasImmediately() {
        openTable()
        let zeros = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ AND label == %@", Self.formulaCellID, "0"))
        XCTAssertTrue(waitUntil(5) { zeros.count == 1 },
                      "Only the blank fixture row should read 0 to begin with")

        let addRow = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRow.waitForExistence(timeout: 5), "Add-row button not found")
        addRow.tap()
        spinRunloop(0.6)

        XCTAssertTrue(waitUntil(5) { zeros.count == 2 },
                      "A newly added blank row should compute 0 straight away")
    }

    func testDeletingARow_leavesTheOtherRowsResultsIntact() {
        openTable()
        assertFormulaCell("6", "Row 1 should start at 6")

        let selector = app.images.matching(identifier: "MyButton").element(boundBy: 0)
        XCTAssertTrue(selector.waitForExistence(timeout: 5), "Row 1's selector not found")
        selector.tap()
        spinRunloop(0.3)

        app.buttons["TableMoreButtonIdentifier"].waitAndTap(timeout: 5, message: "More button not found")
        app.buttons["TableDeleteRowIdentifier"].waitAndTap(timeout: 5, message: "Delete-row button not found")
        spinRunloop(0.6)

        XCTAssertTrue(formulaCell("6").waitForNonExistence(timeout: 5), "Row 1's result should be gone")
        assertFormulaCell("20", "Row 2's result should survive the delete")
    }

    // MARK: - Collection: root schema

    func testCollectionRoot_columnFormulaComputes() {
        openCollection()
        assertFormulaCell("6", "Root row 1 Total should be 2 * 3")
        assertFormulaCell("81", "Root row 2 Total should be 9 * 9")
    }

    func testCollectionRoot_blankRowEvaluatesAsZero() {
        openCollection()
        assertFormulaCell("0", "A blank root row should compute 0")
    }

    func testCollectionRoot_cellFormulaOverridesColumnFormula() {
        openCollection()
        // The column would give 4 * 4 = 16; the cell's `=Qty + Price` gives 8.
        assertFormulaCell("8", "Root row 4's cell formula should win")
        XCTAssertFalse(formulaCell("16").exists, "The column formula must not also be applied")
    }

    func testCollectionRoot_editingACellRecomputes() {
        openCollection()
        openCollectionRootRowForm(1)

        XCTAssertTrue(formulaCell("6").waitForExistence(timeout: 5), "Root row 1's form should show 6")
        setRowFormNumber(0, to: "5")
        XCTAssertTrue(formulaCell("15").waitForExistence(timeout: 5),
                      "Total should recompute to 5 * 3")
        closeRowForm()
    }

    func testCollectionEditingACell_neverWritesAFormulaResultToTheDocument() {
        openCollection()
        openCollectionRootRowForm(1)
        setRowFormNumber(0, to: "7")

        // The collection has its own view model and its own refresh call site, so the
        // guarantee that a result is display-only has to be proved here too.
        let cells = lastChangedRowCells()
        XCTAssertNotNil(cells[CollectionColumn.qty], "The edited Qty should be in the change payload")
        XCTAssertNil(cells[CollectionColumn.total],
                     "A computed Total must never be written back to the document")
        closeRowForm()
    }

    // MARK: - Collection: nested schema

    func testCollectionNested_formulaResolvesAgainstItsOwnSchema() {
        openCollection()
        expandCollectionRootRow(1)

        // Root and child both declare `=A * B`, but the letters are positional and each schema
        // has its own columns: the child's A is Rate, not the root's Qty.
        assertFormulaCell("40", "Nested row 1 Cost should be Rate 10 * Hours 4")
        XCTAssertTrue(formulaCell("6").exists,
                      "The root row's own 2 * 3 should be unaffected by the child schema")
    }

    func testCollectionNested_cellFormulaOverridesColumnFormula() {
        openCollection()
        expandCollectionRootRow(1)

        // The column would give 7 * 3 = 21; the cell's `=A + B` gives 10.
        assertFormulaCell("10", "Nested row 2's cell formula should win")
        XCTAssertFalse(formulaCell("21").exists, "The column formula must not also be applied")
    }

    func testCollectionNested_editingACellRecomputes() {
        openCollection()
        expandCollectionRootRow(1)
        assertFormulaCell("40", "Nested row 1 should start at 40")

        let rate = app.textFields.matching(identifier: "TabelNumberFieldIdentifier")
            .element(boundBy: 2)
        XCTAssertTrue(rate.waitForExistence(timeout: 5), "Nested Rate cell not found")
        rate.tap()
        rate.clearText()
        rate.typeText("5")
        app.dismissKeyboardIfVisible()
        spinRunloop(0.6)

        assertFormulaCell("20", "Nested Cost should recompute to 5 * 4")
    }

    func testCollectionNested_addingARowComputesItsFormula() {
        openCollection()
        expandCollectionRootRow(1)

        let zeros = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ AND label == %@", Self.formulaCellID, "0"))
        let before = zeros.count

        let addNested = app.buttons.matching(identifier: "collectionSchemaAddRowButton").element(boundBy: 0)
        XCTAssertTrue(addNested.waitForExistence(timeout: 5), "Nested add-row button not found")
        addNested.tap()
        spinRunloop(0.6)

        XCTAssertTrue(waitUntil(5) { zeros.count == before + 1 },
                      "A new nested row should compute 0 straight away")
    }
}
