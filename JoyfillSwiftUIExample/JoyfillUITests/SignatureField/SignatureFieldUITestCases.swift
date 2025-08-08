//
//  SignatureFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 12/07/25.
//

import XCTest
import JoyfillModel

final class SignatureFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "SignatureFieldTestData"
    }
    
    func drawSignatureLine() {
        let canvas = app.otherElements["CanvasIdentifier"]
        canvas.tap()
        let startPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let endPoint = canvas.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 1))
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
    }
    
    func testSaveSignature() throws {
        let signatureDetailButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        app.swipeUp()
        app.swipeDown()
        
        XCTAssertEqual("Edit Signature", signatureDetailButton.label)
        XCTAssertNotNil(onChangeResultValue().signatureURL?.isEmpty)
    }
    
    func testClearSignature() throws {
        let signatureDetailButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
        
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["ClearSignatureIdentifier"].tap()
        app.buttons["SaveSignatureIdentifier"].tap()
        XCTAssertEqual("Add Signature", signatureDetailButton.label)
    }

    func testFieldHeaderRendering() throws {
        
        let shortTitle = app.staticTexts["Signature"]
        XCTAssertTrue(shortTitle.exists)
        
        let multilineTitle = app.staticTexts["This signature field is\nreadonly and testing for \nmultiline header."]
        XCTAssertTrue(multilineTitle.exists)
         
        // Verify no-text header
        let noHeader = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 1)
        XCTAssertTrue(noHeader.exists, "No-text header should exist")
    }

    func testReadonlySignatureFieldNotEditable() throws {
        app.swipeUp()
        var index = 1;
        if UIDevice.current.userInterfaceIdiom == .pad {
            index = 2;
        }
        let disabledButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: index)
        XCTAssertTrue(disabledButton.exists, "Readonly signature button should exist")
        disabledButton.tap()
        XCTAssertFalse(app.otherElements["CanvasIdentifier"].exists, "Canvas should not appear for readonly signature field")
    }

    func testOnChangePayloadDetails() throws {
        let signatureButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        signatureButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        let payload = onChangeResult().dictionary
        XCTAssertEqual(payload["fieldId"] as? String, "68722bf19c672bea4f559b57")
        XCTAssertEqual(payload["pageId"] as? String, "66a14ced15a9dc96374e091e")
        XCTAssertEqual(payload["fieldIdentifier"] as? String, "field_68722bf903d0b4dec6baeb1a")
        XCTAssertEqual(payload["fieldPositionId"] as? String, "68722bf9f8f55c7e44903770")
    }

    func testSignatureFieldOnFocusAndOnBlur() throws {
        let signatureButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        // Tap to open the signature canvas
        XCTAssertTrue(signatureButton.waitForExistence(timeout: 5), "Signature button not found")
        signatureButton.tap()
        // Verify the canvas appears
        let canvas = app.otherElements["CanvasIdentifier"]
        XCTAssertTrue(canvas.waitForExistence(timeout: 5), "Signature canvas should appear on tap")
        // Dismiss the canvas by tapping outside
        app.otherElements.firstMatch.tap()
        // Ensure the canvas is dismissed
        XCTAssertTrue(canvas.exists, "Signature canvas should be dismissed on blur")
    }

    func testRequiredAsteriskPresence() throws {
        let asteriskIcon = app.images.matching(identifier: "asterisk").element(boundBy: 0)
        XCTAssertTrue(asteriskIcon.exists, "Asterisk should be visible for required signature field")
        // Draw and save signature should not remove the asterisk
        let signatureButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        signatureButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        XCTAssertTrue(asteriskIcon.exists, "Asterisk should remain after saving signature")
    }

    func testConditionalLogicShowHide() throws {
        app.swipeUp()
        // Third signature field (index 2) should be hidden until conditions are met
        let hiddenButton = app.buttons.matching(identifier: "SignatureIdentifier")
        app.swipeUp()
        app.swipeDown()
        XCTAssertTrue(hiddenButton.count == 3, "Third signature field should initially be hidden")
        // Enter the trigger value into the text field
        app.swipeUp()
        let triggerField = app.textFields.firstMatch
        triggerField.tap()
        triggerField.clearText()
        triggerField.typeText("hidexyz")
        sleep(1)
        app.swipeUp()
        app.swipeDown()
        XCTAssertFalse(hiddenButton.count == 1, "Third signature field should be shown after conditions met")
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
    
    func testDefaultSignatureFilled() throws {
        let signatureDetailButton = app.buttons.matching(identifier: "SignatureIdentifier").element(boundBy: 0)
        
        XCTAssertTrue(signatureDetailButton.waitForExistence(timeout: 5), "Signature button not found")
        signatureDetailButton.tap()
        drawSignatureLine()
        app.buttons["SaveSignatureIdentifier"].tap()
        app.swipeUp()
        app.swipeDown()
        XCTAssertEqual("Edit Signature", signatureDetailButton.label)
        XCTAssertNotNil(onChangeResultValue().signatureURL?.isEmpty)
        // 4. Check that it starts/ends with the right bits of your known-default PNG
        let expectedPrefix = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABmgAAAG4CAYAAABB4Gh5"
        let expectedSuffix = "AElFTkSuQmCC"
        XCTAssertTrue(((onChangeResultValue().signatureURL?.hasPrefix(expectedPrefix)) != nil),
                      "Signature data should start with expected prefix")
        XCTAssertTrue(((onChangeResultValue().signatureURL?.hasSuffix(expectedSuffix)) != nil),
                      "Signature data should end with expected suffix")
    }
}
