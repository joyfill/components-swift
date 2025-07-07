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
}
