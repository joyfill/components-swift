import XCTest
import JoyfillModel
import Joyfill

@testable import JoyfillExample

final class OnChangeHandlerUITests: JoyfillUITestsBaseClass {
    
    func goToCollectionView(index: Int = 0) {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: index)
        tapOnSecondTableView.tap()
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func drawSignatureLine() {
        let canvas = app.otherElements["CanvasIdentifier"]
        canvas.tap()
        let startPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let endPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
    
    func expandRow(number: Int) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
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
    
    func selectAllNestedRows() {
        app.images.matching(identifier: "selectAllNestedRows")
            .element.tap()
    }
    
    func tapSchemaAddRowButton(number: Int) {
        let buttons = app.buttons.matching(identifier: "collectionSchemaAddRowButton")
        XCTAssertTrue(buttons.count > 0)
        buttons.element(boundBy: number).tap()
    }
    
    func editRowsButton() -> XCUIElement {
        return app.buttons["TableEditRowsIdentifier"]
    }
    
    fileprivate func tapOnMoreButtonCollection() {
        //tap more icon
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
    }
    
    
    func addThreeNestedRows(parentRowNumber: Int) {
        expandRow(number: parentRowNumber)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        let firstNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("", firstNestedTextField.value as! String)
        firstNestedTextField.tap()
        firstNestedTextField.typeText("one")
        
        let secNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("", secNestedTextField.value as! String)
        secNestedTextField.tap()
        secNestedTextField.typeText("two")
        
        let thirdNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("", thirdNestedTextField.value as! String)
        thirdNestedTextField.tap()
        thirdNestedTextField.typeText("123")
    }
    
    func openFilterModalForDismissKeyboard() {
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        if !filterButton.exists {
            XCTFail("Filter button should exist")
        }
        
        filterButton.firstMatch.tap()
        
        // Verify filter modal opened
        let filterModalExists = app.staticTexts["Filter"].exists
        XCTAssertTrue(filterModalExists, "Filter modal should be open")
        
        dismissSheet()
    }
    
    func openFilterModal() {
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        if !filterButton.exists {
            XCTFail("Filter button should exist")
        }
        
        filterButton.firstMatch.tap()
        
        // Verify filter modal opened
        let filterModalExists = app.staticTexts["Filter"].exists
        XCTAssertTrue(filterModalExists, "Filter modal should be open")
    }
    
    func editSingleRowUpperButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["UpperRowButtonIdentifier"].firstMatch
    }
    
