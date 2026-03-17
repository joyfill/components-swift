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
}
