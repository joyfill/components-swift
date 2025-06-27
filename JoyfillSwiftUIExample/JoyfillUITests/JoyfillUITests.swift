import XCTest
import JoyfillModel

final class JoyfillUITests: JoyfillUITestsBaseClass {

    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "Joydocjson"
    }
    
    func testTextFields() throws {
        let textField = app.textFields["Text"]
        XCTAssertEqual("Hello sir", textField.value as! String)
        textField.tap()
        textField.typeText("Hello\n")
        XCTAssertEqual("Hello sirHello", onChangeResultValue().text!)
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        sleep(1)
        
        let alert = app.alerts["ToolTip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["ToolTip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["ToolTip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    func testMultilineField() throws {
        let multiLineTextField = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertEqual("Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir", multiLineTextField.value as! String)
        multiLineTextField.tap()
        multiLineTextField.typeText("Hello")
        //        tap textfield to trigger onChange
        let textField = app.textFields["Text"]
        textField.tap()
        XCTAssertEqual("HelloHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir", onChangeResultValue().multilineText)
    }
    
    func testNumberField() throws {
        app.swipeUp()
        let numberTextField = app.textFields["Number"]
        XCTAssertEqual("98789", numberTextField.value as! String)
        numberTextField.tap()
        numberTextField.typeText("345\n")
        XCTAssertEqual(98789345.0, onChangeResultValue().number!)
    }

    func testDropdownFieldSelect_Unselect() throws {
        app.swipeUp()
        let dropdownButton = app.buttons["Dropdown"]
        XCTAssertEqual("Yes", dropdownButton.label)
        dropdownButton.tap()
        var dropdownOptions = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        var firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        XCTAssertEqual("6628f2e15cea1b971f6a9383", onChangeResultValue().text!)

        // test DropdownField UnselectOption
        dropdownButton.tap()
        dropdownOptions = app.buttons.matching(identifier: "DropdownoptionIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        XCTAssertEqual("", onChangeResultValue().text!)
    }

    func testMultiSelectionView() throws {
        app.swipeUp()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual("Yes", multiButtons.element(boundBy: 0).label)
        XCTAssertEqual("No", multiButtons.element(boundBy: 1).label)
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        XCTAssertEqual("6628f2e19c3cba4fdf9e5f19", onChangeResultValue().multiSelector?.first!)
    }
    
    func testSingleSelection() throws {
        app.swipeUp()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual("Yes", multiButtons.firstMatch.label)
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        XCTAssertEqual("6628f2e16bf0362dd5498eb4", onChangeResultValue().multiSelector?.first!)
    }
    
    // Test case for textfields call onChange after two seconds 
    func testTextFieldCallOnChangeAfterTwoSeconds() throws {
        let textField = app.textFields["Text"]
        XCTAssertEqual("Hello sir", textField.value as! String)
        textField.tap()
        textField.typeText("Hello")
        sleep(2)
        XCTAssertEqual("Hello sirHello", onChangeResultValue().text!)
    }
    
    func testMultilineFieldCallOnChangeAfterTwoSeconds() throws {
        let multiLineTextField = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertEqual("Hello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir", multiLineTextField.value as! String)
        multiLineTextField.tap()
        multiLineTextField.typeText("Hello")
        sleep(2)
        XCTAssertEqual("HelloHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir\nHello sir", onChangeResultValue().multilineText)
    }
    
    func testNumberFieldCallOnChangeAfterTwoSeconds() throws {
        app.swipeUp()
        let numberTextField = app.textFields["Number"]
        XCTAssertEqual("98789", numberTextField.value as! String)
        numberTextField.tap()
        numberTextField.typeText("345")
        sleep(2)
        XCTAssertEqual(98789345.0, onChangeResultValue().number!)
    }
}