    func editSingleRowLowerButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["LowerRowButtonIdentifier"].firstMatch
    }
    
    func editInsertRowPlusButton() -> XCUIElement {
        app.scrollViews.otherElements.buttons["PlusTheRowButtonIdentifier"].firstMatch
    }
    
    func deleteRowButton() -> XCUIElement {
        return app.buttons["TableDeleteRowIdentifier"].firstMatch
    }
    
    func selectNestedRow(number: Int) {
        app.images.matching(identifier: "selectNestedRowItem\(number)")
            .element.firstMatch.tap()
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
    
    func selectRow(number: Int) {
        //select the row with number as index
        app.images.matching(identifier: "selectRowItem\(number)")
            .element.firstMatch.tap()
    }
    
    
    func selectSchema(_ schemaName: String) {
        let schemaSelector = app.buttons.matching(identifier: "SelectSchemaTypeIDentifier")
        schemaSelector.element.firstMatch.tap()
        
        let schemaOption = app.buttons[schemaName].firstMatch
        schemaOption.tap()
    }
    
    func selectColumn(_ columnName: String, selectorIndex: Int = 0) {
        let selectors = app.buttons.matching(identifier: "CollectionFilterColumnSelectorIdentifier")
        let columnSelector = selectors.element(boundBy: selectorIndex)
        XCTAssertTrue(
            columnSelector.exists,
            "Column selector at index \(selectorIndex) should exist"
        )
        columnSelector.tap()
        
        let columnOption = app.buttons[columnName].firstMatch
        if !columnOption.exists {
            XCTFail("Column option should exist")
        }
        columnOption.tap()
    }
    
    func enterTextFilter(_ text: String) {
        let searchField = app.textFields["TextFieldSearchBarIdentifier"]
        if searchField.exists {
            searchField.tap()
            searchField.clearText()
            searchField.typeText(text)
        } else {
            XCTFail("SearchField Should exist")
        }
        
    }
    
    func selectDropdownOption(_ optionName: String) {
        let dropdownFilterButton = app.buttons["SearchBarDropdownIdentifier"]
        if dropdownFilterButton.exists {
            dropdownFilterButton.tap()
            
            let option = app.buttons[optionName].firstMatch
            if option.exists {
                option.tap()
            }
        } else {
            XCTFail("Dropdown should exist")
        }
    }
    
    func selectMultiSelectOption(_ optionName: String) {
        let multiSelectFilterButton = app.buttons["SearchBarMultiSelectionFieldIdentifier"]
        if multiSelectFilterButton.exists {
            multiSelectFilterButton.tap()
            
            let option = app.buttons[optionName].firstMatch
            if option.exists {
                option.tap()
            }
        } else {
            XCTFail("MultiSlect filter should exist")
        }
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
    }
    
    func tapApplyButton() {
        let applyButton = app.buttons["Apply"]
        if !applyButton.exists {
            XCTFail("Apply button should exist")
        }
        
        applyButton.tap()
        
    }
    func closeFilterModal() {
        dismissSheet()
    }
    
    func applyTextFilter(schema: String = "Root Table", column: String, text: String) {
        openFilterModalCollection()
        
        selectSchema(schema)
        
        selectColumn(column)
        enterTextFilter(text)
        tapApplyButton()
        closeFilterModal()
    }
    
    func getVisibleRowCount() -> Int {
        // Count rows using multiple possible row identifiers
        return rowCount(baseIdentifier: "selectRowItem")
    }
    
    func getVisibleNestexRowsCount() -> Int {
        return rowCountWithScrollLoad(baseIdentifier: "selectNestedRowItem")
    }
    
    /// Scrolls up through the scrollView loading new items by identifier, then scrolls back down.
    /// Returns the total number of matching images found.
    func rowCountWithScrollLoad(baseIdentifier: String, maxScrolls: Int = 10) -> Int {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", baseIdentifier)
        let scrollView = app.scrollViews.firstMatch
        
        var previousCount = -1
        var currentCount = 0
        var attempts = 0
        
        // Swipe up until no new images load or we hit maxScrolls
        while attempts < maxScrolls {
            scrollView.swipeUp()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))  // allow content to settle
            currentCount = app.images.matching(predicate).count
            if currentCount == previousCount { break }
            previousCount = currentCount
            attempts += 1
        }
        
        // Reset counter and swipe back down until stable
        attempts = 0
        while attempts < maxScrolls {
            scrollView.swipeDown()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            let newCount = app.images.matching(predicate).count
            if newCount == previousCount { break }
            previousCount = newCount
            attempts += 1
        }
        
        return currentCount
    }
    
    func rowCount(baseIdentifier: String) -> Int {
        let beginsWith = NSPredicate(format: "identifier BEGINSWITH %@", baseIdentifier)
        return app.images.matching(beginsWith).count
    }
    
    func openFilterModalCollection() {
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        if !filterButton.exists {
            XCTFail("Filter button should exist")
        }
        
        filterButton.firstMatch.tap()
        
        // Verify filter modal opened
        let filterModalExists = app.staticTexts["Filter"].exists
        XCTAssertTrue(filterModalExists, "Filter modal should be open")
    }
    
    func testMoveUpState() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        selectRow(number: 1)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().isEnabled, false)
        XCTAssertEqual(moveDownButton().isEnabled, true)
        moveDownButton().tap()
        goBack()
        selectRow(number: 1)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().isEnabled, false)
        XCTAssertEqual(moveDownButton().isEnabled, true)
    }
    
    func testMoveDownState() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        selectRow(number: 4)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().isEnabled, true)
        XCTAssertEqual(moveDownButton().isEnabled, false)
        moveUpButton().tap()
        goBack()
        selectRow(number: 4)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().isEnabled, true)
        XCTAssertEqual(moveDownButton().isEnabled, false)
    }
    
    func testMoveUpAndMoveDownButtonAvailableOrNot() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        selectRow(number: 1)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().exists, true)
        XCTAssertEqual(moveDownButton().exists, true)
        XCTAssertEqual(inserRowBelowButton().exists, true)
        moveDownButton().tap()
        goBack()
        selectRow(number: 1)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().exists, true)
        XCTAssertEqual(moveDownButton().exists, true)
        XCTAssertEqual(inserRowBelowButton().exists, true)
    }
    
    func testMoveUpAndMoveDownButtonAvailableOrNotOnMultipleRows() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        selectRow(number: 1)
        selectRow(number: 2)
        tapOnMoreButtonCollection()
        
        XCTAssertEqual(moveUpButton().exists, false)
        XCTAssertEqual(moveDownButton().exists, false)
        XCTAssertEqual(inserRowBelowButton().exists, false)
        dismissSheet()
        goBack()
        selectRow(number: 1)
        selectRow(number: 2)
        tapOnMoreButtonCollection()
        XCTAssertEqual(moveUpButton().exists, false)
        XCTAssertEqual(moveDownButton().exists, false)
        XCTAssertEqual(inserRowBelowButton().exists, false)
    }
    
//    func testChangeText() {
//        guard UIDevice.current.userInterfaceIdiom == .pad else {
//            return
//        }
//        goToCollectionView()
//        goToCollectionView()
//       
//        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
//        XCTAssertEqual("A", firstTableTextField.value as! String)
//        XCTAssertTrue(firstTableTextField.waitForExistence(timeout: 3))
//        firstTableTextField.tap()
//        firstTableTextField.typeText("one")
//
//        let firstValueCount = app.textViews.countMatchingValue(firstTableTextField.value as! String)
//        print("Number of textViews with value \"FirstA\": \(firstValueCount)")
//        XCTAssertEqual(2, firstValueCount, "Expected exactly two textViews with value 'FirstA' (one in each form)")
//    }
    
    func testChangeNumberCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
       
        let firstTableTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("12.2", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.clearText()
        
        firstTableTextField.typeText("12345")

        let firstValueCount = app.textFields.countMatchingValue("12345")
        print("Number of number fields with value \"12345\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two number fields with value '12345' (one in each form)")
    }
    
    fileprivate func selectAllMultiSlectOptions() {
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertTrue(optionsButtons.element.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(optionsButtons.count, 0)
        let firstOptionButton = optionsButtons.element(boundBy: 0)
        firstOptionButton.tap()
        let secOptionButton = optionsButtons.element(boundBy: 1)
        secOptionButton.tap()
        let thirdOptionButton = optionsButtons.element(boundBy: 2)
        thirdOptionButton.tap()
    }
    
    func testChangeMultiCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        let multiSelectionButtons = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButtons.count, 0)
        let firstButton = multiSelectionButtons.element(boundBy: 0)
        firstButton.tap()
        
        selectAllMultiSlectOptions()

        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()

        goBack()
        
        let multiSelectionButton = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButton.count, 0)
        let firstButto = multiSelectionButton.element(boundBy: 0)
        firstButto.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
