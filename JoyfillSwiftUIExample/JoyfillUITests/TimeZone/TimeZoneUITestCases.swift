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
        outputFormatter.dateFormat = "EEEE, MMMM d"
        
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
        let totalDateButtons = app.buttons.matching(identifier:"ChangeDateIdentifier")
        
        XCTAssertEqual(totalDateButtons.count, 5, "Should have at least 5 date field buttons")
    }
    
    // MARK: - Test Case 2: Change date and check timezone
    func getDateFieldButtonByIndexAndIdentifier(_ index: Int) -> XCUIElement {
        return app.buttons.matching(identifier: "ChangeDateIdentifier").element(boundBy: index)
    }
    
    func testChangeDateAndCheckTimezone() {
        testChangeDateForTimezone(index: 0, timezone: "Asia/Kolkata")
        testChangeDateForTimezone(index: 1, timezone: "America/New_York")
        testChangeDateForTimezone(index: 3, timezone: "nil")
        testChangeDateForTimezone(index: 4, timezone: "123kjh")
    }
    
    private func testChangeDateForTimezone(index: Int, timezone: String) {
        let dateButton = getDateFieldButtonByIndexAndIdentifier(index)
        XCTAssertTrue(dateButton.exists, "Date button at index \(index) should exist")
         
        // Tap button to open date picker
        dateButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Verify date picker opened
        let datePickers = app.datePickers
        XCTAssertTrue(datePickers.count > 0, "Date picker should open for \(timezone)")
        
        let dateButtons = app.datePickers.firstMatch.buttons
        let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("10") })

        if let day10Button = day10Button {
            day10Button.tap()
        } else {
            XCTFail("No button found containing '10'")
        }
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        // Verify button is still accessible after interaction
        XCTAssertTrue(dateButton.exists, "Date button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Date button should be hittable after interaction")
        
        // Test onChange event and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: timezone, fieldDescription: timezone)
    }
    
    func testConvertEpochWithTimeZone() {
        let dateButton2 = getDateFieldButtonByIndexAndIdentifier(1)
        let convertedTime = formatEpoch(1752530400000, timeZoneTitle: "America/New_York", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        
        XCTAssertEqual(dateButton2.label, convertedTime, "Datetime should be same after epoch convert")
    }
    
    func testNilAndInvalidTimezone() {
        
        testNilTimezone(index: 3)
        testInvalidTimezone(index: 4)
    }
    
    private func testNilTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndexAndIdentifier(index)
        XCTAssertTrue(dateButton.exists, "Nil timezone button at index \(index) should exist")
         
        // Test button interaction
        dateButton.tap()
        
        let dateButtons = app.datePickers.firstMatch.buttons
        let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("10") })

        if let day10Button = day10Button {
            day10Button.tap()
        } else {
            XCTFail("No button found containing '10'")
        }
                
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        XCTAssertTrue(dateButton.exists, "Nil timezone button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Nil timezone button should be hittable after interaction")
        
        verifyTimezoneInOnChangePayload(expectedTimezone: "Asia/Kolkata", fieldDescription: "nil")
    }
    
    private func testInvalidTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndexAndIdentifier(index)
        XCTAssertTrue(dateButton.exists, "Invalid timezone button at index \(index) should exist")
         
        // Test button interaction
        dateButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let dateButtons = app.datePickers.firstMatch.buttons
        let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("10") })

        if let day10Button = day10Button {
            day10Button.tap()
        } else {
            XCTFail("No button found containing '10'")
        }
        
//        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-10")
//        let dateField = app.buttons[firstDateLabel].firstMatch
//        dateField.tap()
//        app.buttons["PopoverDismissRegion"].tap()
        
        // Dismiss date picker
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        XCTAssertTrue(dateButton.exists, "Invalid timezone button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Invalid timezone button should be hittable after interaction")
        
        // Test onChange event for invalid timezone and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: "Asia/Kolkata", fieldDescription: "123kjh")
        
        // Test multiple interactions to ensure stability
        for _ in 0..<3 {
            dateButton.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }
        
        // Final verification
        XCTAssertTrue(dateButton.exists, "Invalid timezone button should remain stable after multiple interactions")
    }
    
