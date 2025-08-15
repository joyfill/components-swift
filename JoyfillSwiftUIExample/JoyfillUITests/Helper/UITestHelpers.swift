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

        // --- helpers ---
        @inline(__always) func yield(_ s: TimeInterval = 0.05) {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: s))
        }

        /// Return a normalized Y (0...1) inside `scrollView` that sits a bit ABOVE the keyboard edge.
        /// If no keyboard or cannot compute, returns a conservative safe value.
        func safeStartDYAboveKeyboard(extraMarginPts: CGFloat = 20) -> CGFloat {
            let win = self.windows.firstMatch
            let svf = scrollView.frame
            guard win.exists, !svf.isEmpty else { return 0.70 } // default near top 30%

            // If keyboard is visible and overlaps the scrollView, compute the visible height
            if self.keyboards.firstMatch.exists {
                let kbf = self.keyboards.firstMatch.frame
                if !kbf.isEmpty, kbf.intersects(svf) {
                    let kbTop = kbf.minY - extraMarginPts                 // a bit above the keyboard
                    let visible = max(0, kbTop - svf.minY)
                    // Convert to normalized dy within the scrollView’s bounds
                    let dy = visible / svf.height
                    // keep within [0.55, 0.90] so we’re comfortably away from bottom overlays
                    return CGFloat(max(0.55, min(0.90, dy)))
                }
            }
            // No keyboard => still avoid bottom 30%
            return 0.70
        }

        func isVisible(_ e: XCUIElement) -> Bool {
            guard e.exists else { return false }
            return e.frame.intersects(scrollView.frame)
        }
        // --- /helpers ---

        var attempts = 0
        var elementQuery = self.descendants(matching: type).matching(identifier: identifier)
        var targetElement = elementQuery.element(boundBy: index)

        while attempts < maxAttempts {
            if isVisible(targetElement) { return targetElement }

            // compute a lane that starts a little ABOVE the keyboard every time
            let startDY = safeStartDYAboveKeyboard(extraMarginPts: 24)   // tweak margin if needed
            let endDYUp   = max(0.12, startDY - 0.50) // go up ~50% of sv height
            let endDYDown = min(0.90, startDY + 0.50) // go down ~50%

            switch direction.lowercased() {
            case "up":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: startDY))
                let end   = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: endDYUp))
                start.press(forDuration: 0.02, thenDragTo: end)

            case "down":
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: max(0.20, endDYUp)))
                let end   = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: endDYDown))
                start.press(forDuration: 0.02, thenDragTo: end)

            case "left":
                // horizontal: pick a Y that’s also above keyboard
                let dy = startDY
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: dy))
                let end   = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: dy))
                start.press(forDuration: 0.02, thenDragTo: end)

            case "right":
                let dy = startDY
                let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.15, dy: dy))
                let end   = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: dy))
                start.press(forDuration: 0.02, thenDragTo: end)

            default:
                XCTFail("Invalid swipe direction: \(direction)")
                return nil
            }

            yield(0.15)

            // re-resolve fresh each loop
            elementQuery = self.descendants(matching: type).matching(identifier: identifier)
            targetElement = elementQuery.element(boundBy: index)
            attempts += 1
        }

        return isVisible(targetElement) ? targetElement : nil
    }
    
    /// Dismisses the keyboard if it is visible and removes focus from the active element.
    func dismissKeyboardIfVisible(timeout: TimeInterval = 2.0) {
        guard self.keyboards.element.exists else { return }

        func yield(_ s: TimeInterval = 0.05) {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: s))
        }

        // Try a bunch of common keys/buttons that dismiss keyboards
        let kb = self.keyboards.element

        // 1) Toolbar "Done" above the keyboard (common on text views / number pads)
        if self.toolbars.buttons["Done"].exists && self.toolbars.buttons["Done"].isHittable {
            self.toolbars.buttons["Done"].tap()
        } else if kb.buttons["Done"].exists && kb.buttons["Done"].isHittable {
            kb.buttons["Done"].tap()
        }
        yield(0.15)
        if !kb.exists { return }

        // 2) "Hide keyboard" button (iPad / some layouts)
        for label in ["Hide keyboard", "Dismiss", "Minimize Keyboard"] {
            if kb.buttons[label].exists && kb.buttons[label].isHittable {
                kb.buttons[label].tap()
                yield(0.15)
                if !self.keyboards.element.exists { return }
            }
        }

        // 3) Return/Go/Search/Send/Next variants (text view return won’t dismiss, but some UIs remap it)
//        let returnCandidates = ["Return", "Go", "Search", "Send", "Next", "Continue"]
//        for title in returnCandidates {
//            if kb.buttons[title].exists && kb.buttons[title].isHittable {
//                kb.buttons[title].tap()
//                yield(0.15)
//                if !self.keyboards.element.exists { return }
//            }
//            if kb.keys[title].exists && kb.keys[title].isHittable {
//                kb.keys[title].tap()
//                yield(0.15)
//                if !self.keyboards.element.exists { return }
//            }
//        }

        // 4) Tap outside in a safe zone well above the keyboard (center-top 10%)
        let win = self.windows.firstMatch
        if win.exists {
            let safeTop = win.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.10))
            safeTop.tap()
            yield(0.15)
            if !self.keyboards.element.exists { return }
        }

        // 5) As a last resort, perform a left-edge swipe (often pops and resigns first responder)
        if win.exists {
            let start = win.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
            let end   = win.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
            start.press(forDuration: 0.02, thenDragTo: end)
            yield(0.15)
            if !self.keyboards.element.exists { return }
        }

        // 6) Final wait loop (don’t proceed until gone or we time out)
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !self.keyboards.element.exists { break }
            yield(0.05)
        }
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
    
    private func runloopYield(_ seconds: TimeInterval = 0.05) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
    }

    private func waitForKeyboard(_ timeout: TimeInterval = 3) {
        let app = XCUIApplication()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if app.keyboards.count > 0 { return }
            runloopYield(0.05)
        }
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
        // 0) If empty, nothing to select—avoid long‑press/menu entirely
        if let current = field.value as? String, current.isEmpty {
            // ensure focus so next typeText goes to the right place
            _ = field.waitForExistence(timeout: timeout)
            if field.isHittable { field.tap() }
            waitForKeyboard(2)
            return true
        }

        // 1) Make sure we’re focused with keyboard up
        guard field.waitForExistence(timeout: timeout) else { return false }
        if field.isHittable { field.tap() }
        waitForKeyboard(2)

        // 2) Fast path: try Command‑A (works on both UITextField & UITextView)
        field.typeText(XCUIKeyboardKey.command.rawValue + "a")
        runloopYield(0.1)

        // If the platform shows a modern/legacy edit menu, we can still tap "Select All"
        if app.menuItems["Select All"].exists { app.menuItems["Select All"].tap(); return true }
        if app.buttons["Select All"].exists   { app.buttons["Select All"].tap();   return true }

        // 3) Fallback: use your long‑press menu path
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
