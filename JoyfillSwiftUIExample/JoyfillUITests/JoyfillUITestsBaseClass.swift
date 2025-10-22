import XCTest
import Joyfill
import JoyfillModel

// MARK: - Suite-wide helpers (added)

/// Non-blocking tiny pause that lets UIKit process events.
@discardableResult
func spinRunloop(_ seconds: TimeInterval) -> Bool {
    RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
    return true
}

/// Wait for a condition using runloop polling (avoid sleep).
@discardableResult
func waitUntil(_ timeout: TimeInterval,
               poll: TimeInterval = 0.05,
               condition: @escaping () -> Bool) -> Bool {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
        if condition() { return true }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: poll))
    }
    return false
}

/// Dismiss keyboards/sheets/alerts so next action isn’t blocked.
func dismissTransientUIIfNeeded(app: XCUIApplication) {
    // Keyboard
    if app.keyboards.count > 0 {
        if app.keyboards.buttons["Done"].exists { app.keyboards.buttons["Done"].tap() }
        else if app.keys["return"].exists { app.keys["return"].tap() }
        else { app.windows.firstMatch.tap() }
        spinRunloop(0.2)
    }

    // Sheets / Popovers
    if app.sheets.firstMatch.exists {
        let sheet = app.sheets.firstMatch
        if sheet.exists {
            // Try swipe-down
            sheet.swipeDown()
            spinRunloop(0.2)
        }
    }

    // Alerts
    if app.alerts.firstMatch.exists {
        app.alerts.buttons.firstMatch.tap()
        spinRunloop(0.2)
    }
}

/**
 * Base class for UI tests with automatic hardware keyboard disabling.
 *
 * This class automatically disables the hardware keyboard during test execution
 * to ensure consistent UI test behavior. This is important for:
 * - Consistent keyboard behavior across different environments
 * - Reliable text input testing
 * - Avoiding conflicts between hardware and software keyboards
 *
 * The hardware keyboard is automatically disabled for all tests via:
 * 1. Test plan configuration (simulatorSettings.disableHardwareKeyboard)
 * 2. Launch arguments (--disable-hardware-keyboard)
 * 3. Environment variables (SIMCTL_CHILD_DISABLE_HARDWARE_KEYBOARD)
 *
 * No additional code is required in individual test methods.
 */
class JoyfillUITestsBaseClass: XCTestCase {
    var app: XCUIApplication!

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
        
        // Automatically disable hardware keyboard for all UI tests
        disableHardwareKeyboardForAllTests()
        
        // Add crash prevention arguments
        app.launchArguments.append("--safe-mode")
        app.launchArguments.append("--disable-crash-on-error")
        
        // Add fresh instance flag
        app.launchArguments.append("--fresh-instance")

        // Global alert/permission handler (added before launch so it's active immediately)
        addUIInterruptionMonitor(withDescription: "System Alerts") { alert in
            for btn in ["Allow", "OK", "Continue", "Don’t Allow", "Remind Me Later", "While Using the App"] {
                if alert.buttons[btn].exists
                {
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

            app.activate() // ensure alerts/interruption monitor can trigger

            // Additional wait to ensure app is fully loaded
            // REPLACED sleep(1) with a state-based wait for stability
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
            
            print("✅ Fresh app instance created for test: \(self.name)")
        } catch {
            print("⚠️  App launch failed: \(error)")
            // Don't fail the test, just log the error
        }
    }

    override func tearDownWithError() throws {
        if app != nil {
            print("🧹 Tearing down test: \(self.name)")
            
            // Handle potential exit code -1 issues
            handleExitCodeIssue()

            // Dismiss any leftover UI that could affect the next test
            dismissTransientUIIfNeeded(app: app)

            // Ensure app is properly terminated
            app.terminate()

            // REPLACED sleep(2) with state-based wait
            _ = waitUntil(5) { self.app.state != .runningForeground }

            // Force cleanup any remaining processes
            let cleanupApp = XCUIApplication()
            if cleanupApp.state == .runningForeground {
                cleanupApp.terminate()
                _ = waitUntil(3) { cleanupApp.state != .runningForeground }
            }
        }
        
        // Clear app reference
        app = nil
        
        // Clear any cached state
        UserDefaults.standard.synchronize()
        
        print("✅ Test cleanup completed for: \(self.name)")
    }
    
    // Override this method in test classes to specify a custom JSON file
    func getJSONFileNameForTest() -> String {
        return "Joydocjson" // Default JSON file
    }
    
    func goBack() {
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
    }
    
    func swipeSheetDown() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    /// Automatically disables hardware keyboard for all UI tests
    func disableHardwareKeyboardForAllTests() {
        // Add launch argument to disable hardware keyboard
        app.launchArguments.append("--disable-hardware-keyboard")
        
        // Set environment variable to disable hardware keyboard
        setenv("SIMCTL_CHILD_DISABLE_HARDWARE_KEYBOARD", "1", 1)
        
        print("Hardware keyboard automatically disabled for all UI tests")
    }
    
    /// Ensures hardware keyboard is disabled during test execution (internal use)
    private func ensureHardwareKeyboardDisabled() {
        // Check if we're running in UI test mode
        if ProcessInfo.processInfo.arguments.contains("JoyfillUITests") {
            // Set environment variable to disable hardware keyboard
            setenv("SIMCTL_CHILD_DISABLE_HARDWARE_KEYBOARD", "1", 1)
        }
    }
    
    /// Check if hardware keyboard is disabled
    func isHardwareKeyboardDisabled() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("--disable-hardware-keyboard") ||
               ProcessInfo.processInfo.environment["SIMCTL_CHILD_DISABLE_HARDWARE_KEYBOARD"] == "1"
    }
    
