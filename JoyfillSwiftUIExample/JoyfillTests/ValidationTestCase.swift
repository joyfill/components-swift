import XCTest
import Foundation
import SwiftUI
import JoyfillModel
@testable import Joyfill

final class ValidationTestCase: XCTestCase {
    
    // MARK: - Test Helpers
    let licenseKey: String = ""
    
    /// Mock event handler to capture onChange events for testing
    class ChangeCapture: FormChangeEvent {
        var capturedChanges: [Change] = []
        var capturedFocusEvents: [Event] = []
        var capturedBlurEvents: [Event] = []
        
        func onChange(changes: [Change], document: JoyDoc) {
            capturedChanges.append(contentsOf: changes)
        }
        
        func onFocus(event: Event) {
            capturedFocusEvents.append(event)
        }
        
        func onBlur(event: Event) {
            capturedBlurEvents.append(event)
        }
        
        func onCapture(event: CaptureEvent) {}
        func onUpload(event: UploadEvent) {}
        func onError(error: JoyfillError) {}
        
        func reset() {
            capturedChanges.removeAll()
            capturedFocusEvents.removeAll()
            capturedBlurEvents.removeAll()
        }
    }
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    func collectionDocumentEditor(document: JoyDoc) -> DocumentEditor {
        let license = (ProcessInfo.processInfo.environment["JOYFILL_TEST_LICENSE"] ?? licenseKey)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertFalse(license.isEmpty, "Missing license: set JOYFILL_TEST_LICENSE env var or check licenseKey")
        XCTAssertTrue(LicenseValidator.isCollectionEnabled(licenseToken: license), "License verification failed — the token does not match the public key in LicenseValidator")
        return DocumentEditor(document: document, validateSchema: false, license: license)
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fab82ddb5cdd73a2f27f")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fb203149d1c34cc6d6f8")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fb203149d1c34cc6d6f8")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fb2fca14b3e2ef978349")
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
        XCTAssertEqual(validationResult.fieldValidities.first?.fieldPositionId, "6629fb2fca14b3e2ef978349")
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
        //Test case changed as we not returning the hidden fields/any elements
        XCTAssertEqual(validationResult.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
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
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        
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
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
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
        XCTAssertEqual(validationResult.fieldValidities.count, 1)
        XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
        XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
//        XCTAssertEqual(validationResult.fieldValidities[1].field.id, "66aa28f805a4900ae643db9c")
//        XCTAssertEqual(validationResult.fieldValidities[1].status, .valid)
        
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
        //Result should be invalid coz a row with id "67612793a6cd1f9d39c8433d" has nil cells
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
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

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
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
        //if table/collection is not required , but some internal things are req and not filled , whole table is invalid
        
        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
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
    
    // Test formula duplication when duplicating a page
    func testPageDuplication_withFormulas() {
        // Create a test document with formulas
        var document = JoyDoc()
        document.id = "test_doc_1"
        document.identifier = "doc_test_1"
        
        // Create file and page
        var file = File()
        file.id = "file_1"
        file.pageOrder = ["page_1"]
        
        var page = Page()
        page.id = "page_1"
        
        // Create fields: text1, text2 (references text1), text3 (uses concat/upper), number1, number11 (similar ID)
        var field1 = JoyDocField()
        field1.id = "text1"
        field1.identifier = "field_text1"
        field1.fieldType = .text
        field1.title = "Text 1"
        field1.value = ValueUnion.string("test value")
        field1.file = "file_1"
        
        var field2 = JoyDocField()
        field2.id = "text2"
        field2.identifier = "field_text2"
        field2.fieldType = .text
        field2.title = "Copy of text1"
        field2.file = "file_1"
        var appliedFormula1 = AppliedFormula()
        appliedFormula1.id = "AF_text2"
        appliedFormula1.formula = "formula_text1Reference"
        appliedFormula1.key = "value"
        field2.formulas = [appliedFormula1]
        
        var field3 = JoyDocField()
        field3.id = "text3"
        field3.identifier = "field_text3"
        field3.fieldType = .text
        field3.title = "Uppercased with prefix"
        field3.file = "file_1"
        var appliedFormula2 = AppliedFormula()
        appliedFormula2.id = "AF_text3"
        appliedFormula2.formula = "formula_concatUpperCase"
        appliedFormula2.key = "value"
        field3.formulas = [appliedFormula2]
        
        var field4 = JoyDocField()
        field4.id = "number1"
        field4.identifier = "field_number1"
        field4.fieldType = .number
        field4.title = "Number 1"
        field4.value = ValueUnion.double(10)
        field4.file = "file_1"
        
        var field5 = JoyDocField()
        field5.id = "number11"
        field5.identifier = "field_number11"
        field5.fieldType = .number
        field5.title = "Number 11"
        field5.value = ValueUnion.double(20)
        field5.file = "file_1"
        
        var field6 = JoyDocField()
        field6.id = "sum_field"
        field6.identifier = "field_sum"
        field6.fieldType = .number
        field6.title = "Sum"
        field6.file = "file_1"
        var appliedFormula3 = AppliedFormula()
        appliedFormula3.id = "AF_sum"
        appliedFormula3.formula = "formula_sum"
        appliedFormula3.key = "value"
        field6.formulas = [appliedFormula3]
        
        // Create field positions
        var fp1 = FieldPosition()
        fp1.id = "fp_1"
        fp1.field = "text1"
        fp1.type = .text
        
        var fp2 = FieldPosition()
        fp2.id = "fp_2"
        fp2.field = "text2"
        fp2.type = .text
        
        var fp3 = FieldPosition()
        fp3.id = "fp_3"
        fp3.field = "text3"
        fp3.type = .text
        
        var fp4 = FieldPosition()
        fp4.id = "fp_4"
        fp4.field = "number1"
        fp4.type = .number
        
        var fp5 = FieldPosition()
        fp5.id = "fp_5"
        fp5.field = "number11"
        fp5.type = .number
        
        var fp6 = FieldPosition()
        fp6.id = "fp_6"
        fp6.field = "sum_field"
        fp6.type = .number
        
        page.fieldPositions = [fp1, fp2, fp3, fp4, fp5, fp6]
        file.pages = [page]
        document.files = [file]
        document.fields = [field1, field2, field3, field4, field5, field6]
        
        // Create document-level formulas
        var formula1 = Formula()
        formula1.id = "formula_text1Reference"
        formula1.desc = "Echo text1"
        formula1.type = "calc"
        formula1.scope = "private"
        formula1.expression = "text1"
        
        var formula2 = Formula()
        formula2.id = "formula_concatUpperCase"
        formula2.desc = "Uppercase + Prefix"
        formula2.type = "calc"
        formula2.scope = "private"
        formula2.expression = "concat(\"Current entry: \", upper(text1))"
        
        var formula3 = Formula()
        formula3.id = "formula_sum"
        formula3.desc = "Sum number1 and number11"
        formula3.type = "calc"
        formula3.scope = "private"
        formula3.expression = "number1 + number11"
        
        document.formulas = [formula1, formula2, formula3]
        
        // Create document editor and duplicate page
        let documentEditor = documentEditor(document: document)
        let originalFormulaCount = documentEditor.document.formulas.count
        let originalFieldCount = documentEditor.document.fields.count
        
        documentEditor.duplicatePage(pageID: "page_1")
        
        // Verify page duplication
        let firstFile = documentEditor.document.files.first
        let pageOrder = firstFile?.pageOrder
        XCTAssertEqual(pageOrder?.count, 2, "Should have 2 pages after duplication")
        
        guard let duplicatedPageID = pageOrder?[1] else {
            XCTFail("Could not find duplicated page ID")
            return
        }
        
        // Verify field duplication
        XCTAssertEqual(documentEditor.document.fields.count, originalFieldCount * 2, "Should have double the fields")
        
        // Verify formula duplication
        XCTAssertEqual(documentEditor.document.formulas.count, originalFormulaCount * 2, "Should have double the formulas")
        
        // Get duplicated fields
        let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID })
        let duplicatedFieldIDs = duplicatedPage?.fieldPositions?.compactMap { $0.field } ?? []
        XCTAssertEqual(duplicatedFieldIDs.count, 6, "Duplicated page should have 6 fields")
        
        // Find duplicated fields by their positions
        let dupText1ID = duplicatedFieldIDs[0]
        let dupText2ID = duplicatedFieldIDs[1]
        let dupText3ID = duplicatedFieldIDs[2]
        let dupNumber1ID = duplicatedFieldIDs[3]
        let dupNumber11ID = duplicatedFieldIDs[4]
        let dupSumFieldID = duplicatedFieldIDs[5]
        
        // Verify field IDs are different
        XCTAssertNotEqual(dupText1ID, "text1", "Duplicated field should have new ID")
        XCTAssertNotEqual(dupText2ID, "text2", "Duplicated field should have new ID")
        XCTAssertNotEqual(dupNumber1ID, "number1", "Duplicated field should have new ID")
        XCTAssertNotEqual(dupNumber11ID, "number11", "Duplicated field should have new ID")
        
        // Find duplicated fields
        guard let dupText2 = documentEditor.document.fields.first(where: { $0.id == dupText2ID }),
              let dupText3 = documentEditor.document.fields.first(where: { $0.id == dupText3ID }),
              let dupSumField = documentEditor.document.fields.first(where: { $0.id == dupSumFieldID }) else {
            XCTFail("Could not find duplicated fields")
            return
        }
        
        // Verify field formulas are updated to reference new formula IDs
        XCTAssertNotNil(dupText2.formulas, "Duplicated field should have formulas")
        XCTAssertEqual(dupText2.formulas?.count, 1, "Should have 1 formula")
        let dupText2FormulaRef = dupText2.formulas?[0].formula
        XCTAssertNotNil(dupText2FormulaRef, "Formula reference should exist")
        XCTAssertNotEqual(dupText2FormulaRef, "formula_text1Reference", "Should reference new formula ID")
        
        XCTAssertNotNil(dupText3.formulas, "Duplicated field should have formulas")
        let dupText3FormulaRef = dupText3.formulas?[0].formula
        XCTAssertNotEqual(dupText3FormulaRef, "formula_concatUpperCase", "Should reference new formula ID")
        
        XCTAssertNotNil(dupSumField.formulas, "Duplicated field should have formulas")
        let dupSumFormulaRef = dupSumField.formulas?[0].formula
        XCTAssertNotEqual(dupSumFormulaRef, "formula_sum", "Should reference new formula ID")
        
        // Verify new formulas exist with updated expressions
        guard let newFormula1 = documentEditor.document.formulas.first(where: { $0.id == dupText2FormulaRef }),
              let newFormula2 = documentEditor.document.formulas.first(where: { $0.id == dupText3FormulaRef }),
              let newFormula3 = documentEditor.document.formulas.first(where: { $0.id == dupSumFormulaRef }) else {
            XCTFail("Could not find duplicated formulas")
            return
        }
        
        // Verify expressions are updated with new field IDs - using exact string matching
        XCTAssertEqual(newFormula1.expression, dupText1ID, "Expression should be exactly the new text1 field ID")
        
        // Build expected expression for formula 2
        let expectedFormula2Expression = "concat(\"Current entry: \", upper(\(dupText1ID)))"
        XCTAssertEqual(newFormula2.expression, expectedFormula2Expression, "Expression should be exactly: concat(\"Current entry: \", upper(\(dupText1ID)))")
        
        // Verify that number1 is replaced but number11 is NOT affected (word boundary test)
        let expectedFormula3Expression = "\(dupNumber1ID) + \(dupNumber11ID)"
        XCTAssertEqual(newFormula3.expression, expectedFormula3Expression, "Expression should be exactly: \(dupNumber1ID) + \(dupNumber11ID)")
        
        // Verify original formulas are unchanged
        let origFormula1 = documentEditor.document.formulas.first(where: { $0.id == "formula_text1Reference" })
        let origFormula3 = documentEditor.document.formulas.first(where: { $0.id == "formula_sum" })
        XCTAssertEqual(origFormula1?.expression, "text1", "Original formula should be unchanged")
        XCTAssertEqual(origFormula3?.expression, "number1 + number11", "Original formula should be unchanged")
        
        print("✅ Formula duplication test passed!")
    }

    // MARK: - Duplicate Page Additional Tests
    /// Duplicate when document has no files should not mutate document.
    func testPageDuplication_noFile_doesNotMutateDocument() {
        var document = JoyDoc().setDocument()
        // setDocument() sets files = []; do not call setFile()
        XCTAssertTrue(document.files.isEmpty, "Test setup should have no files.")

        let documentEditor = documentEditor(document: document)
        documentEditor.duplicatePage(pageID: "any_page_id")

        XCTAssertTrue(documentEditor.document.files.isEmpty, "Document should still have no files after duplicate with no file.")
    }

    /// Duplicating a page should fire onChange with field.create and page.create changes.
    func testPageDuplication_onChangeDuplicatePage_firesChangeEvents() {
        let changeCapture = ChangeCapture()
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let documentEditor = DocumentEditor(document: document, events: changeCapture, isPageDuplicateEnabled: true, validateSchema: false)
        let originalPageID = "6629fab320fca7c8107a6cf6"
        let initialChangeCount = changeCapture.capturedChanges.count

        documentEditor.duplicatePage(pageID: originalPageID)

        let changes = changeCapture.capturedChanges
        XCTAssertGreaterThan(changes.count, initialChangeCount, "Duplicate page should produce onChange events.")

        let fieldCreates = changes.filter { $0.target == "field.create" }
        let pageCreates = changes.filter { $0.target == "page.create" }
        XCTAssertEqual(fieldCreates.count, 2, "Should have 2 field.create events (heading + text field).")
        XCTAssertGreaterThanOrEqual(pageCreates.count, 1, "Should have at least 1 page.create event.")

        let pageCreate = pageCreates.first
        XCTAssertNotNil(pageCreate?.fileId, "page.create should include fileId.")
        if let changeDict = pageCreate?.dictionary["change"] as? [String: Any] {
            XCTAssertNotNil(changeDict["page"], "page.create change should include page.")
            XCTAssertNotNil(changeDict["targetIndex"], "page.create change should include targetIndex.")
        }
    }

    /// isPageDuplicateEnabled is false in readonly mode; true when explicitly enabled in fill mode.
    func testPageDuplicate_isPageDuplicateEnabled_respected() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let editorFillEnabled = DocumentEditor(document: document, mode: .fill, isPageDuplicateEnabled: true, validateSchema: false)
        XCTAssertTrue(editorFillEnabled.isPageDuplicateEnabled, "Fill mode with isPageDuplicateEnabled true should have it true.")

        let editorReadonly = DocumentEditor(document: document, mode: .readonly, isPageDuplicateEnabled: true, validateSchema: false)
        XCTAssertFalse(editorReadonly.isPageDuplicateEnabled, "Readonly mode should force isPageDuplicateEnabled to false.")
    }
    /// Duplicate page with zero field positions still creates a new page and updates pageOrder.
    func testPageDuplication_emptyPage_createsPageAndUpdatesOrder() {
        var document = JoyDoc().setDocument().setFile()
        var page = Page()
        page.id = "empty_page_1"
        page.name = "Empty"
        page.fieldPositions = []
        document.files[0].pages = [page]
        document.files[0].pageOrder = ["empty_page_1"]

        let documentEditor = documentEditor(document: document)
        documentEditor.duplicatePage(pageID: "empty_page_1")

        let firstFile = documentEditor.document.files.first
        XCTAssertEqual(firstFile?.pages?.count, 2, "Should have 2 pages.")
        XCTAssertEqual(firstFile?.pageOrder?.count, 2, "Page order should have 2 entries.")
        let duplicatedPage = firstFile?.pages?.first(where: { $0.id != "empty_page_1" })
        XCTAssertNotNil(duplicatedPage, "Duplicated page should exist.")
        XCTAssertEqual(duplicatedPage?.fieldPositions?.count ?? 0, 0, "Duplicated page should have no field positions.")
    }

    /// Desktop has 1 page with 2 fields; mobile view has the same page with 2 fields + 1 extra (3 total).
    /// Duplicate the mobile page and assert exactly 3 new fields appear in document.fields (one per mobile field).
    func testPageDuplication_mobilePageWithExtraField_addsThreeNewFieldsToFieldsArray() {
        let fileID = "file_dup_mobile_1"
        let pageID = "page_dup_mobile_1"
        let fieldA = "field_a"
        let fieldB = "field_b"
        let fieldC = "field_mobile_only"

        // Fields: A and B on both desktop and mobile; C only on mobile
        var field1 = JoyDocField()
        field1.id = fieldA
        field1.identifier = "ident_a"
        field1.fieldType = .text
        field1.title = "Field A"
        field1.file = fileID

        var field2 = JoyDocField()
        field2.id = fieldB
        field2.identifier = "ident_b"
        field2.fieldType = .text
        field2.title = "Field B"
        field2.file = fileID

        var field3 = JoyDocField()
        field3.id = fieldC
        field3.identifier = "ident_c"
        field3.fieldType = .text
        field3.title = "Field C (mobile only)"
        field3.file = fileID

        // Desktop page: 2 field positions (A, B)
        var fpDesktop1 = FieldPosition()
        fpDesktop1.id = "fp_d_1"
        fpDesktop1.field = fieldA
        fpDesktop1.type = .text
        var fpDesktop2 = FieldPosition()
        fpDesktop2.id = "fp_d_2"
        fpDesktop2.field = fieldB
        fpDesktop2.type = .text

        var desktopPage = Page()
        desktopPage.id = pageID
        desktopPage.name = "Page 1"
        desktopPage.fieldPositions = [fpDesktop1, fpDesktop2]

        // Mobile page: same page ID, 3 field positions (A, B, C) — extra field on mobile
        var fpMobile1 = FieldPosition()
        fpMobile1.id = "fp_m_1"
        fpMobile1.field = fieldA
        fpMobile1.type = .text
        var fpMobile2 = FieldPosition()
        fpMobile2.id = "fp_m_2"
        fpMobile2.field = fieldB
        fpMobile2.type = .text
        var fpMobile3 = FieldPosition()
        fpMobile3.id = "fp_m_3"
        fpMobile3.field = fieldC
        fpMobile3.type = .text

        var mobilePage = Page()
        mobilePage.id = pageID
        mobilePage.name = "Page 1 (mobile)"
        mobilePage.fieldPositions = [fpMobile1, fpMobile2, fpMobile3]

        var mobileView = ModelView()
        mobileView.id = "view_mobile_1"
        mobileView.type = "mobile"
        mobileView.pages = [mobilePage]
        mobileView.pageOrder = [pageID]

        var file = File()
        file.id = fileID
        file.pageOrder = [pageID]
        file.pages = [desktopPage]
        file.views = [mobileView]

        var document = JoyDoc()
        document.id = "doc_dup_mobile_1"
        document.identifier = "ident_doc_1"
        document.files = [file]
        document.fields = [field1, field2, field3]

        let originalFieldIDs = Set(document.fields.compactMap { $0.id })
        XCTAssertEqual(originalFieldIDs.count, 3, "Initial document should have 3 fields (A, B, C).")

        let documentEditor = documentEditor(document: document)
        documentEditor.duplicatePage(pageID: pageID)

        let fieldsAfter = documentEditor.document.fields
        let afterFieldIDs = Set(fieldsAfter.compactMap { $0.id })
        let newFieldIDs = afterFieldIDs.subtracting(originalFieldIDs)

        // Duplicating the mobile page should create exactly 3 new fields (one per field on the mobile page).
        XCTAssertEqual(newFieldIDs.count, 3, "Duplicating the mobile page (3 fields) should add exactly 3 new fields to the fields array.")
        XCTAssertEqual(fieldsAfter.count, 6, "After duplicate, document.fields should contain the 3 new fields (implementation replaces with duplicated set).")

        // Duplicated page should exist in mobile view with 3 field positions pointing to new field IDs
        let firstFile = documentEditor.document.files.first
        let viewPage = firstFile?.views?.first?.pages?.first(where: { $0.id != pageID })
        XCTAssertNotNil(viewPage, "Duplicated page should exist in mobile view.")
        let dupPositionFieldIDs = viewPage?.fieldPositions?.compactMap { $0.field } ?? []
        XCTAssertEqual(dupPositionFieldIDs.count, 3, "Duplicated mobile page should have 3 field positions.")
        dupPositionFieldIDs.forEach { id in
            XCTAssertTrue(newFieldIDs.contains(id), "Each duplicated position should reference one of the new field IDs.")
        }
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
        
        // Verify ALL changelog properties for orphaned field
        if let changelog = orphanedFieldChangelog {
            XCTAssertEqual(changelog.v, 1, "Version should be 1")
            XCTAssertEqual(changelog.sdk, "swift", "SDK should be 'swift'")
            XCTAssertEqual(changelog.target, "field.delete", "Target should be 'field.delete'")
            XCTAssertEqual(changelog.id, "6629fc6367b3a40644096182", "Document ID should match")
            XCTAssertEqual(changelog.identifier, "doc_6629fc6367b3a40644096182", "Document identifier should match")
            XCTAssertEqual(changelog.fileId, "6629fab3c0ba3fb775b4a55c", "File ID should match")
            XCTAssertEqual(changelog.pageId, pageToDeleteID, "Page ID should match deleted page")
            XCTAssertEqual(changelog.fieldId, orphanedFieldID, "Field ID should match orphaned field")
            XCTAssertEqual(changelog.fieldIdentifier, "orphanedField", "Field identifier should match")
            XCTAssertEqual(changelog.fieldPositionId, "orphaned_pos", "Field position ID should be captured correctly")
            XCTAssertNotNil(changelog.createdOn, "CreatedOn should be set")
            XCTAssertGreaterThan(changelog.createdOn ?? 0, 0, "CreatedOn should be a valid timestamp")
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
        let pageDeleteChanges = changes.filter { $0.target == "page.delete" }
        
        // Verify cross-view field does NOT have changelog
        let crossViewChangelog = fieldDeleteChanges.first(where: { $0.fieldId == crossViewFieldID })
        XCTAssertNil(crossViewChangelog,
                    "Cross-view field should NOT have changelog (still in mobile view)")
        
        // Verify page.delete changelog properties
        XCTAssertEqual(pageDeleteChanges.count, 2, "Should have 2 page.delete event")
        if let pageDelete = pageDeleteChanges.first {
            XCTAssertEqual(pageDelete.v, 1)
            XCTAssertEqual(pageDelete.sdk, "swift")
            XCTAssertEqual(pageDelete.target, "page.delete")
            XCTAssertEqual(pageDelete.id, "6629fc6367b3a40644096182")
            XCTAssertEqual(pageDelete.identifier, "doc_6629fc6367b3a40644096182")
            XCTAssertEqual(pageDelete.fileId, "6629fab3c0ba3fb775b4a55c")
            XCTAssertEqual(pageDelete.pageId, pageToDeleteID)
            XCTAssertNotNil(pageDelete.view, "Mobile page delete should have view")
            XCTAssertNotNil(pageDelete.createdOn)
            XCTAssertGreaterThan(pageDelete.createdOn ?? 0, 0)
        }
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

            let documentEditor = collectionDocumentEditor(document: document)
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

            let documentEditor = collectionDocumentEditor(document: document)
            let result = documentEditor.validate()

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

            let editor = collectionDocumentEditor(document: document)
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

            let editor = collectionDocumentEditor(document: document)
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

            let editor = collectionDocumentEditor(document: document)
            let result = editor.validate()
            //if table/collection is not required , but some internal things are req and not filled , whole table is invalid
            XCTAssertEqual(result.status, .invalid)
            XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
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

        let editor = collectionDocumentEditor(document: document)
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

        let editor = collectionDocumentEditor(document: document)
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

        let editor = collectionDocumentEditor(document: document)
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

        let editor = collectionDocumentEditor(document: document)
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

        let editor = collectionDocumentEditor(document: document)
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
        XCTAssertEqual(validationResult.fieldValidities.count, 0)
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
            XCTAssertEqual(validationResult.fieldValidities.count, 1)
            XCTAssertEqual(validationResult.fieldValidities.first?.field.id, "66aa2865da10ac1c7b7acb1d")
            XCTAssertEqual(validationResult.fieldValidities.first?.status, .valid)
            XCTAssertEqual(validationResult.fieldValidities.first?.pageId, "6629fab320fca7c8107a6cf6")
        }
    
    // MARK: - Page Focus/Blur Event Tests
    
    /// Test that jumping to the current page does NOT fire blur or focus events
    func testPageFocusBlur_jumpToCurrentPage_noEvents() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let pageID = "6629fab320fca7c8107a6cf6"
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: pageID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: false,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Jump to the same page
        documentEditor.currentPageID = pageID
        
        // Should NOT fire any events
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 0, "No focus events should fire when jumping to current page")
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 0, "No blur events should fire when jumping to current page")
    }
    
    /// Test that jumping to a different page via UI fires blur and focus events
    func testPageFocusBlur_jumpToDifferentPage_firesEvents() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "second_page_id_12345"
        
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: page1ID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: false,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Jump to different page
        documentEditor.goto(page2ID)
        
        // Should fire blur for page1 and focus for page2
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 1, "One blur event should fire")
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 1, "One focus event should fire")
        
        // Verify blur event
        let blurEvent = eventCapture.capturedBlurEvents.first
        XCTAssertNotNil(blurEvent?.pageEvent, "Blur event should be a page event")
        XCTAssertEqual(blurEvent?.pageEvent?.type, "page.blur")
        XCTAssertEqual(blurEvent?.pageEvent?.page.id, page1ID)
        
        // Verify focus event
        let focusEvent = eventCapture.capturedFocusEvents.first
        XCTAssertNotNil(focusEvent?.pageEvent, "Focus event should be a page event")
        XCTAssertEqual(focusEvent?.pageEvent?.type, "page.focus")
        XCTAssertEqual(focusEvent?.pageEvent?.page.id, page2ID)
    }
    
    /// Test that programmatic navigation using goto() fires blur and focus events
    func testPageFocusBlur_programmaticNavigation_firesEvents() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "second_page_id_12345"
        
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: page1ID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: false,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Navigate programmatically using goto
        let result = documentEditor.goto(page2ID)
        
        XCTAssertEqual(result, .success, "Navigation should succeed")
        
        // Should fire blur for page1 and focus for page2
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 1, "One blur event should fire")
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 1, "One focus event should fire")
        
        // Verify blur event
        let blurEvent = eventCapture.capturedBlurEvents.first
        XCTAssertNotNil(blurEvent?.pageEvent, "Blur event should be a page event")
        XCTAssertEqual(blurEvent?.pageEvent?.type, "page.blur")
        XCTAssertEqual(blurEvent?.pageEvent?.page.id, page1ID)
        
        // Verify focus event
        let focusEvent = eventCapture.capturedFocusEvents.first
        XCTAssertNotNil(focusEvent?.pageEvent, "Focus event should be a page event")
        XCTAssertEqual(focusEvent?.pageEvent?.type, "page.focus")
        XCTAssertEqual(focusEvent?.pageEvent?.page.id, page2ID)
    }
    
    /// Test that page duplication doesn't cause unexpected focus/blur events
    func testPageFocusBlur_pageDuplication_noUnexpectedEvents() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()
        
        let originalPageID = "6629fab320fca7c8107a6cf6"
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: originalPageID,
            navigation: true,
            isPageDuplicateEnabled: true,
            isPageDeleteEnabled: false,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Duplicate the page
        documentEditor.duplicatePage(pageID: originalPageID)
        
        // Duplication should not fire focus/blur events on current page
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 0, "Page duplication should not fire focus events")
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 0, "Page duplication should not fire blur events")
        
        // Current page should still be the original
        XCTAssertEqual(documentEditor.currentPageID, originalPageID, "Current page should remain unchanged after duplication")
    }
    
    /// Test that deleting the currently focused page fires proper blur and focus events
    func testPageFocusBlur_deleteCurrentPage_firesEventsForNewPage() {
        let document = JoyDoc()
            .setDocument()
            .setSinglePageFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "second_page_id_12345"
        
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: page1ID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: true,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Delete the currently focused page
        let result = documentEditor.deletePage(pageID: page1ID)
        
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Should fire blur for deleted page and focus for new current page
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 1, "One blur event should fire for deleted page")
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 1, "One focus event should fire for new current page")
        
        // Verify blur event for deleted page
        let blurEvent = eventCapture.capturedBlurEvents.first
        XCTAssertNotNil(blurEvent?.pageEvent, "Blur event should be a page event")
        XCTAssertEqual(blurEvent?.pageEvent?.type, "page.blur")
        XCTAssertEqual(blurEvent?.pageEvent?.page.id, page1ID)
        
        // Verify focus event for new page
        let focusEvent = eventCapture.capturedFocusEvents.first
        XCTAssertNotNil(focusEvent?.pageEvent, "Focus event should be a page event")
        XCTAssertEqual(focusEvent?.pageEvent?.type, "page.focus")
        
        // New current page should be page2
        XCTAssertEqual(documentEditor.currentPageID, page2ID, "Current page should switch to remaining page")
        XCTAssertEqual(focusEvent?.pageEvent?.page.id, page2ID, "Focus event should be for page2")
    }
    
    /// Test that deleting a non-current page doesn't fire focus/blur events
    func testPageFocusBlur_deleteNonCurrentPage_noEvents() {
        let document = JoyDoc()
            .setDocument()
            .setSinglePageFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "second_page_id_12345"
        
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: page1ID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: true,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Delete a different page (not the current one)
        let result = documentEditor.deletePage(pageID: page2ID)
        
        XCTAssertTrue(result, "Page deletion should succeed")
        
        // Should NOT fire any focus/blur events
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 0, "No blur events should fire when deleting non-current page")
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 0, "No focus events should fire when deleting non-current page")
        
        // Current page should remain unchanged
        XCTAssertEqual(documentEditor.currentPageID, page1ID, "Current page should remain unchanged")
    }
    
    /// Test multiple page navigations fire correct sequence of events
    func testPageFocusBlur_multipleNavigations_correctSequence() {
        let document = JoyDoc()
            .setDocument()
            .setSinglePageFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()
        
        let page1ID = "6629fab320fca7c8107a6cf6"
        let page2ID = "second_page_id_12345"
        
        let eventCapture = ChangeCapture()
        let documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: eventCapture,
            pageID: page1ID,
            navigation: true,
            isPageDuplicateEnabled: false,
            isPageDeleteEnabled: false,
            validateSchema: false
        )
        
        // Clear any initial events
        eventCapture.reset()
        
        // Navigate page1 -> page2
        documentEditor.currentPageID = page2ID
        
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 1)
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 1)
        XCTAssertEqual(eventCapture.capturedBlurEvents.first?.pageEvent?.page.id, page1ID)
        XCTAssertEqual(eventCapture.capturedFocusEvents.first?.pageEvent?.page.id, page2ID)
        
        // Navigate page2 -> page1
        documentEditor.currentPageID = page1ID
        
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 2)
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 2)
        XCTAssertEqual(eventCapture.capturedBlurEvents[1].pageEvent?.page.id, page2ID)
        XCTAssertEqual(eventCapture.capturedFocusEvents[1].pageEvent?.page.id, page1ID)
        
        // Navigate page1 -> page2 again
        documentEditor.currentPageID = page2ID
        
        XCTAssertEqual(eventCapture.capturedBlurEvents.count, 3)
        XCTAssertEqual(eventCapture.capturedFocusEvents.count, 3)
        XCTAssertEqual(eventCapture.capturedBlurEvents[2].pageEvent?.page.id, page1ID)
        XCTAssertEqual(eventCapture.capturedFocusEvents[2].pageEvent?.page.id, page2ID)
    }

    // MARK: - Table Row/Cell Output Tests

    func testTableField_RowsReturnedInOutput() {
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

        let fieldValidity = validationResult.fieldValidities.first
        XCTAssertNotNil(fieldValidity?.rowValidities)
        // 5 rows total: 3 with data + 1 deleted (skipped) + 1 nil cells = 4 non-deleted
        XCTAssertEqual(fieldValidity?.rowValidities?.count, 4)
    }

    func testTableField_DeletedRowsExcludedFromOutput() {
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

        let rows = validationResult.fieldValidities.first?.rowValidities ?? []
        let deletedRowId = "67612793a6cd1f9d39c8433c"
        XCTAssertFalse(rows.contains(where: { $0.rowId == deletedRowId }))
    }

    func testTableField_CellValiditiesReturnedPerRow() {
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

        let firstRow = validationResult.fieldValidities.first?.rowValidities?.first
        XCTAssertNotNil(firstRow)
        // 3 columns visible (none hidden), but column3 is not required
        XCTAssertEqual(firstRow?.cellValidities.count, 3)
        XCTAssertEqual(firstRow?.rowId, "676127938056dcd158942bad")
    }

    func testTableField_InvalidRowHasInvalidCells() {
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

        // Row 5 (id: 67612793a6cd1f9d39c8433d) has nil cells, should be invalid
        let nilCellsRow = validationResult.fieldValidities.first?.rowValidities?.first(where: { $0.rowId == "67612793a6cd1f9d39c8433d" })
        XCTAssertNotNil(nilCellsRow)
        XCTAssertEqual(nilCellsRow?.status, .invalid)

        let invalidCells = nilCellsRow?.cellValidities.filter { $0.status == .invalid } ?? []
        XCTAssertFalse(invalidCells.isEmpty)
    }

    func testTableField_ValidRowsHaveValidStatus() {
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

        // Row 1 (id: 676127938056dcd158942bad) has all cells populated
        let validRow = validationResult.fieldValidities.first?.rowValidities?.first(where: { $0.rowId == "676127938056dcd158942bad" })
        XCTAssertNotNil(validRow)
        XCTAssertEqual(validRow?.status, .valid)
        XCTAssertTrue(validRow?.cellValidities.allSatisfy { $0.status == .valid } ?? false)
    }

    func testTableField_EmptyCells_AllRowsInvalid() {
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

        let rows = validationResult.fieldValidities.first?.rowValidities ?? []
        XCTAssertFalse(rows.isEmpty)
        // Row 2 has empty cells, should be invalid
        let row2 = rows.first(where: { $0.rowId == "67612793f70928da78973744" })
        XCTAssertEqual(row2?.status, .invalid)
    }

    func testTableField_HiddenColumns_CellsNotValidated() {
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
    }

    func testTableField_NonRequiredColumns_CellsAlwaysValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: false, areCellsEmpty: true, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        let rows = validationResult.fieldValidities.first?.rowValidities ?? []
        for row in rows {
            XCTAssertEqual(row.status, .valid)
            XCTAssertTrue(row.cellValidities.allSatisfy { $0.status == .valid })
        }
    }

    func testTableField_ZeroRows_NoRowsInOutput() {
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

        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        let rows = validationResult.fieldValidities.first?.rowValidities
        XCTAssertNotNil(rows)
        XCTAssertEqual(rows?.count, 0)
    }

    func testTableField_AllRowsDeleted_IsInvalid() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: true, isColumnRequired: true, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)

        if let fieldIndex = document.fields.firstIndex(where: { $0.id == "67612793c4e6a5e6a05e64a3" }),
           var elements = document.fields[fieldIndex].valueToValueElements {
            for i in elements.indices {
                elements[i].deleted = true
            }
            document.fields[fieldIndex].value = .valueElementArray(elements)
        }

        let documentEditor = documentEditor(document: document)
        let validationResult = documentEditor.validate()

        XCTAssertEqual(validationResult.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.status, .invalid)
        XCTAssertEqual(validationResult.fieldValidities.first?.rowValidities?.count, 0)
    }

    // MARK: - Collection Row/Cell Output Tests

    func testCollectionField_RowsReturnedInOutput() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let fieldValidity = result.fieldValidities.first
        XCTAssertNotNil(fieldValidity?.rowValidities)
        XCTAssertFalse(fieldValidity?.rowValidities?.isEmpty ?? true)
    }

    func testCollectionField_RootRowHasCorrectSchemaId() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertNotNil(rootRow)
        XCTAssertEqual(rootRow?.schemaId, "main_schema")
    }

    func testCollectionField_NestedRowHasCorrectSchemaId() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let nestedRow = rows.first(where: { $0.rowId == "nested_row_1" })
        XCTAssertNotNil(nestedRow)
        XCTAssertEqual(nestedRow?.schemaId, "child_schema_1")
    }

    func testCollectionField_FlatRowsContainBothRootAndNested() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        // Should have root row + nested row in flat array
        XCTAssertEqual(rows.count, 2)

        let schemaIds = rows.compactMap { $0.schemaId }
        XCTAssertTrue(schemaIds.contains("main_schema"))
        XCTAssertTrue(schemaIds.contains("child_schema_1"))
    }

    func testCollectionField_CellValiditiesReturnedPerRow() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.schemaId == "main_schema" })
        XCTAssertEqual(rootRow?.cellValidities.count, 1)
        XCTAssertEqual(rootRow?.cellValidities.first?.columnId, "col_text_1")

        let nestedRow = rows.first(where: { $0.schemaId == "child_schema_1" })
        XCTAssertEqual(nestedRow?.cellValidities.count, 1)
        XCTAssertEqual(nestedRow?.cellValidities.first?.columnId, "nested_col_1")
    }

    func testCollectionField_OmittedValues_CellsAreInvalid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: true)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.schemaId == "main_schema" })
        XCTAssertEqual(rootRow?.status, .invalid)
        XCTAssertEqual(rootRow?.cellValidities.first?.status, .invalid)
    }

    func testCollectionField_RequiredSchemaNoRows_FieldInvalid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: false, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .invalid)
        XCTAssertEqual(result.fieldValidities.first?.status, .invalid)
        // Only root row in output (no nested rows)
        let rows = result.fieldValidities.first?.rowValidities ?? []
        XCTAssertFalse(rows.contains(where: { $0.schemaId == "child_schema_1" }))
    }

    func testCollectionField_SchemaNotRequired_NoRowsStillValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: false, includeNestedRows: false, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .valid)
        XCTAssertEqual(result.fieldValidities.first?.status, .valid)
    }

    // MARK: - Bottom-Up Row Validity (row status reflects child schema validity)

    func testCollectionField_RootRowInvalid_WhenRequiredChildSchemaHasNoRows() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: false, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertNotNil(rootRow)
        // Root row's own cells are filled, but its required child schema has zero rows
        // so the root row itself must be invalid
        XCTAssertEqual(rootRow?.status, .invalid)
        // The root row's cells should still all be valid (invalidity comes from children)
        XCTAssertTrue(rootRow?.cellValidities.allSatisfy { $0.status == .valid } ?? false)
    }

    func testCollectionField_RootRowValid_WhenChildSchemaNotRequiredAndEmpty() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: false, includeNestedRows: false, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertNotNil(rootRow)
        // Child schema is not required, so empty children don't affect root row
        XCTAssertEqual(rootRow?.status, .valid)
    }

    func testCollectionField_RootRowInvalid_WhenChildRowHasInvalidCells() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        // Clear only the nested row's cells so child row is invalid while root cells stay valid
        let collectionFieldId = "67ddc52d35de157f6d7ebb63"
        if let fieldIndex = document.fields.firstIndex(where: { $0.id == collectionFieldId }),
           var elements = document.fields[fieldIndex].valueToValueElements {
            let emptyNestedRow = ValueElement(dictionary: [
                "_id": "nested_row_1",
                "cells": [String: Any](),
                "children": [String: Any]()
            ])
            elements[0].childrens = [
                "child_schema_1": Children(dictionary: ["value": [emptyNestedRow]])
            ]
            document.fields[fieldIndex].value = .valueElementArray(elements)
        }

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []

        // The nested child row should be invalid (empty required cells)
        let nestedRow = rows.first(where: { $0.rowId == "nested_row_1" })
        XCTAssertNotNil(nestedRow)
        XCTAssertEqual(nestedRow?.status, .invalid)

        // The root row should also be invalid because its child row is invalid
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertNotNil(rootRow)
        XCTAssertEqual(rootRow?.status, .invalid)
        // But the root row's own cells are all valid
        XCTAssertTrue(rootRow?.cellValidities.allSatisfy { $0.status == .valid } ?? false)
    }

    func testCollectionField_RootRowValid_WhenAllChildrenValid() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: false)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        let rows = result.fieldValidities.first?.rowValidities ?? []
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertNotNil(rootRow)
        // Root cells valid + child schema has rows + child row cells valid = root row valid
        XCTAssertEqual(rootRow?.status, .valid)

        let nestedRow = rows.first(where: { $0.rowId == "nested_row_1" })
        XCTAssertNotNil(nestedRow)
        XCTAssertEqual(nestedRow?.status, .valid)
    }

    func testCollectionField_BothRowsInvalid_WhenAllValuesOmitted() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionFieldRequired(isFieldRequired: true, isSchemaRequired: true, includeNestedRows: true, omitRequiredValues: true)
            .setCollectionFieldPosition()

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        XCTAssertEqual(result.status, .invalid)

        let rows = result.fieldValidities.first?.rowValidities ?? []

        // Child row invalid because its own cells are empty
        let nestedRow = rows.first(where: { $0.rowId == "nested_row_1" })
        XCTAssertEqual(nestedRow?.status, .invalid)

        // Root row invalid because its own cells are empty AND its child row is invalid
        let rootRow = rows.first(where: { $0.rowId == "row_1" })
        XCTAssertEqual(rootRow?.status, .invalid)
    }

    // MARK: - Unknown Field Type Excluded

    func testUnknownFieldType_ExcludedFromValidation() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()

        var field = JoyDocField()
        field.type = "someFutureType"
        field.id = "unknown_field_1"
        field.identifier = "field_unknown_1"
        field.title = "Unknown Field"
        field.required = true
        field.value = .string("")
        field.file = "6629fab3c0ba3fb775b4a55c"
        document.fields.append(field)

        var fieldPosition = FieldPosition()
        fieldPosition.field = "unknown_field_1"
        fieldPosition.displayType = "original"
        fieldPosition.width = 12
        fieldPosition.height = 8
        fieldPosition.x = 0
        fieldPosition.y = 60
        fieldPosition.id = "unknown_field_1_pos"
        document.files[0].views?[0].pages?[0].fieldPositions?.append(fieldPosition)

        let editor = documentEditor(document: document)
        let result = editor.validate()

        XCTAssertFalse(result.fieldValidities.contains(where: { $0.fieldId == "unknown_field_1" }))
    }

    // MARK: - Collection License Validation Tests

    func testCollectionField_NoLicense_ShouldBeExcludedFromValidation() {
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

        XCTAssertFalse(
            result.fieldValidities.contains(where: { $0.field.fieldType == .collection }),
            "Collection field should not appear in validation results when no license is provided"
        )
    }

    func testCollectionField_NoLicense_OtherFieldsStillValidated() {
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

        XCTAssertFalse(
            result.fieldValidities.contains(where: { $0.field.fieldType == .collection }),
            "Collection field should be excluded when no license is provided"
        )

    }

    func testCollectionField_ValidLicense_ShouldBeIncludedInValidation() {
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

        let editor = collectionDocumentEditor(document: document)
        let result = editor.validate()

        XCTAssertTrue(
            result.fieldValidities.contains(where: { $0.field.fieldType == .collection }),
            "Collection field should be included in validation when a valid license is provided"
        )
    }
}
