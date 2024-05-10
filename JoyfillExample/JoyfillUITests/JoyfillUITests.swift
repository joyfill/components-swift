import XCTest
import JoyfillModel

final class JoyfillUITests: JoyfillUITestsBaseClass {


    func testMultipleImageUploadFromDetailPage() {
        app.buttons["ImageMoreIdentifier"].tap()
        XCUIApplication().scrollViews.children(matching: .other).element(boundBy: 0).children(matching: .other).element.children(matching: .image).matching(identifier: "DetailPageImageSelectionIdentifier").element(boundBy: 0).tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertEqual("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s", onChangeResultValue().imageURLs?.first)
    }

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
    
    func testDatePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }
    
    func testTimePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 1)
        datePicker.tap()
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }
    
    func testDateTimePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 2)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
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
    
    func goToChartDetailField() {
        app.swipeUp()
        app.swipeUp()
        app.swipeUp()
        app.buttons["ChartViewIdentifier"].tap()
    }
    
    func testChartField() {
        goToChartDetailField()
        
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
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual("Horizontal Label X", onChangeResultChange().xTitle)
        XCTAssertEqual("Vertical Label Y", onChangeResultChange().yTitle)
        XCTAssertEqual(10040.0, onChangeResultChange().xMax)
        XCTAssertEqual(20.0, onChangeResultChange().xMin)
        XCTAssertEqual(10030.0, onChangeResultChange().yMax)
        XCTAssertEqual(10.0, onChangeResultChange().yMin)
    }
    
    func testChartLineButton() throws {
        goToChartDetailField()
        let addLineButtonIdentifier = app.buttons.matching(identifier: "AddLineIdentifier")
        let addLineButton = addLineButtonIdentifier.element(boundBy: 0)
        addLineButton.tap()
        let removeLineButtonIdentifier = app.buttons.matching(identifier: "RemoveLineIdentifier")
        let removeLineButton = removeLineButtonIdentifier.element(boundBy: 0)
        removeLineButton.tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual(1, onChangeResultValue().valueElements?.count)
    }
    
    func testChartAddPoint() throws {
        goToChartDetailField()
        let addPointButtonIdentifier = app.buttons.matching(identifier: "AddPointIdentifier")
        let addPointButton = addPointButtonIdentifier.element(boundBy: 0)
        addPointButton.tap()
        
        let removePointButtonIdentifier = app.buttons.matching(identifier: "RemovePointIdentifier")
        let removePointButton = removePointButtonIdentifier.element(boundBy: 0)
        removePointButton.tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual(3, onChangeResultValue().valueElements?.first?.points?.count)
    }
    
    func testChartPointTitleAndDescription() throws {
        goToChartDetailField()
        let titleTextFieldIdentifier = app.textFields["TitleTextFieldIdentifier"]
        titleTextFieldIdentifier.tap()
        titleTextFieldIdentifier.typeText("Line Title")
        
        let descriptionTextFieldIdentifier = app.textFields["DescriptionTextFieldIdentifier"]
        descriptionTextFieldIdentifier.tap()
        descriptionTextFieldIdentifier.typeText("Line Description")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual("Line Title", onChangeResultValue().valueElements?[0].title)
        XCTAssertEqual("Line Description", onChangeResultValue().valueElements?[0].description)
        
    }
    
    func testChartPointsLabel() throws {
        goToChartDetailField()
        let textFields = app.textFields.matching(identifier: "PointLabelTextFieldIdentifier")
        let texts = ["PointLabel1", "PointLabel2", "PointLabel3"]
        
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
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual("PointLabel1", onChangeResultValue().valueElements?[0].points?[0].label)
        XCTAssertEqual("PointLabel2", onChangeResultValue().valueElements?[0].points?[1].label)
        XCTAssertEqual("PointLabel3", onChangeResultValue().valueElements?[0].points?[2].label)
    }
    
    func testChartPointsValue() throws {
        goToChartDetailField()
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
        let horizontalPointsValue2 = horizontalPointsValueIdentifier2.element(boundBy: 2)
        horizontalPointsValue2.tap()
        horizontalPointsValue2.typeText("50")
        
        let verticalPointsValueIdentifier2 = app.textFields.matching(identifier: "VerticalPointsValue")
        let verticalPointsValue2 = verticalPointsValueIdentifier2.element(boundBy: 2)
        verticalPointsValue2.tap()
        verticalPointsValue2.typeText("60")
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        XCTAssertEqual(10, onChangeResultValue().valueElements?[0].points?[0].x)
        XCTAssertEqual(30, onChangeResultValue().valueElements?[0].points?[0].y)
        XCTAssertEqual(20, onChangeResultValue().valueElements?[0].points?[1].x)
        XCTAssertEqual(40, onChangeResultValue().valueElements?[0].points?[1].y)
        XCTAssertEqual(50, onChangeResultValue().valueElements?[0].points?[2].x)
        XCTAssertEqual(60, onChangeResultValue().valueElements?[0].points?[2].y)
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

extension ValueUnion {
    var xTitle: String? {
        return (self.dictionary as! [String: Any])["xTitle"] as? String
    }
    
    var yTitle: String? {
        return (self.dictionary as! [String: Any])["yTitle"] as? String
    }
    
    var yMin: Double? {
        return (self.dictionary as! [String: Any])["yMin"] as? Double
    }
    
    var yMax: Double? {
        return (self.dictionary as! [String: Any])["yMax"] as? Double
    }
    
    var xMin: Double? {
        return (self.dictionary as! [String: Any])["xMin"] as? Double
    }
    
    var xMax: Double? {
        return (self.dictionary as! [String: Any])["xMax"] as? Double
    }
}