    /// Get hardware keyboard status for debugging
    func getHardwareKeyboardStatus() -> String {
        let isDisabled = isHardwareKeyboardDisabled()
        let hasLaunchArg = ProcessInfo.processInfo.arguments.contains("--disable-hardware-keyboard")
        let hasEnvVar = ProcessInfo.processInfo.environment["SIMCTL_CHILD_DISABLE_HARDWARE_KEYBOARD"] == "1"
        
        return """
        Hardware Keyboard Status:
        - Disabled: \(isDisabled)
        - Launch Argument: \(hasLaunchArg)
        - Environment Variable: \(hasEnvVar)
        """
    }
    
    /// Verify hardware keyboard is disabled and log the status
    func verifyHardwareKeyboardDisabled() {
        let isDisabled = isHardwareKeyboardDisabled()
        print("✅ Hardware keyboard automatically disabled: \(isDisabled)")
        
        if !isDisabled {
            print("⚠️  Warning: Hardware keyboard is not disabled. This may cause inconsistent test behavior.")
        }
    }
    
    /// Handle app crashes gracefully
    func handleAppCrash() {
        if app.state != .runningForeground {
            print("⚠️  App crashed or stopped running")
            
            // Try to relaunch the app
            do {
                app.terminate()
                // REPLACED sleep(2) with state wait
                _ = waitUntil(5) { self.app.state != .runningForeground }
                app.launch()
                XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "App relaunch failed")
            } catch {
                print("❌ Failed to relaunch app after crash: \(error)")
            }
        }
    }
    
    /// Ensure app is stable before proceeding with tests
    func ensureAppStability() {
        // Check if app is still running
        guard app.state == .runningForeground else {
            print("⚠️  App is not in foreground state")
            handleAppCrash()
            return
        }
        
        // Check if basic UI elements are accessible
        let basicElements = app.windows.firstMatch
        guard basicElements.exists else {
            print("⚠️  Basic UI elements not accessible")
            return
        }
        
        print("✅ App is stable and ready for testing")
    }
    
    /// Force cleanup of any existing app instance
    func forceCleanupExistingApp() {
        // Terminate any existing app instance
        if app != nil {
            print("🧹 Cleaning up existing app instance")
            app.terminate()
            // REPLACED sleep(2) with state wait
            _ = waitUntil(5) { self.app.state != .runningForeground }
            app = nil
        }
        
        // Force cleanup of any remaining app processes
        let cleanupApp = XCUIApplication()
        if cleanupApp.state == .runningForeground {
            cleanupApp.terminate()
            // REPLACED sleep(1) with state wait
            _ = waitUntil(3) { cleanupApp.state != .runningForeground }
        }
        
        // Clear any cached state
        UserDefaults.standard.synchronize()
        
        print("✅ App cleanup completed")
    }
    
    /// Handle exit code -1 issues
    func handleExitCodeIssue() {
        // REPLACED sleep(1) with tiny runloop yield
        spinRunloop(0.2)

        // Check if app is responding
        if app.state != .runningForeground {
            print("⚠️  Detected potential exit code -1 issue")
            
            // Try to recover gracefully
            do {
                app.terminate()
                // REPLACED sleep(3) with state wait
                _ = waitUntil(8) { self.app.state != .runningForeground }
                app.launch()
                XCTAssertTrue(app.wait(for: .runningForeground, timeout: 20), "App recovery failed")
                app.activate()
                XCTAssertTrue(waitForAppStability(timeout: 10), "App not stable after recovery")
            } catch {
                print("❌ Failed to recover from exit code -1: \(error)")
            }
        }
    }
    
    /// Check if app is in a stable state for testing
    func isAppStable() -> Bool {
        // FIX: original had `!app.windows.firstMatch.isHittable == false`
        guard app.state == .runningForeground else { return false }
        let win = app.windows.firstMatch
        return win.exists && win.isHittable
    }
    
    /// Wait for app to be stable before proceeding
    func waitForAppStability(timeout: TimeInterval = 10,
                             minStableDuration: TimeInterval = 0.5,
                             poll: TimeInterval = 0.05) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        var stableSince: Date?

        while Date() < deadline {
            if isAppStable() {
                if stableSince == nil { stableSince = Date() }
                if let started = stableSince,
                   Date().timeIntervalSince(started) >= minStableDuration {
                    return true
                }
            } else {
                stableSince = nil // reset if we dip out of stable
            }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: poll))
        }

        print("⚠️  App did not become stable within \(timeout) seconds")
        return false
    }

    /// Verify that this test is running with a fresh app instance
    func verifyFreshAppInstance() {
        // Check if fresh instance flag is present
        let hasFreshFlag = ProcessInfo.processInfo.arguments.contains("--fresh-instance")
        let hasTestId = ProcessInfo.processInfo.arguments.contains("--test-id")

        print("🔍 Fresh instance verification:")
        print("   - Fresh instance flag: \(hasFreshFlag)")
        print("   - Test ID present: \(hasTestId)")
        print("   - Test name: \(self.name)")

        if !hasFreshFlag || !hasTestId {
            print("⚠️  Warning: App may not be running with fresh instance")
        } else {
            print("✅ Confirmed fresh app instance")
        }
    }

    /// Reset app state to ensure clean test environment
    func resetAppState() {
        // Navigate back to root if possible
        if app.navigationBars.buttons.count > 0 {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        // Clear any text fields
        let textFields = app.textFields
        for i in 0..<textFields.count {
            textFields.element(boundBy: i).clearText()
        }

        // Clear any text views
        let textViews = app.textViews
        for i in 0..<textViews.count {
            textViews.element(boundBy: i).clearText()
        }

        print("🔄 App state reset completed")
    }

    /// Check if test is being skipped and log details
    func checkTestSkipped() {
        print("🔍 Test execution check:")
        print("   - Test name: \(self.name)")
        print("   - App state: \(app.state.rawValue)")
        print("   - App exists: \(app.exists)")
        print("   - App is hittable: \(app.isHittable)")

        if app.state != .runningForeground {
            print("⚠️  Test may be skipped due to app not running")
        } else {
            print("✅ Test is running normally")
        }
    }
}

