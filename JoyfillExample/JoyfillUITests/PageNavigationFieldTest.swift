import XCTest
import JoyfillModel

final class PageNavigationFieldTests: JoyfillUITestsBaseClass {
    
    func testPageNavigation() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let page2TextField = app.textFields["Text"]
        XCTAssertEqual("Page 2", page2TextField.value as! String)
        page2TextField.tap()
        page2TextField.typeText(" Done\n")
        XCTAssertEqual("Page 2 Done", onChangeResultValue().text!)
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
    }
}
