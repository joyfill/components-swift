import XCTest

private extension XCUIElement {
    var hasKeyboardFocus: Bool {
        // Hittable + keyboard shown is a good proxy
        return self.isHittable && XCUIApplication().keyboards.count > 0
    }
}

extension XCUIApplication {
    func swipeToFindElement(identifier: String,
                            type: XCUIElement.ElementType,
                            direction: String = "up",
                            index: Int = 0,
                            maxAttempts: Int = 6) -> XCUIElement? {
        
        let scrollView = self.scrollViews.firstMatch
        guard scrollView.exists else {
            XCTFail("ScrollView not found for swipe action")
            return nil
        }

        var attempts = 0
        var elementQuery = self.descendants(matching: type).matching(identifier: identifier)
        var targetElement = elementQuery.element(boundBy: index)

        while attempts < maxAttempts {
            if targetElement.exists && targetElement.isHittable {
                return targetElement
            }

            // Scroll
            switch direction.lowercased() {
            case "up":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
                let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                start.press(forDuration: 0.3, thenDragTo: end)
            case "down":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
                let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
                start.press(forDuration: 0.3, thenDragTo: end)
            case "left":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
                let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
                start.press(forDuration: 0.3, thenDragTo: end)
            case "right":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))
                let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
                start.press(forDuration: 0.3, thenDragTo: end)
            default:
                XCTFail("Invalid swipe direction: \(direction)")
                return nil
            }

            // Replace sleep with proper wait
            let waitResult = XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: targetElement)], timeout: 1.0)
            if waitResult == .completed {
                break
            }
            
            elementQuery = self.descendants(matching: type).matching(identifier: identifier)
            targetElement = elementQuery.element(boundBy: 0)
            attempts += 1
        }

        return targetElement.exists && targetElement.isHittable ? targetElement : nil
    }
    
    /// Dismisses the keyboard if it is visible and removes focus from the active element.
        func dismissKeyboardIfVisible() {
            let keyboard = self.keyboards.element
            if keyboard.exists {
                // 1. Try tapping the return key (for alphabetic keyboards)
                let returnButton = keyboard.buttons["Return"]
                if returnButton.exists && returnButton.isHittable {
                    returnButton.tap()
                    return
                }

                // 2. Try tapping "Done" key (common on numeric pads)
                let doneButton = keyboard.buttons["Done"]
                if doneButton.exists && doneButton.isHittable {
                    doneButton.tap()
                    return
                }

                // 3. Try tapping outside keyboard area (fallback)
                let coordinate = self.windows.element(boundBy: 0).coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
                coordinate.tap()
            }
        }
    
    func tapOutsideToDismissKeyboard() {
            // Slightly different approach if above fails
            let safeArea = windows.element(boundBy: 0)
            let dismissTap = safeArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01))
            dismissTap.tap()
        }
}

// MARK: - New Helper Methods for Robust UI Testing

extension XCUIElement {
    /// Clears text from text fields and text views using backspace deletion
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
    
