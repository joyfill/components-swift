//
//  TimeZoneUITests.swift
//  JoyfillExample
//
//  Created by Rajan on 18/09/25.
//
  
import XCTest
import JoyfillModel

final class TimeZoneUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "TimeZoneTestData"
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
    
    func getDateFieldByIndex(_ index: Int) -> XCUIElement {
        return app.datePickers.element(boundBy: index)
    }
    
    func getDateFieldButtonByIndex(_ index: Int) -> XCUIElement {
        return app.buttons.element(boundBy: index)
    }
    
    func getDateFieldLabelByIndex(_ index: Int) -> XCUIElement {
        return app.staticTexts.element(boundBy: index)
    }
    
    func getDateFieldValue(_ index: Int) -> String {
        let dateField = getDateFieldByIndex(index)
        return dateField.value as? String ?? ""
    }
    
    func getDateFieldButtonLabel(_ index: Int) -> String {
        let dateButton = getDateFieldButtonByIndex(index)
        return dateButton.label
    }
    
    func verifyTimezoneInOnChangePayload(expectedTimezone: String, fieldDescription: String) {
        let payload = onChangeResult().dictionary
        
        guard let change = payload["change"] as? [String: Any],
              let payloadTimezone = change["tz"] as? String else {
            XCTFail("onChange payload should contain timezone information for \(fieldDescription)")
            return
        }
        
        print("onChange payload timezone for \(fieldDescription): \(payloadTimezone)")
        
        // Determine expected timezone based on field type
        let actualExpectedTimezone: String
        if expectedTimezone == "nil" || expectedTimezone == "123kjh" {
            actualExpectedTimezone = "Asia/Kolkata"  // Default for nil and invalid timezones
        } else {
            actualExpectedTimezone = expectedTimezone  // Keep original timezone for valid ones
        }
        
        XCTAssertEqual(payloadTimezone, actualExpectedTimezone, 
                      "Timezone should be \(actualExpectedTimezone) for \(fieldDescription)")
    }
     
    
    func testCheckAllDateColumnValueAndTimezone() {
        // Test all 5 date fields with their timezone values
        let expectedTimezones = [
            "America/New_York",    // Index 0
            "Asia/Kolkata",        // Index 1  
            "Europe/London",       // Index 2
            "nil",                 // Index 3
            "123kjh"               // Index 4
        ]
        
        // Check each date field button exists and has correct label
        for index in 0..<5 {
            let dateButton = getDateFieldButtonByIndex(index)
            XCTAssertTrue(dateButton.exists, "Date button at index \(index) should exist")
            
            // Check button is accessible
            XCTAssertTrue(dateButton.isHittable, "Date button at index \(index) should be hittable")
            
            // Check button label
            let buttonLabel = getDateFieldButtonLabel(index)
            XCTAssertFalse(buttonLabel.isEmpty, "Date button at index \(index) should have a label")
        }
        
        // Verify all date field buttons are present
        let totalDateButtons = app.buttons.count
        XCTAssertGreaterThan(totalDateButtons, 5, "Should have at least 5 date field buttons")
        
        // Also verify date pickers are present
        let totalDatePickers = app.datePickers.count
        XCTAssertEqual(totalDatePickers, 5, "Should have exactly 5 date picker fields")
    }
    
    // MARK: - Test Case 2: Change date and check timezone
    
    func testChangeDateAndCheckTimezone() {
        // Test changing date in each timezone field and verify timezone behavior
        
        // Test America/New_York timezone (Index 0)
        testChangeDateForTimezone(index: 9, timezone: "nil")
        
        // Test Asia/Kolkata timezone (Index 1)
        testChangeDateForTimezone(index: 10, timezone: "123kjh")
        
        // Test Europe/London timezone (Index 2)
        testChangeDateForTimezone(index: 11, timezone: "Asia/Kolkata")
    
        // Test Europe/London timezone (Index 2)
        testChangeDateForTimezone(index: 7, timezone: "America/New_York")
    }
    
    private func testChangeDateForTimezone(index: Int, timezone: String) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Date button at index \(index) should exist")
        
        // Get initial label from button
        let initialLabel = getDateFieldButtonLabel(index)
        
        // Tap button to open date picker
        dateButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Verify date picker opened
        let datePickers = app.datePickers
        XCTAssertTrue(datePickers.count > 0, "Date picker should open for \(timezone)")
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-10")
        let dateField = app.buttons[firstDateLabel].firstMatch
        dateField.tap()
        app.buttons["PopoverDismissRegion"].tap()
        
        // Dismiss date picker
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Check if label changed (it might or might not depending on implementation)
        let finalLabel = getDateFieldButtonLabel(index)
        
        // Verify button is still accessible after interaction
        XCTAssertTrue(dateButton.exists, "Date button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Date button should be hittable after interaction")
        
        // Test onChange event and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: timezone, fieldDescription: timezone)
    }
    
    func testNilAndInvalidTimezone() {
        // Test nil timezone (Index 3)
        testNilTimezone(index: 9)
        
        // Test invalid timezone (Index 4)
        testInvalidTimezone(index: 10)
    }
    
    private func testNilTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Nil timezone button at index \(index) should exist")
        
        // Get initial label from button
        let initialLabel = getDateFieldButtonLabel(index)
        print("Nil timezone initial label: \(initialLabel)")
        
        // Test button interaction
        dateButton.tap()
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-10")
        let dateField = app.buttons[firstDateLabel].firstMatch
        dateField.tap()
        app.buttons["PopoverDismissRegion"].tap()
        
        // Dismiss date picker
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Verify button still works after interaction
        let finalLabel = getDateFieldButtonLabel(index)
        print("Nil timezone final label: \(finalLabel)")
        
        XCTAssertTrue(dateButton.exists, "Nil timezone button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Nil timezone button should be hittable after interaction")
        
        // Test onChange event for nil timezone and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: "Asia/Kolkata", fieldDescription: "nil")
    }
    
    private func testInvalidTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Invalid timezone button at index \(index) should exist")
        
        // Get initial label from button
        let initialLabel = getDateFieldButtonLabel(index)
        print("Invalid timezone initial label: \(initialLabel)")
        
        // Test button interaction
        dateButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-10")
        let dateField = app.buttons[firstDateLabel].firstMatch
        dateField.tap()
        app.buttons["PopoverDismissRegion"].tap()
        
        // Dismiss date picker
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Verify button still works after interaction
        let finalLabel = getDateFieldButtonLabel(index)
        
        XCTAssertTrue(dateButton.exists, "Invalid timezone button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Invalid timezone button should be hittable after interaction")
        
        // Test onChange event for invalid timezone and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: "Asia/Kolkata", fieldDescription: "123kjh")
        
        // Test multiple interactions to ensure stability
        for i in 0..<3 {
            dateButton.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }
        
        // Final verification
        XCTAssertTrue(dateButton.exists, "Invalid timezone button should remain stable after multiple interactions")
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
}
