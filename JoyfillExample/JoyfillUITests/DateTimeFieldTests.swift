//
//  DateTimeFieldTests.swift
//  JoyfillUITests
//
//  Created by Vishnu Dutt on 10/05/24.
//

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
        let datePicker = app.datePickers.element(boundBy: 1)
        datePicker.tap()
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }

    func testDateTimePicker() {
        app.swipeUp()
        let datePicker = app.datePickers.element(boundBy: 2)
        XCTAssertTrue(datePicker.exists)
        XCTAssertEqual(datePicker.label, "")
    }

}
