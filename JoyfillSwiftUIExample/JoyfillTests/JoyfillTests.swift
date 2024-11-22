import XCTest
import Foundation
import SwiftUI
import JoyfillModel

final class JoyfillTests: XCTestCase {
    
    func jsonDocument() -> JoyDoc {
        let path = Bundle.main.path(forResource: "TableFieldJson", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }

    var document = JoyDoc()
    
    func testGetJoyDoc() {
        jsonDocument().assertDocument()
    }
    
    func testSetJoyDoc() {
        document.setDocument().assertDocument()
    }
    
    func testGetFileFields() {
        jsonDocument().assertFileFields()
    }
    
    func testSetFileFields() {
        document.setDocument().setFile().assertFileFields()
    }
    
    func testGetImageField() {
        jsonDocument().assertImageField()
    }
    
    func testSetImageField() {
        document.setDocument().setImagefields().assertImageField()
    }
    
    func testHeadingText() {
        jsonDocument().assertHeadingText()
    }
    
    func testSetHeadingText() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .assertHeadingText()
    }
    
    func testGetDisplayText() {
        jsonDocument().assertDisplayText()
    }
    
    func testSetDisplayText() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .assertDisplayText()
    }
    
    func testGetEmptySpaceField() {
        jsonDocument().assertEmptySpaceField()
    }
    
    func testSetEmptySpaceField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .assertEmptySpaceField()
    }
    
    func testGetTextField() {
        jsonDocument().assertTextField()
    }
    
    func testSetTextField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .assertTextField()
    }
    
    func testGetMultilineTextField() {
        jsonDocument().assertMultilineTextField()
    }
    
    func testSetMultilineTextField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .assertMultilineTextField()
    }
    
    func testGetNumberField() {
        jsonDocument().assertNumberField()
    }
    
    func testSetNumberField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .assertNumberField()
    }
    
    func testGetDateField() {
        jsonDocument().assertDateField()
    }
    
    func testSetDateField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .assertDateField()
    }
    
    func testGetTimeField() {
        jsonDocument().assertTimeField()
    }
    
    func testSetTimeField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .assertTimeField()
    }
    
    func testGetDateTimeField() {
        jsonDocument().assertDateTimeField()
    }
    
    func testSetDateTimeField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .assertDateTimeField()
    }
    
    func testgetDropdownField() {
        jsonDocument().assertDropdownField()
    }
    
    func testSetDropdownField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .assertDropdownField()
    }
    
    func testGetMultipleChoiceField() {
        jsonDocument().assertMultipleChoiceField()
    }
    
    func testSetMultipleChoiceField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .setMultipleChoiceField()
            .assertMultipleChoiceField()
    }
    
    func testGetSingleChoiceField() {
        jsonDocument().assertSingleChoiceField()
    }
    
    func testSetSingleChoiceField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .setMultipleChoiceField()
            .setSingleChoiceField()
            .assertSingleChoiceField()
    }
    
    func testGetSignatureField() {
        jsonDocument().assertSignatureField()
    }
    
    func testSetSignatureField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .setMultipleChoiceField()
            .setSingleChoiceField()
            .setSignatureField()
            .assertSignatureField()
    }
    
    func testGetTableField() {
        jsonDocument().assertTableField()
    }
    
    func testSetTableField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .setMultipleChoiceField()
            .setSingleChoiceField()
            .setSignatureField()
            .setTableField()
            .assertTableField()
    }
    
    func testgetChartField() {
        jsonDocument().asssertChartField()
    }
    
    func testSetChartField() {
        document
            .setDocument()
            .setImagefields()
            .setHeadingText()
            .setDisplayText()
            .setEmptySpaceField()
            .setTextField()
            .setMultilineTextField()
            .setNumberField()
            .setDateField()
            .setTimeField()
            .setDateTimeField()
            .setDropdownField()
            .setMultipleChoiceField()
            .setSingleChoiceField()
            .setSignatureField()
            .setTableField()
            .setChartField()
            .asssertChartField()
    }
    
    func testGetPageField() {
        jsonDocument().assertPageField()
    }
    
    func testSetPageField() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .setPageField()
            .assertPageField()
    }
    
    func testGetImageFieldPosition() {
        jsonDocument().assertImageFieldPosition()
    }
    
    func testSetImageFieldPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .assertImageFieldPosition()
    }
    
    func testGetHeadingTextPosition() {
        jsonDocument().assertHeadingText()
    }
    
    func testSetHeadingTextPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .assertHeadingTextPosition()
    }
    
    func testGetDisplayTextPosition() {
        jsonDocument().assertDisplayTextPosition()
    }
    
    func testSetDisplayTextPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .assertDisplayTextPosition()
    }
    
    func testGetEmptySpacePosition() {
        jsonDocument().assertEmptySpacePosition()
    }
    
    func testSetEmptySpacePosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .assertEmptySpacePosition()
    }
    
    func testGetTextPosition() {
        jsonDocument().assertTextPosition()
    }
    
    func testSetTextPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .assertTextPosition()
    }
    
    func testGetMultiLineTextPosition() {
        jsonDocument().assertMultiLineTextPosition()
    }
    
    func testSetMultiLineTextPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .assertMultiLineTextPosition()
    }
    
    func testGetNumberPosition() {
        jsonDocument().assertNumberPosition()
    }
    
    func testSetNumberPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .assertNumberPosition()
    }
    
    func testGetDatePosition() {
        jsonDocument().assertDatePosition()
    }
    
    func testSetDatePosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .assertDatePosition()
    }
    
    func testGetTimePosition() {
        jsonDocument().assertTimePosition()
    }
    
    func testSetTimePosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .assertTimePosition()
    }
    
    func testGetDateTimePosition() {
        jsonDocument().assertDateTimePosition()
    }
    
    func testSetDateTimePosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .setDateTimePosition()
            .assertDateTimePosition()
    }
    
    func testGetDropdownPosition() {
        jsonDocument().assertDropdownPosition()
    }
    
    func testSetDropdownPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .setDateTimePosition()
            .setDropdownPosition()
            .assertDropdownPosition()
    }
    
    func testGetMultiselectPosition() {
        jsonDocument().assertMultiselectPosition()
    }
    
    func testSetMultiselectPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .setDateTimePosition()
            .setDropdownPosition()
            .setMultiselectPosition()
            .assertMultiselectPosition()
    }
    
    func testGetSingleSelectPosition() {
        jsonDocument().assertSingleSelectPosition()
    }
    
    func testSetSingleSelectPosition() {
        document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .setDateTimePosition()
            .setDropdownPosition()
            .setMultiselectPosition()
            .setSingleSelectPosition()
            .assertSingleSelectPosition()
    }
    
    func testGetSignaturePosition() {
        jsonDocument().assertSignaturePosition()
    }
    
    func testSetSignaturePosition() {
        getSignaturePositionWithDependentFields()
            .assertSignaturePosition()
    }
    
    func testGetTablePosition() {
        jsonDocument().assertTablePosition()
    }
    
    func testSetTablePosition() {
        getTablePositionWithDependentFields()
            .assertTablePosition()
    }
    
    func testGetChartPosition() {
        jsonDocument().assertChartPosition()
    }
    
    func testSetChartPosition() {
        getTablePositionWithDependentFields()
            .setChartPosition()
            .assertChartPosition()
    }

    func getSignaturePositionWithDependentFields() -> JoyDoc {
        return document
            .setDocument()
            .setFile()
            .setPageField()
            .setImageFieldPosition()
            .setHeadingTextPosition()
            .setDisplayTextPosition()
            .setEmptySpacePosition()
            .setTextPosition()
            .setMultiLineTextPosition()
            .setNumberPosition()
            .setDatePosition()
            .setTimePosition()
            .setDateTimePosition()
            .setDropdownPosition()
            .setMultiselectPosition()
            .setSingleSelectPosition()
            .setSignaturePosition()
    }

    func getTablePositionWithDependentFields() -> JoyDoc {
        return getSignaturePositionWithDependentFields()
            .setTablePosition()
    }
}
