import XCTest
import JoyfillModel

final class PageNavigationFieldTests: JoyfillUITestsBaseClass {
    
    func testPageNavigation() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        let firstTextField = textFields[0]
        XCTAssertTrue(firstTextField.exists, "The third text field does not exist.")
        XCTAssertEqual("", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
    }
    
    func testPageDuplicate() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 2)
        originalPageButton.tap()
        
        let originalTextFields = app.textFields.allElementsBoundByIndex
        let origFirstTextField = originalTextFields[0]
        XCTAssertTrue(origFirstTextField.exists, "The first text field does not exist on the original page.")
        XCTAssertEqual("", origFirstTextField.value as! String, "Original text field should start empty.")
        
        origFirstTextField.tap()
        origFirstTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!, "Original page text field should contain 'Hello'.")
        
        pageSelectionButton.tap()
        let pageDuplicateButton = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let duplicatePageButton = pageDuplicateButton.element(boundBy: 2)
        duplicatePageButton.tap()
        
        let duplicatedPageButton = pageSheetSelectionButton.element(boundBy: 3)
        duplicatedPageButton.tap()
        
        let duplicatedTextFields = app.textFields.allElementsBoundByIndex
        let dupFirstTextField = duplicatedTextFields[0]
        XCTAssertTrue(dupFirstTextField.exists, "The first text field does not exist on the duplicated page.")
        XCTAssertEqual("Hello", dupFirstTextField.value as! String, "Duplicated page should initially display the same text as original.")
        
        dupFirstTextField.tap()
        dupFirstTextField.typeText(" Sir, duplicate\n")
        XCTAssertEqual("Hello Sir, duplicate", onChangeResultValue().text!, "Duplicated page text field should update to 'Hello Sir, duplicate'.")
        
        let dupSecondTextField = duplicatedTextFields[1]
        XCTAssertTrue(dupSecondTextField.exists, "The second text field does not exist on the duplicated page.")
        XCTAssertEqual("", dupSecondTextField.value as! String, "Duplicated page second field should start empty.")
        dupSecondTextField.tap()
        dupSecondTextField.typeText("The quick brown fox jumps over the lazy dog.\n")
        XCTAssertEqual("The quick brown fox jumps over the lazy dog.", onChangeResultValue().text!, "Duplicated page second field should have the new value.")
        
        pageSelectionButton.tap()
        originalPageButton.tap()
        
        let origTextFieldsAfterDuplicate = app.textFields.allElementsBoundByIndex
        let origFirstTextFieldAfter = origTextFieldsAfterDuplicate[0]
        XCTAssertTrue(origFirstTextFieldAfter.exists, "The first text field does not exist on the original page after duplication.")
        XCTAssertEqual("Hello", origFirstTextFieldAfter.value as! String, "Original page text field should remain 'Hello' after duplication.")
        
        let origSecondTextFieldAfter = origTextFieldsAfterDuplicate[1]
        XCTAssertTrue(origSecondTextFieldAfter.exists, "The second text field does not exist on the original page after duplication.")
        XCTAssertEqual("", origSecondTextFieldAfter.value as! String, "Original page second field should remain unchanged.")
    }
    
    func testDuplicatedPageConditionalLogic() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageDuplicateButton = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let duplicatePageButton = pageDuplicateButton.element(boundBy: 1)
        duplicatePageButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 2)
        originalPageButton.tap()
        
        let originalTextFields = app.textFields.allElementsBoundByIndex
       
        let hideFieldOnConditionTrueTextField = originalTextFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        XCTAssertEqual("Field is Hide when condition true", onChangeResultValue().text!)
        
        let hideFieldTitle = "Field Hide When Condition True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        let applyIsEqualConditionTextField = originalTextFields[2]
        XCTAssertTrue(applyIsEqualConditionTextField.exists, "The applyIsEqualCondition text field does not exist.")
        applyIsEqualConditionTextField.tap()
        applyIsEqualConditionTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        let applyConditionTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let applyConditionTextFieldLabel = app.staticTexts[applyConditionTextFieldTitle]
        XCTAssertTrue(applyConditionTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        let showFieldOnConditionTrueTextField = originalTextFields[1]
        XCTAssertTrue(showFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrueTextField.tap()
        showFieldOnConditionTrueTextField.typeText("Field is show when condition true\n")
        XCTAssertEqual("Field is show when condition true", onChangeResultValue().text!)
        
        let showFieldTitle = "Field Show When Condition True"
        let showFieldLabel = app.staticTexts[showFieldTitle]
        XCTAssertTrue(showFieldLabel.exists, "The title label does not exist or does not have the correct title.")
    }
}
