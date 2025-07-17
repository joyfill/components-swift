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
      
    func testDropdownFieldSelect_Unselect() throws {
        app.swipeUp()
        let dropdownButton = app.buttons["Dropdown"]
        var scrollAttempts = 0
        while !dropdownButton.exists && scrollAttempts < 5 {
            app.swipeUp()
            sleep(1)
            scrollAttempts += 1
        }
        XCTAssertTrue(dropdownButton.waitForExistence(timeout: 5), "Dropdown button not found on iPad")

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
}

