//
//  RequiredLogic.swift
//  JoyfillExample
//
//  Created by Vivek Mac on 17/07/26.
//

import XCTest
import JoyfillModel

final class RequiredLogic: JoyfillUITestsBaseClass {

    private typealias S = DecoratorUITestSupport

    override func getJSONFileNameForTest() -> String {
        return "RequiredLogic"
    }

    // MARK: - Page field helpers (number1 / trigger1 are plain TextFields)

    private func setPageText(_ text: String) {
        scrollToTop()
        let field = app.textFields["Text"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "trigger1 text field should exist")
        field.tap()
        field.typeText(text)
        app.dismissKeyboardIfVisible()
        spinRunloop(0.3)
    }

    private func clearPageText() {
        scrollToTop()
        let field = app.textFields["Text"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "trigger1 text field should exist")
        field.tap()
        field.clearText()
        app.dismissKeyboardIfVisible()
        spinRunloop(0.3)
    }

    private func setPageNumber(_ text: String) {
        scrollToTop()
        let field = app.textFields["Number"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "number1 field should exist")
        field.tap()
        field.typeText(text)
        app.dismissKeyboardIfVisible()
        spinRunloop(0.3)
    }

    private func clearPageNumber() {
        scrollToTop()
        let field = app.textFields["Number"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "number1 field should exist")
        field.tap()
        field.clearText()
        app.dismissKeyboardIfVisible()
        spinRunloop(0.3)
    }

    private func rowFormTextCell(_ boundBy: Int) -> XCUIElement {
        app.textFields.matching(identifier: "EditRowsTextFieldIdentifier").element(boundBy: boundBy)
    }

    // MARK: - Scrolling

    private func scrollToTop(maxSwipes: Int = 8) {
        var n = 0
        let anchor = app.textFields["Number"]
        while n < maxSwipes && !(anchor.exists && anchor.isHittable) {
            app.swipeDown()
            spinRunloop(0.15)
            n += 1
        }
    }

    @discardableResult
    private func scrollToStaticText(_ label: String, maxSwipes: Int = 8) -> Bool {
        let el = app.staticTexts[label]
        var n = 0
        while n < maxSwipes {
            if el.exists && el.isHittable { return true }
            app.swipeUp()
            spinRunloop(0.15)
            n += 1
        }
        return el.exists
    }

    // MARK: - Modal navigation

    private func openTable() { S.openTableDetailView(in: app) }
    private func openCollection() { S.openCollectionDetailView(in: app) }

    private func closeRowForm() {
        let dismiss = app.buttons["DismissEditSingleRowSheetButtonIdentifier"]
        if dismiss.waitForExistence(timeout: 2) {
            dismiss.tap()
            spinRunloop(0.2)
        }
    }

    private func exitModal() {
        closeRowForm()
        goBack()
        spinRunloop(0.3)
    }

    // MARK: - Asterisk lookup

    private func fieldAsterisk(_ title: String) -> XCUIElement {
        app.images["RequiredAsterisk_field_\(title)"]
    }

    private func tableColAsterisk(_ columnID: String) -> XCUIElement {
        app.images["RequiredAsterisk_col_\(columnID)"]
    }

    private func collColAsterisk(_ columnID: String) -> XCUIElement {
        app.images.matching(NSPredicate(format: "identifier BEGINSWITH %@ AND identifier ENDSWITH %@",
                                        "RequiredAsterisk_col_", "_\(columnID)")).firstMatch
    }

    private func existsInForm(_ element: XCUIElement, timeout: TimeInterval = 3) -> Bool {
        if element.waitForExistence(timeout: timeout) { return true }
        for _ in 0..<4 {
            app.swipeUp()
            spinRunloop(0.2)
            if element.exists { return true }
        }
        return element.exists
    }

    // MARK: - A. Field-level required logic (enforce on trigger1 "is filled")

