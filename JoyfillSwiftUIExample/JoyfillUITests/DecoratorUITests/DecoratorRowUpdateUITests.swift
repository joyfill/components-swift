import XCTest

// Table column decorator actions (from DecoratorToRowUpdate.json, tableColumnOrder)
private let tableDropdownAction    = "Comment"   // dropdown   → "Yes"
private let tableTextAction        = "Camera"    // text       → "Updated #1"
private let tableMultiSelectAction = "Import"    // multiSelect → "Option 1"
private let tableImageAction       = "Image"     // image      → 1 image added
private let tableNumberAction      = "File"      // number     → 10
private let tableDateAction        = "Download"  // date       → current epoch
private let tableBlockAction       = "Claud"     // block      → display-only
private let tableBarcodeAction     = "Filter"    // barcode    → "Updated #1"
private let tableSignatureAction   = "Share"     // signature  → image URL

// Collection root-level decorator actions (collectionSchemaId: text, dropdown, image)
private let collRootTextAction     = "flag"      // text       → "Updated #1"
private let collRootDropdownAction = "plus"      // dropdown   → "High"
private let collRootImageAction    = "info"      // image      → 1 image added

// Collection level-1 decorator actions (level1Table1: multiSelect, number, date)
private let collL1MultiSelectAction = "eye"        // multiSelect → "Option 1"
private let collL1NumberAction      = "magnet"     // number      → 10
private let collL1DateAction        = "folderopen" // date        → current epoch

// Collection level-2 decorator actions (level2Table1: signature, barcode, block)
private let collL2SignatureAction = "paper"    // signature → image URL
private let collL2BarcodeAction   = "filter"   // barcode   → "Updated #1"
private let collL2BlockAction     = "rotate"   // block     → display-only

// MARK: - DecoratorRowUpdateUITests

