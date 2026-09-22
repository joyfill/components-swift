//
//  CollectionNestedCollection.swift
//  JoyfillExample
//
//  Created by Vivek's Mac on 22/09/26.
//

import Foundation
import XCTest
import JoyfillModel

final class CollectionNestedCollection: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "CollectionNestedCondition"
    }

    private func openCollection() {
        let button = app.buttons["CollectionDetailViewIdentifier"]
        for _ in 0..<8 where !button.exists {
            app.swipeUp()
            spinRunloop(0.2)
        }
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Collection quick-view button never appeared")
        button.tap()
        XCTAssertTrue(waitForAppStability(timeout: 10), "Collection modal did not settle")
    }

    private func expandRootRow() {
        let expander = app.images["CollectionExpandCollapseButton1"]
        XCTAssertTrue(expander.waitForExistence(timeout: 15), "Root row expander never appeared")
        expander.tap()
        XCTAssertTrue(waitForAppStability(timeout: 10), "Nested tables did not settle after expanding")
    }

    private func gridScrollView() -> XCUIElement {
        let named = app.scrollViews["TableScrollView"]
        return named.exists ? named : app.scrollViews.firstMatch
    }

    private func openRootMultiSelectCell() {
        let cell = app.buttons.matching(identifier: "TableMultiSelectionFieldIdentifier").firstMatch
        let grid = gridScrollView()
        for _ in 0..<4 where !cell.exists {
            grid.swipeLeft()
            spinRunloop(0.3)
        }
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "MultiSelect cell never appeared")
        cell.tap()
    }

    private func toggleOption(_ label: String) {
        let predicate = NSPredicate(format: "identifier == %@ AND label CONTAINS[c] %@",
                                    "TableMultiSelectOptionsSheetIdentifier", label)
        let option = app.buttons.matching(predicate).firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 5), "\(label) not found in the options sheet")
        option.tap()
    }

    private func toggleRootMultiSelect(_ labels: [String]) {
        openRootMultiSelectCell()
        labels.forEach(toggleOption)
        app.buttons["TableMultiSelectionFieldApplyIdentifier"].tap()
        XCTAssertTrue(waitForAppStability(timeout: 10), "Collection did not settle after the multi-select change")
    }

    func testNestedSchemaWithoutRowDataFollowsItsShowLogic() {
        openCollection()
        expandRootRow()

        XCTAssertTrue(app.staticTexts["New Table 2"].waitForExistence(timeout: 10),
                      "The MultiSelect cell matches New Table 2's show condition, so it must be visible")
        XCTAssertFalse(app.staticTexts["New Table 3"].exists,
                       "New Table 3 has no row data and its condition does not match, so it must stay hidden")
        XCTAssertFalse(app.staticTexts["New Table 1"].exists,
                       "New Table 1 has row data but its condition does not match, so it must stay hidden")
    }

    func testChangingMultiSelectSwitchesTheVisibleNestedTable() {
        openCollection()
        expandRootRow()

        XCTAssertTrue(app.staticTexts["New Table 2"].waitForExistence(timeout: 10),
                      "Precondition: Option 2 is selected, so New Table 2 starts visible")

        toggleRootMultiSelect(["Option 2", "Option 3"])

        XCTAssertTrue(app.staticTexts["New Table 3"].waitForExistence(timeout: 10),
                      "Option 3 now matches New Table 3's show condition, so it must appear")
        XCTAssertFalse(app.staticTexts["New Table 2"].exists,
                       "Option 2 is no longer selected, so New Table 2 must disappear")
        XCTAssertFalse(app.staticTexts["New Table 1"].exists,
                       "New Table 1's condition still does not match, so it must stay hidden")
    }

    func testSelectingEveryOptionShowsAllNestedTablesAndClearingHidesThemAll() {
        openCollection()
        expandRootRow()

        toggleRootMultiSelect(["Option 1", "Option 3"])

        XCTAssertTrue(app.staticTexts["New Table 1"].waitForExistence(timeout: 10),
                      "Option 1 is selected, so New Table 1 must be visible")
        XCTAssertTrue(app.staticTexts["New Table 2"].exists,
                      "Option 2 is still selected, so New Table 2 must stay visible")
        XCTAssertTrue(app.staticTexts["New Table 3"].exists,
                      "Option 3 is selected, so New Table 3 must be visible")

        toggleRootMultiSelect(["Option 1", "Option 2", "Option 3"])

        XCTAssertTrue(app.staticTexts["New Table 1"].waitForNonExistence(timeout: 10),
                      "No option is selected, so New Table 1 must be hidden")
        XCTAssertFalse(app.staticTexts["New Table 2"].exists,
                       "No option is selected, so New Table 2 must be hidden")
        XCTAssertFalse(app.staticTexts["New Table 3"].exists,
                       "No option is selected, so New Table 3 must be hidden")
    }
}