    func testTableFieldAsterisk_appearsWhenTriggerFilled_disappearsWhenCleared() {
        // trigger1 empty at launch -> table field is optional -> no asterisk.
        XCTAssertTrue(app.staticTexts["Table"].waitForExistence(timeout: 5))
        XCTAssertFalse(fieldAsterisk("Table").exists,
                       "Table field should have no asterisk while trigger1 is empty")

        // Fill trigger1 -> enforce condition matches -> table becomes required.
        setPageText("go")
        XCTAssertTrue(fieldAsterisk("Table").waitForExistence(timeout: 3),
                      "Table field asterisk should appear after trigger1 is filled")

        // Clear trigger1 -> back to optional -> asterisk removed.
        clearPageText()
        XCTAssertTrue(fieldAsterisk("Table").waitForNonExistence(timeout: 3),
                      "Table field asterisk should disappear after trigger1 is cleared")
    }

    func testCollectionFieldAsterisk_appearsWhenTriggerFilled_disappearsWhenCleared() {
        scrollToStaticText("Collection")
        XCTAssertFalse(fieldAsterisk("Collection").exists,
                       "Collection field should have no asterisk while trigger1 is empty")

        setPageText("go")
        scrollToStaticText("Collection")
        XCTAssertTrue(fieldAsterisk("Collection").waitForExistence(timeout: 3),
                      "Collection field asterisk should appear after trigger1 is filled")

        clearPageText()
        scrollToStaticText("Collection")
        XCTAssertTrue(fieldAsterisk("Collection").waitForNonExistence(timeout: 3),
                      "Collection field asterisk should disappear after trigger1 is cleared")
    }

    // MARK: - B. Column-level required logic (table)

