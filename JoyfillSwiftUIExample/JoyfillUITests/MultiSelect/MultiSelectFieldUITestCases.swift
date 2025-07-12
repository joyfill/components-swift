//
//  MultiSelectFieldUITestCases.swift
//  JoyfillUITests
//
//  Created by Vivek on 07/07/25.
//

import XCTest
import JoyfillModel

final class MultiSelectFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "MultiSelectFieldTestData"
    }
        
    func testMultiSelectField() throws {
        
        let optionCount = getOptionsButtonsCount(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual(5, optionCount)
     
        // tap on first button with identifier MultiSelectionIdenitfier
        let firstOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier").firstMatch
        firstOption.tap()
        verifyMultiSelectValue(expectedOptionIds: ["686b854528a03e7759da506c", "686b85454ac2c55af987d4bb"])
        
    }
    
    func testSingleSelectField() throws {
        
        let optionCount = getOptionsButtonsCount(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual(6, optionCount)
     
        // tap on first button with identifier MultiSelectionIdenitfier
        let firstOption = app.buttons.matching(identifier: "SingleSelectionIdentifier").firstMatch
        firstOption.tap()
        verifyMultiSelectValue(expectedOptionIds: ["686b85454ac2c55af987d4bb"])
        
    }
    
    
    func getOptionsButtonsCount(identifier: String) -> Int {
        let multiSelect = app.buttons.matching(identifier: identifier)
        return multiSelect.count
    }

    internal override func goBack() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    private func verifyMultiSelectValue(expectedOptionIds: [String]) {
        let result = onChangeResultValue()
        XCTAssertNotNil(result.multiSelector, "Multi-select value should not be nil")
        XCTAssertEqual(result.multiSelector?.count, expectedOptionIds.count, "Should have \(expectedOptionIds.count) selected options")
        
        for optionId in expectedOptionIds {
            XCTAssertTrue(result.multiSelector?.contains(optionId) == true, "Should contain option ID: \(optionId)")
        }
    }
    
    //ConditionalLogic tests
    
    func testConditonalLogicWithMultiSelect() throws {
        let optionCount = getOptionsButtonsCount(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual(5, optionCount)
        
        let label = "Hello"
        let buttons = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        let target = buttons.allElementsBoundByIndex.first { $0.label == label }

        XCTAssertNotNil(target, "Button with label '\(label)' and identifier should exist")
        target?.tap()
        
        //Hello tapped , then the Checkbox field should hide
        let finalOptionCount = getOptionsButtonsCount(identifier: "MultiSelectionIdenitfier")
        XCTAssertEqual(5, finalOptionCount)
        
        let finalSingleOptionCount = getOptionsButtonsCount(identifier: "SingleSelectionIdentifier")
        XCTAssertEqual(3, finalSingleOptionCount)
    }
    
    // MARK: — Required Asterisk Persists
    func testRequiredMultiselectAsteriskPersistsAfterSelection() {
        // required field is the first multi-select
        let requiredLabel = app.staticTexts["Multiple Choice"]
        XCTAssertTrue(requiredLabel.exists)
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk should be visible before selection")

        // make a selection
        let firstOption = app.buttons.matching(identifier: "MultiSelectionIdenitfier").element(boundBy: 0)
        firstOption.tap()
        sleep(1)

        // asterisk should still be there
        XCTAssertTrue(asteriskIcon.exists, "Asterisk should remain after making a selection")
    }

    // MARK: — Retain Value After Scroll
    func testMultiselectRetainsValueAfterScroll() {
        let multi = app.buttons.matching(identifier: "MultiSelectionIdenitfier")
        multi.element(boundBy: 2).tap()

        // scroll up/down
        app.swipeUp()
        app.swipeDown()
        sleep(1)

        // verify label(s) still selected in payload
        let result = onChangeResultValue()
        XCTAssertEqual(Set(result.multiSelector ?? []),
                       Set(["686b854528a03e7759da506c", "686b854514dfef2c5bb24eed"]),
                       "Selections should persist after scrolling")
    }
 

    // MARK: — Header Rendering
    func testMultiselectFieldHeaderRendering() {
        // small header (second field)
        let small = app.staticTexts["Multiple Choice"]
        XCTAssertTrue(small.exists)

        // multiline header (third field)
        let multiline = app.staticTexts["This Multiple Choice is for\ntesting multiline header text."]
        XCTAssertTrue(multiline.exists)

        app.swipeUp()
        // no-header field (fourth multi-select)
        let noHeader = app.buttons.matching(identifier: "MultiSelectionIdenitfier").element(boundBy: 2)
        // we expect no static text for its header
        XCTAssertTrue(noHeader.exists)
    }

    // MARK: — Tooltip Display
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
}
