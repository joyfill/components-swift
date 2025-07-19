import XCTest

final class TableFieldTests: JoyfillUITestsBaseClass {
    
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "Joydocjson"
    }
    
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
    
    // Delete all row - then check all row selector image for it is disbale or not
    func testDeleteAllRowsAndCheckColumnClickability() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoreButton()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"]
        selectallbuttonImage.tap()
        XCTAssertTrue(selectallbuttonImage.label == "circle", "The button should initially display the 'circle' image")
        
        app.buttons["TableAddRowIdentifier"].tap()
        selectallbuttonImage.tap()
        XCTAssertTrue(selectallbuttonImage.label == "record.circle.fill", "The button should initially display the 'record.circle.fill' image")
    }
    
    // First Page Table Test Cases
    
    // Test case for Check column header order - check column titles
    func testDropdownFieldColumnTitle() throws {
        goToTableDetailPage()
        let dropdownFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 1)
        XCTAssertTrue(dropdownFieldColumnTitleButton.label == "Dropdown Column", "\(dropdownFieldColumnTitleButton.label)")
        XCTAssertTrue(textFieldColumnTitleButton.label == "Text Column", "\(textFieldColumnTitleButton.label)")
    }
    
    // Test case for check dropdown is in First Place or not - because check column order work fine or not
    func testSearchFilterForDropdownFieldPageFirst() throws {
        goToTableDetailPage()
        let dropdownFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
        dropdownFieldColumnTitleButton.tap()
        
        tapOnDropdownFieldFilter()
        
        // Check dropdown data after search
        let checkSearchDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnFirstDropdownField.element(boundBy: 0).label)
        
        // Check field text data after search
        let checkSearchDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", checkSearchDataOnFirstTextField.value as! String)
    }
    
    func testTableTextFields() throws {
        goToTableDetailPage()
        
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Hello", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.clearText()
        firstTableTextField.typeText("First")
        
        let secondTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("His", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.clearText()
        secondTableTextField.typeText("Second")
        
        let thirdTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("His", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.clearText()
        thirdTableTextField.typeText("Third")
        
        goBack()
        sleep(2)
        let firstCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6628f2e11a2b28119985cfbb"]?.text)
        let secondCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[1].cells?["6628f2e11a2b28119985cfbb"]?.text)
        let thirdCellTextValue = try XCTUnwrap(onChangeResultValue().valueElements?[2].cells?["6628f2e11a2b28119985cfbb"]?.text)
        XCTAssertEqual("FirstHello", firstCellTextValue)
        XCTAssertEqual("SecondHis", secondCellTextValue)
        XCTAssertEqual("ThirdHis", thirdCellTextValue)
        
        // Navigate to signature detail view - then go to table detail view - to check recently enterd data is saved or not in table
        guard let SignatureButton = app.swipeToFindElement(identifier: "SignatureIdentifier", type: .button, direction: "down") else {
            XCTFail("Failed to find signature button after swiping")
            return
        }
        SignatureButton.tap()
        sleep(1)
        goBack()
        
        goToTableDetailPage()
        XCTAssertEqual("FirstHello", firstTableTextField.value as! String)
        XCTAssertEqual("SecondHis", secondTableTextField.value as! String)
        XCTAssertEqual("ThirdHis", thirdTableTextField.value as! String)
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
        sleep(2)
        let firstCellDropdownValue = try XCTUnwrap(onChangeResultValue().valueElements?[0].cells?["6628f2e123ca77fa82a2c45e"]?.text)
        XCTAssertEqual("6628f2e1c12db4664e9eb38f", firstCellDropdownValue)
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
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowCreate", fieldTarget)
        
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
        let fieldResult = onChangeResult()
        
        XCTAssertEqual("field.value.rowDelete", fieldResult.target)
        XCTAssertEqual("6628f2e1750679d671be36b8", fieldResult.change?["rowId"] as! String)

        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(3, valueElements.count)
    }
    
//    func testTableDuplicateRow() throws {
//        goToTableDetailPage()
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        let fieldTarget = onChangeResult().target
//        XCTAssertEqual("field.value.rowCreate", fieldTarget)
//        
//        let duplicateTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
//        XCTAssertEqual("His", duplicateTextField.value as! String)
//        duplicateTextField.tap()
//        duplicateTextField.typeText("Duplicate ")
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(3, lastIndex)
//    }

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
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowDelete", fieldTarget)
        
        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
//    func testDuplicateAllRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnMoreButton()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        // First Row Duplicate
//        let duplicateFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("App 1", duplicateFirstTextField.value as! String)
//        duplicateFirstTextField.tap()
//        duplicateFirstTextField.typeText("Duplicate ")
//        
//        // Second Row Duplicate
//        let duplicateSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
//        XCTAssertEqual("Apple 2", duplicateSecondTextField.value as! String)
//        duplicateSecondTextField.tap()
//        duplicateSecondTextField.typeText("Duplicate ")
//        
//        // Third Row Duplicate
//        let duplicateThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
//        XCTAssertEqual("Boy 3", duplicateThirdTextField.value as! String)
//        duplicateThirdTextField.tap()
//        duplicateThirdTextField.typeText("Duplicate ")
//        
//        // Fourth Row Duplicate
//        let duplicateFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 7)
//        XCTAssertEqual("Cat 4", duplicateFourthTextField.value as! String)
//        duplicateFourthTextField.tap()
//        duplicateFourthTextField.typeText("Duplicate ")
//        
//        // Fifth Row Duplicate
//        let duplicateFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 9)
//        XCTAssertEqual("Dog 5", duplicateFifthTextField.value as! String)
//        duplicateFifthTextField.tap()
//        duplicateFifthTextField.typeText("Duplicate ")
//                
//        var targetIndex = 1
//        for change in onChangeResultChanges() {
//            let value = try XCTUnwrap(change.dictionary as? [String: Any])
//            let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//            let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//            XCTAssertNotNil(newRow["_id"])
//            XCTAssertEqual(targetIndex, lastIndex)
//            targetIndex = targetIndex + 2
//        }
//    }
    
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
        textField.clearText()
        sleep(1)
        textField.typeText("App 1Edit")
        
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("Yes", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
//        app.buttons["ApplyAllButtonIdentifier"].tap()
        dismissSheet()
        
        sleep(1)
        
        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1Edit", checkEditDataOnTextField.value as! String)
        
        sleep(1)
        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkEditDataOnDropdownField.element(boundBy: 0).label)
    }
    
    func tapOnSearchBarTextField() {
        let searchBarTextField = app.textFields["TextFieldSearchBarIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("app\n")
    }
    
    func checkSearchTextFieldFilterData() {
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
    
//    func testSearchFilterForTextField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        checkSearchTextFieldFilterData()
//    }
    
    func checkDropdownFieldFilterData() {
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
    
    func tapOnDropdownFieldFilter() {
        let dropdownButton = app.buttons["SearchBarDropdownIdentifier"]
        XCTAssertEqual("Select Option", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
    }
    
//    func testSearchFilterForDropdownField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        checkDropdownFieldFilterData()
//    }
    
//    func tapOnDropdownFieldFilter() {
//        let dropdownButton = app.buttons["SearchBarDropdownIdentifier"]
//        XCTAssertEqual("Select Option", dropdownButton.label)
//        dropdownButton.tap()
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        let firstOption = dropdownOptions.element(boundBy: 0)
//        firstOption.tap()
//    }
    
//    func testSearchFilterForDropdownField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        checkDropdownFieldFilterData()
//    }
    
    func checkDescendingOrderSortingDataOfTextfield() {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Dog 5", checkSortDataOnFirstTextField.value as! String)
        checkSortDataOnFirstTextField.tap()
        checkSortDataOnFirstTextField.typeText("55")
        
        let checkSortDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Cat 4", checkSortDataOnSecondTextField.value as! String)
        
        let checkSortDataOnThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Boy 3", checkSortDataOnThirdTextField.value as! String)
        
        let checkSortDataOnFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("Apple 2", checkSortDataOnFifthTextField.value as! String)
        
        let checkSortDataOnFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("App 1", checkSortDataOnFourthTextField.value as! String)
        checkSortDataOnFourthTextField.tap()
        checkSortDataOnFourthTextField.typeText("11")
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
    
    func checkNoSortingFilterDataOfTextfield()  {
        app.buttons["SortButtonIdentifier"].tap()
        
        let checkSortDataOnFirstTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("11App 1", checkSortDataOnFirstTextField.value as! String)
        
        let checkSortDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Apple 2", checkSortDataOnSecondTextField.value as! String)
        
        let checkSortDataOnThirdTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Boy 3", checkSortDataOnThirdTextField.value as! String)
        
        let checkSortDataOnFourthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("Cat 4", checkSortDataOnFourthTextField.value as! String)
        
        let checkSortDataOnFifthTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("55Dog 5", checkSortDataOnFifthTextField.value as! String)
    }
    
//    func testSortingOnTextField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        
//        // First Time tap
//        checkAscendingOrderSortingDataOfTextfield()
//        // Second Time tap
//        checkDescendingOrderSortingDataOfTextfield()
//        // Third Time tap
//        checkNoSortingFilterDataOfTextfield()
//    }
    
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
        
        let checkSortingDataOnSecondDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 1)
        XCTAssertEqual("Yes", checkSortingDataOnSecondDropdownField.label)
        checkSortingDataOnSecondDropdownField.tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 2)
        firstOption.tap()
        
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
        XCTAssertEqual("N/A", checkSortingDataOnFourthDropdownField.element(boundBy: 3).label)
        
        let checkSortingDataOnFifthDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSortingDataOnFifthDropdownField.element(boundBy: 4).label)
    }
    
//    func testSortingOnDropdownField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        
//        // First time click
//        checkAscendingOrderSortingDataOfDropdownfield()
//        // Second Time click
//        checkDescendignOrderSortingDataOfDropdownfield()
//        // Third Time click
//        checkNoSortingFilterDataOfDropdownfield()
//
//    }
    
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
        sleep(1)
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        sleep(1)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        let checkSelectedValue = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSelectedValue.element(boundBy: 4).label)
    }
    
    // test case for add row using filter
