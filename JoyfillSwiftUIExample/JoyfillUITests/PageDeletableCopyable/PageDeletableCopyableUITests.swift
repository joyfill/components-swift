//
//  PageDeletableCopyableUITests.swift
//  JoyfillExample
//
//  Created by Vivek on 30/03/26.
//

import XCTest

final class PageDeletableCopyableUITests: JoyfillUITestsBaseClass {
    private struct ExpectedPageBehavior {
        let name: String
        let isDeletable: Bool
        let hasWithValuesCopy: Bool
        let hasWithoutValuesCopy: Bool
        let canDuplicate: Bool
    }

    private func loadExpectedPageBehaviorFromJSON() throws -> [ExpectedPageBehavior] {
        let fileName = getJSONFileNameForTest()
        let bundle = Bundle(for: type(of: self))

        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw NSError(
                domain: "PageDeletableCopyableUITests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find \(fileName).json in UI test bundle resources."]
            )
        }

        let data = try Data(contentsOf: url)
        guard let root = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let files = root["files"] as? [[String: Any]],
              let firstFile = files.first,
              let pages = firstFile["pages"] as? [[String: Any]] else {
            throw NSError(
                domain: "PageDeletableCopyableUITests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON shape. Expected files[0].pages."]
            )
        }

        return pages.enumerated().map { index, page in
            let name = page["name"] as? String ?? "Page \(index + 1)"
            let isDeletable = page["deletable"] as? Bool ?? true
            let copyable = (page["copyable"] as? [Any])?.compactMap { $0 as? String } ?? ["with-values"]
            let hasWithValuesCopy = copyable.contains("with-values")
            let hasWithoutValuesCopy = copyable.contains("without-values")
            let canDuplicate = hasWithValuesCopy || hasWithoutValuesCopy
            return ExpectedPageBehavior(
                name: name,
                isDeletable: isDeletable,
                hasWithValuesCopy: hasWithValuesCopy,
                hasWithoutValuesCopy: hasWithoutValuesCopy,
                canDuplicate: canDuplicate
            )
        }
    }

    private func loadExpectedPagesOrFail(file: StaticString = #filePath, line: UInt = #line) -> [ExpectedPageBehavior]? {
        do {
            return try loadExpectedPageBehaviorFromJSON()
        } catch {
            XCTFail("Failed to load expected page behavior from JSON: \(error.localizedDescription)", file: file, line: line)
            return nil
        }
    }

    private func openPageNavigationSheet() {
        let pageNavigationButton = app.buttons["PageNavigationIdentifier"]
        XCTAssertTrue(pageNavigationButton.waitForExistence(timeout: 5), "Page navigation button should exist.")
        pageNavigationButton.tap()
    }

    private func waitForPageRowsInSheet(timeout: TimeInterval) -> Bool {
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        if pageRows.firstMatch.waitForExistence(timeout: timeout) {
            return true
        }

        // Retry opening the sheet once in case the first tap didn't present it.
        let pageNavigationButton = app.buttons["PageNavigationIdentifier"]
        if pageNavigationButton.exists && pageNavigationButton.isHittable {
            pageNavigationButton.tap()
        }

        return pageRows.firstMatch.waitForExistence(timeout: timeout)
    }

    private func visibleRows(from pageRows: XCUIElementQuery) -> [XCUIElement] {
        return pageRows.allElementsBoundByIndex.filter { $0.exists }
    }

    private func rowContainsPageName(_ row: XCUIElement, pageName: String) -> Bool {
        return row.label.contains(pageName) || row.staticTexts[pageName].exists
    }

    private func swipeUpInPageSheetOrFallback() {
        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists && scrollView.isHittable {
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82))
            let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.62))
            start.press(forDuration: 0.01, thenDragTo: end)
            return
        }

        app.swipeUp()
    }

    private func currentTestSelector(from name: String) -> String {
        let trimmed = name.hasSuffix("]") ? String(name.dropLast()) : name
        return trimmed.split(separator: " ").last.map(String.init) ?? name
    }

    private var usesReadonlyMode: Bool {
        let selector = currentTestSelector(from: self.name)
        return selector == "testReadonlyModeHidesDeleteAndDuplicateControlsEvenWhenEnabled"
    }

    private func firstTextFieldOrFail(requireHittable: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement? {
        let firstTextField = app.textFields.firstMatch
        XCTAssertTrue(firstTextField.waitForExistence(timeout: 5), "Expected at least one text field on the selected page.", file: file, line: line)
        guard firstTextField.exists else { return nil }

        if requireHittable {
            XCTAssertTrue(
                waitUntil(5) { firstTextField.exists && firstTextField.isHittable },
                "Expected first text field to become hittable before editing.",
                file: file,
                line: line
            )
            guard firstTextField.isHittable else { return nil }
        }

        return firstTextField
    }

    private func setFirstTextFieldValue(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let firstTextField = firstTextFieldOrFail(requireHittable: true, file: file, line: line) else { return }

        // Clearing can be flaky in UI tests; retry until we reliably set the exact value.
        for _ in 0..<3 {
            firstTextField.tap()
            firstTextField.clearTextReliably()
            firstTextField.typeText("\(text)\n")

            if let current = firstTextField.value as? String,
               current.trimmingCharacters(in: .whitespacesAndNewlines) == text {
                return
            }
        }

        let actualValue = (firstTextField.value as? String) ?? "<nil>"
        XCTFail(
            "Failed to set first text field to '\(text)'. Actual value: '\(actualValue)'",
            file: file,
            line: line
        )
    }

    private func firstTextFieldValue(file: StaticString = #filePath, line: UInt = #line) -> String? {
        guard let firstTextField = firstTextFieldOrFail(file: file, line: line) else { return nil }
        guard let value = firstTextField.value as? String else {
            XCTFail("Expected first text field to contain a string value.", file: file, line: line)
            return nil
        }
        return value
    }

    private func assertFieldTextVisible(_ expectedText: String, file: StaticString = #filePath, line: UInt = #line) {
        let textFieldPredicate = NSPredicate(format: "value == %@", expectedText)
        let matchingTextField = app.textFields.matching(textFieldPredicate).firstMatch
        if matchingTextField.waitForExistence(timeout: 2) {
            return
        }

        let staticText = app.staticTexts[expectedText]
        if staticText.waitForExistence(timeout: 2) {
            return
        }

        app.swipeUp()
        if matchingTextField.waitForExistence(timeout: 1) || staticText.waitForExistence(timeout: 1) {
            return
        }

        XCTFail("Expected to find text '\(expectedText)' in duplicated page, but it was not visible.", file: file, line: line)
    }

    private func assertStaticTextOccurrences(_ text: String, minimumCount: Int, file: StaticString = #filePath, line: UInt = #line) {
        func visibleCount() -> Int {
            app.staticTexts.matching(NSPredicate(format: "label == %@", text)).allElementsBoundByIndex.filter { $0.exists }.count
        }

        if waitUntil(2, condition: { visibleCount() >= minimumCount }) {
            return
        }

        app.swipeUp()
        if waitUntil(2, condition: { visibleCount() >= minimumCount }) {
            return
        }

        let actualCount = visibleCount()
        XCTFail(
            "Expected at least \(minimumCount) visible static texts with value '\(text)', found \(actualCount).",
            file: file,
            line: line
        )
    }

    private func findRow(named pageName: String, in pageRows: XCUIElementQuery, maxScrolls: Int) -> XCUIElement? {
        for _ in 0..<maxScrolls {
            let rows = visibleRows(from: pageRows)
            if let match = rows.first(where: { rowContainsPageName($0, pageName: pageName) }) {
                return match
            }
            swipeUpInPageSheetOrFallback()
        }
        return nil
    }

    private func tapDeleteCancelButtonOrFail(file: StaticString = #filePath, line: UInt = #line) {
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "Delete confirmation should appear.", file: file, line: line)

        let cancelCandidates = ["Cancel", "Keep", "No", "Don't Delete"]
        for title in cancelCandidates where alert.buttons[title].exists {
            alert.buttons[title].tap()
            return
        }

        XCTFail("Could not find a cancel-style button on delete confirmation.", file: file, line: line)
    }

    private func chooseDuplicateModeOrFail(_ modeButtonTitle: String, file: StaticString = #filePath, line: UInt = #line) {
        let duplicateAlert = app.alerts.firstMatch
        XCTAssertTrue(duplicateAlert.waitForExistence(timeout: 3), "Duplicate mode dialog should appear.", file: file, line: line)

        if duplicateAlert.buttons[modeButtonTitle].exists {
            duplicateAlert.buttons[modeButtonTitle].tap()
            return
        }

        if app.buttons[modeButtonTitle].exists {
            app.buttons[modeButtonTitle].tap()
            return
        }

        XCTFail("Could not find duplicate mode button '\(modeButtonTitle)'.", file: file, line: line)
    }

    override func getJSONFileNameForTest() -> String {
        return "PageDeletableCopyable"
    }

    override func getGotoLaunchArguments() -> [(String, String?)] {
        // Reuse base setup; this suite only needs additional page-control launch flags.
        var args: [(String, String?)] = [
            ("--page-delete-enabled", "true"),
            ("--page-duplicate-enabled", "true"),
        ]

        // Verify readonly behavior even when page controls are explicitly enabled.
        if usesReadonlyMode {
            args.append(("--mode", "readonly"))
        }

        return args
    }

    func testCheckPageDeletableCopyableMatchesJSON() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }

        XCTAssertFalse(expectedPages.isEmpty, "Expected at least one page in the JSON fixture.")

        openPageNavigationSheet()

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        var actualByName: [String: (hasDuplicate: Bool, hasDelete: Bool)] = [:]

        for _ in 0..<(expectedPages.count * 8) {
            let rows = visibleRows(from: pageRows)

            for row in rows {
                guard let matchingPageName = expectedPages.first(where: { rowContainsPageName(row, pageName: $0.name) })?.name else {
                    continue
                }

                let hasDuplicate = row.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").count > 0
                let hasDelete = row.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier").count > 0
                actualByName[matchingPageName] = (hasDuplicate, hasDelete)
            }

            if actualByName.count == expectedPages.count {
                break
            }

            swipeUpInPageSheetOrFallback()
        }

        let missingPages = expectedPages.map(\.name).filter { actualByName[$0] == nil }
        XCTAssertTrue(missingPages.isEmpty, "Some pages were not found in page sheet: \(missingPages)")

        for expected in expectedPages {
            guard let actual = actualByName[expected.name] else { continue }
            XCTAssertEqual(actual.hasDuplicate, expected.canDuplicate, "Duplicate button mismatch for \(expected.name)")
            XCTAssertEqual(actual.hasDelete, expected.isDeletable, "Delete button mismatch for \(expected.name)")
        }
    }

    func testDeletePageRemovesItFromPageSheet() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }

        guard let pageToDelete = expectedPages.first(where: { $0.isDeletable }) else {
            XCTFail("Need at least one deletable page in fixture.")
            return
        }

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        var rowToDelete: XCUIElement?
        for _ in 0..<(expectedPages.count * 8) {
            let rows = visibleRows(from: pageRows)
            if let matched = rows.first(where: { rowContainsPageName($0, pageName: pageToDelete.name) }) {
                rowToDelete = matched
                break
            }

            swipeUpInPageSheetOrFallback()
        }

        guard let rowToDelete else {
            XCTFail("Could not find deletable page row '\(pageToDelete.name)'.")
            return
        }

        let deleteButton = rowToDelete.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier").firstMatch
        XCTAssertTrue(deleteButton.exists, "Delete button should exist for deletable page '\(pageToDelete.name)'.")
        deleteButton.tap()

        let confirmDeleteButton = app.alerts.buttons["Delete"]
        XCTAssertTrue(confirmDeleteButton.waitForExistence(timeout: 3), "Delete confirmation should appear.")
        confirmDeleteButton.tap()

        let closeSheetButton = app.buttons["ClosePageSelectionSheetIdentifier"]
        if closeSheetButton.waitForExistence(timeout: 2) {
            closeSheetButton.tap()
        }

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear after deletion.")

        let refreshedPageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let remainingExpectedPageNames = Set(expectedPages.map(\.name).filter { $0 != pageToDelete.name })
        var foundRemainingPageNames = Set<String>()

        for _ in 0..<(expectedPages.count * 8) {
            let rows = visibleRows(from: refreshedPageRows)

            for row in rows {
                if rowContainsPageName(row, pageName: pageToDelete.name) {
                    XCTFail("Deleted page '\(pageToDelete.name)' should not appear in page sheet.")
                    return
                }

                for pageName in remainingExpectedPageNames where rowContainsPageName(row, pageName: pageName) {
                    foundRemainingPageNames.insert(pageName)
                }
            }

            if foundRemainingPageNames == remainingExpectedPageNames {
                break
            }

            swipeUpInPageSheetOrFallback()
        }

        let missingRemainingPages = remainingExpectedPageNames.subtracting(foundRemainingPageNames)
        XCTAssertTrue(missingRemainingPages.isEmpty, "Missing expected pages after deletion: \(Array(missingRemainingPages))")
    }

    func testDuplicateWithValuesCopiesFieldData() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }
        guard let sourceIndex = expectedPages.firstIndex(where: { $0.name == "Page 4" }) else {
            XCTFail("Page 4 is required for this test.")
            return
        }
        let sourcePageName = "Page 4"

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let sourcePageRow = pageRows.element(boundBy: sourceIndex)
        XCTAssertTrue(sourcePageRow.exists, "Page 4 row should exist before duplication.")
        XCTAssertTrue(rowContainsPageName(sourcePageRow, pageName: sourcePageName), "Expected source row at index \(sourceIndex) to be Page 4.")
        sourcePageRow.tap()

        let uniqueValue = "with-values-copy-\(UUID().uuidString.prefix(8))"
        setFirstTextFieldValue(uniqueValue)
        XCTAssertEqual(firstTextFieldValue(), uniqueValue, "Page 4 should keep the edited value before duplication.")

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear for duplication.")
        let initialCount = pageRows.count
        XCTAssertTrue(pageRows.element(boundBy: sourceIndex).exists, "Page 4 row should exist for duplication.")

        let sourceRow = pageRows.element(boundBy: sourceIndex)
        let duplicateButton = sourceRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button should exist for Page 4.")
        duplicateButton.tap()
        chooseDuplicateModeOrFail("With Values")

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 }, "Page count should increase by 1 after duplication.")

        let duplicatedRow = pageRows.element(boundBy: sourceIndex + 1)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear immediately after Page 4.")
        duplicatedRow.tap()

        XCTAssertEqual(firstTextFieldValue(), uniqueValue, "With-values duplicate should preserve Page 4 field value.")
    }

    func testDuplicateWithoutValuesResetsFieldData() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }
        guard let sourceIndex = expectedPages.firstIndex(where: { $0.name == "Page 4" }) else {
            XCTFail("Page 4 is required for this test.")
            return
        }
        let sourcePageName = "Page 4"

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let sourcePageRow = pageRows.element(boundBy: sourceIndex)
        XCTAssertTrue(sourcePageRow.exists, "Page 4 row should exist before duplication.")
        XCTAssertTrue(rowContainsPageName(sourcePageRow, pageName: sourcePageName), "Expected source row at index \(sourceIndex) to be Page 4.")
        sourcePageRow.tap()

        let uniqueValue = "without-values-source-\(UUID().uuidString.prefix(8))"
        setFirstTextFieldValue(uniqueValue)
        XCTAssertEqual(firstTextFieldValue(), uniqueValue, "Page 4 should keep the edited value before duplication.")

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear for duplication.")
        let initialCount = pageRows.count
        XCTAssertTrue(pageRows.element(boundBy: sourceIndex).exists, "Page 4 row should exist for duplication.")

        let sourceRow = pageRows.element(boundBy: sourceIndex)
        let duplicateButton = sourceRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button should exist for Page 4.")
        duplicateButton.tap()
        chooseDuplicateModeOrFail("Without Values")

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 }, "Page count should increase by 1 after duplication.")

        let duplicatedRow = pageRows.element(boundBy: sourceIndex + 1)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear immediately after Page 4.")
        duplicatedRow.tap()

        guard let duplicatedValue = firstTextFieldValue() else { return }
        XCTAssertTrue(
            duplicatedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            "Without-values duplicate should clear the editable text field. Actual duplicated value: '\(duplicatedValue)'"
        )
    }

    func testDuplicateWithoutValuesPreservesReadonlyAndBlockValues() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }
        guard let sourceIndex = expectedPages.firstIndex(where: { $0.name == "Page 4" }) else {
            XCTFail("Page 4 is required for this test.")
            return
        }
        let sourcePageName = "Page 4"

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let sourcePageRow = pageRows.element(boundBy: sourceIndex)
        XCTAssertTrue(sourcePageRow.exists, "Page 4 row should exist before duplication.")
        XCTAssertTrue(rowContainsPageName(sourcePageRow, pageName: sourcePageName), "Expected source row at index \(sourceIndex) to be Page 4.")
        sourcePageRow.tap()

        let uniqueValue = "without-values-preserve-\(UUID().uuidString.prefix(8))"
        setFirstTextFieldValue(uniqueValue)
        XCTAssertEqual(firstTextFieldValue(), uniqueValue, "Page 4 should keep the edited value before duplication.")

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear for duplication.")
        let initialCount = pageRows.count
        XCTAssertTrue(pageRows.element(boundBy: sourceIndex).exists, "Page 4 row should exist for duplication.")

        let sourceRow = pageRows.element(boundBy: sourceIndex)
        let duplicateButton = sourceRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button should exist for Page 4.")
        duplicateButton.tap()
        chooseDuplicateModeOrFail("Without Values")

        XCTAssertTrue(waitUntil(5) { pageRows.count == initialCount + 1 }, "Page count should increase by 1 after duplication.")

        let duplicatedRow = pageRows.element(boundBy: sourceIndex + 1)
        XCTAssertTrue(duplicatedRow.waitForExistence(timeout: 3), "Duplicated row should appear immediately after Page 4.")
        duplicatedRow.tap()

        assertFieldTextVisible("Readonly fixture value")
        assertStaticTextOccurrences("Page 4", minimumCount: 2)
    }

    func testDuplicateCancelKeepsPageUnchanged() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }
        guard let sourceIndex = expectedPages.firstIndex(where: { $0.name == "Page 4" }) else {
            XCTFail("Page 4 is required for this test.")
            return
        }
        let sourcePageName = "Page 4"

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        let sourcePageRow = pageRows.element(boundBy: sourceIndex)
        XCTAssertTrue(sourcePageRow.exists, "Page 4 row should exist for duplication.")
        XCTAssertTrue(rowContainsPageName(sourcePageRow, pageName: sourcePageName), "Expected source row at index \(sourceIndex) to be Page 4.")

        let sourceRow = pageRows.element(boundBy: sourceIndex)
        let duplicateButton = sourceRow.descendants(matching: .button).matching(identifier: "PageDuplicateIdentifier").firstMatch
        XCTAssertTrue(duplicateButton.exists, "Duplicate button should exist for Page 4.")
        duplicateButton.tap()

        let duplicateAlert = app.alerts.firstMatch
        XCTAssertTrue(duplicateAlert.waitForExistence(timeout: 3), "Duplicate mode dialog should appear.")
        XCTAssertTrue(duplicateAlert.buttons["Cancel"].exists, "Duplicate mode dialog should contain 'Cancel'.")
        duplicateAlert.buttons["Cancel"].tap()

        XCTAssertTrue(waitUntil(3) { !self.app.alerts.firstMatch.exists }, "Duplicate mode dialog should dismiss after tapping cancel.")
        XCTAssertEqual(pageRows.count, initialCount, "Page count should remain unchanged after canceling duplication.")
        XCTAssertTrue(rowContainsPageName(pageRows.element(boundBy: sourceIndex), pageName: sourcePageName), "Page 4 should remain at the same source index after canceling duplication.")

        if sourceIndex + 1 < expectedPages.count {
            let nextRow = pageRows.element(boundBy: sourceIndex + 1)
            XCTAssertTrue(nextRow.exists, "Next row should still exist after canceling duplication.")
            XCTAssertTrue(
                rowContainsPageName(nextRow, pageName: expectedPages[sourceIndex + 1].name),
                "Page order should remain unchanged after canceling duplication."
            )
        }
    }

    func testDeleteCancelKeepsPage() {
        guard let expectedPages = loadExpectedPagesOrFail() else { return }
        guard let pageToDelete = expectedPages.first(where: { $0.isDeletable }) else {
            XCTFail("Need at least one deletable page in fixture.")
            return
        }

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in the page sheet.")
        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let initialCount = pageRows.count

        guard let targetRow = findRow(named: pageToDelete.name, in: pageRows, maxScrolls: expectedPages.count * 8) else {
            XCTFail("Could not find deletable page row '\(pageToDelete.name)'.")
            return
        }

        let deleteButton = targetRow.descendants(matching: .button).matching(identifier: "PageDeleteIdentifier").firstMatch
        XCTAssertTrue(deleteButton.exists, "Delete button should exist for deletable page '\(pageToDelete.name)'.")
        deleteButton.tap()

        tapDeleteCancelButtonOrFail()
        XCTAssertTrue(waitUntil(3) { !self.app.alerts.firstMatch.exists }, "Delete confirmation should dismiss after cancel.")
        XCTAssertEqual(pageRows.count, initialCount, "Page count should remain unchanged after canceling deletion.")

        let closeSheetButton = app.buttons["ClosePageSelectionSheetIdentifier"]
        if closeSheetButton.waitForExistence(timeout: 2) {
            closeSheetButton.tap()
        }

        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear after canceling deletion.")
        let refreshedRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        let rowStillExists = findRow(named: pageToDelete.name, in: refreshedRows, maxScrolls: expectedPages.count * 8) != nil
        XCTAssertTrue(rowStillExists, "Page '\(pageToDelete.name)' should still exist after canceling deletion.")
    }

    func testReadonlyModeHidesDeleteAndDuplicateControlsEvenWhenEnabled() {
        openPageNavigationSheet()
        XCTAssertTrue(waitForPageRowsInSheet(timeout: 8), "Page rows should appear in readonly mode.")

        let pageRows = app.buttons.matching(identifier: "PageSelectionIdentifier")
        XCTAssertTrue(pageRows.count > 0, "Readonly mode should still allow page navigation rows to appear.")

        let duplicateButtons = app.buttons.matching(identifier: "PageDuplicateIdentifier")
        let deleteButtons = app.buttons.matching(identifier: "PageDeleteIdentifier")
        XCTAssertEqual(duplicateButtons.count, 0, "Duplicate controls should be hidden in readonly mode.")
        XCTAssertEqual(deleteButtons.count, 0, "Delete controls should be hidden in readonly mode.")
    }
}
