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
        var newRowID = ""
        do {
            let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
            let newRow = try XCTUnwrap(value["row"] as? [String: Any])
            XCTAssertNotNil(newRow["_id"])
            newRowID = newRow["_id"] as! String
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
}
