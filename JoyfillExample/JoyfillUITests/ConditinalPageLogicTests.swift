import XCTest
import JoyfillModel

final class ConditionalPageLogicTests: JoyfillUITestsBaseClass {
    func testEqualConditionOnPages() throws {
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
        alwaysShowTextField.typeText("Page Hide when condition is true\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        
        let conditionPage = pageSheetSelectionButton.element(boundBy: 2)
        conditionPage.tap()
        
        let conditionPageTextField = app.textFields["Text"]
        conditionPageTextField.tap()
        conditionPageTextField.typeText("Hello\n")
        
        let conditionPageTextFieldTitle = "Page 5 Text Field - Type Hello"
        let conditionPageLabel = app.staticTexts[conditionPageTextFieldTitle]
        XCTAssertTrue(conditionPageLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        
        let fourthPageShowOnCondition = pageSheetSelectionButton.element(boundBy: 1)
        fourthPageShowOnCondition.tap()
        
        let fourthPageTextField = app.textFields["Text"]
        fourthPageTextField.tap()
        fourthPageTextField.typeText("Page show when condition is true\n")
        
        let fourthPageTextFieldTitle = "Page 4 Text Field - Show when condition is true"
        let fourthPageLabel = app.staticTexts[fourthPageTextFieldTitle]
        XCTAssertTrue(fourthPageLabel.exists, "The title label does not exist or does not have the correct title.")
        
        pageSelectionButton.tap()
        
        let navigateToFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        navigateToFirstPage.tap()
    }
}
