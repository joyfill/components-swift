import Foundation
import XCTest

/// Shared helpers for Decorator UI tests. Reusable across field / table / collection suites.
///
/// The test drives every API call explicitly: build a command dict, write it to the
/// system pasteboard, tap the hidden `decorator_command_execute` button in the app,
/// then assert on the resulting UI. Out-of-process XCUITests cannot touch
/// DocumentEditor directly, so the pasteboard is the sync bridge.
enum DecoratorUITestSupport {

    // MARK: - Command builders

    static func addCommand(path: String, decorators: [[String: Any]]) -> [String: Any] {
        return ["op": "add", "path": path, "decorators": decorators]
    }

    static func removeCommand(path: String, action: String) -> [String: Any] {
        return ["op": "remove", "path": path, "action": action]
    }

    static func updateCommand(path: String, action: String, decorator: [String: Any]) -> [String: Any] {
        return ["op": "update", "path": path, "action": action, "decorator": decorator]
    }

    /// Build a decorator dictionary.
    static func decorator(action: String, icon: String? = nil, label: String? = nil, color: String? = nil) -> [String: Any] {
        var d: [String: Any] = ["action": action]
        if let icon = icon { d["icon"] = icon }
        if let label = label { d["label"] = label }
        if let color = color { d["color"] = color }
        return d
    }

    // MARK: - Execution bridge

    /// Ship a single command to the app: write JSON to the pasteboard, then tap the
    /// hidden execute button so the app invokes the matching DocumentEditor API.
    /// Type the JSON command into the bridge TextField, then tap the adjacent
    /// button so the app invokes the matching DocumentEditor API. No pasteboard
    /// involvement → no iOS 16+ permission prompt.
    static func run(_ command: [String: Any], in app: XCUIApplication, file: StaticString = #file, line: UInt = #line) {
        let data = try! JSONSerialization.data(withJSONObject: command)
        let json = String(data: data, encoding: .utf8)!

        let input = app.textFields["decorator_command_input"]
        let button = app.buttons["decorator_command_execute"]
        guard input.waitForExistence(timeout: 5), button.waitForExistence(timeout: 5) else {
            XCTFail("decorator_command bridge not found — is the app running under joyfillUITestsMode?",
                    file: file, line: line)
            return
        }
        input.tap()
        input.typeText(json)
        button.tap()
    }

    // MARK: - Accessibility identifiers

    /// Identifier for a field-level decorator button.
    static func fieldDecoratorID(action: String) -> String {
        return "decorator_button_\(action)"
    }

    /// Identifier for a single row-level decorator button (shown when exactly one is displayable).
    /// Row and field buttons currently share the same DecoratorButton identifier format.
    static func rowDecoratorID(action: String) -> String {
        return "decorator_button_\(action)"
    }

    /// Identifier for the row hamburger menu button (shown when multiple decorators exist on a row).
    static let rowDecoratorMenuID = "row_decorator_menu"

    // MARK: - Focus event helper

    /// Find the decorator-scoped focus event for `action` within a batch of focusBlur results.
    /// Searches for a focus event whose fieldEvent carries the decorator action as `type`.
    static func decoratorFocusEvent(action: String, in results: [[String: Any]]) -> [String: Any]? {
        return results.first { event in
            guard event["kind"] as? String == "focus",
                  let fe = event["fieldEvent"] as? [String: Any] else { return false }
            return (fe["type"] as? String) == action
        }?["fieldEvent"] as? [String: Any]
    }

    // MARK: - Navigation helpers

    /// Navigate into the table detail view (TableModalView).
    /// Row decorator buttons only render inside this view, not in the quick-view on the main form.
    static func openTableDetailView(in app: XCUIApplication) {
        let btn = app.buttons.matching(identifier: "TableDetailViewIdentifier").firstMatch
        if !btn.waitForExistence(timeout: 3) {
            app.swipeUp()
            _ = btn.waitForExistence(timeout: 3)
        }
        btn.tap()
        spinRunloop(0.2)
    }

