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
}


