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
    
    func testShowTextField() throws {
        let pageSelectionButton = app.buttons["PageNavigationIdentifier"]
        pageSelectionButton.tap()
        
        let pageSheetSelectionButton = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let secondPage = pageSheetSelectionButton.element(boundBy: 1)
        secondPage.tap()
        
        let textFields = app.textFields.allElementsBoundByIndex
        
        let thirdTextField = textFields[2]
        XCTAssertTrue(thirdTextField.exists, "The third text field does not exist.")
        
        thirdTextField.tap()
        thirdTextField.typeText("Hello\n")
        
//        let page2TextField = app.textFields["Text"]
//        page2TextField.tap()
//        page2TextField.typeText("Hello\n")
//        XCTAssertEqual("Hello", onChangeResultValue().text!)
        
        pageSelectionButton.tap()
        
        let firstPage = pageSheetSelectionButton.element(boundBy: 0)
        firstPage.tap()
        
        pageSelectionButton.tap()
        secondPage.tap()
        
//        let page2TextField = app.textFields["Text"]
//        XCTAssertEqual("Page 2", page2TextField.value as! String)
//        page2TextField.tap()
//        page2TextField.typeText(" Done\n")
//        XCTAssertEqual("Page 2 Done", onChangeResultValue().text!)
    }
}
