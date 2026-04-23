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
    static func rowDecoratorID(action: String) -> String {
        return "row_decorator_\(action)"
    }

    /// Identifier for the row hamburger menu button (shown when multiple decorators exist on a row).
    static let rowDecoratorMenuID = "row_decorator_menu"
}
