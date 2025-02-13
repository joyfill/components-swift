import XCTest
import JoyfillModel

final class FirstPageHiddenLogicTests: JoyfillUITestsBaseClass {
    
    // FirstPageHidden json file
    func testFirstPageHiddenLogic() throws {
        // Enter data in multiline field
        let multiLineTextField = app.textViews["MultilineTextFieldIdentifier"]
        XCTAssertEqual("", multiLineTextField.value as! String)
        multiLineTextField.tap()
        multiLineTextField.typeText("Hello")
        sleep(2)
        XCTAssertEqual("Hello", onChangeResultValue().multilineText)
        
        // Tap on page button
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertEqual("Page 2 ", pageSelectionButton.label)
        pageSelectionButton.tap()
        
        // Tap on page sheet button
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        XCTAssertEqual("Page 2 ", firstPage.label)
        firstPage.tap()
        
        // Now enter data in Number field
        let numberTextField = app.textFields["Number"]
        XCTAssertEqual("", numberTextField.value as! String)
        numberTextField.tap()
        numberTextField.typeText("345\n")
        sleep(2)
        XCTAssertEqual(345.0, onChangeResultValue().number!)
    }
}
