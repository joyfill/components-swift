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
        var firstIndex = 7
        var secondIndex = 8
        var thirdIndex = 10
        var fourthIndex = 11
        if UIDevice.current.userInterfaceIdiom == .pad  {
            firstIndex = 8
            secondIndex = 9
            thirdIndex = 11
            fourthIndex = 12
        }
        testChangeDateForTimezone(index: firstIndex, timezone: "Asia/Kolkata")
        testChangeDateForTimezone(index: secondIndex, timezone: "America/New_York")
        testChangeDateForTimezone(index: thirdIndex, timezone: "nil")
        testChangeDateForTimezone(index: fourthIndex, timezone: "123kjh")
    }
    
    private func testChangeDateForTimezone(index: Int, timezone: String) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Date button at index \(index) should exist")
         
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
        
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        // Verify button is still accessible after interaction
        XCTAssertTrue(dateButton.exists, "Date button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Date button should be hittable after interaction")
        
        // Test onChange event and verify timezone
        verifyTimezoneInOnChangePayload(expectedTimezone: timezone, fieldDescription: timezone)
    }
    
    func testConvertEpochWithTimeZone() {
        var firstIndex = 14
        var secondIndex = 15
        if UIDevice.current.userInterfaceIdiom == .pad  {
            firstIndex = 15
            secondIndex = 16
        }
        // Get initial label from button
        let firstLabel = getDateFieldButtonLabel(firstIndex)
        let secondLabel = getDateFieldButtonLabel(secondIndex)
        let fullLabel = (firstLabel + " " + secondLabel).normalizedSpaces
        let convertedTime = formatEpoch(1752530400000, timeZoneTitle: "America/New_York")?.normalizedSpaces
        
        XCTAssertEqual(fullLabel, convertedTime, "Datetime should be same after epoch convert")
    }
    
    func testNilAndInvalidTimezone() {
        var firstIndex = 10
        var secondIndex = 11
        if UIDevice.current.userInterfaceIdiom == .pad  {
            firstIndex = 11
            secondIndex = 12
        }
        testNilTimezone(index: firstIndex)
        testInvalidTimezone(index: secondIndex)
    }
    
    private func testNilTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Nil timezone button at index \(index) should exist")
         
        // Test button interaction
        dateButton.tap()
        
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-07-10")
        let dateField = app.buttons[firstDateLabel].firstMatch
        dateField.tap()
        app.buttons["PopoverDismissRegion"].tap()
        
        dismissSheet()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        XCTAssertTrue(dateButton.exists, "Nil timezone button should exist after interaction")
        XCTAssertTrue(dateButton.isHittable, "Nil timezone button should be hittable after interaction")
        
        verifyTimezoneInOnChangePayload(expectedTimezone: "Asia/Kolkata", fieldDescription: "nil")
    }
    
    private func testInvalidTimezone(index: Int) {
        let dateButton = getDateFieldButtonByIndex(index)
        XCTAssertTrue(dateButton.exists, "Invalid timezone button at index \(index) should exist")
         
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
    
    /* Table timezone UI test cases */
    
    func testTableTimezoneFields() throws {
        goToTableDetailPage()
        
        // Test Case 1: Check all table timezone fields
        testTableCheckAllTimezoneFields()
        
        // Test Case 2: Change date time and check timezone
        testTableChangeDateTimeAndCheckTimezone()
        
        // Test Case 3: Nil and invalid timezone behavior
        testTableNilAndInvalidTimezone()
    }
    
    private func testTableCheckAllTimezoneFields() {
        let tableTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
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
        let columnButtons = app.buttons.matching(identifier: "ColumnButtonIdentifier")
        XCTAssertGreaterThan(columnButtons.count, 0, "Table should have column buttons")
        
        for index in 0..<columnButtons.count {
            let columnButton = columnButtons.element(boundBy: index)
            XCTAssertTrue(columnButton.exists, "Table column button at index \(index) should exist")
            
            let columnLabel = columnButton.label
            XCTAssertFalse(columnLabel.isEmpty, "Table column button at index \(index) should have a label")
        }
    }
    
    private func testTableChangeDateTimeAndCheckTimezone() {
        // Use the correct button selector for table date fields
        let tableTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
        
        // Test changing date/time for each table timezone field
        for index in 0..<min(tableTimezoneFields.count, 6) { // Test first 3 fields
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
             
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-15")
            let dateField = app.buttons[firstDateLabel].firstMatch
            if dateField.exists {
                dateField.tap()
            }
            
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
    
    private func testTableNilAndInvalidTimezone() {
        // Use the correct button selector for table date fields
        let tableTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
        
        // Test nil and invalid timezone fields in table
        for index in 2..<min(tableTimezoneFields.count, 6) { // Test first 2 fields for nil/invalid
            let timezoneField = tableTimezoneFields.element(boundBy: index)
            XCTAssertTrue(timezoneField.exists, "Table timezone field at index \(index) should exist")
             
            // Tap to open date picker
            timezoneField.tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            
            // Interact with date picker
            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-12")
            let dateField = app.buttons[firstDateLabel].firstMatch
            if dateField.exists {
                dateField.tap()
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
    
    func testTableSingleEdit() throws {
        goToTableDetailPage()
        
        app.scrollViews.otherElements.containing(.image, identifier:"MyButton").children(matching: .image).matching(identifier: "MyButton").element(boundBy: 0).tap()
        app.buttons["TableMoreButtonIdentifier"].tap()
        app.buttons["TableEditRowsIdentifier"].tap()
        Thread.sleep(forTimeInterval: 0.5)
          
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 0).tap()
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-05")
        let dateField = app.buttons[firstDateLabel].firstMatch
        if dateField.exists {
            dateField.tap()
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
        let secondDateLabel = formattedAccessibilityLabel(for: "2025-09-07")
        let dateField2 = app.buttons[secondDateLabel].firstMatch
        if dateField2.exists {
            dateField2.tap()
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
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(nextDay)") && $0.isHittable }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(currentDay - 1)") && $0.isHittable }) {
            prevDayButton.tap()
        } else {
            // Fallback: tap any hittable date button
            app.buttons.allElementsBoundByIndex.first { $0.isHittable && $0.label.contains("August") }?.tap()
        }
        dismissSheet()
        app.images.element(boundBy: secondIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        // Try to tap any available date in current month
        let currentDay2 = Calendar.current.component(.day, from: Date())
        let nextDay2 = currentDay2 + 1
        
        if let nextDayButton2 = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(nextDay2)") && $0.isHittable }) {
            nextDayButton2.tap()
        } else if let prevDayButton2 = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(currentDay2 - 1)") && $0.isHittable }) {
            prevDayButton2.tap()
        } else {
            // Fallback: tap any hittable date button
            app.buttons.allElementsBoundByIndex.first { $0.isHittable && $0.label.contains("August") }?.tap()
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
        let collectionTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
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
        let collectionTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
        
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
            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-15")
            let dateField = app.buttons[firstDateLabel].firstMatch
            if dateField.exists {
                dateField.tap()
            }
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
        let collectionTimezoneFields = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'September'"))
        
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
            let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-12")
            let dateField = app.buttons[firstDateLabel].firstMatch
            if dateField.exists {
                dateField.tap()
            }
            
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
        let firstDateLabel = formattedAccessibilityLabel(for: "2025-09-05")
        let dateField = app.buttons[firstDateLabel].firstMatch
        if dateField.exists {
            dateField.tap()
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
        let secondDateLabel = formattedAccessibilityLabel(for: "2025-09-07")
        let dateField2 = app.buttons[secondDateLabel].firstMatch
        if dateField2.exists {
            dateField2.tap()
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
        let currentDay = Calendar.current.component(.day, from: Date())
        let nextDay = currentDay + 1
        
        if let nextDayButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(nextDay)") && $0.isHittable }) {
            nextDayButton.tap()
        } else if let prevDayButton = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(currentDay - 1)") && $0.isHittable }) {
            prevDayButton.tap()
        } else {
            // Fallback: tap any hittable date button
            app.buttons.allElementsBoundByIndex.first { $0.isHittable && $0.label.contains("August") }?.tap()
        }
        dismissSheet()
        
        app.images.element(boundBy: secondIndex).firstMatch.tap()
        app.buttons.matching(identifier: "EditRowsDateFieldIdentifier").element(boundBy: 1).tap()
        // Try to tap any available date in current month
        let currentDay2 = Calendar.current.component(.day, from: Date())
        let nextDay2 = currentDay2 + 1
        
        if let nextDayButton2 = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(nextDay2)") && $0.isHittable }) {
            nextDayButton2.tap()
        } else if let prevDayButton2 = app.buttons.allElementsBoundByIndex.first(where: { $0.label.contains("\(currentDay2 - 1)") && $0.isHittable }) {
            prevDayButton2.tap()
        } else {
            // Fallback: tap any hittable date button
            app.buttons.allElementsBoundByIndex.first { $0.isHittable && $0.label.contains("August") }?.tap()
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

extension String {
    /// Replaces narrow/regular no-break spaces with a normal space and collapses multiples.
    var normalizedSpaces: String {
        self
            .replacingOccurrences(of: "\u{202F}", with: " ") // narrow no-break space
            .replacingOccurrences(of: "\u{00A0}", with: " ") // no-break space
            .replacingOccurrences(of: #" {2,}"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
