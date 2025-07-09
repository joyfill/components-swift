import XCTest

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
}