//    func testAddRowWithFiltersTextField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        checkSearchTextFieldFilterData()
//        app.buttons["TableAddRowIdentifier"].tap()
//        sleep(1)
////        checkSearchTextFieldFilterData()
//        
//        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
//        XCTAssertEqual("app", checkDataOnAddRowWithFiltersTextField.value as! String)
//        
//        let checkDataOnAddRowWithFiltersDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Select Option", checkDataOnAddRowWithFiltersDropdownField.element(boundBy: 2).label)
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        // its count all row in table
//        XCTAssertEqual(5, lastIndex)
//    }
    
//    func testAddRowWithFiltersDropownField() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        checkDropdownFieldFilterData()
//        app.buttons["TableAddRowIdentifier"].tap()
//        checkDropdownFieldFilterData()
//        
//        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
//        XCTAssertEqual("", checkDataOnAddRowWithFiltersTextField.value as! String)
//        
//        let checkDataOnAddRowWithFiltersDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Yes", checkDataOnAddRowWithFiltersDropdownField.element(boundBy: 2).label)
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        // its count all row in table
//        XCTAssertEqual(5, lastIndex)
//    }
    
    func checkFilterDataOfBothFields() {
        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1", checkDataOnAddRowWithFiltersTextField.value as! String)
        
        let checkDataOnAddRowWithFiltersDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkDataOnAddRowWithFiltersDropdownField.element(boundBy: 0).label)
    }
    
