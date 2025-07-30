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
        triggerField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        triggerField.typeText("hide first")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        // Explicitly check that only one text view remains (the trigger field)
        XCTAssertEqual(app.textViews.count, 2, "Target multiline text field should be hidden when condition is met.")
    }

    func testDisplayBlockHidesOnSpecificMultilineInput() {
        let field = app.textViews.element(boundBy: 0)
        XCTAssertTrue(field.exists)
        field.tap()
        field.typeText("hide")
        sleep(1)
        let displayText = app.staticTexts["This displayed text will be hidden if the multiline text is \"The quick brown fox jumps over the lazy dog\"."]
        
        XCTAssertTrue(displayText.exists)
        field.tap()
        field.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        field.typeText("The quick brown fox jumps over the lazy dog")
        sleep(1)
        XCTAssertFalse(displayText.exists)
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
        field.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
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
        let triggerField = app.textViews.element(boundBy: 1)
        let targetField = app.textViews.element(boundBy: 0)
        triggerField.tap()
        sleep(1)
        triggerField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        sleep(1)
        triggerField.typeText("hide first")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(app.textViews.count, 2, "Target multiline text field should be hidden when condition is met.")
        targetField.tap()
        targetField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        targetField.typeText("reset")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(app.textViews.count, 3, "Target multiline text field should be shown when condition is met.")
    }
    func testHideDisplayTextThenMultilineFieldAndUnhideAll() {
        let multilineField = app.textViews.element(boundBy: 0)
        multilineField.tap()
        multilineField.typeText("hide")
        sleep(1)
        let triggerField = app.textViews.element(boundBy: 1)
        let displayText = app.staticTexts["This displayed text will be hidden if the multiline text is \"The quick brown fox jumps over the lazy dog\"."]

        // Step 1: Hide display text
        XCTAssertTrue(displayText.exists)
        multilineField.tap()
        multilineField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multilineField.typeText("The quick brown fox jumps over the lazy dog")
        sleep(1)
        XCTAssertFalse(displayText.exists, "Display text should be hidden after matching input.")

        // Step 2: Hide first multiline field
        XCTAssertTrue(triggerField.exists)
        triggerField.tap()
        triggerField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        triggerField.typeText("hide first")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(app.textViews.count, 2, "Multiline field should be hidden, only trigger should remain.")

        // Step 3: Unhide all by resetting trigger field
        multilineField.tap()
        multilineField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multilineField.typeText("reset")
        sleep(1)

        // Step 4: Unhide display text
        multilineField.tap()
        multilineField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multilineField.typeText("Some other text")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        // Step 5: Verify all visible again
        XCTAssertEqual(app.textViews.count, 3, "Both multiline fields should be visible again.")
        XCTAssertFalse(displayText.exists, "Display text should be hide again.")
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
        sleep(1)
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
        sleep(1)
        
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
        sleep(1)

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
        field.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        sleep(2)
        app.menuItems["Copy"].tap()
        let copyText = app.menuItems["Copy"]
        XCTAssertTrue(copyText.waitForExistence(timeout: 5),"‘Copy’ menu didn’t show up")
        copyText.tap()
        
        field2.tap()
        field2.clearText()
        field2.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        field2.clearText()
        field2.press(forDuration: 1.0)
        sleep(1)
        app.menuItems["Paste"].tap()
        sleep(1)
        XCTAssertEqual(field2.value as? String, "CopyMe")
    }

    func testMultilineFocusBlur() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        sleep(1)
        XCTAssertTrue(field.isHittable, "Field should be focused")
        field.typeText("FocusCheck")
        sleep(1)
        app.otherElements.firstMatch.tap() // blur
        sleep(1)
        XCTAssertEqual(onChangeResultValue().multilineText, "FocusCheck")
    }
  
    func testMultilineOnChangePayloadDetails() {
        let field = app.textViews.element(boundBy: 0)
        field.tap()
        field.clearText()
        field.typeText("PayloadCheck")
        sleep(1)

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
        sleep(1)

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
        sleep(1)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when first multiline matches.")

        // Reset and test: second is empty
        firstMultiline.tap()
        firstMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstMultiline.typeText("reset")
        secondMultiline.tap()
        secondMultiline.clearText()
        sleep(1)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline is empty.")

        // Reset and test: second = "hide second"
        secondMultiline.tap()
        secondMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        secondMultiline.typeText("hide second")
        sleep(1)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline is 'hide second'.")

        // Reset and test: first != "hide"
        secondMultiline.tap()
        secondMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        secondMultiline.typeText("this is text")
        sleep(1)
        firstMultiline.tap()
        firstMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstMultiline.typeText("hide")
        sleep(2)
        XCTAssertTrue(displayText.exists, "Display text should be hidden when first multiline is not 'hide'.")

        // Reset and test: second contains "abcd"
        secondMultiline.tap()
        secondMultiline.press(forDuration: 1.0)
        let selectAll = app.menuItems["Select All"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5),"‘Select All’ menu didn’t show up")
        selectAll.tap()
        secondMultiline.typeText("123 abcd 456")
        sleep(1)
        XCTAssertFalse(displayText.exists, "Display text should be hidden when second multiline contains 'abcd'.")

        // Now test third field logic: third is hidden if first is empty and second contains xyz
        firstMultiline.tap()
        firstMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstMultiline.clearText()
        sleep(1)
        secondMultiline.tap()
        secondMultiline.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        secondMultiline.typeText("xyz")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(app.textViews.count, 2, "Third multiline should be hidden when first is empty and second contains 'xyz'")
    }
    
    func testMultilineFieldCallOnChangeAfterTwoSeconds() throws {
        let multiLineTextField = app.textViews.element(boundBy: 1)
        XCTAssertEqual("A very long paragraph\nthat spans multiple\nlines and exceeds\nthe visible area.", multiLineTextField.value as! String)
        multiLineTextField.tap()
        multiLineTextField.press(forDuration: 1.0)
        let selectAll = app.menuItems["Select All"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5),"‘Select All’ menu didn’t show up")
        selectAll.tap()
        multiLineTextField.typeText("Hello sir")
        sleep(2)
        XCTAssertEqual("Hello sir", onChangeResultValue().multilineText)
    }
}
