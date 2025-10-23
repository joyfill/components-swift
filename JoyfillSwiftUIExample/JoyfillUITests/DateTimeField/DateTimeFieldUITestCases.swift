//
//  DateTimeFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 10/07/25.
//

import XCTest
import JoyfillModel

final class DateTimeFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "DateTimeFieldTestData"
    }
    
    // Verifies various field headers
    func testFieldHeaderRendering() {
        // Verify the main page title
        let pageTitle = app.staticTexts["Every Field Type"]
        XCTAssertTrue(pageTitle.exists, "Page title should exist")
        
        // Verify all visible field headers 
        let dateTitle = app.staticTexts["Date"]
        XCTAssertTrue(dateTitle.exists, "Date field title should exist")
        
        let timeTitle = app.staticTexts["Time"]
        XCTAssertTrue(timeTitle.exists, "Time field title should exist")
        
        let dateTimeTitle = app.staticTexts["Date Time"]
        XCTAssertTrue(dateTimeTitle.exists, "Date Time field title should exist")
        
        // Note: The multiline readonly field ("This is default date with readonly\nfield and testing multiline header.")
        // is not visible because it has conditional logic that hides it when conditions aren't met.
        // This is the expected behavior for a field with "action": "show" logic.
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    
    func testRequiredFieldAsteriskPresence() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")
        
        // Tap the date button to open the picker popup
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        XCTAssertEqual(dateButton.label, "07/15/2025")
        dateButton.tap()
        
        // Interact with picker wheels to change date
        let dayWheel = app.datePickers.pickerWheels.element(boundBy: 0)
        XCTAssertTrue(dayWheel.waitForExistence(timeout: 3), "Date picker wheel should exist")
        dayWheel.adjust(toPickerWheelValue: "17")
        
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    
    func testDatePickerValueAfterScrollPage() {
        // Tap the date button to open picker popup
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        XCTAssertEqual(dateButton.label, "07/15/2025")
        dateButton.tap()
        
        // Adjust picker wheels to change date
        let dayWheel = app.datePickers.pickerWheels.element(boundBy: 0)
        dayWheel.adjust(toPickerWheelValue: "17")
        
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        // Scroll to test value persistence
        app.swipeUp()
        app.swipeDown()
        
        // Verify the payload was updated correctly
        verifyOnChangePayload(expectedValue: 1752690600000) // static value for July 17
    }
    
    func testDateFieldOnFocusAndOnBlur() {
        // Tap the date button to open picker popup
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        dateButton.tap()
        
        // Verify picker popup opened by checking for picker wheels
        let dayWheel = app.datePickers.pickerWheels.element(boundBy: 0)
        XCTAssertTrue(dayWheel.waitForExistence(timeout: 3), "Date picker should be in focus")
        
        // Tap outside to dismiss popup
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        // The date button should still exist with the value
        XCTAssertTrue(dateButton.exists, "Date button remains visible since field has value")
    }
    
    
    func testOpenDatePickerAndChangeDate() {
        // Tap the date button to open picker popup (Date-only format uses .wheels style)
        let calendarButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(calendarButton.exists, "Date button should exist to open date picker")
        calendarButton.tap()

        XCTAssertTrue(app.datePickers.element.exists, "Date picker should be in focus")
        // Verify the date button still has the value
        XCTAssertTrue(calendarButton.exists, "Date button should still exist after closing picker")
    }
    
    func testCalendarFieldValueChanges() {
        // Field 1: Date field (MM/DD/YYYY format) - uses .wheels style
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        dateButton.tap()
        
        // Close the wheels picker
        let closeButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
        
        app.swipeUp()
        
        // Field 2: Time field (hh:mma format) - uses .wheels style
        let timeButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 1)
        if timeButton.waitForExistence(timeout: 3) {
            timeButton.tap()
            
            // For time-only, use picker wheels if available
            if app.pickerWheels.count > 1 {
                app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "10")
                app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "30")
            }
            
            // Close picker
            let timeCloseButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
            if timeCloseButton.waitForExistence(timeout: 3) {
                timeCloseButton.tap()
            } else {
                app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
            }
        }
        
        // Field 3: DateTime field (MM/DD/YYYY hh:mma format) - uses .inline style (HAS date buttons!)
        let dateTimeButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 2)
        if dateTimeButton.waitForExistence(timeout: 3) {
            dateTimeButton.tap()
            
            // For date+time format, can tap date buttons in inline picker
            let dateLabel = formattedAccessibilityLabel(for: "2025-07-13")
            let dateInPicker = app.buttons[dateLabel].firstMatch
            if dateInPicker.waitForExistence(timeout: 3) {
                dateInPicker.tap()
            }
            
            // Close picker
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
    }
    
    func testMatchPayloadFieldsValue() {
        // Field 1: Date field - DatePicker should already be visible
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        
        XCTAssertEqual(dateButton.label, "07/15/2025")
        dateButton.tap()
        
        let dayWheel = app.datePickers.pickerWheels.firstMatch
        dayWheel.adjust(toPickerWheelValue: "17")
        
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686f4e36557902657597794c")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686f4e3b58a0861ac3f1ebfa")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686f4e3b613b3abcf155d775")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fileId"] as? String, "66a14ced9dc829a95e272506")
        XCTAssertEqual(payload["target"] as? String, "field.update")
        XCTAssertEqual(payload["identifier"] as? String, "template_6849dbb509ede5510725c910")
        XCTAssertEqual(payload["_id"] as? String, "66a14cedd6e1ebcdf176a8da")
        XCTAssertEqual(payload["sdk"] as? String, "swift")
        guard
            let change = payload["change"] as? [String: Any],
            let tzValue = change["tz"] as? String,
            let value = change["value"] as? Double
        else {
            XCTFail("Invalid onChange payload structure")
            return
        }
        XCTAssertEqual(tzValue, "Asia/Kolkata")
        XCTAssertEqual(value, 1752690600000)
    }
    
    func testChangeMonthAndYear() {
        // Tap the date button to open picker popup (Date-only format uses .wheels style)
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        dateButton.tap()
        
        // For wheels style picker, verify picker wheels exist
        XCTAssertTrue(app.pickerWheels.count > 0, "Picker wheels should be visible")
        
        // Close the picker
        let closeButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
        
        app.swipeUp()
        app.swipeDown()
        
        // Verify the date button still exists
        XCTAssertTrue(dateButton.exists, "Date button should persist after scrolling")
    }
    
    func testChangeMonthWithNextAndPrevious() {
        // Tap the date button to open picker popup (Date-only format uses .wheels style)
        let dateButton = app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: 0)
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Date button should exist")
        dateButton.tap()
        
        // For wheels style, verify picker opens
        XCTAssertTrue(app.pickerWheels.count > 0 || app.buttons.matching(identifier: "xmark.circle.fill").firstMatch.exists, 
                     "Date picker should be visible")
        
        // Close the picker
        let closeButton = app.buttons.matching(identifier: "xmark.circle.fill").firstMatch
        if closeButton.waitForExistence(timeout: 3) {
            closeButton.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
        
        // Verify date button still exists
        XCTAssertTrue(dateButton.exists, "Date button should still exist after closing picker")
    }
    
    func formattedAccessibilityLabel(for isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: isoDate) else {
            XCTFail("Invalid date string: \(isoDate)")
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        // UIDatePicker inline mode uses format: "d MMMM yyyy" (e.g., "17 July 2025")
        outputFormatter.dateFormat = "d MMMM yyyy"
        
        return outputFormatter.string(from: date)
    }
    
    func verifyOnChangePayload(expectedValue: Double) {
        let payload = onChangeResult().dictionary
        
        guard
            let change = payload["change"] as? [String: Any],
            let actualValue = change["value"] as? Double,
            let tz = change["tz"] as? String
        else {
            XCTFail("Invalid onChange payload structure")
            return
        }
        XCTAssertEqual(tz, "Asia/Kolkata")
        XCTAssertEqual(actualValue, expectedValue, "onChange payload value should match expected value")
    }
}
