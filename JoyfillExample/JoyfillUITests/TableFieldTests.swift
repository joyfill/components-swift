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
    
    func navigateToTableViewOnSecondPage() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()

        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 1)
        tapOnSecondPage.tap()
        
        app.swipeUp()
        let goToTableDetailView = app.buttons.matching(identifier: "TableDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 1)
        tapOnSecondTableView.tap()
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
    }
    
    func testTableUploadImage() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        goBack()
    }
    
    // test case for - when image field is empty
    func testTableUploadImageOnSecondField() throws {
        goToTableDetailPage()
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        let firstImageButton = imageButtons.element(boundBy: 1)
        firstImageButton.tap()
        app.buttons["ImageUploadImageIdentifier"].tap()
        dismissSheet()
        goBack()
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
    }
    
    func testTableAddRow() throws {
        goToTableDetailPage()
        app.buttons["TableAddRowIdentifier"].tap()
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(3, lastIndex)
    }
    
    func testTableDeleteRow() throws {
        goToTableDetailPage()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(3, valueElements.count)
    }
    
    func testTableDuplicateRow() throws {
        goToTableDetailPage()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDuplicateRowIdentifier"].tap()
        
        let duplicateTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("His", duplicateTextField.value as! String)
        duplicateTextField.tap()
        duplicateTextField.typeText("Duplicate ")
        
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(3, lastIndex)
    }

    // Test when all row deleted, then add new row
    func testTableAddRowOnPageSecond() throws {
        navigateToTableViewOnSecondPage()
        
        app.buttons["TableAddRowIdentifier"].tap()
        app.buttons["TableAddRowIdentifier"].tap()
        goBack()
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(6, lastIndex)
    }
    
    func testDeleteAllRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoreButton()
        
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
    func testDuplicateAllRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoreButton()
        app.buttons["TableDuplicateRowIdentifier"].tap()
        
        // First Row Duplicate
        let duplicateFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("App 1", duplicateFirstTextField.value as! String)
        duplicateFirstTextField.tap()
        duplicateFirstTextField.typeText("Duplicate ")
        
        // Second Row Duplicate
        let duplicateSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("Apple 2", duplicateSecondTextField.value as! String)
        duplicateSecondTextField.tap()
        duplicateSecondTextField.typeText("Duplicate ")
        
        // Third Row Duplicate
        let duplicateThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
        XCTAssertEqual("Boy 3", duplicateThirdTextField.value as! String)
        duplicateThirdTextField.tap()
        duplicateThirdTextField.typeText("Duplicate ")
        
        // Fourth Row Duplicate
        let duplicateFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 7)
        XCTAssertEqual("Cat 4", duplicateFourthTextField.value as! String)
        duplicateFourthTextField.tap()
        duplicateFourthTextField.typeText("Duplicate ")
        
        // Fifth Row Duplicate
        let duplicateFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 9)
        XCTAssertEqual("Dog 5", duplicateFifthTextField.value as! String)
        duplicateFifthTextField.tap()
        duplicateFifthTextField.typeText("Duplicate ")
                
        for change in onChangeResultChanges() {
            let value = try XCTUnwrap(change.dictionary as? [String: Any])
            let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
            let newRow = try XCTUnwrap(value["row"] as? [String: Any])
            XCTAssertNotNil(newRow["_id"])
//            XCTAssertEqual(9, lastIndex)
        }
    }
    
    func testEditAllRows() throws {
        navigateToTableViewOnSecondPage()
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
    
    // Click on apply all button without enter any data - Check data changed or not
    func testEditAllRowsEnterNoData() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        sleep(1)
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        let textFieldValues = [
            "App 1",
            "Apple 2",
            "Boy 3",
            "Cat 4",
            "Dog 5"
        ]
        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for (index, textFieldValue) in textFieldValues.enumerated() {
            let textField = textFields.element(boundBy: index)
            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
        }
        
        let dropdownValueLabels = [
            "Yes",
            "No",
            "N/A",
            "Yes",
            "Select Option"
        ]
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
            let button = dropdownButtons.element(boundBy: index)
            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
        }
    }
    
    func testEditSingleRow() throws {
        navigateToTableViewOnSecondPage()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
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
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Edit", checkEditDataOnTextField.value as! String)
        
        sleep(1)
        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkEditDataOnDropdownField.element(boundBy: 0).label)
    }
    
    func testSearchFilterForTextField() throws {
        navigateToTableViewOnSecondPage()
        tapOnTextFieldColumn()
        
        let searchBarTextField = app.textFields["TextFieldSearchBarIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("app\n")
        
        // Check field text data after search
        let checkSearchDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1", checkSearchDataOnFirstTextField.value as! String)
        
        let checkSearchDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Apple 2", checkSearchDataOnSecondTextField.value as! String)
        
        // Check dropdown data after search
        let checkSearchDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSearchDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSearchDataOnSecondDropdownField.element(boundBy: 1).label)
    }
    
    func testSearchFilterForDropdownField() throws {
        navigateToTableViewOnSecondPage()
        tapOnDropdownFieldColumn()
        
        let dropdownButton = app.buttons["SearchBarDropdownIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        // Check field text data after search
        let checkSearchDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1", checkSearchDataOnFirstTextField.value as! String)
        
        let checkSearchDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Cat 4", checkSearchDataOnSecondTextField.value as! String)
        
        // Check dropdown data after search
        let checkSearchDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSearchDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnSecondDropdownField.element(boundBy: 1).label)
    }
    
    func checkDescendingOrderSortingDataOfTextfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Dog 5", checkSortDataOnFirstTextField.value as! String)
        
        let checkSortDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Cat 4", checkSortDataOnSecondTextField.value as! String)
        
        let checkSortDataOnThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Boy 3", checkSortDataOnThirdTextField.value as! String)
        
        let checkSortDataOnFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("Apple 2", checkSortDataOnFourthTextField.value as! String)
        
        let checkSortDataOnFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("App 1", checkSortDataOnFifthTextField.value as! String)
    }
    
    func checkAscendingOrderSortingDataOfTextfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1", checkSortDataOnFirstTextField.value as! String)
        
        let checkSortDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Apple 2", checkSortDataOnSecondTextField.value as! String)
        
        let checkSortDataOnThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Boy 3", checkSortDataOnThirdTextField.value as! String)
        
        let checkSortDataOnFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("Cat 4", checkSortDataOnFourthTextField.value as! String)
        
        let checkSortDataOnFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Dog 5", checkSortDataOnFifthTextField.value as! String)
    }
    
    func testSortingOnTextField() throws {
        navigateToTableViewOnSecondPage()
        tapOnTextFieldColumn()
        
        // First Time tap
        checkAscendingOrderSortingDataOfTextfield()
        // Second Time tap
        checkDescendingOrderSortingDataOfTextfield()
        // Third Time tap
        checkAscendingOrderSortingDataOfTextfield()
    }
    
    func checkAscendingOrderSortingDataOfDropdownfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortingDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSortingDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSortingDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("N/A", checkSortingDataOnSecondDropdownField.element(boundBy: 1).label)
        
        let checkSortingDataOnThirdDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSortingDataOnThirdDropdownField.element(boundBy: 2).label)
        
        let checkSortingDataOnFourthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnFourthDropdownField.element(boundBy: 3).label)
        
        let checkSortingDataOnFifthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnFifthDropdownField.element(boundBy: 4).label)
    }
    
    func checkDescendignOrderSortingDataOfDropdownfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortingDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSortingDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnSecondDropdownField.element(boundBy: 1).label)
        
        let checkSortingDataOnThirdDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSortingDataOnThirdDropdownField.element(boundBy: 2).label)
        
        let checkSortingDataOnFourthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("N/A", checkSortingDataOnFourthDropdownField.element(boundBy: 3).label)
        
        let checkSortingDataOnFifthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSortingDataOnFifthDropdownField.element(boundBy: 4).label)
    }
    
    func checkNoSortingFilterDataOfDropdownfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortingDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnFirstDropdownField.element(boundBy: 0).label)
        
        let checkSortingDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSortingDataOnSecondDropdownField.element(boundBy: 1).label)
        
        let checkSortingDataOnThirdDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("N/A", checkSortingDataOnThirdDropdownField.element(boundBy: 2).label)
        
        let checkSortingDataOnFourthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSortingDataOnFourthDropdownField.element(boundBy: 3).label)
        
        let checkSortingDataOnFifthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSortingDataOnFifthDropdownField.element(boundBy: 4).label)
    }
    
    func testSortingOnDropdownField() throws {
        navigateToTableViewOnSecondPage()
        tapOnDropdownFieldColumn()
        
        // First time click
        checkAscendingOrderSortingDataOfDropdownfield()
        // Second Time click
        checkDescendignOrderSortingDataOfDropdownfield()
        // Third Time click
        checkNoSortingFilterDataOfDropdownfield()

    }
    
    func testAllRowSelectorButtonIsClickedOrNot() throws {
        navigateToTableViewOnSecondPage()
        
        // tap on all row selector button to select all rows
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"]
        selectallbuttonImage.tap()
        
        // verify more button is show or not after click on rows selector
        let button = app.buttons["TableMoreButtonIdentifier"] // Replace with your button's identifier
        XCTAssertTrue(button.exists, "The button should exist on the screen")

        // now unselect one row and then check - all row selector button is unselect or not
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        
        // more button show
        XCTAssertTrue(button.exists, "The button should exist on the screen")
        
        // now again tap on all row selector button to select all row
        selectallbuttonImage.tap()
        
        // more button show
        XCTAssertTrue(button.exists, "The button should exist on the screen")
        
        // now again tap on all row selector button to unselect all row
        selectallbuttonImage.tap()
        
        // now more button hide
        XCTAssertFalse(button.exists, "The button should not exist on the screen")
    }
    
    // test case for - when no option is selected
    func testDropdownFieldOnEmptyValue() throws {
        navigateToTableViewOnSecondPage()
        let dropdownButton = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 4)
        dropdownButton.tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        let checkSelectedValue = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSelectedValue.element(boundBy: 4).label)
    }
}

