//
//  CollectionStickyHeadersUITests.swift
//  JoyfillUITests
//

import XCTest
import JoyfillModel

// NO-2360: sticky headers for the collection field; the overlay is .accessibilityHidden, so these tests verify interaction still works past pinned nested headers (up to 4 levels) rather than visual pinning.
final class CollectionStickyHeadersUITests: JoyfillUITestsBaseClass {
    override func getJSONFileNameForTest() -> String {
        return "CollectionStickyHeadersTestData"
    }

    func goToCollectionDetailField() {
        let collectionButton = app.buttons["CollectionDetailViewIdentifier"].firstMatch
        XCTAssertTrue(collectionButton.waitForExistence(timeout: 5), "Collection detail button not found")
        collectionButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
    }

    @discardableResult
    private func scrollUntilHittable(_ element: XCUIElement, maxSwipes: Int = 14) -> Bool {
        if element.exists && element.isHittable { return true }
        for _ in 0..<maxSwipes {
            app.swipeUp()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            if element.exists && element.isHittable { return true }
        }
        for _ in 0..<maxSwipes {
            app.swipeDown()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            if element.exists && element.isHittable { return true }
        }
        return element.exists && element.isHittable
    }

    /// Finds an element by identifier regardless of scroll position, trying both directions then falling back to a direct (possibly off-screen) lookup.
    private func findElement(identifier: String, type: XCUIElement.ElementType, index: Int = 0) -> XCUIElement {
        if let found = app.swipeToFindElement(identifier: identifier, type: type, direction: "down", index: index, maxAttempts: 14) {
            return found
        }
        if let found = app.swipeToFindElement(identifier: identifier, type: type, direction: "up", index: index, maxAttempts: 14) {
            return found
        }
        return app.descendants(matching: type).matching(identifier: identifier).element(boundBy: index)
    }

