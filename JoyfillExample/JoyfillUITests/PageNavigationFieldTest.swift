import XCTest
import JoyfillModel

final class PageNavigationFieldTests: JoyfillUITestsBaseClass {
    
    func testPageNavigation() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        let firstTextField = textFields[0]
        XCTAssertTrue(firstTextField.exists, "The third text field does not exist.")
        XCTAssertEqual("", firstTextField.value as! String)
        firstTextField.tap()
        firstTextField.typeText("Hello\n")
        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
    }
}
