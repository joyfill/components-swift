import XCTest

final class TableNewFieldsTestCase: JoyfillUITestsBaseClass {
    func goToTableDetailPage() {
        app.buttons["TableDetailViewIdentifier"].tap()
    }
    // Test Case For Block Field
    func testTableBlockTextFields() throws {
        goToTableDetailPage()
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Block", firstTableTextField.value as! String)
        firstTableTextField.tap()
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Column", secondTableTextField.value as! String)
        secondTableTextField.tap()
        
        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Done", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        
    }
    
    // Test Case for Number Field
    
    func tapOnNumberFieldColumn() {
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
        textFieldColumnTitleButton.tap()
    }

    func tapOnSearchBarTextField() {
        let searchBarTextField = app.textFields["TableNumberTextFieldSearchBarIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("345\n")
    }
    
    // Add numbers in number field
    func testTableNumberField() throws {
        goToTableDetailPage()
        
        let firstTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("1234567890", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("123")
        
        let secondTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("34.789", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("123")
        
        let thirdTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("56345", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("123")
        
        goBack()
        goToTableDetailPage()
        XCTAssertEqual("1231234567890", firstTableTextField.value as! String)
        XCTAssertEqual("12334.789", secondTableTextField.value as! String)
        XCTAssertEqual("12356345", thirdTableTextField.value as! String)
    }
    
    // test case for filter number
    func testTableNumberFilter() throws {
        goToTableDetailPage()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField()
        
        let firstTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("1234567890", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("123")
        
        let secondTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("56345", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("123")
        
        app.buttons["HideFilterSearchBar"].tap()
        
        XCTAssertEqual("1231234567890", firstTableTextField.value as! String)
        
        let thirdTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("56345", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("12356345")
    }
    
    // test case for sorting
    func testTableNumberFieldSorting() throws {
        goToTableDetailPage()
        tapOnNumberFieldColumn()
        
        // Ascending Order
        app.buttons["SortButtonIdentifier"].tap()
        let firstTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("34.789", firstTableTextField.value as! String)
        
        let secondTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("56345", secondTableTextField.value as! String)
        
        let thirdTableTextField = app.textViews.matching(identifier: "TableNumberFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("1234567890", thirdTableTextField.value as! String)
                
        // Descending order
        app.buttons["SortButtonIdentifier"].tap()
        XCTAssertEqual("1234567890", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("123")
        
        XCTAssertEqual("56345", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("123")
        
        XCTAssertEqual("34.789", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("123")
        
        // Normal State
        app.buttons["SortButtonIdentifier"].tap()
        XCTAssertEqual("1231234567890", firstTableTextField.value as! String)
        XCTAssertEqual("12334.789", secondTableTextField.value as! String)
        XCTAssertEqual("12356345", thirdTableTextField.value as! String)
    }
}
