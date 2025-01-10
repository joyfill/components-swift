import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class ConditionLogicUnitTests: XCTestCase {
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document)
    }
        
    func testTextFieldShowOnNumber() {
        //Text Field should show when number is 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: true, fieldID: numberFieldID, conditionType: .equals)
        
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
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .equals)
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
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .greaterThan)
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
    
    func testTextFieldHideOnLessNumber() {
        //Text Field should hide when number is less than 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .lessThan)
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
    
    func testTextFieldHideOnNotEqualNumber() {
        //Text Field should hide when number is not equals 100
        let textFieldID = "66aa2865da10ac1c7b7acb1d"
        let numberFieldID = "6629fb3df03de10b26270ab3"
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .notEquals)
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
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNull)
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
        
        let logicDictionary = getLogicDictionary(isShow: false, fieldID: numberFieldID, conditionType: .isNotNull)
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

    func getLogicDictionary(isShow: Bool, fieldID: String, conditionType: ConditionType) -> [String: Any] {
        [
            "action": isShow ? "show" : "hide",
            "eval": "and",
            "conditions": [
                [
                    "file": fileID,
                    "page": pageID,
                    "field": fieldID,
                    "condition": conditionType.rawValue,
                    "value": ValueUnion.double(100),
                    "_id": "66aa2a7c4bbc669133bad221"
                ]
            ],
            "_id": "66aa2a7c4bbc669133bad220"
        ]
    }
}

enum ConditionType: String {
    case equals = "="
    case notEquals = "!="
    case contains = "?="
    case greaterThan = ">"
    case lessThan = "<"
    case isNull = "null="
    case isNotNull = "*="
}
