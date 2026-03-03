//
//  FocusCallbackUITests.swift
//  JoyfillUITests
//
//  UI tests for field onFocus/onBlur callbacks when using goto(path, GotoConfig(open:, focus:)).
//  Uses Navigation.json and triggers goto via launch args; asserts focusBlurResultfield content.
//

import XCTest

final class FocusCallbackUITests: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "Navigation"
    }

    override func getGotoLaunchArguments() -> [(String, String?)] {
        // Route goto path and flags per test so the app triggers goto on load. Paths use page 691f376206195944e65eef76 (Page 2 in Navigation.json).
        let name = self.name
        if name.contains("testFieldFocus_TextField_") {
            return [("--goto-path", "691f376206195944e65eef76/6970926943176f7a04947ce6"), ("--goto-focus", nil)]
        }
        if name.contains("testFieldFocus_NumberField_") {
            return [("--goto-path", "691f376206195944e65eef76/69709289bbae3675aabd7367"), ("--goto-focus", nil)]
        }
        if name.contains("testFieldFocus_DropdownField_") {
            return [("--goto-path", "691f376206195944e65eef76/6970938c377426ff921d24ac"), ("--goto-focus", nil)]
        }
        if name.contains("testFieldFocus_TableRow_") {
            return [("--goto-path", "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9"), ("--goto-open", nil), ("--goto-focus", nil)]
        }
        if name.contains("testFieldFocus_TableRowColumn_") {
            return [("--goto-path", "691f376206195944e65eef76/69709462236416126c166efe/697090a399394f50229899a9/697090a35fe3eb39f20fa2d8"), ("--goto-open", nil), ("--goto-focus", nil)]
        }
        if name.contains("testFieldFocus_CollectionRow_") {
            return [("--goto-path", "691f376206195944e65eef76/6970a485380c41d6c06005aa/6970a4a3b830a02d7d3a3172"), ("--goto-open", nil), ("--goto-focus", nil)]
        }
        return []
    }

    // MARK: - Helpers

    func focusBlurEventsFromApp() -> [[String: Any]] {
        let el = app.staticTexts["focusBlurResultfield"]
        guard el.waitForExistence(timeout: 3), !el.label.isEmpty, el.label != "[]" else { return [] }
        guard let data = el.label.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return array
    }

    func hasFocusEventWithFieldID(_ fieldID: String) -> Bool {
        let events = focusBlurEventsFromApp()
        return events.contains { dict in
            guard dict["kind"] as? String == "focus",
                  let fieldEvent = dict["fieldEvent"] as? [String: Any],
                  let id = fieldEvent["fieldID"] as? String else { return false }
            return id == fieldID
        }
    }

    func waitForFocusBlurResult(timeout: TimeInterval = 3) {
        _ = waitUntil(timeout) { self.focusBlurEventsFromApp().isEmpty == false }
    }

    // MARK: - Field focus (goto with focus: true)

    func testFieldFocus_TextField_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("69709269bd629e934b3642be"), "onFocus should fire for text field when goto with focus: true")
    }

    func testFieldFocus_NumberField_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("6970928904c386acae8b78d7"), "onFocus should fire for number field when goto with focus: true")
    }

    func testFieldFocus_DropdownField_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("6970938c8fd5ed82236cd84c"), "onFocus should fire for dropdown field when goto with focus: true")
    }

    func testFieldFocus_TableRow_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("69709462be820cc2c7c39a90"), "onFocus should fire for table field when goto to row with open and focus")
    }

    func testFieldFocus_TableRowColumn_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("69709462be820cc2c7c39a90"), "onFocus should fire for table field when goto to row+column with open and focus")
    }

    func testFieldFocus_CollectionRow_FiresOnFocus() {
        waitForFocusBlurResult()
        XCTAssertTrue(hasFocusEventWithFieldID("6970a4856fd033cacf088025"), "onFocus should fire for collection field when goto to row with open and focus")
    }
}
