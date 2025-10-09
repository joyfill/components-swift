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
              let change = result.change,
              let value = change["value"] as? String else {
            return nil
        }
        return value
    }
    
    func testDropdownFieldExists() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        XCTAssertTrue(dropdownField.exists, "Dropdown field should exist on screen")
    }
    
    func testDropdownFieldTapOpensOptions() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        let option = app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes"))
        XCTAssertTrue(option.waitForExistence(timeout: 2), "Dropdown options should be visible after tapping")
    }
    
    func testDropdownOptionSelectionYes() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
        XCTAssertEqual(dropdownField.label, "Yes", "Dropdown should display selected value 'Yes'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba0e870181427371e6", "Expected dropdown ID mismatch")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownOptionSelectionNo() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "No")).tap()
        XCTAssertEqual(dropdownField.label, "No", "Dropdown should display selected value 'No'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba71b3be77e6c1d2c7", "Backend should receive correct ID for 'No'")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownOptionSelectionNA() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "N/A")).tap()
        XCTAssertEqual(dropdownField.label, "N/A", "Dropdown should display selected value 'N/A'")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba91350da2a4d4d614", "Backend should receive correct ID for 'N/A'")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    
    func testDropdownLogicHidesMultilineField() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "N/A")).tap()
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(multilineField.exists, "Multiline field should be hidden when dropdown is set to 'N/A'")
    }
    
    func testDropdownLogicDoesNotHideMultilineField() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertTrue(multilineField.exists, "Multiline field should be visible when dropdown is not 'N/A'")
    }
    
    func testDropdownRetainsValueAfterNavigation() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "No")).tap()
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(dropdownField.label, "No", "Dropdown should retain selected value after screen navigation")
    }
    
    func testDropdownClearsSelection() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
        dropdownField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
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
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        let options = ["Yes", "No", "N/A","Hindi: नमस्ते दुनिया | Chinese: 你好，世界 | Arabic: مرحبا بالعالم 🌍","This is a very long option label used for testing overflow or wrapping behavior in dropdown fields\"\n3. Special Characters: \"!@#$%^&*()_+-=[]{}|;':\\\",.<>/?`~","✅ Done 🎉 Success 🚀 Launch 🌟 Favorite","\"default\": { \"label\": \"Option1\", \"value\": \"1\" }"]
        for option in options {
            let optionElement = app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", option))
            XCTAssertTrue(optionElement.exists, "\(option) option should be visible")
        }
    }
    
    func testDropdownBackendValueMatch() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        let options: [(label: String, id: String)] = [
            ("Yes", "686de9ba0e870181427371e6"),
            ("No", "686de9ba71b3be77e6c1d2c7"),
            ("N/A", "686de9ba91350da2a4d4d614")
        ]
        for (label, id) in options {
            dropdownField.tap()
            app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", label)).tap()
            if let selectedId = extractChangeValueAsString() {
                XCTAssertEqual(selectedId, id, "Backend should receive correct ID for \(label)")
            } else {
                XCTFail("Value not found in change dictionary")
            }
        }
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Dropdown"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    func testRequiredFieldAsteriskPresence() {
        let requiredLabel = app.staticTexts["Dropdown"]
        XCTAssertTrue(requiredLabel.exists, "Required field label should display")

        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")

        // Enter value and ensure asterisk still remains
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "No")).tap()
        XCTAssertEqual(dropdownField.label, "No", "Dropdown should retain selected value after screen navigation")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    func testDropdownFieldHeaderRendering() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        XCTAssertTrue(dropdownField.exists)

        let titleWithMultiline = app.staticTexts["This dropdown is readonly with\n'readonly' default value"]
        XCTAssertTrue(titleWithMultiline.exists)

        let smallTitle = app.staticTexts["Dropdown"]
        XCTAssertTrue(smallTitle.exists)

        let noTitleField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 1)
        XCTAssertTrue(noTitleField.exists)
    }

    func testReadonlyDropdownFieldDoesNotTriggerKeyboardOrOpenOptions() {
        let readonlyDropdown = app.buttons.matching(identifier: "Dropdown").element(boundBy: 1)
        XCTAssertTrue(readonlyDropdown.exists, "Readonly dropdown should exist on screen")
        
        readonlyDropdown.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        // Check that dropdown options are not visible
        let option = app.buttons.matching(identifier: "DropdownoptionIdentifier").element(boundBy: 0)
        XCTAssertFalse(option.exists, "Dropdown options should not be visible for readonly dropdown")
        
        // Also ensure keyboard did not appear
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly dropdown")
    }
    
    
    func testDropdownPayloadIncludesAllExpectedFields() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        dropdownField.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        guard let payload = onChangeOptionalResult()?.dictionary else {
            XCTFail("onChange payload missing")
            return
        }

        XCTAssertEqual(payload["fieldId"] as? String, "686dfcbda4eede35bd882f73", "fieldId should match expected value")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e", "pageId should match expected value")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686e0d9cf0fb90914e468030", "fieldIdentifier should match expected")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686e0d9c0eb92f572f47e3a5", "fieldPositionId should match expected")
        XCTAssertEqual(payload["fileId"] as? String, "66a14ced9dc829a95e272506")
        XCTAssertEqual(payload["target"] as? String, "field.update")
        XCTAssertEqual(payload["identifier"] as? String, "template_6849dbb509ede5510725c910")
        XCTAssertEqual(payload["_id"] as? String, "66a14cedd6e1ebcdf176a8da")
        XCTAssertEqual(payload["sdk"] as? String, "swift")
        if let selectedId = extractChangeValueAsString() {
            XCTAssertEqual(selectedId, "686de9ba0e870181427371e6", "Expected dropdown ID mismatch")
        } else {
            XCTFail("Value not found in change dictionary")
        }
    }
    func testDropdownOnFocusAndOnBlur() {
        let dropdownField = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        XCTAssertTrue(dropdownField.exists, "Dropdown field should exist")

        // Tap to trigger focus
        dropdownField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        // Check that dropdown is focused (options are shown)
        let option = app.buttons.matching(identifier: "DropdownoptionIdentifier").element(boundBy: 0)
        XCTAssertTrue(option.exists, "Dropdown options should be visible (onFocus)")

        // Tap outside to blur (simulate blur)
        swipeSheetDown()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        // Verify dropdown options are no longer visible (onBlur)
        XCTAssertFalse(option.exists, "Dropdown options should be hidden after blur (onBlur)")
    }
    
    func testMultilineFieldConditionalHideLogic() {
        let dropdown1 = app.buttons.matching(identifier: "Dropdown").element(boundBy: 0)
        let dropdown2 = app.buttons.matching(identifier: "Dropdown").element(boundBy: 2)
        let dropdown3 = app.buttons.matching(identifier: "Dropdown").element(boundBy: 1)
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]

        // Case 1: Dropdown 1 = N/A (686de9ba91350da2a4d4d614)
        dropdown1.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "N/A")).tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(multilineField.exists, "Multiline should be hidden when dropdown1 = N/A")

        // Reset to visible state
        dropdown1.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "Yes")).tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertTrue(multilineField.exists, "Multiline should be visible when dropdown1 = Yes")

        // Case 2: Dropdown 2 is null (simulate by deselecting or clearing dropdown2 if UI allows it)
        // NOTE: Actual clearing/deselecting logic depends on app UI. If not possible, skip or document.

        // Case 3: Dropdown 3 = "No" (686de9ba71b3be77e6c1d2c7)
        dropdown2.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "No")).tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(multilineField.exists, "Multiline should be hidden when dropdown3 = No")

        // Case 4: Dropdown 3 = null (simulate if applicable)
    }
    
    func testReadonlyDropdownHiddenOnMultilineTestAndDropdown3IsTwo() {
        let dropdown3 = app.buttons.matching(identifier: "Dropdown").element(boundBy: 2)
        let readonlyDropdown = app.buttons.matching(identifier: "Dropdown").element(boundBy: 3)

        dropdown3.tap()
        app.buttons.matching(identifier: "DropdownoptionIdentifier").element(matching: NSPredicate(format: "label == %@", "two")).tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertFalse(readonlyDropdown.exists, "Readonly dropdown should be hidden when Multiline = 'test' and Dropdown 3 = two")
    }
}
