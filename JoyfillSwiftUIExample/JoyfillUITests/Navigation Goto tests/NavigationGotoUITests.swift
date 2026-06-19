import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class NavigationGotoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        //app.launchArguments = ["--disable-animations"]
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for label in ["Allow", "OK", "Continue", "Don't Allow"] {
                if alert.buttons[label].exists { alert.buttons[label].tap(); return true }
            }
            return false
        }
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch")

        // Navigate from OptionSelectionView → FooterExampleView
        let card = app.staticTexts["Footer Example"]
        if !card.waitForExistence(timeout: 5) {
            app.swipeUp()
            _ = card.waitForExistence(timeout: 3)
        }
        XCTAssertTrue(card.exists, "Footer Example card not found in OptionSelectionView")
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

    func testGotoCollectionAndNavigateBetweenSchemas() throws {
        
        let submitButton = app.buttons["SubmitValidateButtonIdentifier"]
        submitButton.tap()

        let upButton = app.buttons["UpperNavigationIdentifier"].firstMatch

        upButton.tap()
        XCTAssertTrue(app.textFields["Number"].waitForExistence(timeout: 5),
                      "Number field should be visible after first Up navigation")
        
        upButton.tap()
        let dismissButton = app.buttons.matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5),
                      "Row form sheet should open after goto navigates into the collection")
        
        XCTAssertTrue(app.staticTexts["Child table"].exists)
        let childElements = app.staticTexts.matching(NSPredicate(format: "label == %@", "Child table"))
        XCTAssertEqual(childElements.count, 2)
        XCTAssertTrue(app.staticTexts["Parent table"].exists)
        let parentElements = app.staticTexts.matching(NSPredicate(format: "label == %@", "Parent table"))
        XCTAssertEqual(parentElements.count, 1)
        
        upButton.tap()
        XCTAssertTrue(app.staticTexts["Child table"].waitForExistence(timeout: 5))
        let childElementsAfterFirstUp = app.staticTexts.matching(NSPredicate(format: "label == %@", "Child table"))
        XCTAssertEqual(childElementsAfterFirstUp.count, 1)
        let parentElementsAfterFirstUp = app.staticTexts.matching(NSPredicate(format: "label == %@", "Parent table"))
        XCTAssertEqual(parentElementsAfterFirstUp.count, 2)

    }

    /// Verifies goto navigation between collection rows with different schemas and across two different row forms.
    /// Flow: submit triggers validation → Up opens collection row form → Up navigates between rows → Up moves to standalone table field.
    func testGotoCollectionAndNavigateBetweenSchemasAndAcrossTwoDifferentRowForms() throws {
        let submitButton = app.buttons["SubmitValidateButtonIdentifier"]
        submitButton.tap()

        let upButton = app.buttons["UpperNavigationIdentifier"].firstMatch
        upButton.tap()
        XCTAssertTrue(app.textFields["Number"].waitForExistence(timeout: 5),
                      "Number field should be visible after first Up navigation")

        upButton.tap()
        let dismissButton = app.buttons.matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5),
                      "Row form sheet should open after goto navigates into the collection")

        XCTAssertTrue(app.staticTexts["Child table"].exists)
        let childElements = app.staticTexts.matching(NSPredicate(format: "label == %@", "Child table"))
        XCTAssertEqual(childElements.count, 2)
        XCTAssertTrue(app.staticTexts["Parent table"].exists)
        let parentElements = app.staticTexts.matching(NSPredicate(format: "label == %@", "Parent table"))
        XCTAssertEqual(parentElements.count, 1)

        upButton.tap()
        upButton.tap()
        let tableRowDismissButton = app.buttons.matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").firstMatch
        XCTAssertTrue(tableRowDismissButton.waitForExistence(timeout: 5),
                      "Table row form sheet should open after goto navigates into the table field")
        XCTAssertFalse(app.staticTexts["Child table"].exists,
                       "Collection row form should be fully dismissed")
        XCTAssertFalse(app.staticTexts["Parent table"].exists,
                       "Collection row form should be fully dismissed")
        XCTAssertTrue(app.staticTexts["1 row selected"].exists)

    }
}
