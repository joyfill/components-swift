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
        
        // DatePicker should already be visible since field has a value
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "First date picker should be visible")
        firstDatePicker.tap()
        
        let firstDate = app.buttons["15 Jul 2025"].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist")
        firstDate.tap()
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    
    func testDatePickerValueAfterScrollPage() {
        // Field 1: Date field at index 2 - DatePicker should already be visible
        let datePicker = app.datePickers["DateIdenitfier"].firstMatch
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3), "Date picker should be visible")
        
        let firstDate = app.buttons["15 Jul 2025"].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist")
        firstDate.tap()
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let dateField = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist: \(firstDateLabel)")
        dateField.tap()
        app.buttons["PopoverDismissRegion"].tap()
        
        // Dismiss the picker and scroll to test value persistence
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        app.swipeUp()
        app.swipeDown()
        
        // Verify the payload was updated correctly
        verifyOnChangePayload(expectedValue: 1752748200000) // static value
    }
    
    func testDateFieldOnFocusAndOnBlur() {
        // DatePicker should already be visible since field has a value
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "Date picker should already be visible")
        firstDatePicker.tap()
        
        // Verify we can interact with date buttons
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-12")
        let firstDate = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "Date picker should be in focus")
        
        // Tap outside to blur
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        
        // Since the field has a value, the DatePicker should remain visible
        // (The DateTimeView keeps the picker open when there's a value)
        XCTAssertTrue(firstDatePicker.exists, "Date picker remains visible since field has value")
    }
    
    
    func testOpenDatePickerAndChangeDate() {
        let calendarButton = app.buttons["15 Jul 2025"]
        XCTAssertTrue(calendarButton.exists, "Calendar button should exist to open date picker")
        calendarButton.tap()
        
        // Date picker should already be visible since the field has a value
        let datePicker = app.datePickers["DateIdenitfier"]
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3), "Date picker should be visible")
        
        // Format the expected date dynamically (handles iPhone/iPad differences)
        let formattedDate = formattedAccessibilityLabel(for: "2025-07-17")
        let newDateButton = app.buttons[formattedDate]
        XCTAssertTrue(newDateButton.waitForExistence(timeout: 5), "Formatted date button should exist: \(formattedDate)")
        newDateButton.tap()
        app.buttons["PopoverDismissRegion"].tap()
        // Wait for the change to be processed
//        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: app.staticTexts["resultfield"])
//        wait(for: [expectation], timeout: 3)
        verifyOnChangePayload(expectedValue: 1752748200000)
    }
    
    func testCalendarFieldValueChanges() {
        // Field 1: Date field - DatePicker should already be visible since it has a value
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "First date picker should be visible")
        firstDatePicker.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let firstDate = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        verifyOnChangePayload(expectedValue: 1752690600000) // static value
        // Dismiss picker and scroll to access other fields
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        app.swipeUp()
        
        // Field 2: Time field - find time picker
        let timePicker = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Time'")).firstMatch
        if timePicker.waitForExistence(timeout: 3) {
            timePicker.tap()
            
            // Wait for picker wheels to appear and check if they exist
            if app.pickerWheels.count > 1 {
                app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "10")
                app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "30")
                verifyOnChangePayload(expectedValue: 946746000000) // static value for 10:30 AM
            }
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        }
        
        // Field 3: Another date field
        let secondDatePicker = app.datePickers.element(boundBy: 1)
        if secondDatePicker.waitForExistence(timeout: 3) {
            let thirdDateLabel = formattedAccessibilityLabel(for: "2025-07-13")
            let thirdDate = app.buttons[thirdDateLabel].firstMatch
            if thirdDate.waitForExistence(timeout: 3) {
                thirdDate.tap()
                verifyOnChangePayload(expectedValue: 1752345000000) // static value
            }
        }
    }
    
    func testMatchPayloadFieldsValue() {
        // Field 1: Date field - DatePicker should already be visible
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "First date picker should be visible")
        firstDatePicker.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-17")
        let firstDate = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        verifyOnChangePayload(expectedValue: 1752690600000) // static value
        
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
            let tzValue = change["tz"] as? String
        else {
            XCTFail("Invalid onChange payload structure")
            return
        }
        XCTAssertEqual(tzValue, "Asia/Kolkata")
    }
    
    func testChangeMonthAndYear() {
        // DatePicker should already be visible since field has a value
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "First date picker should be visible")
        firstDatePicker.tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-12")
        let firstDate = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        
        // Find the month/year picker button to access picker wheels
        let monthYearButton = app.buttons.matching(identifier: "DatePicker.Show").firstMatch
        XCTAssertTrue(monthYearButton.waitForExistence(timeout: 3), "Month/year picker button should exist")
        monthYearButton.tap() // open month and year picker wheels
        
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "May")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "2024")
        app.buttons["PopoverDismissRegion"].tap()
        
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        app.swipeUp()
        app.swipeDown()
        verifyOnChangePayload(expectedValue: 1715452200000) // static value
    }
    
    func testChangeMonthWithNextAndPrevious() {
        // DatePicker should already be visible since field has a value
        let firstDatePicker = app.datePickers.element(boundBy: 0)
        XCTAssertTrue(firstDatePicker.waitForExistence(timeout: 3), "First date picker should be visible")
        firstDatePicker.tap()
        
        let previousButton = app.buttons.matching(identifier: "DatePicker.PreviousMonth").element(boundBy: 0)
        
        XCTAssertTrue(previousButton.waitForExistence(timeout: 3), "Previous month button should show")
        previousButton.tap()
        previousButton.tap()
        let nextButton = app.buttons.matching(identifier: "DatePicker.NextMonth").element(boundBy: 0)
        
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3), "Next month button should show")
        nextButton.tap()
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-06-25")
        
        let firstDate = app.buttons[firstDateLabel].firstMatch
        XCTAssertTrue(firstDate.waitForExistence(timeout: 3), "First date label should exist: \(firstDateLabel)")
        firstDate.tap()
        
        // Tap outside the date picker to dismiss it
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1)).tap()
        verifyOnChangePayload(expectedValue: 1750789800000) // static value
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
            if #available(iOS 26.0, *) {
                outputFormatter.dateFormat = "EEEE, d MMMM"
            } else {
                outputFormatter.dateFormat = "EEEE d MMMM"
            }
        }
        
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