//            XCTAssertEqual(optionButton.value as? String, "Selected")
        let optionButton = optionsButtons.element(boundBy: 0)
        let optionButton2 = optionsButtons.element(boundBy: 1)
        let optionButton3 = optionsButtons.element(boundBy: 2)
        XCTAssertEqual(optionButton.value as? String, "Not selected")
        XCTAssertEqual(optionButton2.value as? String, "Selected")
        XCTAssertEqual(optionButton3.value as? String, "Selected")
    }
    
    func testChangeDropdownCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 0).label)
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 1).label)
        XCTAssertEqual("Yes D1", dropdownButtons.element(boundBy: 2).label)
        
        XCTAssertEqual("No D1", dropdownButtons.element(boundBy: 3).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 2)
        firstOption.tap()
        goBack()
        
        let secdropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("N/A D1", secdropdownButtons.element(boundBy: 0).label)
    }
    
    func testChangeDateCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        let dateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        XCTAssertEqual(dateFields.count, 4, "Date fields should exist")
        
        let dateField1 = dateFields.element(boundBy: 0)
        let dateField2 = dateFields.element(boundBy: 1)
        dateField1.tap()
        dateField2.tap()
        goBack()
        
        let secDateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        XCTAssertEqual(secDateFields.count, 0, "Date fields should exist")
    }
    
    func testChangeImageCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(imageButtons.count, 0, "Image buttons should exist")
        
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        
        let uploadImageButton = app.buttons["ImageUploadImageIdentifier"]
        if uploadImageButton.exists {
            uploadImageButton.tap()
            dismissSheet()
        }
        goBack()
        
        let secImageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(secImageButtons.count, 0, "Image buttons should exist")
        
        let imageButton = imageButtons.element(boundBy: 0)
        imageButton.tap()
        
        let allImages = app.images.matching(identifier: "DetailPageImageSelectionIdentifier")

        let circleImages = allImages.matching(NSPredicate(format: "label == %@", "circle"))

        let circleCount = circleImages.count
        XCTAssertEqual(circleCount, 1)
    }
    
    func testBulkEditNestedRows() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        expandRow(number: 1)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        selectAllNestedRows()
        tapOnMoreButtonCollection()
        editRowsButton().tap()
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.typeText("Edit")
          
        // Tap on Apply All Button
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        goBack()
        expandRow(number: 1)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let firstCellTextValue = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for i in 2..<7 {
            let cell = firstCellTextValue.element(boundBy: i)
            XCTAssertTrue(cell.exists, "Cell at index \(i) should exist")
            let value = cell.value as? String
            XCTAssertEqual(value, "Edit", "Cell \(i) should have value “123.345”, but was \(value ?? "nil")")
        }
    }
    
    
    // Test disabled buttons on Row Form for nested rows
