import XCTest
import JoyfillModel

final class SelectionFieldPageLogicTests: JoyfillUITestsBaseClass {
    
    // Hide Page 7 on "No" opiton selected
    func testHidePageOnDropdownFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSixthPage = pageSheetSelectionButton.element(boundBy: 3)
        tapOnSixthPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Select "No" option ( Condition Field )
        let dropdownButton = app.buttons["Dropdown"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        let tapOnOption = dropdownOptions.element(boundBy: 1)
        tapOnOption.tap()
        XCTAssertEqual("66a0fd2b8a5085b2eaa4bb29", onChangeResultValue().text!)
        
        let conditionFieldTitle = "Condition Dropdown Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 7 & 8 Is hidden or not by show in page list )
        pageSelectionButton.tap()
        
        // assert for check page is hidden
        let page7Title = app.staticTexts["Page 7 - Single Choice X code test case"]
        XCTAssertFalse(page7Title.exists, "Page 7 should not exist.")
        
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page Six to unselect the dropdown option
        pageSelectionButton.tap()
        tapOnSixthPage.tap()
        
        // Click dropdown option for unselect the option
        dropdownButton.tap()
        let dropdownOption = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        let unselectOption = dropdownOption.element(boundBy: 1)
        unselectOption.tap()
        XCTAssertEqual("", onChangeResultValue().text!)
        
        // Navigate to Page 7
        pageSelectionButton.tap()
        XCTAssertTrue(page7Title.exists, "Page 7 should exist.")
        
        let tapOnSeventhPage = pageSheetSelectionButton.element(boundBy: 4)
        tapOnSeventhPage.tap()
        
        // Page 7 Always Show TextField
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Page is Show\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
    
    func testHidePageOnSinlgeChoiceFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSeventhPage = pageSheetSelectionButton.element(boundBy: 4)
        tapOnSeventhPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        
        // Select "No" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 1).tap()
        XCTAssertEqual("66a1e2e9ed6de57065b6cede", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Single Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 8 Is hidden or not by show in page list )
        pageSelectionButton.tap()
        
        // assert for check page is hidden
        let page8Title = app.staticTexts["Page 8 - Multiselect X code test case"]
        XCTAssertFalse(page8Title.exists, "Page 8 should not exist.")
        
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page Seven to unselect the dropdown option
        pageSelectionButton.tap()
        tapOnSeventhPage.tap()
        
        // Click dropdown option for unselect the option
        selectYesOption.element(boundBy: 1).tap()
        
        // Navigate to Page 8
        pageSelectionButton.tap()
        let tapOnEighthPage = pageSheetSelectionButton.element(boundBy: 5)
        tapOnEighthPage.tap()
        
        // Page 8 Always Show TextField
        let page8AlwaysShowTextField = textFields[0]
        XCTAssertTrue(page8AlwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        page8AlwaysShowTextField.tap()
        page8AlwaysShowTextField.typeText("Page is show\n")
        
        let page8AlwaysShowTextFieldTitle = "Always Show Field"
        let page8AlwaysShowTextFieldTitleLabel = app.staticTexts[page8AlwaysShowTextFieldTitle]
        XCTAssertTrue(page8AlwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
    
    func testHidePageOnMultiChoiceFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnEightPage = pageSheetSelectionButton.element(boundBy: 5)
        tapOnEightPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        
        // Select "No" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 1).tap()
        XCTAssertEqual("66a1e2e9688109457faf7d9b", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Multiple Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 8 Is hidden or not by show in page list )
        pageSelectionButton.tap()
        
        // assert for check page is hidden
        let page6Title = app.staticTexts["Page 6 - Dropdown X Code test case"]
        XCTAssertFalse(page6Title.exists, "Page 8 should not exist.")
        
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page Eight to unselect the dropdown option
        pageSelectionButton.tap()
        let againTapOnEightPage = pageSheetSelectionButton.element(boundBy: 4)
        againTapOnEightPage.tap()
        
        // Click dropdown option for unselect the option
        selectYesOption.element(boundBy: 1).tap()
//        XCTAssertEqual("", onChangeResultValue().multiSelector?.first!)
        
        // Navigate to Page 8
        pageSelectionButton.tap()
        let tapOnSixthPage = pageSheetSelectionButton.element(boundBy: 3)
        tapOnSixthPage.tap()
        
        // Page 8 Always Show TextField
        let page6AlwaysShowTextField = textFields[0]
        XCTAssertTrue(page6AlwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        page6AlwaysShowTextField.tap()
        page6AlwaysShowTextField.typeText("Page is show\n")
        
        let page6AlwaysShowTextFieldTitle = "Always Show Field"
        let page6AlwaysShowTextFieldTitleLabel = app.staticTexts[page6AlwaysShowTextFieldTitle]
        XCTAssertTrue(page6AlwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
}


