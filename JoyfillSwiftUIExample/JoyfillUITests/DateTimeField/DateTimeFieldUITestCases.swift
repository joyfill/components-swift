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
        let titleWithMultiline = app.staticTexts["This is default date with readonly\nfield and testing multiline header."]
        XCTAssertTrue(titleWithMultiline.exists)
        
        let smallTitle = app.staticTexts["Date Time"]
        XCTAssertTrue(smallTitle.exists)
        
        let time = app.staticTexts["Time"]
        XCTAssertTrue(time.exists)
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        sleep(1)
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    
    func testRequiredFieldAsteriskPresence() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")
        
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        app.buttons["PopoverDismissRegion"].tap()
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    
    func testDatePickerValueAfterScrollPage() {
        // Field 1: Date field at index 2
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-12")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        app.buttons["PopoverDismissRegion"].tap()
        app.swipeUp()
        app.swipeDown()
        verifyOnChangePayload(expectedValue: 1752258600000) // static value
        sleep(1)
        let newButton = app.buttons.matching(NSPredicate(format: "value == %@", "12 Jul 2025")).firstMatch
        XCTAssertTrue(newButton.waitForExistence(timeout: 2), "Expected to find button")
        newButton.tap()
    }
    
    func testDateFieldOnFocusAndOnBlur() {
        // Find the first “Date Picker” button by type, then tap to focus
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        
        // The UIDatePicker should now appear
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-12")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "Date picker should appear on focus")
        // Tap outside to blur (e.g. the toolbar or background)
        app.buttons["PopoverDismissRegion"].tap()
        // Wait a moment for dismissal animation
        XCTAssertFalse(firstDate.exists, "Date picker should disappear on blur")
    }
    
    
    func testOpenDatePickerAndChangeDate() {
        // Tap to open the date picker
        let calendarButton = app.buttons["15 Jul 2025"]
        XCTAssertTrue(calendarButton.exists, "Calendar button should exist to open date picker")
        calendarButton.tap()
        
        // Wait for date picker
        let datePicker = app.datePickers["DateIdenitfier"]
        XCTAssertTrue(datePicker.waitForExistence(timeout: 2), "Date picker should be visible")
        
        // Format the expected date dynamically (handles iPhone/iPad differences)
        let formattedDate = formattedAccessibilityLabel(for: "2025-07-17")
        let newDateButton = app.buttons[formattedDate]
        XCTAssertTrue(newDateButton.exists, "Formatted date button should exist: \(formattedDate)")
        newDateButton.tap()
        sleep(1)
        verifyOnChangePayload(expectedValue: 1752748200000)
    }
    
    func testCalendarFieldValueChanges() {
        // Field 1: Date field at index 2
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        verifyOnChangePayload(expectedValue: 1752690600000) // static value
        app.buttons["PopoverDismissRegion"].tap()
        
        // Field 2: Time field at index 3
        let secondTimeButton = app.buttons.element(boundBy: 3)
        secondTimeButton.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "10")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "30")
        verifyOnChangePayload(expectedValue: 946746000000) // static value for 10:30 AM
        app.buttons["PopoverDismissRegion"].tap()
        
        // Field 3: Date field at index 4
        let thirdDateButton = app.buttons.element(boundBy: 4)
        thirdDateButton.tap()
        let thirdDateLabel = formattedAccessibilityLabel(for: "2025-07-13")
        let thirdDate = app.buttons[thirdDateLabel]
        XCTAssertTrue(thirdDate.exists, "Third date label should exist: \(thirdDateLabel)")
        thirdDate.tap()
        verifyOnChangePayload(expectedValue: 1752402600000) // static value
        app.buttons["PopoverDismissRegion"].tap()
        
        // Field 4: Time field at index 7
        let thirdTimeButton = app.buttons.element(boundBy: 7)
        thirdTimeButton.tap()
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "2")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "15")
        verifyOnChangePayload(expectedValue: 1752396300000) // static value for 2:15 AM
        app.buttons["PopoverDismissRegion"].tap()
        
        // Field 5: Read-only date field at index 5
        let readonlyButton = app.buttons.element(boundBy: 5)
        readonlyButton.tap()
        sleep(1)
        let readonlyDateLabel = formattedAccessibilityLabel(for: "2025-07-11")
        let readonlyDate = app.buttons[firstDateLabel]
        XCTAssertFalse(readonlyDate.exists, "Readonly date label should not exist: \(firstDateLabel)")
    }
    
    func testMatchPayloadFieldsValue() {
        // Field 1: Date field at index 2
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        verifyOnChangePayload(expectedValue: 1752690600000) // static value
        app.buttons["PopoverDismissRegion"].tap()
        
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686f4e36557902657597794c")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686f4e3b58a0861ac3f1ebfa")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686f4e3b613b3abcf155d775")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
    }
    
    func testChangeMonthAndYear() {
        // Field 1: Date field at index 2
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-12")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        firstDateButton.tap() // open month and year picker wheels
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "May")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2024")
        firstDateButton.tap() // hide month and year picker
        app.buttons["PopoverDismissRegion"].tap()
        app.swipeUp()
        app.swipeDown()
        verifyOnChangePayload(expectedValue: 1715452200000) // static value
        sleep(1)
        let newButton = app.buttons.matching(NSPredicate(format: "value == %@", "12 May 2024")).firstMatch
        XCTAssertTrue(newButton.waitForExistence(timeout: 2), "Expected to find button")
        newButton.tap()
    }
    
    func testChangeMonthWithNextAndPrevious() {
        // Field 1: Date field at index 2
        let firstDateButton = app.buttons.element(boundBy: 2)
        firstDateButton.tap()
        let previousButton = app.buttons.matching(identifier: "DatePicker.PreviousMonth").element(boundBy: 0)
        XCTAssertTrue(previousButton.waitForExistence(timeout: 2), "Previous month button should show")
        previousButton.tap()
        previousButton.tap()
        let nextButton = app.buttons.matching(identifier: "DatePicker.NextMonth").element(boundBy: 0)
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2), "Next month button should show")
        nextButton.tap()
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-06-25")
        let firstDate = app.buttons[firstDateLabel]
        XCTAssertTrue(firstDate.exists, "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        app.buttons["PopoverDismissRegion"].tap()
        verifyOnChangePayload(expectedValue: 1750789800000) // static value
        sleep(1)
        let newButton = app.buttons.matching(NSPredicate(format: "value == %@", "25 Jun 2025")).firstMatch
        XCTAssertTrue(newButton.waitForExistence(timeout: 2), "Expected to find button")
        newButton.tap()
    }
    
    func formattedAccessibilityLabel(for isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US")
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: isoDate) else {
            XCTFail("Invalid date string: \(isoDate)")
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "en_US")
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: with comma
            if #available(iOS 19.0, *) {
                   outputFormatter.dateFormat = "EEEE, d MMMM"
            } else {
                outputFormatter.dateFormat = "EEEE d MMMM"
            }
        } else {
            // iPhone: no comma
            outputFormatter.dateFormat = "EEEE d MMMM"
        }
        
        return outputFormatter.string(from: date)
    }
    
    func verifyOnChangePayload(expectedValue: Double) {
        let payload = onChangeResult().dictionary
        
        guard
            let change = payload["change"] as? [String: Any],
            let actualValue = change["value"] as? Double
        else {
            XCTFail("Invalid onChange payload structure")
            return
        }
        
        XCTAssertEqual(actualValue, expectedValue, "onChange payload value should match expected value")
    }
}