//    func testSelectOneNestedRow() throws {
//        guard UIDevice.current.userInterfaceIdiom == .pad else {
//            return
//        }
//        goToCollectionView()
//        goToCollectionView()
//        addThreeNestedRows(parentRowNumber: 2)
//        // Make sure collection search filter is on
//        openFilterModalForDismissKeyboard()
//        app.dismissKeyboardIfVisible()
//        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
//        expandRow(number: 3)
//        
//        selectNestedRow(number: 2)
//        
//        tapOnMoreButtonCollection()
//        editRowsButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, true)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//        //go to next row and test
//        editSingleRowLowerButton().tap()
//        editSingleRowLowerButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//        
//        //tap inssert below and test
//        editInsertRowPlusButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//        dismissSheet()
//        goBack()
//        expandRow(number: 2)
//        expandRow(number: 3)
//        
//        selectNestedRow(number: 2)
//        
//        tapOnMoreButtonCollection()
//        editRowsButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, true)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//        //go to next row and test
//        editSingleRowLowerButton().tap()
//        editSingleRowLowerButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//        
//        //tap inssert below and test
//        editInsertRowPlusButton().tap()
//        
//        XCTAssertEqual(editSingleRowUpperButton().isEnabled, true)
//        XCTAssertEqual(editSingleRowLowerButton().isEnabled, false)
//        XCTAssertEqual(editInsertRowPlusButton().isEnabled, true)
//    }
    
    
    func testDeleteAllRowsApplyFiltersThenReAddAndFilterDepth2() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        
        // Step 1: Delete all rows
        app.images["SelectParentAllRowSelectorButton"].firstMatch.tap()
        tapOnMoreButtonCollection()
        app.buttons["TableDeleteRowIdentifier"].firstMatch.tap()
        
        // Step 2: Apply a filter after all rows are deleted
        applyTextFilter(column: "Text D1", text: "Test")
        let filteredCount = getVisibleRowCount()
        XCTAssertEqual(filteredCount, 0, "Filtered count should be 0 after deleting all rows")
        
        // Clear existing filters before deleting
        openFilterModalCollection()
        enterTextFilter("")
        tapApplyButton()
        
        // Step 3: Add 3 new root rows
        let addRowButton = app.buttons.matching(identifier: "TableAddRowIdentifier").element(boundBy: 0)
        addRowButton.tap()
        addRowButton.tap()
        addRowButton.tap()
        
        expandRow(number: 1)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        let firstNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("", firstNestedTextField.value as! String)
        firstNestedTextField.tap()
        firstNestedTextField.typeText("quick")
        
        let secNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy:2)
        XCTAssertEqual("", secNestedTextField.value as! String)
        secNestedTextField.tap()
        secNestedTextField.typeText("Two")
        
        let thirdNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("", thirdNestedTextField.value as! String)
        thirdNestedTextField.tap()
        thirdNestedTextField.typeText("123")
        
        goBack()
        expandRow(number: 1)
        // Step 7: Apply filter in Depth 2 for text "Hello"
        applyTextFilter(schema: "Depth 2", column: "Text D2", text: "Two")
        
        // Step 8: Validate filtered results
        let parentRowsCount = getVisibleRowCount()
        let nestedRowsCount = getVisibleNestexRowsCount()
        XCTAssertEqual(parentRowsCount, 1, "Expected 1 parent row matching 'Hello'")
        XCTAssertEqual(nestedRowsCount, 1, "Expected 1 nested row matching 'Hello'")
        
    }
    
    func testDeleteAndMoveRow() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView()
        selectRow(number: 3)
        selectRow(number: 4)
        tapOnMoreButtonCollection()
        XCTAssertEqual(deleteRowButton().isEnabled, true)
        deleteRowButton().tap()
        selectRow(number: 2)
        tapOnMoreButtonCollection()
        moveUpButton().tap()
        tapOnMoreButtonCollection()
        moveDownButton().tap()
        tapOnMoreButtonCollection()
        inserRowBelowButton().tap()
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        firstTableTextField.tap()
        firstTableTextField.typeText("hi")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        selectRow(number: 3)
        tapOnMoreButtonCollection()
        moveUpButton().tap()
        tapOnMoreButtonCollection()
        moveUpButton().tap()
        let CheckTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual(CheckTextField.value as! String, "hi")
    }
    
    /* Table on change handler test cases*/
    func goToTableDetailPage(index: Int = 0) {
        app.buttons.matching(identifier: "TableDetailViewIdentifier").element(boundBy: index).tap()
    }
    
    func tapOnMoreButton() {
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"].firstMatch
        selectallbuttonImage.tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
    }
    
    func tapOnNumberTextField(atIndex index: Int) -> XCUIElement {
        // Try simplified method first (assumes iPad or iPhone with identifiers working)
        let numberField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: index)
        
        if numberField.exists && numberField.isHittable {
            numberField.tap()
            return numberField
        }
        
        // If not hittable or missing, fall back to deep traversal (iPhone-specific layout)
        let deepNumberField = app.children(matching: .window).element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .scrollView).element(boundBy: 2)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .textField).matching(identifier: "TabelNumberFieldIdentifier")
            .element(boundBy: index)
        
        XCTAssertTrue(deepNumberField.waitForExistence(timeout: 5), "Number field at index \(index) not found (deep fallback)")
        deepNumberField.tap()
        return deepNumberField
    }
    
    func tapOnNumberFieldColumn() {
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 3)
        textFieldColumnTitleButton.tap()
    }
    
    func enterDataInBarcodeSearchFilter() {
        let textField = app.textViews.matching(identifier: "SearchBarCodeFieldIdentifier").element(boundBy: 0)
        textField.tap()
        textField.typeText("Row")
    }
    
    func tapOnBarcodeFieldColumn() {
        let textFieldColumnTitleButton = app.buttons.matching(identifier: "ColumnButtonIdentifier").element(boundBy: 0)
        textFieldColumnTitleButton.tap()
    }
    
    func tapOnMultiSelectionFieldColumn() {
        guard let multiFieldColumnTitleButton = app.swipeToFindElement(identifier: "ColumnButtonIdentifier", type: .button, direction: "left") else {
            XCTFail("Failed to find multifield column after swiping")
            return
        }
        multiFieldColumnTitleButton.tap()
    }
    
    func tapOnSearchBarTextField(value: String) {
        let searchBarTextField = app.textFields["SearchBarNumberIdentifier"]
        searchBarTextField.tap()
        searchBarTextField.typeText("\(value)")
    }
    
    // Moved second row on top
    func tapOnMoveUpRowButton() {
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableMoveUpRowIdentifier"].firstMatch.tap()
    }
    
    // Move down last second row to last
    func tapOnMoveDownRowButton() {
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableMoveDownRowIdentifier"].firstMatch.tap()
    }
    
    // Check moved row data on top
    func checkMovedRowDataOfSecondRow() {
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Second", checkMovedRowTextField.value as! String)
        
        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No D1", checkSearchDataOnDropdownField.element(boundBy: 0).label)
    }
    
    // Check moved row data at the end
    func checkMovedRowDataOfLastSecondRow() {
        let checkMovedRowTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Text", checkMovedRowTextField.value as! String)
        
        let checkSearchDataOnDropdownField = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Yes D1", checkSearchDataOnDropdownField.element(boundBy: 4).label)
    }
    
    func randomCalendarDayLabelInCurrentMonth(excludingToday: Bool = true) -> String? {
        let calendar = Calendar.current
        let today = Date()
        
        guard let range = calendar.range(of: .day, in: .month, for: today) else { return nil }
        
        let todayDay = calendar.component(.day, from: today)
        
        // Get all valid days of this month excluding today
        let possibleDays = range.filter { excludingToday ? $0 != todayDay : true }
        
        guard let randomDay = possibleDays.randomElement() else { return nil }
        
        var components = calendar.dateComponents([.year, .month], from: today)
        components.day = randomDay
        
        guard let randomDate = calendar.date(from: components) else { return nil }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: with comma
            if #available(iOS 19.0, *) {
                formatter.dateFormat = "EEEE, d MMMM"
            } else {
                formatter.dateFormat = "EEEE d MMMM"
            }
        } else {
            // iPhone: no comma
            formatter.dateFormat = "EEEE d MMMM"
        }
        
        return formatter.string(from: randomDate)
    }
    
    func formattedAccessibilityLabel(for isoDate: String) -> String {
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
            outputFormatter.dateFormat = "EEEE d MMMM"
        }
        
        return outputFormatter.string(from: date)
    }
    
