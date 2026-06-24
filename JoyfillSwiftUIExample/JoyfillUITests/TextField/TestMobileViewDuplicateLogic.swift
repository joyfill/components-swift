//
//  MultiSelectFieldUITestCases.swift
//  JoyfillUITests
//
//  Created by Vivek on 07/07/25.
//

import XCTest
import JoyfillModel

final class TestMobileViewDuplicateLogic: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "TestMobileViewDuplicateLogic"
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
        
        // Add custom launch arguments for this test
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
    
    func testMobileViewConditonalLogic() {
        XCTAssertTrue(!app.staticTexts["Table"].exists)
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        let duplicateButton = app.buttons["PageDuplicateIdentifier"]
        duplicateButton.firstMatch.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 1)
        tapOnSecondPage.tap()
        
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("100")
        
        app.swipeDown()
        
        XCTAssertTrue(app.staticTexts["Table"].exists)
    }
}
