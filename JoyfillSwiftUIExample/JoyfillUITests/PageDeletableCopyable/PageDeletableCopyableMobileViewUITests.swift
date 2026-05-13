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

    private func mobileViewPageRowOrFail(file: StaticString = #filePath, line: UInt = #line) -> XCUIElement? {
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(pageRows.firstMatch.waitForExistence(timeout: 8), "Page rows should appear in the sheet.", file: file, line: line)

        let row = pageRows.allElementsBoundByIndex.first { row in
            row.label.contains("Mobile View Page") || row.staticTexts["Mobile View Page"].exists
        }
        XCTAssertNotNil(row, "Mobile-view page row should be visible — confirms mobile view is active.", file: file, line: line)
        return row
    }

    /// Confirms that after duplicating the mobile-view page, the new page is rendered
    /// with the spec defaults: `deletable=true` (delete button visible) and
    /// `copyable=[withValues, withoutValues]` (duplicate dialog offers both modes).
    func testDuplicateInMobileViewProducesPageWithDeletableAndFullCopyable() {
        openPageNavigationSheet()
        guard let originalRow = mobileViewPageRowOrFail() else { return }

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        // 1. Tap the copyable (duplicate) icon on the original page.
        let duplicateButton = originalRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button must exist on the mobile-view page.")
        duplicateButton.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 },
                      "Page count should increase by 1 after duplication.")

        // 2. Locate the duplicated row (inserted right after the original).
        let duplicatedRow = pageRows.element(boundBy: initialCount)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear after the original.")

        // 3. Duplicated page must be deletable — delete control is present.
        let dupDelete = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier")
        XCTAssertGreaterThan(dupDelete.count, 0,
                             "Duplicated page must show delete button (deletable reset to true).")

        // 4. Duplicated page's copyable must include both with-values AND without-values.
        //    Tap its duplicate button and assert the dialog presents both options.
        let dupDuplicate = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(dupDuplicate.exists,
                      "Duplicated page must show duplicate button (copyable reset).")
        dupDuplicate.tap()

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Duplicate dialog should appear on the duplicated page.")
        let hasWithValues = alert.buttons["With Values"].exists || app.buttons["With Values"].exists
        let hasWithoutValues = alert.buttons["Without Values"].exists || app.buttons["Without Values"].exists
        XCTAssertTrue(hasWithValues, "Duplicated page's copyable must include with-values.")
        XCTAssertTrue(hasWithoutValues, "Duplicated page's copyable must include without-values.")
    }

    /// Duplicates the mobile-view page, then taps delete on the duplicate and confirms
    /// the page is removed.
    func testDeleteDuplicatedPageInMobileViewRemovesIt() {
        openPageNavigationSheet()
        guard let originalRow = mobileViewPageRowOrFail() else { return }

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        let duplicateButton = originalRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button must exist on the mobile-view page.")
        duplicateButton.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 },
                      "Page count should increase by 1 after duplication.")

        let duplicatedRow = pageRows.element(boundBy: initialCount)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear after the original.")

        let deleteButton = duplicatedRow.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier").firstMatch
        XCTAssertTrue(deleteButton.exists, "Delete button must be visible on the duplicated row.")
        deleteButton.tap()

        let confirmDelete = app.alerts.buttons["Delete"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 3), "Delete confirmation dialog should appear.")
        confirmDelete.tap()

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount },
                      "Page count should return to \(initialCount) after deleting the duplicate.")
    }
}
