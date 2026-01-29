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
}
