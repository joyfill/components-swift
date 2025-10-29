import XCTest
import Joyfill
import JoyfillModel

final class ReadonlyModeUITestCases: JoyfillUITestsBaseClass {
    
    override func getJSONFileNameForTest() -> String {
        return "PageNavigationTest"
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    // MARK: - Helper Methods
    
    /// Navigate to a specific page by index
    func navigateToPage(at index: Int) {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageSelectionButton.waitForExistence(timeout: 5), "Page navigation button should exist")
        pageSelectionButton.tap()
        
        Thread.sleep(forTimeInterval: 0.3) // Allow sheet to appear
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(pageSheetSelectionButton.element(boundBy: index).exists, "Page at index \(index) should exist")
        pageSheetSelectionButton.element(boundBy: index).tap()
    }
    
    /// Get all duplicate page buttons
    func getDuplicatePageButtons() -> XCUIElementQuery {
        return app.buttons.matching(identifier: "PageDuplicateIdentifier")
    }
    
    /// Check if duplicate page button exists at a specific index
    func isDuplicateButtonVisible(at index: Int) -> Bool {
        let duplicateButtons = getDuplicatePageButtons()
        return duplicateButtons.element(boundBy: index).exists
    }
    
    /// Count visible duplicate page buttons
    func getVisibleDuplicateButtonsCount() -> Int {
        let duplicateButtons = getDuplicatePageButtons()
        return duplicateButtons.count
    }
    
    /// Open page navigation sheet
    func openPageNavigationSheet() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageSelectionButton.waitForExistence(timeout: 5), "Page navigation button should exist")
        pageSelectionButton.tap()
        Thread.sleep(forTimeInterval: 0.3) // Allow sheet to appear
    }
    
    /// Close page navigation sheet by swiping down
    func closePageNavigationSheet() {
        swipeSheetDown()
        Thread.sleep(forTimeInterval: 0.3)
    }
    
    // MARK: - Test Cases
    
    /// Test that duplicate page button is visible in fill mode
    func testDuplicateButtonVisibleInFillMode() throws {
        openPageNavigationSheet()
        
        let duplicateButtons = getDuplicatePageButtons()
        let duplicateButtonCount = duplicateButtons.count
                
        XCTAssertTrue(duplicateButtonCount > 0, "Duplicate page buttons should be visible in fill mode")
        
        for i in 0..<min(duplicateButtonCount, 3) {
            let button = duplicateButtons.element(boundBy: i)
            XCTAssertTrue(button.exists, "Duplicate button at index \(i) should exist in fill mode")
        }
        
        closePageNavigationSheet()
    }
    
    func testDuplicateButtonVisibilityInFillMode() throws {
        openPageNavigationSheet()
        
        let duplicateButtons = getDuplicatePageButtons()
        let duplicateButtonCount = duplicateButtons.count
                
        XCTAssertTrue(duplicateButtonCount > 0, "Duplicate page buttons SHOULD be visible in fill mode")
        
        for i in 0..<min(duplicateButtonCount, 3) {
            let button = duplicateButtons.element(boundBy: i)
            XCTAssertTrue(button.exists, "Duplicate button at index \(i) should exist in fill mode")
        }
        
        closePageNavigationSheet()
    }
    
    func testDuplicateButtonFunctionalityInFillMode() throws {
        navigateToPage(at: 0)
        
        openPageNavigationSheet()
        let initialPageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialPageCount = initialPageButtons.count
        
        let duplicateButtons = getDuplicatePageButtons()
        XCTAssertTrue(duplicateButtons.element(boundBy: 0).exists, "First duplicate button should exist")
        duplicateButtons.element(boundBy: 0).tap()
        
        Thread.sleep(forTimeInterval: 0.5) // Allow page duplication to complete
        
        // Verify page was duplicated
        let updatedPageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let updatedPageCount = updatedPageButtons.count
        
        XCTAssertEqual(updatedPageCount, initialPageCount + 1, "Page count should increase by 1 after duplication")
        
        closePageNavigationSheet()
    }
    
    func testAllPagesHaveDuplicateButtonsInFillMode() throws {
        openPageNavigationSheet()
        
        let pageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let duplicateButtons = getDuplicatePageButtons()
        
        let pageCount = pageButtons.count
        let duplicateCount = duplicateButtons.count
        
        XCTAssertEqual(duplicateCount, pageCount, "Each page should have a duplicate button in fill mode")
        
        // Verify each duplicate button is accessible
        for i in 0..<duplicateCount {
            let button = duplicateButtons.element(boundBy: i)
            XCTAssertTrue(button.exists, "Duplicate button \(i) should exist")
            XCTAssertTrue(button.isHittable, "Duplicate button \(i) should be hittable")
        }
        
        closePageNavigationSheet()
    }
    
    func testDuplicateButtonPropertiesInFillMode() throws {
        openPageNavigationSheet()
        
        let duplicateButtons = getDuplicatePageButtons()
        
        // Test first duplicate button properties
        if duplicateButtons.count > 0 {
            let firstButton = duplicateButtons.element(boundBy: 0)
            
            XCTAssertTrue(firstButton.exists, "First duplicate button should exist")
            XCTAssertTrue(firstButton.isEnabled, "First duplicate button should be enabled")
            XCTAssertTrue(firstButton.isHittable, "First duplicate button should be hittable")
        } else {
            XCTFail("No duplicate buttons found in fill mode")
        }
        
        closePageNavigationSheet()
    }
}

