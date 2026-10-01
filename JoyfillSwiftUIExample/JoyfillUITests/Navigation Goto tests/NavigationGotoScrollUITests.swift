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
    private let collectionLastRowIndex = 37

    // Navigation.json table (page / fieldPosition) and its 38th row (40 rows baked in).
    private let tablePageId = "69709dc281b4c8ab68c4db52"
    private let tableFieldPositionId = "69709462236416126c166efe"
    private let tableLastRowId = "6abe25bc78732758a2bc9115"
    private let tableLastRowNumber = 38

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
        XCTAssertTrue(waitUntil(5) { selectedRowCell.exists},
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
        XCTAssertTrue(waitUntil(5) { selectedRowNumber.exists },
                      "Table did not scroll down to the selected row after goto")
    }

}
