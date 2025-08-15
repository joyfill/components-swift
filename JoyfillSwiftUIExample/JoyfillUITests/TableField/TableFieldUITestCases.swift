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
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
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
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("Edit")
        
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for i in 0..<5 {
            let textField = textFields.element(boundBy: i)
            XCTAssertEqual("Edit", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
        
        let buttons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        for i in 0..<5 {
            let button = buttons.element(boundBy: i)
            XCTAssertTrue(button.exists)
            XCTAssertEqual(button.label, "Yes", "The text on button \(i+1) is incorrect")
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
        sleep(1)
        
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
        app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0).tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
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
        sleep(1)
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
    
    func testInsertDataThenScroll() throws {
        goToTableDetailPage()
        tapOnTextFieldColumn()
        let cells = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        let initialCount = cells.count
        app.buttons["TableAddRowIdentifier"].tap()
        let newCell = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: initialCount)
        XCTAssertTrue(newCell.waitForExistence(timeout: 5), "New row should appear at the end")
        newCell.tap()
        app.selectAllInTextField(in: newCell, app: app)
        newCell.typeText("one")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        while !newCell.isHittable {
            app.swipeUp()
        }
        XCTAssertEqual(newCell.value as? String, "one")
    }
    
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
}
