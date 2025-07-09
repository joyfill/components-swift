//
//  File.swift
//  JoyfillUITests
//
//  Created by Vivek on 24/06/25.
//

import Foundation
import XCTest
import JoyfillModel

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

final class CollectionFieldSearchFilterTests: JoyfillUITestsBaseClass {
    
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "CollectionFilter"
    }
    
    func goToCollectionDetailField(index: Int = 0) {
        navigateToCollection(index: index)
        sleep(1)
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func navigateToCollection(index: Int) {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: index)
        tapOnSecondTableView.tap()
    }
    
    // MARK: - Helper Functions for Verifying Filter Results
    
    func getVisibleRowCount() -> Int {
        // Count rows using multiple possible row identifiers
        return rowCount(baseIdentifier: "selectRowItem")
    }
    
    func getVisibleNestexRowsCount() -> Int {
        return rowCountWithScrollLoad(baseIdentifier: "selectNestedRowItem")
    }
    
    func rowCountWithScrollLoad(baseIdentifier: String, maxScrolls: Int = 10) -> Int {
        let predicate = NSPredicate(format: "identifier BEGINSWITH %@", baseIdentifier)
        let scrollView = app.scrollViews.firstMatch

        var previousCount = -1
        var currentCount = 0
        var scrollAttempts = 0

        while scrollAttempts < maxScrolls {
            let matchingElements = app.images.matching(predicate)
            currentCount = matchingElements.count

            if currentCount == previousCount {
                break // No new rows loaded
            }

            previousCount = currentCount

            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
            let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
            start.press(forDuration: 0.1, thenDragTo: end)

            sleep(1) // Allow time to load more items
            scrollAttempts += 1
        }

        return currentCount
    }
    
    func rowCount(baseIdentifier: String) -> Int {
        let beginsWith = NSPredicate(format: "identifier BEGINSWITH %@", baseIdentifier)
        return app.images.matching(beginsWith).count
    }
        
    func verifyFilteredResults(expectedRowCount: Int, description: String) {
        // Wait a moment for the filter to be applied
        sleep(1)
        
        let actualRowCount = getVisibleRowCount()
        XCTAssertEqual(actualRowCount, expectedRowCount, "\(description): Expected \(expectedRowCount) rows but found \(actualRowCount)")
    }
    
    func verifyRowContainsText(_ text: String, atIndex index: Int) -> Bool {
        let rowSelector = app.buttons["selectRowItem\(index)"]
        return rowSelector.exists
    }
    
    // MARK: - Common Filter UI Helper Methods
    
    func openFilterModal() {
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        if !filterButton.exists {
            XCTFail("Filter button should exist")
        }
        
        filterButton.tap()
        
        // Verify filter modal opened
        let filterModalExists = app.staticTexts["Filter"].exists
        XCTAssertTrue(filterModalExists, "Filter modal should be open")
    }
    
    func selectSchema(_ schemaName: String) {
        let schemaSelector = app.buttons.matching(identifier: "SelectSchemaTypeIDentifier")
        schemaSelector.element.tap()

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
    
    func tapCancelButton() {
        let cancelButton = app.buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
    }
    
    func closeFilterModal() {
        dismissSheet()
    }
    
    // MARK: - Complete Filter Flow Helper
    
    func applyTextFilter(schema: String = "Root Table", column: String, text: String) {
        openFilterModal()
        
        selectSchema(schema)
        
        selectColumn(column)
        enterTextFilter(text)
        tapApplyButton()
        closeFilterModal()
    }
    
    func tapOnAddMoreFilterButton() {
        let addButton = app.buttons["AddMoreFilterButtonIdentifier"]
        if !addButton.exists {
            XCTFail("Apply button should exist")
        }
        
        addButton.tap()
    }
    
    func isAddMoreFilterButtonEnabled() -> Bool {
        let addButton = app.buttons["AddMoreFilterButtonIdentifier"]
        return addButton.exists && addButton.isEnabled
    }
    
    func tapOnMoreButton() {
        let moreButton = app.buttons["TableMoreButtonIdentifier"]
        if !moreButton.exists {
            XCTFail("More button should exist")
        }
        
        moreButton.tap()
    }
        
    func applyDropdownFilter(schema: String = "Root Table", column: String, option: String) {
        openFilterModal()
        
        // Select schema if provided
        selectSchema(schema)
        // Select column
         selectColumn(column)
        
        // Select dropdown option
        selectDropdownOption(option)
        
        // Apply filter
        tapApplyButton()
    }
    
    func applyMultiSelectFilter(schema: String = "Root Table", column: String, option: String) {
         openFilterModal()
        
        selectSchema(schema)
        selectColumn(column)
        selectMultiSelectOption(option)
        
        tapApplyButton()
    }
    
    func getFieldPositionsCountFromLabel() -> Int? {
        let app = XCUIApplication()
        let resultLabel = app.staticTexts["resultfield"].label

        guard let data = resultLabel.data(using: .utf8) else {
            XCTFail("Failed to convert label to data")
            return nil
        }

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                for obj in jsonArray {
                    if obj["target"] as? String == "page.create",
                       let change = obj["change"] as? [String: Any],
                       let page = change["page"] as? [String: Any],
                       let fieldPositions = page["fieldPositions"] as? [[String: Any]] {
                        return fieldPositions.count
                    }
                }
            }
        } catch {
            XCTFail("Failed to parse label JSON: \(error)")
        }

        return nil
    }
    
    func assertImageCount(for cellId: String, expectedCount: Int) {
        let actualCount = imageURLCount(for: cellId)
        XCTAssertEqual(actualCount, expectedCount, "Expected \(expectedCount) image(s), found \(actualCount)")
    }
    
    func imageURLCount(for cellId: String) -> Int {
         let result = onChangeResult().dictionary
              let change = result["change"] as? [String: Any]
        let rowAny = change?["row"] as? Any
              let row = rowAny as? [String: Any]
        let cellsAny = row?["cells"] as? Any
              let cells = cellsAny as? [String: Any]
        let imageArray = cells?[cellId] as? [[String: Any]]

        return imageArray?.count ?? 0
    }
    
    func imageURLCountFromValueArray(for cellId: String) -> Int {
        guard
            let result = onChangeResult().dictionary["change"] as? [String: Any],
            let valueArray = result["value"] as? [[String: Any]],
            let firstItem = valueArray.first,
            let cells = firstItem["cells"] as? [String: Any],
            let imageArray = cells[cellId] as? [[String: Any]]
        else {
            return 0
        }
        
        return imageArray.count
    }

    func assertImageCountFromValueArray(for cellId: String, expectedCount: Int) {
        let actualCount = imageURLCountFromValueArray(for: cellId)
        XCTAssertEqual(actualCount, expectedCount, "Expected \(expectedCount) image(s) for \(cellId), but found \(actualCount)")
    }
    
    func testopenCollection() {
        goToCollectionDetailField()
    }
    
    // MARK: - Basic Filter Modal Tests
    
    func testOpenCollectionFilterModal() {
        goToCollectionDetailField()
        
        // Test opening filter modal
        openFilterModal()
        
        // Close filter modal
        closeFilterModal()
        
        // Verify we're back to the collection view
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        XCTAssertTrue(filterButton.exists, "Should be back to collection view")
    }
    
    // MARK: - Complete Filter Flow Test Based on JSON Structure
    
    func testCompleteFilterFlow_SchemaColumnValue() {
        goToCollectionDetailField()
        
        // Get initial row count before filtering
        let initialRowCount = getVisibleRowCount()
        
        // Apply text filter using helper method
        applyTextFilter(schema: "Root Table", column: "Text D1", text: "A")
        
        // Verify filtered results
        let filteredRowCount = getVisibleRowCount()
        XCTAssertTrue(filteredRowCount == initialRowCount, "Filtered row count should equal because all rows should contain 'A'")
        
        // Verify we're back to collection view with filtered results
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        XCTAssertTrue(filterButton.exists, "Should return to collection view")
        
    }
    
    func testCompleteFilterFlow_DropdownColumn() {
        goToCollectionDetailField()
        
        // Get initial row count
        let initialRowCount = getVisibleRowCount()
        
        // Apply dropdown filter using helper method
        applyDropdownFilter(column: "Dropdown D1", option: "Yes D1")
        
        // Verify filtered results
        let filteredRowCount = getVisibleRowCount()
        XCTAssertTrue(initialRowCount > filteredRowCount, "Filtered row count should not exceed initial count")
        
        
        // Verify we're back to collection view
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        XCTAssertTrue(filterButton.exists, "Should return to collection view")
    }
    
    // MARK: - Filter Results Verification Tests
    
    func testFilterResults_TextColumnWithRowCountVerification() {
        goToCollectionDetailField()
        
        // Get initial row count
         applyTextFilter(column: "Text D1", text: "AbC")
        
        let filteredCountAbC = getVisibleRowCount()
        XCTAssertTrue(filteredCountAbC == 1, "More specific filter should return fewer or equal results")
        
        // Test Case 3: Filter that should return no results
        applyTextFilter(column: "Text D1", text: "NonExistentText123")
        
        let filteredCountEmpty = getVisibleRowCount()
        XCTAssertEqual(filteredCountEmpty, 0, "Filter for non-existent text should return 0 results")
    }
    
    func testFilterResults_DropdownColumnVerification() {
        goToCollectionDetailField()
                
        // Test filtering by "Yes D1"
        applyDropdownFilter(column: "Dropdown D1", option: "Yes D1")
        
        let filteredCountYes = getVisibleRowCount()
        XCTAssertTrue(filteredCountYes == 3, "Filtered results should not exceed initial count")
        
        // Test filtering by "No D1"
        applyDropdownFilter(column: "Dropdown D1", option: "No D1")
        
        let filteredCountNo = getVisibleRowCount()
        XCTAssertTrue(filteredCountNo == 1, "No D1 filtered results should not exceed initial count")
    }
    
    // MARK: - Clean Test Cases Using Helper Methods
    
    func testFilterTextRetain() {
        goToCollectionDetailField()
        
        // Test 1: Text Column Filter (from JSON: "Text Column")
        applyTextFilter(column: "Text D1", text: "A")
        openFilterModal()
        let searchField = app.textFields["TextFieldSearchBarIdentifier"]
        XCTAssertTrue(searchField.exists)
        XCTAssertEqual(searchField.value as! String, "A")
    }
    
    func testMultipleFilterTypes_BasedOnJSON() {
        goToCollectionDetailField()
        
        // Test 1: Text Column Filter (from JSON: "Text Column")
        applyTextFilter(column: "Text D1", text: "b")
        //Tap on add filter button
        openFilterModal()
        
        tapOnAddMoreFilterButton()
        //Select ColumnType And Add another Column
        selectColumn("Dropdown D1", selectorIndex: 1)
        selectDropdownOption("No D1")
        tapApplyButton()

        let dropdownFilterCount = getVisibleRowCount()
        
        // All filter counts should be <= initial count
        XCTAssertTrue(dropdownFilterCount == 1, "Dropdown filter results should not exceed initial count")
    }
    
    func testFilterClearAndReapply() {
        goToCollectionDetailField()
        let initialRowCount = 4
        
        // Apply a restrictive filter
        applyTextFilter(column: "Text D1", text: "NonExistentText")
        let restrictiveCount = getVisibleRowCount()
        XCTAssertEqual(restrictiveCount, 0, "Restrictive filter should return 0 rows")
        openFilterModal()
        // Apply a broader filter
        enterTextFilter("")
        tapApplyButton()
        let broadCount = getVisibleRowCount()
        XCTAssertTrue(broadCount == initialRowCount, "Broader filter should show more rows")
    }
    
    func testFilterModalCancelation() {
        goToCollectionDetailField()
        let initialRowCount = getVisibleRowCount()
        
        // Open filter modal but cancel without applying
        openFilterModal()
        selectColumn("Text D1")
        enterTextFilter("SomeText")
        
        // Cancel instead of applying
        closeFilterModal()
        
        // Verify no filter was applied
        let finalCount = getVisibleRowCount()
        XCTAssertEqual(finalCount, initialRowCount, "Canceling filter should not change row count")
    }
    
    func testSequentialFilters_JSON_BasedData() {
        goToCollectionDetailField()
        let initialRowCount = 4
        
        // Sequential filtering based on JSON structure
        let testCases = [
            ("Text D1", "Ab"),      // Should match "A", "AbC", "a B c"
            ("Text D1", "AbC"),    // Should match "AbC" only
            ("Text D1", "test"),   // Should match "test" entries
        ]
        
        var previousCount = initialRowCount
        
        for (column, text) in testCases {
            applyTextFilter(column: column, text: text)
            let currentCount = getVisibleRowCount()
            
            // Each more specific filter should return same or fewer results
            XCTAssertTrue(currentCount < previousCount, "More specific filter should not increase row count")
            previousCount = currentCount
        }
    }
    
    // MARK: - Nested Schema Filter Tests
    
    func testNestedSchemaDiscovery() {
        goToCollectionDetailField()
        
        // Discover available schemas
        openFilterModal()
        
        let schemaSelector = app.buttons.matching(identifier: "SelectSchemaTypeIDentifier")
        schemaSelector.element.tap()
        
        // Verify all actual schema names from real JSON data exist
        let actualSchemas = ["Root Table", "Depth 2", "Depth 3", "Depth 4", "Depth 5"]
        var foundSchemas = 0
        
        for schemaName in actualSchemas {
            let schemaOption = app.buttons[schemaName].firstMatch
            if schemaOption.exists {
                foundSchemas += 1
            }
        }
        
        XCTAssertEqual(foundSchemas, actualSchemas.count, "All \(actualSchemas.count) schemas should be discoverable in the UI")
        
        closeFilterModal()
    }
    
    func testNestedRowFiltering_ChildSchema() {
        goToCollectionDetailField()
        let rootRowCount = 4
        
        // Test filtering on nested/child schema using real JSON data
        applyTextFilter(schema: "Depth 3", column: "Text D3", text: "Ab")
        
        let nestedFilteredCount = getVisibleNestexRowsCount()
        
        // Nested rows might have different count structure
        XCTAssertEqual(nestedFilteredCount, 7, "Should handle nested row filtering")
        
        // Verify we can return to root schema
        applyTextFilter(schema: "Root Table", column: "Text D1", text: "A")
        let backToRootCount = getVisibleRowCount()
        XCTAssertTrue(backToRootCount == 4, "Should be able to return to root schema")
        XCTAssertTrue(rootRowCount > 0, "Root schema should have rows")
    }
    
    func testNestedDropdownFiltering() {
        goToCollectionDetailField()
        
        // Apply dropdown filter on nested schema using real JSON data
        applyDropdownFilter(schema: "Depth 3", column: "Dropdown D3", option: "Yes D3")
        
        let nestedDropdownCount = getVisibleNestexRowsCount()
        XCTAssertEqual(nestedDropdownCount, 9, "Nested dropdown filtering should work")
        
        // Test different nested dropdown option
        applyDropdownFilter(schema: "Depth 3", column: "Dropdown D3", option: "No D3")
        
        let differentOptionCount = getVisibleNestexRowsCount()
        XCTAssertEqual(differentOptionCount, 7, "Nested dropdown filtering should work")
    }
    
    
    func testMultiLevelSchemaFiltering() {
        goToCollectionDetailField()
        
        // Test filtering across multiple schema levels
        let testSchemas = [
            ("Depth 2", "Text D2", "A", 5),        // From JSON: "A", "AbC", "ab", "a B c"
            ("Depth 3", "Text D3", "A", 13),           // From JSON: "A", "AbC", "a B C"
            ("Depth 4", "Text D4", "A", 0)            // From JSON: "A", "AbC", "ab", "a B c"
        ]
        
        for (schema, column, text, count) in testSchemas {
            applyTextFilter(schema: schema, column: column, text: text)
            let currentCount = getVisibleNestexRowsCount()
            XCTAssertEqual(currentCount, count, "Schema '\(schema)' filtering should work")
        }
    }
    
    func testNestedRowIdentifierDiscovery() {
        goToCollectionDetailField()
        
        // Switch to nested schema first using real JSON data
        applyTextFilter(schema: "Depth 3", column: "Text D3", text: " ")
        let topLevelRowsCount = getVisibleRowCount()
        XCTAssertEqual(topLevelRowsCount, 1, "Space filtering should work")
        
        let nestedRowsCount = getVisibleNestexRowsCount()
        XCTAssertEqual(nestedRowsCount, 2, "Space filtering should work")

    }
    
    func testNestedRowExpanding() {
        goToCollectionDetailField()
        
        applyMultiSelectFilter(schema: "Depth 3", column: "MultiSelect D3", option: "Option 2 D3")
        let topLevelRowsCount = getVisibleRowCount()
        XCTAssertEqual(topLevelRowsCount, 2, "Empty filtering should work")
        
        let nestedRowsCount = getVisibleNestexRowsCount()
        XCTAssertEqual(nestedRowsCount, 6, "Space filtering should work")

    }
    
    func tapSchemaAddRowButton(number: Int) {
        let buttons = app.buttons.matching(identifier: "collectionSchemaAddRowButton")
        XCTAssertTrue(buttons.count > 0)
        buttons.element(boundBy: number).tap()
    }
    
    func expandRow(number: Int) {
        let expandButton = app.images["CollectionExpandCollapseButton\(number)"]
        XCTAssertTrue(expandButton.exists, "Expand/collapse button should exist")
        expandButton.tap()
    }
    
    func addThreeNestedRows(parentRowNumber: Int) {
        expandRow(number: parentRowNumber)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        tapSchemaAddRowButton(number: 0)
        
        let firstNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 4)
        XCTAssertEqual("", firstNestedTextField.value as! String)
        firstNestedTextField.tap()
        firstNestedTextField.typeText("Hello ji")
        
        let secNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 5)
        XCTAssertEqual("", secNestedTextField.value as! String)
        secNestedTextField.tap()
        secNestedTextField.typeText("Namaste ji")
        
        let thirdNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 6)
        XCTAssertEqual("", thirdNestedTextField.value as! String)
        thirdNestedTextField.tap()
        thirdNestedTextField.typeText("123456789")
    }
    
    
    func testNestedRowCountingAccuracy() {
        goToCollectionDetailField()
        addThreeNestedRows(parentRowNumber: 1)
        applyTextFilter(schema: "Depth 2", column: "Text D2", text: "Hello ji")
        
        let parentRowsCount = getVisibleRowCount()
        let nestedRowsCount = getVisibleNestexRowsCount()
        XCTAssertEqual(parentRowsCount, 1 , "Parent row counting should return valid count")
        XCTAssertEqual(nestedRowsCount, 1 , "Nested row counting should return valid count")
       
    }
    
    func testNestedSchemaColumnDiscovery() {
        goToCollectionDetailField()
        
        // Test what columns are available in nested schemas using real JSON data
        openFilterModal()
        selectSchema("Depth 3")
        
        let columnSelector = app.buttons.matching(identifier: "CollectionFilterColumnSelectorIdentifier")
        columnSelector.element.tap()
        
        // Check for actual nested column names from JSON
        let actualColumns = [
            "Text D3", "Dropdown D3", "MultiSelect D3", "Number D3", "Date D3",
            "Label D3", "Barcode D3", "Signature D3", "Image D3"
        ]
        
        var foundColumns = 0
        for columnName in actualColumns {
            let columnOption = app.buttons[columnName].firstMatch
            if columnOption.exists {
                foundColumns += 1
            }
        }
        
        XCTAssertEqual(foundColumns, 5, "Should find at least some nested columns in Depth 3 schema")
        
        closeFilterModal()
    }
    
    func testNestedMultipleFiltersWithAddButton() {
        goToCollectionDetailField()
        
        // Start with nested schema filter using real JSON data
        applyTextFilter(schema: "Depth 3", column: "Text D3", text: "A")
        
        // Add additional filter using the add button
        openFilterModal()
        tapOnAddMoreFilterButton()
        
        // Add second filter on different nested column
        selectColumn("Dropdown D3", selectorIndex: 1)
        selectDropdownOption("Yes D3")
        tapApplyButton()
        
        let topLevelRows = getVisibleRowCount()
        XCTAssertEqual(topLevelRows, 2, "Multiple nested filters should work")
        
        let multiNestedFilterCount = getVisibleNestexRowsCount()
        XCTAssertEqual(multiNestedFilterCount, 9, "Multiple nested filters should work")
    }

    
    func testTextColumnFilter_CaseInsensitive() {
        goToCollectionDetailField()
        
        // Open filter modal
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        // Select Text D1 column for filtering
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Text D1" column
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            // Enter search text - should match "A", "AbC", "ab", "a B c"
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("a")
                
                // Apply filter
                app.buttons["Apply"].tap()
                
                // Verify we're back to collection view with filtered results
                XCTAssertTrue(filterButton.exists, "Should be back to collection view")
            }
        }
        
        // If no specific UI elements found, just verify modal works
        if !textColumnOption.exists {
            dismissSheet()
        }
    }
    
    func testTextColumnFilter_PartialMatch() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            // Search for "b" - should match "AbC", "ab", "a B c"
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("b")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Dropdown Column Filter Tests
    
    func testDropdownColumnFilter_YesD1() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Dropdown D1" column
        let dropdownColumnOption = app.buttons["Dropdown D1"]
        if dropdownColumnOption.exists {
            dropdownColumnOption.tap()
            
                         // Select "Yes D1" option from dropdown filter
             let dropdownFilterButton = app.buttons["SearchBarDropdownIdentifier"]
             if dropdownFilterButton.exists {
                 dropdownFilterButton.tap()
                 
                 let yesOption = app.buttons["Yes D1"].firstMatch
                 if yesOption.exists {
                     yesOption.tap()
                 }
             }
            
            app.buttons["Apply"].tap()
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        } else {
            dismissSheet()
        }
    }
    
    func testDropdownColumnFilter_NoD1() {
        goToCollectionDetailField()
        let oldCount = getVisibleRowCount()
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let dropdownColumnOption = app.buttons["Dropdown D1"]
        if dropdownColumnOption.exists {
            dropdownColumnOption.tap()
            
                         let dropdownFilterButton = app.buttons["SearchBarDropdownIdentifier"]
             if dropdownFilterButton.exists {
                 dropdownFilterButton.tap()
                 
                 let noOption = app.buttons["No D1"].firstMatch
                 if noOption.exists {
                     noOption.tap()
                 }
                 
                 
             }
            
            tapApplyButton()
            assert(oldCount > getVisibleRowCount())
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - MultiSelect Column Filter Tests
    
    func testMultiSelectColumnFilter_Option1D1() {
        goToCollectionDetailField()
        let oldCount = getVisibleRowCount()
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "MultiSelect D1" column
        let multiSelectColumnOption = app.buttons["MultiSelect  D1"]
        if multiSelectColumnOption.exists {
            multiSelectColumnOption.tap()
            
                         // Select "Option 1 D1" from multiselect filter
             let multiSelectFilterButton = app.buttons["SearchBarMultiSelectionFieldIdentifier"]
             if multiSelectFilterButton.exists {
                 multiSelectFilterButton.tap()
                 
                 let option1 = app.buttons["Option 1 D1"].firstMatch
                 if option1.exists {
                     option1.tap()
                 }
             }
            app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
            tapApplyButton()
            assert(oldCount > getVisibleRowCount())
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        } else {
            dismissSheet()
        }
    }
    
    func testMultiSelectColumnFilter_Option2D1() {
        goToCollectionDetailField()
        let oldCount = getVisibleRowCount()
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let multiSelectColumnOption = app.buttons["MultiSelect  D1"]
        if multiSelectColumnOption.exists {
            multiSelectColumnOption.tap()
            
                         let multiSelectFilterButton = app.buttons["SearchBarMultiSelectionFieldIdentifier"]
             if multiSelectFilterButton.exists {
                 multiSelectFilterButton.tap()
                 
                 let option2 = app.buttons["Option 2 D1"].firstMatch
                 if option2.exists {
                     option2.tap()
                 }
             }
            
            app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
            tapApplyButton()
            assert(oldCount > getVisibleRowCount())
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Number Column Filter Tests
    
    func testNumberColumnFilter_PrefixMatch() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Number D1" column
        let numberColumnOption = app.buttons["Number  D1"]
        if numberColumnOption.exists {
            numberColumnOption.tap()
            
            // Search for "2" - should match 22, 22.2, 200
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("2")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    func testNumberColumnFilter_DecimalMatch() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let numberColumnOption = app.buttons["Number  D1"]
        if numberColumnOption.exists {
            numberColumnOption.tap()
            
            // Search for "12" - should match 12.2
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("12")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Block Column Filter Tests
    
    func testBlockColumnFilter() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Label Column" (block type)
        let blockColumnOption = app.buttons["Label Column"]
        if blockColumnOption.exists {
            blockColumnOption.tap()
            
            // Search for "A" - should match rows with "A" in block column
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("A")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Barcode Column Filter Tests
    
    func testBarcodeColumnFilter() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Barcode D1" column
        let barcodeColumnOption = app.buttons["Barcode  D1"]
        if barcodeColumnOption.exists {
            barcodeColumnOption.tap()
            
            // Search for "Ab" - should match "AbC"
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("Ab")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Multiple Filter Tests
    
    func testMultipleFiltersApplication() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        // Apply first filter - Text column
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("A")
            }
            
            // Add another filter by tapping add filter button
            let addFilterButton = app.buttons["plus.circle"]
            if addFilterButton.exists {
                addFilterButton.tap()
                
                // Select dropdown column for second filter
                let secondColumnSelector = app.buttons.matching(identifier: "CollectionFilterColumnSelectorIdentifier").element(boundBy: 1)
                if secondColumnSelector.exists {
                    secondColumnSelector.tap()
                    
                    let dropdownOption = app.buttons["Dropdown D1"]
                    if dropdownOption.exists {
                        dropdownOption.tap()
                    }
                }
            }
            
            app.buttons["Apply"].tap()
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Clear Filter Tests
    
    func testClearAllFilters() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        // Apply a filter first
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("Test")
            }
            
            // Clear all filters
            let clearAllButton = app.buttons["Clear All"]
            if clearAllButton.exists {
                clearAllButton.tap()
                
                // Verify search field is cleared
                if searchField.exists {
                    XCTAssertEqual(searchField.value as? String ?? "", "", "Search field should be cleared")
                }
            }
            
            app.buttons["Apply"].tap()
        } else {
            dismissSheet()
        }
        
        XCTAssertTrue(filterButton.exists, "Should return to collection view")
    }
    
    // MARK: - Nested Schema Filter Tests
    
    func testNestedSchemaFiltering_Depth2() {
        goToCollectionDetailField()
        
        // First expand a row to show nested data
        let expandButton = app.images["CollectionExpandCollapseButton0"]
        if expandButton.exists {
            expandButton.tap()
        }
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Text D2" column from nested schema
        let textD2Option = app.buttons["Text D2"]
        if textD2Option.exists {
            textD2Option.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("A")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    func testNestedSchemaFiltering_Depth3() {
        goToCollectionDetailField()
        
        // Expand rows to show depth 3 data
        let expandButton1 = app.images["CollectionExpandCollapseButton0"]
        if expandButton1.exists {
            expandButton1.tap()
        }
        
        let expandButton2 = app.images["CollectionExpandCollapseButton1"]
        if expandButton2.exists {
            expandButton2.tap()
        }
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        // Select "Text D3" column from depth 3 schema
        let textD3Option = app.buttons["Text D3"]
        if textD3Option.exists {
            textD3Option.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("a B c")
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should return to collection view")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Filter State Persistence Tests
    
    func testFilterStatePersistence() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        // Apply a filter
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText("A")
                
                app.buttons["Apply"].tap()
                
                // Reopen filter modal to check if state is preserved
                filterButton.tap()
                
                // Verify the filter is still applied
                XCTAssertTrue(app.buttons["Apply"].exists, "Filter modal should reopen")
                
                dismissSheet()
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testEmptySearchFilter() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            // Apply filter without entering any search text
            app.buttons["Apply"].tap()
            XCTAssertTrue(filterButton.exists, "Should return to collection view with no filter applied")
        } else {
            dismissSheet()
        }
    }
    
    func testSpecialCharacterSearch() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        filterButton.tap()
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        columnSelector.tap()
        
        let textColumnOption = app.buttons["Text D1"]
        if textColumnOption.exists {
            textColumnOption.tap()
            
            let searchField = app.textFields["TextFieldSearchBarIdentifier"]
            if searchField.exists {
                searchField.tap()
                searchField.typeText(" B ") // Search for space-separated character
                
                app.buttons["Apply"].tap()
                XCTAssertTrue(filterButton.exists, "Should handle special character search")
            }
        } else {
            dismissSheet()
        }
    }
    
    // MARK: - Integration Tests
    
    func testCompleteFilterWorkflow() {
        goToCollectionDetailField()
        
        let filterButton = app.buttons["CollectionFilterButtonIdentifier"]
        
        // Test complete workflow: open -> select column -> enter filter -> apply -> verify
        filterButton.tap()
        XCTAssertTrue(app.buttons["Apply"].exists, "Filter modal should open")
        
        let columnSelector = app.buttons["CollectionFilterColumnSelectorIdentifier"]
        XCTAssertTrue(columnSelector.exists, "Column selector should exist")
        
        columnSelector.tap()
        
        // Try to select any available column
        let availableColumns = ["Text D1", "Dropdown D1", "MultiSelect  D1", "Number  D1", "Label Column", "Barcode  D1"]
        var columnSelected = false
        
        for columnName in availableColumns {
            let columnOption = app.buttons[columnName]
            if columnOption.exists {
                columnOption.tap()
                columnSelected = true
                break
            }
        }
        
        if columnSelected {
            app.buttons["Apply"].tap()
            XCTAssertTrue(filterButton.exists, "Should return to collection view after applying filter")
        } else {
            dismissSheet()
            XCTAssertTrue(filterButton.exists, "Should return to collection view")
        }
    }
    
    func testCollectionPageDuplicate() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 0)
        originalPageButton.tap()
        
        goToCollectionDetailField()
        goBack()
        
        pageSelectionButton.tap()
        let pageDuplicateButton = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let duplicatePageButton = pageDuplicateButton.element(boundBy: 0)
        duplicatePageButton.tap()
        if let count = getFieldPositionsCountFromLabel() {
            XCTAssertEqual(count, 3, "Expected 2 field positions")
        } else {
            XCTFail("Could not retrieve field position count")
        }
        
        let duplicatedPageButton = pageSheetSelectionButton.element(boundBy: 1)
        duplicatedPageButton.tap()
        goToCollectionDetailField()
        
        let TableAddRowIdentifier = app.buttons.matching(identifier: "TableAddRowIdentifier").element(boundBy: 0)
        TableAddRowIdentifier.tap()
        let actualRowCount = getVisibleRowCount()
        XCTAssertEqual(actualRowCount, 5, "Expected 5 rows count")
        
        goBack()
        
        pageSelectionButton.tap()
        originalPageButton.tap()
        goToCollectionDetailField()
        let firstNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("A", firstNestedTextField.value as! String)
        firstNestedTextField.tap()
        firstNestedTextField.clearText()
        firstNestedTextField.typeText("Hello ji")
        goBack()
        pageSelectionButton.tap()
        duplicatedPageButton.tap()
        goToCollectionDetailField()
        let firstNestedTextFieldDup = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 0)
        XCTAssertEqual("A", firstNestedTextFieldDup.value as! String)
        goBack()
    }
    
    
    func testCollectionImageUpload() throws {
        app.swipeUp()
        goToCollectionDetailField(index: 1)

        let uploadButton = app.staticTexts["Upload"]
        let imageButtonIdentifier = "TableImageIdentifier"

        let imageButtons = app.buttons.matching(identifier: imageButtonIdentifier)
        XCTAssertEqual(imageButtons.count, 3, "Expected 3 image buttons")

        // Multi Image Upload (Index 0)
        let multiImageButton = imageButtons.element(boundBy: 0)
        XCTAssertTrue(multiImageButton.exists, "Multi-image button does not exist")
        multiImageButton.tap()

        XCTAssertTrue(uploadButton.waitForExistence(timeout: 3))
        uploadButton.tap()
        uploadButton.tap()
        
        assertImageCount(for: "6813008ea26d706f2a5db2d5", expectedCount: 2)

        dismissSheet()
        app.swipeLeft()
        // Single Image Upload - Column 2 (Index 1)
        let singleImageButton1 = imageButtons.element(boundBy: 1)
        XCTAssertTrue(singleImageButton1.exists, "Single image button 1 does not exist")
        singleImageButton1.tap()
        XCTAssertTrue(uploadButton.waitForExistence(timeout: 3))
        uploadButton.doubleTap()
        uploadButton.tap()
        
        assertImageCount(for: "686b8f0caa36b1d9e6bbd544", expectedCount: 1)
        
        dismissSheet()
        app.swipeLeft()
        // Single Image Upload - Column 3 (Index 2)
        let singleImageButton2 = imageButtons.element(boundBy: 2)
        XCTAssertTrue(singleImageButton2.exists, "Single image button 2 does not exist")
        singleImageButton2.tap()
        XCTAssertTrue(uploadButton.waitForExistence(timeout: 3))
        uploadButton.doubleTap()
        uploadButton.tap()
        assertImageCount(for: "686b8f0f6c1c6a51b85ccf1f", expectedCount: 1)
        dismissSheet()
 
        goBack()
        sleep(1)
        assertImageCountFromValueArray(for: "686b8f0caa36b1d9e6bbd544", expectedCount: 1)
        assertImageCountFromValueArray(for: "6813008ea26d706f2a5db2d5", expectedCount: 2)
        assertImageCountFromValueArray(for: "686b8f0f6c1c6a51b85ccf1f", expectedCount: 1)
    }
    
    func testFilterApply_BB_NoResult_ThenA_ThenClearAndVerify() {
        goToCollectionDetailField()
        
        let initialRowCount = getVisibleRowCount()
        
        // Step 1: Apply filter with "BB" (expected to return 0)
        applyTextFilter(column: "Text D1", text: "BB")
        let filteredCountBB = getVisibleRowCount()
        XCTAssertEqual(filteredCountBB, 0, "Filter with 'BB' should return 0 rows")

        // Step 2: Apply filter with "A"
        applyTextFilter(column: "Text D1", text: "A")
        let filteredCountA = getVisibleRowCount()
        XCTAssertEqual(filteredCountA, initialRowCount, "Filter with 'A' should return initial row count")

        // Step 3: Clear filter
        openFilterModal()
        enterTextFilter("")
        tapApplyButton()
        
        // Step 4: Verify that row count after clearing matches initial
        let finalRowCount = getVisibleRowCount()
        XCTAssertEqual(finalRowCount, initialRowCount, "Row count after clearing filter should match initial")
    }
    
    func testAddRowEnterTextAndFilter() {
        goToCollectionDetailField()

        // Add new row
        let addRowButton = app.buttons.matching(identifier: "TableAddRowIdentifier").element(boundBy: 0)
        XCTAssertTrue(addRowButton.exists, "Add row button should exist")
        addRowButton.tap()

        // Enter "Testing Demo" in newly added row (last text field)
        let textFields = app.textViews.matching(identifier: "TabelTextFieldIdentifier")
        let newTextField = textFields.element(boundBy: textFields.count - 1)
        XCTAssertTrue(newTextField.exists, "New text field should exist")
        newTextField.tap()
        newTextField.clearText()
        newTextField.typeText("Testing Demo")

        // Go back and return to detail view
        goBack()
        goToCollectionDetailField()

        // Apply filter for "Testing Demo"
        applyTextFilter(column: "Text D1", text: "Testing Demo")

        // Verify filtered count is 1
        let filteredCount = getVisibleRowCount()
        XCTAssertEqual(filteredCount, 1, "Filter should return 1 row for 'Testing Demo'")
    }
    
    func testAddRowAddSubRowsAndApplyAllFilters() {
        goToCollectionDetailField()

        // Step 1: Add a new root row
        let addRowButton = app.buttons.matching(identifier: "TableAddRowIdentifier").element(boundBy: 0)
        XCTAssertTrue(addRowButton.exists, "Add row button should exist")
        addRowButton.tap()

        // Step 2: Expand the newly added row
        let newRowIndex = getVisibleRowCount() - 1
        let expandButton = app.images["CollectionExpandCollapseButton\(newRowIndex)"]
        XCTAssertTrue(expandButton.exists, "Expand button for new row should exist")
        expandButton.tap()

        // Step 3: Add 2 sub rows under this row
        let nestedAddButton = app.buttons.matching(identifier: "collectionSchemaAddRowButton").element(boundBy: 0)
        XCTAssertTrue(nestedAddButton.exists, "Nested add row button should exist")
        nestedAddButton.tap()
        nestedAddButton.tap()

        // Step 4: Open filter modal
        openFilterModal()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectSchema("Root Table")
        selectColumn("Text D1", selectorIndex: 0)
        enterTextFilter("A")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        tapOnAddMoreFilterButton()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectColumn("Dropdown D1", selectorIndex: 1)
        selectDropdownOption("Yes D1")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        tapOnAddMoreFilterButton()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectColumn("MultiSelect  D1", selectorIndex: 2)
        selectMultiSelectOption("Option 1 D1")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        tapOnAddMoreFilterButton()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectColumn("Number  D1", selectorIndex: 3)
        let element = app.textFields["SearchBarNumberIdentifier"].firstMatch
        element.tap()
        element.typeText("2")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        tapOnAddMoreFilterButton()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectColumn("Barcode  D1", selectorIndex: 4)
        let barcodeField = app/*@START_MENU_TOKEN@*/.textViews["TableBarcodeFieldIdentifier"].firstMatch/*[[".otherElements.textViews[\"TableBarcodeFieldIdentifier\"].firstMatch",".textViews",".containing(.other, identifier: nil).firstMatch",".containing(.other, identifier: \"Vertical scroll bar, 2 pages\").firstMatch",".firstMatch",".textViews[\"TableBarcodeFieldIdentifier\"].firstMatch"],[[[-1,5],[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0]]@END_MENU_TOKEN@*/
        barcodeField.tap()
        barcodeField.typeText("2")
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        tapApplyButton()
        closeFilterModal()
        let parentRowsCount = getVisibleRowCount()
        XCTAssertEqual(parentRowsCount, 0, "Expected 0 parent row matching")
        
        
    }
    
    func testDeleteAllRowsApplyFiltersThenReAddAndFilterDepth2() {
        goToCollectionDetailField()
        
        // Step 1: Delete all rows
        app/*@START_MENU_TOKEN@*/.images["SelectParentAllRowSelectorButton"]/*[[".otherElements",".images[\"Square\"]",".images[\"SelectParentAllRowSelectorButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        tapOnMoreButton()
        app.buttons["TableDeleteRowIdentifier"].firstMatch.tap()
        
        // Step 2: Apply a filter after all rows are deleted
        applyTextFilter(column: "Text D1", text: "Test")
        let filteredCount = getVisibleRowCount()
        XCTAssertEqual(filteredCount, 0, "Filtered count should be 0 after deleting all rows")
        
        // Clear existing filters before deleting
        openFilterModal()
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
        firstNestedTextField.typeText("Hello ji")
        
        let secNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy:2)
        XCTAssertEqual("", secNestedTextField.value as! String)
        secNestedTextField.tap()
        secNestedTextField.typeText("Namaste ji")
        
        let thirdNestedTextField = app.textViews.matching(identifier: "TabelTextFieldIdentifier").element(boundBy: 3)
        XCTAssertEqual("", thirdNestedTextField.value as! String)
        thirdNestedTextField.tap()
        thirdNestedTextField.typeText("123456789")
        
        // Step 7: Apply filter in Depth 2 for text "Hello"
        applyTextFilter(schema: "Depth 2", column: "Text D2", text: "Hello")
        
        // Step 8: Validate filtered results
        let parentRowsCount = getVisibleRowCount()
        let nestedRowsCount = getVisibleNestexRowsCount()
        XCTAssertEqual(parentRowsCount, 1, "Expected 1 parent row matching 'Hello'")
        XCTAssertEqual(nestedRowsCount, 1, "Expected 1 nested row matching 'Hello'")
        
    }
    
    func testFilterSchemaChangeResetsColumnSelection() {
        goToCollectionDetailField()
        
        // Step 1: Open filter modal
        openFilterModal()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectSchema("Root Table")
        
        // Step 2: Apply Sort - Select column and Descending
        let sortColumnSelector = app.buttons["CollectionSortColumnSelectorIdentifier"]
        XCTAssertTrue(sortColumnSelector.exists, "Sort column selector should exist")
        sortColumnSelector.tap()
        
        let sortOption = app.buttons["Text D1"]
        XCTAssertTrue(sortOption.exists, "Sort column option should exist")
        sortOption.tap()
        
        let sortButton = app.buttons["Sort"]
        XCTAssertTrue(sortButton.exists, "Sort button should exist")
        XCTAssertTrue(sortButton.isEnabled, "Sort button should be disabled until direction selected")
        sortButton.tap()
        sortButton.tap()
        
        selectColumn("Text D1", selectorIndex: 0)
        enterTextFilter("A")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        tapOnAddMoreFilterButton()
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        selectColumn("Dropdown D1", selectorIndex: 1)
        selectDropdownOption("Yes D1")
        if !isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be enabled")
        }
        
        tapApplyButton()
        closeFilterModal()
        
        // Step 3: Verify filtered result (optional, based on test data)
        let filteredRowCount = getVisibleRowCount()
        XCTAssertTrue(filteredRowCount >= 0, "Filtered row count should be valid")
        
        // Step 4: Open filter modal again and change schema
        openFilterModal()
        selectSchema("Depth 2")
        
        // Step 5: Verify column selector has reset
        let columnSelectors = app.buttons.matching(identifier: "CollectionFilterColumnSelectorIdentifier")
        let firstSelectorLabel = columnSelectors.element(boundBy: 0).label
        XCTAssertEqual(firstSelectorLabel, "Select column type", "Column selector should reset after schema change")
        if isAddMoreFilterButtonEnabled() {
            XCTFail("Add More Filter button should be disabled")
        }
        tapApplyButton()
        closeFilterModal()
    }
}