    /// Navigate into the collection detail view (CollectionModalView).
    static func openCollectionDetailView(in app: XCUIApplication) {
        let btn = app.buttons.matching(identifier: "CollectionDetailViewIdentifier").firstMatch
        if !btn.waitForExistence(timeout: 3) {
            app.swipeUp()
            _ = btn.waitForExistence(timeout: 3)
        }
        btn.tap()
        spinRunloop(0.2)
    }

    /// Expand (or collapse) a root row in the collection modal view.
    /// `index` is 1-based, matching the row display index.
    static func expandCollectionRootRow(at index: Int, in app: XCUIApplication) {
        let expander = app.images.matching(identifier: "CollectionExpandCollapseButton\(index)").firstMatch
        if expander.waitForExistence(timeout: 3) {
            expander.tap()
            spinRunloop(0.2)
        }
    }

    /// Expand (or collapse) a nested row in the collection modal view.
    /// `index` is 1-based within its parent's nested list.
    static func expandCollectionNestedRow(at index: Int, in app: XCUIApplication) {
        let expander = app.images.matching(identifier: "CollectionExpandCollapseNestedButton\(index)").firstMatch
        if expander.waitForExistence(timeout: 3) {
            expander.tap()
            spinRunloop(0.2)
        }
    }

    // MARK: - Row edit form helpers (for cell decorator tests)
    // Cell decorators (path: pageID/field/rowId/colId) appear inside the
    // row edit form (EditMultipleRowsSheetView / CollectionEditMultipleRowsSheetView),
    // not in column headers on row selection alone.

    /// Open the table row edit form for a given row.
    /// `rowIndex` is 1-based; internally maps to 0-based SingleClickEditButton{rowIndex-1}.
    static func openTableRowEditForm(rowIndex: Int, in app: XCUIApplication) {
        let editBtn = app.images.matching(identifier: "SingleClickEditButton\(rowIndex - 1)").firstMatch
        if editBtn.waitForExistence(timeout: 1) {
            editBtn.tap()
            spinRunloop(0.2)
        }
    }

    /// Open the collection root-row edit form for a given row.
    /// `rowIndex` is 1-based.
    static func openCollectionRootRowEditForm(rowIndex: Int, in app: XCUIApplication) {
        let editBtn = app.images.matching(identifier: "SingleClickEditButton\(rowIndex)").firstMatch
        if editBtn.waitForExistence(timeout: 1) {
            editBtn.tap()
            spinRunloop(0.2)
        }
    }

    /// Open the collection nested-row edit form.
    /// `rowIndex` is 1-based within its schema level.
    /// `boundBy` disambiguates when L1 and L2 rows share the same index
    /// (e.g. boundBy:0 = L1 row 1, boundBy:1 = L2 row 1 when both are visible).
    static func openCollectionNestedRowEditForm(rowIndex: Int, boundBy boundByIndex: Int = 0, in app: XCUIApplication) {
        let editBtn = app.images.matching(identifier: "SingleClickEditNestedButton\(rowIndex)").element(boundBy: boundByIndex)
        if editBtn.waitForExistence(timeout: 1) {
            editBtn.tap()
            spinRunloop(0.2)
        }
    }

    /// Navigate to the next row inside the row edit form (tap the `>` chevron button).
    static func navigateToNextRowInEditForm(in app: XCUIApplication) {
        let btn = app.buttons["LowerRowButtonIdentifier"]
        if btn.waitForExistence(timeout: 2) {
            btn.tap()
            spinRunloop(0.3)
        }
    }

    /// Navigate to the previous row inside the row edit form (tap the `<` chevron button).
    static func navigateToPreviousRowInEditForm(in app: XCUIApplication) {
        let btn = app.buttons["UpperRowButtonIdentifier"]
        if btn.waitForExistence(timeout: 2) {
            btn.tap()
            spinRunloop(0.3)
        }
    }

    /// Dismiss the row edit form sheet by swiping it down.
    static func dismissRowEditForm(in app: XCUIApplication) {
        let sheet = app.sheets.firstMatch
        if sheet.waitForExistence(timeout: 2) {
            sheet.swipeDown()
            spinRunloop(0.2)
        }
    }
}
