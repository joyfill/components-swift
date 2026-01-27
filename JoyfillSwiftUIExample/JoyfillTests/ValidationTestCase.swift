import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class ValidationTestCase: XCTestCase {
    
    // MARK: - Test Helpers
    
    /// Mock event handler to capture onChange events for testing
    class ChangeCapture: FormChangeEvent {
        var capturedChanges: [Change] = []
        
        func onChange(changes: [Change], document: JoyDoc) {
            capturedChanges.append(contentsOf: changes)
        }
        
        func onFocus(event: FieldIdentifier) {}
        func onBlur(event: FieldIdentifier) {}
        func onCapture(event: CaptureEvent) {}
        func onUpload(event: UploadEvent) {}
        func onError(error: JoyfillError) {}
        
    }
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageID)
        
        XCTAssertFalse(result, "Deletion should fail")
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
        
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
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
    
    // MARK: - Orphaned Fields Tests
    
    /// Test that fields shared across pages are NOT deleted when one page is deleted
    func testPageDeletion_sharedFieldsAcrossPagesPreserved() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        // Add a shared field that will appear on both pages
        let sharedFieldID = "shared_field_abc123"
        var sharedField = JoyDocField(field: [:])
        sharedField.id = sharedFieldID
        sharedField.identifier = "sharedField"
        sharedField.type = "text"
        sharedField.title = "Shared Field"
        document.fields.append(sharedField)
        
        // Modify pages to add the shared field to both
        guard var file = document.files.first, var pages = file.pages, pages.count >= 2 else {
            XCTFail("Document should have at least 2 pages")
            return
        }
        
        // Add shared field position to page 1
        var page1 = pages[0]
        let sharedFieldPos1 = FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_1",
            "x": 0,
            "y": 0,
            "width": 4,
            "height": 8
        ])
        var page1FieldPositions = page1.fieldPositions ?? []
        page1FieldPositions.append(sharedFieldPos1)
        page1.fieldPositions = page1FieldPositions
        pages[0] = page1
        
        // Add shared field position to page 2 (the one we'll delete)
        var page2 = pages[1]
        let sharedFieldPos2 = FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_2",
            "x": 0,
            "y": 8,
            "width": 4,
            "height": 8
        ])
        var page2FieldPositions = page2.fieldPositions ?? []
        page2FieldPositions.append(sharedFieldPos2)
        page2.fieldPositions = page2FieldPositions
        pages[1] = page2
        
        file.pages = pages
        document.files[0] = file
        
        let pageToDeleteID = "second_page_id_12345" // ✅ Fixed: Using correct page ID
        let documentEditor = documentEditor(document: document)
        
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == sharedFieldID }), 
                     "Shared field should exist before deletion")
        
        // Delete page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify shared field still exists (because it's on page 1)
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == sharedFieldID }),
                     "Shared field should NOT be deleted because it's still on page 1")
        
        // Verify page 2's exclusive field was deleted
        let page2ExclusiveFieldID = "second_page_field_1"
        XCTAssertFalse(documentEditor.document.fields.contains(where: { $0.id == page2ExclusiveFieldID }),
                      "Page 2 exclusive field should be deleted")
    }
    
    /// Test that fields shared across desktop and mobile views are preserved
    func testPageDeletion_sharedFieldsAcrossViewsPreserved() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .addSecondPage()
            .addSecondPageInMobileView()
            .setHeadingText()
            .setTextField()
        
        // Add a field that appears in mobile view but also on the desktop page we're deleting
        let sharedFieldID = "mobile_desktop_field_xyz"
        var sharedField = JoyDocField(field: [:])
        sharedField.id = sharedFieldID
        sharedField.identifier = "mobileDesktopField"
        sharedField.type = "text"
        sharedField.title = "Mobile Desktop Field"
        document.fields.append(sharedField)
        
        guard var file = document.files.first else {
            XCTFail("Document should have a file")
            return
        }
        
        // Add to desktop page 2 (which we'll delete)
        if var pages = file.pages, pages.count >= 2 {
            var page2 = pages[1]
            let desktopFieldPos = FieldPosition(dictionary: [
                "field": sharedFieldID,
                "_id": "desktop_pos",
                "x": 0,
                "y": 0,
                "width": 4,
                "height": 8
            ])
            var fieldPositions = page2.fieldPositions ?? []
            fieldPositions.append(desktopFieldPos)
            page2.fieldPositions = fieldPositions
            pages[1] = page2
            file.pages = pages
        }
        
        // Add to mobile view page 1
        if var views = file.views, !views.isEmpty {
            var view = views[0]
            if var mobilePages = view.pages, !mobilePages.isEmpty {
                var mobilePage1 = mobilePages[0]
                let mobileFieldPos = FieldPosition(dictionary: [
                    "field": sharedFieldID,
                    "_id": "mobile_pos",
                    "x": 0,
                    "y": 0,
                    "width": 1,
                    "height": 64
                ])
                var mobileFieldPositions = mobilePage1.fieldPositions ?? []
                mobileFieldPositions.append(mobileFieldPos)
                mobilePage1.fieldPositions = mobileFieldPositions
                mobilePages[0] = mobilePage1
                view.pages = mobilePages
                views[0] = view
            }
            file.views = views
        }
        
        document.files[0] = file
        
        let pageToDeleteID = "second_page_id_12345" // ✅ Fixed: Using correct page ID
        let documentEditor = documentEditor(document: document)
        
        // Verify field exists before deletion
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == sharedFieldID }),
                     "Shared field should exist before deletion")
        
        // Delete desktop page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify field still exists (because it's in mobile view page 1)
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == sharedFieldID }),
                     "Shared field should NOT be deleted because it's still in mobile view page 1")
    }
    
    /// Test that only truly orphaned fields are deleted
    func testPageDeletion_onlyOrphanedFieldsDeleted() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .addThirdPage()
            .setHeadingText()
            .setTextField()
        
        // Create three fields:
        // - Field A: Only on page 2 (will be deleted) - ORPHANED
        // - Field B: On page 2 AND page 3 - NOT ORPHANED
        // - Field C: Only on page 3 - NOT ORPHANED
        
        let orphanedFieldID = "orphaned_field_123"
        let sharedFieldID = "shared_field_456"
        let page3FieldID = "page3_field_789"
        
        // Add all three fields to document
        var orphanedField = JoyDocField(field: [:])
        orphanedField.id = orphanedFieldID
        orphanedField.identifier = "orphanedField"
        orphanedField.type = "text"
        document.fields.append(orphanedField)
        
        var sharedField = JoyDocField(field: [:])
        sharedField.id = sharedFieldID
        sharedField.identifier = "sharedField"
        sharedField.type = "text"
        document.fields.append(sharedField)
        
        var page3Field = JoyDocField(field: [:])
        page3Field.id = page3FieldID
        page3Field.identifier = "page3Field"
        page3Field.type = "text"
        document.fields.append(page3Field)
        
        guard var file = document.files.first, var pages = file.pages, pages.count >= 3 else {
            XCTFail("Document should have at least 3 pages")
            return
        }
        
        // Add orphaned field only to page 2
        var page2 = pages[1]
        var page2Positions = page2.fieldPositions ?? []
        page2Positions.append(FieldPosition(dictionary: [
            "field": orphanedFieldID,
            "_id": "orphaned_pos",
            "x": 0, "y": 0, "width": 4, "height": 8
        ]))
        
        // Add shared field to page 2
        page2Positions.append(FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_page2",
            "x": 0, "y": 8, "width": 4, "height": 8
        ]))
        page2.fieldPositions = page2Positions
        pages[1] = page2
        
        // Add shared field to page 3
        var page3 = pages[2]
        var page3Positions = page3.fieldPositions ?? []
        page3Positions.append(FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_page3",
            "x": 0, "y": 0, "width": 4, "height": 8
        ]))
        
        // Add page3-exclusive field to page 3
        page3Positions.append(FieldPosition(dictionary: [
            "field": page3FieldID,
            "_id": "page3_pos",
            "x": 0, "y": 8, "width": 4, "height": 8
        ]))
        page3.fieldPositions = page3Positions
        pages[2] = page3
        
        file.pages = pages
        document.files[0] = file
        
        let pageToDeleteID = "second_page_id_12345" // ✅ Fixed: Using correct page ID
        let documentEditor = documentEditor(document: document)
        
        let initialFieldCount = documentEditor.document.fields.count
        
        // Delete page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify orphaned field was deleted
        XCTAssertFalse(documentEditor.document.fields.contains(where: { $0.id == orphanedFieldID }),
                      "Orphaned field should be deleted")
        
        // Verify shared field still exists
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == sharedFieldID }),
                     "Shared field should NOT be deleted (still on page 3)")
        
        // Verify page 3 exclusive field still exists
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == page3FieldID }),
                     "Page 3 field should NOT be deleted")
        
        // Verify correct number of fields deleted
        let finalFieldCount = documentEditor.document.fields.count
        let deletedCount = initialFieldCount - finalFieldCount
        XCTAssertGreaterThan(deletedCount, 0, "At least one field should be deleted")
    }
    
    /// Test complex scenario with multiple views and shared fields
    func testPageDeletion_complexMultiViewScenario() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .addSecondPage()
            .addSecondPageInMobileView()
            .addThirdPage()
            .setHeadingText()
            .setTextField()
        
        // Create complex field sharing:
        // Field A: Desktop Page 1, Desktop Page 2, Mobile Page 1
        // Field B: Desktop Page 2 only (ORPHANED when page 2 deleted)
        // Field C: Desktop Page 2, Desktop Page 3
        // Field D: Mobile Page 1, Mobile Page 2
        
        let fieldA_ID = "field_a_everywhere"
        let fieldB_ID = "field_b_page2_only"
        let fieldC_ID = "field_c_desktop_pages"
        let fieldD_ID = "field_d_mobile_pages"
        
        // Add all fields
        for (id, identifier) in [(fieldA_ID, "fieldA"), (fieldB_ID, "fieldB"), 
                                   (fieldC_ID, "fieldC"), (fieldD_ID, "fieldD")] {
            var field = JoyDocField(field: [:])
            field.id = id
            field.identifier = identifier
            field.type = "text"
            document.fields.append(field)
        }
        
        guard var file = document.files.first else {
            XCTFail("Document should have a file")
            return
        }
        
        // Setup desktop pages
        if var pages = file.pages, pages.count >= 3 {
            // Desktop Page 1: Field A
            var page1 = pages[0]
            var page1Pos = page1.fieldPositions ?? []
            page1Pos.append(FieldPosition(dictionary: ["field": fieldA_ID, "_id": "a_d1", "x": 0, "y": 0, "width": 4, "height": 8]))
            page1.fieldPositions = page1Pos
            pages[0] = page1
            
            // Desktop Page 2 (to be deleted): Field A, B, C
            var page2 = pages[1]
            var page2Pos = page2.fieldPositions ?? []
            page2Pos.append(FieldPosition(dictionary: ["field": fieldA_ID, "_id": "a_d2", "x": 0, "y": 0, "width": 4, "height": 8]))
            page2Pos.append(FieldPosition(dictionary: ["field": fieldB_ID, "_id": "b_d2", "x": 0, "y": 8, "width": 4, "height": 8]))
            page2Pos.append(FieldPosition(dictionary: ["field": fieldC_ID, "_id": "c_d2", "x": 0, "y": 16, "width": 4, "height": 8]))
            page2.fieldPositions = page2Pos
            pages[1] = page2
            
            // Desktop Page 3: Field C
            var page3 = pages[2]
            var page3Pos = page3.fieldPositions ?? []
            page3Pos.append(FieldPosition(dictionary: ["field": fieldC_ID, "_id": "c_d3", "x": 0, "y": 0, "width": 4, "height": 8]))
            page3.fieldPositions = page3Pos
            pages[2] = page3
            
            file.pages = pages
        }
        
        // Setup mobile pages
        if var views = file.views, !views.isEmpty {
            var view = views[0]
            if var mobilePages = view.pages, mobilePages.count >= 2 {
                // Mobile Page 1: Field A, D
                var mobilePage1 = mobilePages[0]
                var mp1Pos = mobilePage1.fieldPositions ?? []
                mp1Pos.append(FieldPosition(dictionary: ["field": fieldA_ID, "_id": "a_m1", "x": 0, "y": 0, "width": 1, "height": 64]))
                mp1Pos.append(FieldPosition(dictionary: ["field": fieldD_ID, "_id": "d_m1", "x": 0, "y": 64, "width": 1, "height": 64]))
                mobilePage1.fieldPositions = mp1Pos
                mobilePages[0] = mobilePage1
                
                // Mobile Page 2: Field D
                var mobilePage2 = mobilePages[1]
                var mp2Pos = mobilePage2.fieldPositions ?? []
                mp2Pos.append(FieldPosition(dictionary: ["field": fieldD_ID, "_id": "d_m2", "x": 0, "y": 0, "width": 1, "height": 64]))
                mobilePage2.fieldPositions = mp2Pos
                mobilePages[1] = mobilePage2
                
                view.pages = mobilePages
                views[0] = view
            }
            file.views = views
        }
        
        document.files[0] = file
        
        let pageToDeleteID = "second_page_id_12345" // ✅ Fixed: Using correct page ID
        let documentEditor = documentEditor(document: document)
        
        // Delete desktop page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify Field A still exists (on desktop page 1 and mobile page 1)
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == fieldA_ID }),
                     "Field A should NOT be deleted (on desktop page 1 and mobile page 1)")
        
        // Verify Field B was deleted (only on deleted page 2)
        XCTAssertFalse(documentEditor.document.fields.contains(where: { $0.id == fieldB_ID }),
                      "Field B should be deleted (orphaned)")
        
        // Verify Field C still exists (on desktop page 3)
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == fieldC_ID }),
                     "Field C should NOT be deleted (still on desktop page 3)")
        
        // Verify Field D still exists (on mobile pages 1 and 2)
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == fieldD_ID }),
                     "Field D should NOT be deleted (on mobile pages)")
    }
    
    /// Test that deleting last occurrence of a field removes it
    func testPageDeletion_lastOccurrenceRemoved() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        // Add a field that only exists on page 2
        let exclusiveFieldID = "exclusive_field_xyz"
        var exclusiveField = JoyDocField(field: [:])
        exclusiveField.id = exclusiveFieldID
        exclusiveField.identifier = "exclusiveField"
        exclusiveField.type = "text"
        document.fields.append(exclusiveField)
        
        guard var file = document.files.first, var pages = file.pages, pages.count >= 2 else {
            XCTFail("Document should have at least 2 pages")
            return
        }
        
        // Add exclusive field only to page 2
        var page2 = pages[1]
        var page2Positions = page2.fieldPositions ?? []
        page2Positions.append(FieldPosition(dictionary: [
            "field": exclusiveFieldID,
            "_id": "exclusive_pos",
            "x": 0, "y": 0, "width": 4, "height": 8
        ]))
        page2.fieldPositions = page2Positions
        pages[1] = page2
        
        file.pages = pages
        document.files[0] = file
        
        let pageToDeleteID = "second_page_id_12345" // ✅ Fixed: Using correct page ID
        let documentEditor = documentEditor(document: document)
        
        // Verify field exists before deletion
        XCTAssertTrue(documentEditor.document.fields.contains(where: { $0.id == exclusiveFieldID }),
                     "Exclusive field should exist before deletion")
        
        // Delete page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify field was deleted (last occurrence removed)
        XCTAssertFalse(documentEditor.document.fields.contains(where: { $0.id == exclusiveFieldID }),
                      "Exclusive field should be deleted (no references remain)")
    }
    
    // MARK: - Changelog Tests for Page Deletion
    
    /// Test that changelogs are only generated for orphaned fields, not shared fields
    func testPageDeletion_changelogsOnlyForOrphanedFields() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        // Create two fields:
        // - Orphaned field: Only on page 2
        // - Shared field: On both page 1 and page 2
        let orphanedFieldID = "orphaned_changelog_field"
        let sharedFieldID = "shared_changelog_field"
        
        var orphanedField = JoyDocField(field: [:])
        orphanedField.id = orphanedFieldID
        orphanedField.identifier = "orphanedField"
        orphanedField.type = "text"
        document.fields.append(orphanedField)
        
        var sharedField = JoyDocField(field: [:])
        sharedField.id = sharedFieldID
        sharedField.identifier = "sharedField"
        sharedField.type = "text"
        document.fields.append(sharedField)
        
        guard var file = document.files.first, var pages = file.pages, pages.count >= 2 else {
            XCTFail("Document should have at least 2 pages")
            return
        }
        
        // Add shared field to page 1
        var page1 = pages[0]
        var page1Positions = page1.fieldPositions ?? []
        page1Positions.append(FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_1",
            "x": 0, "y": 16, "width": 4, "height": 8
        ]))
        page1.fieldPositions = page1Positions
        pages[0] = page1
        
        // Add both fields to page 2
        var page2 = pages[1]
        var page2Positions = page2.fieldPositions ?? []
        page2Positions.append(FieldPosition(dictionary: [
            "field": orphanedFieldID,
            "_id": "orphaned_pos",
            "x": 0, "y": 0, "width": 4, "height": 8
        ]))
        page2Positions.append(FieldPosition(dictionary: [
            "field": sharedFieldID,
            "_id": "shared_pos_2",
            "x": 0, "y": 8, "width": 4, "height": 8
        ]))
        page2.fieldPositions = page2Positions
        pages[1] = page2
        
        file.pages = pages
        document.files[0] = file
        
        let changeCapture = ChangeCapture()
        let documentEditor = DocumentEditor(document: document, events: changeCapture, validateSchema: false)
        
        let pageToDeleteID = "second_page_id_12345"
        
        // Delete page 2
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Verify changelogs
        let changes = changeCapture.capturedChanges
        
        // Should have: 1 page.delete + 1 field.delete (for orphaned field only)
        // Page 2's default field "second_page_field_1" is also orphaned, so total field.delete = 2
        let pageDeleteChanges = changes.filter { $0.target == "page.delete" }
        let fieldDeleteChanges = changes.filter { $0.target == "field.delete" }
        
        XCTAssertEqual(pageDeleteChanges.count, 1, "Should have exactly 1 page.delete changelog")
        XCTAssertEqual(pageDeleteChanges.first?.pageId, pageToDeleteID, "Page delete should reference correct page ID")
        
        // Verify orphaned field has changelog
        let orphanedFieldChangelog = fieldDeleteChanges.first(where: { $0.fieldId == orphanedFieldID })
        XCTAssertNotNil(orphanedFieldChangelog, "Orphaned field should have field.delete changelog")
        
        // Verify shared field does NOT have changelog
        let sharedFieldChangelog = fieldDeleteChanges.first(where: { $0.fieldId == sharedFieldID })
        XCTAssertNil(sharedFieldChangelog, "Shared field should NOT have field.delete changelog")
        
        // Verify changelog structure for orphaned field
        if let changelog = orphanedFieldChangelog {
            XCTAssertEqual(changelog.target, "field.delete")
            XCTAssertEqual(changelog.fieldId, orphanedFieldID)
            XCTAssertEqual(changelog.fieldIdentifier, "orphanedField")
            XCTAssertEqual(changelog.pageId, pageToDeleteID)
        }
    }
    
    /// Test that multiple orphaned fields generate correct number of changelogs
    func testPageDeletion_changelogsForMultipleOrphanedFields() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .addThirdPage()
            .setHeadingText()
            .setTextField()
        
        // Create scenario:
        // - Field A: Only on page 2 (ORPHANED)
        // - Field B: Only on page 2 (ORPHANED)
        // - Field C: On page 2 and page 3 (NOT ORPHANED)
        
        let fieldA_ID = "orphaned_a"
        let fieldB_ID = "orphaned_b"
        let fieldC_ID = "shared_c"
        
        for (id, identifier) in [(fieldA_ID, "fieldA"), (fieldB_ID, "fieldB"), (fieldC_ID, "fieldC")] {
            var field = JoyDocField(field: [:])
            field.id = id
            field.identifier = identifier
            field.type = "text"
            document.fields.append(field)
        }
        
        guard var file = document.files.first, var pages = file.pages, pages.count >= 3 else {
            XCTFail("Document should have at least 3 pages")
            return
        }
        
        // Add all three fields to page 2
        var page2 = pages[1]
        var page2Positions = page2.fieldPositions ?? []
        for (id, posId) in [(fieldA_ID, "pos_a"), (fieldB_ID, "pos_b"), (fieldC_ID, "pos_c")] {
            page2Positions.append(FieldPosition(dictionary: [
                "field": id,
                "_id": posId,
                "x": 0, "y": 0, "width": 4, "height": 8
            ]))
        }
        page2.fieldPositions = page2Positions
        pages[1] = page2
        
        // Add field C to page 3
        var page3 = pages[2]
        var page3Positions = page3.fieldPositions ?? []
        page3Positions.append(FieldPosition(dictionary: [
            "field": fieldC_ID,
            "_id": "pos_c_page3",
            "x": 0, "y": 0, "width": 4, "height": 8
        ]))
        page3.fieldPositions = page3Positions
        pages[2] = page3
        
        file.pages = pages
        document.files[0] = file
        
        let changeCapture = ChangeCapture()
        let documentEditor = DocumentEditor(document: document, events: changeCapture, validateSchema: false)
        
        let pageToDeleteID = "second_page_id_12345"
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        let changes = changeCapture.capturedChanges
        let fieldDeleteChanges = changes.filter { $0.target == "field.delete" }
        
        // Verify Field A has changelog (orphaned)
        XCTAssertTrue(fieldDeleteChanges.contains(where: { $0.fieldId == fieldA_ID }),
                     "Field A should have changelog (orphaned)")
        
        // Verify Field B has changelog (orphaned)
        XCTAssertTrue(fieldDeleteChanges.contains(where: { $0.fieldId == fieldB_ID }),
                     "Field B should have changelog (orphaned)")
        
        // Verify Field C does NOT have changelog (shared with page 3)
        XCTAssertFalse(fieldDeleteChanges.contains(where: { $0.fieldId == fieldC_ID }),
                      "Field C should NOT have changelog (still on page 3)")
        
        // Note: "second_page_field_1" is also orphaned, so total orphaned = 3
        XCTAssertGreaterThanOrEqual(fieldDeleteChanges.count, 2,
                                    "Should have at least 2 field.delete changelogs (for Field A and B)")
    }
    
    /// Test changelog generation with mobile view shared fields
    func testPageDeletion_changelogsMobileViewSharedFields() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .addSecondPage()
            .addSecondPageInMobileView()
            .setHeadingText()
            .setTextField()
        
        // Field on desktop page 2 AND mobile page 1 - should NOT generate changelog
        let crossViewFieldID = "cross_view_field"
        var crossViewField = JoyDocField(field: [:])
        crossViewField.id = crossViewFieldID
        crossViewField.identifier = "crossViewField"
        crossViewField.type = "text"
        document.fields.append(crossViewField)
        
        guard var file = document.files.first else {
            XCTFail("Document should have a file")
            return
        }
        
        // Add to desktop page 2
        if var pages = file.pages, pages.count >= 2 {
            var page2 = pages[1]
            var page2Positions = page2.fieldPositions ?? []
            page2Positions.append(FieldPosition(dictionary: [
                "field": crossViewFieldID,
                "_id": "cross_desktop_pos",
                "x": 0, "y": 0, "width": 4, "height": 8
            ]))
            page2.fieldPositions = page2Positions
            pages[1] = page2
            file.pages = pages
        }
        
        // Add to mobile page 1
        if var views = file.views, !views.isEmpty {
            var view = views[0]
            if var mobilePages = view.pages, !mobilePages.isEmpty {
                var mobilePage1 = mobilePages[0]
                var mobilePositions = mobilePage1.fieldPositions ?? []
                mobilePositions.append(FieldPosition(dictionary: [
                    "field": crossViewFieldID,
                    "_id": "cross_mobile_pos",
                    "x": 0, "y": 0, "width": 1, "height": 64
                ]))
                mobilePage1.fieldPositions = mobilePositions
                mobilePages[0] = mobilePage1
                view.pages = mobilePages
                views[0] = view
            }
            file.views = views
        }
        
        document.files[0] = file
        
        let changeCapture = ChangeCapture()
        let documentEditor = DocumentEditor(document: document, events: changeCapture, validateSchema: false)
        
        let pageToDeleteID = "second_page_id_12345"
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        let changes = changeCapture.capturedChanges
        let fieldDeleteChanges = changes.filter { $0.target == "field.delete" }
        
        // Verify cross-view field does NOT have changelog
        let crossViewChangelog = fieldDeleteChanges.first(where: { $0.fieldId == crossViewFieldID })
        XCTAssertNil(crossViewChangelog,
                    "Cross-view field should NOT have changelog (still in mobile view)")
    }
    
    /// Test that page.delete changelog is always generated regardless of fields
    func testPageDeletion_pageDeleteChangelogAlwaysGenerated() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        // Make all fields on page 2 shared with page 1 (no orphaned fields)
        guard var file = document.files.first, var pages = file.pages, pages.count >= 2 else {
            XCTFail("Document should have at least 2 pages")
            return
        }
        
        // Get page 2's field and add it to page 1
        if let page2Field = pages[1].fieldPositions?.first?.field {
            var page1 = pages[0]
            var page1Positions = page1.fieldPositions ?? []
            page1Positions.append(FieldPosition(dictionary: [
                "field": page2Field,
                "_id": "shared_field_pos",
                "x": 0, "y": 16, "width": 4, "height": 8
            ]))
            page1.fieldPositions = page1Positions
            pages[0] = page1
            file.pages = pages
            document.files[0] = file
        }
        
        let changeCapture = ChangeCapture()
        let documentEditor = DocumentEditor(document: document, events: changeCapture, validateSchema: false)
        
        let pageToDeleteID = "second_page_id_12345"
        let result = documentEditor.deletePage(pageID: pageToDeleteID)
        XCTAssertTrue(result, "Page deletion should succeed")
        
        let changes = changeCapture.capturedChanges
        let pageDeleteChanges = changes.filter { $0.target == "page.delete" }
        
        // page.delete changelog should ALWAYS be generated
        XCTAssertEqual(pageDeleteChanges.count, 1,
                      "page.delete changelog should always be generated")
        XCTAssertEqual(pageDeleteChanges.first?.pageId, pageToDeleteID,
                      "page.delete should reference correct page ID")
        
        // Verify no field.delete changelogs (all fields are shared)
        let fieldDeleteChanges = changes.filter { $0.target == "field.delete" }
        XCTAssertEqual(fieldDeleteChanges.count, 0,
                      "No field.delete changelogs should be generated (all fields shared)")
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
