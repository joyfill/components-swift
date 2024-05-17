import XCTest

final class TableFieldTests: JoyfillUITestsBaseClass {
    private func goToTableDetailPage() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["TableDetailViewIdentifier"].tap()
    }
    
    private func dismissSheet() {
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
        XCTAssertEqual("Hi", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("S")

        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Hi", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("T")

        goBack()
        sleep(1)
        XCTAssertEqual("FirstHello", onChangeResultValue().valueElements?[0].cells?["6628f2e11a2b28119985cfbb"]?.text)
        XCTAssertEqual("SHi", onChangeResultValue().valueElements?[1].cells?["6628f2e11a2b28119985cfbb"]?.text)
        XCTAssertEqual("THi", onChangeResultValue().valueElements?[2].cells?["6628f2e11a2b28119985cfbb"]?.text)
    }
    
    func testTableDropdownSelect() throws {
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
        XCTAssertEqual("No", dropdownButtons.element(boundBy: 0).label)
        goBack()
        sleep(1)
        XCTAssertEqual("6628f2e1c12db4664e9eb38f", onChangeResultValue().valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text)
    }

    func testTableDropdownUnselect() throws {
        goToTableDetailPage()
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", dropdownButtons.element(boundBy: 0).label)
        XCTAssertEqual("No", dropdownButtons.element(boundBy: 1).label)
        XCTAssertEqual("No", dropdownButtons.element(boundBy: 2).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        XCTAssertEqual("Select Option", dropdownButtons.element(boundBy: 0).label)
        goBack()
        sleep(1)
        XCTAssertEqual("", onChangeResultValue().valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text)
    }

    func testTableUploadImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 1)
        XCTAssertEqual(firstImageButton.label, "")

        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        XCTAssertEqual(firstImageButton.label, "+1")

        goBack()
        sleep(1)

        let value = onChangeResultValue()
        let valueElements = value.valueElements
        let cells = valueElements![1].cells
        let images = cells!["663dcdcfcd08ad955955fd95"]!.valueElements!
        XCTAssertEqual(images.count, 1)
        let imageURL = try XCTUnwrap(images[0].url)
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", imageURL)
    }

    func testTableUploadMoreImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        XCTAssertEqual(firstImageButton.label, "+1")

        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        XCTAssertEqual(firstImageButton.label, "+2")

        goBack()
        sleep(1)

        let value = onChangeResultValue()
        let valueElements = value.valueElements
        let cells = valueElements?.first?.cells
        let images = cells!["663dcdcfcd08ad955955fd95"]!.valueElements!
        XCTAssertEqual(images.count, 2)
        let imageURL = try XCTUnwrap(images[1].url)
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", imageURL)
    }

    func testTabelDeleteImage() throws {
        goToTableDetailPage()
        // Check for image count
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        XCTAssertEqual(firstImageButton.label, "+1")
        
        // show image detail
        firstImageButton.tap()
        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
        app.buttons["ImageDeleteIdentifier"].tap()

        dismissSheet()
        XCTAssertEqual(firstImageButton.label, "")

        goBack()

        sleep(1)

        let value = onChangeResultValue()
        let valueElements = value.valueElements
        let cells = valueElements?.first?.cells
        let images = cells!["663dcdcfcd08ad955955fd95"]
        XCTAssertNil(images?.valueElements)
    }


    func testTabelDeleteMoreImage() throws {
        goToTableDetailPage()
        // Check for image count
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        XCTAssertEqual(firstImageButton.label, "+1")


        // show image detail
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()

        dismissSheet()

        XCTAssertEqual(firstImageButton.label, "+2")
        firstImageButton.tap()

        app.scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
        app.buttons["ImageDeleteIdentifier"].tap()

        dismissSheet()
        XCTAssertEqual(firstImageButton.label, "+1")

        goBack()

        sleep(1)

        let value = onChangeResultValue()
        let valueElements = value.valueElements
        let cells = valueElements?.first?.cells
        let images = cells!["663dcdcfcd08ad955955fd95"]!.valueElements!
        XCTAssertEqual(images.count, 1)
        let imageURL = try XCTUnwrap(images[0].url)
        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", imageURL)
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

