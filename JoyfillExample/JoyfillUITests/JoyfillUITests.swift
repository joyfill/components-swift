import XCTest
import JoyfillModel

final class JoyfillUITests: JoyfillUITestsBaseClass {

    func testTextFields() throws {
        let textField = app.textFields["Text"]
        XCTAssertEqual("Hello sir", textField.value as! String)
        textField.tap()
        textField.typeText("Hello\n")
        XCTAssertEqual("Hello sirHello", onChangeResultValue().text!)
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
        XCTAssertEqual("Select Option", dropdownButton.label)
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
        XCTAssertEqual("6628f2e1679bcf815adfa0f6", onChangeResultValue().multiSelector?.first!)
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
}

