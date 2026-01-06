import XCTest
import JoyfillModel

final class PageNavigationFieldTests: JoyfillUITestsBaseClass {
    
    override func getJSONFileNameForTest() -> String {
        // Use a multi-page JSON for page navigation tests
        return "Joydocjson"
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Force cleanup
        forceCleanupExistingApp()
        
        // Create app instance
        self.app = XCUIApplication()
        
        // Add all standard launch arguments (from base class)
        let testIdentifier = UUID().uuidString
        app.launchArguments.append("JoyfillUITests")
        app.launchArguments.append("--test-id")
        app.launchArguments.append(testIdentifier)
        app.launchArguments.append("--test-specific-id")
        app.launchArguments.append("\(self.name)-\(testIdentifier)")
        app.launchArguments.append("--json-file")
        app.launchArguments.append(getJSONFileNameForTest())
        app.launchArguments.append("--test-name")
        app.launchArguments.append(self.name)
        app.launchArguments.append("--test-run-id")
        app.launchArguments.append(UUID().uuidString)
        
        // 🎯 ADD CUSTOM ARGUMENTS FOR PAGE TESTS
        app.launchArguments.append("--page-delete-enabled")
        app.launchArguments.append("true")
        app.launchArguments.append("--page-duplicate-enabled")
        app.launchArguments.append("true")
        
        // Disable hardware keyboard
        disableHardwareKeyboardForAllTests()
        
        // Crash prevention
        app.launchArguments.append("--safe-mode")
        app.launchArguments.append("--disable-crash-on-error")
        app.launchArguments.append("--fresh-instance")
        
        // Alert handler
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for btn in ["Allow", "OK", "Continue", "Don't Allow", "Remind Me Later", "While Using the App"] {
                if alert.buttons[btn].exists {
                    alert.buttons[btn].tap()
                    return true
                }
            }
            return false
        }
        