    func expandRow(number: Int) {
        let identifier = "CollectionExpandCollapseButton\(number)"
        let button = findElement(identifier: identifier, type: .image)
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Failed to find expand/collapse button with identifier: \(identifier)")
        scrollUntilHittable(button)
        button.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.6))
    }

    func expandNestedRow(number: Int) {
        let identifier = "CollectionExpandCollapseNestedButton\(number)"
        let button = findElement(identifier: identifier, type: .image)
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Failed to find nested expand/collapse button with identifier: \(identifier)")
        scrollUntilHittable(button)
        button.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.8))
    }

    /// Expands row 1 of the deepest revealed nested table: `...NestedButton1` is reused per-table, so the most-indented (largest minX) one is the freshly-revealed level's row 1 to drill into next.
    func expandDeepestNestedRow1() {
        let query = app.images.matching(identifier: "CollectionExpandCollapseNestedButton1")
        var target: XCUIElement?
        var deepestX: CGFloat = -1
        for i in 0..<query.count {
            let e = query.element(boundBy: i)
            guard e.exists else { continue }
            if e.frame.minX > deepestX {
                deepestX = e.frame.minX
                target = e
            }
        }
        guard let button = target else {
            XCTFail("No nested row-1 expand button found to drill into")
            return
        }
        scrollUntilHittable(button)
        button.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.8))
    }

    func tapSchemaAddRowButton(number: Int) {
        let button = findElement(identifier: "collectionSchemaAddRowButton", type: .button, index: number)
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Failed to find schema add-row button at index \(number)")
        scrollUntilHittable(button)
        button.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.6))
    }

    /// `collectionSchemaAddRowButton` is shared across levels and lazy-rendered, so fixed indices are unstable; for a straight drill-down chain the last currently-mounted match is the just-revealed table's.
    func tapDeepestSchemaAddRowButton(maxScrollAttempts: Int = 24) {
        let query = app.buttons.matching(identifier: "collectionSchemaAddRowButton")
        var attempts = 0
        while attempts < maxScrollAttempts {
            let count = query.count
            if count > 0 {
                let candidate = query.element(boundBy: count - 1)
                if candidate.exists && candidate.isHittable {
                    candidate.tap()
                    RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.6))
                    return
                }
            }
            app.swipeUp()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.25))
            attempts += 1
        }
        XCTFail("Failed to find/tap the deepest schema add-row button after scrolling")
    }

    func scrollDown(times: Int = 1) {
        for _ in 0..<times {
            app.swipeUp()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3))
        }
    }

    func scrollUp(times: Int = 1) {
        for _ in 0..<times {
            app.swipeDown()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3))
        }
    }

    /// Mirror the suite convention: read `onChangeResultValue()` only after `goBack()` + a settle delay, since the "resultfield" label lags behind mid-navigation.
    func waitForAppToSettle() {
        guard app.wait(for: .runningForeground, timeout: 2) else {
            XCTFail("App did not settle")
            return
        }
        usleep(500000)
    }

    // MARK: - Expand through all four nesting levels, scrolling repeatedly, without crashing

    func testScrollThroughAllFourNestingLevelsWithoutCrash() throws {
        goToCollectionDetailField()

        // Root Row 1 -> Level1 Row 1 -> Level2 Row 1 -> Level3 rows (5 of them)
        expandRow(number: 1)
        expandNestedRow(number: 1)
        expandNestedRow(number: 2)

        scrollDown(times: 4)
        scrollUp(times: 2)
        scrollDown(times: 3)
        scrollUp(times: 5)

        // Expand/collapse doesn't mutate document data, so assert structurally that nothing crashed and the collection stays interactive.
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 3),
                      "App should remain responsive after scrolling past all four pinned nesting levels")
        XCTAssertTrue(app.buttons.matching(identifier: "collectionSchemaAddRowButton").count > 0,
                      "Nested table controls should still be present after scrolling through pinned headers")
    }

    // MARK: - Add a root row after scrolling past nested pinned headers

    func testAddRootRowAfterScrollingPastNestedHeaders() throws {
        goToCollectionDetailField()

        expandRow(number: 1)
        expandNestedRow(number: 1)
        scrollDown(times: 3)

        let addRootRowButton = findElement(identifier: "TableAddRowIdentifier", type: .button)
        XCTAssertTrue(addRootRowButton.waitForExistence(timeout: 5), "Root add-row button not found")
        scrollUntilHittable(addRootRowButton)
        addRootRowButton.tap()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        goBack()
        waitForAppToSettle()

        XCTAssertEqual(onChangeResultValue().valueElements?.count, 16,
                       "A new root row should be added even after the root header has been pinned/unpinned")
    }

    // MARK: - Add a nested row at level 1, 2, and 3 after scrolling

    func testAddNestedRowsAtEachLevelAfterScrolling() throws {
        goToCollectionDetailField()

        expandRow(number: 1)
        // Only one nested add-row button exists yet: Level 1 table under Root Row 1.
        tapDeepestSchemaAddRowButton()

        // Drill into Level 1 Row 1 to reveal its Level 2 table, then add a Level 2 row.
        expandDeepestNestedRow1()
        tapDeepestSchemaAddRowButton()

        // Drill into Level 2 Row 1 to reveal its Level 3 table, then add a Level 3 row.
        expandDeepestNestedRow1()
        tapDeepestSchemaAddRowButton()

        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))

        goBack()
        waitForAppToSettle()

        let level1 = try XCTUnwrap(onChangeResultValue().valueElements?.first?.childrens?["level1Schema"]?.valueToValueElements,
                                   "Expected level1Schema rows after adding a Level 1 row")
        XCTAssertEqual(level1.count, 8, "Level 1 table should have gained a row")

        let level2 = try XCTUnwrap(level1.first?.childrens?["level2Schema"]?.valueToValueElements,
                                   "Expected level2Schema rows after adding a Level 2 row")
        XCTAssertEqual(level2.count, 8, "Level 2 table should have gained a row")

        let level3 = try XCTUnwrap(level2.first?.childrens?["level3Schema"]?.valueToValueElements,
                                   "Expected level3Schema rows after adding a Level 3 row")
        XCTAssertEqual(level3.count, 8, "Level 3 table should have gained a row")
    }

    // MARK: - Edit a deeply-nested cell after scrolling past its ancestors' pinned headers

    func testEditDeepestNestedCellAfterScrollingPastAncestorHeaders() throws {
        goToCollectionDetailField()

        expandRow(number: 1)
        expandNestedRow(number: 1)
        expandNestedRow(number: 2)

        scrollDown(times: 3)

        let level3TextField = findElement(identifier: "TabelTextFieldIdentifier", type: .textView)
        XCTAssertTrue(level3TextField.waitForExistence(timeout: 5), "Expected a visible text cell after scrolling to level 3 rows")
        scrollUntilHittable(level3TextField)
        level3TextField.tap()
        level3TextField.typeText("edited")
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        app.dismissKeyboardIfVisible()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 3),
                      "Editing a level-3 cell underneath pinned ancestor headers should not crash the app")
    }

    // MARK: - Collapsing a parent row while its children are scrolled into view removes them cleanly

    func testCollapseParentRowWhileChildrenScrolledIntoView() throws {
        goToCollectionDetailField()

        expandRow(number: 1)
        scrollDown(times: 2)

        let nestedRowCheckbox = findElement(identifier: "selectNestedRowItem1", type: .image)
        XCTAssertTrue(nestedRowCheckbox.waitForExistence(timeout: 5), "Level 1 nested row should be visible after expanding")

        // Re-tap the same root expand/collapse control to collapse Root Row 1 again.
        expandRow(number: 1)

        // Expand/collapse doesn't mutate document data — verify via the UI that the collapsed nested row is gone, not via onChange.
        XCTAssertFalse(app.images["selectNestedRowItem1"].exists,
                       "Nested rows should disappear once their parent is collapsed, even if they were scrolled under a pinned header")
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 3),
                      "Collapsing a parent row whose children were scrolled under a pinned header should not crash")
    }

    // MARK: - Sibling root rows can be expanded/collapsed independently while scrolled

    func testExpandSiblingRootRowsIndependently() throws {
        goToCollectionDetailField()

        expandRow(number: 1)
        scrollDown(times: 1)
        expandRow(number: 2)
        scrollDown(times: 2)
        scrollUp(times: 3)

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 3),
                      "Expanding a second sibling root row while the first is scrolled/pinned should not crash")
        let nestedRowCheckbox = findElement(identifier: "selectNestedRowItem1", type: .image)
        XCTAssertTrue(nestedRowCheckbox.waitForExistence(timeout: 5),
                      "Root Row 1's nested content should remain expanded")
    }
}
