import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class ValidatePathTests: XCTestCase {

    // MARK: - Known IDs (from existing test data builders)

    let pageID            = "6629fab320fca7c8107a6cf6"
    /// Second page from `addSecondPage()` / `addSecondPageInMobileView()` in JoyDoc+DummyModel.
    let secondPageID      = "second_page_id_12345"
    let imageFieldID      = "6629fab36e8925135f0cdd4f"
    let imagePositionID   = "6629fab82ddb5cdd73a2f27f"
    let textFieldID       = "6629fb1d92a76d06750ca4a1"
    let textPositionID    = "6629fb203149d1c34cc6d6f8"
    let multilineFieldID  = "6629fb2b9a487ce1c1f35f6c"
    let multilinePositionID = "6629fb2fca14b3e2ef978349"

    // MARK: - Helpers

    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    func makeDocumentWithHiddenRequiredImageField() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue(hidden: true)
            .setImageFieldPositionInMobile()
        return documentEditor(document: document)
    }

    func makeDocumentWithTwoRequiredFields() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setImageFieldPositionInMobile()
            .setRequiredTextFieldWithoutValue()
            .setTextPositionInMobile()
        return documentEditor(document: document)
    }

    func makeDocumentWithRequiredMultilineField(hasValue: Bool) -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        let withField = hasValue
            ? document.setRequiredMultilineTextFieldWithValue()
            : document.setRequiredMultilineTextFieldWithoutValue()
        return documentEditor(document: withField.setMultilinePositionInMobile())
    }

    func makeDocumentWithRequiredImageFieldWithoutValue() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setImageFieldPositionInMobile()
        return documentEditor(document: document)
    }

    func makeDocumentWithRequiredImageFieldWithValue() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithValue()
            .setImageFieldPositionInMobile()
        return documentEditor(document: document)
    }

    func makeDocumentWithRequiredTextField(hasValue: Bool) -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        let withField = hasValue
            ? document.setRequiredTextFieldWithValue()
            : document.setRequiredTextFieldWithoutValue()
        return documentEditor(document: withField.setTextPositionInMobile())
    }

    func makeDocumentWithNonRequiredTextField() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setTextField()
            .setTextPositionInMobile()
        return documentEditor(document: document)
    }

    /// First page has required image (mobile layout); a real second page exists so paths can use a wrong but existing `pageId`.
    func makeDocumentWithRequiredImageFirstPageAndSecondPage() -> DocumentEditor {
        let document = JoyDoc()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredImagefieldsWithoutValue()
            .setImageFieldPositionInMobile()
            .addSecondPage()
            .addSecondPageInMobileView()
        return documentEditor(document: document)
    }

    func makeTableEditorForRowCellPathValidation() -> DocumentEditor {
        let document = JoyDoc(dictionary: [
            "_id": "doc-1",
            "files": [[
                "_id": "file-1",
                "pageOrder": ["page-1"],
                "pages": [[
                    "_id": "page-1",
                    "fieldPositions": [[
                        "_id": "fp-1",
                        "field": "field-1",
                        "type": "table",
                    ]],
                ]],
            ]],
            "fields": [[
                "_id": "field-1",
                "file": "file-1",
                "type": "table",
                "required": true,
                "tableColumns": [
                    ["_id": "col-required", "title": "Required", "type": "text", "required": true],
                    ["_id": "col-optional", "title": "Optional", "type": "text", "required": false],
                ],
                "tableColumnOrder": ["col-required", "col-optional"],
                "value": [[
                    "_id": "row-1",
                    "cells": [
                        "col-required": "",
                        "col-optional": "ok",
                    ],
                ]],
            ]],
        ])
        return documentEditor(document: document)
    }

    // MARK: - 1. Empty path → same result as validate()

    func testValidatePath_EmptyPath_ReturnsDotPage() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: "")

        if case .page(let validation) = result {
            let full = editor.validate()
            XCTAssertEqual(validation.status, full.status)
            XCTAssertEqual(validation.fieldValidities.count, full.fieldValidities.count)
        } else {
            XCTFail("Expected .page for empty path")
        }
    }

    func testValidatePath_EmptyPath_StatusMatchesFullValidate() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let pathResult = editor.validate(path: "")
        let fullResult = editor.validate()

        if case .page(let validation) = pathResult {
            XCTAssertEqual(validation.status, fullResult.status)
        } else {
            XCTFail("Expected .page for empty path")
        }
    }

    func testValidatePath_WhitespaceOnly_TreatedAsEmptyPath() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let pathResult = editor.validate(path: "  \n\t  ")
        let fullResult = editor.validate()

        if case .page(let validation) = pathResult {
            XCTAssertEqual(validation.status, fullResult.status)
            XCTAssertEqual(validation.fieldValidities.count, fullResult.fieldValidities.count)
        } else {
            XCTFail("Expected .page for whitespace-only path")
        }
    }

    func testValidatePath_TrimsSurroundingAndSegmentWhitespace() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let trimmedEquivalent = " \(pageID) / \(imagePositionID) \n"
        let tight = "\(pageID)/\(imagePositionID)"

        guard case .field(let a) = editor.validate(path: trimmedEquivalent),
              case .field(let b) = editor.validate(path: tight) else {
            XCTFail("Expected .field for both paths"); return
        }
        XCTAssertEqual(a.fieldPositionId, b.fieldPositionId)
        XCTAssertEqual(a.pageId, b.pageId)
        XCTAssertEqual(a.status, b.status)
    }

    // MARK: - 2. Valid pageID only → .page scoped to that page

    func testValidatePath_ValidPageID_ReturnsDotPage() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: pageID)

        if case .page(let validation) = result {
            XCTAssertEqual(validation.status, .invalid)
            XCTAssertFalse(validation.fieldValidities.isEmpty)
        } else {
            XCTFail("Expected .page for valid pageID")
        }
    }

    func testValidatePath_ValidPageID_FieldValiditiesOnlyBelongToThatPage() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: pageID)

        if case .page(let validation) = result {
            for fieldValidity in validation.fieldValidities {
                XCTAssertEqual(fieldValidity.pageId, pageID)
            }
        } else {
            XCTFail("Expected .page for valid pageID")
        }
    }

    func testValidatePath_ValidPageID_IsSubsetOfFullValidate() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let fullValidation = editor.validate()
        let result = editor.validate(path: pageID)

        if case .page(let pageValidation) = result {
            let fullIDs = Set(fullValidation.fieldValidities.compactMap { $0.fieldPositionId })
            let pageIDs = Set(pageValidation.fieldValidities.compactMap { $0.fieldPositionId })
            XCTAssertTrue(pageIDs.isSubset(of: fullIDs))
        } else {
            XCTFail("Expected .page for valid pageID")
        }
    }

    // MARK: - 3. Non-existent pageID → .page with empty fieldValidities

    func testValidatePath_NonExistentPageID_ReturnsEmptyValidation() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: "non-existent-page-id")

        if case .page(let validation) = result {
            XCTAssertEqual(validation.status, .valid)
            XCTAssertTrue(validation.fieldValidities.isEmpty)
        } else {
            XCTFail("Expected .page for non-existent pageID")
        }
    }

    // MARK: - 4. Valid pageId/fieldPositionId → .field(FieldValidity)

    func testValidatePath_ValidFieldPositionID_ReturnsDotField() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.fieldPositionId, imagePositionID)
        } else {
            XCTFail("Expected .field for valid pageId/fieldPositionId")
        }
    }

    func testValidatePath_ValidFieldPositionID_HasCorrectPageID() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.pageId, pageID)
        } else {
            XCTFail("Expected .field for valid pageId/fieldPositionId")
        }
    }

    func testValidatePath_ValidFieldPositionID_HasCorrectFieldID() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.field.id, imageFieldID)
        } else {
            XCTFail("Expected .field for valid pageId/fieldPositionId")
        }
    }

    // MARK: - 5. Non-existent fieldPositionId → .notFound

    func testValidatePath_NonExistentFieldPositionID_ReturnsNotFound() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/non-existent-position-id"
        let result = editor.validate(path: path)

        if case .notFound = result { } else {
            XCTFail("Expected .notFound for non-existent fieldPositionId")
        }
    }

    // MARK: - 6. Invalid rowId on non-table field → .notFound (no crash)

    func testValidatePath_ExtraDepthPath_ReturnsNotFound() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)/nonexistent-row-id"
        let result = editor.validate(path: path)

        if case .notFound = result { } else {
            XCTFail("Expected .notFound for rowId on non-table field")
        }
    }

    // MARK: - Path page must own the field position

    func testValidatePath_WrongPageIDWithValidFieldPositionID_ReturnsNotFound() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "non-existent-page-id/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .notFound = result { } else {
            XCTFail("Expected .notFound when fieldPositionId does not belong to the given pageId, got \(result)")
        }
    }

    /// Locks `fieldIdentifier.pageID == pageId` prefix: position exists on page 1 but path uses another real page id → `.page` for that other page, not `.field` for the image on page 1.
    func testValidatePath_RealOtherPageIDWithPositionFromFirstPage_ReturnsNotFound() {
        let editor = makeDocumentWithRequiredImageFirstPageAndSecondPage()

        let correctPath = "\(pageID)/\(imagePositionID)"
        guard case .field(let fieldValidityForCorrectPath) = editor.validate(path: correctPath) else {
            XCTFail("Sanity check: valid page + position should return .field"); return
        }
        XCTAssertEqual(fieldValidityForCorrectPath.fieldPositionId, imagePositionID)
        XCTAssertEqual(fieldValidityForCorrectPath.pageId, pageID)

        let wrongPath = "\(secondPageID)/\(imagePositionID)"
        let result = editor.validate(path: wrongPath)

        if case .notFound = result { } else {
            XCTFail("Expected .notFound when fieldPositionId does not belong to the given pageId, got \(result)")
        }
    }

    // MARK: - 7. Required field without value → .invalid

    func testValidatePath_RequiredFieldWithoutValue_IsInvalid() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.status, .invalid)
        } else {
            XCTFail("Expected .field")
        }
    }

    // MARK: - 8. Required field with value → .valid

    func testValidatePath_RequiredFieldWithValue_IsValid() {
        let editor = makeDocumentWithRequiredImageFieldWithValue()
        let path = "\(pageID)/\(imagePositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.status, .valid)
        } else {
            XCTFail("Expected .field")
        }
    }

    // MARK: - 9. Non-required field without value → .valid

    func testValidatePath_NonRequiredFieldWithoutValue_IsValid() {
        let editor = makeDocumentWithNonRequiredTextField()
        let path = "\(pageID)/\(textPositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.status, .valid)
        } else {
            XCTFail("Expected .field")
        }
    }

    // MARK: - 10. Text field — required without value → .invalid

    func testValidatePath_RequiredTextFieldWithoutValue_IsInvalid() {
        let editor = makeDocumentWithRequiredTextField(hasValue: false)
        let path = "\(pageID)/\(textPositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.status, .invalid)
        } else {
            XCTFail("Expected .field")
        }
    }

    // MARK: - 11. Text field — required with value → .valid

    func testValidatePath_RequiredTextFieldWithValue_IsValid() {
        let editor = makeDocumentWithRequiredTextField(hasValue: true)
        let path = "\(pageID)/\(textPositionID)"
        let result = editor.validate(path: path)

        if case .field(let fieldValidity) = result {
            XCTAssertEqual(fieldValidity.status, .valid)
        } else {
            XCTFail("Expected .field")
        }
    }

    // MARK: - 12. validate(path: "") consistency with validate()

    func testValidatePath_EmptyPath_FieldValiditiesCountMatchesFull() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let pathResult = editor.validate(path: "")
        let fullResult = editor.validate()

        if case .page(let validation) = pathResult {
            XCTAssertEqual(validation.fieldValidities.count, fullResult.fieldValidities.count)
        } else {
            XCTFail("Expected .page")
        }
    }

    func testValidatePath_EmptyPath_FieldPositionIDsMatchFull() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let pathResult = editor.validate(path: "")
        let fullResult = editor.validate()

        if case .page(let validation) = pathResult {
            let pathPositionIDs = validation.fieldValidities.compactMap { $0.fieldPositionId }.sorted()
            let fullPositionIDs = fullResult.fieldValidities.compactMap { $0.fieldPositionId }.sorted()
            XCTAssertEqual(pathPositionIDs, fullPositionIDs)
        } else {
            XCTFail("Expected .page")
        }
    }

    // MARK: - 13. getFieldIdentifier(forFieldPositionID:) — valid

    func testGetFieldIdentifier_ForValidPositionID_ReturnsNonNil() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let identifier = editor.getFieldIdentifier(forFieldPositionID: imagePositionID)

        XCTAssertNotNil(identifier)
    }

    func testGetFieldIdentifier_ForValidPositionID_HasCorrectFieldID() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let identifier = editor.getFieldIdentifier(forFieldPositionID: imagePositionID)

        XCTAssertEqual(identifier?.fieldID, imageFieldID)
    }

    func testGetFieldIdentifier_ForValidPositionID_HasCorrectPageID() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let identifier = editor.getFieldIdentifier(forFieldPositionID: imagePositionID)

        XCTAssertEqual(identifier?.pageID, pageID)
    }

    func testGetFieldIdentifier_ForValidPositionID_HasCorrectFieldPositionID() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let identifier = editor.getFieldIdentifier(forFieldPositionID: imagePositionID)

        XCTAssertEqual(identifier?.fieldPositionId, imagePositionID)
    }

    // MARK: - 14. getFieldIdentifier(forFieldPositionID:) — invalid

    func testGetFieldIdentifier_ForNonExistentPositionID_ReturnsNil() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let identifier = editor.getFieldIdentifier(forFieldPositionID: "non-existent-position-id")

        XCTAssertNil(identifier)
    }

    // MARK: - 15. ComponentValidity enum — associated values are accessible

    func testComponentValidity_PageCase_AssociatedValidationIsAccessible() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: pageID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page")
            return
        }
        XCTAssertNotNil(validation)
    }

    func testComponentValidity_FieldCase_AssociatedFieldValidityIsAccessible() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: "\(pageID)/\(imagePositionID)")

        guard case .field(let fieldValidity) = result else {
            XCTFail("Expected .field")
            return
        }
        XCTAssertNotNil(fieldValidity)
    }

    // MARK: - 16. Validate → update value → re-validate

    // Helper: simulates a user entering a value into a field
    @discardableResult
    private func enterValue(into editor: DocumentEditor, fieldID: String, value: ValueUnion) -> DocumentEditor {
        let fieldIdentifier = FieldIdentifier(fieldID: fieldID)
        let event = FieldChangeData(fieldIdentifier: fieldIdentifier, updateValue: value)
        editor.updateField(event: event, fieldIdentifier: fieldIdentifier)
        return editor
    }

    private var sampleImageValue: ValueUnion {
        let dict: [String: String] = [
            "_id": "6629fad9a6d0c81c8c217fc5",
            "url": "https://example.com/image.png",
            "fileName": "image.png",
            "filePath": "some/path"
        ]
        return .valueElementArray([ValueElement(dictionary: dict)])
    }

    // Image field: starts invalid → enter image → now valid
    func testRevalidation_ImageField_InvalidThenFillThenValid() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let path = "\(pageID)/\(imagePositionID)"

        // Step 1: confirm invalid before entering value
        let before = editor.validate(path: path)
        guard case .field(let beforeValidity) = before else {
            XCTFail("Expected .field before update"); return
        }
        XCTAssertEqual(beforeValidity.status, .invalid)

        // Step 2: enter a value
        enterValue(into: editor, fieldID: imageFieldID, value: sampleImageValue)

        // Step 3: re-validate — should now be valid
        let after = editor.validate(path: path)
        guard case .field(let afterValidity) = after else {
            XCTFail("Expected .field after update"); return
        }
        XCTAssertEqual(afterValidity.status, .valid)
    }

    // Text field: starts invalid → enter text → now valid
    func testRevalidation_TextField_InvalidThenFillThenValid() {
        let editor = makeDocumentWithRequiredTextField(hasValue: false)
        let path = "\(pageID)/\(textPositionID)"

        // Step 1: confirm invalid
        let before = editor.validate(path: path)
        guard case .field(let beforeValidity) = before else {
            XCTFail("Expected .field before update"); return
        }
        XCTAssertEqual(beforeValidity.status, .invalid)

        // Step 2: enter a value
        enterValue(into: editor, fieldID: textFieldID, value: .string("Hello"))

        // Step 3: re-validate — should now be valid
        let after = editor.validate(path: path)
        guard case .field(let afterValidity) = after else {
            XCTFail("Expected .field after update"); return
        }
        XCTAssertEqual(afterValidity.status, .valid)
    }

    // Text field: starts valid → clear value → now invalid
    func testRevalidation_TextField_ValidThenClearThenInvalid() {
        let editor = makeDocumentWithRequiredTextField(hasValue: true)
        let path = "\(pageID)/\(textPositionID)"

        // Step 1: confirm valid
        let before = editor.validate(path: path)
        guard case .field(let beforeValidity) = before else {
            XCTFail("Expected .field before clear"); return
        }
        XCTAssertEqual(beforeValidity.status, .valid)

        // Step 2: clear the value
        enterValue(into: editor, fieldID: textFieldID, value: .string(""))

        // Step 3: re-validate — should now be invalid
        let after = editor.validate(path: path)
        guard case .field(let afterValidity) = after else {
            XCTFail("Expected .field after clear"); return
        }
        XCTAssertEqual(afterValidity.status, .invalid)
    }

    // Page scope: starts invalid → fix the field → page becomes valid
    func testRevalidation_PageScope_InvalidThenFillFieldThenValid() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()

        // Step 1: page is invalid
        let before = editor.validate(path: pageID)
        guard case .page(let beforeValidation) = before else {
            XCTFail("Expected .page before update"); return
        }
        XCTAssertEqual(beforeValidation.status, .invalid)

        // Step 2: enter a value for the image field
        enterValue(into: editor, fieldID: imageFieldID, value: sampleImageValue)

        // Step 3: page should now be valid
        let after = editor.validate(path: pageID)
        guard case .page(let afterValidation) = after else {
            XCTFail("Expected .page after update"); return
        }
        XCTAssertEqual(afterValidation.status, .valid)
    }

    // Full validate(): starts invalid → fix field → overall becomes valid
    func testRevalidation_FullValidate_InvalidThenFillFieldThenValid() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()

        // Step 1: overall document is invalid
        XCTAssertEqual(editor.validate().status, .invalid)

        // Step 2: enter a value
        enterValue(into: editor, fieldID: imageFieldID, value: sampleImageValue)

        // Step 3: overall document should now be valid
        XCTAssertEqual(editor.validate().status, .valid)
    }

    // validate(path:) and validate() stay in sync after update
    func testRevalidation_PathAndFullValidate_StayInSyncAfterUpdate() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()

        enterValue(into: editor, fieldID: imageFieldID, value: sampleImageValue)

        let pathResult = editor.validate(path: "")
        let fullResult = editor.validate()

        guard case .page(let pathValidation) = pathResult else {
            XCTFail("Expected .page from validate(path:)"); return
        }
        XCTAssertEqual(pathValidation.status, fullResult.status)
    }

    // MARK: - 17. Hidden required field is excluded from validation

    // A hidden required field has no value but should not count as invalid
    func testValidate_HiddenRequiredField_IsExcludedFromValidation() {
        let editor = makeDocumentWithHiddenRequiredImageField()

        let result = editor.validate()

        XCTAssertEqual(result.status, .valid)
        XCTAssertTrue(result.fieldValidities.isEmpty)
    }

    func testValidatePath_PageScope_HiddenRequiredField_PageIsValid() {
        let editor = makeDocumentWithHiddenRequiredImageField()

        let result = editor.validate(path: pageID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page"); return
        }
        XCTAssertEqual(validation.status, .valid)
        XCTAssertTrue(validation.fieldValidities.isEmpty)
    }

    // MARK: - 18. Multiple required fields — partial fix keeps page invalid

    func testValidatePath_TwoRequiredFields_BothMissing_PageIsInvalid() {
        let editor = makeDocumentWithTwoRequiredFields()

        let result = editor.validate(path: pageID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page"); return
        }
        XCTAssertEqual(validation.status, .invalid)
        XCTAssertEqual(validation.fieldValidities.count, 2)
    }

    func testValidatePath_TwoRequiredFields_FixOnlyOne_PageStillInvalid() {
        let editor = makeDocumentWithTwoRequiredFields()

        // Fix only the text field
        enterValue(into: editor, fieldID: textFieldID, value: .string("Hello"))

        let result = editor.validate(path: pageID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page"); return
        }
        XCTAssertEqual(validation.status, .invalid)
    }

    func testValidatePath_TwoRequiredFields_FixBoth_PageBecomesValid() {
        let editor = makeDocumentWithTwoRequiredFields()

        // Fix both fields
        enterValue(into: editor, fieldID: textFieldID, value: .string("Hello"))
        enterValue(into: editor, fieldID: imageFieldID, value: sampleImageValue)

        let result = editor.validate(path: pageID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page"); return
        }
        XCTAssertEqual(validation.status, .valid)
    }

    // MARK: - 19. Multiline field validation

    func testValidatePath_RequiredMultilineField_WithoutValue_IsInvalid() {
        let editor = makeDocumentWithRequiredMultilineField(hasValue: false)
        let path = "\(pageID)/\(multilinePositionID)"

        let result = editor.validate(path: path)

        guard case .field(let fieldValidity) = result else {
            XCTFail("Expected .field"); return
        }
        XCTAssertEqual(fieldValidity.status, .invalid)
    }

    func testValidatePath_RequiredMultilineField_WithValue_IsValid() {
        let editor = makeDocumentWithRequiredMultilineField(hasValue: true)
        let path = "\(pageID)/\(multilinePositionID)"

        let result = editor.validate(path: path)

        guard case .field(let fieldValidity) = result else {
            XCTFail("Expected .field"); return
        }
        XCTAssertEqual(fieldValidity.status, .valid)
    }

    func testRevalidation_MultilineField_InvalidThenFillThenValid() {
        let editor = makeDocumentWithRequiredMultilineField(hasValue: false)
        let path = "\(pageID)/\(multilinePositionID)"

        // Step 1: confirm invalid
        let before = editor.validate(path: path)
        guard case .field(let beforeValidity) = before else {
            XCTFail("Expected .field before update"); return
        }
        XCTAssertEqual(beforeValidity.status, .invalid)

        // Step 2: enter a value
        enterValue(into: editor, fieldID: multilineFieldID, value: .string("Some text"))

        // Step 3: re-validate — should now be valid
        let after = editor.validate(path: path)
        guard case .field(let afterValidity) = after else {
            XCTFail("Expected .field after update"); return
        }
        XCTAssertEqual(afterValidity.status, .valid)
    }

    // MARK: - 20. getFieldIdentifier for other field types

    func testGetFieldIdentifier_ForTextPositionID_ReturnsNonNil() {
        let editor = makeDocumentWithRequiredTextField(hasValue: false)
        let identifier = editor.getFieldIdentifier(forFieldPositionID: textPositionID)

        XCTAssertNotNil(identifier)
    }

    func testGetFieldIdentifier_ForTextPositionID_HasCorrectFieldID() {
        let editor = makeDocumentWithRequiredTextField(hasValue: false)
        let identifier = editor.getFieldIdentifier(forFieldPositionID: textPositionID)

        XCTAssertEqual(identifier?.fieldID, textFieldID)
    }

    func testGetFieldIdentifier_ForMultilinePositionID_ReturnsNonNil() {
        let editor = makeDocumentWithRequiredMultilineField(hasValue: false)
        let identifier = editor.getFieldIdentifier(forFieldPositionID: multilinePositionID)

        XCTAssertNotNil(identifier)
    }

    func testGetFieldIdentifier_ForMultilinePositionID_HasCorrectFieldID() {
        let editor = makeDocumentWithRequiredMultilineField(hasValue: false)
        let identifier = editor.getFieldIdentifier(forFieldPositionID: multilinePositionID)

        XCTAssertEqual(identifier?.fieldID, multilineFieldID)
    }

    // MARK: - 21. ComponentValidity.fieldValidity computed property

    // .page case → fieldValidity must be nil
    func testComponentValidity_PageCase_FieldValidityIsNil() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: pageID)

        XCTAssertNil(result.fieldValidity)
    }

    // .field case → fieldValidity must be non-nil and match
    func testComponentValidity_FieldCase_FieldValidityIsNonNil() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: "\(pageID)/\(imagePositionID)")

        XCTAssertNotNil(result.fieldValidity)
    }

    func testComponentValidity_FieldCase_FieldValidityMatchesDirectAccess() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: "\(pageID)/\(imagePositionID)")

        guard case .field(let direct) = result else {
            XCTFail("Expected .field"); return
        }
        XCTAssertEqual(result.fieldValidity?.fieldPositionId, direct.fieldPositionId)
        XCTAssertEqual(result.fieldValidity?.status, direct.status)
    }

    // MARK: - 22. Edge case paths

    // Bare fieldPositionID with no slash → treated as unknown pageID → empty .page
    func testValidatePath_BarePositionID_NoSlash_ReturnsEmptyPage() {
        let editor = makeDocumentWithRequiredImageFieldWithoutValue()
        let result = editor.validate(path: imagePositionID)

        guard case .page(let validation) = result else {
            XCTFail("Expected .page for bare positionID"); return
        }
        XCTAssertEqual(validation.status, .valid)
        XCTAssertTrue(validation.fieldValidities.isEmpty)
    }

    // Page-level revalidation reverse: valid → clear field → page invalid
    func testRevalidation_PageScope_ValidThenClearThenInvalid() {
        let editor = makeDocumentWithRequiredTextField(hasValue: true)

        // Step 1: page is valid
        let before = editor.validate(path: pageID)
        guard case .page(let beforeValidation) = before else {
            XCTFail("Expected .page before clear"); return
        }
        XCTAssertEqual(beforeValidation.status, .valid)

        // Step 2: clear the text value
        enterValue(into: editor, fieldID: textFieldID, value: .string(""))

        // Step 3: page should now be invalid
        let after = editor.validate(path: pageID)
        guard case .page(let afterValidation) = after else {
            XCTFail("Expected .page after clear"); return
        }
        XCTAssertEqual(afterValidation.status, .invalid)
    }

    // MARK: - 23. Row/Cell path validation

    func testValidatePath_RowPath_ReturnsDotRowValidity() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/fp-1/row-1")

        guard case .row(let rowValidity) = result else {
            XCTFail("Expected .row for row path")
            return
        }
        XCTAssertEqual(rowValidity.rowId, "row-1")
        XCTAssertEqual(rowValidity.status, .invalid)
    }

    func testValidatePath_CellPath_ReturnsDotCellValidity() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/fp-1/row-1/col-required")

        guard case .cell(let cellValidity) = result else {
            XCTFail("Expected .cell for cell path")
            return
        }
        XCTAssertEqual(cellValidity.columnId, "col-required")
        XCTAssertEqual(cellValidity.status, .invalid)
    }

    func testValidatePath_InvalidColumnId_ReturnsNotFound() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/fp-1/row-1/missing-column")

        if case .notFound = result { } else {
            XCTFail("Expected .notFound for invalid columnId")
        }
    }

    func testValidatePath_InvalidRowId_ReturnsNotFound() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/fp-1/missing-row")

        if case .notFound = result { } else {
            XCTFail("Expected .notFound for invalid rowId")
        }
    }

    func testValidatePath_InvalidFieldPositionId_ReturnsNotFound() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/missing-fp")

        if case .notFound = result { } else {
            XCTFail("Expected .notFound for invalid fieldPositionId")
        }
    }

    func testValidatePath_OptionalCellWithValue_ReturnsCellValid() {
        let editor = makeTableEditorForRowCellPathValidation()
        let result = editor.validate(path: "page-1/fp-1/row-1/col-optional")

        guard case .cell(let cellValidity) = result else {
            XCTFail("Expected .cell for optional column with value")
            return
        }
        XCTAssertEqual(cellValidity.status, .valid)
    }
}