    /// Simple and reliable text clearing method
    func clearTextReliably() {
        self.tap()
        
        // Get current text and delete it character by character - most reliable method
        while let stringValue = self.value as? String, !stringValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            self.typeText(deleteString)
            
            // Break if no progress made to avoid infinite loop
            if let newValue = self.value as? String, newValue == stringValue {
                break
            }
        }
    }
    
    /// Waits for element to exist and be hittable, then taps it
    func waitAndTap(timeout: TimeInterval = 5, message: String? = nil) {
        let waitMessage = message ?? "Element '\(self.identifier)' did not appear in time"
        XCTAssertTrue(self.waitForExistence(timeout: timeout), waitMessage)
        XCTAssertTrue(self.isHittable, "Element '\(self.identifier)' is not hittable")
        self.tap()
    }
    
    /// Waits for element to exist, then clears and types text
    func waitAndClearAndTypeText(_ text: String, timeout: TimeInterval = 5, message: String? = nil) {
        let waitMessage = message ?? "Element '\(self.identifier)' did not appear in time"
        XCTAssertTrue(self.waitForExistence(timeout: timeout), waitMessage)
        XCTAssertTrue(self.isHittable, "Element '\(self.identifier)' is not hittable")
        self.tap()
        self.clearText()
        self.typeText(text)
    }
    
    /// Waits for navigation to complete (waits for navigation bar to be ready)
    func waitForNavigation(timeout: TimeInterval = 5) {
        let navigationBar = XCUIApplication().navigationBars.firstMatch
        XCTAssertTrue(navigationBar.waitForExistence(timeout: timeout), "Navigation did not complete in time")
    }
    
    /// Waits for field value to be empty after clearing
    func waitForEmptyValue(timeout: TimeInterval = 3) -> Bool {
        let predicate = NSPredicate(format: "value == '' || value == nil")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for field value to change to a specific value
    func waitForValue(_ expectedValue: String, timeout: TimeInterval = 3) -> Bool {
        let predicate = NSPredicate(format: "value == %@", expectedValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    /// Waits for element to disappear
    func waitForNonExistence(timeout: TimeInterval = 3) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    func waitForKeyboard(timeout: TimeInterval = 5) -> Bool {
        let app = XCUIApplication()
        let end = Date().addingTimeInterval(timeout)
        while Date() < end {
            if app.keyboards.count > 0 { return true }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return false
    }
}

extension XCUIApplication {
    /// Waits for a specific number of text views to be present
    func waitForTextViewCount(_ expectedCount: Int, timeout: TimeInterval = 5) -> Bool {
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if self.textViews.count == expectedCount {
                return true
            }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return false
    }
    
    /// Robust "Select All" that works across iOS versions.
    /// Shows the iOS edit menu WITHOUT pre‑selecting text (avoid doubleTap).
    @discardableResult
    func showEditMenu(on field: XCUIElement, app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        guard field.waitForExistence(timeout: timeout) else { return false }
        if !field.isHittable { return false }
        field.tap() // place caret (no selection)

        // Long‑press to open the menu (doesn't auto‑select text)
        field.press(forDuration: 0.5)

        // Wait for either legacy (menuItems) or modern (buttons) edit menu to appear
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if app.menuItems.element(boundBy: 0).exists { return true }
            if app.buttons["Cut"].exists || app.buttons["Paste"].exists || app.buttons["Select"].exists { return true }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return false
    }

    @discardableResult
    func tapEditMenuItem(_ title: String, app: XCUIApplication, timeout: TimeInterval = 3) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if app.menuItems[title].exists { app.menuItems[title].tap(); return true }
            if app.buttons[title].exists    { app.buttons[title].tap();    return true } // iOS 16+ menu
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        }
        return false
    }

    @discardableResult
    func selectAllInTextField(in field: XCUIElement, app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        guard showEditMenu(on: field, app: app, timeout: timeout) else { return false }
        return tapEditMenuItem("Select All", app: app, timeout: timeout)
    }
    
    func enterTextReliably(_ text: String, into field: XCUIElement, timeout: TimeInterval = 5) {
        XCTAssertTrue(field.waitForExistence(timeout: timeout), "Text field not found")
        field.tap()
        XCTAssertTrue(field.waitForKeyboard(), "Keyboard didn’t appear")
        
        // Type char-by-char with short yields so iOS can keep up
        for ch in text {
            field.typeText(String(ch))
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.02))
        }
        
        // Commit autocorrect by adding a space and deleting it (prevents last-letter drop)
        field.typeText(" ")
        field.typeText(XCUIKeyboardKey.delete.rawValue)
        
        // Verify and top-up missing suffix if needed
        let current = (field.value as? String) ?? ""
        if !current.hasSuffix(text) {
            // Type only the missing part
            let prefixLen = current.commonPrefix(with: text).count
            let missing = text.dropFirst(prefixLen)
            if !missing.isEmpty {
                field.typeText(String(missing))
            }
        }
    }
}
