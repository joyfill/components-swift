//
//  MultiSelectFieldUITestCases.swift
//  JoyfillUITests
//
//  Created by Vishnu on 09/07/25.
//

import XCTest
import JoyfillModel

final class NumberFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "NumberFieldTestData"
    }
        
    func testNumberFieldFocusBehavior() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        XCTAssertTrue(app.keyboards.count > 0, "Keyboard should appear on focus")
    }

    func testNumberFieldClearAndEmpty() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(numberField.value as? String, "")
    }
    
    func testNumberFieldBasicEntry() throws {
        let numberField = app.textFields.element(boundBy: 0)
        XCTAssertEqual("10", numberField.value as! String)

        numberField.tap()
        numberField.typeText("5") // This will make it 105
        XCTAssertEqual(numberField.value as? String, "105")
    }
    
    func testMultilineConditionalHideLogicWithNumber() throws {
        let numberField = app.textFields.element(boundBy: 0)
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]

        // Initially visible
        XCTAssertTrue(multilineField.exists)

        // Trigger hide logic: input number > 50 and != 55
        numberField.tap()
        numberField.clearText()
        numberField.typeText("51")

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(multilineField.exists)
        
        
        // Trigger show logic: input number == 55
        numberField.tap()
        numberField.clearText()
        numberField.typeText("55")

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertTrue(multilineField.exists)
    }
    
    
    func testNumberFieldConditionalHideLogic() throws {
        let numberField = app.textFields.element(boundBy: 0)
        let multilineField = app.textViews["MultilineTextFieldIdentifier"]

        XCTAssertTrue(multilineField.exists)

        numberField.tap()
        numberField.clearText()
        numberField.typeText("55") // Should not hide because value == 55

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertTrue(multilineField.exists)

        numberField.tap()
        numberField.clearText()
        numberField.typeText("60") // Should hide

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertFalse(multilineField.exists)
    }
      
    func testNumberFieldNegativeEntry() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.typeText("-42")

        // Assuming logic doesn't hide multiline for negative
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertTrue(app.textViews["MultilineTextFieldIdentifier"].exists)
        XCTAssertEqual(numberField.value as? String, "-42")
    }

    func testNumberFieldDecimalEntry() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.typeText("123.45")

        // Assuming decimal should be accepted, otherwise update assertion
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(numberField.value as? String, "123.45")
    }

    func testNumberFieldInvalidCharactersRejection() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        
        let invalidInputs = [
            "abc",          // String
            "@#$%^",        // Symbols
            "true",         // Boolean literal
            "null",         // Null literal
            "[]",           // Empty array
            "[1,2,3]",      // Array of numbers
            "{}",           // Empty object
            "{\"key\":1}",  // Object with key-value
            //"NaN",          // Not a number
            "∞",            // Infinity symbol
            "１２３",        // Full-width unicode numbers
            "123abc",       // Mixed valid and invalid
            "123.45.67",    // Multiple decimals
            "--123"         // Invalid negative
        ]
        
        for input in invalidInputs {
          numberField.tap()
          numberField.clearText()
          numberField.typeText(input)
          // better than sleep: wait for your UI to update, if possible
          
          let backendValue = onChangeResultValue().number
          if let str = backendValue as? String {
            XCTAssertEqual(str, "", "Backend should return empty string for invalid input: \(input)")
          }
          else if backendValue == nil {
            // still okay if you ever return nil
          }
          else if let num = backendValue as? Double {
            // **Now expect** 0.0 for pure-text errors:
            XCTAssertEqual(num, 0.0,
                           "Backend should return 0.0 for invalid input: \(input)")
          }
          else {
            XCTFail("Unexpected type for backend value from input '\(input)': \(type(of: backendValue))")
          }
        }
    }

    func testNumberFieldBoundaryValues() throws {
        let numberField = app.textFields.element(boundBy: 0)
        
        // Very small
        numberField.tap()
        numberField.clearText()
        numberField.typeText("-999999")
        XCTAssertEqual(numberField.value as? String, "-999999")

        // Very large
        numberField.tap()
        app.selectAllInTextField(in: numberField, app: app)
        numberField.typeText("9999999")
        XCTAssertEqual(numberField.value as? String, "9999999")
    }
    
    
    func testNumberFieldCallOnChangeAfterTwoSeconds() throws {
        let numberTextField = app.textFields.element(boundBy: 0)
        XCTAssertEqual("10", numberTextField.value as! String)
        numberTextField.tap()
        numberTextField.typeText("345")
        sleep(2)
        XCTAssertEqual(10345.0, onChangeResultValue().number!)
    }
     
    func testMultilineLongTextInNumberField() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        let longText = """
        12345678901234567890
        23456789012345678901
        34567890123456789012
        """
        numberField.typeText(longText)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        // App should not crash and backend should return valid prefix
        let onchangeNumber = onChangeResultValue().number ?? 0
        let formatted = String(format: "%.0f", onchangeNumber)
        XCTAssertTrue(formatted.hasPrefix("123456789012345"), "Should handle long numeric text safely")
    }

    func testThirdNumberFieldEmptyValue() throws {
        let thirdField = app.textFields.element(boundBy: 2) // index for 3rd number field
        let thirdFieldValue = thirdField.value as? String ?? ""
        XCTAssertEqual(thirdFieldValue, "", "The third number field should be empty")
    }
  
    
    func testToolTip() throws {
        let toolTipButton = app.buttons["ToolTipIdentifier"]
        toolTipButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        let alert = app.alerts["Tooltip Title"]
        XCTAssertTrue(alert.exists, "Alert should be visible")
        
        let alertTitle = alert.staticTexts["Tooltip Title"]
        XCTAssertTrue(alertTitle.exists, "Alert title should be visible")
        
        let alertDescription = alert.staticTexts["Tooltip Description"]
        XCTAssertTrue(alertDescription.exists, "Alert description should be visible")
        
        alert.buttons["Dismiss"].tap()
    }

    func testReadonlyNumberFieldNotEditable() throws {
        let readonlyField = app.textFields.element(boundBy: 3)
        XCTAssertTrue(readonlyField.exists)
        readonlyField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        
        XCTAssertEqual(app.keyboards.count, 0, "Keyboard should not appear for readonly field")
        let initialValue = readonlyField.value as? String
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
         
        // Optionally, you can also check that the field's value remains unchanged
        let finalValue = readonlyField.value as? String
        XCTAssertEqual(initialValue, finalValue, "Readonly field's value should not change")
    }
    
    func testNumberFieldOnChangePayloadDetails() throws {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.typeText("1234")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "686dea82ad19e9a7a3f7c976")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_686dea98c790de3716db73d2")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "686dea9891602bff8d529bc9")
        XCTAssertEqual(payload["fileId"] as? String, "66a14ced9dc829a95e272506")
        XCTAssertEqual(payload["target"] as? String, "field.update")
        XCTAssertEqual(payload["identifier"] as? String, "template_6849dbb509ede5510725c910")
        XCTAssertEqual(payload["_id"] as? String, "66a14cedd6e1ebcdf176a8da")
        XCTAssertEqual(payload["sdk"] as? String, "swift")
    }
     
    func testThirdNumberFieldInitialEmpty() throws {
        let thirdField = app.textFields.element(boundBy: 2)
        let value = thirdField.value as? String ?? ""
        XCTAssertEqual(value, "", "Third number field should be empty initially")
    }
     
    
    func testNumberFieldTitleRendering() throws {
        let longTitle = app.staticTexts["Number 1"]
        XCTAssertTrue(longTitle.exists, "Long title should be visible")

        let shortTitle = app.staticTexts["Number"]
        XCTAssertTrue(shortTitle.exists, "Short title should be visible")
        
        let multilineTitle = app.staticTexts["This is multiline text box enter multiline text here for better testing."]
        XCTAssertTrue(multilineTitle.exists, "Long title should be visible")

        let thirdField = app.textFields.element(boundBy: 2)
        XCTAssertTrue(thirdField.exists, "Field without visible title should not crash")
    }
    
    func testNumberFieldScrollRetainsValue() {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.typeText("1234567890")
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(numberField.value as? String, "1234567890")
    }
    
    func testNumberFieldTypingAndPaste() {
        UIPasteboard.general.string = "123456789"
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.press(forDuration: 1.0)
        let paste = app.menuItems["Paste"]
        XCTAssertTrue(paste.waitForExistence(timeout: 5),"Paste menu never appeared")
        paste.tap()
        XCTAssertEqual(numberField.value as? String, "123456789")
    }
    
    func testNumberFieldOnChangePayloadAndFocusBlur() {
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0)) // simulate focus delay
        numberField.typeText("12345")
        sleep(2) // simulate delay before blur
        app.otherElements.firstMatch.tap() // dismiss keyboard
        XCTAssertEqual(onChangeResultValue().text!, "1012345.0")
    }
    
    func testRequiredFieldAsteriskPresence() {
        let requiredLabel = app.staticTexts["Number"]
        XCTAssertTrue(requiredLabel.exists, "Required field label should display")

        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should be visible for required field")

        // Enter value and ensure asterisk still remains
        let numberField = app.textFields.element(boundBy: 0)
        numberField.tap()
        numberField.clearText()
        numberField.typeText("12345")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        XCTAssertTrue(asteriskIcon.exists, "Asterisk icon should remain after entering value in required field")
    }
    
    func testNonRequiredFieldNoAsterisk() {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 2)
        XCTAssertFalse(asteriskIcon.exists, "Asterisk icon should not be visible for non required field")
    }
    
    func testSecondNumberFieldConditionalHideCases() throws {
        let firstField = app.textFields.element(boundBy: 0)
        let secondField = app.textFields.element(boundBy: 1)
        let thirdField = app.textFields.element(boundBy: 2)
        let allFields = app.textFields
        
        // Case 1: First is empty → second should hide
        firstField.tap()
        firstField.clearText()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Second field should hide when first is empty")

        // Case 2: First = 20 → second should hide
        firstField.tap()
        firstField.clearText()
        firstField.typeText("20")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Second field should hide when first = 20")

        // Case 3: First ≠ 10 → second should hide
        firstField.tap()
        firstField.clearText()
        firstField.typeText("30")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Second field should hide when first ≠ 10")

        // Case 4: First > 50 → second should hide
        firstField.tap()
        firstField.clearText()
        firstField.typeText("51")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Second field should hide when first > 50")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        // Case 5: Third < 70 → second should hide
        secondField.tap()
        secondField.clearText()
        secondField.typeText("65")
        firstField.tap()
        firstField.clearText()
        firstField.typeText("10") // Reset to ensure other conditions don't match
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Second field should hide when third < 70")
        sleep(2)
        // Case 6: All invalidated → second should show
        secondField.tap()
        secondField.clearText()
        secondField.tap()
        secondField.typeText("90")
        firstField.tap()
        firstField.press(forDuration: 1.0)
        app.menuItems["Select All"].tap()
        firstField.clearText()
        firstField.typeText("10")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 4, "Second field should show when all conditions are false")
    }
    
    func testThirdNumberFieldConditionalHideCases() throws {
        let firstField = app.textFields.element(boundBy: 0)
        let secondField = app.textFields.element(boundBy: 1)
        let thirdField = app.textFields.element(boundBy: 2)
        let allFields = app.textFields
        
        // Case 1: First > 80 AND second is empty → third should hide
        secondField.tap()
        secondField.clearText()
        
        firstField.tap()
        firstField.clearText()
        firstField.typeText("81")
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        XCTAssertEqual(allFields.count, 2, "Third field should hide when first > 80 and second is empty")

        // Case 2: Make second field non-empty → third should show
        firstField.tap()
        firstField.clearText()
        firstField.typeText("10")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        secondField.tap()
        secondField.clearText()
        secondField.typeText("5")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 4, "Third field should show when second is filled")

        // Case 3: Reset first field ≤ 80 → third should show
        firstField.tap()
        firstField.clearText()
        firstField.typeText("60")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual(allFields.count, 3, "Third field should stay visible when first ≤ 80")
    }
}
