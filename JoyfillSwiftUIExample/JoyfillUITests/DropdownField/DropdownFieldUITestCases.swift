//
//  DropdownFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 09/07/25.
//

import XCTest
import JoyfillModel

final class DropdownFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "DropdownFieldTestData"
    }
    
    func extractChangeValueAsString() -> String? {
        guard let result = onChangeOptionalResult(),
              let change = result.change as? [String: Any],
              let value = change["value"] as? String else {
            return nil
        }
        return value
    }
    
    func testDropdownFieldExists() {
        let dropdownField = app.buttons["Dropdown"]
        XCTAssertTrue(dropdownField.exists, "Dropdown field should exist on screen")
    }
    
    func testDropdownFieldTapOpensOptions() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        let option = app.staticTexts["Yes"]
        XCTAssertTrue(option.waitForExistence(timeout: 2), "Dropdown options should be visible after tapping")
    }
    
    func testDropdownOptionSelectionYes() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["Yes"].tap()
        XCTAssertEqual(dropdownField.label, "Yes", "Dropdown should display selected value 'Yes'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba0e870181427371e6", "Expected dropdown ID mismatch")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownOptionSelectionNo() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["No"].tap()
        XCTAssertEqual(dropdownField.label, "No", "Dropdown should display selected value 'No'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba71b3be77e6c1d2c7", "Backend should receive correct ID for 'No'")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownOptionSelectionNA() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["N/A"].tap()
        XCTAssertEqual(dropdownField.label, "N/A", "Dropdown should display selected value 'N/A'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba91350da2a4d4d614", "Backend should receive correct ID for 'N/A'")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownLogicHidesMultilineField() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["N/A"].tap()
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]
        sleep(1)
        XCTAssertFalse(multilineField.exists, "Multiline field should be hidden when dropdown is set to 'N/A'")
    }
    
    func testDropdownLogicDoesNotHideMultilineField() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["Yes"].tap()
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]
        sleep(1)
        XCTAssertTrue(multilineField.exists, "Multiline field should be visible when dropdown is not 'N/A'")
    }
    
    func testDropdownRetainsValueAfterNavigation() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["No"].tap()
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(dropdownField.label, "No", "Dropdown should retain selected value after screen navigation")
    }
    
    func testDropdownClearsSelection() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        app.staticTexts["Yes"].tap()
        dropdownField.tap()
        sleep(1)
        app.staticTexts["Yes"].firstMatch.tap()
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "", "Backend should reflect cleared value")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownFieldHasCorrectLabel() {
        let dropdownLabel = app.staticTexts["Dropdown"]
        XCTAssertTrue(dropdownLabel.exists, "Dropdown label should exist and match the field title")
    }
    
    func testDropdownOptionCountAndLabels() {
        let dropdownField = app.buttons["Dropdown"]
        dropdownField.tap()
        let options = ["Yes", "No", "N/A"]
        for option in options {
            XCTAssertTrue(app.staticTexts[option].exists, "\(option) option should be visible")
        }
    }
    
    func testDropdownBackendValueMatch() {
        let dropdownField = app.buttons["Dropdown"]
        let options: [(label: String, id: String)] = [
            ("Yes", "686de9ba0e870181427371e6"),
            ("No", "686de9ba71b3be77e6c1d2c7"),
            ("N/A", "686de9ba91350da2a4d4d614")
        ]
        for (label, id) in options {
            dropdownField.tap()
            app.staticTexts[label].tap()
            if let selectedId = extractChangeValueAsString() {
                XCTAssertEqual(selectedId, id, "Backend should receive correct ID for \(label)")
            } else {
                XCTFail("Value not found in change dictionary")
            }
        }
    }
}
