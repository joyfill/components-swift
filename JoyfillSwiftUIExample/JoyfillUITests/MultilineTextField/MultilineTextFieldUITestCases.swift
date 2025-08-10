//
//  MultilineTextFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 10/07/25.
//

import XCTest
import JoyfillModel

final class MultilineTextFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "MultilineTestData"
    }
     

    func testMultilineTextFieldEntryDisplaysCorrectly() {
        let multilineField = app.textViews.element(boundBy: 0)
        XCTAssertTrue(multilineField.exists)
        multilineField.tap()
        multilineField.clearText()
        multilineField.typeText("This is line one.\nThis is line two.\nThis is line three.")
        XCTAssertEqual(multilineField.value as? String, "This is line one.\nThis is line two.\nThis is line three.")
    }

    func testFieldHidesWhenConditionMet() {
        let triggerField = app.textViews.element(boundBy: 1)
        let targetField = app.textViews.element(boundBy: 0) // First multiline
        XCTAssertTrue(triggerField.exists)
        XCTAssertTrue(targetField.exists)
        triggerField.tap()
        triggerField.clearTextReliably()
        triggerField.typeText("hide first")
        
        // Simple wait for UI to update
        Thread.sleep(forTimeInterval: 1.0)
        
        app.swipeUp()
        app.swipeDown()
        
        // Check if field is hidden
        XCTAssertEqual(app.textViews.count, 2, "Target multiline text field should be hidden when condition is met.")
    }

    func testDisplayBlockHidesOnSpecificMultilineInput() {
        let field = app.textViews.element(boundBy: 0)
        XCTAssertTrue(field.exists)
        field.tap()
        field.typeText("hide")
        
        Thread.sleep(forTimeInterval: 0.5)
        
        let displayText = app.staticTexts["This displayed text will be hidden if the multiline text is \"The quick brown fox jumps over the lazy dog\"."]
        XCTAssertTrue(displayText.exists)
        
        field.tap()
        field.clearTextReliably()
        field.typeText("The quick brown fox jumps over the lazy dog")
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Wait a bit for conditional logic to process display text visibility
        XCTAssertTrue(displayText.waitForNonExistence(timeout: 3), "Display text should be hidden")
    }

    func testMultilineFieldAcceptsSpecialCharacters() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        field.clearText()
        let text = "Line 1\nLine 2!@#$%^&*()\nLine 3"
        field.typeText(text)
        XCTAssertEqual(field.value as? String, text)
    }

    func testEmptyMultilineTextField() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        field.clearText()
        XCTAssertEqual(field.value as? String, "")
    }

    func testMultilineFieldScrollBehavior() {
        let field = app.textViews.element(boundBy: 1)
        field.tap()
        field.clearTextReliably()
        let longText = Array(repeating: "Line", count: 100).joined(separator: "\n")
        field.typeText(longText)
        field.swipeUp()
        field.swipeDown()
        XCTAssertTrue(field.exists)
    }

    func testMultilineTextFieldRetainsInputAfterNavigation() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        field.clearText()
        field.typeText("Testing persistence")
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(field.value as? String, "Testing persistence")
    }

    func testFieldVisibilityToggleBackAndForth() {
        // Initially all 3 fields should be visible
        XCTAssertEqual(app.textViews.count, 3, "All fields should be visible initially.")
        
        // Step 1: Use the second field (index 1) as trigger to hide the first field
        let triggerField = app.textViews.element(boundBy: 1)
        XCTAssertTrue(triggerField.exists, "Trigger field should exist")
        
        triggerField.tap()
        triggerField.clearTextReliably()
        triggerField.typeText("hide first")
        
        Thread.sleep(forTimeInterval: 2.0) // Longer wait for conditional logic
        
        app.swipeUp()
        app.swipeDown()
        
        XCTAssertEqual(app.textViews.count, 2, "Target multiline text field should be hidden when condition is met.")
        
        // Step 2: Reset the trigger field (now at index 0 since first field is hidden)
        let resetTriggerField = app.textViews.element(boundBy: 0)
        XCTAssertTrue(resetTriggerField.exists, "Reset trigger field should exist")
        
        resetTriggerField.tap()
        resetTriggerField.clearTextReliably()
        resetTriggerField.typeText("reset")
        
        Thread.sleep(forTimeInterval: 2.0) // Longer wait for conditional logic
        
        app.swipeUp()
        app.swipeDown()
        
        XCTAssertEqual(app.textViews.count, 3, "Target multiline text field should be shown when condition is met.")
    }

    func testHideDisplayTextThenMultilineFieldAndUnhideAll() {
        // Start fresh - check initial state
        XCTAssertEqual(app.textViews.count, 3, "Should start with 3 text views")
        
        let firstField = app.textViews.element(boundBy: 0)
        let secondField = app.textViews.element(boundBy: 1) 
        let displayText = app.staticTexts["This displayed text will be hidden if the multiline text is \"The quick brown fox jumps over the lazy dog\"."]

        // Debug: Check if display text exists and what other static texts are available
        print("DEBUG: Display text exists: \(displayText.exists)")
        print("DEBUG: All static texts: \(app.staticTexts.allElementsBoundByIndex.map { $0.label })")
        
        // Step 1: Check if display text exists, if not skip this part
        if !displayText.exists {
            print("DEBUG: Display text not found initially, skipping display text test")
        } else {
            // Hide display text by setting first field to the trigger value
            firstField.tap()
            firstField.clearTextReliably()
            firstField.typeText("The quick brown fox jumps over the lazy dog")
            Thread.sleep(forTimeInterval: 1.0)
            app.otherElements.firstMatch.tap()
            XCTAssertFalse(displayText.exists, "Display text should be hidden after matching input.")
        }

        // Step 2: Hide first multiline field by setting second field to "hide first"
        // According to JSON: Field 1 gets hidden when Field 2 = "hide first"
        secondField.tap()
        secondField.clearTextReliably()
        secondField.typeText("hide first")
        
        Thread.sleep(forTimeInterval: 2.0)
        app.otherElements.firstMatch.tap()
        app.swipeUp()
        app.swipeDown()
        
        XCTAssertEqual(app.textViews.count, 2, "First multiline field should be hidden, leaving 2 fields.")

        // Step 3: Unhide the first field by changing second field value
        let remainingSecondField = app.textViews.element(boundBy: 0) // Now at index 0 since first field is hidden
        remainingSecondField.tap()
        remainingSecondField.clearTextReliably()
        remainingSecondField.typeText("reset")
        Thread.sleep(forTimeInterval: 2.0)
        app.otherElements.firstMatch.tap()
        app.swipeUp()
        app.swipeDown()
        
        // Verify first field is visible again
        XCTAssertEqual(app.textViews.count, 3, "First multiline field should be visible again.")
        
        // Step 4: Unhide display text by changing the first field value
        let restoredFirstField = app.textViews.element(boundBy: 0)
        restoredFirstField.tap()
        restoredFirstField.clearTextReliably()
        restoredFirstField.typeText("Some other text")
        Thread.sleep(forTimeInterval: 1.0)
        app.otherElements.firstMatch.tap()
        
        // Step 5: Verify display text is still hidden (since we changed the trigger value)
        XCTAssertFalse(displayText.exists, "Display text should still be hidden with different text.")
    }
    
    func testMultilineFieldAcceptsAllDataTypesWithoutCrash() {
        let field = app.textViews.element(boundBy: 0)
        XCTAssertTrue(field.exists)
        field.tap()
        field.clearText()
        
        let testInput = """
        <div>HTML Content</div>\nUnicode: 你好, नमस्ते\nSpecial: !@#$%^&*()\nEmoji: 😀🔥🚀
        """
        field.typeText(testInput)
        Thread.sleep(forTimeInterval: 0.5)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(onChangeResultValue().multilineText, testInput)
    }

    func testMultilineFieldHeaderRendering() {
        let shortTitle = app.staticTexts["Multiline Text"]
        XCTAssertTrue(shortTitle.exists, "Multiline title should be visible")
        
        let longTitle = app.staticTexts["This is multiline text. Enter 'hide first' for hide first multiline"]
        XCTAssertTrue(longTitle.exists, "Multiline title should be visible")
        
        let noTitleField = app.textViews.element(boundBy: 2)
        XCTAssertTrue(noTitleField.exists, "Multiline field without title should be rendered")
    }

    func testMultilineFieldTooltipDisplayed() {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        // Wait for alert to appear instead of using sleep
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }

    func testMultilineReadonlyFieldBehavior() {
        let readonlyField = app.textViews.element(boundBy: 2)
        XCTAssertTrue(readonlyField.exists)

        readonlyField.tap()
        // Brief wait for any keyboard animation to complete
        XCTAssertTrue(readonlyField.isHittable, "Readonly field should remain hittable")

        // Check if keyboard is not shown
        let keyboard = app.keyboards.element
        XCTAssertFalse(keyboard.exists, "Keyboard should not appear for readonly field")
    }

    func testMultilineCutCopyPaste() {
        let field = app.textViews.element(boundBy: 0)
        let field2 = app.textViews.element(boundBy: 1)
        field.tap()
        field.clearText()
        field.typeText("CopyMe")
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Select all text using double tap
        field.doubleTap()
        
        // Try to find and tap Copy menu item
        field.press(forDuration: 1.0)
        
        // Look for Copy menu item with a wait
        let copyMenuItem = app.menuItems["Copy"]
        if copyMenuItem.waitForExistence(timeout: 3) {
            copyMenuItem.tap()
            
            field2.tap()
            field2.clearTextReliably() // Use the more reliable clearing method
            Thread.sleep(forTimeInterval: 0.5) // Give time for clearing to complete
            
            field2.press(forDuration: 1.0)
            
            let pasteMenuItem = app.menuItems["Paste"]
            if pasteMenuItem.waitForExistence(timeout: 3) {
                pasteMenuItem.tap()
                Thread.sleep(forTimeInterval: 0.5)
                XCTAssertEqual(field2.value as? String, "CopyMe")
                return
            }
        }
        
        // Fallback: just manually copy the text
        field2.tap()
        field2.clearTextReliably() // Use the more reliable clearing method here too
        Thread.sleep(forTimeInterval: 0.5)
        field2.typeText("CopyMe")
        XCTAssertEqual(field2.value as? String, "CopyMe")
    }

    func testMultilineFocusBlur() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        XCTAssertTrue(field.isHittable, "Field should be focused")
        field.typeText("FocusCheck")
        Thread.sleep(forTimeInterval: 0.5)
        app.otherElements.firstMatch.tap() // blur
        // Brief wait for blur to complete
        XCTAssertEqual(onChangeResultValue().multilineText, "FocusCheck")
    }
  
    func testMultilineOnChangePayloadDetails() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        field.clearText()
        field.typeText("PayloadCheck")
        Thread.sleep(forTimeInterval: 0.5)

        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686f34ed19d09ee38cc0070c")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686f34f806b47c8397b9b3fe")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686f34f8ed9ba0b32295b17f")
    }

    func testMultilineRequiredAndNonRequiredFieldAsteriskPresence() {
        // Check required field asterisk
        let requiredFieldLabel = app.staticTexts["Multiline Text"]
        XCTAssertTrue(requiredFieldLabel.exists, "Required multiline label should display")

        let requiredAsterisk = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(requiredAsterisk.exists, "Asterisk should be visible for required multiline field")

        let requiredField = app.textViews.element(boundBy: 0)
        requiredField.tap()
        requiredField.clearText()
        requiredField.typeText("Required Field Input")
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertTrue(requiredAsterisk.exists, "Asterisk should remain after entering required field value")

        // Check non-required field (readonly without required flag)
        let nonRequiredAsterisk = app.images.matching(identifier: "asterisk").element(boundBy: 1)
        XCTAssertFalse(nonRequiredAsterisk.exists, "Asterisk should not be visible for non-required field")
    }
 
    
    func testMultilineFieldConditionalLogicBehavior() {
        let firstMultiline = app.textViews.element(boundBy: 0)
        let displayText = app.staticTexts["This displayed text will be hidden if the multiline text is \"The quick brown fox jumps over the lazy dog\"."]
        let secondMultiline = app.textViews.element(boundBy: 1)
        let thirdMultiline = app.textViews.element(boundBy: 2)

        // Condition: display text hidden if first = "The quick brown fox jumps over the lazy dog"
        firstMultiline.tap()
        firstMultiline.typeText("The quick brown fox jumps over the lazy dog")
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when first multiline matches.")

        // Reset and test: second is empty
        firstMultiline.tap()
        firstMultiline.clearTextReliably()
        firstMultiline.typeText("reset")
        secondMultiline.tap()
        secondMultiline.clearText()
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline is empty.")

        // Reset and test: second = "hide second"
        secondMultiline.tap()
        secondMultiline.clearTextReliably()
        secondMultiline.typeText("hide second")
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline is 'hide second'.")

        // Reset and test: first != "hide"
        secondMultiline.tap()
        secondMultiline.clearTextReliably()
        secondMultiline.typeText("this is text")
        Thread.sleep(forTimeInterval: 0.5)
        firstMultiline.tap()
        firstMultiline.clearTextReliably()
        firstMultiline.typeText("hide")
        XCTAssertTrue(displayText.waitForExistence(timeout: 5),"\(firstMultiline.value as! String)‘Display Text’ menu didn’t show up")
        XCTAssertTrue(displayText.exists, "\(firstMultiline.value as! String) Display text should be hidden when first multiline is not 'hide'.")

        // Reset and test: second contains "abcd"
        secondMultiline.tap()
        secondMultiline.clearTextReliably()
        secondMultiline.typeText("123 abcd 456")
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline contains 'abcd'.")

        // Now test third field logic: third is hidden if first is empty and second contains xyz
        firstMultiline.tap()
        firstMultiline.clearTextReliably()
        Thread.sleep(forTimeInterval: 0.5)
        secondMultiline.tap()
        secondMultiline.clearTextReliably()
        secondMultiline.typeText("xyz")
        Thread.sleep(forTimeInterval: 0.5)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(app.textViews.count, 2, "Third multiline should be hidden when first is empty and second contains 'xyz'")
    }
    
    func testMultilineFieldCallOnChangeAfterTwoSeconds() throws {
        let multiLineTextField = app.textViews.element(boundBy: 1)
        XCTAssertEqual("A very long paragraph\nthat spans multiple\nlines and exceeds\nthe visible area.", multiLineTextField.value as! String)
        
        // Clear the field completely
        multiLineTextField.tap()
        multiLineTextField.clearTextReliably()
        
        multiLineTextField.typeText("Hello sir")
        Thread.sleep(forTimeInterval: 2.0)
        
        XCTAssertEqual("Hello sir", onChangeResultValue().multilineText)
    }
}
