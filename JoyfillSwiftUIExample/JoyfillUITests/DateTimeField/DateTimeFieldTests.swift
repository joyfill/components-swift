import XCTest

final class DateTimeFieldTests: JoyfillUITestsBaseClass {
    func testDatePicker() {
        app.swipeUp()
        // Tap a date button using its identifier to open the picker popup
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").firstMatch
        XCTAssertTrue(dateButton.waitForExistence(timeout: 5), "Date button should exist")
        dateButton.tap()
        
        // Verify picker popup is shown
        let pickerExists = app.datePickers.count > 0 || app.pickerWheels.count > 0
        XCTAssertTrue(pickerExists, "Date picker popup should be visible")
    }

    func testTimePicker() {
        app.swipeUp()
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
