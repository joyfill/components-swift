//
//  MultiSelectFieldUITestCases.swift
//  JoyfillUITests
//
//  Created by Vivek on 07/07/25.
//

import XCTest
import JoyfillModel

final class TestMobileViewDuplicateLogic: JoyfillUITestsBaseClass {
    // Override to specify which JSON file to use for this test class
    override func getJSONFileNameForTest() -> String {
        return "TestMobileViewDuplicateLogic"
    }
    
    func testMobileViewConditonalLogic() {
        app.launchArguments.append("--page-duplicate-enabled")
        app.launchArguments.append("true")
        XCTAssertTrue(!app.staticTexts["Table"].exists)
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        let duplicateButton = app.buttons["PageDuplicateIdentifier"]
        duplicateButton.firstMatch.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let tapOnSecondPage = pageSheetSelectionButton.element(boundBy: 1)
        tapOnSecondPage.tap()
        
        let textField = app.textFields.element(boundBy: 0)
        textField.tap()
        textField.clearText()
        textField.typeText("100")
        
        app.swipeDown()
        
        XCTAssertTrue(app.staticTexts["Table"].exists)
    }
}
