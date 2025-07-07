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
        let textField = app.textFields["Text"]
        XCTAssertEqual("test", textField.value as! String)
        
        textField.tap()
        textField.typeText("Hello\n")
        XCTAssertEqual("testHello", onChangeResultValue().text!)
        
    }
    
    func testMultilineField() throws {
        let multiLineTextField = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertEqual("test", multiLineTextField.value as! String)
        multiLineTextField.tap()
        multiLineTextField.typeText("Hello")
        sleep(1)
        XCTAssertEqual("Hellotest", onChangeResultValue().multilineText)
    }
    
    
    func getOptionsButtonsCount(identifier: String) -> Int {
        let multiSelect = app.buttons.matching(identifier: identifier)
        return multiSelect.count
    }

    internal override func goBack() {
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }
    
    //Conditional logic case insensitive UI test cases
    //In json we have logic using "HELLO" and we are testing this with "hello" case insensitive logic
    func testConditonalLogicWithMultiSelect() throws {
        let textField = app.textFields["Text"]
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
}
