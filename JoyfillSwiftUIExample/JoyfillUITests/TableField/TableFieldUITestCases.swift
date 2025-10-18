//
//  TableFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 15/07/25.
//

import XCTest
import JoyfillModel

final class TableFieldUITestCases: JoyfillUITestsBaseClass {
    
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "TableFieldTestData"
    }
    
    func goToTableDetailPage() {
        app.buttons["TableDetailViewIdentifier"].firstMatch.tap()
    }
    
    func tapOnMoreButton() {
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"]
        selectallbuttonImage.tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
    }
    
    func tapOnTextFieldColumn() {
        let textFieldColumnTitleButton = app.images.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
        textFieldColumnTitleButton.tap()
    }
    
    func tapOnDropdownFieldColumn() {
        let dropdownFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 1)
        dropdownFieldColumnTitleButton.tap()
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func checkSearchTextFieldFilterData() {
        // Check field text data after search
        let checkSearchDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("AB", checkSearchDataOnFirstTextField.value as! String)
        
        let checkSearchDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("CD", checkSearchDataOnSecondTextField.value as! String)
        
        // Check dropdown data after search
        let checkSearchDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSearchDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSearchDataOnSecondDropdownField.element(boundBy: 1).label)
    }
    
    func tapOnSearchBarTextField() {
        let searchBarTextField = app.textFields["TextFieldSearchBarIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("a\n")
    }
    
    
    func testEditAllRows() throws {
        goToTableDetailPage()
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.typeText("Edit")
        
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        
        let valueElements = onChangeResultValue().valueElements
        XCTAssertNotNil(valueElements, "Value elements should not be nil")
        
        guard let rows = valueElements else {
            XCTFail("Value elements are nil")
            return
        }
        
        let rowCount = rows.count
        XCTAssertGreaterThan(rowCount, 0, "Should have at least one row")
        
        // Verify all rows have the updated text and dropdown values
        for i in 0..<rowCount {
            if i == 2 { continue }
            
            let textValue = rows[i].cells?["687478ee0b423b73bb24cafa"]?.text
            XCTAssertEqual(textValue, "Edit", "Row \(i+1) text field should be 'Edit'")
            
            let dropdownValue = rows[i].cells?["6875f786e39a025afbe7d481"]?.text
            XCTAssertEqual(dropdownValue, "6875f7865f5cc15caa852f92", "Row \(i+1) dropdown should be '6875f7865f5cc15caa852f92' (Yes)")
        }
        
        goToTableDetailPage()
        
        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for i in 0..<min(rowCount, 10) {
            let textField = textFields.element(boundBy: i)
            if textField.exists {
                XCTAssertEqual("Edit", textField.value as! String, "The text in UI field \(i+1) is incorrect")
            }
        }
        
        let buttons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        for i in 0..<min(rowCount, 10) {
            let button = buttons.element(boundBy: i)
            if button.exists {
                XCTAssertEqual(button.label, "Yes", "The dropdown label on button \(i+1) is incorrect")
            }
        }
    }
    
    
    func testAddRowAfterSearchFilterVisibleAtLast() throws {
        goToTableDetailPage()
        tapOnTextFieldColumn()
        tapOnSearchBarTextField()
        app.buttons["TableAddRowIdentifier"].tap()
        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        let last = textFields.count - 1
        XCTAssertTrue(textFields.element(boundBy: last).exists)
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "6875c7c5e988bf485f897df6")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_6875c7ccc7953a86420924d9")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "6875c7ccc68951e6aff6ebea")
        XCTAssertEqual(payload["fileId"] as? String, "66a14ced9dc829a95e272506")
        XCTAssertEqual(payload["target"] as? String, "field.value.rowCreate")
        XCTAssertEqual(payload["identifier"] as? String, "template_6849dbb509ede5510725c910")
        XCTAssertEqual(payload["_id"] as? String, "66a14cedd6e1ebcdf176a8da")
        XCTAssertEqual(payload["sdk"] as? String, "swift")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        guard let change = payload["change"] as? [String: Any] else {
            return XCTFail("Missing or invalid 'change' dictionary")
        }
        XCTAssertEqual(change["targetRowIndex"] as? Int, 6)
        
        // row
        guard let row = change["row"] as? [String: Any] else {
            return XCTFail("Missing or invalid 'row' dictionary")
        } 
        
        // cells
        guard let cells = row["cells"] as? [String: Any] else {
            return XCTFail("Missing or invalid 'cells' dictionary")
        }
        XCTAssertEqual(cells["687478ee0b423b73bb24cafa"] as? String, "a")
    }
    
    
    func testTableDifferentDataTypesRenderWithoutCrash() throws {
        goToTableDetailPage()
        let textCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textCell.exists)
        
        let textCell1 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertTrue(textCell1.exists)
        
        let textCell2 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertTrue(textCell2.exists)
        
        let textCell3 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertTrue(textCell3.exists)
        
        let textCell4 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertTrue(textCell4.exists)
        
        let textCell5 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
        XCTAssertTrue(textCell5.exists)
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    func testRequiredFieldAsteriskPresence() {
        let requiredLabel = app.staticTexts["This is first\ntable with multiline header\ntext."]
        XCTAssertTrue(requiredLabel.exists, "Required field label should display")
        
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")
        
        // Enter value and ensure asterisk still remains
        goToTableDetailPage()
        let textCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(textCell.exists)
        textCell.tap()
        textCell.typeText("Hello test")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    // Verifies various field headers
    func testFieldHeaderRendering() {
        let firstTable = app.staticTexts["This is first\ntable with multiline header\ntext."]
        XCTAssertTrue(firstTable.exists)
        
        let secondTable = app.staticTexts["Second Table"]
        XCTAssertTrue(secondTable.exists)
        app.swipeUp()
        XCTAssertTrue(app.buttons.matching(identifier: "TableDetailViewIdentifier").element(boundBy: 2).exists)
    }
    
    
    func testReadonlyShouldNotEdit() {
        app.swipeUp()
        app.buttons.matching(identifier: "TableDetailViewIdentifier").element(boundBy: 2).tap()
        let checkBox = app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0)
        XCTAssertTrue(checkBox.waitForNonExistence(timeout: 2))
        let moreButton = app.buttons["TableMoreButtonIdentifier"].firstMatch
        XCTAssertTrue(moreButton.waitForNonExistence(timeout: 2))
        
        let addRowButton = app.buttons["TableAddRowIdentifier"].firstMatch
        XCTAssertFalse(addRowButton.isEnabled)
        addRowButton.tap()
        addRowButton.tap()
        let cells = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly")
        XCTAssertEqual(cells.count, 2)
        
        let textField = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").element(boundBy: 0)
        XCTAssertFalse(textField.isEnabled)
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier").firstMatch
        XCTAssertFalse(dropdownButtons.isEnabled)
        
        let multiSelectButton = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier").firstMatch
        XCTAssertFalse(multiSelectButton.isEnabled)
        
        let imageButton = app.buttons.matching(identifier: "TableImageIdentifier").firstMatch
        XCTAssertFalse(imageButton.isEnabled)
        app.swipeLeft()
        
        let numberField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").firstMatch
        XCTAssertFalse(numberField.isEnabled)
        numberField.tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        app.swipeLeft()
        let barcodeField = app.staticTexts.matching(identifier: "TableBarcodeFieldIdentifierReadonly").firstMatch
        XCTAssertFalse(barcodeField.isEnabled)
        barcodeField.tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        
        let signatureButton = app.buttons.matching(identifier: "TableSignatureOpenSheetButton").firstMatch
        XCTAssertFalse(signatureButton.isEnabled)
    }
    
    func testCopyPasteDataInColumn() throws {
        goToTableDetailPage()
        tapOnTextFieldColumn()
        let firstCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
        firstCell.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        app.menuItems["Copy"].tap()
        let secondCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        secondCell.tap()
        secondCell.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        app.menuItems["Paste"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(secondCell.value as? String, firstCell.value as? String)
    }
    
    func testColumnOnFocusAndOnBlur() throws {
        goToTableDetailPage()
        tapOnTextFieldColumn()
        let firstCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()
        if UIDevice.current.userInterfaceIdiom != .pad {
            let keyboard = app.keyboards.element
            XCTAssertTrue(keyboard.waitForExistence(timeout: 5),
                          "Keyboard should appear on focus")
            app.otherElements.firstMatch.tap() // dismiss
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            XCTAssertTrue(app.keyboards.element.exists, "Keyboard should appear on blur")
        }
    }
    
//    func testInsertDataThenScroll() throws {
//        goToTableDetailPage()
//        tapOnTextFieldColumn()
//        let cells = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        let initialCount = cells.count
//        app.buttons["TableAddRowIdentifier"].tap()
//        let newCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: initialCount)
//        XCTAssertTrue(newCell.waitForExistence(timeout: 5), "New row should appear at the end")
//        newCell.tap()
//        app.selectAllInTextField(in: newCell, app: app)
//        newCell.typeText("one")
//        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
//        while !newCell.isHittable {
//            app.swipeUp()
//        }
//        XCTAssertEqual(newCell.value as? String, "one")
//    }
    
    func testTableMoveUpRow() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        let moveDownButton = app.buttons["TableMoveDownRowIdentifier"]
        XCTAssertTrue(moveDownButton.exists, "Move Down button should be present")
        XCTAssertTrue(moveDownButton.isEnabled, "Move Down button should be disabled when the last row is selected")
        
        let moveUpButton = app.buttons["TableMoveUpRowIdentifier"]
        XCTAssertTrue(moveUpButton.exists, "Move Down button should be present")
        XCTAssertFalse(moveUpButton.isEnabled, "Move Down button should be disabled when the last row is selected")
        
        // check move row data - remains same or not - in this case it remain same
        let checkMovedRowTextField = app.textViews.firstMatch
        XCTAssertEqual("AB", checkMovedRowTextField.value as! String)
        
        
    }
    
    func testHideTableByTextField() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 1)
        originalPageButton.tap()
        
        let tableDetailButton = app.buttons["TableDetailViewIdentifier"].firstMatch
        XCTAssertTrue(tableDetailButton.exists)
        
        let textField = app.textFields.element(boundBy: 0)
        XCTAssert(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.clearText()
        textField.typeText("hide")
        XCTAssertFalse(tableDetailButton.exists)
        
        textField.tap()
        textField.clearText()
        textField.typeText("show")
        XCTAssertTrue(tableDetailButton.exists)
    }
    
    func testCheckQuickViewValueUpdate() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 2)
        originalPageButton.tap()
        
        let tableDetailButton = app.buttons.matching(identifier: "TableDetailViewIdentifier")
        tableDetailButton.element(boundBy: 0).tap()
        
        let textField = app.textViews.element(boundBy: 0)
        XCTAssert(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.press(forDuration: 1.0)
        let selectAll = app.menuItems["Select All"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5),"‘Select All’ menu didn’t show up")
        selectAll.tap()
        textField.typeText("one")
        
        let dropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        dropdownField.element(boundBy: 0).tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        let multiselectField = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        multiselectField.element(boundBy: 0).tap()
        
        let multiValueOptions = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        multiValueOptions.element(boundBy: 0).tap()
        multiValueOptions.element(boundBy: 1).tap()
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        goBack()
        let button = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier").firstMatch
        XCTAssertEqual(button.label , "Option 2")
        
        let staticText = app.staticTexts.matching(identifier: "TableTextFieldIdentifierReadonly").firstMatch
        XCTAssertEqual(staticText.label , "one")
        
        let dropdownText = app.staticTexts["Yes"].firstMatch
        XCTAssertEqual(dropdownText.label , "Yes")
        
        tableDetailButton.element(boundBy: 1).tap()
        
        let imageButton = app.buttons.matching(identifier: "TableImageIdentifier").firstMatch
        imageButton.tap()
        let uploadMoreButton = app.buttons.matching(identifier: "ImageUploadImageIdentifier").element(boundBy: 0)
        uploadMoreButton.tap()
        uploadMoreButton.tap()
        dismissSheet()
        
        let numberField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").firstMatch
        numberField.tap()
        numberField.clearText()
        numberField.typeText("123456");
        app.swipeLeft()
        let dateField = app.buttons["October 17, 2025"].firstMatch
        dateField.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "10")
        dismissSheet()
        goBack()
        
        let imageText = app.staticTexts["+1"].firstMatch
        XCTAssertTrue(imageText.exists)
        
        let numberText = app.staticTexts["123456"].firstMatch
        XCTAssertTrue(numberText.exists)
        
        let dateText = app.staticTexts["October 10, 2025"].firstMatch
        XCTAssertTrue(dateText.exists)
        
        app.swipeUp()
        tableDetailButton.element(boundBy: 2).tap()
        app.swipeLeft()
        
        let barcodeField = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        XCTAssert(barcodeField.waitForExistence(timeout: 5))
        barcodeField.tap()
        barcodeField.press(forDuration: 1.0)
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5),"‘Select All’ menu didn’t show up")
        selectAll.tap()
        barcodeField.typeText("code")
        
        let signatureButton = app.buttons.matching(identifier: "TableSignatureOpenSheetButton").firstMatch
        signatureButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        
        goBack()
        
        let blockText = app.staticTexts["quick"].firstMatch
        XCTAssertTrue(blockText.exists)
        
        let barcodeText = app.staticTexts["code"].firstMatch
        XCTAssertTrue(barcodeText.exists)
        
        let signatureText = app.staticTexts["Signature Column"].firstMatch
        XCTAssertTrue(signatureText.exists)
    }
    
    func drawSignatureLine() {
        let canvas = app.otherElements["CanvasIdentifier"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5))
        canvas.tap()
        let startPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let endPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
    
    private func formattedAccessibilityLabel(for isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US")
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: isoDate) else {
            XCTFail("Invalid date string: \(isoDate)")
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US")
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: with comma
            if #available(iOS 19.0, *) {
                outputFormatter.dateFormat = "EEEE, d MMMM"
            } else {
                outputFormatter.dateFormat = "EEEE d MMMM"
            }
        } else {
            // iPhone: no comma
            if #available(iOS 26.0, *) {
                outputFormatter.dateFormat = "EEEE, d MMMM"
            } else {
                outputFormatter.dateFormat = "EEEE d MMMM"
            }
        }
        return outputFormatter.string(from: date)
    }
}