//    func testBlankDateField() {
//        var firstIndex = 5
//        var secondIndex = 6
//        if UIDevice.current.userInterfaceIdiom == .pad  {
//            firstIndex = 23
//            secondIndex = 24
//        } else {
//            app.swipeUp()
//        }
//        
//        let calendarImage = app.images.element(boundBy: 1)
//        calendarImage.tap()
//        let currentEpochMs = Int64(Date().timeIntervalSince1970 * 1000)
//        
//        // Get initial label from button
//        let firstLabel = getDateFieldButtonLabel(firstIndex)
//        let secondLabel = getDateFieldButtonLabel(secondIndex)
//        let fullLabel = (firstLabel + " " + secondLabel).normalizedSpaces
//        let convertedTime = formatEpoch(currentEpochMs, timeZoneTitle: "Asia/Kolkata", format: "")?.normalizedSpaces
//        
//        XCTAssertEqual(fullLabel, convertedTime, "Datetime should be same after epoch convert")
//        
//        let payload = onChangeResult().dictionary
//        guard
//            let change = payload["change"] as? [String: Any],
//            let actualValue = change["value"] as? Int64,
//            let actualTZ = change["tz"] as? String else {
//            XCTFail("Invalid onChange payload structure")
//            return
//        }
//        
//        XCTAssertNotNil(actualValue)
//        XCTAssertEqual(actualTZ, "America/New_York", "onChange payload value should match expected value")
//    }
    
    /* Table timezone UI test cases */
    
    func testTableTimezoneFields() throws {
        goToTableDetailPage()
        
        // Test Case 1: Check all table timezone fields
        tableCheckAllTimezoneFields()
        
        // Test Case 2: Change date time and check timezone
        tableChangeDateTimeAndCheckTimezone()
        
        // Test Case 3: Nil and invalid timezone behavior
        tableNilAndInvalidTimezone()
    }
    
    private func tableCheckAllTimezoneFields() {
        let tableTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        XCTAssertGreaterThan(tableTimezoneFields.count, 0, "Table should have timezone date fields")
        
        // Check each timezone field in table
        for index in 0..<tableTimezoneFields.count {
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
            XCTAssertTrue(timezoneField.isHittable, "Table timezone field at index \(index) should be hittable")
            
            let fieldLabel = timezoneField.label
            XCTAssertFalse(fieldLabel.isEmpty, "Table timezone field at index \(index) should have a label")
        }
        
        // Also check for column buttons
        let columnButtons = app.images.matching(identifier: "ColumnButtonIdentifier")
        XCTAssertGreaterThan(columnButtons.count, 0, "Table should have column buttons")
        
        for index in 0..<columnButtons.count {
            let columnButton = columnButtons.element(boundBy: index)
            XCTAssertTrue(columnButton.exists, "Table column button at index \(index) should exist")
            
            let columnLabel = columnButton.label
            XCTAssertFalse(columnLabel.isEmpty, "Table column button at index \(index) should have a label")
        }
    }
    
    private func tableChangeDateTimeAndCheckTimezone() {
        // Use the correct button selector for table date fields
        let tableTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        
        // Test changing date/time for each table timezone field
        for index in 0..<min(tableTimezoneFields.count, 6) { // Test first 3 fields
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
             
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
            let dateButtons = app.datePickers.firstMatch.buttons
            let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("15") })

            if let day10Button = day10Button {
                day10Button.tap()
            } else {
                XCTFail("No button found containing '10'")
            }
