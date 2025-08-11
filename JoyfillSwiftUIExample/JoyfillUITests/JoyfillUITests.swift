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
        
        // Wait for MultiSelection elements to appear
        let multiButtons = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        let firstButton = multiButtons.element(boundBy: 0)
        
        // Scroll to find the MultiSelection elements if they're not immediately visible
        var scrollAttempts = 0
        while !firstButton.waitForExistence(timeout: 1) && scrollAttempts < 5 {
            app.swipeUp()
            scrollAttempts += 1
        }
        
        XCTAssertTrue(firstButton.exists, "MultiSelection buttons not found")
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
        let firstButton = multiButtons.element(boundBy: 0)
        
        // Scroll to find the MultiSelection elements if they're not immediately visible
        var scrollAttempts = 0
        while !firstButton.waitForExistence(timeout: 1) && scrollAttempts < 5 {
            app.swipeUp()
            scrollAttempts += 1
        }

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
        
        // Wait for onChange to be called with polling approach
        let startTime = Date()
        let timeout: TimeInterval = 3.0
        var result: String?
        
        repeat {
            result = onChangeResultValue().text
            if result == "Hello sirHello" {
                break
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        } while Date().timeIntervalSince(startTime) < timeout
        
        XCTAssertEqual("Hello sirHello", onChangeResultValue().text!)
    }
}

