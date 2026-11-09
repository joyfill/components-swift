import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

// Verifies a `goto` into a far-down collection row auto-scrolls the grid to that row (NO-2336 regression guard).
final class NavigationGotoScrollUITests: XCTestCase {

    var app: XCUIApplication!

    // Navigation.json collection (page / fieldPosition) and its 38th row (40 rows baked in).
    private let collectionPageId = "69709dc281b4c8ab68c4db52"
    private let collectionFieldPositionId = "6970a3eceab9374076e43a0b"
    private let collectionLastRowId = "6abe2602448499a6a5483012"
    private let collectionLastRowIndex = 38

    // Navigation.json table (page / fieldPosition) and its 38th row (40 rows baked in).
    private let tablePageId = "69709dc281b4c8ab68c4db52"
    private let tableFieldPositionId = "69709462236416126c166efe"
    private let tableLastRowId = "6abe25bc78732758a2bc9115"
    private let tableLastRowNumber = 38
    // Unique value seeded into the far-down row's first (text) column so its grid cell is queryable for alignment.
    private let tableLastRowMarker = "AlignCheck38"

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Collection has 40 rows baked into Navigation.json so the far row (index 39) exists.
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for label in ["Allow", "OK", "Continue", "Don't Allow"] {
                if alert.buttons[label].exists { alert.buttons[label].tap(); return true }
            }
            return false
        }
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch")

        // Navigate from OptionSelectionView → Navigation Test (SimpleNavigationTestView).
        let card = app.staticTexts["Navigation Test"]
        if !card.waitForExistence(timeout: 5) {
            app.swipeUp()
            _ = card.waitForExistence(timeout: 3)
        }
        XCTAssertTrue(card.exists, "Navigation Test card not found in OptionSelectionView")
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

    func testGotoScrollsCollectionToSelectedRow() throws {
        let pathField = app.textFields["NavigationManualPathField"]
        XCTAssertTrue(pathField.waitForExistence(timeout: 5),
                      "Manual path field not found on Navigation Test screen")

        pathField.tap()
        pathField.typeText("\(collectionPageId)/\(collectionFieldPositionId)/\(collectionLastRowId)")

        app.dismissKeyboardIfVisible()
        app.buttons["NavigationManualPathGoButton"].tap()
        //app.buttons["NavigationManualPathGoButton"].tap()
        let dismissButton = app.buttons
            .matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 8),
                      "Row form sheet should open after goto navigates into the collection")
        dismissButton.tap()

        let selectedRowCell = app.images["selectRowItem\(collectionLastRowIndex)"]
        XCTAssertTrue(waitUntil(5) { selectedRowCell.exists && selectedRowCell.isHittable },
                      "Collection did not scroll down to the selected row after goto")
    }

    func testGotoScrollsTableToSelectedRow() throws {
        let pathField = app.textFields["NavigationManualPathField"]
        XCTAssertTrue(pathField.waitForExistence(timeout: 5),
                      "Manual path field not found on Navigation Test screen")

        pathField.tap()
        pathField.typeText("\(tablePageId)/\(tableFieldPositionId)/\(tableLastRowId)")

        app.dismissKeyboardIfVisible()
        app.buttons["NavigationManualPathGoButton"].tap()
        let dismissButton = app.buttons
            .matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 8),
                      "Row form sheet should open after goto navigates into the table")
        dismissButton.tap()

        // Table rows have no per-row identifier; the row-number column shows index+1 as a staticText.
        let selectedRowNumber = app.staticTexts["\(tableLastRowNumber)"]
        XCTAssertTrue(waitUntil(5) { selectedRowNumber.exists && selectedRowNumber.isHittable },
                      "Table did not scroll down to the selected row after goto")
    }

    // Guards the left row-number column against drifting out of sync with the grid after a goto (the late-capture race),
    // on both the first modal appearance and after the modal is dismissed and re-opened (re-runs scroll + capture).
    func testGotoKeepsTableRowNumberAlignedWithGridRow() throws {
        // First appearance.
        gotoTableLastRowAndDismissForm()
        assertRowNumberAlignedWithGridCell()

        // Pop the table modal, then navigate into the same row again so the modal reappears and re-scrolls.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let pathField = app.textFields["NavigationManualPathField"]
        XCTAssertTrue(pathField.waitForExistence(timeout: 5),
                      "Manual path field not found after dismissing the modal")

        // Reappearance.
        gotoTableLastRowAndDismissForm()
        assertRowNumberAlignedWithGridCell()
    }

    // MARK: - Helpers

    // Navigates via goto into the far-down table row and dismisses the row form it opens.
    private func gotoTableLastRowAndDismissForm(file: StaticString = #file, line: UInt = #line) {
        let pathField = app.textFields["NavigationManualPathField"]
        XCTAssertTrue(pathField.waitForExistence(timeout: 5),
                      "Manual path field not found on Navigation Test screen", file: file, line: line)

        pathField.tap()
        // Clear any text left from a previous goto so the path isn't concatenated.
        if let current = pathField.value as? String, !current.isEmpty {
            pathField.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
        }
        pathField.typeText("\(tablePageId)/\(tableFieldPositionId)/\(tableLastRowId)")

        app.dismissKeyboardIfVisible()
        app.buttons["NavigationManualPathGoButton"].tap()
        let dismissButton = app.buttons
            .matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 8),
                      "Row form sheet should open after goto navigates into the table", file: file, line: line)
        dismissButton.tap()
    }

    // The left-column number and the selected row's grid cell (seeded with a unique value) must share a vertical center.
    private func assertRowNumberAlignedWithGridCell(file: StaticString = #file, line: UInt = #line) {
        let selectedRowNumber = app.staticTexts["\(tableLastRowNumber)"]
        XCTAssertTrue(waitUntil(5) { selectedRowNumber.exists && selectedRowNumber.isHittable },
                      "Table did not scroll down to the selected row after goto", file: file, line: line)

        let gridRowCell = app.textViews.matching(NSPredicate(format: "value == %@", tableLastRowMarker)).firstMatch
        XCTAssertTrue(waitUntil(5) { gridRowCell.exists },
                      "Grid cell for the selected row not found", file: file, line: line)

        // One row is 60pt tall; any real misalignment lands a full row (>=60pt) away, so 20pt is a safe threshold.
        let delta = abs(selectedRowNumber.frame.midY - gridRowCell.frame.midY)
        XCTAssertLessThan(delta, 20,
                          "Row number and grid row are vertically misaligned by \(delta)pt", file: file, line: line)
    }

}
