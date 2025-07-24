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
        multiLineTextField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multiLineTextField.typeText("quick")
        sleep(1)
        XCTAssertEqual("quick", onChangeResultValue().multilineText)
    }
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        sleep(1)
        
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
        sleep(1)
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
        sleep(2)
        XCTAssertEqual("testHello", onChangeResultValue().text!)
    }
    
    func testConditionalLogicForMultilineAndDisplayText() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("hide")
        let multiline = app.textViews["MultilineTextFieldIdentifier"]
        let displayText = app.staticTexts["Display text will be hidden when text is 'hide' and multiline should not 'show'"]
        sleep(1)
        XCTAssertFalse(displayText.exists)
    }
    
    func testReadonlyTextFieldDoesNotTriggerKeyboard() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("qqqq")
        
        let multilineTextView = app.textViews.element(boundBy: 0)
        multilineTextView.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multilineTextView.typeText("hide")
        app.swipeDown()
        let readonlyField = app.textFields.element(boundBy: 1)
        readonlyField.tap()
        XCTAssertFalse(app.keyboards.element.exists, "Keyboard should not be visible for readonly field")
    }
    
    func testTextFieldDataTypes() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("12345")
        sleep(1)
        XCTAssertEqual(onChangeResultValue().text!, "12345")
        
        textField.clearText()
        textField.typeText("[1,2,3]")
        sleep(1)
        XCTAssertEqual(onChangeResultValue().text!, "[1,2,3]")
        
        textField.clearText()
        textField.typeText("{\"key\":\"value\"}")
        sleep(1)
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
        sleep(1)
        app.menuItems["Paste"].tap()
        XCTAssertEqual(textField.value as? String, "Pasted Text")
    }
    
    func testTextFieldOnChangePayloadAndFocusBlur() {
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        sleep(1) // simulate focus delay
        textField.typeText("trigger")
        sleep(2) // simulate delay before blur
        app.otherElements.firstMatch.tap() // dismiss keyboard
        XCTAssertEqual(onChangeResultValue().text!, "testtrigger")
    }
    
    func testTextFieldScrollRetainsValue() {
        let textField = app.textFields.element(boundBy: 0)
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
        sleep(1)
        XCTAssertFalse(multilineTextView.exists)
        
        // Reset to visible state
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("anything")
        sleep(1)
        
        // 2. First = "hide", multiline ≠ "show" => display text should hide
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("hide")
        sleep(1)
        multilineTextView.tap()
        multilineTextView.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        multilineTextView.typeText("not_show")
        sleep(2)
        XCTAssertFalse(displayText.exists)
        
        // 3. Second textbox should hide if:
        //  - First is filled
        //  - OR multiline is empty
        //  - OR First = "readonly"
        //  - OR First ≠ "hide"
        //  - OR First contains "abcd"
        
        // Condition: first is filled
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("filled")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: multiline is empty
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("anything")
        sleep(1)
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first = "readonly"
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("readonly")
        sleep(1)
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first ≠ "hide"
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("not_hide")
        sleep(1)
        XCTAssertFalse(thirdTextField.exists)
        
        // Condition: first contains "abcd"
        firstTextField.tap()
        firstTextField.clearText()
        firstTextField.typeText("abcd")
        sleep(1)
        XCTAssertFalse(thirdTextField.exists)
        
        // 4. Third textbox hidden if first is empty
        firstTextField.tap()
        firstTextField.clearText()
        sleep(1)
        XCTAssertFalse(thirdTextField.exists)
        
        // Restore to unhide all
        firstTextField.tap()
        firstTextField.typeText("visible")
        multilineTextView.tap()
        multilineTextView.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        sleep(1)
        multilineTextView.typeText("show")
        sleep(1)
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
        sleep(1)
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
        sleep(1)
        
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
        sleep(1) // simulate focus delay
        XCTAssertTrue(textField.isHittable, "Text field should be hittable (focused)")
        
        textField.typeText("FocusBlurTest")
        sleep(1)
        
        app.otherElements.firstMatch.tap() // simulate blur
        sleep(1)
        
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
        sleep(1)

        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
}
