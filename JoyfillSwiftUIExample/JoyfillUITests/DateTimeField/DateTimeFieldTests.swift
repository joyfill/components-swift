import XCTest

final class DateTimeFieldTests: JoyfillUITestsBaseClass {
    func testDatePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }

    func testTimePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 0)
        datePicker.tap()
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }

    func testDateTimePicker() {
        let datePicker = app.datePickers.element(boundBy: 2)

        var attempts = 0
        while !datePicker.exists && attempts < 5 {
            app.swipeUp()
            sleep(1)
            attempts += 1
        }

        XCTAssertTrue(datePicker.waitForExistence(timeout: 5), "Date picker not found on screen")
        XCTAssertEqual(datePicker.label, "")
    }

}