//    func testAddRowWithFiltersWithBothFields() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        checkSearchTextFieldFilterData()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        checkFilterDataOfBothFields()
//        
//        app.buttons["TableAddRowIdentifier"].tap()
//        
//        // check data after add row using filter
//        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("app", checkDataOnAddRowWithFiltersTextField.value as! String)
//        
//        let checkDataOnAddRowWithFiltersDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Yes", checkDataOnAddRowWithFiltersDropdownField.element(boundBy: 1).label)
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        // its count all row in table
//        XCTAssertEqual(5, lastIndex)
//    }
    
    // Check field data after delete filter row in both fields
    func checkFieldLabelsAfterDeleteFilterRow() {
        let textFieldValues = [
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
    
    // Delete filter rows on TextField
//    func testDeleteTextFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDeleteRowIdentifier"].tap()
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        checkFieldLabelsAfterDeleteFilterRow()
//    }
    
//    func testEditTextFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableEditRowsIdentifier"].tap()
//        
//        let textField = app.textFields["EditRowsTextFieldIdentifier"]
//        sleep(1)
//        textField.tap()
//        sleep(1)
//        textField.typeText("Edit")
//        
//        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
//        XCTAssertEqual("Select Option", dropdownButton.label)
//        dropdownButton.tap()
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        let firstOption = dropdownOptions.element(boundBy: 1)
//        sleep(1)
//        firstOption.tap()
//        app.buttons["ApplyAllButtonIdentifier"].tap()
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        let textFieldValues = [
//            "Edit",
//            "Apple 2",
//            "Boy 3",
//            "Cat 4",
//            "Dog 5"
//        ]
//        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        for (index, textFieldValue) in textFieldValues.enumerated() {
//            let textField = textFields.element(boundBy: index)
//            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
//            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
//        }
//        
//        let dropdownValueLabels = [
//            "No",
//            "No",
//            "N/A",
//            "Yes",
//            "Select Option"
//        ]
//        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
//            let button = dropdownButtons.element(boundBy: index)
//            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
//            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
//        }
//    }
    
//    func testDuplicateTextFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        
//        // Check row adding or not after duplicating
//        let textFieldValues = [
//            "App 1",
//            "App 1",
//            "Apple 2",
//        ]
//        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        for (index, textFieldValue) in textFieldValues.enumerated() {
//            let textField = textFields.element(boundBy: index)
//            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
//            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
//        }
//        
//        let dropdownValueLabels = [
//            "Yes",
//            "Yes",
//            "No",
//        ]
//        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
//            let button = dropdownButtons.element(boundBy: index)
//            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
//            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
//        }
//        
//        app.buttons["HideFilterSearchBar"].tap()
//        // Now check all row after remove filter
//        checkFieldLablesAfterDuplicateFitlerRowInBothFields()
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(1, lastIndex)
//    }
    
//    func testDuplicateTextFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        
//        // Check row adding or not after duplicating
//        let textFieldValues = [
//            "App 1",
//            "App 1",
//            "Apple 2",
//        ]
//        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        for (index, textFieldValue) in textFieldValues.enumerated() {
//            let textField = textFields.element(boundBy: index)
//            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
//            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
//        }
//        
//        let dropdownValueLabels = [
//            "Yes",
//            "Yes",
//            "No",
//        ]
//        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
//            let button = dropdownButtons.element(boundBy: index)
//            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
//            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
//        }
//        
//        app.buttons["HideFilterSearchBar"].tap()
//        // Now check all row after remove filter
//        checkFieldLablesAfterDuplicateFitlerRowInBothFields()
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(1, lastIndex)
//    }
    
    
    // Test case for dropdown field - delete filter row
//    func testDeleteDropdownFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        
//        checkDropdownFieldFilterData()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDeleteRowIdentifier"].tap()
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        checkFieldLabelsAfterDeleteFilterRow()
//        
//    }
    
//    func testEditDropdownFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        
//        checkDropdownFieldFilterData()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableEditRowsIdentifier"].tap()
//        
//        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
//        XCTAssertEqual("Select Option", dropdownButton.label)
//        dropdownButton.tap()
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        let firstOption = dropdownOptions.element(boundBy: 1)
//        sleep(1)
//        firstOption.tap()
//        app.buttons["ApplyAllButtonIdentifier"].tap()
//        let checkSearchDataOnSecondTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
//        XCTAssertEqual("Cat 4", checkSearchDataOnSecondTextField.value as! String)
//        
//        // Check dropdown data after search
//        let checkSearchDataOnFirstDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Yes", checkSearchDataOnFirstDropdownField.element(boundBy: 0).label)
//        
//        
//        app.buttons["HideFilterSearchBar"].tap()
//                
//        let textFieldValues = [
//            "App 1",
//            "Apple 2",
//            "Boy 3",
//            "Cat 4",
//            "Dog 5"
//        ]
//        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        for (index, textFieldValue) in textFieldValues.enumerated() {
//            let textField = textFields.element(boundBy: index)
//            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
//            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
//        }
//        
//        let dropdownValueLabels = [
//            "No",
//            "No",
//            "N/A",
//            "Yes",
//            "Select Option"
//        ]
//        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
//            let button = dropdownButtons.element(boundBy: index)
//            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
//            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
//        }
//    }
    
    func checkFieldLablesAfterDuplicateFitlerRowInBothFields() {
        let checkAllRowTextFieldValues = [
            "App 1",
            "App 1",
            "Apple 2",
            "Boy 3",
            "Cat 4",
            "Dog 5"
        ]
        let checkTextFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for (index, textFieldValue) in checkAllRowTextFieldValues.enumerated() {
            let textField = checkTextFields.element(boundBy: index)
            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
        }
        
        let checkAllRowDropdownValueLabels = [
            "Yes",
            "Yes",
            "No",
            "N/A",
            "Yes",
            "Select Option"
        ]
        let checkDropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        for (index, dropdownValueLabel) in checkAllRowDropdownValueLabels.enumerated() {
            let button = checkDropdownButtons.element(boundBy: index)
            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
        }
    }
    
//    func testDuplicateDropDownFieldFilterRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnDropdownFieldColumn()
//        tapOnDropdownFieldFilter()
//        
//        checkDropdownFieldFilterData()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        // check fields label after duplicate row
//                
//        let textFieldValues = [
//            "App 1",
//            "App 1",
//            "Cat 4",
//        ]
//        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
//        for (index, textFieldValue) in textFieldValues.enumerated() {
//            let textField = textFields.element(boundBy: index)
//            XCTAssertTrue(textField.exists, "Text field \(index + 1) does not exist")
//            XCTAssertEqual(textField.value as! String, textFieldValue, "The text in field \(index + 1) is incorrect")
//        }
//        
//        let dropdownValueLabels = [
//            "Yes",
//            "Yes",
//            "Yes",
//        ]
//        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        for (index, dropdownValueLabel) in dropdownValueLabels.enumerated() {
//            let button = dropdownButtons.element(boundBy: index)
//            XCTAssertTrue(button.exists, "Button \(index + 1) does not exist")
//            XCTAssertEqual(button.label, dropdownValueLabel, "The label on button \(index + 1) is incorrect")
//        }
//        
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        // Now check all row after remove filter
//        checkFieldLablesAfterDuplicateFitlerRowInBothFields()
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(1, lastIndex)
//    }
    
    // Test case for Insert Row
    
    // Insert row below first row
    func tapOnInsertRowButton() {
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableInsertRowIdentifier"].tap()
    }
    
    // Enter data in inserd row - at first Index
    func enterDataInInsertedRow() {
        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("", enterDateInInsertedField.value as! String)
        enterDateInInsertedField.tap()
        enterDateInInsertedField.typeText("Inserted Row")
        
        // Select first option in dropdown field
        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 1)
        XCTAssertEqual("Select Option", selectDropdownField.label)
        selectDropdownField.tap()
        sleep(1)
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
    }
    
    // Simple insert 1 row
    func testTableInsertRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnInsertRowButton()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowCreate", fieldTarget)
        
        enterDataInInsertedRow()
        
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(1, lastIndex)
    }
    
    // Insert Row on search filter data
//    func testTableInsertRowOnSearchFilter() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        tapOnInsertRowButton()
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        // Enter Data in textfield
//        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("app", enterDateInInsertedField.value as! String)
//        enterDateInInsertedField.tap()
//        enterDateInInsertedField.typeText("Inserted Row")
//        
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 1)
//        XCTAssertEqual("Select Option", selectDropdownField.label)
//        selectDropdownField.tap()
//        
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 1)
//        firstOption.tap()
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(1, lastIndex)
//    }
    
    // Edit data in insert row by - Edit
    func testTableEditInsertRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnInsertRowButton()
        enterDataInInsertedRow()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        // Enter data for edit the field
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.clearText()
        sleep(1)
        textField.typeText("Inserted RowEdit Inserted Row")
        
        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
        XCTAssertEqual("No", dropdownButton.label)
        dropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
