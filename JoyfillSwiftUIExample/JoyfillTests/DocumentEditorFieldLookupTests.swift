import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Covers `DocumentEditor.field(identifier:)` and `DocumentEditor.field(title:)`,
/// the sibling lookups to the existing `field(fieldID:)`.
final class DocumentEditorFieldLookupTests: XCTestCase {

    // MARK: - Helpers

    private func makeField(id: String, identifier: String? = nil, title: String? = nil) -> JoyDocField {
        var field = JoyDocField()
        field.id = id
        field.identifier = identifier
        field.title = title
        field.fieldType = .text
        return field
    }

    private func documentEditor(fields: [JoyDocField]) -> DocumentEditor {
        var document = JoyDoc()
        document.id = "test_doc_1"
        document.identifier = "doc_test_1"
        document.fields = fields
        return DocumentEditor(document: document, validateSchema: false)
    }

    // MARK: - field(identifier:) — input validation

    func testFieldByIdentifier_NilIdentifier_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", identifier: "field_text1")])
        XCTAssertNil(editor.field(identifier: nil))
    }

    func testFieldByIdentifier_EmptyStringNoMatch_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", identifier: "field_text1")])
        XCTAssertNil(editor.field(identifier: ""))
    }

    // MARK: - field(identifier:) — positive match

    func testFieldByIdentifier_ValidIdentifier_ReturnsMatchingField() {
        let field = makeField(id: "text1", identifier: "field_text1", title: "Text 1")
        let editor = documentEditor(fields: [field])
        XCTAssertEqual(editor.field(identifier: "field_text1")?.id, "text1")
    }

    func testFieldByIdentifier_MatchAmongMultipleFields_ReturnsCorrectField() {
        let field1 = makeField(id: "text1", identifier: "field_text1")
        let field2 = makeField(id: "text2", identifier: "field_text2")
        let field3 = makeField(id: "text3", identifier: "field_text3")
        let editor = documentEditor(fields: [field1, field2, field3])
        XCTAssertEqual(editor.field(identifier: "field_text2")?.id, "text2")
    }

    // MARK: - field(identifier:) — no match

    func testFieldByIdentifier_NoMatchingIdentifier_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", identifier: "field_text1")])
        XCTAssertNil(editor.field(identifier: "field_does_not_exist"))
    }

    func testFieldByIdentifier_FieldWithNilIdentifierProperty_ExcludedFromMatch() {
        let field = makeField(id: "text1", identifier: nil)
        let editor = documentEditor(fields: [field])
        XCTAssertNil(editor.field(identifier: "field_text1"))
    }

    func testFieldByIdentifier_EmptyDocument_ReturnsNil() {
        let editor = documentEditor(fields: [])
        XCTAssertNil(editor.field(identifier: "field_text1"))
    }

    // MARK: - field(identifier:) — exactness

    func testFieldByIdentifier_CaseSensitive_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", identifier: "field_text1")])
        XCTAssertNil(editor.field(identifier: "FIELD_TEXT1"))
    }

    func testFieldByIdentifier_WhitespaceMismatch_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", identifier: "field_text1")])
        XCTAssertNil(editor.field(identifier: "field_text1 "))
    }

    // MARK: - field(identifier:) — duplicates

    func testFieldByIdentifier_DuplicateIdentifiers_ReturnsOneMatchingField() {
        let field1 = makeField(id: "text1", identifier: "field_dup")
        let field2 = makeField(id: "text2", identifier: "field_dup")
        let editor = documentEditor(fields: [field1, field2])
        // Order is not guaranteed (fieldMap is a Dictionary), so only assert
        // that *a* field with the duplicate identifier is returned.
        let result = editor.field(identifier: "field_dup")
        XCTAssertTrue(result?.id == "text1" || result?.id == "text2")
    }

    // MARK: - field(title:) — input validation

    func testFieldByTitle_NilTitle_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", title: "Text 1")])
        XCTAssertNil(editor.field(title: nil))
    }

    func testFieldByTitle_EmptyStringNoMatch_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", title: "Text 1")])
        XCTAssertNil(editor.field(title: ""))
    }

    // MARK: - field(title:) — positive match

    func testFieldByTitle_ValidTitle_ReturnsMatchingField() {
        let field = makeField(id: "text1", identifier: "field_text1", title: "Text 1")
        let editor = documentEditor(fields: [field])
        XCTAssertEqual(editor.field(title: "Text 1")?.id, "text1")
    }

    func testFieldByTitle_MatchAmongMultipleFields_ReturnsCorrectField() {
        let field1 = makeField(id: "text1", title: "Text 1")
        let field2 = makeField(id: "text2", title: "Text 2")
        let field3 = makeField(id: "text3", title: "Text 3")
        let editor = documentEditor(fields: [field1, field2, field3])
        XCTAssertEqual(editor.field(title: "Text 2")?.id, "text2")
    }

    // MARK: - field(title:) — no match

    func testFieldByTitle_NoMatchingTitle_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", title: "Text 1")])
        XCTAssertNil(editor.field(title: "Does Not Exist"))
    }

    func testFieldByTitle_FieldWithNilTitleProperty_ExcludedFromMatch() {
        let field = makeField(id: "text1", title: nil)
        let editor = documentEditor(fields: [field])
        XCTAssertNil(editor.field(title: "Text 1"))
    }

    func testFieldByTitle_EmptyDocument_ReturnsNil() {
        let editor = documentEditor(fields: [])
        XCTAssertNil(editor.field(title: "Text 1"))
    }

    // MARK: - field(title:) — exactness

    func testFieldByTitle_CaseSensitive_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", title: "Text 1")])
        XCTAssertNil(editor.field(title: "TEXT 1"))
    }

    func testFieldByTitle_WhitespaceMismatch_ReturnsNil() {
        let editor = documentEditor(fields: [makeField(id: "text1", title: "Text 1")])
        XCTAssertNil(editor.field(title: "Text 1 "))
    }

    // MARK: - field(title:) — duplicates

    func testFieldByTitle_DuplicateTitles_ReturnsOneMatchingField() {
        let field1 = makeField(id: "text1", title: "Duplicate Title")
        let field2 = makeField(id: "text2", title: "Duplicate Title")
        let editor = documentEditor(fields: [field1, field2])
        let result = editor.field(title: "Duplicate Title")
        XCTAssertTrue(result?.id == "text1" || result?.id == "text2")
    }

    // MARK: - Disambiguation between identifier and title

    func testFieldByIdentifierVsTitle_DoesNotCrossMatch() {
        let fieldWithIdentifierX = makeField(id: "text1", identifier: "X", title: "Text 1")
        let fieldWithTitleX = makeField(id: "text2", identifier: "field_text2", title: "X")
        let editor = documentEditor(fields: [fieldWithIdentifierX, fieldWithTitleX])

        XCTAssertEqual(editor.field(identifier: "X")?.id, "text1")
        XCTAssertEqual(editor.field(title: "X")?.id, "text2")
    }

    // MARK: - Consistency with field(fieldID:)

    func testFieldByIdentifierAndTitle_ConsistentWithFieldByFieldID() {
        let field = makeField(id: "text1", identifier: "field_text1", title: "Text 1")
        let editor = documentEditor(fields: [field])

        let byFieldID = editor.field(fieldID: "text1")
        XCTAssertEqual(editor.field(identifier: "field_text1")?.id, byFieldID?.id)
        XCTAssertEqual(editor.field(title: "Text 1")?.id, byFieldID?.id)
    }
}
