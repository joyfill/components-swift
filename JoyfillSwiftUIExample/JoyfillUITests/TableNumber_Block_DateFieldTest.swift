import XCTest

final class TableNumber_Block_DateFieldTest: JoyfillUITestsBaseClass {
    
    func goToTableDetailPage() {
        app.buttons["TableDetailViewIdentifier"].tap()
    }
    
    func tapOnMoreButton() {
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"]
        selectallbuttonImage.tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
    }
    
    func tapOnNumberFieldColumn() {
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 2)
        textFieldColumnTitleButton.tap()
    }
    
    func tapOnSearchBarTextField(value: String) {
        let searchBarTextField = app.textFields["SearchBarNumberIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("\(value)")
    }
    
    func tapOnNumberTextField(atIndex index: Int) -> XCUIElement {
        return app.children(matching: .window).element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .scrollView).element(boundBy: 2)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .textField).matching(identifier: "TabelNumberFieldIdentifier")
            .element(boundBy: index)
    }

    // Enter data in all number textfields
    func testTableNumberTextField() throws {
        goToTableDetailPage()
        
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        XCTAssertEqual("2", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("12")
        XCTAssertEqual("212", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText(".0")
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        thirdTextField.tap()
        thirdTextField.typeText(".001")
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        fourthTextField.tap()
        fourthTextField.typeText("22")
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        goBack()
        sleep(2)
        let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["67691971e689df0b1208de63"]?.number)
        let secondCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["67691971e689df0b1208de63"]?.number)
        let thirdCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["67691971e689df0b1208de63"]?.number)
        let fourthCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[3].cells?["67691971e689df0b1208de63"]?.number)
        let fifthCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[4].cells?["67691971e689df0b1208de63"]?.number)
        let sixthCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[5].cells?["67691971e689df0b1208de63"]?.number)
        XCTAssertEqual(212, firstCellTextValue)
        XCTAssertEqual(22, secondCellTextValue)
        XCTAssertEqual(200.001, thirdCellTextValue)
        XCTAssertEqual(2.11122, fourthCellTextValue)
        XCTAssertEqual(102, fifthCellTextValue)
        XCTAssertEqual(32, sixthCellTextValue)
    }
 
    // Test case for filter data
    func testSearchFilterForNumberTextField() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "2")
        
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText("12")
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        thirdTextField.tap()
        thirdTextField.typeText(".22")
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        XCTAssertEqual("2", firstTextField.value as! String)
        XCTAssertEqual("2212", secondTextField.value as! String)
        XCTAssertEqual("200.22", thirdTextField.value as! String)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
    }
 
    // Insert row with filter text
    func testInsertRowWithFilter() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "22")
        
        let filterDataTextField = tapOnNumberTextField(atIndex: 0)
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        tapOnMoreButton()
        app.buttons["TableInsertRowIdentifier"].tap()
        
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        // Check inserted row data
        let insertedTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", insertedTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        
        let insertedTextFieldDataAfterClearFilter = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("22", insertedTextFieldDataAfterClearFilter.value as! String)
        
        let thirdTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("200", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 6)
        XCTAssertEqual("32", sixthTextField.value as! String)
    }
    
    // Add Row with filter text
    func testAddRowWithFilter() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "22")
        
        let filterDataTextField = tapOnNumberTextField(atIndex: 0)
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        app.buttons["TableAddRowIdentifier"].tap()
        
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        // Check inserted row data
        let insertedTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", insertedTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        let addRowTextFieldDataAfterClearFilter = tapOnNumberTextField(atIndex: 6)
        XCTAssertEqual("22", addRowTextFieldDataAfterClearFilter.value as! String)
    }
    
    // Bulk Edit - Single row
    func testBulkEditNumberFieldSingleRow() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("1234.56")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        XCTAssertEqual("1234.56", firstTextField.value as! String)
        goBack()
        sleep(1)
        let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["67691971e689df0b1208de63"]?.number)
        XCTAssertEqual(1234.56, firstCellTextValue)
    }
    
    // Bulk Edit - Edit all Rows
    func testBulkEditNumberFieldEditAllRows() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("123.345")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        for i in 0..<6 {
            let textField = tapOnNumberTextField(atIndex: i)
            XCTAssertEqual("123.345", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
        
        goBack()
        sleep(1)
        let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["67691971e689df0b1208de63"]?.number)
        XCTAssertEqual(123.345, firstCellTextValue)
    }
    
    // Sorting Test case
    func testSortingNumberField() throws {
        goToTableDetailPage()
        let firstTextField = tapOnNumberTextField(atIndex: 0)
        firstTextField.tap()
        
        tapOnNumberFieldColumn()
        
        // Sort in ascending order - First time click
        app.buttons["SortButtonIdentifier"].tap()
        
        // Check data after sorting in ascending order
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("2.111", secondTextField.value as! String)
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("22", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("32", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("200", sixthTextField.value as! String)
        
        // Sort in descending order - Second time click
        app.buttons["SortButtonIdentifier"].tap()
        
        XCTAssertEqual("200", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("12")
        XCTAssertEqual("102", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText(".34")
        XCTAssertEqual("32", thirdTextField.value as! String)
        XCTAssertEqual("22", fourthTextField.value as! String)
        XCTAssertEqual("2.111", fifthTextField.value as! String)
        XCTAssertEqual("2", sixthTextField.value as! String)
        
        // Remove sort - Third time click
        app.buttons["SortButtonIdentifier"].tap()
        
        XCTAssertEqual("2", firstTextField.value as! String)
        XCTAssertEqual("22", secondTextField.value as! String)
        XCTAssertEqual("20012", thirdTextField.value as! String)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        XCTAssertEqual("102.34", fifthTextField.value as! String)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        goBack()
        sleep(1)
        
        // Check edited cell value - change on sorting time
        let thirdCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["67691971e689df0b1208de63"]?.number)
        let fifthCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[4].cells?["67691971e689df0b1208de63"]?.number)
        XCTAssertEqual(20012, thirdCellTextValue)
        XCTAssertEqual(102.34, fifthCellTextValue)
    }
    
    // Block field test case
    func testTableTextFields() throws {
        goToTableDetailPage()
        sleep(1)
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("First row", firstTableTextField.value as! String)
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Second row", secondTableTextField.value as! String)
        
        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("112", thirdTableTextField.value as! String)
        
        let fourthTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("", fourthTableTextField.value as! String)
        
        let fifthTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Block Field", fifthTableTextField.value as! String)
        
        let sixthTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
        XCTAssertEqual("", sixthTableTextField.value as! String)
        sleep(1)
    }
    
    // Date and time format field test case
    
    // Change selected date
    func testChangeSelectedDate() throws {
        goToTableDetailPage()
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        firstDatePicker.tap()
        
        let nextButton = app.buttons["Next"]
        while !app.staticTexts["April 2024"].exists {
            nextButton.tap()
        }
        
       // Remember - ["Sunday 7 April"] - here set the date of current month
        let specificDayButton = app.buttons["Sunday 7 April"] // The full label of the button
        XCTAssertTrue(specificDayButton.exists, "The date 'Sunday 7 April' should be visible in the calendar.")
            specificDayButton.tap()
        XCUIApplication().buttons["PopoverDismissRegion"].tap()
        
        goBack()
        sleep(1)
        let checkSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertEqual(1712428200000.0, checkSelectedDateValue)
    }
    
    // Set nil to existing date & select another date
    func testSetNilToExitingDate() throws {
        goToTableDetailPage()
        
        let setDateToNilIdentifierButton = app.buttons.matching(identifier: "SetDateToNilIdentifier")
        let tapOnButton = setDateToNilIdentifierButton.element(boundBy: 0)
        tapOnButton.tap()
        sleep(1)
        app.scrollViews.otherElements.containing(.image, identifier:"CalendarImageIdentifier").children(matching: .image).matching(identifier: "CalendarImageIdentifier").element(boundBy: 0).tap()
        
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        firstDatePicker.tap()
        
       // Remember - ["Sunday 7 April"] - here set the date of current month
        let specificDayButton = app.buttons["Sunday 29 December"] // The full label of the button
        XCTAssertTrue(specificDayButton.exists, "The date 'Sunday 29 December' should be visible in the calendar.")
        specificDayButton.tap()
        XCUIApplication().buttons["PopoverDismissRegion"].tap()
        
        goBack()
        sleep(1)
        
        let checkSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(checkSelectedDateValue)
    }

    // Bulk single edit test case
    func testBulkEditDateFieldSingleRow() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
        app.buttons["ApplyAllButtonIdentifier"].tap()
        sleep(1)
        goBack()
        sleep(1)
        let checkSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[3].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(checkSelectedDateValue)
    }
    
    // Bulk edit all rows
    func testBulkEditDateFieldAllRow() throws {
        goToTableDetailPage()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
                                
        app.buttons["ApplyAllButtonIdentifier"].tap()
        sleep(1)
        goBack()
        sleep(1)
        
        let firstSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(firstSelectedDateValue)
        let secondSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(secondSelectedDateValue)
        let thirdSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(thirdSelectedDateValue)
        let fourthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[3].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(fourthSelectedDateValue)
        let fifthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[4].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(fifthSelectedDateValue)
        let sixthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[5].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(sixthSelectedDateValue)
        
    }
    
    // Time only field test case - Change format in json - "hh:mma" to run time only test case
    
    // Change selected time
    func testChangeTimePicker() throws {
        goToTableDetailPage()
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        firstDatePicker.tap()
        
        let hourPicker = app.pickerWheels.element(boundBy: 0)
        let minutePicker = app.pickerWheels.element(boundBy: 1)
        let periodPicker = app.pickerWheels.element(boundBy: 2)
        
        hourPicker.adjust(toPickerWheelValue: "1")
        minutePicker.adjust(toPickerWheelValue: "02")
        periodPicker.adjust(toPickerWheelValue: "PM")
        XCUIApplication().buttons["PopoverDismissRegion"].tap()
        
        sleep(1)
        goBack()
        sleep(1)
        let checkSelectedTimeValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertEqual(946711920000.0, checkSelectedTimeValue)
        
    }
    
    // Set nil to existing time & change another time
    func testSetNilToExitingTime() throws {
        goToTableDetailPage()
        
        let setDateToNilIdentifierButton = app.buttons.matching(identifier: "SetDateToNilIdentifier")
        let tapOnButton = setDateToNilIdentifierButton.element(boundBy: 0)
        tapOnButton.tap()
        sleep(1)
        app.scrollViews.otherElements.containing(.image, identifier:"CalendarImageIdentifier").children(matching: .image).matching(identifier: "CalendarImageIdentifier").element(boundBy: 0).tap()
        
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        firstDatePicker.tap()
        
        let hourPicker = app.pickerWheels.element(boundBy: 0)
        let minutePicker = app.pickerWheels.element(boundBy: 1)
        let periodPicker = app.pickerWheels.element(boundBy: 2)
        
        hourPicker.adjust(toPickerWheelValue: "12")
        minutePicker.adjust(toPickerWheelValue: "12")
        periodPicker.adjust(toPickerWheelValue: "AM")
        XCUIApplication().buttons["PopoverDismissRegion"].tap()
        
        sleep(1)
        goBack()
        sleep(1)
        let checkSelectedTimeValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertEqual(1735152120000.0, checkSelectedTimeValue)
    }
    
    // Bulk single edit test case
    func testBulkEditTimeFieldSingleRow() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
        app.buttons["ApplyAllButtonIdentifier"].tap()
        sleep(1)
        goBack()
        sleep(1)
        let checkSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[3].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(checkSelectedDateValue)
    }
    
    // Bulk edit all rows
    func testBulkEditTimeFieldAllRow() throws {
        goToTableDetailPage()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
                                
        app.buttons["ApplyAllButtonIdentifier"].tap()
        sleep(1)
        goBack()
        sleep(1)
        
        let firstSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(firstSelectedDateValue)
        let secondSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(secondSelectedDateValue)
        let thirdSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(thirdSelectedDateValue)
        let fourthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[3].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(fourthSelectedDateValue)
        let fifthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[4].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(fifthSelectedDateValue)
        let sixthSelectedDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[5].cells?["676919715e36fed325f2f048"]?.number)
        XCTAssertNotNil(sixthSelectedDateValue)
        
    }
}


