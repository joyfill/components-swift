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
    
    func testImageField() {
        let app = appLaunch()
        app.buttons["ImageMoreIdentifier"].tap()
        
        //        app.buttons["DetailImageIdentifier"].tap()
        
        //        app.buttons["ImageDeleteImageIdentifier"].tap()
        
        app.buttons["ImageUploadImageIdentifier"].tap()
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
    
    func testDatePicker() {
        let app = appLaunch()
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }
    
    func testTimePicker() {
        let app = appLaunch()
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 1)
        datePicker.tap()
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }
    
    func testDateTimePicker() {
        let app = appLaunch()
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 2)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }
    
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
    
    func testSignatureField() throws {
        let app = appLaunch()
        app.swipeUp()
        app.swipeUp()
        app.buttons["SignatureIdentifier"].tap()
    }
    
    func testChartField() {
        let app = appLaunch()
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["ChartViewIdentifier"].tap()
        app.buttons["ShowHideButtonIdentifier"].tap()
        
        let verticalTitleTextFieldIdentifier = app.textFields["VerticalTextFieldIdentifier"]
        let horizontalTitleTextFieldIdentifier = app.textFields["HorizontalTextFieldIdentifier"]
        
        verticalTitleTextFieldIdentifier.tap()
        verticalTitleTextFieldIdentifier.typeText(" Label Y")
        
        horizontalTitleTextFieldIdentifier.tap()
        horizontalTitleTextFieldIdentifier.typeText(" Label X")
        
        let minYValuesTextField = app.textFields["MinY"]
        let minXValuesTextField = app.textFields["MinX"]
        let maxYValuesTextField = app.textFields["MaxY"]
        let maxXValuesTextField = app.textFields["MaxX"]
        
        minYValuesTextField.tap()
        minYValuesTextField.typeText("10")
        
        minXValuesTextField.tap()
        minXValuesTextField.typeText("20")
        
        maxYValuesTextField.tap()
        maxYValuesTextField.typeText("30")
        
        maxXValuesTextField.tap()
        maxXValuesTextField.typeText("40")
        
        app.swipeUp()
        
        let addLineButtonIdentifier = app.buttons.matching(identifier: "AddLineIdentifier")
        let addLineButton = addLineButtonIdentifier.element(boundBy: 0)
        addLineButton.tap()
        
        let removeLineButtonIdentifier = app.buttons.matching(identifier: "RemoveLineIdentifier")
        let removeLineButton = removeLineButtonIdentifier.element(boundBy: 0)
        removeLineButton.tap()
        
        let addPointButtonIdentifier = app.buttons.matching(identifier: "AddPointIdentifier")
        let addPointButton = addPointButtonIdentifier.element(boundBy: 0)
        addPointButton.tap()
        
        let removePointButtonIdentifier = app.buttons.matching(identifier: "RemovePointIdentifier")
        let removePointButton = removePointButtonIdentifier.element(boundBy: 0)
        removePointButton.tap()
        
        let titleTextFieldIdentifier = app.textFields["TitleTextFieldIdentifier"]
        titleTextFieldIdentifier.tap()
        titleTextFieldIdentifier.typeText("Line Title")
        
        let descriptionTextFieldIdentifier = app.textFields["DescriptionTextFieldIdentifier"]
        descriptionTextFieldIdentifier.tap()
        descriptionTextFieldIdentifier.typeText("Line Description")
        
        let textFields = app.textFields.matching(identifier: "PointLabelTextFieldIdentifier")
        let texts = ["PointLabel1", "PointLabel2", "PointLabel3\n"]
        
        for i in 0..<textFields.count {
            let textField = textFields.element(boundBy: i)
            guard textField.exists else {
                XCTFail("Text field \(i) does not exist.")
                return
            }
            textField.tap()
            if i < texts.count {
                textField.typeText("\(texts[i])")
            } else {
                XCTFail("No text provided for text field \(i).")
            }
        }
        
        let horizontalPointsValueIdentifier = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue = horizontalPointsValueIdentifier.element(boundBy: 0)
        horizontalPointsValue.tap()
        horizontalPointsValue.typeText("10")
        
        let horizontalPointsValueIdentifier1 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue1 = horizontalPointsValueIdentifier1.element(boundBy: 1)
        horizontalPointsValue1.tap()
        horizontalPointsValue1.typeText("20")
        
        let verticalPointsValueIdentifier = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue = verticalPointsValueIdentifier.element(boundBy: 0)
        verticalPointsValue.tap()
        verticalPointsValue.typeText("30")
        
        let verticalPointsValueIdentifier1 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue1 = verticalPointsValueIdentifier1.element(boundBy: 1)
        verticalPointsValue1.tap()
        verticalPointsValue1.typeText("40")
        
        let horizontalPointsValueIdentifier2 = app.textFields.matching(identifier: "HorizontalPointsValue")
        let horizontalPointsValue2 = horizontalPointsValueIdentifier1.element(boundBy: 2)
        horizontalPointsValue2.tap()
        horizontalPointsValue2.typeText("50")
        
        let verticalPointsValueIdentifier2 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue2 = verticalPointsValueIdentifier2.element(boundBy: 2)
        verticalPointsValue2.tap()
        verticalPointsValue2.typeText("60")
    }
}