final class ReadonlyModeSpecificTests: JoyfillUITestsBaseClass {
    
    override func getJSONFileNameForTest() -> String {
        return "PageNavigationTest"
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Force cleanup of any existing app instance
        forceCleanupExistingApp()
        
        // Create a completely fresh app instance for each test
        self.app = XCUIApplication()
        
        // Add unique test identifier to prevent state conflicts
        let testIdentifier = UUID().uuidString
        app.launchArguments.append("JoyfillUITests")
        app.launchArguments.append("--test-id")
        app.launchArguments.append(testIdentifier)
        
        // Add test-specific arguments to prevent interference
        app.launchArguments.append("--test-specific-id")
        app.launchArguments.append("\(self.name)-\(testIdentifier)")
        
        // Pass the JSON file name to the app via launch arguments
        app.launchArguments.append("--json-file")
        app.launchArguments.append(getJSONFileNameForTest())
        
        // Pass the current test name to the app
        app.launchArguments.append("--test-name")
        app.launchArguments.append(self.name)
        
        // Add a unique identifier for this test run to avoid conflicts
        app.launchArguments.append("--test-run-id")
        app.launchArguments.append(UUID().uuidString)
        
        // **IMPORTANT: Set mode to READONLY for these tests**
        app.launchArguments.append("--mode")
        app.launchArguments.append("readonly")
                
        // Automatically disable hardware keyboard for all UI tests
        disableHardwareKeyboardForAllTests()
        
        // Add crash prevention arguments
        app.launchArguments.append("--safe-mode")
        app.launchArguments.append("--disable-crash-on-error")
        
        // Add fresh instance flag
        app.launchArguments.append("--fresh-instance")
        
        // Global alert/permission handler
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for btn in ["Allow", "OK", "Continue", "Don't Allow", "Remind Me Later", "While Using the App"] {
                if alert.buttons[btn].exists {
                    alert.buttons[btn].tap()
                    return true
                }
            }
            return false
        }
        
        do {
            app.launch()
            
            // Wait for app to be running and stable
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch properly")
            
            app.activate()
            
            // Additional wait to ensure app is fully loaded
            XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
            
            // Verify hardware keyboard is disabled
            verifyHardwareKeyboardDisabled()
            
            // Wait for app to be stable before proceeding
            if !waitForAppStability(timeout: 15) {
                print("⚠️  App is not stable, attempting recovery")
                handleExitCodeIssue()
            }
            
            // Check if app is stable
            ensureAppStability()
            
            // Verify fresh app instance
            verifyFreshAppInstance()
            
            // Check if test is being skipped
            checkTestSkipped()
            
            print("✅ Fresh app instance created in READONLY mode for test: \(self.name)")
        } catch {
            print("⚠️  App launch failed: \(error)")
        }
    }
    

    func openPageNavigationSheet() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageSelectionButton.waitForExistence(timeout: 5), "Page navigation button should exist")
        pageSelectionButton.tap()
        Thread.sleep(forTimeInterval: 0.3) // Allow sheet to appear
    }
    
    /// Close page navigation sheet by swiping down
    func closePageNavigationSheet() {
        swipeSheetDown()
        Thread.sleep(forTimeInterval: 0.3)
    }
    
    /// Get all duplicate page buttons
    func getDuplicatePageButtons() -> XCUIElementQuery {
        return app.buttons.matching(identifier: "PageDuplicateIdentifier")
    }
    
    // MARK: - Readonly Mode Tests
    
    /// Test that duplicate page button is NOT visible in readonly mode
    func testDuplicateButtonNotVisibleInReadonlyMode() throws {
        openPageNavigationSheet()
        
        let duplicateButtons = getDuplicatePageButtons()
        let duplicateButtonCount = duplicateButtons.count
                
        XCTAssertEqual(duplicateButtonCount, 0, "Duplicate page buttons should NOT be visible in readonly mode")
        
        for i in 0..<5 {
            let button = duplicateButtons.element(boundBy: i)
            XCTAssertFalse(button.exists, "Duplicate button at index \(i) should NOT exist in readonly mode")
            print("✅ Duplicate button \(i) is correctly hidden in readonly mode")
        }
        
        closePageNavigationSheet()
    }
    
    func testPageNavigationWorksInReadonlyMode() throws {
        openPageNavigationSheet()
        
        let pageButtons = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let pageCount = pageButtons.count
        
        XCTAssertTrue(pageCount > 0, "Should have at least one page")
        
        // Verify we can navigate to different pages
        if pageCount > 1 {
            // Navigate to second page
            pageButtons.element(boundBy: 1).tap()
            Thread.sleep(forTimeInterval: 0.3)
                        
            openPageNavigationSheet()
            pageButtons.element(boundBy: 0).tap()
            Thread.sleep(forTimeInterval: 0.3)
        }
        
        closePageNavigationSheet()
    }
    
    func testFieldsNotEditableInReadonlyMode() throws {
        let textFields = app.textFields
        let textFieldCount = textFields.count
                
        if textFieldCount > 0 {
            let firstTextField = textFields.element(boundBy: 0)
            
            // In readonly mode, text fields should either:
            // 1. Not be editable, or
            // 2. Not exist (replaced with static text)
            
            if firstTextField.exists {
                // Check if it's enabled for interaction
                let isEnabled = firstTextField.isEnabled
                XCTAssertFalse(isEnabled, "Text field should be disable.")
                
                // Readonly fields might still exist but should not be editable
                // This depends on implementation - some readonly implementations
                // disable fields, others replace them with static text
            } else {
                print("✅ Text fields are correctly hidden/replaced in readonly mode")
            }
        }
    }
    
    /// Test that duplicate button identifier doesn't exist in readonly mode
    func testDuplicateButtonIdentifierNotFoundInReadonlyMode() throws {
        openPageNavigationSheet()
        
        let duplicateButtons = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        
        XCTAssertEqual(duplicateButtons.count, 0, "No elements should have PageDuplicateIdentifier in readonly mode")
        
        let firstButton = duplicateButtons.element(boundBy: 0)
        XCTAssertFalse(firstButton.exists, "First duplicate button should not exist in readonly mode")
                
        closePageNavigationSheet()
    }
}