//    func testInsertBelowCollection() {
//        guard UIDevice.current.userInterfaceIdiom == .pad else {
//            return
//        }
//        goToCollectionView()
//        goToCollectionView()
//        
//        selectRow(number: 1)
//        tapOnMoreButtonCollection()
//        XCTAssertEqual(inserRowBelowButton().exists, true)
//        inserRowBelowButton().tap()
//        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
//        XCTAssertTrue(firstTableTextField.waitForExistence(timeout: 5))
//        firstTableTextField.tap()
//        firstTableTextField.typeText("qu")
//        goBack()
//        XCTAssertEqual(firstTableTextField.value as! String, "qu")
//    }
    
    func testTableDetailView() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")
        
        let firstValueCount = app.textViews.countMatchingValue(firstTableTextField.value as? String ?? "")
        print("Number of textViews with value \"FirstA\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two textViews with value 'FirstA' (one in each form)")
        
    }
    
    func testTableChangeNumberCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let firstTableTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("2", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.clearText()
        
        firstTableTextField.typeText("12345")
        
        let firstValueCount = app.textFields.countMatchingValue(firstTableTextField.value as? String ?? "")
        print("Number of number fields with value \"12345\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two number fields with value '12345' (one in each form)")
    }
    
    func testTableChangeMultiCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let multiSelectionButtons = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButtons.count, 0)
        let firstButton = multiSelectionButtons.element(boundBy: 0)
        firstButton.tap()
        
        selectAllMultiSlectOptions()
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        
        goBack()
        
        let multiSelectionButton = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertGreaterThan(multiSelectionButton.count, 0)
        let firstButto = multiSelectionButton.element(boundBy: 0)
        firstButto.tap()
        
        let optionsButtons = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        let optionButton = optionsButtons.element(boundBy: 0)
        let optionButton2 = optionsButtons.element(boundBy: 1)
        let optionButton3 = optionsButtons.element(boundBy: 2)
        XCTAssertEqual(optionButton.value as? String, "Not selected")
        XCTAssertEqual(optionButton2.value as? String, "Selected")
        XCTAssertEqual(optionButton3.value as? String, "Selected")
    }
    
    func testTableChangeDropdownCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", dropdownButtons.element(boundBy: 0).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 0)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        goBack()
        
        let secdropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("No D1", secdropdownButtons.element(boundBy: 0).label)
    }
    
    func testTableChangeDateCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let dateButtons = app.buttons.matching(identifier: "1 Jun 2024")
        XCTAssertEqual(dateButtons.count, 4, "Date fields should exist")
        
        let dateField1 = dateButtons.element(boundBy: 0)
        dateField1.tap()
        
        // Format the expected date dynamically (handles iPhone/iPad differences)
        let formattedDate = formattedAccessibilityLabel(for: "2024-06-28")
        let newDateButton = app.buttons[formattedDate]
        XCTAssertTrue(newDateButton.exists, "Formatted date button should exist: \(formattedDate)")
        newDateButton.tap()
        app.buttons["PopoverDismissRegion"].tap()
        goBack()
        
        let secDateFields = app.buttons.matching(identifier: "28 Jun 2024")
        XCTAssertEqual(secDateFields.count, 1, "Date fields should exist")
    }
    
    func testTableChangeImageCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage(index: 0)
        
        let imageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(imageButtons.count, 0, "Image buttons should exist")
        
        let firstImageButton = imageButtons.element(boundBy: 0)
        firstImageButton.tap()
        
        let uploadImageButton = app.buttons["ImageUploadImageIdentifier"]
        if uploadImageButton.exists {
            uploadImageButton.tap()
            dismissSheet()
        }
        goBack()
        
        let secImageButtons = app.buttons.matching(identifier: "TableImageIdentifier")
        XCTAssertGreaterThan(secImageButtons.count, 0, "Image buttons should exist")
        
        let imageButton = imageButtons.element(boundBy: 0)
        imageButton.tap()
        
        let allImages = app.images.matching(identifier: "DetailPageImageSelectionIdentifier")
        
        let circleImages = allImages.matching(NSPredicate(format: "label == %@", "circle"))
        
        let circleCount = circleImages.count
        XCTAssertEqual(circleCount, 1)
    }
    
    func testTableNumberTextField() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("2", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("12")
        XCTAssertEqual("212", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText(".0")
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        thirdTextField.tap()
        thirdTextField.typeText(".001")
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        fourthTextField.tap()
        fourthTextField.typeText("22")
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        goBack()
        let secondFirstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("212", secondFirstTextField.value as! String)
    }
    
    // Test case for filter data
    func testSearchFilterForNumberTextField() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "2")
        
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText("12")
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        thirdTextField.tap()
        thirdTextField.typeText(".22")
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        goBack()
        XCTAssertEqual("2", firstTextField.value as! String)
        XCTAssertEqual("2212", secondTextField.value as! String)
        XCTAssertEqual("200.22", thirdTextField.value as! String)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
    }
    
    // Insert row with filter text
    func testInsertRowWithFilterNumberTextField() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "22")
        
        let filterDataTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        app.buttons["TableAddRowIdentifier"].firstMatch.tap()
        
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        goBack()
        // Check inserted row data
        let insertedTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 6)
        XCTAssertEqual("22", insertedTextField.value as! String)
        insertedTextField.tap()
        app.swipeDown()
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        
        let insertedTextFieldDataAfterClearFilter = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", insertedTextFieldDataAfterClearFilter.value as! String)
        
        let thirdTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("32", fifthTextField.value as! String)
    }
    
    // Add Row with filter text
    func testAddRowWithFilterNumberField() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "22")
        
        let filterDataTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("22", filterDataTextField.value as! String)
        filterDataTextField.tap()
        app.buttons["TableAddRowIdentifier"].firstMatch.tap()
        
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        // Check inserted row data
        let insertedTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("22", insertedTextField.value as! String)
        
        // Clear filter
        app.buttons["HideFilterSearchBar"].tap()
        app.swipeDown()
        goBack()
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("22", secondTextField.value as! String)
        secondTextField.tap()
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("200", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        let addRowTextFieldDataAfterClearFilter = tapOnNumberTextField(atIndex: 6)
        XCTAssertEqual("22", addRowTextFieldDataAfterClearFilter.value as! String)
    }
    
    // Bulk Edit - Single row
    func testBulkEditNumberFieldSingleRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.typeText("1234.56")
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        XCTAssertEqual("21234.56", firstTextField.value as! String)
        goBack()
        let secondfirstCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("21234.56", secondfirstCellTextValue.value as! String)
    }
    
    // Bulk Edit - Edit all Rows
    func testBulkEditNumberFieldEditAllRows() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.typeText("123.345")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        for i in 0..<6 {
            let textField = tapOnNumberTextField(atIndex: i)
            XCTAssertEqual("123.345", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
        
        goBack()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let firstCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier")
        for i in 0..<6 {
            let cell = firstCellTextValue.element(boundBy: i)
            XCTAssertTrue(cell.exists, "Cell at index \(i) should exist")
            let value = cell.value as? String
            XCTAssertEqual(value, "123.345", "Cell \(i) should have value “123.345”, but was \(value ?? "nil")")
        }
    }
    
    // Sorting Test case
    func testSortingNumberField() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        
        tapOnNumberFieldColumn()
        
        // Sort in ascending order - First time click
        app.buttons["SortButtonIdentifier"].tap()
        
        // Check data after sorting in ascending order
        XCTAssertEqual("2", firstTextField.value as! String)
        
        let secondTextField = tapOnNumberTextField(atIndex: 1)
        XCTAssertEqual("2.111", secondTextField.value as! String)
        
        let thirdTextField = tapOnNumberTextField(atIndex: 2)
        XCTAssertEqual("22", thirdTextField.value as! String)
        
        let fourthTextField = tapOnNumberTextField(atIndex: 3)
        XCTAssertEqual("32", fourthTextField.value as! String)
        
        let fifthTextField = tapOnNumberTextField(atIndex: 4)
        XCTAssertEqual("102", fifthTextField.value as! String)
        
        let sixthTextField = tapOnNumberTextField(atIndex: 5)
        XCTAssertEqual("200", sixthTextField.value as! String)
        
        // Sort in descending order - Second time click
        app.buttons["SortButtonIdentifier"].tap()
        
        XCTAssertEqual("200", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("12")
        XCTAssertEqual("102", secondTextField.value as! String)
        secondTextField.tap()
        secondTextField.typeText(".34")
        XCTAssertEqual("32", thirdTextField.value as! String)
        XCTAssertEqual("22", fourthTextField.value as! String)
        XCTAssertEqual("2.111", fifthTextField.value as! String)
        XCTAssertEqual("2", sixthTextField.value as! String)
        
        // Remove sort - Third time click
        app.buttons["SortButtonIdentifier"].tap()
        
        XCTAssertEqual("2", firstTextField.value as! String)
        XCTAssertEqual("22", secondTextField.value as! String)
        XCTAssertEqual("20012", thirdTextField.value as! String)
        XCTAssertEqual("2.111", fourthTextField.value as! String)
        XCTAssertEqual("102.34", fifthTextField.value as! String)
        XCTAssertEqual("32", sixthTextField.value as! String)
        
        goBack()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Check edited cell value - change on sorting time
        let thirdCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 2)
        let fifthCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("20012", thirdCellTextValue.value as! String)
        XCTAssertEqual("102.34", fifthCellTextValue.value as! String)
    }
    
    // Bulk single edit test case
    func testBulkEditDateFieldSingleRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
    }
    
    // Change selected time
    func testChangeTimePicker() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let headerTimeLabel = app.buttons.matching(identifier: "12:00 AM").element(boundBy: 0)
        XCTAssertTrue(headerTimeLabel.exists, "Expected to see the time header before switching to wheels")
        headerTimeLabel.tap()
        
        let hourPicker = app.pickerWheels.element(boundBy: 0)
        let minutePicker = app.pickerWheels.element(boundBy: 1)
        let periodPicker = app.pickerWheels.element(boundBy: 2)
        
        hourPicker.adjust(toPickerWheelValue: "1")
        minutePicker.adjust(toPickerWheelValue: "02")
        periodPicker.adjust(toPickerWheelValue: "PM")
        XCUIApplication().buttons["PopoverDismissRegion"].tap()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let checkSelectedTimeValue = app.buttons.matching(identifier: "1:02 PM").element(boundBy: 0)
        XCTAssertTrue(checkSelectedTimeValue.exists)
        
    }
    
    // Change existing value
    func testChangeMultiSelectionOptionValue() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        // Access identifier
        let multiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 0).label)
        XCTAssertEqual("No", multiFieldIdentifier.element(boundBy: 1).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 2).label)
        
        // Tap on Selection button
        let clickOnFirstCell = multiFieldIdentifier.element(boundBy: 0)
        clickOnFirstCell.tap()
        
        // Access Option Value identifier
        let multiValueOptions = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertGreaterThan(multiValueOptions.count, 0)
        
        // Tap on value options
        for i in 0...2 {
            let tapOnEachOption = multiValueOptions.element(boundBy: i)
            tapOnEachOption.tap()
        }
        
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        // Check selected value in cell
        XCTAssertEqual("No, +1", multiFieldIdentifier.element(boundBy: 0).label)
        goBack()
        XCTAssertEqual("No, +1", multiFieldIdentifier.element(boundBy: 0).label)
    }
    
    // Bulk Edit - Single Row edit
    func testMultiSelectionBulkEditOnSingleRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.buttons["EditRowsMultiSelecionFieldIdentifier"].tap()
        
        let multiValueOptions = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertGreaterThan(multiValueOptions.count, 0)
        // Tap on value options
        for i in 0...2 {
            let tapOnEachOption = multiValueOptions.element(boundBy: i)
            tapOnEachOption.tap()
        }
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        
        dismissSheet()
        
        let multiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 3).label)
        goBack()
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 3).label)
    }
    
    // Bulk Edit - All Row edit
    func testMultiSelectionBulkEditOnAllRows() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.buttons["EditRowsMultiSelecionFieldIdentifier"].tap()
        
        let multiValueOptions = app.buttons.matching(identifier: "TableMultiSelectOptionsSheetIdentifier")
        XCTAssertGreaterThan(multiValueOptions.count, 0)
        // Tap on value options
        for i in 0...2 {
            let tapOnEachOption = multiValueOptions.element(boundBy: i)
            tapOnEachOption.tap()
        }
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        let multiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 0).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 1).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 2).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 3).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 4).label)
        XCTAssertEqual("Yes, +2", multiFieldIdentifier.element(boundBy: 5).label)
        
        goBack()
        let secondMultiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 0).label)
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 1).label)
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 2).label)
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 3).label)
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 4).label)
        XCTAssertEqual("Yes, +2", secondMultiFieldIdentifier.element(boundBy: 5).label)
    }
    // Add row - Check defalut column value is set on added new row
    func testDefaultColumnValueOnAddRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        app.buttons["TableAddRowIdentifier"].firstMatch.tap()
        
        let addedCellBlockValue = app.staticTexts.matching(identifier: "TabelBlockFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("Block Column Value", addedCellBlockValue.label)
        
        let addedCellNumberValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 6)
        XCTAssertEqual("12345", addedCellNumberValue.value as! String)
        
        let multiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 6).label)
        
        let barcodeFieldIdentifier = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 6)
        XCTAssertEqual("Default value", barcodeFieldIdentifier.value as! String)
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        XCTAssertEqual("Block Column Value", addedCellBlockValue.label)
        XCTAssertEqual("12345", addedCellNumberValue.value as! String)
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 6).label)
        XCTAssertEqual("Default value", barcodeFieldIdentifier.value as! String)
    }
    
    // Insert row - Check defalut column value is set on Inserted row
    func testInsertRowDefaultColumnValue() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableInsertRowIdentifier"].firstMatch.tap()
        
        let addedCellBlockValue = app.staticTexts.matching(identifier: "TabelBlockFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Block Column Value", addedCellBlockValue.label)
        
        let addedCellNumberValue =  app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("12345", addedCellNumberValue.value as! String)
        
        let multiFieldIdentifier = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier")
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 1).label)
        
        let barcodeFieldIdentifier = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Default value", barcodeFieldIdentifier.value as! String)
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        XCTAssertEqual("Block Column Value", addedCellBlockValue.label)
        XCTAssertEqual("12345", addedCellNumberValue.value as! String)
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 1).label)
        XCTAssertEqual("Default value", barcodeFieldIdentifier.value as! String)
    }
    
    // Simple add data in field and tap on scan button
    func testBarcodeScanButtonValue() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let firstTableTextField = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("First row", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("1 ")
        
        let secondTableTextField = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual("Second row", secondTableTextField.value as! String)
        secondTableTextField.tap()
        secondTableTextField.typeText("2 ")
        
        let thirdTableTextField = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 2)
        XCTAssertEqual("Third row", thirdTableTextField.value as! String)
        thirdTableTextField.tap()
        thirdTableTextField.typeText("3 ")
        
        app.scrollViews.otherElements.containing(.image, identifier:"TableScanButtonIdentifier").children(matching: .image).matching(identifier: "TableScanButtonIdentifier").element(boundBy: 3).tap()
        
        app.scrollViews.otherElements.containing(.image, identifier:"TableScanButtonIdentifier").children(matching: .image).matching(identifier: "TableScanButtonIdentifier").element(boundBy: 4).tap()
        
        let sixthTableTextField = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 5)
        XCTAssertTrue(sixthTableTextField.waitForExistence(timeout: 5),
                      "sixth field didn’t show up")
        sixthTableTextField.tap()
        sixthTableTextField.typeText("Six")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        sleep(2)
        let firstCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        let secondCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 1)
        let thirdCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 2)
        let fourthCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 3)
        let fifthCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 4)
        let sixthCellTextValue = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 5)
        XCTAssertEqual("1 First row", firstCellTextValue.value as! String)
        XCTAssertEqual("2 Second row", secondCellTextValue.value as! String)
        XCTAssertEqual("3 Third row", thirdCellTextValue.value as! String)
        XCTAssertEqual("", fourthCellTextValue.value as! String)
        XCTAssertEqual("", fifthCellTextValue.value as! String)
        XCTAssertEqual("Six", sixthCellTextValue.value as! String)
    }
    
    // Bulk Edit - Edit all Rows
    func testBulkEditBarcodeFieldEditAllRows() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textViews.matching(identifier: "EditRowsBarcodeFieldIdentifier").element(boundBy: 0)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.typeText("quick")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let textFields = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier")
        for i in 0..<6 {
            let textField = textFields.element(boundBy: i)
            XCTAssertEqual("quick", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
        
        goBack()
        for i in 0..<6 {
            let textField = textFields.element(boundBy: i)
            XCTAssertEqual("quick", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
    }
    
    // Bulk Edit - Edit Single Rows
    func testBulkEditBarcodeFieldEditSingleRows() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textViews.matching(identifier: "EditRowsBarcodeFieldIdentifier").element(boundBy: 0)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        textField.clearText()
        textField.typeText("Edit Single rows")
        
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let editTextFieldData = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Edit Single rowsFirst row", editTextFieldData.value as! String)
        
        goBack()
        XCTAssertEqual("Edit Single rowsFirst row", editTextFieldData.value as! String)
    }
    
    func testClearExistingSignature() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let signatureButtons = app.buttons.matching(identifier: "TableSignatureOpenSheetButton")
        let firstSignatureButton = signatureButtons.element(boundBy: 0)
        firstSignatureButton.tap()
        
        app.buttons["TableSignatureEditButton"].firstMatch.tap()
        drawSignatureLine()
        app.buttons["ClearSignatureIdentifier"].firstMatch.tap()
        app.buttons["SaveSignatureIdentifier"].firstMatch.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
    }
    
    func testSaveNewSignature() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let signatureButtons = app.buttons.matching(identifier: "TableSignatureOpenSheetButton")
        let tapOnSignatureButton = signatureButtons.element(boundBy: 1)
        tapOnSignatureButton.tap()
        
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        tapOnSignatureButton.tap()
        
        app.buttons["TableSignatureEditButton"].tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
    }
    
    func testDeleteAllRowsAndCheckColumnClickability() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        tapOnMoreButton()
        app.buttons["TableDeleteRowIdentifier"].firstMatch.tap()
        
        let selectallbuttonImage = XCUIApplication().images["SelectAllRowSelectorButton"]
        selectallbuttonImage.firstMatch.tap()
        XCTAssertTrue(selectallbuttonImage.firstMatch.label == "circle", "The button should initially display the 'circle' image")
        
        app.buttons["TableAddRowIdentifier"].firstMatch.tap()
        selectallbuttonImage.firstMatch.tap()
        XCTAssertTrue(selectallbuttonImage.firstMatch.label == "record.circle.fill", "The button should initially display the 'record.circle.fill' image")
        goBack()
        let editTextFieldData = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Default value", editTextFieldData.value as! String)
    }
    
    func testTableDeleteMovedUpRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let firstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        firstField.tap()
        firstField.typeText("Second")
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", dropdownButtons.element(boundBy: 1).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 1)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 1)
        firstOption.tap()
        
        tapOnMoveUpRowButton()
        checkMovedRowDataOfSecondRow()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableDeleteRowIdentifier"].firstMatch.tap()
        
        goBack()
        let secondFirstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertNotEqual(secondFirstField.value as! String, "Second")
    }
    
    // Delete Moved down row
    func testTableDeleteMovedDownRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let firstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        firstField.tap()
        firstField.typeText("Text")
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", dropdownButtons.element(boundBy: 3).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 3)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        tapOnMoveDownRowButton()
        checkMovedRowDataOfLastSecondRow()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        goBack()
        let secondFirstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertNotEqual(secondFirstField.value as! String, "Text")
    }
    
    // Delete row then add row
    func testTableDeleteAddRow() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        
        app.buttons["TableAddRowIdentifier"].firstMatch.tap()
        
        let firstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        firstField.tap()
        firstField.typeText("Text")
        
        let dropdownButtons = app.buttons.matching(identifier: "TableDropdownIdentifier")
        XCTAssertEqual("Select Option", dropdownButtons.element(boundBy: 3).label)
        let firstdropdownButton = dropdownButtons.element(boundBy: 3)
        firstdropdownButton.tap()
        let dropdownOptions = app.buttons.matching(identifier: "TableDropdownOptionsIdentifier")
        XCTAssertGreaterThan(dropdownOptions.count, 0)
        let firstOption = dropdownOptions.element(boundBy: 0)
        firstOption.tap()
        
        tapOnMoveDownRowButton()
        checkMovedRowDataOfLastSecondRow()
        
        goBack()
        let secondFirstField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual(secondFirstField.value as! String, "Text")
    }
    
    func testCheckMoveUpDownButtonDisable() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let checkButtons = app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton")
        checkButtons.element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        let moveUpButton = app.buttons["TableMoveUpRowIdentifier"].firstMatch
        XCTAssertFalse(moveUpButton.isEnabled)
        dismissSheet()
        checkButtons.element(boundBy: 0).tap()
        checkButtons.element(boundBy: 5).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        let moveDownButton = app.buttons["TableMoveDownRowIdentifier"].firstMatch
        XCTAssertFalse(moveDownButton.isEnabled)
    }
    
    func testInsertBelowTable() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        
        let checkButtons = app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton")
        checkButtons.element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        XCTAssertEqual(inserRowBelowButton().exists, true)
        inserRowBelowButton().tap()
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        firstTableTextField.tap()
        firstTableTextField.typeText("qu")
        goBack()
        XCTAssertEqual(firstTableTextField.value as! String, "qu")
    }
    
    func testDeleteAndMoveRowTable() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToTableDetailPage()
        goToTableDetailPage()
        let checkButtons = app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton")
        checkButtons.element(boundBy: 2).tap()
        checkButtons.element(boundBy: 3).tap()
        checkButtons.element(boundBy: 4).tap()
        checkButtons.element(boundBy: 5).tap()
        let moreButton = app.buttons["TableMoreButtonIdentifier"].firstMatch
        let moveUpButton = app.buttons["TableMoveUpRowIdentifier"].firstMatch
        let moveDownButton = app.buttons["TableMoveDownRowIdentifier"].firstMatch
        moreButton.tap()
        app.buttons["TableDeleteRowIdentifier"].tap()
        checkButtons.element(boundBy: 1).tap()
        moreButton.tap()
        moveUpButton.tap()
        checkButtons.element(boundBy: 0).tap()
        moreButton.tap()
        moveDownButton.tap()
        checkButtons.element(boundBy: 1).tap()
        moreButton.tap()
        inserRowBelowButton().tap()
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 2)
        firstTableTextField.tap()
        firstTableTextField.typeText("hello")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        goBack()
        checkButtons.element(boundBy: 2).tap()
        tapOnMoreButtonCollection()
        moveUpButton.tap()
        let CheckTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 1)
        XCTAssertEqual(CheckTextField.value as! String, "hello")
    }
}

extension XCUIElementQuery {
    func countMatchingValue(_ text: String) -> Int {
        var matchCount = 0
        for index in 0..<self.count {
            let element = self.element(boundBy: index)
            if let value = element.value as? String, value == text {
                matchCount += 1
            }
        }
        return matchCount
    }
}
