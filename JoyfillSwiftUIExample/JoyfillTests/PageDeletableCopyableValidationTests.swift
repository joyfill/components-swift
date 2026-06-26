import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Tests for the per-page `deletable` and `copyable` controls introduced in NO-2007.
///
/// Feature spec:
/// - `Page.deletable = false`  → hide delete button; `canDeletePage` returns `(false, [])`
/// - `Page.copyable = [.none]` → hide duplicate button
/// - `Page.copyable = [.withValues, .withoutValues]` → show dialog on duplicate
/// - Copied pages always reset to `deletable=true, copyable=[.withValues,.withoutValues]`
/// - Last-page protection still applies even when `deletable=true`
final class PageDeletableCopyableValidationTests: XCTestCase {

    // MARK: - Helpers

    private func makeEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    /// Applies a closure to the page with the given id and returns the modified document.
    private func applyToPage(
        _ pageID: String,
        in document: JoyDoc,
        modify: (inout Page) -> Void
    ) -> JoyDoc {
        var doc = document
        guard var file = doc.files.first,
              var pages = file.pages,
              let idx = pages.firstIndex(where: { $0.id == pageID }) else { return doc }
        modify(&pages[idx])
        file.pages = pages
        doc.files[0] = file
        return doc
    }

    // MARK: - canDeletePage: deletable=false

    /// A non-deletable page among multiple pages must not be deletable.
    func testCanDeletePage_DeletableFalse_ReturnsFalse() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()   // page id: "6629fab320fca7c8107a6cf6"
            .addSecondPage()              // page id: "second_page_id_12345"
            .setHeadingText()
            .setTextField()

        document = applyToPage("second_page_id_12345", in: document) { $0.deletable = false }

