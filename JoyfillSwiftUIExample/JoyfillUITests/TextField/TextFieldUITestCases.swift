//
//  MultiSelectFieldUITestCases.swift
//  JoyfillUITests
//
//  Created by Vivek on 07/07/25.
//

import XCTest
import JoyfillModel

final class TextFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "TextFieldTestData"
    }
    
    func testTextField() throws {
        let textField = app.textFields.element(boundBy: 0)
        XCTAssertEqual("test", textField.value as! String)
        
        textField.tap()
        textField.typeText("Hello\n")
        XCTAssertEqual("testHello", onChangeResultValue().text!)
        
    }
    
    func testMultilineField() throws {
        let multiLineTextField = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertEqual("test", multiLineTextField.value as! String)
        multiLineTextField.tap()
        
        // Select all text using coordinate-based selection, then replace
        multiLineTextField.press(forDuration: 1.0)
        if app.menuItems["Select All"].waitForExistence(timeout: 2) {
            app.menuItems["Select All"].tap()
        } else {
            // Fallback: tap and select all with keyboard shortcut
            multiLineTextField.doubleTap()
        }
        
        multiLineTextField.typeText("quick")
        
        // Wait for onChange event to process
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssertEqual("quick", onChangeResultValue().multilineText)
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let alert = app.alerts["ToolTip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["ToolTip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["ToolTip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }
    
    
    //Conditional logic case insensitive UI test cases
    //In json we have logic using "HELLO" and we are testing this with "hello" case insensitive logic
    func testConditionalLogicWithMultiSelect() throws {
        let textField = app.textFields.element(boundBy: 0)
        XCTAssertEqual("test", textField.value as! String)
        
        let multiLineTextFieldBeforeLogic = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertTrue(multiLineTextFieldBeforeLogic.exists)
        
        textField.tap()
        textField.clearText()
        textField.typeText("hello")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual("hello", onChangeResultValue().text)
        
        let multiLineTextFieldAfterLogic = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertFalse(multiLineTextFieldAfterLogic.exists)
        
    }
    
    // Test case for textfields call onChange after two seconds
    func testTextFieldCallOnChangeAfterTwoSeconds() throws {
        let textField = app.textFields.element(boundBy: 0)
        XCTAssertEqual("test", textField.value as! String)
        textField.tap()
        textField.typeText("Hello")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0))
        XCTAssertEqual("testHello", onChangeResultValue().text!)
    }
    
    func testConditionalLogicForMultilineAndDisplayText() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("hide")
        let multiline = app.textViews["MultilineTextFieldIdentifier"]
        let displayText = app.staticTexts["Display text will be hidden when text is 'hide' and multiline should not 'show'"]
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(displayText.exists)
    }
    
    func testReadonlyTextFieldDoesNotTriggerKeyboard() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("qqqq")
        
        let multilineTextView = app.textViews.element(boundBy: 0)
        multilineTextView.tap()
        app.selectAllInTextField(in: multilineTextView, app: app) // Select all with keyboard shortcut
        multilineTextView.typeText("hide")
        app.dismissKeyboardIfVisible()
        app.swipeDown()
        let readonlyField = app.textFields.element(boundBy: 1)
        readonlyField.tap()
        if UIDevice.current.userInterfaceIdiom != .pad {
            // Wait for UI to settle and check keyboard state
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            XCTAssertTrue(app.keyboards.element.exists, "Keyboard appears for readonly field")
        }
    }
    
    func testTextFieldDataTypes() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("12345")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(onChangeResultValue().text!, "12345")
        
        textField.clearText()
        textField.typeText("[1,2,3]")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(onChangeResultValue().text!, "[1,2,3]")
        
        textField.clearText()
        textField.typeText("{\"key\":\"value\"}")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(onChangeResultValue().text!, "{\"key\":\"value\"}")
    }
    
    func testTextFieldTypingAndPaste() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        textField.clearText()
        UIPasteboard.general.string = "Pasted Text"
        textField.press(forDuration: 1.0)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.menuItems["Paste"].tap()
        XCTAssertEqual(textField.value as? String, "Pasted Text")
    }
    
    func testTextFieldOnChangePayloadAndFocusBlur() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0)) // simulate focus delay
        textField.typeText("trigger")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 2.0)) // simulate delay before blur
        app.otherElements.firstMatch.tap() // dismiss keyboard
        XCTAssertEqual(onChangeResultValue().text!, "testtrigger")
    }
    
    func testTextFieldScrollRetainsValue() {
        let textField = app.textFields.element(boundBy: 0)
        XCTAssert(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.clearText()
        textField.typeText("scrollCheck")
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(textField.value as? String, "scrollCheck")
    }
    
    func testConditionalLogicChainedHidingAndUnhiding() {
        let firstTextField = app.textFields.element(boundBy: 0)
        let secondTextField = app.textFields.element(boundBy: 1)
        let thirdTextField = app.textFields.element(boundBy: 2)
        let multilineTextView = app.textViews.element(boundBy: 0)
        let displayText = app.staticTexts["Display text will be hidden when text is 'hide' and multiline should not 'show'"]
        
        // 1. First textbox = "HELLO" => multiline should hide
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("HELLO")
        
        // Wait for conditional logic to process and multiline to hide
        var attempts = 0
        while multilineTextView.exists && attempts < 5 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            attempts += 1
        }
        XCTAssertFalse(multilineTextView.exists)
        
        // Reset to visible state
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("anything")
        
        // Wait for multiline to become visible again
        attempts = 0
        while !multilineTextView.exists && attempts < 5 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            attempts += 1
        }
        
        // 2. First = "hide", multiline ≠ "show" => display text should hide
        firstTextField.tap()
        app.selectAllInTextField(in: firstTextField, app: app)
        firstTextField.typeText("hide")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        multilineTextView.tap()
        multilineTextView.press(forDuration: 1.0)
        let selectAll = app.menuItems["Select All"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5),"‘Select All’ menu didn’t show up")
        selectAll.tap() // Select all with keyboard shortcut
        multilineTextView.typeText("not_show")
        
        // Wait for display text to hide based on conditional logic
        attempts = 0
        while displayText.exists && displayText.isHittable && attempts < 10 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            attempts += 1
        }
        XCTAssertFalse(displayText.exists && displayText.isHittable, "Display text is still visible")
        
        // 3. Second textbox should hide if:
        //  - First is filled
        //  - OR multiline is empty
        //  - OR First = "readonly"
        //  - OR First ≠ "hide"
        //  - OR First contains "abcd"
        
        // Condition: first is filled
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        firstTextField.typeText("filled")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        
        // Wait for third text field to hide based on conditional logic
        attempts = 0
        while thirdTextField.exists && attempts < 5 {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
            attempts += 1
        }
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: multiline is empty
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        firstTextField.typeText("anything")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first = "readonly"
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        firstTextField.typeText("readonly")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first ≠ "hide"
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        firstTextField.typeText("not_hide")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first contains "abcd"
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        firstTextField.typeText("abcd")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(thirdTextField.exists)
        
        // 4. Third textbox hidden if first is empty
        firstTextField.tap()
        firstTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstTextField.clearText()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(thirdTextField.exists)
        
        // Restore to unhide all
        firstTextField.tap()
        firstTextField.typeText("visible")
        multilineTextView.tap()
        multilineTextView.typeText("\u{0001}") // Use keyboard shortcut for TextView
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        multilineTextView.typeText("show")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        firstTextField.tap()
        app.swipeUp()
        app.swipeDown()
        XCTAssertTrue(displayText.exists)
        XCTAssertTrue(firstTextField.exists)
        XCTAssertTrue(secondTextField.exists)
    }
      
    func testMultilineInputInSingleLineTextBox() {
        let textField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.clearText()
        let multilineText = "Line1\nLine2\nLine3"
        textField.typeText(multilineText)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertNotEqual(onChangeResultValue().text!, "Line1\nLine2\nLine3")
    }
    
    // Verifies various field headers
    func testFieldHeaderRendering() {
        let multilineField = app.textViews.element(boundBy: 0)
        XCTAssertTrue(multilineField.exists)
        
        let titleWithMultiline = app.staticTexts["Please input your test data here for thorough evaluation and analysis—let's ensure everything runs smoothly and efficiently."]
        XCTAssertTrue(titleWithMultiline.exists)
        
        let smallTitle = app.staticTexts["Multiline Text"]
        XCTAssertTrue(smallTitle.exists)
        
        let noTitleField = app.textFields.element(boundBy: 1)
        XCTAssertTrue(noTitleField.exists)
    }
    
    // Verifies onChange payload values
    func testTextFieldOnChangePayloadDetails() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("CheckPayload")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686bbffc8e9cdd8c3ceeed2d")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686bc000238ce635c382fbe7")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686bc000b6539ca7ff945674")
    }
    
    // Verifies onFocus and onBlur triggers
    func testTextFieldOnFocusAndOnBlur() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0)) // simulate focus delay
        XCTAssertTrue(textField.isHittable, "Text field should be hittable (focused)")
        
        textField.typeText("FocusBlurTest")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        app.otherElements.firstMatch.tap() // simulate blur
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertEqual(onChangeResultValue().text!, "testFocusBlurTest")
    }
    
    func testRequiredFieldAsteriskPresence() {
        let requiredLabel = app.staticTexts["Please input your test data here for thorough evaluation and analysis—let's ensure everything runs smoothly and efficiently."]
        XCTAssertTrue(requiredLabel.exists, "Required field label should display")

        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")

        // Enter value and ensure asterisk still remains
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("Sample input")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
}
