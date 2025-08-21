import XCTest
import JoyfillModel

final class ConditionalPageLogicTests: JoyfillUITestsBaseClass {
    func testEqualConditionOnPages() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 1)
        tapOnSecondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Page 2 ( Page hide when condition is true)
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Page Hide when condition is true\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        pageSelectionButton.tap()
        
        // Page 5 (Condition Page)
        let tapOnConditionPage = pageSheetSelectionButton.element(boundBy: 2)
        tapOnConditionPage.tap()
        
        let conditionPageTextField = textFields[0]
        conditionPageTextField.tap()
        conditionPageTextField.typeText("Hello\n")
        
        let conditionPageTextFieldTitle = "Page 5 Text Field - Type Hello"
        let conditionPageLabel = app.staticTexts[conditionPageTextFieldTitle]
        XCTAssertTrue(conditionPageLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // check field is hidden or not - simle hidden field
        let checkTitleField = textFields[2]
        XCTAssertFalse(checkTitleField.exists, "The second field that should be hidden is visible.")
        
        pageSelectionButton.tap()
        
        // Page 4 (Page show when condition is true)
        let fourthPageShowOnCondition = pageSheetSelectionButton.element(boundBy: 1)
        fourthPageShowOnCondition.tap()
        
        let fourthPageTextField = app.textFields["Text"]
        fourthPageTextField.tap()
        fourthPageTextField.typeText("Page show when condition is true\n")
        
        let fourthPageTextFieldTitle = "Page 4 Text Field - Show when condition is true"
        let fourthPageLabel = app.staticTexts[fourthPageTextFieldTitle]
        XCTAssertTrue(fourthPageLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        tapOnConditionPage.tap()
        
        conditionPageTextField.tap()
        conditionPageTextField.typeText(" Sir\n")
        XCTAssertTrue(conditionPageLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        tapOnSecondPage.tap()
        
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        
        let navigateToFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        navigateToFirstPage.tap()
    }
}
