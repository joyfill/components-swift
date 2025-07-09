//
//  SingleChoiceFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 09/07/25.
//



import XCTest
import JoyfillModel

final class SingleChoiceFieldUITestCases: JoyfillUITestsBaseClass {
     
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "SingleChoiceFieldTestData"
    }
    
    func onChangeResult() -> XCUIElement {
        // Placeholder for accessing the onChange result element, adjust as needed for your app
        return app.otherElements["onChangeResult"]
    }

    func testSelectYesOption() {
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        field.tap()
        XCTAssertEqual(field.label, "Yes")
        let value = onChangeResult().dictionary["change"] as? [String: Any]
        XCTAssertEqual(value?["value"] as? [String], ["686de9badfd75c7b17b254aa"])
    }

    func testSelectNoOption() {
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        field.tap()
        XCTAssertEqual(field.label, "No")
        let value = onChangeResult().dictionary["change"] as? [String: Any]
        XCTAssertEqual(value?["value"] as? [String], ["686de9ba20dae4339fa96e21"])
    }

    func testSelectNAOption() {
        let naButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        naButton.tap()
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        field.tap()
        XCTAssertEqual(field.label, "N/A")
        let value = onChangeResult().dictionary["change"] as? [String: Any]
        XCTAssertEqual(value?["value"] as? [String], ["686de9ba934f8e89c6ee45d4"])
    }

    func testYesOptionShowsCorrectBlock() {
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        field.tap()
        XCTAssertTrue(app.staticTexts["Checkbox is true"].exists)
        XCTAssertFalse(app.staticTexts["Checkbox is false"].exists)
        XCTAssertFalse(app.staticTexts["N/A selected in single choice"].exists)
    }

    func testNoOptionShowsCorrectBlock() {
        let naButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        naButton.tap()
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        field.tap()
        XCTAssertTrue(app.staticTexts["Checkbox is false"].exists)
        XCTAssertFalse(app.staticTexts["Checkbox is true"].exists)
        XCTAssertFalse(app.staticTexts["N/A selected in single choice"].exists)
    }

    func testNAOptionShowsCorrectBlock() {
        let naButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        naButton.tap()
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        field.tap()
        XCTAssertTrue(app.staticTexts["N/A selected in single choice"].exists)
        XCTAssertFalse(app.staticTexts["Checkbox is true"].exists)
        XCTAssertFalse(app.staticTexts["Checkbox is false"].exists)
    }

    func testSwitchBetweenOptions() {
        let yesButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        let noButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        let naButton = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)

        yesButton.tap()
        XCTAssertEqual(yesButton.label, "Yes")

        noButton.tap()
        XCTAssertEqual(noButton.label, "No")

        naButton.tap()
        XCTAssertEqual(naButton.label, "N/A")
    }

    func testInitialSelectedOption() {
        let field = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        XCTAssertEqual(field.label, "N/A")
        XCTAssertTrue(app.staticTexts["N/A selected in single choice"].exists)
    }

    func testOnlyOneOptionCanBeSelected() {
        let yesField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        yesField.tap()
        let noField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        noField.tap()
        XCTAssertEqual(noField.label, "No")
    }

    func testSelectionPersistenceAfterScrollOrNavigation() {
        let yesField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        yesField.tap()
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(yesField.label, "Yes")
    }

    func testRapidMultipleSelections() {
        let yesField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 0)
        let noField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 1)
        let naField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)

        yesField.tap()
        noField.tap()
        naField.tap()
        XCTAssertEqual(naField.label, "N/A")
    }

    func testFieldInteractionWithoutSelection() {
        let naField = app.buttons.matching(identifier: "SingleSelectionIdentifier").element(boundBy: 2)
        XCTAssertEqual(naField.label, "N/A", "Default selected option should be 'N/A'")
        XCTAssertTrue(app.staticTexts["N/A selected in single choice"].exists, "Corresponding block for N/A should be visible")
    }
}