//            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-15")
//            let dateField = app.buttons[firstDateLabel].firstMatch
//            if dateField.exists {
//                dateField.tap()
//            }
            
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
             
            // Verify onChange event and timezone for table row
            let payload = onChangeResult().dictionary
            XCTAssertNotNil(payload, "Table timezone field should trigger onChange event")
            
            // Table has row-based timezone structure
            if let change = payload["change"] as? [String: Any],
               let row = change["row"] as? [String: Any],
               let payloadTimezone = row["tz"] as? String {
                XCTAssertFalse(payloadTimezone.isEmpty, "Table timezone should not be empty")
                
                // Verify row structure
                if let rowId = change["rowId"] as? String {
                    XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
                }
                
                // Verify cells structure
                if let cells = row["cells"] as? [String: Any] {
                    XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
                }
            } else {
                XCTFail("Table onChange payload should contain row-based timezone structure")
            }
        }
    }
    
    private func tableNilAndInvalidTimezone() {
        // Use the correct button selector for table date fields
        let tableTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        
        // Test nil and invalid timezone fields in table
        for index in 2..<min(tableTimezoneFields.count, 6) { // Test first 2 fields for nil/invalid
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
             
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
//            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-12")
//            let dateField = app.buttons[firstDateLabel].firstMatch
//            if dateField.exists {
//                dateField.tap()
//            }
            let dateButtons = app.datePickers.firstMatch.buttons
            let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("12") })

            if let day10Button = day10Button {
                day10Button.tap()
            } else {
                XCTFail("No button found containing '10'")
            }
            
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
             
            // Verify timezone behavior for nil/invalid timezones in table row
            let payload = onChangeResult().dictionary
            if let change = payload["change"] as? [String: Any],
               let row = change["row"] as? [String: Any],
               let payloadTimezone = row["tz"] as? String {
                
                // For nil and invalid timezones, should default to current timezone (Asia/Kolkata)
                XCTAssertEqual(payloadTimezone, "Asia/Kolkata", 
                              "Table nil/invalid timezone should default to Asia/Kolkata")
                
                // Verify row structure for nil/invalid timezones
                if let rowId = change["rowId"] as? String {
                    XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
                }
                
                // Verify cells structure for nil/invalid timezones
                if let cells = row["cells"] as? [String: Any] {
                    XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
                }
            } else {
                XCTFail("Table nil/invalid timezone onChange payload should contain row-based timezone structure")
            }
        }
    }
    
    func testTableBlankDateTimeWithDifferentTimezone() {
        app.swipeUp()
        goToTableDetailPage()
        let CalendarImages = app.images.matching(identifier: "CalendarImageIdentifier")
        CalendarImages.element(boundBy: 0).tap()
        
        let currentEpochMs = Int64(Date().timeIntervalSince1970 * 1000)
        let convertedTime = formatEpoch(currentEpochMs, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField = app.buttons[convertedTime ?? ""].firstMatch
        XCTAssertEqual(dateField.label, convertedTime, "Datetime should be same after epoch convert")
        
        let payload = onChangeResult().dictionary
        if let change = payload["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
        
        // Use the correct button selector for table date fields
        let tableTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        
        let timezoneField = tableTimezoneFields.element(boundBy: 8)
        XCTAssertTrue(timezoneField.waitForExistence(timeout: 5), "Table timezone field at index \(String(describing: index)) should exist")
        timezoneField.tap()
        
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let payload2 = onChangeResult().dictionary
        if let change = payload2["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
        
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.images.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        dismissSheet()
        let convertedTime2 = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField2 = app.buttons[convertedTime2 as? String ?? ""].firstMatch
        XCTAssertEqual(dateField2.label, convertedTime2, "Datetime should be same after epoch convert")
        
        let payload3 = onChangeResult().dictionary
        if let change = payload3["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
    }
    
    func testTableBlankDateTimeWithDifferentTimezoneBulkEdit() {
        app.swipeUp()
        goToTableDetailPage()
        
        let checkButtons = app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton")
        checkButtons.element(boundBy: 0).tap()
        checkButtons.element(boundBy: 1).tap()
        checkButtons.element(boundBy: 2).tap()
        checkButtons.element(boundBy: 3).tap()
        checkButtons.element(boundBy: 4).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let dateFields = app.images.matching(identifier: "EditRowsDateFieldIdentifier")
        dateFields.element(boundBy: 0).tap()
        dateFields.element(boundBy: 1).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        app.buttons["ApplyAllButtonIdentifier"].tap()
        let convertedTime = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
         
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let tableTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '\(monthName)'"))
        
        // Test nil and invalid timezone fields in table
        for index in 0..<min(tableTimezoneFields.count, 10) { // Test first 2 fields for nil/invalid
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
            XCTAssertEqual(timezoneField.label, convertedTime)
        }
        
        let result = onChangeResult()

//        if let payloadArray = result.dictionary as? [[String: Any]] {
//            // Multiple payloads
//            for (index, payload3) in payloadArray.enumerated() {
//                if let change = payload3["change"] as? [String: Any],
//                   let row = change["row"] as? [String: Any],
//                   let payloadTimezone = row["tz"] as? String {
//                    
//                    XCTAssertNotNil(payloadTimezone)
//                    
//                    if let rowId = change["rowId"] as? String {
//                        XCTAssertFalse(rowId.isEmpty, "Row ID should not be empty (index \(index))")
//                    }
//                    
//                    if let cells = row["cells"] as? [String: Any] {
//                        XCTAssertGreaterThan(cells.count, 0, "Cells should not be empty (index \(index))")
//                    }
//                } else {
//                    XCTFail("Payload missing row-based timezone structure (index \(index))")
//                }
//            }
//        } else {
//            XCTFail("Table onChange payload should contain row-based timezone structure")
//        }
    }
    
    func testTableBlankDateTimeWithoutTimezone() {
        app.swipeUp()
        goToTableDetailPage()
         
        let dateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        dateFields.element(boundBy: 2).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        let convertedTime = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField = app.buttons[convertedTime ?? ""].firstMatch
        XCTAssertEqual(dateField.label, convertedTime, "Datetime should be same after epoch convert")
        
        let payload = onChangeResult().dictionary
        XCTAssertNotNil(payload, "Table single edit first date field should trigger onChange event")
        
        if let change = payload["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
            XCTAssertEqual(payloadTimezone, "Asia/Kolkata", "Table single edit first date field timezone should be Asia/Kolkata")
        } else {
            XCTFail("Table single edit first date field onChange payload should contain row-based timezone structure")
        }
    }
    
    func testTableSingleEdit() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
          
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 0).tap()
        let dateButtons = app.datePickers.firstMatch.buttons
        let day11Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("11") })

        if let day11Button = day11Button {
            day11Button.tap()
        } else {
            XCTFail("No button found containing '11'")
        }
        dismissSheet()
        app.buttons["LowerRowButtonIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["UpperRowButtonIdentifier"].tap()
        
        // Verify timezone in onChange result for first date field
        let payload1 = onChangeResult().dictionary
        XCTAssertNotNil(payload1, "Table single edit first date field should trigger onChange event")
        
        if let change1 = payload1["change"] as? [String: Any],
           let row1 = change1["row"] as? [String: Any],
           let payloadTimezone1 = row1["tz"] as? String {
            XCTAssertEqual(payloadTimezone1, "Asia/Kolkata", "Table single edit first date field timezone should be Asia/Kolkata")
        } else {
            XCTFail("Table single edit first date field onChange payload should contain row-based timezone structure")
        }
        
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        let day17Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("17") })

        if let day17Button = day17Button {
            day17Button.tap()
        } else {
            XCTFail("No button found containing '17'")
        }

        dismissSheet()
        app.buttons["LowerRowButtonIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["UpperRowButtonIdentifier"].tap()
        dismissSheet()
        
        // Verify timezone in onChange result for second date field
        let payload2 = onChangeResult().dictionary
        XCTAssertNotNil(payload2, "Table single edit second date field should trigger onChange event")
        
        if let change2 = payload2["change"] as? [String: Any],
           let row2 = change2["row"] as? [String: Any],
           let payloadTimezone2 = row2["tz"] as? String {
            XCTAssertEqual(payloadTimezone2, "Asia/Kolkata", "Table single edit second date field timezone should be Asia/Kolkata")
        } else {
            XCTFail("Table single edit second date field onChange payload should contain row-based timezone structure")
        }
         
    }
    
    func testTableBulkEdit() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 1).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        var firstIndex = 0
        var secondIndex = 1
        if UIDevice.current.userInterfaceIdiom == .pad  {
            firstIndex = 2
            secondIndex = 3
        }
        app.images.element(boundBy: firstIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 0).tap()
        // Try to tap any available date in current month
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        dismissSheet()
        app.images.element(boundBy: secondIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        // Try to tap any available date in current month
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        dismissSheet()
        app.buttons["ApplyAllButtonIdentifier"].tap()
        
        // Verify timezone in onChange result for second date field in bulk edit
        let payload2 = onChangeResult().dictionary
        XCTAssertNotNil(payload2, "Table bulk edit second date field should trigger onChange event")
        
        if let change2 = payload2["change"] as? [String: Any],
           let row2 = change2["row"] as? [String: Any],
           let payloadTimezone2 = row2["tz"] as? String {
            XCTAssertEqual(payloadTimezone2, "Asia/Kolkata", "Table bulk edit second date field timezone should be Asia/Kolkata")
        } else {
            XCTFail("Table bulk edit second date field onChange payload should contain row-based timezone structure")
        }
    }
    
    /* Collection timezone UI test cases */
    
    func testCollectionTimezoneFields() throws {
        app.swipeUp()
        goToCollectionDetailPage()
        
        // Test Case 1: Check all collection timezone fields
        testCollectionCheckAllTimezoneFields()
        
        // Test Case 2: Change date time and check timezone
        testCollectionChangeDateTimeAndCheckTimezone()
        
        // Test Case 3: Nil and invalid timezone behavior
        testCollectionNilAndInvalidTimezone()
    }
    
    private func testCollectionCheckAllTimezoneFields() {
        // Check that all collection timezone fields are present and accessible
        // Based on the button output, collection date fields have labels like "September 10, 2025 9:00 AM"
        let collectionTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        XCTAssertGreaterThan(collectionTimezoneFields.count, 0, "Collection should have timezone date fields")
        
        // Check each timezone field in collection
        for index in 0..<collectionTimezoneFields.count {
            let timezoneField = collectionTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Collection timezone field at index \(index) should exist")
            XCTAssertTrue(timezoneField.isHittable, "Collection timezone field at index \(index) should be hittable")
            
            let fieldLabel = timezoneField.label
            XCTAssertFalse(fieldLabel.isEmpty, "Collection timezone field at index \(index) should have a label")
            
            print("Collection timezone field \(index): \(fieldLabel)")
        }
    }
    
    private func testCollectionChangeDateTimeAndCheckTimezone() {
        // Use the correct button selector for collection date fields
        let collectionTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        
        // Test changing date/time for each collection timezone field
        for index in 0..<min(collectionTimezoneFields.count, 6) { // Test first 3 fields
            let timezoneField = collectionTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Collection timezone field at index \(index) should exist")
            
            // Get initial label
            let initialLabel = timezoneField.label
            print("Collection timezone field \(index) initial label: \(initialLabel)")
            
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
            let dateButtons = app.datePickers.firstMatch.buttons
            let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("15") })

            if let day10Button = day10Button {
                day10Button.tap()
            } else {
                XCTFail("No button found containing '10'")
            }