        let editor = makeEditor(document: document)
        let result = editor.canDeletePage(pageID: "second_page_id_12345")
        XCTAssertFalse(result.canDelete, "Non-deletable page should not be deletable even when multiple pages exist.")
    }

    /// A non-deletable page must return empty warnings (no user-facing message per spec).
    func testCanDeletePage_DeletableFalse_ReturnsEmptyWarnings() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()

        document = applyToPage("second_page_id_12345", in: document) { $0.deletable = false }

        let editor = makeEditor(document: document)
        let result = editor.canDeletePage(pageID: "second_page_id_12345")
        XCTAssertTrue(result.warnings.isEmpty, "Non-deletable page should return empty warnings (spec: hide button silently).")
    }

    /// `deletePage` must return false and leave the document unchanged for a non-deletable page.
    func testDeletePage_DeletableFalse_ReturnsFalseAndPageUnchanged() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()

        document = applyToPage("second_page_id_12345", in: document) { $0.deletable = false }

        let editor = makeEditor(document: document)
        let initialCount = editor.document.files.first?.pages?.count ?? 0

        let result = editor.deletePage(pageID: "second_page_id_12345")

        XCTAssertFalse(result, "deletePage should return false for a non-deletable page.")
        let finalCount = editor.document.files.first?.pages?.count ?? 0
        XCTAssertEqual(finalCount, initialCount, "Page count must not change when deletion is blocked by deletable=false.")
        XCTAssertNotNil(
            editor.document.files.first?.pages?.first(where: { $0.id == "second_page_id_12345" }),
            "Non-deletable page must still exist after failed deletion."
        )
    }

    // MARK: - canDeletePage: deletable=true still works

    /// A page with `deletable=true` among multiple pages must be deletable.
    func testCanDeletePage_DeletableTrue_MultiplePages_ReturnsTrue() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()

        document = applyToPage("second_page_id_12345", in: document) { $0.deletable = true }

        let editor = makeEditor(document: document)
        let result = editor.canDeletePage(pageID: "second_page_id_12345")
        XCTAssertTrue(result.canDelete, "Page with deletable=true should be deletable when other pages exist.")
        XCTAssertTrue(result.warnings.isEmpty, "No warnings expected for a straightforward deletion.")
    }

    // MARK: - canDeletePage: last page protection takes priority

    /// Last-page protection fires before the `deletable` check — a single page is still blocked.
    func testCanDeletePage_LastPage_BlockedEvenWhenDeletableIsTrue() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        document = applyToPage("6629fab320fca7c8107a6cf6", in: document) { $0.deletable = true }

        let editor = makeEditor(document: document)
        let result = editor.canDeletePage(pageID: "6629fab320fca7c8107a6cf6")
        XCTAssertFalse(result.canDelete, "Last page must not be deletable even if deletable=true.")
        XCTAssertFalse(result.warnings.isEmpty, "Last page protection should return a warning message.")
    }

    // MARK: - duplicatePage: resets deletable=true

    /// After duplication the copy should always have `deletable=true`,
    /// regardless of what the original page had.
    func testDuplicatePage_ResetsDeletableToTrue_WhenOriginalIsFalse() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        document = applyToPage(pageID, in: document) { $0.deletable = false }

        let editor = makeEditor(document: document)
        editor.duplicatePage(pageID: pageID)

        let firstFile = editor.document.files.first
        let pageOrder = firstFile?.pageOrder
        guard let duplicatedPageID = pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        XCTAssertTrue(duplicatedPage.deletable, "Duplicated page must have deletable=true regardless of original.")
    }

    // MARK: - duplicatePage: resets copyable=[.withValues,.withoutValues]

    /// After duplication the copy should always have full copyable access.
    func testDuplicatePage_ResetsCopyableToFullAccess_WhenOriginalIsNone() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        document = applyToPage(pageID, in: document) { $0.copyable = [.none] }

        let editor = makeEditor(document: document)
        editor.duplicatePage(pageID: pageID)

        let firstFile = editor.document.files.first
        let pageOrder = firstFile?.pageOrder
        guard let duplicatedPageID = pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        XCTAssertEqual(duplicatedPage.copyable, [.withValues, .withoutValues],
                       "Duplicated page must always have copyable=[.withValues,.withoutValues].")
    }

    /// Original has only one copy mode — duplicate should still be fully copyable.
    func testDuplicatePage_ResetsCopyableToFullAccess_WhenOriginalIsWithValuesOnly() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        document = applyToPage(pageID, in: document) { $0.copyable = [.withValues] }

        let editor = makeEditor(document: document)
        editor.duplicatePage(pageID: pageID)

        let firstFile = editor.document.files.first
        let pageOrder = firstFile?.pageOrder
        guard let duplicatedPageID = pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        XCTAssertEqual(duplicatedPage.copyable, [.withValues, .withoutValues],
                       "Duplicated page must always have full copyable even when original had only withValues.")
    }

    // MARK: - duplicatePage: original page properties unchanged

    /// Duplication must not mutate the original page's `deletable` or `copyable`.
    func testDuplicatePage_OriginalPagePropertiesUnchanged() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setHeadingText()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        document = applyToPage(pageID, in: document) {
            $0.deletable = false
            $0.copyable = [.none]
        }

        let editor = makeEditor(document: document)
        editor.duplicatePage(pageID: pageID)

        let originalPage = editor.document.files.first?.pages?.first(where: { $0.id == pageID })
        XCTAssertNotNil(originalPage, "Original page must still exist after duplication.")
        XCTAssertFalse(originalPage?.deletable ?? true, "Original page deletable must not be changed by duplication.")
        XCTAssertEqual(originalPage?.copyable, [.none], "Original page copyable must not be changed by duplication.")
    }

    // MARK: - copyWithValues behaviour

    /// Duplicate with `copyWithValues=false` should clear values only on the new page's fields.
    func testDuplicatePage_WithoutValues_ClearsOnlyDuplicatedPageFieldValues() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        let editor = makeEditor(document: document)

        XCTAssertFalse(editor.document.fields.isEmpty, "Test requires at least one field.")

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        // Find the duplicated page
        let firstFile = editor.document.files.first
        let pageOrder = firstFile?.pageOrder
        guard let duplicatedPageID = pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        // Collect the field IDs that belong to the duplicated page
        let duplicatedFieldIDs = Set(duplicatedPage.fieldPositions?.compactMap { $0.field } ?? [])
        XCTAssertFalse(duplicatedFieldIDs.isEmpty, "Duplicated page should have field positions.")

        // Only those fields should have nil values
        let duplicatedFields = editor.document.fields.filter { duplicatedFieldIDs.contains($0.id ?? "") }
        for field in duplicatedFields {
            XCTAssertNil(field.value, "copyWithValues=false should nil out the value of duplicated page field '\(field.id ?? "")'.")
        }
    }

    /// Duplicate with `copyWithValues=true` (default) should preserve values on the new page's fields.
    func testDuplicatePage_WithValues_PreservesDuplicatedPageFieldValues() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        let editor = makeEditor(document: document)

        XCTAssertFalse(editor.document.fields.isEmpty, "Test requires at least one field.")

        editor.duplicatePage(pageID: pageID, copyWithValues: true)

        // Find the duplicated page
        let firstFile = editor.document.files.first
        let pageOrder = firstFile?.pageOrder
        guard let duplicatedPageID = pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        let duplicatedFieldIDs = Set(duplicatedPage.fieldPositions?.compactMap { $0.field } ?? [])
        let duplicatedFields = editor.document.fields.filter { duplicatedFieldIDs.contains($0.id ?? "") }

        let hasValue = duplicatedFields.contains(where: { $0.value != nil })
        XCTAssertTrue(hasValue, "copyWithValues=true should preserve at least one field value on the duplicated page.")
    }

    /// Regression: copying "without values" must NOT drop the `value` key on table/collection
    /// fields. The JSON schema marks `value` as required for those types, so nilling it out
    /// (which removes the key) makes the duplicated document fail schema validation. They must
    /// instead be cleared to an empty array so the key survives.
    func testDuplicatePage_WithoutValues_TableFieldKeepsEmptyValueArray() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()

        // Add a table field (with rows) positioned on the page that will be duplicated.
        var tableField = JoyDocField()
        tableField.id = "regression_table_field"
        tableField.type = "table"
        tableField.file = "6629fab3c0ba3fb775b4a55c"
        tableField.rowOrder = ["regression_row_1"]
        tableField.value = .valueElementArray([ValueElement(id: "regression_row_1")])
        document.fields.append(tableField)

        let tablePosition = FieldPosition(dictionary: [
            "field": "regression_table_field",
            "displayType": "original",
            "width": 12, "height": 8, "x": 0, "y": 16,
            "_id": "regression_table_position",
            "type": "table"
        ])
        document.files[0].pages?[0].fieldPositions?.append(tablePosition)

        let pageID = "6629fab320fca7c8107a6cf6"
        let editor = makeEditor(document: document)

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        // Locate the duplicated page and its table field.
        let firstFile = editor.document.files.first
        guard let duplicatedPageID = firstFile?.pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }
        let duplicatedFieldIDs = Set(duplicatedPage.fieldPositions?.compactMap { $0.field } ?? [])
        let duplicatedFields = editor.document.fields.filter { duplicatedFieldIDs.contains($0.id ?? "") }
        guard let duplicatedTable = duplicatedFields.first(where: { $0.fieldType == .table }) else {
            XCTFail("Duplicated table field not found on the duplicated page.")
            return
        }

        // The required `value` key must still exist and be an (empty) array, not absent.
        XCTAssertNotNil(duplicatedTable.dictionary["value"],
                        "Table field must keep its required `value` key when copied without values.")
        let valueArray = duplicatedTable.dictionary["value"] as? [Any]
        XCTAssertNotNil(valueArray, "Table field `value` must be an array when copied without values.")
        XCTAssertTrue(valueArray?.isEmpty ?? false, "Table field rows must be cleared when copied without values.")
        XCTAssertEqual(duplicatedTable.rowOrder ?? ["non-empty"], [],
                       "Table field rowOrder must be cleared to stay consistent with the emptied value.")
    }

    /// Regression: same as the table case, but for collection fields. The schema marks
    /// `value` as required for collections too, so copying "without values" must clear it to
    /// an empty array (keeping the key) rather than nilling it out (dropping the key).
    func testDuplicatePage_WithoutValues_CollectionFieldKeepsEmptyValueArray() {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()

        // Add a collection field (with items) positioned on the page that will be duplicated.
        var collectionField = JoyDocField()
        collectionField.id = "regression_collection_field"
        collectionField.type = "collection"
        collectionField.file = "6629fab3c0ba3fb775b4a55c"
        collectionField.value = .valueElementArray([ValueElement(id: "regression_item_1")])
        document.fields.append(collectionField)

        let collectionPosition = FieldPosition(dictionary: [
            "field": "regression_collection_field",
            "displayType": "original",
            "width": 12, "height": 10, "x": 0, "y": 24,
            "_id": "regression_collection_position",
            "type": "collection"
        ])
        document.files[0].pages?[0].fieldPositions?.append(collectionPosition)

        let pageID = "6629fab320fca7c8107a6cf6"
        let editor = makeEditor(document: document)

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        // Locate the duplicated page and its collection field.
        let firstFile = editor.document.files.first
        guard let duplicatedPageID = firstFile?.pageOrder?.first(where: { $0 != pageID }),
              let duplicatedPage = firstFile?.pages?.first(where: { $0.id == duplicatedPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }
        let duplicatedFieldIDs = Set(duplicatedPage.fieldPositions?.compactMap { $0.field } ?? [])
        let duplicatedFields = editor.document.fields.filter { duplicatedFieldIDs.contains($0.id ?? "") }
        guard let duplicatedCollection = duplicatedFields.first(where: { $0.fieldType == .collection }) else {
            XCTFail("Duplicated collection field not found on the duplicated page.")
            return
        }

        // The required `value` key must still exist and be an (empty) array, not absent.
        XCTAssertNotNil(duplicatedCollection.dictionary["value"],
                        "Collection field must keep its required `value` key when copied without values.")
        let valueArray = duplicatedCollection.dictionary["value"] as? [Any]
        XCTAssertNotNil(valueArray, "Collection field `value` must be an array when copied without values.")
        XCTAssertTrue(valueArray?.isEmpty ?? false, "Collection field items must be cleared when copied without values.")
    }

    // MARK: - copyWithValues=false: original page fields untouched

    /// `copyWithValues=false` must only clear the NEW page's fields — the original page's
    /// field values must remain intact.
    func testDuplicatePage_WithoutValues_OriginalPageFieldsUnchanged() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .setTextField()

        let pageID = "6629fab320fca7c8107a6cf6"
        let editor = makeEditor(document: document)

        // Collect the original page's field IDs before duplication.
        let originalPage = editor.document.files.first?.pages?.first(where: { $0.id == pageID })
        let originalFieldIDs = Set(originalPage?.fieldPositions?.compactMap { $0.field } ?? [])
        XCTAssertFalse(originalFieldIDs.isEmpty, "Test requires original page to have field positions.")

        // Snapshot which original fields have values before the duplicate.
        let fieldsBefore = editor.document.fields.filter { originalFieldIDs.contains($0.id ?? "") }
        let valuesBefore = fieldsBefore.compactMap { $0.value }
        XCTAssertFalse(valuesBefore.isEmpty, "Test requires at least one original field with a value.")

        editor.duplicatePage(pageID: pageID, copyWithValues: false)

        // Original page fields must still have their values.
        let fieldsAfter = editor.document.fields.filter { originalFieldIDs.contains($0.id ?? "") }
        let valuesAfter = fieldsAfter.compactMap { $0.value }
        XCTAssertEqual(valuesAfter.count, valuesBefore.count,
                       "copyWithValues=false must not clear the original page's field values.")
    }

    // MARK: - duplicatePage: shared field between alt-view and web page duplicated only once
    func testDuplicatePage_SharedField_BetweenAltViewAndWebPage_IsNotDuplicatedTwice() {
        let pageID       = "shared_test_page_001"
        let sharedFieldID = "shared_test_field_001"

        // Build one field that lives on both the web page and the alternate-view page.
        var sharedField = JoyDocField()
        sharedField.id    = sharedFieldID
        sharedField.type  = "text"
        sharedField.value = .string("Original value")

        let sharedFieldPos = FieldPosition(dictionary: [
            "field":       sharedFieldID,
            "displayType": "original",
            "width":       4,
            "height":      8,
            "x":           0,
            "y":           0,
            "_id":         "shared_pos_id_001",
            "type":        "text"
        ])

        // Web page — references the shared field.
        var webPage = Page()
        webPage.id             = pageID
        webPage.name           = "Page 1"
        webPage.fieldPositions = [sharedFieldPos]

        // Alternate-view page — same pageID, same field position.
        var altPage = Page()
        altPage.id             = pageID
        altPage.name           = "Page 1"
        altPage.fieldPositions = [sharedFieldPos]

        var altView = ModelView()
        altView.id        = "alt_view_id_001"
        altView.type      = "web"
        altView.pages     = [altPage]
        altView.pageOrder = [pageID]

        var file = File()
        file.id        = "file_id_001"
        file.pages     = [webPage]
        file.views     = [altView]
        file.pageOrder = [pageID]

        var document = JoyDoc()
        document.fields = [sharedField]
        document.files  = [file]

        let editor           = makeEditor(document: document)
        let fieldCountBefore = editor.document.fields.count // 1

        editor.duplicatePage(pageID: pageID)

        // ── 1. Exactly one new field added, not two ───────────────────────────
        let fieldCountAfter = editor.document.fields.count
        XCTAssertEqual(
            fieldCountAfter, fieldCountBefore + 1,
            "A field shared between the alt-view and web page must be duplicated only once, not twice."
        )

        // ── 2. Duplicated page exists ─────────────────────────────────────────
        guard let newPageID = editor.document.files.first?.pageOrder?.first(where: { $0 != pageID }),
              let newPage   = editor.document.files.first?.pages?.first(where: { $0.id == newPageID }) else {
            XCTFail("Duplicated page not found.")
            return
        }

        // ── 3. New page has exactly one field position ────────────────────────
        let newFieldIDs = newPage.fieldPositions?.compactMap { $0.field } ?? []
        XCTAssertEqual(newFieldIDs.count, 1,
                       "Duplicated web page should have exactly 1 field position.")

        // ── 4. That position uses a new ID (not the original) ─────────────────
        let newFieldID = newFieldIDs.first
        XCTAssertNotEqual(newFieldID, sharedFieldID,
                          "Duplicated page field position must use a newly generated ID.")

        // ── 5. The new ID resolves to a real field in document.fields ─────────
        XCTAssertNotNil(
            editor.document.fields.first(where: { $0.id == newFieldID }),
            "The new field position must reference a field that actually exists in document.fields."
        )

        // ── 6. Alt-view new page also points to the SAME new field ID ─────────
        let altNewPage    = editor.document.files.first?.views?.first?.pages?.first(where: { $0.id == newPageID })
        let altNewFieldID = altNewPage?.fieldPositions?.first?.field
        XCTAssertEqual(altNewFieldID, newFieldID,
                       "Alt-view duplicated page must point to the same new field ID as the web page, not a separate copy.")
    }

    // MARK: - canDeletePage: deletable key absent defaults to true

    /// A page that has no `deletable` key set (i.e., the default) must be treated
    /// as deletable — `canDeletePage` should return `(true, [])`.
    func testCanDeletePage_DeletableKeyAbsent_DefaultsToTrue() {
        // addSecondPage() creates a page with no deletable key set — raw default.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setPageWithFieldPosition()
            .addSecondPage()
            .setHeadingText()
            .setTextField()

        let editor = makeEditor(document: document)
        let result = editor.canDeletePage(pageID: "second_page_id_12345")
        XCTAssertTrue(result.canDelete, "Page with no deletable key should be deletable by default.")
        XCTAssertTrue(result.warnings.isEmpty, "No warnings expected for a default-deletable page.")
    }
}