final class DecoratorRowUpdateUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--disable-animations"]
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for label in ["Allow", "OK", "Continue", "Don't Allow"] {
                if alert.buttons[label].exists { alert.buttons[label].tap(); return true }
            }
            return false
        }
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch")

        // Navigate from OptionSelectionView → DecoratorRowUpdateDemoView
        let card = app.staticTexts["Decorator → Row Change"]
        if !card.waitForExistence(timeout: 5) {
            app.swipeUp()
            _ = card.waitForExistence(timeout: 3)
        }
        XCTAssertTrue(card.exists, "Decorator → Row Change card not found in OptionSelectionView")
        card.tap()
        spinRunloop(0.2)

        let continueBtn = app.buttons["Continue"]
        XCTAssertTrue(continueBtn.waitForExistence(timeout: 3), "Continue button not found")
        continueBtn.tap()
        spinRunloop(0.5)
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    // MARK: - Table

    /// Opens table row 1's edit form, taps every column decorator once,
    /// verifies each field updates live, then dismisses and checks the grid.
    func testTableDecoratorUpdatesRowFormAndGrid() {
        typealias S = DecoratorUITestSupport

        S.openTableDetailView(in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)

        // Dropdown → "Yes" (first option)
        tapDecoratorAndAssertStaticText(action: tableDropdownAction, expected: "Yes")
        // Text → "Updated #1" (TextField inside TableTextRowFormView)
        tapDecoratorAndAssertTextField(action: tableTextAction, identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        // MultiSelect → "Option 1" (first option shown as Text inside button)
        tapDecoratorAndAssertStaticText(action: tableMultiSelectAction, expected: "Option 1")
        // Image → cell receives one image (container exists)
        tapDecoratorAndAssertExists(action: tableImageAction, identifier: "EditRowsImageFieldIdentifier")
        // Number → "10" (TextField inside TableNumberView, identifier "TabelNumberFieldIdentifier")
        tapDecoratorAndAssertTextField(action: tableNumberAction, identifier: "TabelNumberFieldIdentifier", expected: "10")
        // Date → inner ChangeCellDateIdentifier button has a non-empty label
        tapDecoratorAndAssertButtonHasValue(action: tableDateAction, identifier: "ChangeCellDateIdentifier")
        // Block → display-only, no row-form editor
        tapDecoratorDisplayOnly(action: tableBlockAction)
        // Barcode → "Updated #1" (TextEditor inside TableBarcodeView, identifier "TableBarcodeFieldIdentifier")
        tapDecoratorAndAssertTextView(action: tableBarcodeAction, identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        // Signature → field container renders after URL is set
        tapDecoratorAndAssertExists(action: tableSignatureAction, identifier: "EditRowsSignatureFieldIdentifier")

        dismissSheet()

        assertGridTextView(identifier: "TabelTextFieldIdentifier", expected: "Updated #1")
        assertGridTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertGridButtonContains(identifier: "TableDropdownIdentifier", text: "Yes")
        assertGridButtonContains(identifier: "TableMultiSelectionFieldIdentifier", text: "Option 1")
        assertGridButtonHasValue(identifier: "ChangeCellDateIdentifier")
        assertGridButtonExists(identifier: "TableSignatureOpenSheetButton")
    }
    
    // MARK: - Add Row / Insert Below persistence

    /// Opens row 1's form, sets every column via decorator taps, dismisses,
    /// taps Add Row, then re-opens row 1 and verifies all values survive.
    func testTableDecoratorValuesPreservedAfterAddRow() {
        typealias S = DecoratorUITestSupport

        S.openTableDetailView(in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)

        tapDecoratorAndAssertStaticText(action: tableDropdownAction, expected: "Yes")
        tapDecoratorAndAssertTextField(action: tableTextAction, identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        tapDecoratorAndAssertStaticText(action: tableMultiSelectAction, expected: "Option 1")
        tapDecoratorAndAssertExists(action: tableImageAction, identifier: "EditRowsImageFieldIdentifier")
        tapDecoratorAndAssertTextField(action: tableNumberAction, identifier: "TabelNumberFieldIdentifier", expected: "10")
        tapDecoratorAndAssertButtonHasValue(action: tableDateAction, identifier: "ChangeCellDateIdentifier")
        tapDecoratorDisplayOnly(action: tableBlockAction)
        tapDecoratorAndAssertTextView(action: tableBarcodeAction, identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        tapDecoratorAndAssertExists(action: tableSignatureAction, identifier: "EditRowsSignatureFieldIdentifier")

        dismissSheet()

        // Add Row is in the table view (accessible once the row-form sheet is dismissed)
        let addRowBtn = app.buttons["TableAddRowIdentifier"]
        XCTAssertTrue(addRowBtn.waitForExistence(timeout: 3), "Add Row button not found")
        addRowBtn.tap()
        spinRunloop(0.5)

        // Row 1 is still at index 0 (new row was appended at the end)
        S.openTableRowEditForm(rowIndex: 1, in: app)

        assertRowFormStaticText("Yes")
        assertRowFormTextField(identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        assertRowFormStaticText("Option 1")
        assertRowFormExists(identifier: "EditRowsImageFieldIdentifier")
        assertRowFormTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertRowFormButtonHasValue(identifier: "ChangeCellDateIdentifier")
        assertRowFormTextView(identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        assertRowFormExists(identifier: "EditRowsSignatureFieldIdentifier")

        dismissSheet()

        assertGridTextView(identifier: "TabelTextFieldIdentifier", expected: "Updated #1")
        assertGridTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertGridButtonContains(identifier: "TableDropdownIdentifier", text: "Yes")
        assertGridButtonContains(identifier: "TableMultiSelectionFieldIdentifier", text: "Option 1")
        assertGridButtonHasValue(identifier: "ChangeCellDateIdentifier")
        assertGridButtonExists(identifier: "TableSignatureOpenSheetButton")
    }

    /// Opens row 1's form, sets every column via decorator taps, then taps the
    /// "+" (Insert Below) button — which inserts a row below and navigates to it.
    /// Navigates back to row 1 and verifies all values survive.
    func testTableDecoratorValuesPreservedAfterInsertBelow() {
        typealias S = DecoratorUITestSupport

        S.openTableDetailView(in: app)
        S.openTableRowEditForm(rowIndex: 1, in: app)

        tapDecoratorAndAssertStaticText(action: tableDropdownAction, expected: "Yes")
        tapDecoratorAndAssertTextField(action: tableTextAction, identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        tapDecoratorAndAssertStaticText(action: tableMultiSelectAction, expected: "Option 1")
        tapDecoratorAndAssertExists(action: tableImageAction, identifier: "EditRowsImageFieldIdentifier")
        tapDecoratorAndAssertTextField(action: tableNumberAction, identifier: "TabelNumberFieldIdentifier", expected: "10")
        tapDecoratorAndAssertButtonHasValue(action: tableDateAction, identifier: "ChangeCellDateIdentifier")
        tapDecoratorDisplayOnly(action: tableBlockAction)
        tapDecoratorAndAssertTextView(action: tableBarcodeAction, identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        tapDecoratorAndAssertExists(action: tableSignatureAction, identifier: "EditRowsSignatureFieldIdentifier")

        // "+" button inserts a row below and navigates the form to the new row
        let plusBtn = app.buttons["PlusTheRowButtonIdentifier"]
        XCTAssertTrue(plusBtn.waitForExistence(timeout: 3), "Plus (Insert Below) button not found in row form")
        plusBtn.tap()
        spinRunloop(0.5)

        // Navigate back to row 1 (the < chevron goes to the row above the newly-selected one)
        let upperBtn = app.buttons["UpperRowButtonIdentifier"]
        XCTAssertTrue(upperBtn.waitForExistence(timeout: 3), "Upper row (←) button not found")
        upperBtn.tap()
        spinRunloop(0.5)

        // All values must survive the insert-below + row-navigation cycle
        assertRowFormStaticText("Yes")
        assertRowFormTextField(identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        assertRowFormStaticText("Option 1")
        assertRowFormExists(identifier: "EditRowsImageFieldIdentifier")
        assertRowFormTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertRowFormButtonHasValue(identifier: "ChangeCellDateIdentifier")
        assertRowFormTextView(identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        assertRowFormExists(identifier: "EditRowsSignatureFieldIdentifier")

        dismissSheet()

        assertGridTextView(identifier: "TabelTextFieldIdentifier", expected: "Updated #1")
        assertGridTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertGridButtonContains(identifier: "TableDropdownIdentifier", text: "Yes")
        assertGridButtonContains(identifier: "TableMultiSelectionFieldIdentifier", text: "Option 1")
        assertGridButtonHasValue(identifier: "ChangeCellDateIdentifier")
        assertGridButtonExists(identifier: "TableSignatureOpenSheetButton")
    }

    // MARK: - Collection root level

    /// Opens collection root row 1's edit form, taps all 3 decorators (text, dropdown,
    /// image), verifies live updates, then dismisses and checks the grid cells.
    func testCollectionRootDecoratorUpdatesRowFormAndGrid() {
        typealias S = DecoratorUITestSupport

        S.openCollectionDetailView(in: app)
        S.openCollectionRootRowEditForm(rowIndex: 1, in: app)

        // Text → "Updated #1"
        tapDecoratorAndAssertTextField(action: collRootTextAction, identifier: "EditRowsTextFieldIdentifier", expected: "Updated #1")
        // Dropdown → "High" (first option)
        tapDecoratorAndAssertStaticText(action: collRootDropdownAction, expected: "High")
        // Image → container exists
        tapDecoratorAndAssertExists(action: collRootImageAction, identifier: "EditRowsImageFieldIdentifier")

        dismissSheet()

        assertGridTextView(identifier: "TabelTextFieldIdentifier", expected: "Updated #1")
        assertGridButtonContains(identifier: "TableDropdownIdentifier", text: "High")
    }

    // MARK: - Collection level 1

    /// Expands root row 1, opens L1 row 1's edit form, taps all 3 decorators
    /// (multiSelect, number, date), verifies live updates, then dismisses and checks the grid.
    func testCollectionLevel1DecoratorUpdatesRowFormAndGrid() {
        typealias S = DecoratorUITestSupport

        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 0, in: app)

        // MultiSelect → "Option 1"
        tapDecoratorAndAssertStaticText(action: collL1MultiSelectAction, expected: "Option 1")
        // Number → "10"
        tapDecoratorAndAssertTextField(action: collL1NumberAction, identifier: "TabelNumberFieldIdentifier", expected: "10")
        // Date → inner button has a non-empty label
        tapDecoratorAndAssertButtonHasValue(action: collL1DateAction, identifier: "ChangeCellDateIdentifier")

        dismissSheet()

        assertGridButtonContains(identifier: "TableMultiSelectionFieldIdentifier", text: "Option 1")
        assertGridTextField(identifier: "TabelNumberFieldIdentifier", expected: "10")
        assertGridButtonHasValue(identifier: "ChangeCellDateIdentifier")
    }

    // MARK: - Collection level 2

    /// Expands root row 1 → L1 row 1, opens L2 row 1's edit form, taps all 3 decorators
    /// (signature, barcode, block), verifies live updates, then dismisses and checks the grid.
    func testCollectionLevel2DecoratorUpdatesRowFormAndGrid() {
        typealias S = DecoratorUITestSupport

        S.openCollectionDetailView(in: app)
        S.expandCollectionRootRow(at: 1, in: app)
        S.expandCollectionNestedRow(at: 1, in: app)
        // L2 row shares "SingleClickEditNestedButton1" with L1; boundBy:1 picks L2
        S.openCollectionNestedRowEditForm(rowIndex: 1, boundBy: 1, in: app)

        // Signature → container renders after URL is set
        tapDecoratorAndAssertExists(action: collL2SignatureAction, identifier: "EditRowsSignatureFieldIdentifier")
        // Barcode → "Updated #1" (TextEditor, identifier "TableBarcodeFieldIdentifier")
        tapDecoratorAndAssertTextView(action: collL2BarcodeAction, identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
        // Block → display-only, no row-form editor
        tapDecoratorDisplayOnly(action: collL2BlockAction)

        dismissSheet()

        assertGridButtonExists(identifier: "TableSignatureOpenSheetButton")
        assertGridTextView(identifier: "TableBarcodeFieldIdentifier", expected: "Updated #1")
    }

    // MARK: - Row-form tap + assert helpers

    /// Taps decorator, waits for a SwiftUI TextField (→ .textField) to show expected value.
    /// Used for: text column (EditRowsTextFieldIdentifier), number (TabelNumberFieldIdentifier).
    private func tapDecoratorAndAssertTextField(action: String, identifier: String, expected: String) {
        tapDecorator(action: action)
        let field = app.textFields.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { field.exists && field.value as? String == expected },
            "'\(identifier)' should show '\(expected)' after tapping '\(action)' decorator"
        )
    }

    /// Taps decorator, waits for a SwiftUI TextEditor (→ .textView) to show expected value.
    /// Used for: barcode column (TableBarcodeFieldIdentifier).
    private func tapDecoratorAndAssertTextView(action: String, identifier: String, expected: String) {
        tapDecorator(action: action)
        let field = app.textViews.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { field.exists && field.value as? String == expected },
            "'\(identifier)' should show '\(expected)' after tapping '\(action)' decorator"
        )
    }

    /// Taps decorator, waits for a static text with the given label to appear.
    /// Used for: dropdown and multiSelect (selected option value is rendered as Text).
    private func tapDecoratorAndAssertStaticText(action: String, expected: String) {
        tapDecorator(action: action)
        XCTAssertTrue(
            waitUntil(3) { self.app.staticTexts[expected].exists },
            "'\(expected)' should appear as static text after tapping '\(action)' decorator"
        )
    }

    /// Taps decorator, waits for a button with the given identifier to have a non-empty label.
    /// Used for: date column (ChangeCellDateIdentifier shows the formatted date).
    private func tapDecoratorAndAssertButtonHasValue(action: String, identifier: String) {
        tapDecorator(action: action)
        let button = app.buttons.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { button.exists && !button.label.isEmpty },
            "'\(identifier)' button should have a value after tapping '\(action)' decorator"
        )
    }

    /// Taps decorator, waits for any element with the given identifier to exist.
    /// Used for: image and signature containers that render once a value is present.
    private func tapDecoratorAndAssertExists(action: String, identifier: String) {
        tapDecorator(action: action)
        let element = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { element.exists },
            "'\(identifier)' should exist after tapping '\(action)' decorator"
        )
    }

    /// Taps a display-only column decorator (e.g. block) and waits for the
    /// async Change API round-trip to complete before the next assertion.
    private func tapDecoratorDisplayOnly(action: String) {
        tapDecorator(action: action)
        spinRunloop(1.5)
    }

    // MARK: - Row-form assert helpers (no decorator tap — used after add/insert row)

    private func assertRowFormTextField(identifier: String, expected: String) {
        let field = app.textFields.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { field.exists && field.value as? String == expected },
            "Row form '\(identifier)' should show '\(expected)'"
        )
    }

    private func assertRowFormTextView(identifier: String, expected: String) {
        let field = app.textViews.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { field.exists && field.value as? String == expected },
            "Row form '\(identifier)' should show '\(expected)'"
        )
    }

    private func assertRowFormStaticText(_ expected: String) {
        XCTAssertTrue(
            waitUntil(3) { self.app.staticTexts[expected].exists },
            "Row form should show '\(expected)' as static text"
        )
    }

    private func assertRowFormButtonHasValue(identifier: String) {
        let btn = app.buttons.matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { btn.exists && !btn.label.isEmpty },
            "Row form '\(identifier)' button should have a non-empty value"
        )
    }

    private func assertRowFormExists(identifier: String) {
        let el = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        XCTAssertTrue(
            waitUntil(3) { el.exists },
            "Row form '\(identifier)' should exist"
        )
    }

    // MARK: - Grid cell assert helpers

    /// Grid text cell (UITextView wrapper, identifier "TabelTextFieldIdentifier").
    private func assertGridTextView(identifier: String, expected: String) {
        let cell = app.textViews.matching(identifier: identifier).element(boundBy: 0)
        XCTAssertTrue(
            waitUntil(2) { cell.exists && cell.value as? String == expected },
            "Grid '\(identifier)'[0] should show '\(expected)'"
        )
    }

    /// Grid number/text cell backed by a SwiftUI TextField (identifier "TabelNumberFieldIdentifier").
    private func assertGridTextField(identifier: String, expected: String) {
        let cell = app.textFields.matching(identifier: identifier).element(boundBy: 0)
        XCTAssertTrue(
            waitUntil(2) { cell.exists && cell.value as? String == expected },
            "Grid '\(identifier)'[0] should show '\(expected)'"
        )
    }

    /// Grid dropdown / multiSelect button whose label contains the selected option.
    private func assertGridButtonContains(identifier: String, text: String) {
        let cell = app.buttons.matching(identifier: identifier).element(boundBy: 0)
        XCTAssertTrue(
            waitUntil(2) { cell.exists && cell.label.contains(text) },
            "Grid '\(identifier)'[0] label should contain '\(text)'"
        )
    }

    /// Grid date button: just verifies a formatted date is displayed (non-empty label).
    private func assertGridButtonHasValue(identifier: String) {
        let cell = app.buttons.matching(identifier: identifier).element(boundBy: 0)
        XCTAssertTrue(
            waitUntil(2) { cell.exists && !cell.label.isEmpty },
            "Grid '\(identifier)'[0] should have a non-empty value"
        )
    }

    /// Grid cell that exists as a tappable button once any value is set (e.g. signature).
    private func assertGridButtonExists(identifier: String) {
        let cell = app.buttons.matching(identifier: identifier).element(boundBy: 0)
        XCTAssertTrue(
            cell.waitForExistence(timeout: 2),
            "Grid '\(identifier)'[0] should exist"
        )
    }
    
    private func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }



    // MARK: - Decorator tap helper

    /// Taps a cell decorator button inside the open row form.
    /// Scrolls up once if the button isn't immediately visible.
    private func tapDecorator(action: String) {
        typealias S = DecoratorUITestSupport
        let button = app.buttons[S.fieldDecoratorID(action: action)]
        if !button.waitForExistence(timeout: 1) {
            app.swipeUp()
            _ = button.waitForExistence(timeout: 2)
        }
        if button.exists {
            button.tap()
        } else {
            XCTFail("Decorator button '\(action)' not found in row form")
        }
    }
}
