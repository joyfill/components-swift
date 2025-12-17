import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class ConditionLogicUnitTests: XCTestCase {
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }
    
    func testTextFieldOnNullCondition() {
        //Text Field should show when number is 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getEmptyConditionsLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals)
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, false)
    }
    
    func testEnterUnKnownCaseType() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let multiFieldID = "678104b387d3004e70120ac6"
        
        // Enter unknown condition case type to go in defalut switch case
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: multiFieldID, conditionType: .unKnown, value: .string("677e2bfa9c5249a2acd3644f"))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, false)
    }
    
    func testMultiSelectFieldEqualConditionValue() {
        //Text Field should show when multi value is equal to this value "677e2bfa9c5249a2acd3644f"
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let multiFieldID = "678104b387d3004e70120ac6"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: multiFieldID, conditionType: .equals, value: .string("677e2bfa9c5249a2acd3644f"))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testMultiSelectFieldNotEqualConditionValue() {
        //Text Field should show when multi value is Not euqal to this value"677e2bfa9c5249a2acd3644f"
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let multiFieldID = "678104b387d3004e70120ac6"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: multiFieldID, conditionType: .notEquals, value: .string("677e2bfa9c5249a2acd3644f"))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa152e9f549edf0813"]), multi: true)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testMultiSelectFieldIsEmptyConditionValue() {
        //Text Field should show when multi value is empty
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let multiFieldID = "678104b387d3004e70120ac6"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: multiFieldID, conditionType: .isNull, value: .string("677e2bfa9c5249a2acd3644f"))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setMultiSelectField(hidden: false, value: .array([""]), multi: true)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testSetPageToNil() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getEmptyConditionsLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals)
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        // Set page to nil
        let result = documentEditor.shouldShow(page: nil)
        
        XCTAssertEqual(result, true)
    }
    
    func testSetUnknownPageId() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getEmptyConditionsLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals)
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        // Pass different page id ( for pagesForCurrentView function )
        let result = documentEditor.shouldShow(pageID: "what if i pass unknown page id")
        
        XCTAssertEqual(result, true)
    }
    
    func testSetFieldIDToNil() {
        //Set FiledID to nil
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getEmptyConditionsLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals)
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        // Set fieldId to nil
        let result = documentEditor.shouldShow(fieldID: nil)
        
        XCTAssertEqual(result, true)
    }
        
    func testTextFieldShowOnNumber() {
        //Text Field should show when number is 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testSetConditionFieldToNil() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        // Set fieldID to nil
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: nil, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, false)
    }
    
    func testSetConditionFieldToNilBothFieldHidden() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        // Set fieldID to nil
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: nil, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testTextAsShownAndConditionOfShow() {
        //Text Field should show when number is 100 and also showed at first(Its an edge case)
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testTextAsHideAndConditionOfHide() {
        //Text Field should show when number is 100 and also showed at first(Its an edge case)
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldShowOn() {
        //Text Field should show when number is 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals, value: .double(100))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: "66aa2865da10ac1c7b7acb1d")
        
        XCTAssertEqual(result, true)
    }
    
    func testTextFieldHideOnNumber() {
        //Text Field should hide when number is 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .equals, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldHideOnGreaterNumber() {
        //Text Field should hide when number is greater than 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .greaterThan, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(101))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    //Edge case 1 for greaterThan(When field value is null)
    func testTextFieldOnGreaterWithNullFieldValue() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .greaterThan, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .null)//When field value is null
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    //Edge case 2 for greaterThan (When condition value is null)
    func testTextFieldOnGreaterWithNullConditionValue() {
        //Text Field should Not hide when number is Not greater than 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .greaterThan, value: .null)
        //When condition value is null
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    func testTextFieldHideOnLessNumber() {
        //Text Field should hide when number is less than 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .lessThan, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(99))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    //Edge case 1 for lessThan (When field value is null)
    func testTextFieldOnLessNumberNullFieldValue() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .lessThan, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .null) // When field value is null
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    //Edge case 2 for lessThan(When condition value is null)
    func testTextFieldOnLessNumberNullConditionValue() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .lessThan, value: .null)
        //When condition value is null
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    //Edge case 1 for isNull (When condition value is null)
    func testTextFieldOnIsNullNumberNullConditionValue() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNull, value: .null)
        //When condition value is null
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("hello"))
            .setNumberField(hidden: false, value: .double(100))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    //Edge case 1 for isNotNull (When condition value is null)
    func testTextFieldOnIsNotNullNumberNullConditionValue() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNotNull, value: .null)
        //When condition value is null
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("hello"))
            .setNumberField(hidden: false, value: .null)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    
    func testTextFieldHideOnNotEqualNumber() {
        //Text Field should hide when number is not equals 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .notEquals, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(99))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldHideOnNillNumber() {
        //Text Field should hide when number is not filled
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNull, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .null)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldHideOnNotNillNumber() {
        //Text Field should hide when number is not nill
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNotNull, value: .double(100))
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello"))
            .setNumberField(hidden: false, value: .double(99))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testNumberOnTextField() {
        //Number Field should hide when test is not nill
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: textFieldID, conditionType: .isNull, value: .null)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("hello"))
            .setNumberField(hidden: false, value: .double(99))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true) //Conition not satisfying
    }
    
    func testNumberOnNotNullConditionTextField() {
        //Number Field should hide when test is not nill
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: textFieldID, conditionType: .isNotNull, value: .null)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("hello"))
            .setNumberField(hidden: false, value: .double(99))
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldShowOnDropdownAndMultipleChoice() {
        //Text Field should Show when both dropdown is yes and multiselect is yes
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .equals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: true,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello")) // Hidden at first
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1")) // Yes selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa1ff43cf15d159310"]), multi: true) // Yes selected
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    func testTextFieldShowOnDropdownOrMultipleChoice() {
        //Text Field should Show when either dropdown is yes or multiselect is yes
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .equals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: true,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .or)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello")) // Hidden at first
            .setDropdownField(hidden: false, value: .null) // none is selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa1ff43cf15d159310"]), multi: true) // Yes selected
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    func testTextFieldShowOnNotDropdownAndMultipleChoice() {
        //Text Field(hidden at first) should Show when both dropdown is not yes and multiselect is not yes
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .notEquals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .notEquals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: true,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello")) // Hidden at first
            .setDropdownField(hidden: false, value: .string("677e2bfaf81647d2f6a016a0")) // No is selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true) // No selected
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
    }
    
    func testTextFieldShowOnOneNotDropdownAndMultipleChoice() {
        //Text Field(Shown at first) should Hide when both dropdown is yes and multiselect is not yes
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .notEquals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // Shown at first
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1")) // Yes is selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true) // No selected
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
    }
    
    func testTextFieldShowOnOneNullOneNotNullDropdownAndMultipleChoice() {
        //Text Field(Shown at first) should Hide when both dropdown is null and multiselect is not Null
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .isNull,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .isNotNull,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // Shown at first
            .setDropdownField(hidden: false, value: .null) // Is Null
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true) // No selected(IS Not Null)
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)//Text field is hidden now
    }
    // 6629fb2b9a487ce1c1f35f6c
    
    func testTextFieldShowOnOneNullOneNotNullDropdownAndMultiline() {
        //Text Field(Shown at first) should Hide when both dropdown is Null and MultiLine is contains "vivek"
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiLineFieldID = "6629fb2b9a487ce1c1f35f6c"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .isNull,
                                                     value: .null)
        let conditionTestModel2 = LogicConditionTest(fieldID: multiLineFieldID,
                                                     conditionType: .contains,
                                                     value: .string("vivek"))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // Shown at first
            .setDropdownField(hidden: false, value: .null) // Is Null
            .setMultilineTextField(hidden: false, value: .string("hello world vivek")) //Multiline contains "vivek"
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)//Text field is hidden now
    }
    
    func testTextFieldShowOnAllNullDropdownAndMultiline() {
        //Text Field(Shown at first) should Hide when both dropdown is yes and MultiLine is contains "vivek"
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiLineFieldID = "6629fb2b9a487ce1c1f35f6c"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .null)
        let conditionTestModel2 = LogicConditionTest(fieldID: multiLineFieldID,
                                                     conditionType: .contains,
                                                     value: .null)
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // Shown at first
            .setDropdownField(hidden: false, value: .null) // Is Null
            .setMultilineTextField(hidden: false, value: .string("hello world vivek")) //Multiline contains "vivek"
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true) // Text field is hidden now
    }
    //Edge case for contains when field value is null
    func testTextFieldMultilineValueNull() {
        //Text Field(Shown at first) should Hide when both dropdown is yes and MultiLine is contains "vivek"
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiLineFieldID = "6629fb2b9a487ce1c1f35f6c"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .null)
        let conditionTestModel2 = LogicConditionTest(fieldID: multiLineFieldID,
                                                     conditionType: .contains,
                                                     value: .null)
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: false, value: .string("Hello")) // Shown at first
            .setDropdownField(hidden: false, value: .null) // Is Null
            .setMultilineTextField(hidden: false, value: .null) // when field value is null
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true) // Text field is hidden now
    }
    
    // page condition logic tests
    func testPageConditionLogic() {
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "66600801dc1d8b4f72f54917" //we will add the logic to page 2 and fields in page 1
        
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: textFieldID,
                                                     conditionType: .equals,
                                                     value: .string("Hello"))
        let conditionTestModel2 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              customePageID: page2ID,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setTwoPageField(page1hidden: false, page2hidden: false)
            .setTextField(hidden: false, value: .string("Hello"))
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"))
            .setConditionalLogic(pageID: page2ID, logic: Logic(field: logicDictionary))
            
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(pageID: page2ID)
        
        XCTAssertEqual(result, false) // Page is hidden now
    }
    
    func testPageLogicFieldToNil() {
        let page2ID = "66600801dc1d8b4f72f54917" //we will add the logic to page 2 and fields in page 1
        
        // Set fieldID to nil
        let conditionTestModel1 = LogicConditionTest(fieldID: nil,
                                                     conditionType: .equals,
                                                     value: .string("Hello"))
        let conditionTestModel2 = LogicConditionTest(fieldID: nil,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              customePageID: page2ID,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setTwoPageField(page1hidden: false, page2hidden: false)
            .setTextField(hidden: false, value: .string("Hello"))
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"))
            .setConditionalLogic(pageID: page2ID, logic: Logic(field: logicDictionary))
            
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(pageID: page2ID)
        
        XCTAssertEqual(result, true) // Page is hidden now
    }
    
    func testPageOnORConditionLogic() {
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "66600801dc1d8b4f72f54917" //we will add the logic to page 2 and fields in page 1
        
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: textFieldID,
                                                     conditionType: .equals,
                                                     value: .string("Hello"))
        let conditionTestModel2 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              customePageID: page2ID,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .or)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setTwoPageField(page1hidden: false, page2hidden: false)
            .setTextField(hidden: false, value: .null)
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"))
            .setConditionalLogic(pageID: page2ID, logic: Logic(field: logicDictionary))
            
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(pageID: page2ID)
        
        XCTAssertEqual(result, false) // Page is hidden now
    }
    
    func testSetPageLogicToNil() {
        let page2ID = "66600801dc1d8b4f72f54917" //we will add the logic to page 2 and fields in page 1
        
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: textFieldID,
                                                     conditionType: .equals,
                                                     value: .string("Hello"))
        let conditionTestModel2 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setTwoPageField(page1hidden: false, page2hidden: false)
            .setTextField(hidden: false, value: .null)
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"))
             // Set Page logic to nil
            .setConditionalLogic(pageID: page2ID, logic: nil)
            
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(pageID: page2ID)
        
        XCTAssertEqual(result, true) // Page is hidden now
    }
    
    func testPageIDToNil() {
        // Set PageID to Nil
        let page2ID = "66600801dc1d8b4f72f54917" //we will add the logic to page 2 and fields in page 1
        
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: textFieldID,
                                                     conditionType: .equals,
                                                     value: .string("Hello"))
        let conditionTestModel2 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: false,
                                                              customePageID: page2ID,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .or)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setTwoPageField(page1hidden: false, page2hidden: false)
            .setTextField(hidden: false, value: .null)
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"))
            .setConditionalLogic(pageID: page2ID, logic: Logic(field: logicDictionary))
            
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(pageID: nil)
        
        XCTAssertEqual(result, true) // Page is hidden now
    }
    
    // Fields needs to be refreshed
    func testFieldsNeedsToRefresh() {
        //Text Field should Show when both dropdown is yes and multiselect is yes
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .equals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: true,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello")) // Hidden at first
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1")) // Yes selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa1ff43cf15d159310"]), multi: true) // Yes selected
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [textFieldID : .text, dropdownFieldID : .dropdown, multiSelectFieldID: .multiSelect])
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
        let fieldIdentifier = FieldIdentifier(fieldID: dropdownFieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("677e2bfa152e9f549edf0813"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
    }
    
    func testFieldsNeedsToRefreshOnUnknownID() {
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let dropdownFieldID = "6781040987a55e48b4507a38"
        let multiSelectFieldID = "678104b387d3004e70120ac6"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: dropdownFieldID,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: multiSelectFieldID,
                                                     conditionType: .equals,
                                                     value: .array(["677e2bfa1ff43cf15d159310"]))
        
        let logicDictionary = getTwoConditionsLogicDictionary(isShow: true,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField(hidden: true, value: .string("Hello")) // Hidden at first
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1")) // Yes selected
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa1ff43cf15d159310"]), multi: true) // Yes selected
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [textFieldID : .text, dropdownFieldID : .dropdown, multiSelectFieldID: .multiSelect])
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, true)
        let fieldIdentifier = FieldIdentifier(fieldID: "unknown field id")
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("677e2bfa152e9f549edf0813"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
    }
    
    func testTextFieldAllCondition() {
        //Text Field should hide when all condition is true
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let textFieldID2 = "6629fb1d92a76d06750ca4a1"
        
        let conditionTestModel1 = LogicConditionTest(fieldID: textFieldID2,
                                                     conditionType: .equals,
                                                     value: .string("Hello sir"))
        let conditionTestModel2 = LogicConditionTest(fieldID: textFieldID2,
                                                     conditionType: .isNotNull, value: .null)
        let conditionTestModel3 = LogicConditionTest(fieldID: textFieldID2,
                                                     conditionType: .contains, value: .string("llo"))
        let conditionTestModel4 = LogicConditionTest(fieldID: textFieldID2,
                                                     conditionType: .notEquals, value: .string("world"))
        let conditionTestModel5 = LogicConditionTest(fieldID: textFieldID,
                                                     conditionType: .isNull, value: .null)
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4, conditionTestModel5],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField()
            .setTextField(hidden: false, value: .string(""))
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [textFieldID : .text, textFieldID2 : .text])
            .setConditionalLogicToField(fieldID: textFieldID, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: textFieldID)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: textFieldID2)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("Hello World"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: textFieldID)
        XCTAssertEqual(resultShow, true)
    }
    
    func testTextAreaFieldAllCondition() {
        //Textarea Field should hide when all condition is true
        let firstMultiline = "6629fb2b9a487ce1c1f35f2c"
        let secondMultiline = "6629fb2b9a487ce1c1f35f3c"
        let hiddenMultiline = "6629fb2b9a487ce1c1f35f4c"
        let conditionTestModel1 = LogicConditionTest(fieldID: firstMultiline,
                                                     conditionType: .equals,
                                                     value: .string("Hide"))
        let conditionTestModel2 = LogicConditionTest(fieldID: firstMultiline,
                                                     conditionType: .isNotNull, value: .string(""))
        let conditionTestModel3 = LogicConditionTest(fieldID: firstMultiline,
                                                     conditionType: .contains, value: .string("id"))
        let conditionTestModel4 = LogicConditionTest(fieldID: firstMultiline,
                                                     conditionType: .notEquals, value: .string("world"))
        let conditionTestModel5 = LogicConditionTest(fieldID: secondMultiline,
                                                     conditionType: .isNull, value: .string(""))
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4, conditionTestModel5],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultilineTextField(hidden: false, value: .string("Hide"), id: "6629fb2b9a487ce1c1f35f2c")
            .setMultilineTextField(hidden: false, value: .string(""), id: "6629fb2b9a487ce1c1f35f3c")
            .setMultilineTextField(hidden: false, value: .string(""), id: "6629fb2b9a487ce1c1f35f4c")
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [firstMultiline : .textarea, secondMultiline : .textarea, hiddenMultiline : .textarea])
            .setConditionalLogicToField(fieldID: hiddenMultiline, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: hiddenMultiline)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: firstMultiline)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("World"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: hiddenMultiline)
        XCTAssertEqual(resultShow, true)
    }
    
    func testNumberFieldAllCondition() {
        //Number Field should hide when all condition is true
        let firstNumber = "6629fb2b9a487ce1c1f35f2c"
        let secondNumber = "6629fb2b9a487ce1c1f35f3c"
        let hiddenNumber = "6629fb2b9a487ce1c1f35f4c"
        let conditionTestModel1 = LogicConditionTest(fieldID: firstNumber,
                                                     conditionType: .equals,
                                                     value: .double(123))
        let conditionTestModel2 = LogicConditionTest(fieldID: firstNumber,
                                                     conditionType: .isNotNull, value: .null)
        let conditionTestModel3 = LogicConditionTest(fieldID: firstNumber,
                                                     conditionType: .greaterThan, value: .double(10))
        let conditionTestModel4 = LogicConditionTest(fieldID: firstNumber,
                                                     conditionType: .notEquals, value: .double(567))
        let conditionTestModel5 = LogicConditionTest(fieldID: firstNumber,
                                                     conditionType: .lessThan, value: .double(200))
        let conditionTestModel6 = LogicConditionTest(fieldID: secondNumber,
                                                     conditionType: .isNull, value: .null)
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4, conditionTestModel5, conditionTestModel6],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setNumberField(hidden: false, value: .double(123), id: "6629fb2b9a487ce1c1f35f2c")
            .setNumberField(hidden: false, value: .null, id: "6629fb2b9a487ce1c1f35f3c")
            .setNumberField(hidden: false, value: .double(0), id: "6629fb2b9a487ce1c1f35f4c")
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [firstNumber : .number, secondNumber : .number, hiddenNumber : .number])
            .setConditionalLogicToField(fieldID: hiddenNumber, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: hiddenNumber)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: firstNumber)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .double(567))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: hiddenNumber)
        XCTAssertEqual(resultShow, true)
    }
    
    func testDropdownFieldAllCondition() {
        //Dropdown should hide when all condition is true
        let firstDropdown = "6629fb2b9a487ce1c1f35f2c"
        let secondDropdown = "6629fb2b9a487ce1c1f35f3c"
        let hiddenDropdown = "6629fb2b9a487ce1c1f35f4c"
        let conditionTestModel1 = LogicConditionTest(fieldID: firstDropdown,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfab0d5dce4162c36c1"))
        let conditionTestModel2 = LogicConditionTest(fieldID: firstDropdown,
                                                     conditionType: .isNotNull, value: .null)
        let conditionTestModel3 = LogicConditionTest(fieldID: firstDropdown,
                                                     conditionType: .notEquals, value: .string("677e2bfaf81647d2f6a016a0"))
        let conditionTestModel4 = LogicConditionTest(fieldID: secondDropdown,
                                                     conditionType: .isNull, value: .null)
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"), id: "6629fb2b9a487ce1c1f35f2c")
            .setDropdownField(hidden: false, value: .null, id: "6629fb2b9a487ce1c1f35f3c")
            .setDropdownField(hidden: false, value: .string("677e2bfa0f4ed64ef5055bcf"), id: "6629fb2b9a487ce1c1f35f4c")
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [firstDropdown : .dropdown, secondDropdown : .dropdown, hiddenDropdown : .dropdown])
            .setConditionalLogicToField(fieldID: hiddenDropdown, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: hiddenDropdown)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: firstDropdown)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("677e2bfaf81647d2f6a016a0"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: hiddenDropdown)
        XCTAssertEqual(resultShow, true)
    }
    
    func testDropdownFieldAnyCondition() {
        //Dropdown should hide when any condition is true
        let firstDropdown = "6629fb2b9a487ce1c1f35f2c"
        let secondDropdown = "6629fb2b9a487ce1c1f35f3c"
        let thirdDropdown = "6629fb2b9a487ce1c1f35f5c"
        let fourthDropdown = "6629fb2b9a487ce1c1f35f6c"
        let hiddenDropdown = "6629fb2b9a487ce1c1f35f4c"
        let conditionTestModel1 = LogicConditionTest(fieldID: firstDropdown,
                                                     conditionType: .equals,
                                                     value: .string("677e2bfa0f4ed64ef5055bcf"))
        let conditionTestModel2 = LogicConditionTest(fieldID: secondDropdown,
                                                     conditionType: .isNotNull, value: .null)
        let conditionTestModel3 = LogicConditionTest(fieldID: thirdDropdown,
                                                     conditionType: .notEquals, value: .string("677e2bfaf81647d2f6a016a0"))
        let conditionTestModel4 = LogicConditionTest(fieldID: fourthDropdown,
                                                     conditionType: .isNull, value: .null)
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4],
                                                              evaluationType: .or)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setDropdownField(hidden: false, value: .string("677e2bfab0d5dce4162c36c1"), id: "6629fb2b9a487ce1c1f35f2c")
            .setDropdownField(hidden: false, value: .null, id: "6629fb2b9a487ce1c1f35f3c")
            .setDropdownField(hidden: false, value: .string("677e2bfaf81647d2f6a016a0"), id: "6629fb2b9a487ce1c1f35f5c")
            .setDropdownField(hidden: false, value: .null, id: "6629fb2b9a487ce1c1f35f6c")
            .setDropdownField(hidden: false, value: .string("677e2bfa0f4ed64ef5055bcf"), id: "6629fb2b9a487ce1c1f35f4c")
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [firstDropdown : .dropdown, secondDropdown : .dropdown, thirdDropdown : .dropdown, fourthDropdown : .dropdown, hiddenDropdown : .dropdown])
            .setConditionalLogicToField(fieldID: hiddenDropdown, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: hiddenDropdown)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: fourthDropdown)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("677e2bfa0f4ed64ef5055bcf"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: hiddenDropdown)
        XCTAssertEqual(resultShow, true)
    }
    
    func testMultiSelectFieldAllCondition() {
        //Multiselect should hide when all condition is true
        let firstMultiSelect = "6629fb2b9a487ce1c1f35f2c"
        let secondMultiSelect = "6629fb2b9a487ce1c1f35f3c"
        let hiddenMultiSelect = "6629fb2b9a487ce1c1f35f4c"
        let conditionTestModel1 = LogicConditionTest(fieldID: firstMultiSelect,
                                                     conditionType: .equals,
                                                     value: .array(["677e2bfa9c5249a2acd3644f"]))
        let conditionTestModel2 = LogicConditionTest(fieldID: firstMultiSelect,
                                                     conditionType: .isNotNull, value: .null)
        let conditionTestModel3 = LogicConditionTest(fieldID: firstMultiSelect,
                                                     conditionType: .notEquals, value: .array(["677e2bfa1ff43cf15d159310"]))
        let conditionTestModel4 = LogicConditionTest(fieldID: secondMultiSelect,
                                                     conditionType: .isNull, value: .null)
        
        let logicDictionary = getDynamicLogicDictionary(isShow: false,
                                                              logicConditionTests: [conditionTestModel1, conditionTestModel2, conditionTestModel3, conditionTestModel4],
                                                              evaluationType: .and)
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa9c5249a2acd3644f"]), multi: true, id: "6629fb2b9a487ce1c1f35f2c")
            .setMultiSelectField(hidden: false, value: .null, multi: true, id: "6629fb2b9a487ce1c1f35f3c")
            .setMultiSelectField(hidden: false, value: .array(["677e2bfa1ff43cf15d159310"]), multi: true, id: "6629fb2b9a487ce1c1f35f4c")
            .setFieldPositionToPage(pageId: pageID,
                                    idAndTypes: [firstMultiSelect : .multiSelect, secondMultiSelect : .multiSelect, hiddenMultiSelect : .multiSelect])
            .setConditionalLogicToField(fieldID: hiddenMultiSelect, logic: Logic(field: logicDictionary))
        
        let documentEditor = documentEditor(document: document)
        let result = documentEditor.shouldShow(fieldID: hiddenMultiSelect)
        
        XCTAssertEqual(result, false)
        let fieldIdentifier = FieldIdentifier(fieldID: firstMultiSelect)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: .string("677e2bfa1ff43cf15d159310"))
        documentEditor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        
        let resultShow = documentEditor.shouldShow(fieldID: hiddenMultiSelect)
        XCTAssertEqual(resultShow, true)
    }
    
    
    //Empty conditions
    func getEmptyConditionsLogicDictionary(isShow: Bool, fieldID: String, conditionType: ConditionType) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": "and",
            "_id": "66aa2a7c4bbc669133bad220"
        ]
    }

    func getLogicDictionary(isShow: Bool, fieldID: String? = nil, conditionType: ConditionType, value: ValueUnion) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": "and",
            "conditions": [
                [
                    "file": fileID,
                    "page": pageID,
                    "field": fieldID,
                    "condition": conditionType.rawValue,
                    "value": value,
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
    }
    
    func getTwoConditionsLogicDictionary(isShow: Bool,customePageID: String? = nil, logicConditionTests: [LogicConditionTest], evaluationType: EvaluationType) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": evaluationType.rawValue,
            "conditions": [
                [
                    "file": fileID,
                    "page": customePageID ?? pageID,
                    "field": logicConditionTests[0].fieldID,
                    "condition": logicConditionTests[0].conditionType.rawValue,
                    "value": logicConditionTests[0].value,
                    "_id": "66aa2a7c4bbc669133bad221"
                ],
                [
                    "file": fileID,
                    "page": customePageID ?? pageID,
                    "field": logicConditionTests[1].fieldID,
                    "condition": logicConditionTests[1].conditionType.rawValue,
                    "value": logicConditionTests[1].value,
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
    }
    
    func getDynamicLogicDictionary(
        isShow: Bool,
        customPageID: String? = nil,
        logicConditionTests: [LogicConditionTest],
        evaluationType: EvaluationType
    ) -> [String: Any]? {
        guard !logicConditionTests.isEmpty else { return nil }

        let page = customPageID ?? pageID
        let conditions: [[String: Any]] = logicConditionTests.map { test in
            [
                "file": fileID,
                "page": page,
                "field": test.fieldID,
                "condition": test.conditionType.rawValue,
                "value": test.value,
                "_id": UUID().uuidString
            ]
        }

        return [
            "action": isShow ? "show" : "hide",
            "eval": evaluationType.rawValue,
            "conditions": conditions,
            "_id": UUID().uuidString
        ]
    }
}

struct LogicConditionTest {
    init(fieldID: String? = nil, conditionType: ConditionType, value: ValueUnion) {
        self.fieldID = fieldID
        self.conditionType = conditionType
        self.value = value
    }
    let fieldID: String?
    let conditionType: ConditionType
    let value: ValueUnion
}

enum EvaluationType: String {
    case and = "and"
    case or = "or"
}
enum ConditionType: String {
    case equals = "="
    case notEquals = "!="
    case contains = "?="
    case greaterThan = ">"
    case lessThan = "<"
    case isNull = "null="
    case isNotNull = "*="
    case unKnown = "notCase" // for defalut case
}
