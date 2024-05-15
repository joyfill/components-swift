import XCTest

final class TableFieldTests: JoyfillUITestsBaseClass {
    func goToTableDetailPage() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["TableDetailViewIdentifier"].tap()
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func testTableTextFields() throws {
        goToTableDetailPage()
        
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("His", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("Second")
        
        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("His", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("Third")
        
        goBack()
        sleep(1)
        XCTAssertEqual("FirstHello", onChangeResultValue().valueElements?[0].cells?["6628f2e11a2b28119985cfbb"]?.text)
        XCTAssertEqual("SecondHis", onChangeResultValue().valueElements?[1].cells?["6628f2e11a2b28119985cfbb"]?.text)
        XCTAssertEqual("ThiHisrd", onChangeResultValue().valueElements?[2].cells?["6628f2e11a2b28119985cfbb"]?.text)
    }
    
    func testTableDropdownOption() throws {
        goToTableDetailPage()
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", dropdownButtons.element(boundBy: 0).label)
        XCTAssertEqual("No", dropdownButtons.element(boundBy: 1).label)
        XCTAssertEqual("No", dropdownButtons.element(boundBy: 2).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        goBack()
        sleep(1)
        XCTAssertEqual("6628f2e1c12db4664e9eb38f", onChangeResultValue().valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text)
    }
    
    func testTableUploadImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        goBack()
        sleep(1)
        XCTAssertEqual("https://s3.amazonaws.com/docspace.production.documents/6628f1034892618fc118503b/documents/doc_663dcddf95255501dfa00ee5/663dce179e381b4f29128820-1715326487573.jpg", onChangeResultValue().valueElements?[0].cells?["663dcdcfcd08ad955955fd95"]?.valueElements?.first?.url)
    }
    
    func testTabelDeleteImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
        app.buttons["ImageDeleteIdentifier"].tap()
        dismissSheet()
        goBack()
        sleep(1)
        XCTAssertEqual(nil, onChangeResultValue().valueElements?[0].cells?["663dcdcfcd08ad955955fd95"]?.valueElements?.first?.url)
    }
    
    func testTableAddRow() throws {
        goToTableDetailPage()
        app.buttons["TableAddRowIdentifier"].tap()
        goBack()
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
        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(3, valueElements.count)
    }
}