    func testTableColumnEnforce_asteriskAppearsWhenNumberFilled() {
        // Col A (text1): enforce when number1 is filled. Row B has text1 empty.
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (empty)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3),
                      "Static-required Col B anchor should render in the row-form")
        XCTAssertFalse(tableColAsterisk("text1").exists,
                       "Col A should not be required while number1 is empty")
        exitModal()

        setPageNumber("5")
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(tableColAsterisk("text1")),
                      "Col A should become required once number1 is filled")
    }

    func testTableColumnStaticRequired_asteriskAlwaysPresent() {
        // Col B (dropdown1): static required:true -> always required.
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (empty dropdown)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3),
                      "Static-required Col B should always show an asterisk when empty")
    }

    func testTableColumnUnenforce_noAsteriskWhenNumberEmpty_appearsWhenFilled() {
        // Col D (text3): static required, but UNenforced when number1 is empty.
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (empty)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(tableColAsterisk("text3").exists,
                       "Col D should be optional (unenforced) while number1 is empty")
        exitModal()

        setPageNumber("5")
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(tableColAsterisk("text3")),
                      "Col D static-required should apply once number1 is filled (unenforce no longer matches)")
    }

    // MARK: - B. Column-level required logic (collection root)

    func testCollectionRootColumnEnforce_asteriskWhenNumberFilled() {
        // Root A (text1): enforce when number1 filled. collRoot2 has text1 empty.
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (empty)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3),
                      "Static-required Root B anchor should render")
        XCTAssertFalse(collColAsterisk("text1").exists,
                       "Root A should not be required while number1 is empty")
        exitModal()

        setPageNumber("5")
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(collColAsterisk("text1")),
                      "Root A should become required once number1 is filled")
    }

    func testCollectionRootColumnStaticRequired_asteriskAlwaysPresent() {
        // Root B (dropdown1): static required.
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (empty)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3),
                      "Static-required Root B should always show an asterisk when empty")
    }

    // MARK: - C. Cell-level required logic (per-row, sibling)

    func testTableCellRequired_perRowSibling() {
        // Col C (text2): cell-required when sibling Col A (text1) is filled in that row.
        // rowA has text1 filled -> Col C required; rowB has text1 empty -> not required.
        openTable()
        S.openTableRowEditForm(rowIndex: 1, in: app) // rowA (text1 filled)
        XCTAssertTrue(existsInForm(tableColAsterisk("text2")),
                      "Col C should be required in rowA (sibling Col A filled)")
        closeRowForm()

        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (text1 empty)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(tableColAsterisk("text2").exists,
                       "Col C should not be required in rowB (sibling Col A empty)")
    }

    func testCollectionRootCellRequired_imageSibling() {
        // Root C (image1): cell-required when sibling Root A (text1) filled.
        // collRoot1 text1 filled -> required; collRoot2 text1 empty -> not required.
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app) // collRoot1 (text1 filled)
        XCTAssertTrue(existsInForm(collColAsterisk("image1")),
                      "Root C should be required in collRoot1 (sibling Root A filled)")
        closeRowForm()

        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (text1 empty)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(collColAsterisk("image1").exists,
                       "Root C should not be required in collRoot2 (sibling Root A empty)")
    }

    func testCollectionChildCellRequired_notesSibling() {
        // Child B (notes1): cell-required when sibling Child A (text1) filled.
        // collChild1 text1 filled -> required; collChild2 text1 empty -> not required.
        openCollection()
        S.expandCollectionRootRow(at: 1, in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app) // collChild1 (text1 filled)
        XCTAssertTrue(existsInForm(collColAsterisk("notes1")),
                      "Child B should be required in collChild1 (sibling Child A filled)")
        closeRowForm()

        S.openCollectionNestedRowEditForm(rowIndex: 2, boundBy: 0, in: app) // collChild2 (text1 empty)
        XCTAssertTrue(collColAsterisk("text1").waitForExistence(timeout: 3),
                      "Static-required Child A anchor should render for the empty child row")
        XCTAssertFalse(collColAsterisk("notes1").exists,
                       "Child B should not be required in collChild2 (sibling Child A empty)")
    }

    // MARK: - D. Static required in nested child schema

    func testCollectionChildStaticRequired() {
        // Child A (text1): static required:true -> asterisk on the empty child row.
        openCollection()
        S.expandCollectionRootRow(at: 1, in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 2, boundBy: 0, in: app) // collChild2 (empty)
        XCTAssertTrue(existsInForm(collColAsterisk("text1")),
                      "Static-required Child A should show an asterisk in the empty child row")
    }

    // MARK: - E. Precedence: cellRequiredLogic overrides column requiredLogic per row

    func testTableCellLogicOverridesColumnLogic_perRow() {
        // Col E (text4): column enforce when number1 filled; cell UNenforce when sibling Col A filled.
        // With number1 filled: rowA (text1 filled) -> cell unenforce wins -> optional (no asterisk);
        //                      rowB (text1 empty)  -> column rule applies -> required (asterisk).
        setPageNumber("5")
        openTable()
        S.openTableRowEditForm(rowIndex: 1, in: app) // rowA (text1 filled)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(tableColAsterisk("text4").exists,
                       "Col E cell-unenforce should override column rule in rowA (sibling filled)")
        closeRowForm()

        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (text1 empty)
        XCTAssertTrue(existsInForm(tableColAsterisk("text4")),
                      "Col E column rule should apply in rowB (sibling empty, number filled)")
    }

    func testCollectionCellLogicOverridesColumnLogic_perRow() {
        // Root E (dual1): column enforce when number1 filled; cell UNenforce when sibling Root A filled.
        setPageNumber("5")
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app) // collRoot1 (text1 filled)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(collColAsterisk("dual1").exists,
                       "Root E cell-unenforce should override column rule in collRoot1 (sibling filled)")
        closeRowForm()

        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (text1 empty)
        XCTAssertTrue(existsInForm(collColAsterisk("dual1")),
                      "Root E column rule should apply in collRoot2 (sibling empty, number filled)")
    }

    // MARK: - F. Sibling-edit write path: editing a sibling cell drives cell-required-ness

    func testTableCellRequired_updatesAfterSiblingEditedInRowForm() {
        // Col C (text2): cell-required when sibling Col A (text1) is filled in the same row.
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (text1 empty)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(tableColAsterisk("text2").exists,
                       "Col C should not be required before sibling Col A is filled")

        // Col A (text1) is the first text cell in the row-form; typing commits per keystroke.
        let colA = rowFormTextCell(0)
        XCTAssertTrue(colA.waitForExistence(timeout: 3), "Col A text cell should exist in the row-form")
        colA.tap()
        colA.typeText("x")
        app.dismissKeyboardIfVisible()
        spinRunloop(0.4)

        // Reopen the same row so the column titles recompute from the committed value.
        closeRowForm()
        S.openTableRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(tableColAsterisk("text2")),
                      "Col C should be required after Col A was filled in the row-form")
    }

    func testCollectionRootCellRequired_updatesAfterSiblingEditedInRowForm() {
        // Root C (image1): cell-required when sibling Root A (text1) is filled.
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (text1 empty)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(collColAsterisk("image1").exists,
                       "Root C should not be required before sibling Root A is filled")

        // Root A (text1) is the first text cell in the collection row-form.
        let rootA = rowFormTextCell(0)
        XCTAssertTrue(rootA.waitForExistence(timeout: 3), "Root A text cell should exist in the row-form")
        rootA.tap()
        rootA.typeText("x")
        app.dismissKeyboardIfVisible()
        spinRunloop(0.4)

        closeRowForm()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(collColAsterisk("image1")),
                      "Root C should be required after Root A was filled in the row-form")
    }

    // MARK: - G. Column enforce toggle-off: driver page field cleared removes the asterisk

    func testTableColumnEnforce_toggleOffWhenNumberCleared() {
        // Col A (text1): enforce when number1 filled. Fill -> asterisk; clear -> asterisk gone.
        setPageNumber("5")
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app) // rowB (empty)
        XCTAssertTrue(existsInForm(tableColAsterisk("text1")),
                      "Col A should be required while number1 is filled")
        exitModal()

        clearPageNumber()
        openTable()
        S.openTableRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(tableColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(tableColAsterisk("text1").exists,
                       "Col A should be optional again after number1 is cleared")
    }

    func testCollectionRootColumnEnforce_toggleOffWhenNumberCleared() {
        // Root A (text1): enforce when number1 filled. Fill -> asterisk; clear -> asterisk gone.
        setPageNumber("5")
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (empty)
        XCTAssertTrue(existsInForm(collColAsterisk("text1")),
                      "Root A should be required while number1 is filled")
        exitModal()

        clearPageNumber()
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(collColAsterisk("text1").exists,
                       "Root A should be optional again after number1 is cleared")
    }

    // MARK: - H. Collection parity: root-column unenforce & child-column requiredLogic

    func testCollectionRootColumnUnenforce_noAsteriskWhenNumberEmpty_appearsWhenFilled() {
        // Root D (text3): static required, but UNenforced when number1 is empty (parity with table Col D).
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app) // collRoot2 (empty)
        XCTAssertTrue(collColAsterisk("dropdown1").waitForExistence(timeout: 3))
        XCTAssertFalse(collColAsterisk("text3").exists,
                       "Root D should be optional (unenforced) while number1 is empty")
        exitModal()

        setPageNumber("5")
        openCollection()
        S.openCollectionRootRowEditForm(rowIndex: 2, in: app)
        XCTAssertTrue(existsInForm(collColAsterisk("text3")),
                      "Root D static-required should apply once number1 is filled (unenforce no longer matches)")
    }

    func testCollectionChildColumnEnforce_asteriskWhenNumberFilled() {
        // Child C (flag1): column-level enforce when number1 filled (child-schema requiredLogic).
        // expandCollectionRootRow is a toggle, so `openChildRowForm` only expands the root when
        // the nested edit button isn't already visible — robust whether or not the collection
        // retains its expanded state across a close/reopen.
        openCollection()
        openChildRowForm() // collChild2 (empty)
        XCTAssertTrue(collColAsterisk("text1").waitForExistence(timeout: 3),
                      "Static-required Child A anchor should render for the empty child row")
        XCTAssertFalse(collColAsterisk("flag1").exists,
                       "Child C should not be required while number1 is empty")

        // Fill number1 in a fresh open, then re-open the child row-form for the positive check.
        exitModal()
        setPageNumber("5")
        openCollection()
        openChildRowForm()
        XCTAssertTrue(existsInForm(collColAsterisk("flag1")),
                      "Child C column enforce should apply once number1 is filled")
    }

    private func openChildRowForm() {
        let childEdit = app.images.matching(identifier: "SingleClickEditNestedButton2").firstMatch
        if !childEdit.waitForExistence(timeout: 1) {
            S.expandCollectionRootRow(at: 1, in: app)
        }
        S.openCollectionNestedRowEditForm(rowIndex: 2, boundBy: 0, in: app)
    }
}
