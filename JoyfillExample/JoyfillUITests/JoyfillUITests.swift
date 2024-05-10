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
        XCTAssertFalse(app.sheets.firstMatch.exists)
        XCTAssertEqual("", onChangeResultValue().text!)
    }

    func testMultiSelectionView() throws {
        app.swipeUp()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        XCTAssertEqual("6628f2e1679bcf815adfa0f6", onChangeResultValue().multiSelector?.first!)
    }
    
    func testSingleSelection() throws {
        app.swipeUp()
        app.swipeUp()
        let multiButtons = app.buttons.matching(identifier: "SingleSelectionIdentifier")
        for button in multiButtons.allElementsBoundByIndex {
            button.tap()
        }
        XCTAssertEqual("6628f2e16bf0362dd5498eb4", onChangeResultValue().multiSelector?.first!)
    }
    
    func testSignatureField() throws {
        app.swipeUp()
        app.swipeUp()
        app.buttons["SignatureIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func goToTableDetailPage() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["TableDetailViewIdentifier"].tap()
    }
    
    func testTableTextFields() throws {
        goToTableDetailPage()
        
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        secondTableTextField.tap()
        secondTableTextField.typeText("Second")
        
        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("Third")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func testTableDropdownOption() throws {
        goToTableDetailPage()
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func testTableUploadImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func testTabelDeleteImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        XCUIApplication().scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
        app.buttons["ImageDeleteIdentifier"].tap()
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    func testTableAddRow() throws {
        goToTableDetailPage()
        app.buttons["TableAddRowIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(3, lastIndex)
    }
    
    func testTableDeleteRow() throws {
        goToTableDetailPage()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(3, valueElements.count)
    }
}