final class PageDuplicateDisabledTests: JoyfillUITestsBaseClass {
    
    override func getJSONFileNameForTest() -> String {
        return "PageNavigationTest"
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Force cleanup of any existing app instance
        forceCleanupExistingApp()
        
        // Create a completely fresh app instance for each test
        self.app = XCUIApplication()
        
        // Add unique test identifier to prevent state conflicts
        let testIdentifier = UUID().uuidString
        app.launchArguments.append("JoyfillUITests")
        app.launchArguments.append("--test-id")
        app.launchArguments.append(testIdentifier)
        
        // Pass the JSON file name to the app via launch arguments
        app.launchArguments.append("--json-file")
        app.launchArguments.append(getJSONFileNameForTest())
        
        // Pass the current test name to the app
        app.launchArguments.append("--test-name")
        app.launchArguments.append(self.name)
        
        // **IMPORTANT: Disable page duplication**
        app.launchArguments.append("--page-duplicate-enabled")
        app.launchArguments.append("false")
                
        // Automatically disable hardware keyboard for all UI tests
        disableHardwareKeyboardForAllTests()
        
        // Add crash prevention arguments
        app.launchArguments.append("--safe-mode")
        app.launchArguments.append("--disable-crash-on-error")
        
        // Add fresh instance flag
        app.launchArguments.append("--fresh-instance")
        
        do {
            app.launch()
            XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15), "App did not launch properly")
            app.activate()
            XCTAssertTrue(waitForAppStability(timeout: 15), "App did not become stable")
            print("✅ App launched with page duplication disabled")
        } catch {
            print("⚠️  App launch failed: \(error)")
        }
    }
    
    /// Open page navigation sheet
    func openPageNavigationSheet() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageSelectionButton.waitForExistence(timeout: 5), "Page navigation button should exist")
        pageSelectionButton.tap()
        Thread.sleep(forTimeInterval: 0.3)
    }
    
    /// Close page navigation sheet
    func closePageNavigationSheet() {
        swipeSheetDown()
        Thread.sleep(forTimeInterval: 0.3)
    }
    
    /// Get all duplicate page buttons
    func getDuplicatePageButtons() -> XCUIElementQuery {
        return app.buttons.matching(identifier: "PageDuplicateIdentifier")
    }
    
    /// Test that duplicate buttons are not visible when explicitly disabled
    func testDuplicateButtonNotVisibleWhenDisabled() throws {
        openPageNavigationSheet()
        
        // Get duplicate buttons
        let duplicateButtons = getDuplicatePageButtons()
        let duplicateButtonCount = duplicateButtons.count
        
        XCTAssertEqual(duplicateButtonCount, 0, "Duplicate page buttons should NOT be visible when page duplication is disabled")
                
        closePageNavigationSheet()
    }
}

