//
//  PageDeletableCopyableMobileViewUITests.swift
//  JoyfillExample
//

import XCTest

final class PageDeletableCopyableMobileViewUITests: JoyfillUITestsBaseClass {
    override func getJSONFileNameForTest() -> String {
        return "PageDeletableCopyableMobileView"
    }

    override func getGotoLaunchArguments() -> [(String, String?)] {
        return [
            ("--page-delete-enabled", "true"),
            ("--page-duplicate-enabled", "true"),
        ]
    }

    private func openPageNavigationSheet() {
        let pageNavigationButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageNavigationButton.waitForExistence(timeout: 5), "Page navigation button should exist.")
        pageNavigationButton.tap()
    }

    /// Returns the mobile-view page row and its index within the current page-row query.
    /// The fixture's mobile-view page is intentionally restrictive (deletable=false,
    /// copyable=[with-values]) so the copy keeps that copyable and still becomes deletable.
    private func mobileViewPageRowOrFail(file: StaticString = #filePath, line: UInt = #line) -> (row: XCUIElement, index: Int)? {
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(pageRows.firstMatch.waitForExistence(timeout: 8), "Page rows should appear in the sheet.", file: file, line: line)

        let rows = pageRows.allElementsBoundByIndex
        guard let idx = rows.firstIndex(where: { $0.label.contains("Mobile View Page") || $0.staticTexts["Mobile View Page"].exists }) else {
            XCTFail("Mobile-view page row should be visible — confirms mobile view is active.", file: file, line: line)
            return nil
        }
        return (rows[idx], idx)
    }

    /// Confirms that after duplicating the mobile-view page, the new page is deletable
    /// and keeps the source `copyable=[with-values]` (a second tap duplicates directly,
    /// with no both-modes dialog). The source page stays non-deletable.
    func testDuplicateInMobileViewKeepsCopyableAndForcesDeletable() {
        openPageNavigationSheet()
        guard let original = mobileViewPageRowOrFail() else { return }

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        // Source page is restrictive in the fixture: no delete button should be visible on it.
        let originalDeleteBefore = original.row.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier")
        XCTAssertEqual(originalDeleteBefore.count, 0,
                       "Source mobile-view page is restrictive (deletable=false) — no delete button expected before duplication.")

        // 1. Tap the copyable (duplicate) icon on the original page. Because the source's
        //    copyable contains only with-values, this triggers a direct duplicate (no dialog).
        let duplicateButton = original.row.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button must exist on the mobile-view page.")
        duplicateButton.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 },
                      "Page count should increase by 1 after duplication.")

        // 2. Locate the duplicated row. The implementation inserts it at originalIdx + 1
        //    (not necessarily at the end of the list), so address it by that index.
        let duplicatedRow = pageRows.element(boundBy: original.index + 1)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear right after the original.")

        // 3. Duplicated page must be deletable — delete control is present.
        let dupDelete = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier")
        XCTAssertGreaterThan(dupDelete.count, 0,
                             "Duplicated page must show delete button (deletable forced to true).")

        // 4. Duplicated page keeps copyable=[with-values] only, so duplicate runs directly
        //    and does not offer the both-modes dialog.
        let dupDuplicate = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(dupDuplicate.exists,
                      "Duplicated page must show duplicate button (with-values is still allowed).")
        dupDuplicate.tap()

        let alert = app.alerts["Duplicate Page"]
        XCTAssertFalse(alert.waitForExistence(timeout: 2),
                       "Copy of a with-values-only page must not offer the both-modes dialog.")
        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 2 },
                      "Second duplicate should apply with-values directly and add another page.")

        // 5. Inverse assertion: the source page must NOT have been mutated in place by the
        //    duplicate flow. Its delete button should still be hidden (deletable=false).
        let originalRowAfter = pageRows.element(boundBy: original.index)
        let originalDeleteAfter = originalRowAfter.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier")
        XCTAssertEqual(originalDeleteAfter.count, 0,
                       "Source page's deletable=false must be preserved after duplication.")
    }

    /// Duplicates the mobile-view page, then taps delete on the duplicate and confirms
    /// the page is removed. Exercises the deletable reset: without it, the duplicate
    /// would inherit deletable=false from the (restrictive) source and have no delete button.
    func testDeleteDuplicatedPageInMobileViewRemovesIt() {
        openPageNavigationSheet()
        guard let original = mobileViewPageRowOrFail() else { return }

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        let duplicateButton = original.row.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button must exist on the mobile-view page.")
        duplicateButton.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 },
                      "Page count should increase by 1 after duplication.")

        let duplicatedRow = pageRows.element(boundBy: original.index + 1)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear right after the original.")

        let deleteButton = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier").firstMatch
        XCTAssertTrue(deleteButton.exists, "Delete button must be visible on the duplicated row (deletable reset to true).")
        deleteButton.tap()

        let confirmDelete = app.alerts.buttons["Delete"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 3), "Delete confirmation dialog should appear.")
        confirmDelete.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount },
                      "Page count should return to \(initialCount) after deleting the duplicate.")
    }
}
