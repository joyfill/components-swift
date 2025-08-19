//
//  ChartFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 14/07/25.
//

import XCTest
import JoyfillModel

final class ChartFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "ChartFieldTestData"
    }

    func goToChartDetailField(index: Int = 0) {
        let chartViewButton = app.buttons.matching(identifier: "ChartViewIdentifier").element(boundBy: index)
        
        var attempts = 0
        while !chartViewButton.exists && attempts < 5 {
            app.swipeUp()
            sleep(1)
            attempts += 1
        }
        
        XCTAssertTrue(chartViewButton.waitForExistence(timeout: 5), "Chart view button not found")
        chartViewButton.tap()
    }
    
    func testPreselectedChartValueDisplays() {
        // Navigate to first chart
        goToChartDetailField(index: 0)
        // Verify preselected chart values shown
        XCTAssertTrue(app.textFields["Label 1"].exists)
        XCTAssertTrue(app.textFields["Label 2"].exists)
        XCTAssertTrue(app.textFields["Label 3"].exists)
    }

    func testInvalidDefaultValueDoesNotCrashUI() {
        // Navigate to second chart
        goToChartDetailField(index: 3)
        // Simulate invalid default value by tapping Show/Hide
        XCTAssertNoThrow(app.buttons["ShowHideButtonIdentifier"].tap())
        app.swipeUp()
        // Verify UI still shows points without crash
        XCTAssertTrue(app.textFields["[\"A\", \"B\", \"C\"]"].exists)
        XCTAssertTrue(app.textFields["{ \"foo\": \"bar\" }"].exists)
        XCTAssertTrue(app.textFields["<div>HTML Tag</div>"].exists)
        XCTAssertTrue(app.textFields["Emoji 🎉🚀"].exists)
    }

    func testChartFieldHeaderRendering() {
        // First chart header multiline title
        let firstChartTitle = app.staticTexts["This is first chart\nand testing multiline\nalong with tooltip."]
        XCTAssertTrue(firstChartTitle.exists)
        // Second chart header short title
        let secondChartTitle = app.staticTexts["Chart"]
        XCTAssertTrue(secondChartTitle.exists)
        // Third chart without title should have no header label
        let thirdChartTitle = app.staticTexts["This is readonly chart"]
        XCTAssertTrue(thirdChartTitle.exists)
        
        goToChartDetailField(index: 3)
        goBack()
    }

    func testReadonlyChartIsNotEditable() {
        // Third chart is readonly
        goToChartDetailField(index: 2)
        
        app.buttons["ShowHideButtonIdentifier"].firstMatch.tap()
        let textFields = app.textFields
        textFields.element(boundBy: 0).tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        
        textFields.element(boundBy: 1).tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        
        textFields.element(boundBy: 2).tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        
        textFields.element(boundBy: 3).tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
        // Attempt to tap edit controls
    }

//    func testChartFieldScrollRetention() {
//        // Change first chart titles and bounds
//        goToChartDetailField(index: 0)
//        app.buttons["ShowHideButtonIdentifier"].tap()
//        let verticalTF = app.textFields["VerticalTextFieldIdentifier"]
//        let horizontalTF = app.textFields["HorizontalTextFieldIdentifier"]
//        verticalTF.tap(); verticalTF.typeText(" UpdatedY")
//        horizontalTF.tap(); horizontalTF.typeText(" UpdatedX")
//        // Navigate away
//        goBack()
//        // Return and verify changes persist
//        goToChartDetailField(index: 0)
//        app.buttons["ShowHideButtonIdentifier"].tap()
//        XCTAssertEqual(verticalTF.value as? String, "Vertical UpdatedY")
//        XCTAssertEqual(horizontalTF.value as? String, "Horizontal UpdatedX")
//    }

    func testChartFieldOnFocusAndOnBlur() {
        goToChartDetailField(index: 0)
        app.buttons["ShowHideButtonIdentifier"].tap()
        let minYTF = app.textFields["MinY"]
        // Focus
        minYTF.tap()
        XCTAssertTrue(minYTF.isHittable)
        // Blur
        app.otherElements.firstMatch.tap()
        XCTAssertFalse(minYTF.hasFocus)
    }

    func testRequiredAsteriskPresenceChartField() {
        // Title has asterisk
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists)
        // Navigate to first chart
        goToChartDetailField(index: 0)
        // After edit input, asterisk remains
        app.buttons["ShowHideButtonIdentifier"].tap()
        let xTF = app.textFields["MinX"]
        xTF.tap(); xTF.clearText(); xTF.typeText("15")
        goBack()
        XCTAssertTrue(asteriskIcon.exists)
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
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

    func testFirstChartOnChangePayload() {
        goToChartDetailField(index: 0)
        app.buttons["ShowHideButtonIdentifier"].tap()
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("test")
        
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "6874cddd8d6de916f42bba2e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_6874cde17db802ff4f0eeb67")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "6874cde1456a8c72d3dc2529")
    }
 
}