//            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-15")
//            let dateField = app.buttons[firstDateLabel].firstMatch
//            if dateField.exists {
//                dateField.tap()
//            }
            // Dismiss date picker
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Get final label
            let finalLabel = timezoneField.label
            print("Collection timezone field \(index) final label: \(finalLabel)")
            
            // Verify onChange event and timezone for collection row
            let payload = onChangeResult().dictionary
            XCTAssertNotNil(payload, "Collection timezone field should trigger onChange event")
            
            // Collection has row-based timezone structure similar to table
            if let change = payload["change"] as? [String: Any],
               let row = change["row"] as? [String: Any],
               let payloadTimezone = row["tz"] as? String {
                print("Collection timezone field \(index) onChange timezone: \(payloadTimezone)")
                XCTAssertFalse(payloadTimezone.isEmpty, "Collection timezone should not be empty")
                
                // Verify timezone matches expected value
                XCTAssertEqual(payloadTimezone, "Asia/Kolkata", 
                              "Collection timezone should be Asia/Kolkata")
                
                // Verify row structure
                if let rowId = change["rowId"] as? String {
                    print("Collection row ID: \(rowId)")
                    XCTAssertFalse(rowId.isEmpty, "Collection row ID should not be empty")
                }
                
                // Verify cells structure
                if let cells = row["cells"] as? [String: Any] {
                    print("Collection row cells: \(cells)")
                    XCTAssertGreaterThan(cells.count, 0, "Collection row should have cells")
                }
                
                // Verify collection-specific fields
                if let parentPath = change["parentPath"] as? String {
                    print("Collection parent path: \(parentPath)")
                }
                
                if let schemaId = change["schemaId"] as? String {
                    print("Collection schema ID: \(schemaId)")
                    XCTAssertEqual(schemaId, "collectionSchemaId", "Collection should have correct schema ID")
                }
            } else {
                XCTFail("Collection onChange payload should contain row-based timezone structure")
            }
        }
    }
    
    private func testCollectionNilAndInvalidTimezone() {
        // Use the correct button selector for collection date fields
        let collectionTimezoneFields = app.buttons.matching(identifier: "ChangeCellDateIdentifier")
        
        // Test nil and invalid timezone fields in collection
        for index in 2..<min(collectionTimezoneFields.count, 6) { // Test first 2 fields for nil/invalid
            let timezoneField = collectionTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Collection timezone field at index \(index) should exist")
            
            // Get initial label
            let initialLabel = timezoneField.label
            print("Collection nil/invalid timezone field \(index) initial label: \(initialLabel)")
            
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
            let dateButtons = app.datePickers.firstMatch.buttons
            let day10Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("12") })

            if let day10Button = day10Button {
                day10Button.tap()
            } else {
                XCTFail("No button found containing '10'")
            }
