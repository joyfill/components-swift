import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class NavigationGotoUITests: JoyfillUITestsBaseClass {

    //Verifies no crash when goto navigates between collection rows with different schemas"
    func testGotoCollectionAndNavigateBetweenSchemas() throws {
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
       

        // After second Up tap — root schema, has barcode
        XCTAssertFalse(app.staticTexts["Text Column"].exists)
        
        upButton.tap()
        
        XCTAssertTrue(app.staticTexts["Text Column"].exists)

    }
}