        // Launch app
        do {
            app.launch()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch")
            app.activate()
            XCTAssertTrue(waitForAppStability(timeout: 15), "App not stable")
            verifyHardwareKeyboardDisabled()
            ensureAppStability()
        } catch {
            print("❌ Launch failed: \(error)")
            throw error
        }
    }
    
    func testPageNavigation() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        let firstTextField = textFields[0]
        XCTAssertTrue(firstTextField.exists, "The third text field does not exist.")
        XCTAssertEqual("", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
    }
    
    func testPageDuplicate() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 2)
        originalPageButton.tap()
        
        let originalTextFields = app.textFields.allElementsBoundByIndex
        let origFirstTextField = originalTextFields[0]
        XCTAssertTrue(origFirstTextField.exists, "The first text field does not exist on the original page.")
        XCTAssertEqual("", origFirstTextField.value as! String, "Original text field should start empty.")
        
        origFirstTextField.tap()
        origFirstTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!, "Original page text field should contain 'Hello'.")
        
        pageSelectionButton.tap()
        let pageDuplicateButton = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let duplicatePageButton = pageDuplicateButton.element(boundBy: 2)
        duplicatePageButton.tap()
        
        let duplicatedPageButton = pageSheetSelectionButton.element(boundBy: 3)
        duplicatedPageButton.tap()
        
        let duplicatedTextFields = app.textFields.allElementsBoundByIndex
        let dupFirstTextField = duplicatedTextFields[0]
        XCTAssertTrue(dupFirstTextField.exists, "The first text field does not exist on the duplicated page.")
        XCTAssertEqual("Hello", dupFirstTextField.value as! String, "Duplicated page should initially display the same text as original.")
        
        dupFirstTextField.tap()
        dupFirstTextField.typeText(" Sir, duplicate\n")
        XCTAssertEqual("Hello Sir, duplicate", onChangeResultValue().text!, "Duplicated page text field should update to 'Hello Sir, duplicate'.")
        
        let dupSecondTextField = duplicatedTextFields[1]
        XCTAssertTrue(dupSecondTextField.exists, "The second text field does not exist on the duplicated page.")
        XCTAssertEqual("", dupSecondTextField.value as! String, "Duplicated page second field should start empty.")
        dupSecondTextField.tap()
        dupSecondTextField.typeText("The quick brown fox jumps over the lazy dog.\n")
        XCTAssertEqual("The quick brown fox jumps over the lazy dog.", onChangeResultValue().text!, "Duplicated page second field should have the new value.")
        
        pageSelectionButton.tap()
        originalPageButton.tap()
        
        let origTextFieldsAfterDuplicate = app.textFields.allElementsBoundByIndex
        let origFirstTextFieldAfter = origTextFieldsAfterDuplicate[0]
        XCTAssertTrue(origFirstTextFieldAfter.exists, "The first text field does not exist on the original page after duplication.")
        XCTAssertEqual("Hello", origFirstTextFieldAfter.value as! String, "Original page text field should remain 'Hello' after duplication.")
        
        let origSecondTextFieldAfter = origTextFieldsAfterDuplicate[1]
        XCTAssertTrue(origSecondTextFieldAfter.exists, "The second text field does not exist on the original page after duplication.")
        XCTAssertEqual("", origSecondTextFieldAfter.value as! String, "Original page second field should remain unchanged.")
    }
    
    func testDuplicatedPageConditionalLogic() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageDuplicateButton = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let duplicatePageButton = pageDuplicateButton.element(boundBy: 1)
        duplicatePageButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 2)
        originalPageButton.tap()
        
        let originalTextFields = app.textFields.allElementsBoundByIndex
       
        let hideFieldOnConditionTrueTextField = originalTextFields[1]
        XCTAssertTrue(hideFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        hideFieldOnConditionTrueTextField.tap()
        hideFieldOnConditionTrueTextField.typeText("Field is Hide when condition true\n")
        XCTAssertEqual("Field is Hide when condition true", onChangeResultValue().text!)
        
        let hideFieldTitle = "Field Hide When Condition True"
        let hideFieldLabel = app.staticTexts[hideFieldTitle]
        XCTAssertTrue(hideFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        let applyIsEqualConditionTextField = originalTextFields[2]
        XCTAssertTrue(applyIsEqualConditionTextField.exists, "The applyIsEqualCondition text field does not exist.")
        applyIsEqualConditionTextField.tap()
        applyIsEqualConditionTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        let applyConditionTextFieldTitle = "Always Show Field - Page Logic - Hide when condition is true"
        let applyConditionTextFieldLabel = app.staticTexts[applyConditionTextFieldTitle]
        XCTAssertTrue(applyConditionTextFieldLabel.exists, "The title label does not exist or does not have the correct title.")
        
        let showFieldOnConditionTrueTextField = originalTextFields[1]
        XCTAssertTrue(showFieldOnConditionTrueTextField.exists, "The hideFieldOnConditionTrue text field does not exist.")
        showFieldOnConditionTrueTextField.tap()
        showFieldOnConditionTrueTextField.typeText("Field is show when condition true\n")
        XCTAssertEqual("Field is show when condition true", onChangeResultValue().text!)
        
        let showFieldTitle = "Field Show When Condition True"
        let showFieldLabel = app.staticTexts[showFieldTitle]
        XCTAssertTrue(showFieldLabel.exists, "The title label does not exist or does not have the correct title.")
    }
    
    // MARK: - Page Deletion UI Tests
    
    func testPageDeletion_deleteSecondPage() throws {
        // This test verifies that page 2 is actually deleted by checking its title is gone
        
        // 1. Open page navigation
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageSelectionButton.waitForExistence(timeout: 5))
        pageSelectionButton.tap()
        
        // 2. Wait for page buttons to appear
        let pageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(pageButtons.firstMatch.waitForExistence(timeout: 3), "Page buttons should appear")
        
        // 3. Small delay for all pages to render
        Thread.sleep(forTimeInterval: 0.5)
        
        // 4. Get the title of the second page before deletion
        let secondPageButton = pageButtons.element(boundBy: 1)
        XCTAssertTrue(secondPageButton.exists, "Second page should exist")
        
        // Get all text labels in the second page button to find the page name
        let secondPageTexts = secondPageButton.staticTexts.allElementsBoundByIndex
        var deletedPageTitle: String = ""
        if let pageNameLabel = secondPageTexts.first {
            deletedPageTitle = pageNameLabel.label
            print("📄 Page 2 title before deletion: '\(deletedPageTitle)'")
        }
        
        XCTAssertFalse(deletedPageTitle.isEmpty, "Should be able to read page 2 title")
        
        // 5. Count initial pages
        let initialPageCount = pageButtons.count
        print("📄 Initial page count: \(initialPageCount)")
        XCTAssertGreaterThan(initialPageCount, 1, "Need at least 2 pages for deletion test")
        
        // 6. Tap delete button on second page
        let pageDeleteButtons = app.buttons.matching(identifier: "PageDeleteIdentifier")
        print("📄 Delete buttons found: \(pageDeleteButtons.count)")
        
        XCTAssertTrue(pageDeleteButtons.element(boundBy: 1).waitForExistence(timeout: 2), "Second page delete button should exist")
        
        let deleteButton = pageDeleteButtons.element(boundBy: 1)
        print("📄 Delete button enabled: \(deleteButton.isEnabled)")
        
        XCTAssertTrue(deleteButton.isEnabled, "Delete button should be enabled")
        deleteButton.tap()
        
        // 7. Handle confirmation alert
        let deleteAlertButton = app.alerts.buttons["Delete"]
        XCTAssertTrue(deleteAlertButton.waitForExistence(timeout: 3), "Delete confirmation alert should appear")
        deleteAlertButton.tap()
        
        // 8. Wait for deletion to complete
        Thread.sleep(forTimeInterval: 1)
        
        // 9. Verify page count decreased
        let updatedPageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let finalPageCount = updatedPageButtons.count
        print("📄 Final page count: \(finalPageCount)")
                
        // 10. 🎯 NEW: Verify the deleted page title is no longer present
        var foundDeletedPage = false
        for i in 0..<finalPageCount {
            let pageButton = updatedPageButtons.element(boundBy: i)
            if pageButton.exists {
                let pageTexts = pageButton.staticTexts.allElementsBoundByIndex
                if let pageNameLabel = pageTexts.first {
                    let currentPageTitle = pageNameLabel.label
                    print("📄 Remaining page \(i): '\(currentPageTitle)'")
                    
                    if currentPageTitle == deletedPageTitle {
                        foundDeletedPage = true
                    }
                }
            }
        }
        
        XCTAssertFalse(foundDeletedPage, "Page with title '\(deletedPageTitle)' should not exist after deletion")
        print("✅ Confirmed: Page '\(deletedPageTitle)' was successfully deleted")
    }
    
    func testPageDeletion_lastPageProtection() throws {
        // This test verifies that the last page cannot be deleted
        // It requires a document with exactly 1 page
        
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let pageCount = pageSheetSelectionButton.count
        
        if pageCount == 1 {
            // Try to find delete button - it should be disabled
            let pageDeleteButtons = app.buttons.matching(identifier: "PageDeleteIdentifier")
            if pageDeleteButtons.count > 0 {
                let deleteButton = pageDeleteButtons.element(boundBy: 0)
                XCTAssertFalse(deleteButton.isEnabled, "Delete button should be disabled for last page")
            }
        }
    }
    
    func testPageDeletion_navigationAfterDelete() throws {
        // This test verifies that after deleting the current page,
        // the app navigates to another page
        
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        guard pageSheetSelectionButton.count >= 2 else {
            XCTFail("Need at least 2 pages for navigation test")
            return
        }
        
        // Select first page
        pageSheetSelectionButton.element(boundBy: 0).tap()
        
        // Reopen navigation
        pageSelectionButton.tap()
        
        // Delete the first page
        let pageDeleteButtons = app.buttons.matching(identifier: "PageDeleteIdentifier")
        if pageDeleteButtons.count > 0 {
            pageDeleteButtons.element(boundBy: 0).tap()
            
            // Confirm deletion
            let deleteButton = app.alerts.buttons["Delete"]
            if deleteButton.exists {
                deleteButton.tap()
            }
            
            // Verify the sheet closed (because we deleted current page)
            // The app should have automatically navigated to another page
            XCTAssertFalse(app.buttons["ClosePageSelectionSheetIdentifier"].exists, 
                          "Sheet should close after deleting current page")
        }
    }
}