//            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-12")
//            let dateField = app.buttons[firstDateLabel].firstMatch
//            if dateField.exists {
//                dateField.tap()
//            }
            
            // Dismiss date picker
            dismissSheet()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Get final label
            let finalLabel = timezoneField.label
            print("Collection nil/invalid timezone field \(index) final label: \(finalLabel)")
            
            // Verify timezone behavior for nil/invalid timezones in collection row
            let payload = onChangeResult().dictionary
            if let change = payload["change"] as? [String: Any],
               let row = change["row"] as? [String: Any],
               let payloadTimezone = row["tz"] as? String {
                print("Collection nil/invalid timezone field \(index) onChange timezone: \(payloadTimezone)")
                
                // For nil and invalid timezones, should default to current timezone (Asia/Kolkata)
                XCTAssertEqual(payloadTimezone, "Asia/Kolkata", 
                              "Collection nil/invalid timezone should default to Asia/Kolkata")
                
                // Verify row structure for nil/invalid timezones
                if let rowId = change["rowId"] as? String {
                    print("Collection nil/invalid timezone row ID: \(rowId)")
                    XCTAssertFalse(rowId.isEmpty, "Collection row ID should not be empty")
                }
                
                // Verify cells structure for nil/invalid timezones
                if let cells = row["cells"] as? [String: Any] {
                    print("Collection nil/invalid timezone row cells: \(cells)")
                    XCTAssertGreaterThan(cells.count, 0, "Collection row should have cells")
                }
                
                // Verify collection-specific fields for nil/invalid timezones
                if let parentPath = change["parentPath"] as? String {
                    print("Collection nil/invalid timezone parent path: \(parentPath)")
                }
                
                if let schemaId = change["schemaId"] as? String {
                    print("Collection nil/invalid timezone schema ID: \(schemaId)")
                    XCTAssertEqual(schemaId, "collectionSchemaId", "Collection should have correct schema ID")
                }
            } else {
                XCTFail("Collection nil/invalid timezone onChange payload should contain row-based timezone structure")
            }
        }
    }
    
    func testCollectionSingleEdit() throws {
        app.swipeUp()
        goToCollectionDetailPage()
        
        selectRow(number: 1)
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
          
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 0).tap()
        
        let dateButtons = app.datePickers.firstMatch.buttons
        let day15Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("15") })

        if let day15Button = day15Button {
            day15Button.tap()
        } else {
            XCTFail("No button found containing '10'")
        }
        dismissSheet()
        app.buttons["LowerRowButtonIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["UpperRowButtonIdentifier"].tap()
        
        // Verify timezone in onChange result for first date field in collection single edit
        let payload1 = onChangeResult().dictionary
        XCTAssertNotNil(payload1, "Collection single edit first date field should trigger onChange event")
        
        if let change1 = payload1["change"] as? [String: Any],
           let row1 = change1["row"] as? [String: Any],
           let payloadTimezone1 = row1["tz"] as? String {
            print("Collection single edit first date field onChange timezone: \(payloadTimezone1)")
            XCTAssertEqual(payloadTimezone1, "Asia/Kolkata", "Collection single edit first date field timezone should be Asia/Kolkata")
            
            // Verify collection-specific fields
            if let schemaId1 = change1["schemaId"] as? String {
                print("Collection single edit first date field schema ID: \(schemaId1)")
                XCTAssertEqual(schemaId1, "collectionSchemaId", "Collection should have correct schema ID")
            }
        } else {
            XCTFail("Collection single edit first date field onChange payload should contain row-based timezone structure")
        }
        
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        let day17Button = dateButtons.allElementsBoundByIndex.first(where: { $0.label.contains("17") })

        if let day17Button = day17Button {
            day17Button.tap()
        } else {
            XCTFail("No button found containing '07'")
        }
        dismissSheet()
        app.buttons["LowerRowButtonIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        app.buttons["UpperRowButtonIdentifier"].tap()
        dismissSheet()
        // Verify timezone in onChange result for second date field in collection single edit
        let payload2 = onChangeResult().dictionary
        XCTAssertNotNil(payload2, "Collection single edit second date field should trigger onChange event")
        
        if let change2 = payload2["change"] as? [String: Any],
           let row2 = change2["row"] as? [String: Any],
           let payloadTimezone2 = row2["tz"] as? String {
            XCTAssertEqual(payloadTimezone2, "Asia/Kolkata", "Collection single edit second date field timezone should be Asia/Kolkata")
            
            // Verify collection-specific fields
            if let schemaId2 = change2["schemaId"] as? String {
                XCTAssertEqual(schemaId2, "collectionSchemaId", "Collection should have correct schema ID")
            }
        } else {
            XCTFail("Collection single edit second date field onChange payload should contain row-based timezone structure")
        }
    }
    
    func testCollectionBulkEdit() throws {
        app.swipeUp()
        goToCollectionDetailPage()
        selectAllParentRows()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
        var firstIndex = 0
        var secondIndex = 1
        if UIDevice.current.userInterfaceIdiom == .pad  {
            firstIndex = 1
            secondIndex = 2
        }
        app.images.element(boundBy: firstIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 0).tap()
        // Try to tap any available date in current month
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        dismissSheet()
        
        app.images.element(boundBy: secondIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        // Try to tap any available date in current month
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        dismissSheet()
        app.buttons["ApplyAllButtonIdentifier"].tap()
        // Verify timezone in onChange result for second date field in collection bulk edit
        let payload2 = onChangeResult().dictionary
        XCTAssertNotNil(payload2, "Collection bulk edit second date field should trigger onChange event")
        
        if let change2 = payload2["change"] as? [String: Any],
           let row2 = change2["row"] as? [String: Any],
           let payloadTimezone2 = row2["tz"] as? String {
            XCTAssertEqual(payloadTimezone2, "Asia/Kolkata", "Collection bulk edit second date field timezone should be Asia/Kolkata")
            
            // Verify collection-specific fields
            if let schemaId2 = change2["schemaId"] as? String {
                XCTAssertEqual(schemaId2, "collectionSchemaId", "Collection should have correct schema ID")
            }
        } else {
            XCTFail("Collection bulk edit second date field onChange payload should contain row-based timezone structure")
        }
    }
    
    func testCollectionBlankDateTimeWithDifferentTimezone() {
        app.swipeUp()
        goToCollectionDetailPage()
        let CalendarImages = app.images.matching(identifier: "CalendarImageIdentifier")
        CalendarImages.element(boundBy: 0).tap()
        
        let currentEpochMs = Int64(Date().timeIntervalSince1970 * 1000)
        let convertedTime = formatEpoch(currentEpochMs, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField = app.buttons[convertedTime ?? ""].firstMatch
        XCTAssertEqual(dateField.label, convertedTime, "Datetime should be same after epoch convert")
        
        let payload = onChangeResult().dictionary
        if let change = payload["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
        
        // Use the correct button selector for table date fields
        let timezoneField = app.buttons["\(dateField.label)"].firstMatch
        XCTAssertTrue(timezoneField.waitForExistence(timeout: 5), "Table timezone field at index \(String(describing: index)) should exist")
        timezoneField.tap()
        
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(nextDay) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: {
            let lbl = $0.label
            return lbl.contains(", \(currentDay - 1) \(monthName)") &&
                   !lbl.contains(":") &&
                   !$0.identifier.hasPrefix("DatePicker.")
        }) {
            prevDayButton.tap()
        }
        
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let payload2 = onChangeResult().dictionary
        if let change = payload2["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
        
        
        selectRow(number: 5)
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.images.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        dismissSheet()
        let convertedTime2 = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField2 = app.buttons[convertedTime2 ?? ""].firstMatch
        XCTAssertEqual(dateField2.label, convertedTime2, "Datetime should be same after epoch convert")
        
        let payload3 = onChangeResult().dictionary
        if let change = payload3["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
           XCTAssertEqual(payloadTimezone, "Europe/London")
            
            if let rowId = change["rowId"] as? String {
                XCTAssertFalse(rowId.isEmpty, "Table row ID should not be empty")
            }
            
            if let cells = row["cells"] as? [String: Any] {
                XCTAssertGreaterThan(cells.count, 0, "Table row should have cells")
            }
        } else {
            XCTFail("Table onChange payload should contain row-based timezone structure")
        }
    }
    
    func testCollectionBlankDateTimeWithoutTimezone() {
        app.swipeUp()
        goToCollectionDetailPage()
         
        let dateFields = app.images.matching(identifier: "CalendarImageIdentifier")
        dateFields.element(boundBy: 2).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        let convertedTime = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        let dateField = app.buttons[convertedTime ?? ""].firstMatch
        XCTAssertEqual(dateField.label, convertedTime, "Datetime should be same after epoch convert")
        
        let payload = onChangeResult().dictionary
        XCTAssertNotNil(payload, "Table single edit first date field should trigger onChange event")
        
        if let change = payload["change"] as? [String: Any],
           let row = change["row"] as? [String: Any],
           let payloadTimezone = row["tz"] as? String {
            XCTAssertEqual(payloadTimezone, "Asia/Kolkata", "Table single edit first date field timezone should be Asia/Kolkata")
        } else {
            XCTFail("Table single edit first date field onChange payload should contain row-based timezone structure")
        }
    }
    
    func testCollectionBlankDateTimeWithDifferentTimezoneBulkEdit() {
        app.swipeUp()
        goToCollectionDetailPage()
        
        selectAllParentRows()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        let dateFields = app.images.matching(identifier: "EditRowsDateFieldIdentifier")
        dateFields.element(boundBy: 0).tap()
        dateFields.element(boundBy: 1).tap()
        let currentEpochMsEditForm = Int64(Date().timeIntervalSince1970 * 1000)
        app.buttons["ApplyAllButtonIdentifier"].tap()
        let convertedTime = formatEpoch(currentEpochMsEditForm, timeZoneTitle: "Asia/Kolkata", format: "MM/dd/yyyy hh:mma")?.normalizedSpaces
        
        let monthName: String = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "LLLL"   // Full month name
            return df.string(from: Date())
        }()
        
        let tableTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] '\(monthName)'"))
        
        // Test nil and invalid timezone fields in table
        for index in 0..<min(tableTimezoneFields.count, 10) { // Test first 2 fields for nil/invalid
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
            XCTAssertEqual(timezoneField.label, convertedTime)
        }
        
        let result = onChangeResult()

//        if let payloadArray = result.dictionary as? [[String: Any]] {
//            // Multiple payloads
//            for (index, payload3) in payloadArray.enumerated() {
//                if let change = payload3["change"] as? [String: Any],
//                   let row = change["row"] as? [String: Any],
//                   let payloadTimezone = row["tz"] as? String {
//
//                    XCTAssertNotNil(payloadTimezone)
//
//                    if let rowId = change["rowId"] as? String {
//                        XCTAssertFalse(rowId.isEmpty, "Row ID should not be empty (index \(index))")
//                    }
//
//                    if let cells = row["cells"] as? [String: Any] {
//                        XCTAssertGreaterThan(cells.count, 0, "Cells should not be empty (index \(index))")
//                    }
//                } else {
//                    XCTFail("Payload missing row-based timezone structure (index \(index))")
//                }
//            }
//        } else {
//            XCTFail("Table onChange payload should contain row-based timezone structure")
//        }
    }
    
    func dismissSheet() {
        let bottomCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let topCoordinate = app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        topCoordinate.press(forDuration: 0, thenDragTo: bottomCoordinate)
    }
    
    func goToTableDetailPage() {
        app.buttons["TableDetailViewIdentifier"].firstMatch.tap()
    }
    
    func goToCollectionDetailPage() {
        let goToTableDetailView = app.buttons.matching(identifier: "CollectionDetailViewIdentifier")
        let tapOnSecondTableView = goToTableDetailView.element(boundBy: 0)
        tapOnSecondTableView.tap()  
    }
    
    func selectAllParentRows() {
        let button = app.images.matching(identifier: "SelectParentAllRowSelectorButton").element
        if button.waitForExistence(timeout: 5) { // waits up to 5 seconds
            button.tap()
        } else {
            XCTFail("Select all parent rows button not found")
        }
    }
    
    func selectRow(number: Int) {
        //select the row with number as index
        let button = app.images.matching(identifier: "selectRowItem\(number)")
        XCTAssertTrue(button.element.waitForExistence(timeout: 5))
        button.element.firstMatch.tap()
            
    }
    
    func formatEpoch(
        _ epoch: Int64,
        timeZoneTitle: String?,
        format: String = "d MMM yyyy h:mm a"
    ) -> String? {
        // Detect ms vs s
        let seconds: TimeInterval = epoch > 10_000_000_000
            ? TimeInterval(epoch) / 1000.0
            : TimeInterval(epoch)
        let date = Date(timeIntervalSince1970: seconds)

        // Resolve timezone
        let tzString = (timeZoneTitle ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isNilLike = tzString.isEmpty || tzString.lowercased() == "nil"
        let tz = (!isNilLike ? TimeZone(identifier: tzString) : nil) ?? .current

        // Formatter
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX") // stable parsing/formatting
        df.timeZone = tz
        df.dateFormat = format

        return df.string(from: date)
    }
}

