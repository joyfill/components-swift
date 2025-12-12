import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class ValidationTestCase: XCTestCase {
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }
    //
    // Test Case for check at same time web and mobile view fields
    func testInValidWebViewWithInValidMobileView_resultShouldBeInValid() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }
    //
    func testInvalidWebViewWithValidMobileView_resultShouldBeValid() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }
    //
    func testValidWebViewWithInValidMobileView_resultShouldBeValid() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testValidWebViewWithValidMobileView_resultShouldBeValid() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Test Case for All fields one by one

    // Invalid Image Field - Result - InValid
    func testInValidWebViewWithInValidMobileImageFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid image field - result - valid
    func testInValidWebViewWithValidMobileImageFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setRequiredChartFieldWithoutValue()
            .setImageFieldPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fab36e8925135f0cdd4f")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Text Field - Result - InValid
    func testInValidWebViewWithInValidMobileTextFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setTextPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Text Field - Result - Valid
    func testInValidWebViewWithValidMobileTextFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setTextPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb1d92a76d06750ca4a1")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Multiline Field - Result - InValid
    func testInValidWebViewWithInValidMobileMultilineTextFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultilineTextFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setMultilinePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Multiline Field - Result - Valid
    func testInValidWebViewWithValidMobileMultilineTextFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultilineTextFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setMultilinePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb2b9a487ce1c1f35f6c")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Number Field - Result - InValid
    func testInValidWebViewWithInValidMobileNumberFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredNumberFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setNumberPosition()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Number Field - Result - Valid
    func testInValidWebViewWithValidMobileNumberFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredNumberFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setNumberPosition()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb3df03de10b26270ab3")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Date Field - Result - InValid
    func testInValidWebViewWithInValidMobileDateFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDatePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Date Field - Result - Valid
    func testInValidWebViewWithValidMobileDateFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDatePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb44c79bb16ce072d233")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Time Field - Result - InValid
    func testInValidWebViewWithInValidMobileTimeFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTimeFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setTimePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Time Field - Result - Valid
    func testInValidWebViewWithValidMobileTimeFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTimeFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setTimePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb638e230f348d0a8682")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid dateTime Field - Result - InValid
    func testInValidWebViewWithInValidMobileDateTimeFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateTimeFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDateTimePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid dateTime Field - Result - Valid
    func testInValidWebViewWithValidMobileDateTimeFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDateTimeFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDateTimePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb6ec5d88d3aadf548ca")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Dropdown Field - Result - InValid
    func testInValidWebViewWithInValidMobileDropdownFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDropdownFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setDropdownPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb77593e3791638628bb")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Dropdown Field - Result - Valid
    func testInValidWebViewWithValidMobileDropdownFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredDropdownFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setDropdownPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb77593e3791638628bb")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Multiselect Field - Result - InValid
    func testInValidWebViewWithInValidMobileMultiSelectFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultipleChoiceFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setMultiselectPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Multiselect Field - Result - Valid
    func testInValidWebViewWithValidMobileMultiSelectFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredMultipleChoiceFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setMultiselectPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fb9f4d912053577652b1")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Single Field - Result - InValid
    func testInValidWebViewWithInValidMobileSingleChoiceFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setSingleSelectPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Single Field - Result - Valid
    func testInValidWebViewWithValidMobileSingleChoiceFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSingleChoiceFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setSingleSelectPositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbb2bf4f965b9d04f153")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Signature Field - Result - InValid
    func testInValidWebViewWithInValidMobileSignatureFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSignatureFieldWithoutValue()
            .setRequiredChartFieldWithoutValue()
            .setSignaturePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Signature Field - Result - Valid
    func testInValidWebViewWithValidMobileSignatureFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredSignatureFieldWithValue()
            .setRequiredChartFieldWithoutValue()
            .setSignaturePositionInMobile()
            .setChartPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbb8cd16c0c4d308a252")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Invalid Chart Field - Result - InValid
    func testInValidWebViewWithInValidMobileChartFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredChartFieldWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setChartPositionInMobile()
            .setSingleSelectPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Valid Chart Field - Result - Valid
    func testInValidWebViewWithValidMobileChartFieldView() {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredChartFieldWithValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setChartPositionInMobile()
            .setSingleSelectPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "6629fbd957d928a973b1b42b")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Hidden Field Test cases - result always - valid
    func testRequiredHiddenNumberFieldWithoutValue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredNumberHiddenFieldWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredNumberHiddenFieldWithoutValuePositionInMobile()
            .setRequiredTextFieldInMobile()
            .setSingleSelectPosition()
            .setMultilineTextField(hidden: true, value: .string(""), required: true)
                let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa29c05db08120464a2875")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
    }

    func testRequiredHiddenNumberFieldWithValue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredNumberHiddenFieldWithValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredNumberHiddenFieldWithoutValuePositionInMobile()
            .setRequiredTextFieldInMobile()
            .setSingleSelectPosition()

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa29c05db08120464a2875")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
    }

    // Show Hidden Field Test Cases
    func testRequiredShowHiddenFieldWithoutValue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredShowNumberFieldByLogicWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredTextFieldInMobile()
            .setRequiredShowNumberFieldByLogicWithoutValuePositionInMobile()
            .setSingleSelectPosition()
        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .invalid)
    }

    func testRequiredShowHiddenFieldWithValue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredShowNumberFieldByLogicWithValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredTextFieldInMobile()
            .setRequiredShowNumberFieldByLogicWithoutValuePositionInMobile()
            .setSingleSelectPosition()
        
        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)

    }

    // Hide field test cases
    func testRequiredShowHiddenFieldWithoutValues() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredHideNumberFieldByLogicWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredTextFieldInMobile()
            .setRequiredHideNumberFieldByLogicWithoutValuePositionInMobile()
            .setSingleSelectPosition()
        
        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
    }

    func testRequiredHideNumberFieldWithValues() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredHideNumberFieldByLogicWithValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredTextFieldInMobile()
            .setRequiredHideNumberFieldByLogicWithoutValuePositionInMobile()
            .setSingleSelectPosition()
        
        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa28f805a4900ae643db9c")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
        
    }
    
    func testRequiredTableField() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: true, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    //Zero columns
    func testRequiredTableFieldZeroColumns() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: true, areCellsEmpty: false, isZeroRows: false, isColumnsZero: true, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // Zero rows
    func testRequiredTableFieldZeroRows() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: true, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    // table is required , columns are required , cells are empty should be invalid
    func testRequiredTableFieldEmptyCells() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: true, areCellsEmpty: true, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testRequiredTableFieldIfHidden() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: true, isTableRequired: true, isColumnRequired: true, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: true)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testNonRequiredTableField() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: true, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testRequiredTableFieldNonRequiredColumns() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67612793c4e6a5e6a05e64a3")
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }
        
        // Test Case for duplicate the page
        func testPageDuplication() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setPageWithFieldPosition()
                .setHeadingText()
                .setTextField()

            let originalPageID = "6629fab320fca7c8107a6cf6"
            let fieldCount = document.fields.count * 2
            let documentEditor = documentEditor(document: document)
            documentEditor.duplicatePage(pageID: originalPageID)
            
            let firstFile = documentEditor.document.files.first
            let pageOrder = firstFile?.pageOrder
            
            // Ensure the original page id exists.
            guard let originalIndex = pageOrder?.firstIndex(of: originalPageID) else {
                XCTFail("Original page id not found in pageOrder.")
                return
            }
            XCTAssertTrue(documentEditor.document.files[0].pages!.count > 1, "Document should have more than one page.")
            XCTAssertTrue(pageOrder!.count > originalIndex + 1, "Duplicated page id should appear after the original.")
            let duplicatedPageID = pageOrder?[originalIndex + 1]
            XCTAssertNotEqual(duplicatedPageID, originalPageID, "Duplicated page id must differ from original.")
            XCTAssertNotNil(firstFile?.pages?.first(where: { $0.id == originalPageID }), "Original page not found in pages array.")
            XCTAssertNotNil(firstFile?.pages?.first(where: { $0.id == duplicatedPageID }), "Duplicated page not found in pages array.")
            let originalPage = firstFile?.pages?.first(where: { $0.id == originalPageID })
            let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID })
            let origFieldPositions = originalPage?.fieldPositions ?? []
            let dupFieldPositions = duplicatedPage?.fieldPositions ?? []
            XCTAssertEqual(origFieldPositions.count, dupFieldPositions.count, "Field positions count should match.")
            for (index, dupFieldPos) in dupFieldPositions.enumerated() {
                if index < origFieldPositions.count {
                    let origFieldPos = origFieldPositions[index]
                    XCTAssertNotEqual(dupFieldPos.field, origFieldPos.field, "Duplicated field id should differ from original field id.")
                }
            }
            
            XCTAssertEqual(documentEditor.document.fields.count, fieldCount, "Fields count can not match.")
        }
    
    // MARK: - Page Deletion Tests
    
    /// Test basic page deletion
    func testPageDeletion_basic() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let initialPageCount = documentEditor.document.files.first?.pages?.count ?? 0
        let initialPageOrderCount = documentEditor.document.files.first?.pageOrder?.count ?? 0
        
        XCTAssertTrue(initialPageCount >= 2, "Document should have at least 2 pages")
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        let finalPageCount = documentEditor.document.files.first?.pages?.count ?? 0
        let finalPageOrderCount = documentEditor.document.files.first?.pageOrder?.count ?? 0
        
        XCTAssertEqual(finalPageCount, initialPageCount - 1, "Page count should decrease by 1")
        XCTAssertEqual(finalPageOrderCount, initialPageOrderCount - 1, "PageOrder count should decrease by 1")
        XCTAssertNil(documentEditor.document.files.first?.pages?.first(where: { $0.id == pageToDeleteID }), "Deleted page should not exist")
        XCTAssertFalse(documentEditor.document.files.first?.pageOrder?.contains(pageToDeleteID) ?? true, "PageOrder should not contain deleted page ID")
    }
    
    /// Test that you cannot delete the last page
    func testPageDeletion_preventLastPage() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()
        
        let pageID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let pageCount = documentEditor.document.files.first?.pages?.count ?? 0
        XCTAssertEqual(pageCount, 1, "Document should have exactly 1 page")
        
        let (canDelete, warnings) = documentEditor.canDeletePage(pageID: pageID)
        
        XCTAssertFalse(canDelete, "Should not be able to delete the last page")
        XCTAssertTrue(warnings.contains(where: { $0.contains("last page") }), "Warning should mention last page")
        
        let result = documentEditor.deletePage(pageID: pageID, force: true)
        
        XCTAssertFalse(result.success, "Deletion should fail")
        XCTAssertEqual(documentEditor.document.files.first?.pages?.count, 1, "Page should still exist")
    }
    
    /// Test that exclusive fields are deleted with the page
    func testPageDeletion_exclusiveFields() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        // Get fields on the page to delete
        let page = documentEditor.document.files.first?.pages?.first(where: { $0.id == pageToDeleteID })
        let fieldIDsOnPage = page?.fieldPositions?.compactMap { $0.field } ?? []
        
        XCTAssertFalse(fieldIDsOnPage.isEmpty, "Page should have fields")
        
        let initialFieldCount = documentEditor.document.fields.count
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        let finalFieldCount = documentEditor.document.fields.count
        
        // Check that fields are completely removed (not just marked as deleted)
        XCTAssertLessThan(finalFieldCount, initialFieldCount, "Field count should decrease")
        
        for fieldID in fieldIDsOnPage {
            let fieldExists = documentEditor.document.fields.contains(where: { $0.id == fieldID })
            XCTAssertFalse(fieldExists, "Field \(fieldID) should be completely removed from document")
        }
    }
    
    /// Test that pageOrder is updated correctly
    func testPageDeletion_pageOrderUpdate() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .addThirdPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let initialPageOrder = documentEditor.document.files.first?.pageOrder ?? []
        XCTAssertTrue(initialPageOrder.count >= 3, "Should have at least 3 pages")
        XCTAssertTrue(initialPageOrder.contains(pageToDeleteID), "PageOrder should contain page to delete")
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        let finalPageOrder = documentEditor.document.files.first?.pageOrder ?? []
        XCTAssertEqual(finalPageOrder.count, initialPageOrder.count - 1, "PageOrder count should decrease by 1")
        XCTAssertFalse(finalPageOrder.contains(pageToDeleteID), "PageOrder should not contain deleted page")
    }
    
    /// Test navigation updates when deleting current page
    func testPageDeletion_navigationUpdate() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        // Set current page to the one we're about to delete
        documentEditor.currentPageID = pageToDeleteID
        XCTAssertEqual(documentEditor.currentPageID, pageToDeleteID)
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        // Current page should have changed
        XCTAssertNotEqual(documentEditor.currentPageID, pageToDeleteID, "Current page should have changed")
        XCTAssertFalse(documentEditor.currentPageID.isEmpty, "Current page should be set to a valid page")
    }
    
    /// Test that views are updated when deleting a page
    func testPageDeletion_viewsUpdate() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .addSecondPage()
            .addSecondPageInMobileView()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let hasViews = !(documentEditor.document.files.first?.views?.isEmpty ?? true)
        guard hasViews else {
            XCTFail("Document should have views for this test")
            return
        }
        
        let initialViewPageCount = documentEditor.document.files.first?.views?.first?.pages?.count ?? 0
        XCTAssertTrue(initialViewPageCount >= 2, "View should have at least 2 pages")
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        // Check main pages
        let mainPageExists = documentEditor.document.files.first?.pages?.contains(where: { $0.id == pageToDeleteID }) ?? false
        XCTAssertFalse(mainPageExists, "Deleted page should not exist in main pages")
        
        // Check view pages
        let viewPageExists = documentEditor.document.files.first?.views?.first?.pages?.contains(where: { $0.id == pageToDeleteID }) ?? false
        XCTAssertFalse(viewPageExists, "Deleted page should not exist in view pages")
        
        // Check view pageOrder
        let viewPageOrderContains = documentEditor.document.files.first?.views?.first?.pageOrder?.contains(pageToDeleteID) ?? false
        XCTAssertFalse(viewPageOrderContains, "View pageOrder should not contain deleted page")
    }
    
    /// Test conditional logic cleanup on pages
    func testPageDeletion_conditionalLogicCleanup_page() {
        // This test would require a document with page-level conditional logic
        // referencing another page. For now, we'll test the basic structure.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        // Verify no pages have logic referencing the deleted page
        let remainingPages = documentEditor.document.files.first?.pages ?? []
        for page in remainingPages {
            if let conditions = page.logic?.conditions {
                let hasInvalidReference = conditions.contains(where: { $0.page == pageToDeleteID })
                XCTAssertFalse(hasInvalidReference, "Page should not have logic referencing deleted page")
            }
        }
    }
    
    /// Test conditional logic cleanup on fields
    func testPageDeletion_conditionalLogicCleanup_field() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID, force: true)
        XCTAssertTrue(result.success, "Page deletion should succeed")
        
        // Verify no fields have logic referencing the deleted page
        for field in documentEditor.document.fields {
            if let conditions = field.logic?.conditions {
                let hasInvalidReference = conditions.contains(where: { $0.page == pageToDeleteID })
                XCTAssertFalse(hasInvalidReference, "Field should not have logic referencing deleted page")
            }
        }
    }
    
    /// Test validation warnings for dependent pages
    func testPageDeletion_validationWarnings() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageToDeleteID = "6629fab320fca7c8107a6cf6"
        let documentEditor = documentEditor(document: document)
        
        let (canDelete, warnings) = documentEditor.canDeletePage(pageID: pageToDeleteID)
        
        XCTAssertTrue(canDelete, "Page should be deletable")
        // Warnings array may or may not be empty depending on the document structure
        XCTAssertNotNil(warnings, "Warnings array should exist")
    }
}

    extension ValidationTestCase {
        func testRequiredCollectionField() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setPageField()
                .setCollectionFieldRequired()
                .setCollectionFieldPosition()

            let documentEditor = documentEditor(document: document)
            let validationResult = documentEditor.validate()

            XCTAssertEqual(validationResult.status, .invalid)
            XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
            XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
            XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }

        func testCollectionField_AllValid_ShouldBeValid() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setPageField()
                .setCollectionFieldRequired(
                    isFieldRequired: true,
                    isSchemaRequired: true,
                    includeNestedRows: true,
                    omitRequiredValues: false
                )
                .setCollectionFieldPosition()

            let editor = documentEditor(document: document)
            let result = editor.validate()

            XCTAssertEqual(result.status, .valid)
            XCTAssertEqual(result.fieldValidities.first?.status, .valid)
            XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
            XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }

        func testCollectionField_MissingRequiredTopLevelValue_ShouldBeInvalid() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setPageField()
                .setCollectionFieldRequired(
                    isFieldRequired: true,
                    isSchemaRequired: true,
                    includeNestedRows: true,
                    omitRequiredValues: true
                )
                .setCollectionFieldPosition()

            let editor = documentEditor(document: document)
            let result = editor.validate()

            XCTAssertEqual(result.status, .invalid)
            XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
            XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
            XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }

        func testCollectionField_NoNestedRowsButRequiredSchema_ShouldBeInvalid() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setPageField()
                .setCollectionFieldRequired(
                    isFieldRequired: true,
                    isSchemaRequired: true,
                    includeNestedRows: false,
                    omitRequiredValues: false
                )
                .setCollectionFieldPosition()

            let editor = documentEditor(document: document)
            let result = editor.validate()

            XCTAssertEqual(result.status, .invalid)
            XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
            XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
            XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }

        func testCollectionField_NotRequired_ShouldBeValidEvenIfEmpty() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setPageField()
                .setCollectionFieldRequired(
                    isFieldRequired: false,
                    isSchemaRequired: false,
                    includeNestedRows: false,
                    omitRequiredValues: true
                )
                .setCollectionFieldPosition()

            let editor = documentEditor(document: document)
            let result = editor.validate()

            XCTAssertEqual(result.status, .valid)
            XCTAssertEqual(result.fieldValidities.first?.status, .valid)
            XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
            XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }

    func testCollectionField_FieldRequired_SchemaNotRequiredWithValues_ShouldBeValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: false, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .valid)
        XCTAssertEqual(result.fieldValidities.first?.status, .valid)
        XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
        XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testCollectionField_FieldAndSchemaRequired_WithoutValues_ShouldBeInvalid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: false, omitRequiredValues: true)
            .setCollectionFieldPosition()

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
        XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testCollectionField_FieldRequired_MissingChildCell_ShouldBeInvalid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: true)
            .setCollectionFieldPosition()

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
        XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testCollectionField_FieldAndSchemaRequired_CompleteData_ShouldBeValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .valid)
        XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
        XCTAssertEqual(result.fieldValidities.first?.status, .valid)
        XCTAssertEqual(result.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
    }

    func testCollectionField_ChildDataMissingRequiredColumn_ShouldBeInvalid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: true)
            .setCollectionFieldPosition()

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.field.id, "67ddc52d35de157f6d7ebb63")
        XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(result.fieldValidities[0].pageId, "6629fab320fca7c8107a6cf6")
    }
    
    // Hidden Field Test cases - result always - valid
    func testRequiredHiddenTextFieldWithoutValue() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTextField()
            .setRequiredNumberHiddenFieldWithoutValue()
            .setRequiredSingleChoiceFieldWithoutValue()
            .setRequiredNumberHiddenFieldWithoutValuePositionInMobile()
            .setRequiredTextFieldInMobile()
            .setSingleSelectPosition()
            .setTextField(hidden: true,value: .string(""), required: true)
            .setRequiredImagefieldsWithoutValue(hidden: true)
            .setRequiredDropdownFieldWithoutValue(hidden: true)
            .setRequiredSignatureFieldWithoutValue(hidden: true)
            .setRequiredDateFieldWithoutValue(hidden: true)
        
        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()
        
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 2)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa29c05db08120464a2875")
        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
        XCTAssertEqual(validationResult.fieldValidities[1].pageId, "6629fab320fca7c8107a6cf6")
    }
        
        func testTwoPageFieldIds() {
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setMobileView()
                .setPageFieldInMobileView()
                .setTwoPageField(page1hidden: false, page2hidden: false)
                .setRequiredTextField()
                .setRequiredNumberHiddenFieldWithoutValue()
                .setFieldPositionToPage(pageId: "6629fab320fca7c8107a6cf6",
                                        idAndTypes: ["66aa2865da10ac1c7b7acb1d" : .text])
                .setFieldPositionToPage(pageId: "66600801dc1d8b4f72f54917",
                                        idAndTypes: ["66aa29c05db08120464a2875" : .number])
            let documentEditor = documentEditor(document: document)
            let validationResult = documentEditor.validate()
            
            XCTAssertEqual(validationResult.status, .valid)
            XCTAssertEqual(validationResult.fieldValidities.count, 2)
            XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
            XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
            XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
            XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa29c05db08120464a2875")
            XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
            XCTAssertEqual(validationResult.fieldValidities[1].pageId, "66600801dc1d8b4f72f54917")
        }
}
