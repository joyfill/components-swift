//
//  CollectionFieldTests.swift
//  JoyfillUITests
//
//  Created by Vivek on 23/04/25.
//

import XCTest
import JoyfillModel

final class CollectionFieldTests: JoyfillUITestsBaseClass {
    
    func goToCollectionDetailField() {
        navigateToCollectionOn10thPage()
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
        let expandButton = app.images["CollectionExpandCollapseButton\(number)"]
        XCTAssertTrue(expandButton.exists, "Expand/collapse button should exist")
        expandButton.tap()
    }
    
    func tapSchemaAddRowButton(number: Int) {
        let buttons = app.buttons.matching(identifier: "collectionSchemaAddRowButton")
        XCTAssertTrue(buttons.count > 0)
        buttons.element(boundBy: number).tap()
    }
    
    fileprivate func selectAllMultiSlectOptions(_ app: XCUIApplication) {
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
    
    func testCollectionFieldTextFields() {
        goToCollectionDetailField()
                    
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("His", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("Second")
        
        
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
        app.buttons["SignatureIdentifier"].tap()
        sleep(1)
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
        let element4 = app.windows.children(matching: .other).element
        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        element.swipeLeft()
        
        let multiSelectionButtons = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButtons.count, 0)
        let firstButton = multiSelectionButtons.element(boundBy: 0)
        firstButton.tap()
        
        selectAllMultiSlectOptions(app)

        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        element.swipeRight()
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
        let element4 = app.windows.children(matching: .other).element
        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        element.swipeLeft()
        
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(imageButtons.count, 0)
        let firstButton = imageButtons.element(boundBy: 0)
        firstButton.tap()
        
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        app.buttons["ImageUploadImageIdentifier"].tap()

        element.swipeDown()
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
        let element4 = app.windows.children(matching: .other).element
        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        element.swipeLeft()
        
        let firstCollectionNumberField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("", firstCollectionNumberField.value as! String)
        firstCollectionNumberField.tap()
        firstCollectionNumberField.typeText("1234567890123456")
        
        goBack()
        sleep(2)
        do {
            let firstCellMultiSelectValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6805b7796ac9ce35b30e9b7c"]?.number)
            XCTAssertEqual(1234567890123456, firstCellMultiSelectValue)
        } catch {
            XCTFail("Failed to unwrap cell text values: \(error)")
        }
    }
    
    func testCollectionFieldDate() {
        goToCollectionDetailField()
        
        let app = XCUIApplication()
        let element4 = app.windows.children(matching: .other).element
        let element = element4.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .scrollView).element(boundBy: 1).children(matching: .other).element.children(matching: .other).element
        element.swipeLeft()
        
        let firstCollectionDateField = app.images.matching(identifier: "CalendarImageIdentifier").element(boundBy: 0)
        firstCollectionDateField.tap()
        
        let datePickers = app.datePickers
        XCTAssertTrue(datePickers.element.exists)
        
        element.swipeRight()
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
        goToCollectionDetailField()
        expandRow(number: 1)
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
        goToCollectionDetailField()
        expandRow(number: 1)
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
    
}
