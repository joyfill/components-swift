//
//  DecoratorErrorHandlingTests.swift
//  JoyfillTests
//
//  Tests every onError emission path in the decorator API:
//    - Path resolution failures
//    - Action-not-found in remove/update
//    - Decorator validation (action required, color must be #RRGGBB)
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DecoratorErrorHandlingTests: XCTestCase {

    // MARK: - Path-resolution errors

    func testGetDecorators_invalidPath_firesOnErrorAndReturnsEmpty() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "bogusPage/bogusFp"
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains(path) ?? false)
    }

    func testAddDecorators_invalidPath_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.addDecorators(path: "bogus/path", decorators: [makeDecorator(action: "x")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
    }

    func testRemoveDecorator_invalidPath_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.removeDecorator(path: "bogus/path", action: "x")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
    }

    func testUpdateDecorator_invalidPath_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.updateDecorator(path: "bogus/path", action: "x", decorator: makeDecorator(action: "x"))
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
    }

    // MARK: - Action-not-found errors

    func testRemoveDecorator_unknownAction_firesOnError_listUnchanged() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "real")])
        mock.reset()

        editor.removeDecorator(path: path, action: "ghost")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to remove decorator with action") ?? false)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("ghost") ?? false)
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["real"])
    }

    func testUpdateDecorator_unknownAction_firesOnError_listUnchanged() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "real", label: "Real")])
        mock.reset()

        editor.updateDecorator(path: path, action: "ghost", decorator: makeDecorator(action: "ghost"))
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to update decorator with action") ?? false)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("ghost") ?? false)
        // Original decorator unchanged
        XCTAssertEqual(editor.getDecorators(path: path).first?.label, "Real")
    }

    // MARK: - Decorator validation: action

    func testValidation_addDecorator_nilAction_firesOnErrorAndBlocks() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        var bad = Decorator(); bad.icon = "flag"; bad.label = "X"; bad.color = "#FF0000"
        editor.addDecorators(path: path, decorators: [bad])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("action") ?? false)
        XCTAssertEqual(editor.getDecorators(path: path).count, 0, "blocked: nothing should persist")
    }

    func testValidation_addDecorator_emptyAction_firesOnErrorAndBlocks() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
    }

    // MARK: - Decorator validation: color

    func testValidation_addDecorator_badHexColor_firesOnErrorAndBlocks() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x", color: "red")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("color") ?? false)
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
    }

    func testValidation_addDecorator_shortHexColor_firesOnErrorAndBlocks() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableFieldPath(),
                             decorators: [makeDecorator(action: "x", color: "#12345")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testValidation_addDecorator_invalidHexChars_firesOnErrorAndBlocks() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableFieldPath(),
                             decorators: [makeDecorator(action: "x", color: "#ZZZZZZ")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testValidation_addDecorator_validLowercaseHex_succeeds() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x", color: "#3b82f6")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.getDecorators(path: path).first?.color, "#3b82f6")
    }

    func testValidation_addDecorator_validUppercaseHex_succeeds() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x", color: "#ABCDEF")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.getDecorators(path: path).first?.color, "#ABCDEF")
    }

    func testValidation_addDecorator_nilColor_succeeds() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x", color: nil)])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.getDecorators(path: path).count, 1)
    }

    func testValidation_addDecorator_emptyColor_succeeds() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x", color: "")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.getDecorators(path: path).count, 1)
    }

    // MARK: - Atomicity

    func testValidation_addDecorators_oneInvalidInBatch_blocksAll() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "good"),
            makeDecorator(action: "", color: "#FF0000"), // empty action → invalid
            makeDecorator(action: "alsoGood"),
        ])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertEqual(editor.getDecorators(path: path).count, 0,
                       "one bad decorator must block the whole batch")
    }

    func testValidation_updateDecorator_badProperty_firesOnError_listUnchanged() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a", label: "Original")])
        mock.reset()

        editor.updateDecorator(path: path, action: "a",
                               decorator: makeDecorator(action: "a", color: "notHex"))
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertEqual(editor.getDecorators(path: path).first?.label, "Original",
                       "blocked update must not mutate the existing decorator")
    }

    // MARK: - Error message shape

    func testErrorMessage_includesPath() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "totally/wrong/path"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x")])
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains(path) ?? false)
    }

    func testErrorMessage_includesAction() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "real")])
        mock.reset()
        editor.updateDecorator(path: path, action: "ghost", decorator: makeDecorator(action: "ghost"))
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("ghost") ?? false)
    }

    func testDecoratorErrorWrapsCorrectMessage() {
        let (editor, mock) = makeChangerHandlerEditor()
        editor.removeDecorator(path: "x/y", action: "z")
        guard let captured = mock.capturedErrors.first else {
            XCTFail("Expected an error"); return
        }
        switch captured {
        case .decoratorError(let err):
            XCTAssertFalse(err.message.isEmpty)
            XCTAssertTrue(err.message.contains("x/y"))
        default:
            XCTFail("Expected .decoratorError, got \(captured)")
        }
    }

    // MARK: - License gating (collection field requires a valid license)

    func testLicense_invalid_collectionAddDecorators_firesOnError_andDoesNotPersist() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootRowPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "blocked")])

        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("license") ?? false,
                      "error message should mention license")
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertNil(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
                       .rowDecorators?.first(where: { $0.action == "blocked" }))
    }

    func testLicense_invalid_collectionRemoveDecorator_firesOnError() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        editor.removeDecorator(path: ChangerHandlerSample.collectionRootRowPath(), action: "x")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("license") ?? false)
    }

    func testLicense_invalid_collectionUpdateDecorator_firesOnError() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        editor.updateDecorator(path: ChangerHandlerSample.collectionRootRowPath(),
                               action: "x", decorator: makeDecorator(action: "x"))
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("license") ?? false)
    }

    /// Reads on collection fields are NOT gated — they're harmless data inspection.
    func testLicense_invalid_collectionGetDecorators_doesNotFireError() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        _ = editor.getDecorators(path: ChangerHandlerSample.collectionRootRowPath())
        XCTAssertEqual(mock.decoratorErrorCount, 0,
                       "reads should not be license-gated")
    }

    /// Table-field decorators are not collection-gated, even with no license.
    func testLicense_invalid_tableAddDecorators_succeeds() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ok")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.getDecorators(path: path).first?.action, "ok")
    }

    func testLicense_invalid_collectionBatchAdd_blocksAll() {
        let (editor, mock) = makeUnlicensedChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootRowPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
        ])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let cached = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators ?? []
        XCTAssertTrue(cached.isEmpty, "no decorators should persist when license blocks")
    }

    // MARK: - No events handler (must not crash)

    func testNoEventsHandler_noCrash_invalidPath() {
        let editor = DocumentEditor(document: sampleJSONDocument(fileName: "ChangerHandlerUnit"),
                                    events: nil, validateSchema: false)
        // Should be a no-op, not a crash.
        editor.addDecorators(path: "bogus/path", decorators: [makeDecorator(action: "x")])
        editor.removeDecorator(path: "bogus/path", action: "x")
        editor.updateDecorator(path: "bogus/path", action: "x", decorator: makeDecorator(action: "x"))
        _ = editor.getDecorators(path: "bogus/path")
    }

    func testNoEventsHandler_noCrash_validation() {
        let editor = DocumentEditor(document: sampleJSONDocument(fileName: "ChangerHandlerUnit"),
                                    events: nil, validateSchema: false)
        editor.addDecorators(path: ChangerHandlerSample.tableFieldPath(),
                             decorators: [makeDecorator(action: "x", color: "notHex")])
        XCTAssertEqual(editor.getDecorators(path: ChangerHandlerSample.tableFieldPath()).count, 0)
    }
}