//        app.buttons["ApplyAllButtonIdentifier"].tap()
        dismissSheet()
        sleep(1)
        
        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Inserted RowEdit Inserted Row", checkEditDataOnTextField.value as! String)
        
        sleep(1)
        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkEditDataOnDropdownField.element(boundBy: 1).label)
        
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(1, lastIndex)
    }
    
    // Duplicate inserted row
//    func testTableDuplicateInsertedRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnInsertRowButton()
//        enterDataInInsertedRow()
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        // check data in Duplicate field
//        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
//        XCTAssertEqual("Inserted Row", checkEditDataOnTextField.value as! String)
//        
//        sleep(1)
//        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("No", checkEditDataOnDropdownField.element(boundBy: 2).label)
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(2, lastIndex)
//    }
    
    // Delete inserted row
    func testTableDeleteInsertedRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnInsertRowButton()
        enterDataInInsertedRow()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        // check data in deleted below field ( check row delete or not )
        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Apple 2", checkEditDataOnTextField.value as! String)
        
        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkEditDataOnDropdownField.element(boundBy: 1).label)
        
        goBack()
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements.last)
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(6, valueElements.count)
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.update", fieldTarget)
    }
    
    // Check inserted row data on Search filter
//    func testTableCheckInsertedRowDataSearchFilter() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnInsertRowButton()
//        enterDataInInsertedRow()
//        tapOnTextFieldColumn()
//        
//        // Enter data in searchbar textfield
//        let searchBarTextField = app.textFields["TextFieldSearchBarIdentifier"]
//        searchBarTextField.tap()
//        searchBarTextField.typeText("inserted\n")
//        
//        // Enter Data in searched filter inserted row
//        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
//        XCTAssertEqual("Inserted Row", enterDateInInsertedField.value as! String)
//        enterDateInInsertedField.tap()
//        enterDateInInsertedField.typeText("Done ")
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0)
//        XCTAssertEqual("No", selectDropdownField.label)
//        selectDropdownField.tap()
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 0)
//        firstOption.tap()
//        
//        app.buttons["HideFilterSearchBar"].tap()
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(1, lastIndex)
//        
//        goBack()
//        // tap on table detail view button to navigate - to check inserted row data is saved or not
//        let goToTableDetailView = app.buttons.matching(identifier: "TableDetailViewIdentifier")
//        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 1)
//        tapOnSecondTableView.tap()
//        
//        
//        // check enter data in fields
//        let checkSearchDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("Done Inserted Row", checkSearchDataOnTextField.value as! String)
//
//        // Check dropdown data after search
//        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Yes", checkSearchDataOnDropdownField.element(boundBy: 1).label)
//    }
    
    // Insert row at the end
    func testTableInsertRowAtEnd() throws {
        navigateToTableViewOnSecondPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableInsertRowIdentifier"].tap()
        
        // Enter data in Inserted row
        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
        XCTAssertEqual("", enterDateInInsertedField.value as! String)
        enterDateInInsertedField.tap()
        enterDateInInsertedField.typeText("Inserted Row")
        
        // Select first option in dropdown field
        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 5)
        XCTAssertEqual("Select Option", selectDropdownField.label)
        selectDropdownField.tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        // Check entered data
        XCTAssertEqual("Inserted Row", enterDateInInsertedField.value as! String)
        XCTAssertEqual("No", selectDropdownField.label)
        
        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
        XCTAssertNotNil(newRow["_id"])
        XCTAssertEqual(5, lastIndex)
    }
    
    // Move Up & Down Row Test Cases
    
    // Moved second row on top
    func tapOnMoveUpRowButton() {
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveUpRowIdentifier"].tap()
    }
    
    // Move down last second row to last
    func tapOnMoveDownRowButton() {
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveDownRowIdentifier"].tap()
    }
    
    // Check moved row data on top
    func checkMovedRowDataOfSecondRow() {
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Apple 2", checkMovedRowTextField.value as! String)

        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkSearchDataOnDropdownField.element(boundBy: 0).label)
    }
    
    // Check moved row data at the end
    func checkMovedRowDataOfLastSecondRow() {
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Cat 4", checkMovedRowTextField.value as! String)

        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnDropdownField.element(boundBy: 4).label)
    }
    
    // Move First row
    func testTableMoveUpRow() throws {
        navigateToTableViewOnSecondPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveUpRowIdentifier"].tap()
        
        // check move row data - remains same or not - in this case it remain same
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("App 1", checkMovedRowTextField.value as! String)

        // Check dropdown data after search
        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnDropdownField.element(boundBy: 0).label)
    }
    
    // Move Last row
    func testTableMoveDownRow() throws {
        navigateToTableViewOnSecondPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveDownRowIdentifier"].tap()
        
        // check move row data - remains same or not - in this case it remain same
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Dog 5", checkMovedRowTextField.value as! String)

        // Check dropdown data after search
        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSearchDataOnDropdownField.element(boundBy: 4).label)
    }
    
    // Move Second row at the top
    func testTableMovedSecondRowAtTheTop() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoveUpRowButton()
        
        let fieldTarget = onChangeResult().target
        XCTAssertEqual("field.value.rowMove", fieldTarget)
        
        // Enter data in Moved row
        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Apple 2", enterDateInInsertedField.value as! String)
        enterDateInInsertedField.tap()
        enterDateInInsertedField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        sleep(1)
        enterDateInInsertedField.typeText("Moved Apple 2")
        
        // Select first option in dropdown field
        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0)
        XCTAssertEqual("No", selectDropdownField.label)
        selectDropdownField.tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        // Check entered data
        XCTAssertEqual("Moved Apple 2", enterDateInInsertedField.value as! String)
        XCTAssertEqual("Yes", selectDropdownField.label)
    }
    
    // Move last second row to last
    func testTableMovedLastSecondRowToLast() throws {
        navigateToTableViewOnSecondPage()
        
        tapOnMoveDownRowButton()
        
        // Enter data in Moved row
        let enterDateInInsertedField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Cat 4", enterDateInInsertedField.value as! String)
        enterDateInInsertedField.tap()
        enterDateInInsertedField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        sleep(1)
        enterDateInInsertedField.typeText("Moved Cat 4")
        
        // Select first option in dropdown field
        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 4)
        XCTAssertEqual("Yes", selectDropdownField.label)
        selectDropdownField.tap()
        
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        // Check entered data
        XCTAssertEqual("Moved Cat 4", enterDateInInsertedField.value as! String)
        XCTAssertEqual("No", selectDropdownField.label)
    }
    
    // Delete moved up row
    func testTableDeleteMovedUpRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoveUpRowButton()
        checkMovedRowDataOfSecondRow()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        goBack()

        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let firstRow = try XCTUnwrap(valueElements[1])
        XCTAssertTrue(firstRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
    // Delete Moved down row
    func testTableDeleteMovedDownRow() throws {
        navigateToTableViewOnSecondPage()
        tapOnMoveDownRowButton()
        checkMovedRowDataOfLastSecondRow()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        goBack()

        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let lastRow = try XCTUnwrap(valueElements[3])
        XCTAssertTrue(lastRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
    // Duplicate Moved up Row
//    func testTableDuplicateMovedUpRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnMoveUpRowButton()
//        checkMovedRowDataOfSecondRow()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        // Enter data in Duplicate Moved row
//        let enterDataInDuplicateRowField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("Apple 2", enterDataInDuplicateRowField.value as! String)
//        enterDataInDuplicateRowField.tap()
//        enterDataInDuplicateRowField.typeText("Duplicate ")
//        
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 1)
//        XCTAssertEqual("No", selectDropdownField.label)
//        selectDropdownField.tap()
//        
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 0)
//        firstOption.tap()
//        
//        // Check entered data
//        XCTAssertEqual("Duplicate Apple 2", enterDataInDuplicateRowField.value as! String)
//        XCTAssertEqual("Yes", selectDropdownField.label)
//        
//        goBack()
//        
//        sleep(2)
//        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
//        XCTAssertEqual(6, valueElements.count)
//    }
    
    // Duplicate move down row
//    func testTableDuplicateMovedDownRow() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnMoveDownRowButton()
//        checkMovedRowDataOfLastSecondRow()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableDuplicateRowIdentifier"].tap()
//        
//        // Enter data in Duplicate Moved row
//        let enterDataInDuplicateRowField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
//        XCTAssertEqual("Cat 4", enterDataInDuplicateRowField.value as! String)
//        enterDataInDuplicateRowField.tap()
//        enterDataInDuplicateRowField.typeText("Duplicate ")
//        
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 5)
//        XCTAssertEqual("Yes", selectDropdownField.label)
//        selectDropdownField.tap()
//        
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 1)
//        firstOption.tap()
//        
//        // Check entered data
//        XCTAssertEqual("Duplicate Cat 4", enterDataInDuplicateRowField.value as! String)
//        XCTAssertEqual("No", selectDropdownField.label)
//        
//        goBack()
//        
//        sleep(2)
//        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
//        XCTAssertEqual(6, valueElements.count)
//    }
    
    // Apply Search filter and then move row up in filter rows
