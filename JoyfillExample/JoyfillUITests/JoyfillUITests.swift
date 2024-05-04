import XCTest

final class JoyfillUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws { }
    
    func testAppLaunch() throws {
        appLaunch()
    }
    
    func appLaunch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("FormView")
        app.launch()
        return app
    }
    
    func testTextFields() throws {
        let app = appLaunch()
        let textField = app.textFields["Text"]
        textField.tap()
        textField.typeText("Hello\n")
        
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("Hello sirHello", resultField.label)
    }
    
    func testMultilineField() throws {
        let app = appLaunch()
        let textField = app.textViews["Multiline Text"]
        textField.tap()
        textField.typeText("Hello\n")
        
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("", resultField.label)
    }
    
    func testNumberField() throws {
        let app = appLaunch()
        app.swipeUp()
        let numberTextField = app.textFields["Number"]
        numberTextField.tap()
        numberTextField.typeText("345\n")
        
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("98789345.0", resultField.label)
    }
    
    //    func testDateField() throws {
    //        let app = appLaunch()
    //        app.swipeUp()
    //        let datePicker = app.datePickers["field_6629fb44309fbfe84376095e"]
    //
    //        // Set the date to January 1, 2022
    //        let newDate = DateComponents(calendar: .current, year: 2022, month: 1, day: 1).date!
    //        datePicker.adjust(toPickerWheelValue: DateFormatter.localizedString(from: newDate, dateStyle: .long, timeStyle: .none))
    //
    //        // Check if the date was correctly set
    //        XCTAssertEqual(datePicker.value as? String, "January 1, 2022", "Date picker value is correct")
    //    }
    
    func testDropdownField() throws {
        let app = appLaunch()
        app.swipeUp()
        app.buttons["Dropdown"].tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "6628f2e15cea1b971f6a9383")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        XCTAssertFalse(app.sheets.firstMatch.exists)
        
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("6628f2e15cea1b971f6a9383", resultField.label)
    }
    
    func testMultiSelectionView() throws {
        let app = appLaunch()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("6628f2e1679bcf815adfa0f6", resultField.label)
    }
    
    func testSingleSelection() throws {
        let app = appLaunch()
        app.swipeUp()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        let resultField = app.staticTexts["resultfield"]
        XCTAssertEqual("6628f2e16bf0362dd5498eb4", resultField.label)
    }
    
    
}
