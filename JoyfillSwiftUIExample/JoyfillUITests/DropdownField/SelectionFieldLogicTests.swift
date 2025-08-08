import XCTest
import JoyfillModel

final class SelectionFieldLogicTests: JoyfillUITestsBaseClass {
    func testEqualConditionOnDropdownField() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 3)
        tapOnSecondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Always Show TextField
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Always Show\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is Hide when condition true
        let hideFieldOnConditionTrueTextField = textFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        
        let hideFieldTitle = "Field Hide when condition is True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Select "Yes" option ( Condition Field )
        let dropdownButton = app.buttons["Dropdown"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        XCTAssertEqual("66a0fd2bf2db63720bb5760f", onChangeResultValue().text!)
        
        let conditionFieldTitle = "Condition Dropdown Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is show when condition true
        let showFieldOnConditionTrue = textFields[1]
        XCTAssertTrue(showFieldOnConditionTrue.exists, "The showFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrue.tap()
        showFieldOnConditionTrue.typeText("Field is show when condition true\n")
        
        let showFieldTextFieldTitle = "Field Show when condition is True"
        let showFieldTextFieldLabel = app.staticTexts[showFieldTextFieldTitle]
        XCTAssertTrue(showFieldTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Click dropdown option for unselect the option
        dropdownButton.tap()
        let dropdownOption = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        let unselectFirstOption = dropdownOption.element(boundBy: 0)
        unselectFirstOption.tap()
        XCTAssertEqual("", onChangeResultValue().text!)
        
        // check after unselect dropdown option
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is show\n")
    }
    
    // Test Case for single choice field
    func testEqualConditionOnSingleChoiceField() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 4)
        tapOnSecondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Always Show TextField
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Always Show\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is Hide when condition true
        let hideFieldOnConditionTrueTextField = textFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        
        let hideFieldTitle = "Field Hide when condition is True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Select "Yes" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 0).tap()
        XCTAssertEqual("66a1e2e9e9e6674ea80d71f7", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Single Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is show when condition true
        let showFieldOnConditionTrue = textFields[1]
        XCTAssertTrue(showFieldOnConditionTrue.exists, "The showFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrue.tap()
        showFieldOnConditionTrue.typeText("Field is show when condition true\n")
        
        let showFieldTextFieldTitle = "Field Show when condition is True"
        let showFieldTextFieldLabel = app.staticTexts[showFieldTextFieldTitle]
        XCTAssertTrue(showFieldTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Click Single select option for unselect the option
        selectYesOption.element(boundBy: 0).tap()
        
        // check after unselect option
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText(" All Ok\n")
    }
    
    // Test Case for Multi choice field
    func testEqualConditionOnMultiChoiceField() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 5)
        tapOnSecondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        // Always Show TextField
        let alwaysShowTextField = textFields[0]
        XCTAssertTrue(alwaysShowTextField.exists, "The alwaysShow text field does not exist.")
        alwaysShowTextField.tap()
        alwaysShowTextField.typeText("Always Show\n")
        
        let alwaysShowTextFieldTitle = "Always Show Field"
        let alwaysShowTextFieldTitleLabel = app.staticTexts[alwaysShowTextFieldTitle]
        XCTAssertTrue(alwaysShowTextFieldTitleLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is Hide when condition true
        let hideFieldOnConditionTrueTextField = textFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        
        let hideFieldTitle = "Field Hide when condition is True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Select "Yes" option ( Condition Field )
        let selectYesOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual("Yes", selectYesOption.firstMatch.label)
        selectYesOption.element(boundBy: 0).tap()
        XCTAssertEqual("66a1e2e923b2fd31e18d4f5c", onChangeResultValue().multiSelector?.first!)
        
        let conditionFieldTitle = "Condition Multiple Choice Field"
        let conditionFieldLabel = app.staticTexts[conditionFieldTitle]
        XCTAssertTrue(conditionFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Field is show when condition true
        let showFieldOnConditionTrue = textFields[1]
        XCTAssertTrue(showFieldOnConditionTrue.exists, "The showFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrue.tap()
        showFieldOnConditionTrue.typeText("Field is show when condition true\n")
        
        let showFieldTextFieldTitle = "Field Show when condition is True"
        let showFieldTextFieldLabel = app.staticTexts[showFieldTextFieldTitle]
        XCTAssertTrue(showFieldTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        // Click Single select option for unselect the option
        selectYesOption.element(boundBy: 0).tap()
        
        // check after unselect option
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText(" All Ok\n")
    }
    
}


