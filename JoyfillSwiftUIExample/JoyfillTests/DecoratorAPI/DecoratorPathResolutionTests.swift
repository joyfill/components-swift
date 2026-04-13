//
//  DecoratorPathResolutionTests.swift
//  JoyfillTests
//
//  Tests for the path-based decorator API: parsing, target resolution,
//  schema-key resolution, and the cross-page shared-fp regression.
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DecoratorPathResolutionTests: XCTestCase {

    // MARK: - Field path

    func testValidFieldPath_resolves() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        // No decorators yet → empty list, but no error.
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        // Round trip: write then read.
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "fieldA")])
        XCTAssertEqual(editor.getDecorators(path: path).first?.action, "fieldA")
    }

    // MARK: - Row path

    func testValidRowPath_table_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableRowPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "tableRow")])
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.count, 1)
        XCTAssertEqual(read.first?.action, "tableRow")
        // Verify it landed on field.rowDecorators (table-scope).
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        XCTAssertEqual(field?.rowDecorators?.first?.action, "tableRow")
    }

    func testValidRowPath_collectionRoot_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootRowPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "rootRow")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first?.action, "rootRow")
    }

    func testValidRowPath_collectionNested_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionNestedRowPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "nestedRow")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.rowDecorators?.first?.action, "nestedRow")
        // Should NOT have leaked into the root schema.
        XCTAssertNil(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first(where: { $0.action == "nestedRow" }))
    }

    // MARK: - Column path

    func testValidColumnPath_table_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableColumnPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "tableCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "tableCol")
    }

    func testValidColumnPath_collectionRoot_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootColumnPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "rootCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "rootCol")
    }

    func testValidColumnPath_collectionNested_resolves() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionNestedColumnPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "nestedCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionNestedColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "nestedCol")
    }

    // MARK: - Shared field position regression

    /// Navigation.json has `6970918d350238d0738dd5c9` as a field-position ID on BOTH page 1 and
    /// page 2, pointing to two different text fields. Each page-scoped path must resolve to the
    /// page's own field, not the first page's field.
    func testSharedFieldPositionId_resolvesToCorrectPage() {
        let (editor, _) = makeNavigationEditor()
        let page1Path = "\(NavigationSample.page1ID)/\(NavigationSample.sharedFieldPositionID)"
        let page2Path = "\(NavigationSample.page2ID)/\(NavigationSample.sharedFieldPositionID)"

        editor.addDecorators(path: page1Path, decorators: [makeDecorator(action: "p1")])
        editor.addDecorators(path: page2Path, decorators: [makeDecorator(action: "p2")])

        XCTAssertEqual(editor.field(fieldID: NavigationSample.page1FieldID)?.decorators?.first?.action, "p1")
        XCTAssertEqual(editor.field(fieldID: NavigationSample.page2FieldID)?.decorators?.first?.action, "p2")
        // No cross-contamination
        XCTAssertNil(editor.field(fieldID: NavigationSample.page1FieldID)?.decorators?.first(where: { $0.action == "p2" }))
        XCTAssertNil(editor.field(fieldID: NavigationSample.page2FieldID)?.decorators?.first(where: { $0.action == "p1" }))
    }

    // MARK: - Invalid paths

    func testInvalidPageId_returnsEmptyAndFiresOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "bogusPage/\(ChangerHandlerSample.tableFieldPositionID)"
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains(path) ?? false)
    }

    func testInvalidFieldPositionId_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/bogusFp"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testEmptyPath_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        _ = editor.getDecorators(path: "")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testPathWithExtraSlashes_parsesCorrectly() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Double slashes between segments should still parse to 2 segments → field path.
        let path = "\(ChangerHandlerSample.pageID)//\(ChangerHandlerSample.tableFieldPositionID)"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "fieldA")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorators?.first?.action, "fieldA")
    }

    func testPathWithTrailingSlash_parsesCorrectly() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.tableFieldPath())/"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "fieldA")])
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorators?.first?.action, "fieldA")
    }

    // MARK: - Schema key resolution behaviour (verified via the public API result)

    func testSchemaKeyResolution_unknownRow_failsToResolveCollectionRow() {
        // For collection row paths, an unknown rowId means schemaKey resolves to nil →
        // setRowDecoratorsForPath bails out (it requires a schemaKey). Decorator should NOT persist.
        let (editor, _) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/unknownRowID"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghost")])

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        // None of the schemas should have picked up the ghost decorator.
        for (_, schema) in field?.schema ?? [:] {
            XCTAssertNil(schema.rowDecorators?.first(where: { $0.action == "ghost" }))
        }
    }

    func testSchemaKeyResolution_tableRowDoesNotRequireSchema() {
        // Even though the rowId given is bogus, the table row writer ignores schemaKey and writes
        // to field.rowDecorators directly. This documents that table row decorators are field-scoped.
        let (editor, _) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/anyRowIdEvenBogus"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "tableRowAny")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.rowDecorators?.first?.action, "tableRowAny")
    }
}
