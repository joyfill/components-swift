import XCTest

// MARK: - IDs from Decorator.json (text field scope)

private let pageID = "69709dc281b4c8ab68c4db52"
private let fpTextField = "6970918d350238d0738dd5c9"

/// Exercises every DocumentEditor decorator API (`addDecorators`, `updateDecorator`,
/// `removeDecorator`) against a text field using a fully test-driven workflow:
/// the test calls `run(...)` to trigger each API, then asserts the UI reflects it
/// before moving to the next step.
///
/// `getDecorators` is read-only with no UI surface and is covered by unit tests.
final class DecoratorTextFieldAPIUITests: JoyfillUITestsBaseClass {

    override func getJSONFileNameForTest() -> String {
        return "Decorator"
    }

    private var fieldPath: String { "\(pageID)/\(fpTextField)" }

    /// Tapping a decorator can emit a regular field-focus event in addition to
    /// the decorator focus, so we search for the focus event whose fieldEvent
    /// carries the decorator action in its `type`.
    private func decoratorFocusEvent(action: String) -> [String: Any]? {
        return focusBlurOptionalResults().first { event in
            guard event["kind"] as? String == "focus",
                  let fe = event["fieldEvent"] as? [String: Any] else { return false }
            return (fe["type"] as? String) == action
        }?["fieldEvent"] as? [String: Any]
    }

    // MARK: - Full lifecycle: single decorator

    func testFlagDecoratorLifecycle() throws {
        typealias S = DecoratorUITestSupport
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]
        XCTAssertFalse(flag.exists, "Decorator should not exist before add")

        // 1. add → button appears with original label.
        S.run(S.addCommand(path: fieldPath,
                           decorators: [S.decorator(action: "flag", icon: "flag", label: "Flag")]),
              in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1),
                      "Decorator button should appear after addDecorators")
        XCTAssertEqual(flag.label, "Flag")
        XCTAssertTrue(flag.isHittable)

        // 2. update → identifier persists, label changes.
        S.run(S.updateCommand(path: fieldPath, action: "flag",
                              decorator: S.decorator(action: "flag", icon: "flag", label: "Done")),
              in: app)
        XCTAssertTrue(waitUntil(1) { flag.label == "Done" },
                      "Decorator label should change to 'Done' after updateDecorator")

        // 3. tap → onFocus fires with decorator action as type & target.
        flag.tap()
        XCTAssertTrue(
            waitUntil(1) { self.decoratorFocusEvent(action: "flag") != nil },
            "Expected a decorator-scoped focus event for 'flag' after tap"
        )
        let fieldEvent = decoratorFocusEvent(action: "flag") ?? [:]
        XCTAssertEqual(fieldEvent["type"] as? String, "flag")
        XCTAssertEqual(fieldEvent["target"] as? String, "flag")
        XCTAssertEqual(fieldEvent["pageID"] as? String, pageID)
        XCTAssertEqual(fieldEvent["fieldPositionId"] as? String, fpTextField)

        // 4. remove → button disappears.
        S.run(S.removeCommand(path: fieldPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(1) { !flag.exists },
                      "Decorator button should disappear after removeDecorator")
    }

    // MARK: - Full lifecycle: multiple decorators

    func testMultipleDecoratorsLifecycle() throws {
        typealias S = DecoratorUITestSupport
        let flag = app.buttons[S.fieldDecoratorID(action: "flag")]
        let comment = app.buttons[S.fieldDecoratorID(action: "comment")]
        let share = app.buttons[S.fieldDecoratorID(action: "share")]

        // 1. add → all three appear.
        S.run(S.addCommand(path: fieldPath, decorators: [
            S.decorator(action: "flag", icon: "flag", label: "Flag"),
            S.decorator(action: "comment", icon: "comment", label: "Comment"),
            S.decorator(action: "share", icon: "share", label: "Share")
        ]), in: app)
        XCTAssertTrue(flag.waitForExistence(timeout: 1))
        XCTAssertTrue(comment.exists)
        XCTAssertTrue(share.exists)
        XCTAssertEqual(comment.label, "Comment")

        // 2. update → only targeted decorator changes.
        S.run(S.updateCommand(path: fieldPath, action: "comment",
                              decorator: S.decorator(action: "comment", icon: "comment", label: "Reviewed")),
              in: app)
        XCTAssertTrue(waitUntil(1) { comment.label == "Reviewed" },
                      "Only the targeted decorator should update")
        XCTAssertEqual(flag.label, "Flag", "Untouched decorator should keep its label")
        XCTAssertEqual(share.label, "Share", "Untouched decorator should keep its label")

        // 3. tap → onFocus fires with the tapped decorator's action.
        comment.tap()
        XCTAssertTrue(
            waitUntil(1) { self.decoratorFocusEvent(action: "comment") != nil },
            "Expected a decorator-scoped focus event for 'comment' after tap"
        )
        let fieldEvent = decoratorFocusEvent(action: "comment") ?? [:]
        XCTAssertEqual(fieldEvent["type"] as? String, "comment")
        XCTAssertEqual(fieldEvent["target"] as? String, "comment")

        // 4. remove → only the targeted decorator is removed.
        S.run(S.removeCommand(path: fieldPath, action: "flag"), in: app)
        XCTAssertTrue(waitUntil(1) { !flag.exists },
                      "Removed decorator should disappear")
        XCTAssertTrue(comment.exists, "Sibling decorator should remain after removal")
        XCTAssertTrue(share.exists, "Sibling decorator should remain after removal")
    }
}
