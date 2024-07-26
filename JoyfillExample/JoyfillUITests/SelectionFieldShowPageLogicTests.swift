import XCTest
import JoyfillModel

final class SelectionFieldShowPageLogicTests: JoyfillUITestsBaseClass {
    
    // Show Page 9 on "N/A" opiton selected
    func testShowPageOnDropdownFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSixthPage = pageSheetSelectionButton.element(boundBy: 3)
        tapOnSixthPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Select "N/A" option ( Condition Field )
        let dropdownButton = app.buttons["Dropdown"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        let tapOnOption = dropdownOptions.element(boundBy: 2)
        tapOnOption.tap()
        XCTAssertEqual("66a0fd2b666d4708d98ea7b5", onChangeResultValue().text!)
        
        let conditionFieldTitle = "Condition Dropdown Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 9 is show )
        pageSelectionButton.tap()
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page Nine
        pageSelectionButton.tap()
        let tapOnNinthPage = pageSheetSelectionButton.element(boundBy: 6)
        tapOnNinthPage.tap()
        
        // Page 9 TextField
        let textField = textFields[0]
        XCTAssertTrue(textField.exists, "The alwaysShow text field does not exist.")
        textField.tap()
        textField.typeText("Page is Show\n")
        
        let textFieldTitle = "Page Show on Dropdown Selection"
        let textFieldTitleLabel = app.staticTexts[textFieldTitle]
        XCTAssertTrue(textFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
    
    func testShowPageOnSinlgeChoiceFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSeventhPage = pageSheetSelectionButton.element(boundBy: 4)
        tapOnSeventhPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        
        // Select "N/A" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 2).tap()
        XCTAssertEqual("66a1e2e9a3948b3bdc7a5d62", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Single Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 10 is show )
        pageSelectionButton.tap()
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page ten
        pageSelectionButton.tap()
        let tapOntenthPage = pageSheetSelectionButton.element(boundBy: 6)
        tapOntenthPage.tap()
        
        // Page 10 TextField
        let textField = textFields[0]
        XCTAssertTrue(textField.exists, "The alwaysShow text field does not exist.")
        textField.tap()
        textField.typeText("Page is Show\n")
        
        let textFieldTitle = "Page Show on single selection"
        let textFieldTitleLabel = app.staticTexts[textFieldTitle]
        XCTAssertTrue(textFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
    
    func testShowPageOnMultiChoiceFieldOption() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnEightPage = pageSheetSelectionButton.element(boundBy: 5)
        tapOnEightPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        
        // Select "N/A" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 2).tap()
        XCTAssertEqual("66a1e2e990bdfc31e9771e06", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Multiple Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Navigate to Page 1 ( Check page 11 is show )
        pageSelectionButton.tap()
        let tapOnFirstPage = pageSheetSelectionButton.element(boundBy: 0)
        tapOnFirstPage.tap()
        
        // Navigate to Page ten
        pageSelectionButton.tap()
        let tapOnEleventhPage = pageSheetSelectionButton.element(boundBy: 6)
        tapOnEleventhPage.tap()
        
        // Page 11 TextField
        let textField = textFields[0]
        XCTAssertTrue(textField.exists, "The alwaysShow text field does not exist.")
        textField.tap()
        textField.typeText("Page is Show\n")
        
        let textFieldTitle = "Page Show on multi selection field"
        let textFieldTitleLabel = app.staticTexts[textFieldTitle]
        XCTAssertTrue(textFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
    }
}



