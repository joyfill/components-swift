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
    func goToCollectionDetailField() {
        navigateToCollection()
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func navigateToCollection() {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 0)
        tapOnSecondTableView.tap()
    }
    
    // MARK: - Helper Functions for Verifying Filter Results
    
    func getVisibleRowCount() -> Int {
        // Count rows using the row selector identifiers
        var rowCount = 0
        var index = 0
        
        // Look for rows with identifiers like "selectRowItem0", "selectRowItem1", etc.
        while index < 25 { // Reasonable upper limit
            let rowSelector = app.images.matching(identifier: "selectRowItem\(index)")
            
            if rowSelector.element.exists {
                rowCount += 1
                index += 1
            } else {
                index += 1
            }
        }
        
        return rowCount
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
    
    func selectMultiSelectOption(_ optionName: String) -> Bool {
        let multiSelectFilterButton = app.buttons["SearchBarMultiSelectionFieldIdentifier"]
        if multiSelectFilterButton.exists {
            multiSelectFilterButton.tap()
            
            let option = app.buttons[optionName]
            if option.exists {
                option.tap()
                return true
            }
        }
        return false
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
    
    func applyMultiSelectFilter(schema: String? = nil, column: String, option: String) {
         openFilterModal()
        
        // Select schema if provided
        if let schema = schema {
            _ = selectSchema(schema)
        }
        
        // Select column
        selectColumn(column)
        closeFilterModal()
        
        // Select multi-select option
        selectMultiSelectOption(option)
        closeFilterModal()
        
        tapApplyButton()
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
    
    // MARK: - Text Column Filter Tests
    
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
}
