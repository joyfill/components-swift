import XCTest

final class DateTimeFieldTests: JoyfillUITestsBaseClass {
    override func getJSONFileNameForTest() -> String {
        return "DateTimeFieldTestData"
    }

    func testEmptyStringDateRendersEmptyState() {
        // A date field with value "" must render the empty "Select a Date -" placeholder,
        // not a fabricated current date/time.
        let placeholder = app.staticTexts["Select a Date -"]

        var attempts = 0
        while !placeholder.exists && attempts < 8 {
            app.swipeUp()
            _ = placeholder.waitForExistence(timeout: 1)
            attempts += 1
        }

        XCTAssertTrue(placeholder.waitForExistence(timeout: 5),
                      "Empty-string date field should show the 'Select a Date -' empty state")
        let placeholderQuery = app.staticTexts.matching(NSPredicate(format: "label == %@", "Select a Date -"))
        XCTAssertEqual(placeholderQuery.count, 1,
                       "Only the empty-string date field should show the empty placeholder")

        // Now set a date/time on the previously-empty field and confirm it gets set.
        placeholder.tap()

        XCTAssertTrue(waitUntil(5) { placeholderQuery.count == 0 },
                      "After tapping, the empty placeholder should disappear (field is now filled)")

        // A change should have been emitted carrying a numeric (millisecond) value.
        let emittedValue = onChangeResultValue()
        XCTAssertNotNil(emittedValue.number,
                        "Setting the date should emit a numeric timestamp value, got \(emittedValue)")
    }

    func testDatePicker() {
        // Tap a date button using its identifier to open the picker popup
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").firstMatch
        XCTAssertTrue(dateButton.waitForExistence(timeout: 5), "Date button should exist")
        dateButton.tap()
        
        // Verify picker popup is shown
        let pickerExists = app.datePickers.count > 0 || app.pickerWheels.count > 0
        XCTAssertTrue(pickerExists, "Date picker popup should be visible")
    }

    func testTimePicker() {
        // Tap a time button using its identifier to open the picker popup
        let timeButton = app.buttons.matching(identifier: "ChangeDateIdentifier").firstMatch
        XCTAssertTrue(timeButton.waitForExistence(timeout: 5), "Time button should exist")
        timeButton.tap()
        
        // Verify picker popup is shown
        let pickerExists = app.datePickers.count > 0 || app.pickerWheels.count > 0
        XCTAssertTrue(pickerExists, "Time picker popup should be visible")
    }

    func testDateTimePicker() {
        let app = XCUIApplication()
        
        // Look for a date/time button using its identifier
        let dateTimeButton = app.buttons.matching(identifier: "ChangeDateIdentifier").firstMatch
        
        var attempts = 0
        while !dateTimeButton.exists && attempts < 5 {
            app.swipeUp()
            _ = dateTimeButton.waitForExistence(timeout: 1)
            attempts += 1
        }
        
        XCTAssertTrue(dateTimeButton.waitForExistence(timeout: 5), "Date/time button not found on screen")
        dateTimeButton.tap()
        
        // Verify picker popup is shown
        let pickerExists = app.datePickers.count > 0 || app.pickerWheels.count > 0
        XCTAssertTrue(pickerExists, "Date/time picker popup should be visible")
    }
}
