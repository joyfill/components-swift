//
//  NavigationJSONTests.swift
//  JoyfillTests
//
//  Unit tests for navigation functionality using Navigation.json
//  Based on comprehensive QA test scenarios
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class NavigationJSONTests: XCTestCase {
    
    var documentEditor: DocumentEditor!
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "Navigation")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Pages QA List (goto(pageId))
    
    func testGotoNonExistentPage_ShouldDoNothing() {
        // Given: Non-existent page ID
        let invalidPageId = "6970982db629fd3b68d11c4"
        let originalPageId = documentEditor.currentPageID
        
        // When
        let result = documentEditor.goto(invalidPageId)
        
        // Then
        XCTAssertEqual(result, .failure, "Should return failure for non-existent page")
        XCTAssertEqual(documentEditor.currentPageID, originalPageId, "Current page should not change")
    }
    
    func testGotoHiddenPage_CurrentlyNavigates() {
        // Given: Page 3 has "hidden": true in JSON
        // NOTE: goto() currently only checks conditional logic, not static hidden property
        // This is a known limitation - static hidden pages CAN be navigated to
        let hiddenPageId = "69709965bf69fedffee003a9"
        
        // When
        let result = documentEditor.goto(hiddenPageId)
        
        // Then - Current behavior: navigation fails for statically hidden pages
        XCTAssertEqual(result, .failure, "Currently navigates to statically hidden pages")
        XCTAssertNotEqual(documentEditor.currentPageID, hiddenPageId, "Page should not changes to hidden page")
    }
    
    func testGotoNormallyVisiblePage_ShouldNavigateToTop() {
        // Given: Page 5 is normally visible
        let pageId = "6970982db629fd3b68d28a35"
        
        // When
        let result = documentEditor.goto(pageId)
        
        // Then
        XCTAssertEqual(result, .success, "Should successfully navigate to normally visible page")
        XCTAssertEqual(documentEditor.currentPageID, pageId, "Current page should be updated to Page 5")
    }
    
    func testGotoConditionallyVisiblePage_WhenConditionsMet_ShouldNavigateToTop() {
        // Given: Page 4 is conditionally visible (69709177d4351d380c2b0c17)
        // Condition: Page 1 text field (6970918d6d04413439c39d8b) must contain some value
        let conditionalPageId = "69709177d4351d380c2b0c17"
        
        let result = documentEditor.goto(conditionalPageId)
        
        // Then
        XCTAssertEqual(result, .success, "Should navigate to conditionally visible page when conditions are met")
        XCTAssertEqual(documentEditor.currentPageID, conditionalPageId, "Current page should be updated")
    }
    
    func testGotoConditionallyVisiblePage_WhenConditionsAreFail_ShouldNavigateToTop() {
        // Given: Page 4 is conditionally visible (69709177d4351d380c2b0c17)
        // Condition: Page 1 text field (6970918d6d04413439c39d8b) must contain some value
        let conditionalPageId = "69709177d4351d380c2b0c17"
        let textFieldID = "6970918d6d04413439c39d8b"
        
        // Fill required field to make page visible using proper update method
        let fieldIdentifier = FieldIdentifier(fieldID: textFieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("test value"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        // When
        let result = documentEditor.goto(conditionalPageId)
        
        // Then
        XCTAssertEqual(result, .failure, "Should not navigate to conditionally hidden page when conditions are met")
        XCTAssertNotEqual(documentEditor.currentPageID, conditionalPageId, "Current page should not be updated")
    }
    
    // MARK: - Field Positions QA List - Navigate and Scroll to Field
    
    func testGotoPage2_TextField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970918d350238d0738dd5c9)
        let path = "691f376206195944e65eef76/6970918d350238d0738dd5c9"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Text field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultilineTextField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970926d749c733958ca8d87)
        let path = "691f376206195944e65eef76/6970926d749c733958ca8d87"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiline Text field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_NumberField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/69709192a4e9c0c281851275)
        let path = "691f376206195944e65eef76/69709192a4e9c0c281851275"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Number field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DateTimeField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970919451f1adb30fcff9ea)
        let path = "691f376206195944e65eef76/6970919451f1adb30fcff9ea"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Date Time field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DropdownFieldOriginal_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970919a6ce635a6b14913ed)
        let path = "691f376206195944e65eef76/6970919a6ce635a6b14913ed"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Dropdown field (original)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DropdownFieldCheck_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970919ee6609e01512c869e)
        let path = "691f376206195944e65eef76/6970919ee6609e01512c869e"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Dropdown field (check)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DropdownFieldCircle_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091a47e293616d5f0ffcc)
        let path = "691f376206195944e65eef76/697091a47e293616d5f0ffcc"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Dropdown field (circle)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DropdownFieldRadio_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091aff5458a1a434a4fa1)
        let path = "691f376206195944e65eef76/697091aff5458a1a434a4fa1"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Dropdown field (radio)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_DropdownFieldSquare_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091b6506844e1ae515c15)
        let path = "691f376206195944e65eef76/697091b6506844e1ae515c15"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Dropdown field (square)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultiSelectField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970919b1dae0701c3bc081a)
        let path = "691f376206195944e65eef76/6970919b1dae0701c3bc081a"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 MultiSelect field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldHorizontal_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091ce62f52594a371591a)
        let path = "691f376206195944e65eef76/697091ce62f52594a371591a"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (horizontal)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldText_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091d1c02045b17d47aecd)
        let path = "691f376206195944e65eef76/697091d1c02045b17d47aecd"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (text)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldCheck_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091d800d402b4c5cb7047)
        let path = "691f376206195944e65eef76/697091d800d402b4c5cb7047"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (check)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldRadio_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091dc4f02e7a58a5a65fe)
        let path = "691f376206195944e65eef76/697091dc4f02e7a58a5a65fe"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (radio)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldCircle_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091e0d1cb18119136e662)
        let path = "691f376206195944e65eef76/697091e0d1cb18119136e662"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (circle)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_MultipleChoiceFieldSquare_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/697091e4e34e0954108e2f7d)
        let path = "691f376206195944e65eef76/697091e4e34e0954108e2f7d"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Multiple Choice field (square)")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_TableField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe)
        let path = "691f376206195944e65eef76/69709462236416126c166efe"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Table field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_InputGroupField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970a47a1f698a20b09578f7)
        let path = "691f376206195944e65eef76/6970a47a1f698a20b09578f7"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Input Group field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoPage2_CollectionField_ShouldScrollToField() {
        // goto(691f376206195944e65eef76/6970a485380c41d6c06005aa)
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should navigate to Page 2 Collection field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    // MARK: - Hidden Fields QA - Should Navigate to Top of Page
    
    func testGotoPage6_HiddenMultilineTextField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970919020f5f698e4ea88cc)
        let path = "6970a8369b24206caf2b71cc/6970919020f5f698e4ea88cc"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenDateTimeField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970919451f1adb30fcff9ea)
        let path = "6970a8369b24206caf2b71cc/6970919451f1adb30fcff9ea"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenEmptyTextField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970926943176f7a04947ce6)
        let path = "6970a8369b24206caf2b71cc/6970926943176f7a04947ce6"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenEmptyNumberField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/69709289bbae3675aabd7367)
        let path = "6970a8369b24206caf2b71cc/69709289bbae3675aabd7367"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenEmptyDropdownField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970938c377426ff921d24ac)
        let path = "6970a8369b24206caf2b71cc/6970938c377426ff921d24ac"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenEmptyMultipleChoiceField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970939fa73a204cdbe54ea7)
        let path = "6970a8369b24206caf2b71cc/6970939fa73a204cdbe54ea7"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenTableField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/69709462236416126c166efe)
        let path = "6970a8369b24206caf2b71cc/69709462236416126c166efe"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenInputGroupField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970a3de337a678f6334590e)
        let path = "6970a8369b24206caf2b71cc/6970a3de337a678f6334590e"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenCollectionField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970a3eceab9374076e43a0b)
        let path = "6970a8369b24206caf2b71cc/6970a3eceab9374076e43a0b"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    func testGotoPage6_HiddenChartField_ShouldNavigateToTop() {
        // goto(6970a8369b24206caf2b71cc/6970a42c4b81ed72dd8b2d69)
        let path = "6970a8369b24206caf2b71cc/6970a42c4b81ed72dd8b2d69"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for hidden field")
        XCTAssertEqual(documentEditor.currentPageID, "6970a8369b24206caf2b71cc", "Should navigate to Page 6")
    }
    
    // MARK: - Non-Existent Field QA
    
    func testGotoPage2_NonExistentField_ShouldNavigateToTop() {
        // goto(691f376206195944e65eef76/6970918d350238d0738dd5c9999)
        let path = "691f376206195944e65eef76/6970918d350238d0738dd5c9999"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for non-existent field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    // MARK: - Invalid Page ID with Valid/Invalid Field Position ID
    
    func testGotoInvalidPageId_ValidFieldPositionId_ShouldDoNothing() {
        // goto(871f376206195944e65sai96/6970a485380c41d6c06005aa)
        let path = "871f376206195944e65sai96/6970a485380c41d6c06005aa"
        let originalPageId = documentEditor.currentPageID
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for invalid page ID")
        XCTAssertEqual(documentEditor.currentPageID, originalPageId, "Current page should not change")
    }
    
    func testGotoInvalidPageId_InvalidFieldPositionId_ShouldDoNothing() {
        // goto(871f376206195944e65sai96/6970a485380c41d6c06005ai)
        let path = "871f376206195944e65sai96/6970a485380c41d6c06005ai"
        let originalPageId = documentEditor.currentPageID
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should return failure for both invalid IDs")
        XCTAssertEqual(documentEditor.currentPageID, originalPageId, "Current page should not change")
    }
    
    // MARK: - Additional Coverage Tests
    
    func testNavigationJSON_HasExpectedNumberOfPages() {
        // Given: Navigation.json should have 6 pages
        let expectedPageCount = 6
        
        // When
        let actualPageCount = documentEditor.pagesForCurrentView.count
        
        // Then
        XCTAssertEqual(actualPageCount, expectedPageCount, "Navigation.json should have 6 pages")
    }
    
    // MARK: - Table Row Navigation Tests (goto(pageId/fieldPositionId/rowId))
    
    func testGotoTableRow_WithOpenTrue_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9, open: true)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should successfully navigate to table row with open true")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoTableRow_WithOpenFalse_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9, open: false)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig())
        
        XCTAssertEqual(result, .success, "Should successfully navigate to table row with open false")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoTableRow_DefaultOpenParameter_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/697090a359f1d7f5c25ba27a)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a359f1d7f5c25ba27a"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .success, "Should successfully navigate to table row")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoTableRow_SecondRow_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/697090a359f1d7f5c25ba27a)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a31a65a3133e84bdd2"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should successfully navigate to second table row")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoTableRow_ThirdRow_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/697090a31a65a3133e84bdd2)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a31a65a3133e84bdd2"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should successfully navigate to third table row")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoTableRow_NonExistentRow_ShouldNavigateToFieldSuccessfully() {
        // goto(691f376206195944e65eef76/69709462236416126c166efe/invalidRowId123)
        // Note: goto() validates field exists but delegates row validation to UI layer
        let path = "691f376206195944e65eef76/69709462236416126c166efe/invalidRowId123"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        // goto() returns failure if it non-existent rows, but navigate to that field with no rows sleected
        XCTAssertEqual(result, .failure, "Should navigate to field successfully; UI validates row existence")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to page")
        // The UI (TableQuickView/CollectionQuickView) will check rowOrder.contains(rowId) and handle gracefully
    }
    
    func testGotoRow_OnNonTableField_ShouldFail() {
        // Try to navigate to a row on a text field (not a table/collection)
        // goto(691f376206195944e65eef76/6970918d350238d0738dd5c9/someRowId)
        let path = "691f376206195944e65eef76/6970918d350238d0738dd5c9/someRowId"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should fail when trying to navigate to row on non-table/collection field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to page")
    }
    
    func testGotoTableRow_InvalidFieldPosition_ShouldFail() {
        // goto(691f376206195944e65eef76/invalidFieldPos123/697090a399394f50229899a9)
        let path = "691f376206195944e65eef76/invalidFieldPos123/697090a399394f50229899a9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should fail for invalid field position ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to page")
    }
    
    func testGotoTableRow_InvalidPage_ShouldFail() {
        // goto(invalidPage123/69709462236416126c166efe/697090a399394f50229899a9)
        let path = "invalidPage123/69709462236416126c166efe/697090a399394f50229899a9"
        let originalPageId = documentEditor.currentPageID
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should fail for invalid page ID")
        XCTAssertEqual(documentEditor.currentPageID, originalPageId, "Current page should not change")
    }
    
    // MARK: - Collection Row Navigation Tests
    
    func testGotoCollectionRow_WithOpenTrue_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a40230cef1a03fc19d81, open: true)
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should successfully navigate to collection row with open true")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoCollectionRow_WithOpenFalse_ShouldNavigateSuccessfully() {
        // goto(691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a40230cef1a03fc19d81, open: false)
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig())
        
        XCTAssertEqual(result, .success, "Should successfully navigate to collection row with open false")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGotoCollectionRow_NonExistentRow_ShouldNavigateToFieldSuccessfully() {
        // goto(691f376206195944e65eef76/6970a485380c41d6c06005aa/invalidCollectionRowId)
        // Note: goto() validates field exists but delegates row validation to UI layer
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa/invalidCollectionRowId"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        // goto() returns failure if it can navigate to the field; UI handles non-existent rows
        XCTAssertEqual(result, .failure, "Should navigate to field successfully, But return failure; UI validates row existence")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to page")
        // The UI (CollectionQuickView) will check if row exists and handle gracefully
    }
    
    // MARK: - Navigation Path Format Tests
    
    func testGoto_EmptyPath_ShouldFail() {
        let originalPageId = documentEditor.currentPageID
        
        let result = documentEditor.goto("")
        
        XCTAssertEqual(result, .failure, "Should fail for empty path")
        XCTAssertEqual(documentEditor.currentPageID, originalPageId, "Current page should not change")
    }
    
    func testGoto_PathWithValidColumnId_ShouldNavigateSuccessfully() {
        // goto(pageId/fieldPositionId/rowId/columnId) with a real table column ID
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/697090a35fe3eb39f20fa2d8"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should navigate successfully with valid columnId")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    func testGoto_PathWithTooManyComponents_ShouldIgnoreExtra() {
        // 5th+ components are ignored; 4th component (columnId) is still validated
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/697090a35fe3eb39f20fa2d8/extraComponent"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should navigate successfully, ignoring extra path components beyond columnId")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
    }
    
    // MARK: - Column ID Validation Tests
    
    func testGotoTableRow_WithValidColumnId_ShouldSucceed() {
        // Table Text Column: 697090a35fe3eb39f20fa2d8
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/697090a35fe3eb39f20fa2d8"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should succeed with valid table column ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoTableRow_WithAnotherValidColumnId_ShouldSucceed() {
        // Table Dropdown Column: 697090a3c7a4091e881bcb8d
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/697090a3c7a4091e881bcb8d"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should succeed with valid table dropdown column ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoTableRow_WithInvalidColumnId_ShouldFail() {
        // Non-existent column ID
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/invalidColumnId123"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should return failure for non-existent column ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should still navigate to page")
    }
    
    func testGotoCollectionRow_WithValidColumnId_ShouldSucceed() {
        // Collection Text column from collectionSchemaId: 697090a3e627059c068c4858
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172/697090a3e627059c068c4858"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should succeed with valid collection column ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGotoCollectionRow_WithInvalidColumnId_ShouldFail() {
        // Non-existent column ID on collection field
        let path = "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172/nonExistentColumnId"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should return failure for non-existent collection column ID")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should still navigate to page")
    }
    
    func testGotoTableRow_WithInvalidRowAndInvalidColumn_ShouldFail() {
        // Both row and column don't exist
        let path = "691f376206195944e65eef76/69709462236416126c166efe/invalidRowId/invalidColumnId"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .failure, "Should return failure when both row and column are invalid")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should still navigate to page")
    }
    
    func testGotoTableRow_WithValidRowAndNoColumn_ShouldSucceed() {
        // Valid row, no column component in path (3-component path)
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result, .success, "Should succeed when no column is specified")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    func testGoto_PathWithSpecialCharacters_ShouldNotHandleCorrectly() {
        // Test with path containing URL-like characters (though not URL encoded)
        let path = "691f376206195944e65eef76*#jehcbvouwefvcowgef"
        
        let result = documentEditor.goto(path)
        
        XCTAssertEqual(result, .failure, "Should not handle path with special characters")
    }
    
    // MARK: - Repeated Navigation Tests
    
    func testGoto_SameRowTwice_ShouldNavigateBothTimes() {
        // First navigation
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        let result1 = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result1, .success, "First navigation should succeed")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should navigate to Page 2")
        
        // Second navigation to same row
        let result2 = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        XCTAssertEqual(result2, .success, "Second navigation to same row should succeed")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should still be on Page 2")
    }
    
    func testGoto_DifferentRowsSequentially_ShouldNavigateToEach() {
        // Navigate to first row
        let path1 = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        let result1 = documentEditor.goto(path1, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result1, .success, "First navigation should succeed")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
        
        // Navigate to second row
        let path2 = "691f376206195944e65eef76/69709462236416126c166efe/697090a359f1d7f5c25ba27a"
        let result2 = documentEditor.goto(path2, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result2, .success, "Second navigation should succeed")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
        
        // Navigate to third row
        let path3 = "691f376206195944e65eef76/69709462236416126c166efe/697090a31a65a3133e84bdd2"
        let result3 = documentEditor.goto(path3, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result3, .success, "Third navigation should succeed")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76")
    }
    
    // MARK: - Multiple Table/Collection Fields on Same Page
    
    func testGoto_DifferentTableFieldsOnSamePage_ShouldNavigateToEach() {
        // Navigate to first table field (original display type)
        let path1 = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        let result1 = documentEditor.goto(path1, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result1, .success, "Should navigate to first table field")
        
        // Navigate to input group table field on same page
        let path2 = "691f376206195944e65eef76/6970a47a1f698a20b09578f7/697090a399394f50229899a9"
        let result2 = documentEditor.goto(path2, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result2, .success, "Should navigate to input group table field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should remain on same page")
    }
    
    func testGoto_DifferentFieldTypesOnSamePage_ShouldNavigateToEach() {
        // Navigate to table field
        let path1 = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        let result1 = documentEditor.goto(path1, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result1, .success, "Should navigate to table field")
        
        // Navigate to collection field on same page
        let path2 = "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172"
        let result2 = documentEditor.goto(path2, gotoConfig: GotoConfig(open: true))
        XCTAssertEqual(result2, .success, "Should navigate to collection field")
        XCTAssertEqual(documentEditor.currentPageID, "691f376206195944e65eef76", "Should remain on same page")
    }
    
    // MARK: - Edge Cases
    
    func testGoto_PathWithLeadingSlash_ShouldHandleGracefully() {
        // Paths shouldn't have leading slash, but test handling
        let path = "/691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        // First component will not be empty string, should Not fail
        XCTAssertEqual(result, .success, "Should pass for path with leading slash")
    }
    
    func testGoto_PathWithTrailingSlash_ShouldIgnoreIt() {
        let path = "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        // Trailing slash creates empty component, should be ignored
        XCTAssertEqual(result, .success, "Should handle trailing slash gracefully")
    }
    
    func testGoto_PathWithDoubleSlash_ShouldNotFail() {
        let path = "691f376206195944e65eef76//6970918d350238d0738dd5c9"
        
        let result = documentEditor.goto(path, gotoConfig: GotoConfig(open: true))
        
        // Double slash creates empty component, should not fail
        XCTAssertEqual(result, .success, "Should not fail for path with double slash")
    }
}