//    func testTableSearchFilterMoveRow() {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        tapOnMoveUpRowButton()
//        checkMovedRowDataOfSecondRow()
//        
//        app.buttons["HideFilterSearchBar"].tap()
//         
//        // Enter data in Moved row
//        let enterDataInField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
//        XCTAssertEqual("Apple 2", enterDataInField.value as! String)
//        enterDataInField.tap()
//        enterDataInField.typeText("Done ")
//        
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0)
//        XCTAssertEqual("No", selectDropdownField.label)
//        selectDropdownField.tap()
//        
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 0)
//        firstOption.tap()
//        
//        // Check entered data
//        XCTAssertEqual("Done Apple 2", enterDataInField.value as! String)
//        XCTAssertEqual("Yes", selectDropdownField.label)
//    }
    
    // Apply Search filter and then move row down in filter rows
//    func testTableSearchFilterMoveRowDown() {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        
//        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
//        app.buttons["TableMoreButtonIdentifier"].tap()
//        app.buttons["TableMoveDownRowIdentifier"].tap()
//        
//        // check move row down data
//        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("App 1", checkMovedRowTextField.value as! String)
//
//        // Check dropdown data after search
//        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
//        XCTAssertEqual("Yes", checkSearchDataOnDropdownField.element(boundBy: 1).label)
//        
//        app.buttons["HideFilterSearchBar"].tap()
//         
//        // Enter data in Moved row
//        let enterDataInField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        enterDataInField.tap()
//        enterDataInField.typeText("Done ")
//        
//        // Select first option in dropdown field
//        let selectDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 1)
//        selectDropdownField.tap()
//        
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        XCTAssertGreaterThan(dropdownOptions.count, 0)
//        let firstOption = dropdownOptions.element(boundBy: 1)
//        firstOption.tap()
//        
//        // Check entered data
//        XCTAssertEqual("Done App 1", enterDataInField.value as! String)
//        XCTAssertEqual("No", selectDropdownField.label)
//    }
   
    // Delete two rows - then moved last row up
    func testTableDeleteTwoRowsAndMoveLastRowUp() throws {
        navigateToTableViewOnSecondPage()
        
        // Delete Two rows
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        // Moved last row - second place
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveUpRowIdentifier"].tap()
        
        // Now moved row on top
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveUpRowIdentifier"].tap()
        
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Dog 5", checkMovedRowTextField.value as! String)

        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", checkSearchDataOnDropdownField.element(boundBy: 0).label)
        
        goBack()
        
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let thirdRow = try XCTUnwrap(valueElements[2])
        let fourthRow = try XCTUnwrap(valueElements[3])
        XCTAssertTrue(thirdRow.deleted!)
        XCTAssertTrue(fourthRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
    // Delete two rows - then moved row down
    func testTableDeleteTwoRowsAndMoveRowDown() throws {
        navigateToTableViewOnSecondPage()
        
        // Delete Two rows
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 2).tap()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        // Moved first row - second place
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveDownRowIdentifier"].tap()
        
        // Now moved row on last
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableMoveDownRowIdentifier"].tap()
        
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("App 1", checkMovedRowTextField.value as! String)

        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes", checkSearchDataOnDropdownField.element(boundBy: 2).label)
        
        goBack()
        
        sleep(2)
        let valueElements = try XCTUnwrap(onChangeResultValue().valueElements)
        let thirdRow = try XCTUnwrap(valueElements[2])
        let fourthRow = try XCTUnwrap(valueElements[3])
        XCTAssertTrue(thirdRow.deleted!)
        XCTAssertTrue(fourthRow.deleted!)
        XCTAssertEqual(5, valueElements.count)
    }
    
    // Insert row under moved row up
    func testTableInsertRowUnderMovedRowUp() {
        navigateToTableViewOnSecondPage()
        tapOnMoveUpRowButton()
        checkMovedRowDataOfSecondRow()
        tapOnInsertRowButton()
        enterDataInInsertedRow()
        
        // check data in Duplicate field
        let checkEditDataOnTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Inserted Row", checkEditDataOnTextField.value as! String)
        
        sleep(1)
        let checkEditDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No", checkEditDataOnDropdownField.element(boundBy: 1).label)
    }
    
//    func testTextFieldAddRowWithFilters() throws {
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        checkSearchTextFieldFilterData()
//        app.buttons["TableAddRowIdentifier"].tap()
//        
//        //there are 2 rows after filter and we add one row with filter, now there are 3 rows , and we check the third row text if its there
//        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
//        XCTAssertEqual("app", checkDataOnAddRowWithFiltersTextField.value as! String)
//        
//        let value = try XCTUnwrap(onChangeResultChange().dictionary as? [String: Any])
//        let lastIndex = try Int(XCTUnwrap(value["targetRowIndex"] as? Double))
//        let newRow = try XCTUnwrap(value["row"] as? [String: Any])
//        XCTAssertNotNil(newRow["_id"])
//        XCTAssertEqual(5, lastIndex)
//    }
    
//    func testApplyFilterAndBulkEdit() throws {
//        //SEE wheather the bulk edit applied or not in filtered rows
//        navigateToTableViewOnSecondPage()
//        tapOnTextFieldColumn()
//        tapOnSearchBarTextField()
//        checkSearchTextFieldFilterData()
//        tapOnMoreButton()
//        app.buttons["TableEditRowsIdentifier"].tap()
//        
//        let textField = app.textFields["EditRowsTextFieldIdentifier"]
//        sleep(1)
//        textField.tap()
//        sleep(1)
//        textField.typeText("app")
//        
//        let dropdownButton = app.buttons["EditRowsDropdownFieldIdentifier"]
//        XCTAssertEqual("Select Option", dropdownButton.label)
//        dropdownButton.tap()
//        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
//        let firstOption = dropdownOptions.element(boundBy: 0)
//        firstOption.tap()
//        
//        app.buttons["ApplyAllButtonIdentifier"].tap()
//        
//        sleep(1)
//        
//        let checkDataOnAddRowWithFiltersTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
//        XCTAssertEqual("app", checkDataOnAddRowWithFiltersTextField.value as! String)
//        
//        let checkDataOnAddRowWithFiltersTextField2 = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertEqual("app", checkDataOnAddRowWithFiltersTextField2.value as! String)
//        
//        let checkDataOnAddRowWithFiltersDropdown = app.buttons.matching(identifier: "TableDropdownIdentifier").element(boundBy: 0)
//        XCTAssertEqual("Yes", checkDataOnAddRowWithFiltersDropdown.label)
//    }
}

