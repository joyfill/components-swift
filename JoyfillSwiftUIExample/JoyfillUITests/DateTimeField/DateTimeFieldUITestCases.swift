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
        
        
        let firstDatePicker = app.datePickers.firstMatch
        firstDatePicker.tap()
        app.buttons["15 Jul 2025"].tap()
        app.buttons["Thursday 17 July"].tap()
        
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
     
    
    func testDatePicker() {
        app.buttons["15 Jul 2025"].tap()
        
        // Verify the date picker appears
        let datePicker = app.datePickers.firstMatch
        sleep(1)
        datePicker.tap()
        sleep(1)
        XCTAssertTrue(datePicker.exists, "Date picker for Date field should appear after tapping calendar image")
    }
   
}
