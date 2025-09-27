//
//  DisplayTextFieldUITestCases.swift
//  JoyfillExample
//
//  Created by Vishnu on 12/07/25.
//


import XCTest
import JoyfillModel

final class DisplayTextFieldUITestCases: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "DisplayTextFieldTestData"
    }

    func testBlackColorHeadingExists() {
        let heading = app.staticTexts["#26E652 COLOR HEADING "]
        XCTAssertTrue(heading.exists)
    }

    func testRedColorHeadingStyling() {
        let heading = app.staticTexts["Red Color Heading"]
        XCTAssertTrue(heading.exists)
    }

    func testEmptySpaceBlockExists() {
        let spaceBlock = app.staticTexts["This is empty space with #1548b7 color"]
        XCTAssertTrue(spaceBlock.exists)
    }

    func testYellowDisplayTextPresence() {
        let yellowText = app.staticTexts["This is yellow color display text\nwith multiline "]
        XCTAssertTrue(yellowText.exists)
    }

    func testFinalBrownHeadingExists() {
        let heading = app.staticTexts["Final Brown Color Heading"]
        XCTAssertTrue(heading.exists)
    }

    func testItalicSmallHeadingExists() {
        let italicHeading = app.staticTexts["Small heading with italic text"]
        XCTAssertTrue(italicHeading.exists)
    }

    func testUnderlineBoldHeadingExists() {
        let underlineHeading = app.staticTexts["Bold and underline heading"]
        XCTAssertTrue(underlineHeading.exists)
    }

    func testMultilineDisplayTextPresence() {
        let multilineText = app.staticTexts["Multiline display text\nline 1\nline 2\nline 3"]
        XCTAssertTrue(multilineText.exists)
    }
    
    func testUnicodeText() {
        app.swipeUp()
        let heading = app.staticTexts["Hindi: नमस्ते दुनिया | Chinese: 你好，世界 | Arabic: مرحبا بالعالم 🌍"]
        XCTAssertTrue(heading.exists)
    }
    
    func testHideAndShowHeading() throws {
        let textField = app.textFields.element(boundBy: 0)
        let heading = app.staticTexts["Red Color Heading"]
        XCTAssertTrue(heading.exists)
        XCTAssertEqual("Default Value", textField.value as! String)
        
        textField.tap()
        textField.clearText()
        app.swipeDown()
        sleep(1)
        XCTAssertTrue(!heading.exists)
        app.swipeUp()
        
        textField.tap()
        textField.typeText("hide red color heading")
        app.swipeDown()
        sleep(1)
        XCTAssertTrue(!heading.exists)
        app.swipeUp()
        
        
        textField.tap()
        textField.clearText()
        textField.typeText("xyz")
        app.swipeDown()
        sleep(1)
        XCTAssertTrue(!heading.exists)
        app.swipeUp()
        
        
        textField.tap()
        textField.clearText()
        textField.typeText("testHello")
        app.swipeDown()
        sleep(1)
        XCTAssertTrue(heading.exists)
        app.swipeUp()
        
        XCTAssertEqual("testHello", onChangeResultValue().text!)
    }
    
    func testHideDisplayTextByTextField() {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let originalPageButton = pageSheetSelectionButton.element(boundBy: 1)
        originalPageButton.tap()
        
        let heading = app.staticTexts["Red Color Heading"].firstMatch
        XCTAssertTrue(heading.exists)
        
        let textField = app.textFields.element(boundBy: 0)
        XCTAssert(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.clearText()
        textField.typeText("hide")
        XCTAssertFalse(heading.exists)
        
        textField.tap()
        textField.clearText()
        textField.typeText("show")
        XCTAssertTrue(heading.exists)
    }
}
