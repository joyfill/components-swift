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
    
    func testChangeText() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
       
        let firstTableTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("A", firstTableTextField.value as! String)
        firstTableTextField.tap()
        firstTableTextField.typeText("First")

        let firstValueCount = app.textViews.countMatchingValue("FirstA")
        print("Number of textViews with value \"FirstA\": \(firstValueCount)")
        XCTAssertEqual(2, firstValueCount, "Expected exactly two textViews with value 'FirstA' (one in each form)")
    }
    
    func testChangeNumberCollection() {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return
        }
        goToCollectionView()
        goToCollectionView(index: 1)
       
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
        goToCollectionView(index: 1)
        
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
        goToCollectionView(index: 1)
        
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
        goToCollectionView(index: 1)
        
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
        goToCollectionView(index: 1)
        
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
        goToCollectionView()
        goToCollectionView(index: 1)
        
        expandRow(number: 1)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        selectAllNestedRows()
        tapOnMoreButtonCollection()
        editRowsButton().tap()
        
        // Textfield
        let textField = app.textFields["EditRowsTextFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("Edit")
          
        // Tap on Apply All Button
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        goBack()
        expandRow(number: 1)
        sleep(1)
        let firstCellTextValue = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        for i in 2..<7 {
            let cell = firstCellTextValue.element(boundBy: i)
            XCTAssertTrue(cell.exists, "Cell at index \(i) should exist")
            let value = cell.value as? String
            XCTAssertEqual(value, "Edit", "Cell \(i) should have value “123.345”, but was \(value ?? "nil")")
        }
        
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
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        tapOnNumberFieldColumn()
        tapOnSearchBarTextField(value: "22")
        
        let filterDataTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("22", filterDataTextField.value as! String)
        
        tapOnMoreButton()
        app.buttons["TableInsertRowIdentifier"].tap()
         
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
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("1234.56")
        dismissSheet()
        sleep(1)
        
        XCTAssertEqual("21234.56", firstTextField.value as! String)
        goBack()
        let secondfirstCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("21234.56", secondfirstCellTextValue.value as! String)
    }
    
    // Bulk Edit - Edit all Rows
    func testBulkEditNumberFieldEditAllRows() throws {
        goToTableDetailPage()
        goToTableDetailPage()
        let firstTextField = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 0)
        firstTextField.tap()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textFields["EditRowsNumberFieldIdentifier"]
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("123.345")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
        for i in 0..<6 {
            let textField = tapOnNumberTextField(atIndex: i)
            XCTAssertEqual("123.345", textField.value as! String, "The text in field \(i+1) is incorrect")
        }
        
        goBack()
        sleep(1)
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
        sleep(1)
        
        // Check edited cell value - change on sorting time
        let thirdCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 2)
        let fifthCellTextValue = app.textFields.matching(identifier: "TabelNumberFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("20012", thirdCellTextValue.value as! String)
        XCTAssertEqual("102.34", fifthCellTextValue.value as! String)
    }
    
    // Bulk single edit test case
    func testBulkEditDateFieldSingleRow() throws {
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
        app.scrollViews.otherElements.images["EditRowsDateFieldIdentifier"].tap()
        dismissSheet()
        sleep(1)
        goBack()
    }
      
    // Change selected time
    func testChangeTimePicker() throws {
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
        
        sleep(1)
        goBack()
        sleep(1)
        let checkSelectedTimeValue = app.buttons.matching(identifier: "1:02 PM").element(boundBy: 0)
        XCTAssertTrue(checkSelectedTimeValue.exists)
        
    }
      
    // Change existing value
    func testChangeMultiSelectionOptionValue() throws {
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
        goToTableDetailPage()
        goToTableDetailPage()
                        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 3).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
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
        goToTableDetailPage()
        goToTableDetailPage()
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].tap()
        sleep(1)
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
        
        sleep(1)
        goBack()
        XCTAssertEqual("Block Column Value", addedCellBlockValue.label)
        XCTAssertEqual("12345", addedCellNumberValue.value as! String)
        XCTAssertEqual("Yes", multiFieldIdentifier.element(boundBy: 6).label)
        XCTAssertEqual("Default value", barcodeFieldIdentifier.value as! String)
    }
    
    // Insert row - Check defalut column value is set on Inserted row
    func testInsertRowDefaultColumnValue() throws {
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
        
        sleep(1)
        goBack()
        XCTAssertEqual("Second row", addedCellBlockValue.label)
        XCTAssertEqual("22", addedCellNumberValue.value as! String)
        XCTAssertEqual("No", multiFieldIdentifier.element(boundBy: 1).label)
        XCTAssertEqual("Second row", barcodeFieldIdentifier.value as! String)
    }
     
    // Simple add data in field and tap on scan button
    func testBarcodeScanButtonValue() throws {
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
        sixthTableTextField.tap()
        sixthTableTextField.typeText("Sixth Row")
        
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
        XCTAssertEqual("Sixth Row", sixthCellTextValue.value as! String)
    }
    
    // Bulk Edit - Edit all Rows
    func testBulkEditBarcodeFieldEditAllRows() throws {
        goToTableDetailPage()
        goToTableDetailPage()
        
        tapOnMoreButton()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textViews.matching(identifier: "EditRowsBarcodeFieldIdentifier").element(boundBy: 0)
        sleep(1)
        textField.tap()
        sleep(1)
        textField.typeText("quick")
        
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        sleep(1)
        
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
        goToTableDetailPage()
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].firstMatch.tap()
        app.buttons["TableEditRowsIdentifier"].firstMatch.tap()
        
        let textField = app.textViews.matching(identifier: "EditRowsBarcodeFieldIdentifier").element(boundBy: 0)
        sleep(1)
        textField.tap()
        sleep(1)
        textField.clearText()
        textField.typeText("Edit Single rows")
        
        dismissSheet()
        sleep(1)
        
        let editTextFieldData = app.textViews.matching(identifier: "TableBarcodeFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("Edit Single rowsFirst row", editTextFieldData.value as! String)
        
        goBack()
        XCTAssertEqual("Edit Single rowsFirst row", editTextFieldData.value as! String)
    }
    
    func testClearExistingSignature() throws {
        goToTableDetailPage()
        goToTableDetailPage()
        
        let signatureButtons = app.buttons.matching(identifier: "TableSignatureOpenSheetButton")
        let firstSignatureButton = signatureButtons.element(boundBy: 0)
        firstSignatureButton.tap()
        
        app.buttons["TableSignatureEditButton"].firstMatch.tap()
        drawSignatureLine()
        app.buttons["ClearSignatureIdentifier"].firstMatch.tap()
        app.buttons["SaveSignatureIdentifier"].firstMatch.tap()
        sleep(1)
        goBack()
    }
    
    func testSaveNewSignature() throws {
        goToTableDetailPage()
        goToTableDetailPage()
        
        let signatureButtons = app.buttons.matching(identifier: "TableSignatureOpenSheetButton")
        let tapOnSignatureButton = signatureButtons.element(boundBy: 1)
        tapOnSignatureButton.tap()
        
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        sleep(1)
        tapOnSignatureButton.tap()
        
        app.buttons["TableSignatureEditButton"].tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        
        sleep(1)
        goBack()
    }
    
    func testDeleteAllRowsAndCheckColumnClickability() throws {
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
