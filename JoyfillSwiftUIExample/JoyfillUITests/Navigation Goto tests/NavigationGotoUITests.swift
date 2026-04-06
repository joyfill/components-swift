import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class NavigationGotoUITests: JoyfillUITestsBaseClass {

    /// Verifies goto navigation between collection rows with different schemas and across two different row forms.
    /// Flow: submit triggers validation → Up opens collection row form → Up navigates between rows → Up moves to standalone table field.
    func testGotoCollectionAndNavigateBetweenSchemasAndAcrossTwoDifferentRowForms() throws {
        // 1. Tap Submit → triggers validation, shows validation bar
        let submitButton = app.buttons["SubmitValidateButtonIdentifier"]
        submitButton.tap()

        // 2. Verify validation bar appeared with Up button
        let upButton = app.buttons["UpperNavigationIdentifier"].firstMatch
        // 3. Tap Up → goto fires with open: true, navigates into collection and opens row form sheet
        upButton.tap()

        // 4. Verify the collection row form sheet is open (no crash)
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

        upButton.tap()
        XCTAssertTrue(app.staticTexts["second page table"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["1 row selected"].exists)

    }
}