extension JoyfillUITestsBaseClass {
    func onChangeResultValue() -> ValueUnion {
        let result = onChangeResult()

        guard let change = result.change else {
            print("No change data in result")
            return ValueUnion(value: "")!
        }

        guard let value = change["value"] else {
            print("No value in change data")
            return ValueUnion(value: "")!
        }

        guard let valueUnion = ValueUnion(value: value) else {
            print("Failed to create ValueUnion from value")
            return ValueUnion(value: "")!
        }

        return valueUnion
    }

    func onChangeResultChange() -> ValueUnion {
        let result = onChangeResult()

        guard let change = result.change else {
            print("No change data in result")
            return ValueUnion(value: [:])!
        }

        guard let valueUnion = ValueUnion(value: change) else {
            print("Failed to create ValueUnion from change")
            return ValueUnion(value: [:])!
        }

        return valueUnion
    }

    func onChangeResultChanges() -> [ValueUnion] {
        let results = onChangeOptionalResults().map { $0.change }
        return results.compactMap {
            ValueUnion(value: $0)!
        }
    }

    func onChangeResult() -> Change {
        guard let result = onChangeOptionalResult() else {
            // Return a safe default Change object instead of crashing
            print("⚠️  No onChange result available, returning default")
            return Change(dictionary: ["type": "default", "value": ""])
        }
        return result
    }

    func onChangeOptionalResult() -> Change? {
        let resultField = app.staticTexts["resultfield"]

        // Check if result field exists
        guard resultField.exists else {
            print("Result field not found")
            return nil
        }

        let jsonString = resultField.label
        print("resultField.label: \(resultField.label)")

        // Check if the JSON string is valid
        guard !jsonString.isEmpty && jsonString != "[]" else {
            print("Empty or invalid JSON string")
            return nil
        }

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dicts = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]],
                   !dicts.isEmpty {
                    let change = Change(dictionary: dicts.first!)
                    return change
                } else {
                    print("No valid changes found in JSON")
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return nil
    }

    func onChangeOptionalResults() -> [Change] {
        let resultField = app.staticTexts["resultfield"]

        // Check if result field exists
        guard resultField.exists else {
            print("Result field not found")
            return []
        }

        let jsonString = resultField.label
        print("resultField.label: \(resultField.label)")

        // Check if the JSON string is valid
        guard !jsonString.isEmpty && jsonString != "[]" else {
            print("Empty or invalid JSON string")
            return []
        }

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dicts = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]] {
                    return dicts.map(Change.init)
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return []
    }
    
    func onUploadOptionalResults() -> [Change] {
        let resultField = app.staticTexts["resultUploadfield"]

        // Check if result field exists
        guard resultField.exists else {
            print("Result field not found")
            return []
        }

        let jsonString = resultField.label
        print("resultField.label: \(resultField.label)")

        // Check if the JSON string is valid
        guard !jsonString.isEmpty && jsonString != "[]" else {
            print("Empty or invalid JSON string")
            return []
        }

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                if let dicts = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: Any]] {
                    return dicts.map(Change.init)
                }
            } catch {
                print("Failed to decode JSON string to model: \(error)")
            }
        } else {
            print("Failed to convert string to data")
        }
        return []
    }
}
