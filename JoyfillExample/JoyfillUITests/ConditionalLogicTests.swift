import XCTest
import JoyfillModel

final class ConditionalLogicTests: JoyfillUITestsBaseClass {
    func testEqualConditionOnTextField() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Always Show TextField
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Always Show\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is Hide when condition true
        let hideFieldOnConditionTrueTextField = textFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        
        let hideFieldTitle = "Field Hide When Condition True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Type Hello (Equal Condition Text Field)
        let applyIsEqualConditionTextField = textFields[2]
        XCTAssertTrue(applyIsEqualConditionTextField.exists, "The applyIsEqualCondition text field does not exist.")
        applyIsEqualConditionTextField.tap()
        applyIsEqualConditionTextField.typeText("Hello\n")
        
        let applyConditionTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let applyConditionTextFieldLabel = app.staticTexts[applyConditionTextFieldTitle]
        XCTAssertTrue(applyConditionTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
        pageSelectionButton.tap()
        secondPage.tap()
        
        // Field is show when condition true
        let showFieldOnConditionTrueTextField = textFields[1]
        XCTAssertTrue(showFieldOnConditionTrueTextField.exists, "The showFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrueTextField.tap()
        showFieldOnConditionTrueTextField.typeText("Field is show when condition true\n")
        
        let showFieldTextFieldTitle = "Field Show When Condition True"
        let showFieldTextFieldLabel = app.staticTexts[showFieldTextFieldTitle]
        XCTAssertTrue(showFieldTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Type Sir To False Condition (Equal Condition Text Field 2nd Time)
        let applyIsEqualConditionTextField2ndTime = textFields[2]
        XCTAssertTrue(applyIsEqualConditionTextField2ndTime.exists, "The applyIsEqualCondition text field does not exist.")
        applyIsEqualConditionTextField2ndTime.tap()
        applyIsEqualConditionTextField2ndTime.typeText(" Sir\n")
    }
}


