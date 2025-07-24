//
//  CollectionFieldTests.swift
//  JoyfillUITests
//
//  Created by Vivek on 23/04/25.
//

import XCTest
import JoyfillModel

final class CollectionFieldTests: JoyfillUITestsBaseClass {
    
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "Joydocjson"
    }
    
    func goToCollectionDetailField() {
        navigateToCollectionOn10thPage()
        sleep(1)
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func navigateToCollectionOn10thPage() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        app.swipeUp()
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 10)
        tapOnSecondPage.tap()
        
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 0)
        tapOnSecondTableView.tap()
    }
    
    func expandRow(number: Int) {
        sleep(1)
        let identifier = "CollectionExpandCollapseButton\(number)"
        
        guard let expandButton = app.swipeToFindElement(identifier: identifier,
                                                    type: .image,
                                                    direction: "up",
                                                    maxAttempts: 6) else {
            XCTFail("Failed to find expand/collapse button with identifier: \(identifier)")
            return
        }

        XCTAssertTrue(expandButton.isHittable, "Expand/collapse button is not hittable")
        expandButton.tap()
    }
    
    func tapSchemaAddRowButton(number: Int) {
        let buttons = app.buttons.matching(identifier: "collectionSchemaAddRowButton")
        XCTAssertTrue(buttons.count > 0)
        buttons.element(boundBy: number).tap()
    }
    
    fileprivate func selectAllMultiSlectOptions() {
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
    }
    
    func moveUpButton() -> XCUIElement {
        return app.buttons["TableMoveUpRowIdentifier"]
    }
    
    func moveDownButton() -> XCUIElement {
        return app.buttons["TableMoveDownRowIdentifier"]
    }
    func inserRowBelowButton() -> XCUIElement {
        return app.buttons["TableInsertRowIdentifier"]
    }
    
    func editRowsButton() -> XCUIElement {
        return app.buttons["TableEditRowsIdentifier"]
    }
    
    func editSingleRowUpperButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["UpperRowButtonIdentifier"]
    }
    
    func editSingleRowLowerButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["LowerRowButtonIdentifier"]
    }
    
    func editInsertRowPlusButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["PlusTheRowButtonIdentifier"]
    }
    
    func deleteRowButton() -> XCUIElement {
        return app.buttons["TableDeleteRowIdentifier"]
    }
    
    func selectRow(number: Int) {
        //select the row with number as index
        app.images.matching(identifier: "selectRowItem\(number)")
            .element.tap()
    }
    
    func selectNestedRow(number: Int) {
        app.images.matching(identifier: "selectNestedRowItem\(number)")
            .element.tap()
    }
    
    fileprivate func tapOnMoreButton() {
        //tap more icon
        app.buttons["TableMoreButtonIdentifier"].tap()
    }
    
    func tapOnCrossButton() {
        app.buttons.matching(identifier: "DismissEditSingleRowSheetButtonIdentifier").element.tap()
    }
    
    func selectAllNestedRows() {
        app.images.matching(identifier: "selectAllNestedRows")
            .element.tap()
    }
    
    func selectAllParentRows() {
        app.images.matching(identifier: "SelectParentAllRowSelectorButton")
            .element.tap()
    }
    
    func addThreeNestedRows(parentRowNumber: Int) {
        goToCollectionDetailField()
        sleep(1)
        expandRow(number: parentRowNumber)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        let firstNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("", firstNestedTextField.value as! String)
        firstNestedTextField.tap()
        firstNestedTextField.typeText("Hello ji")
        
        let secNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("", secNestedTextField.value as! String)
        secNestedTextField.tap()
        secNestedTextField.typeText("Namaste ji")
        
        let thirdNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("", thirdNestedTextField.value as! String)
        thirdNestedTextField.tap()
        thirdNestedTextField.typeText("123456789")
    }
    
    func openFilterModalForDismissKeyboard() {
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        if !filterButton.exists {
            XCTFail("Filter button should exist")
        }
        
        filterButton.tap()
        
        // Verify filter modal opened
        let filterModalExists = app.staticTexts["Filter"].exists
        XCTAssertTrue(filterModalExists, "Filter modal should be open")
        
        dismissSheet()
    }
    
    func testCollectionFieldTextFields() {
        goToCollectionDetailField()
                    
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", firstTableTextField.value as! String)
        firstTableTextField.waitAndClearAndTypeText("First")
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertTrue(secondTableTextField.waitForExistence(timeout: 5), "Second table text field not found")
        XCTAssertEqual("His", secondTableTextField.value as! String)
        secondTableTextField.waitAndClearAndTypeText("Second")
        
        
        goBack()
        sleep(2)
        do {
            let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b644fd938fd8ed7fe2e1"]?.text)
            let secondCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["6805b644fd938fd8ed7fe2e1"]?.text)
            XCTAssertEqual("FirstHello", firstCellTextValue)
            XCTAssertEqual("SecondHis", secondCellTextValue)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
        
        
        // Navigate to signature detail view - then go to table detail view - to check recently enterd data is saved or not in table
        app.buttons["SignatureIdentifier"].waitAndTap()
        app.waitForNavigation()
        goBack()
        
        goToCollectionDetailField()
        XCTAssertEqual("FirstHello", firstTableTextField.value as! String)
        XCTAssertEqual("SecondHis", secondTableTextField.value as! String)
    }
    
    func testTableDropdownOption() throws {
        goToCollectionDetailField()
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("High", dropdownButtons.element(boundBy: 0).label)
        XCTAssertEqual("Medium", dropdownButtons.element(boundBy: 1).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        goBack()
        sleep(2)
        let firstCellDropdownValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b6442f2e0c095a07aebb"]?.text)
        XCTAssertEqual("6805b6443944fc0166ba80a0", firstCellDropdownValue)
    }

    func testExpandFirstRow() {
        //Expand the first row and add row and edit the text field
        goToCollectionDetailField()
        //expand both rows
        expandRow(number: 1)
        expandRow(number: 2)
        
        //Tap on add row
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 1)
        
        //Assert on added rows
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowCreate", fieldTarget)
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            let newRow = try XCTUnwrap(value["row"] as? [String: Any])
            XCTAssertNotNil(newRow["_id"])
            XCTAssertEqual(1, lastIndex)
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testExpandAndCloseRow() {
        goToCollectionDetailField()
        //expand both rows
        expandRow(number: 1)
        expandRow(number: 2)
        expandRow(number: 1)
        expandRow(number: 2)
    }
    
    func testExpandAndAddRowAndEditFirstCellCloseAndCheckVAlue() {
        goToCollectionDetailField()
        expandRow(number: 1)
        
        tapSchemaAddRowButton(number: 0)
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let newRow = try XCTUnwrap(value["row"] as? [String: Any])
            XCTAssertNotNil(newRow["_id"])
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
        
        
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("Hello ji")
        goBack()
        sleep(2)
        goToCollectionDetailField()
        expandRow(number: 1)
        do {
            let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7c2dae7987557c0b602"]?.text)
            XCTAssertEqual("Hello ji", firstCellTextValue)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
    }
    
    func testCollectionFieldMultiSlect() {
        goToCollectionDetailField()
        
        let app = XCUIApplication()
        //let element4 = app.windows.children(matching: .other).element
        //        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        //        element.swipeLeft()
        
        guard let firstButton = app.swipeToFindElement(identifier: "TableMultiSelectionFieldIdentifier", type: .button, direction: "left") else {
            XCTFail("Failed to find multiselect button after swiping")
            return
        }
        firstButton.tap()
        
        selectAllMultiSlectOptions()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        //        element.swipeRight()
        goBack()
        sleep(2)
        do {
            let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b771ab52db07a211a2f6"]?.stringArray)
            XCTAssertEqual(["6805b771d4f71eb6c061e494", "6805b7719a178ac79ef6e871", "6805b77130c78af8dcbbac21"], firstCellMultiSelectValue)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
    }
    
    func testCollectionFieldImage() {
        goToCollectionDetailField()
        
        let app = XCUIApplication()
        //let element4 = app.windows.children(matching: .other).element
        //        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        //        element.swipeLeft()
        
        guard let firstButton = app.swipeToFindElement(identifier: "TableImageIdentifier", type: .button, direction: "left") else {
            XCTFail("Failed to find  button after swiping")
            return
        }
        firstButton.tap()
        
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        
        //        element.swipeDown()
        dismissSheet()
        goBack()
        sleep(2)
        do {
            let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b644fb566d50704a9e2c"]?.valueElements)
            XCTAssertEqual(3, firstCellMultiSelectValue.count)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
    }
    
    func testCollectionFieldNumber() {
        goToCollectionDetailField()
        
        let app = XCUIApplication()
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.exists, "ScrollView not found")
        //let element4 = app.windows.children(matching: .other).element
        //        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        //        element.swipeLeft()
        
        
        if let textField = app.swipeToFindElement(identifier: "TabelNumberFieldIdentifier", type: .textField, direction: "left") {
            textField.tap()
            textField.typeText("123456")
        }
        
        goBack()
        sleep(2)
        do {
            let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b7796ac9ce35b30e9b7c"]?.number)
            XCTAssertEqual(123456, firstCellMultiSelectValue)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
    }
    
    func testCollectionFieldDate() {
        goToCollectionDetailField()
        
        let app = XCUIApplication()
        //        let element4 = app.windows.children(matching: .other).element
        //        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        //        element.swipeLeft()
        
        if let firstCollectionDateField = app.swipeToFindElement(identifier: "CalendarImageIdentifier", type: .image, direction: "left") {
            firstCollectionDateField.tap()
        }
        
        let datePickers = app.datePickers
        XCTAssertTrue(datePickers.element.exists)
        
        //        element.swipeRight()
        goBack()
        sleep(2)
        
        do {
            let firstCellDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b77fc568df7b031590dc"]?.number)
            XCTAssertNotNil(firstCellDateValue)
        } catch {
            XCTFail("Failed to unwrap cell date value: \(error)")
        }
    }
        
    func testMoveUpState() {
        goToCollectionDetailField()
        //select 1st row
        selectRow(number: 1)
        
        tapOnMoreButton()
        
        XCTAssertEqual(moveUpButton().isEnabled, false)
        
        XCTAssertEqual(moveDownButton().isEnabled, true)
    }
    
    func testMoveDownState() {
        goToCollectionDetailField()
        //select last row
        selectRow(number: 2)
        
        tapOnMoreButton()
                
        XCTAssertEqual(moveUpButton().isEnabled, true)
        
        XCTAssertEqual(moveDownButton().isEnabled, false)
    }
    
    func testMoveUpAndMoveDownButtonAvailableOrNot() {
        goToCollectionDetailField()
        selectRow(number: 1)
        tapOnMoreButton()
        
        XCTAssertEqual(moveUpButton().exists, true)
        XCTAssertEqual(moveDownButton().exists, true)
        XCTAssertEqual(inserRowBelowButton().exists, true)
    }
    
    func testMoveUpAndMoveDownButtonAvailableOrNotOnMultipleRows() {
        goToCollectionDetailField()
        selectRow(number: 1)
        selectRow(number: 2)
        tapOnMoreButton()
        
        XCTAssertEqual(moveUpButton().exists, false)
        XCTAssertEqual(moveDownButton().exists, false)
        XCTAssertEqual(inserRowBelowButton().exists, false)
    }
    
    func testInsertBelow() {
        goToCollectionDetailField()
        selectRow(number: 1)
        tapOnMoreButton()
        
        inserRowBelowButton().tap()
        
        goBack()
        sleep(2)
        
        XCTAssertEqual(onChangeResultValue().valueElements?.count, 3)
        XCTAssertNotNil(onChangeResultValue().valueElements?[2].id)
        
        goToCollectionDetailField()
        
        selectRow(number: 2)
        tapOnMoreButton()
        XCTAssertEqual(moveUpButton().isEnabled, true)
        XCTAssertEqual(moveDownButton().isEnabled, true)
    }
    
    func testMoveUpRow() {
        goToCollectionDetailField()
        selectRow(number: 2)
        tapOnMoreButton()
        moveUpButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowMove", fieldTarget)
        
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let rowIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            XCTAssertEqual(0, rowIndex)
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
        
        goBack()
        sleep(2)
        XCTAssertEqual(onChangeResultValue().valueElements?.count , 2)
        XCTAssertEqual(onChangeResultValue().valueElements?[0].cells?["6805b644fd938fd8ed7fe2e1"]?.text , "His")
        
    }
    
    func testMoveDownRow() {
        goToCollectionDetailField()
        selectRow(number: 1)
        tapOnMoreButton()
        moveDownButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowMove", fieldTarget)
        
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let rowIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            XCTAssertEqual(1, rowIndex)
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
        
        goBack()
        sleep(2)
        XCTAssertEqual(onChangeResultValue().valueElements?.count , 2)
        XCTAssertEqual(onChangeResultValue().valueElements?[1].cells?["6805b644fd938fd8ed7fe2e1"]?.text, "Hello")
    }
       
    func testMoveUpOnNestedRow() {
        addThreeNestedRows(parentRowNumber: 1)
        
        selectNestedRow(number: 2)
        tapOnMoreButton()
        
        moveUpButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowMove", fieldTarget)
        
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let rowIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            XCTAssertEqual(0, rowIndex)
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
        
        goBack()
        sleep(2)
        
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?.count, 3)
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7c2dae7987557c0b602"]?.text , "Namaste ji")
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[1].cells?["6805b7c2dae7987557c0b602"]?.text , "Hello ji")
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[2].cells?["6805b7c2dae7987557c0b602"]?.text , "123456789")
    }
    
    func testMoveDownOnNestedRow() {
        addThreeNestedRows(parentRowNumber: 1)
        
        selectNestedRow(number: 2)
        tapOnMoreButton()
        
        moveDownButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowMove", fieldTarget)
        
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let rowIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            XCTAssertEqual(2, rowIndex)
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
        
        goBack()
        sleep(2)
        
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?.count, 3)
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7c2dae7987557c0b602"]?.text , "Hello ji")
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[1].cells?["6805b7c2dae7987557c0b602"]?.text , "123456789")
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[2].cells?["6805b7c2dae7987557c0b602"]?.text , "Namaste ji")
    }
    
    func testDeleteAllOnNestedRow() {
        addThreeNestedRows(parentRowNumber: 1)
        
        selectAllNestedRows()
        tapOnMoreButton()
        
        deleteRowButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowDelete", fieldTarget)
        
        goBack()
        sleep(2)
        
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?.count, nil)
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?.filter({ $0.deleted ?? false }).count, nil)

    }
    
    func testDeleteOnNestedRow() {
        addThreeNestedRows(parentRowNumber: 1)
        
        selectNestedRow(number: 1)
        tapOnMoreButton()
        
        deleteRowButton().tap()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowDelete", fieldTarget)
        
        goBack()
        sleep(2)
        
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?.count, 2)
    }
    
    func drawSignatureLine() {
        let canvas = app.otherElements["CanvasIdentifier"]
        canvas.tap()
        let startPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let endPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
    
    // Edit All Parent Rows
    func testEditBulkRow() throws {
        goToCollectionDetailField()
        selectAllParentRows()
        
        tapOnMoreButton()
        editRowsButton().tap()
        
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        sleep(1)
        textField.tap()
        textField.typeText("Edit")
        app.dismissKeyboardIfVisible()
        
        // Dropdown Field
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertTrue(dropdownButton.waitForExistence(timeout: 3), "Dropdown button not found")
        dropdownButton.tap()

        // Wait for options to appear
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")

        let timeout = 5.0
        let start = Date()
        while dropdownOptions.count == 0 && Date().timeIntervalSince(start) < timeout {
            sleep(1)
        }

        XCTAssertGreaterThan(dropdownOptions.count, 0, "Dropdown options did not appear")
        let firstOption = dropdownOptions.element(boundBy: 0)
        XCTAssertTrue(firstOption.exists && firstOption.isHittable, "Dropdown option is not tappable")
        firstOption.tap()
        
        // Multiselection Field
        let multiSelectionButton = app.buttons["EditRowsMultiSelecionFieldIdentifier"]
        //XCTAssertEqual("", multiSelectionButton.label)
        multiSelectionButton.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        //XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        
        
        // Image Field
        guard let firstImageButton = app.swipeToFindElement(identifier: "EditRowsImageFieldIdentifier", type: .button) else {
            XCTFail("Failed to find image button after swiping")
            return
        }
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        
        guard let dateField = app.swipeToFindElement(identifier: "EditRowsDateFieldIdentifier", type: .image) else {
            XCTFail("Failed to find date button after swiping")
            return
        }
        dateField.tap()
        
        
        // Barcode Column
        guard let barcodeTextField = app.swipeToFindElement(identifier: "EditRowsBarcodeFieldIdentifier", type: .textView) else {
            XCTFail("Failed to find barcode field after swiping")
            return
        }
        barcodeTextField.tap()
        barcodeTextField.clearText()
        barcodeTextField.typeText("quick")
        
        // Number Field
        guard let numberTextField = app.swipeToFindElement(identifier: "EditRowsNumberFieldIdentifier", type: .textField) else {
            XCTFail("Failed to find number text field after swiping")
            return
        }
        numberTextField.tap()
        numberTextField.clearText()
        numberTextField.typeText("12345")
        app.dismissKeyboardIfVisible()
        
        // Signature Column
        let signatureButtons = app.buttons.matching(identifier: "EditRowsSignatureFieldIdentifier")
        let firstSignatureButton = signatureButtons.element(boundBy: 0)
        firstSignatureButton.tap()
        
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        
        // Tap on Apply All Button
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        goBack()
        sleep(2)
        
        // Textfield
        let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b644fd938fd8ed7fe2e1"]?.text)
        let secondCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["6805b644fd938fd8ed7fe2e1"]?.text)
        XCTAssertEqual("Edit", firstCellTextValue)
        XCTAssertEqual("Edit", secondCellTextValue)
        
        // Dropdown Field
        let firstCellDropdownValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b6442f2e0c095a07aebb"]?.text)
        XCTAssertEqual("6805b644125b5d4c3832603b", firstCellDropdownValue)
        
        // Multiselect Column
        let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b771ab52db07a211a2f6"]?.stringArray)
        XCTAssertEqual(["6805b771d4f71eb6c061e494", "6805b7719a178ac79ef6e871", "6805b77130c78af8dcbbac21"], firstCellMultiSelectValue)
        
        // Image Field
        let firstCellImageValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b644fb566d50704a9e2c"]?.valueElements)
        XCTAssertEqual(1, firstCellImageValue.count)
        
        // Number Field
        let firstCellNumberValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b7796ac9ce35b30e9b7c"]?.number)
        XCTAssertEqual(12345, firstCellNumberValue)
        
        // Date Column
        let firstCellDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b77fc568df7b031590dc"]?.number)
        XCTAssertNotNil(firstCellDateValue)
        
        // Barcode Field
        let firstCellBarcodeTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b7a813ea45f5b681dec1"]?.text)
        XCTAssertEqual("quick", firstCellBarcodeTextValue)
        
        // Signature Field
        XCTAssertNotNil(onChangeResultValue().valueElements?[0].cells?["6805b7ac1325377829f4d92e"]?.text)
        
    }
    
    // Edit Single Parent Row
    func testEditSingleRow() throws {
        goToCollectionDetailField()
        //select 1st row
        selectRow(number: 1)
        
        tapOnMoreButton()
        editRowsButton().tap()
        sleep(2)
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, false)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, true)
        
        let firstRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", firstRowTextField.value as! String)
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("High", dropdownButtons.element(boundBy: 0).label)
        
        editSingleRowLowerButton().tap()
        sleep(2)
        let secondRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("His", secondRowTextField.value as! String)
        XCTAssertEqual("Medium", dropdownButtons.element(boundBy: 1).label)
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        
        editInsertRowPlusButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        textField.tap()
        textField.typeText("Edit")
        app.dismissKeyboardIfVisible()
        
        // Dropdown Field
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertTrue(dropdownButton.waitForExistence(timeout: 3), "Dropdown button not found")
        dropdownButton.tap()

        // Wait for options to appear
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")

        let timeout = 5.0
        let start = Date()
        while dropdownOptions.count == 0 && Date().timeIntervalSince(start) < timeout {
            sleep(1)
        }

        XCTAssertGreaterThan(dropdownOptions.count, 0, "Dropdown options did not appear")
        let firstOption = dropdownOptions.element(boundBy: 0)
        XCTAssertTrue(firstOption.exists && firstOption.isHittable, "Dropdown option is not tappable")
        firstOption.tap()
        
        // Multiselection Field
        let multiSelectionButton = app.buttons["EditRowsMultiSelecionFieldIdentifier"]
        //XCTAssertEqual("", multiSelectionButton.label)
        multiSelectionButton.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        //XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        // Image Field
        guard let firstImageButton = app.swipeToFindElement(identifier: "EditRowsImageFieldIdentifier", type: .button) else {
            XCTFail("Failed to find image button after swiping")
            return
        }
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        
        guard let dateField = app.swipeToFindElement(identifier: "EditRowsDateFieldIdentifier", type: .image) else {
            XCTFail("Failed to find date button after swiping")
            return
        }
        dateField.tap()
        
        // Number Field
        guard let numberTextField = app.swipeToFindElement(identifier: "EditRowsNumberFieldIdentifier", type: .textField) else {
            XCTFail("Failed to find number text field after swiping")
            return
        }
        numberTextField.tap()
        numberTextField.clearText()
        numberTextField.typeText("12345")
        firstImageButton.tap()
        dismissSheet()
         
        guard let barcodeTextField = app.swipeToFindElement(identifier: "EditRowsBarcodeFieldIdentifier", type: .textView) else {
            XCTFail("Failed to find barcode text field after swiping")
            return
        }
        barcodeTextField.tap()
        sleep(1)

        // Double tap if needed to ensure keyboard opens
        if !app.keyboards.element.exists {
            barcodeTextField.tap()
            sleep(1)
        }

        // Assert keyboard presence
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 2), "Keyboard did not appear for barcode field")

        // Clear and type
        if let textValue = barcodeTextField.value as? String {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: textValue.count + 5)
            barcodeTextField.typeText(deleteString)
        }
        barcodeTextField.typeText("Edit Barcode")
        
        // Signature Column
        let signatureButtons = app.buttons.matching(identifier: "EditRowsSignatureFieldIdentifier")
        let firstSignatureButton = signatureButtons.element(boundBy: 0)
        firstSignatureButton.tap()
        
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        
        dismissSheet()
        dismissSheet()
        
        goBack()
        sleep(2)
        // Textfield
        let thirdCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b644fd938fd8ed7fe2e1"]?.text)
        XCTAssertEqual("Edit", thirdCellTextValue)
        
        // Dropdown Field
        let firstCellDropdownValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b6442f2e0c095a07aebb"]?.text)
        XCTAssertEqual("6805b644125b5d4c3832603b", firstCellDropdownValue)
        
        // Multiselect Column
        let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b771ab52db07a211a2f6"]?.stringArray)
        XCTAssertEqual(["6805b771d4f71eb6c061e494", "6805b7719a178ac79ef6e871", "6805b77130c78af8dcbbac21"], firstCellMultiSelectValue)
        
        // Image Field
        let firstCellImageValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b644fb566d50704a9e2c"]?.valueElements)
        XCTAssertEqual(1, firstCellImageValue.count)
        
        // Number Field
        let firstCellNumberValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b7796ac9ce35b30e9b7c"]?.number)
        XCTAssertEqual(12345, firstCellNumberValue)
        
        // Date Column
        let firstCellDateValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b77fc568df7b031590dc"]?.number)
        XCTAssertNotNil(firstCellDateValue)
        
        // Barcode Field
        let firstCellBarcodeTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6805b7a813ea45f5b681dec1"]?.text)
        XCTAssertEqual("Edit Barcode", firstCellBarcodeTextValue)
        
        // Signature Field
        XCTAssertNotNil(onChangeResultValue().valueElements?[2].cells?["6805b7ac1325377829f4d92e"]?.text)
    }
    
    // Edit all Nested rows
    func testBulkEditNestedRows() throws {
        goToCollectionDetailField()
        
        expandRow(number: 1)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        selectAllNestedRows()
        tapOnMoreButton()
        editRowsButton().tap()
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("Edit")
        
        // Dropdown Field
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        // Multiselection Field
        let multiSelectionButton = app.buttons["EditRowsMultiSelecionFieldIdentifier"]
//        XCTAssertEqual("", multiSelectionButton.label)
        multiSelectionButton.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
//        XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        
        // Tap on Apply All Button
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        goBack()
        sleep(2)
        
        // Textfield
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7c2dae7987557c0b602"]?.text , "Edit")
        
        // Dropdown Field
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7cd4d3e63602cbc0790"]?.text , "6805b7cdd7e3afe29fc94b0c")
        
        // Multiselect Column
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7d26f17f6a05edeee14"]?.stringArray , ["6805b7d247dcd4e634ccf0a5", "6805b7d244d0a2e6bbb039fb", "6805b7d2b87da9ba35bd466a"])
    }
    
    // Test disabled buttons on row form of top level rows
    func testSelectOneTopLevelRow() throws {
        goToCollectionDetailField()
        expandRow(number: 1)
        expandRow(number: 2)
        selectRow(number: 1)
        
        tapOnMoreButton()
        editRowsButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, false)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, true)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
        //go to next row and test
        editSingleRowLowerButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
        
        //tap inssert below and test
        editInsertRowPlusButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
    }
    
    
    // Test disabled buttons on Row Form for nested rows
    func testSelectOneNestedRow() throws {
        addThreeNestedRows(parentRowNumber: 1)
        // Make sure collection search filter is on
        openFilterModalForDismissKeyboard()
        sleep(1)
        expandRow(number: 2)
        
        selectNestedRow(number: 1)
        
        tapOnMoreButton()
        editRowsButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, false)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, true)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
        //go to next row and test
        editSingleRowLowerButton().tap()
        editSingleRowLowerButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
        
        //tap inssert below and test
        editInsertRowPlusButton().tap()
        
        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
    }
    
    // Edit Single Nested Row
    func testEditSingleNestedRow() throws {
        addThreeNestedRows(parentRowNumber: 1)
        // Make sure collection search filter is on
        openFilterModalForDismissKeyboard()
        expandRow(number: 2)
        
        selectNestedRow(number: 1)
        
        tapOnMoreButton()
        editRowsButton().tap()
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("Edit")
        
        // Dropdown Field
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        // Multiselection Field
        let multiSelectionButton = app.buttons["EditRowsMultiSelecionFieldIdentifier"]
//        XCTAssertEqual("", multiSelectionButton.label)
        multiSelectionButton.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
//        XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        tapOnCrossButton()
        
        goBack()
        sleep(2)
        
        // Textfield
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7c2dae7987557c0b602"]?.text , "Hello jiEdit")
        
        // Dropdown Field
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7cd4d3e63602cbc0790"]?.text , "6805b7cdd7e3afe29fc94b0c")
        
        // Multiselect Column
        XCTAssertEqual(onChangeResultValue().valueElements?.first?.childrens?["6805b7c24343d7bcba916934"]?.valueToValueElements?[0].cells?["6805b7d26f17f6a05edeee14"]?.stringArray , ["6805b7d247dcd4e634ccf0a5", "6805b7d244d0a2e6bbb039fb", "6805b7d2b87da9ba35bd466a"])
    }
}

