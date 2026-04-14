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

    // MARK: - Extra path segments

    /// parsePath reads only the first 4 segments and silently discards the rest.
    /// A 5-segment path resolves as a valid column path — the extra segment is ignored.
    func testPathWithExtraSegments_resolvesAsColumnPath() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.tableColumnPath())/extraSegment"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "extra")])
        XCTAssertEqual(mock.decoratorErrorCount, 0,
                       "extra segments are silently discarded by parsePath")
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "extra")
    }

    // MARK: - Schema key resolution behaviour (verified via the public API result)

    // MARK: - rowId / columnId validation (resolver must reject unknown IDs)

    func testInvalidRowId_collection_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/unknownRowID"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghost")])

        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "unknown rowId on collection must fire a decoratorError")
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            XCTAssertNil(schema.rowDecorators?.first(where: { $0.action == "ghost" }))
        }
    }

    func testInvalidRowId_table_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/bogusRowId"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghostTableRow")])

        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "unknown rowId on table must fire a decoratorError (no silent writes)")
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        XCTAssertNil(field?.rowDecorators?.first(where: { $0.action == "ghostTableRow" }),
                     "the decorator must not leak into the field's global rowDecorators list")
    }

    // MARK: - Cross-schema rowId / columnId mismatch

    /// Passes a root-schema rowId with a nested-schema columnId. The column
    /// exists in the field but belongs to a different schema than the row.
    /// The resolver must reject this — otherwise the setter silently no-ops
    /// because the column is not found in the row's resolved schema.
    func testCrossSchemaColumnMismatch_rootRowNestedColumn_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Root rowId + nested columnId → cross-schema mismatch
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/\(ChangerHandlerSample.collectionRootRowID)/\(ChangerHandlerSample.collectionNestedColumnID)"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "crossSchema")])

        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "cross-schema rowId/columnId mismatch must fire a decoratorError")
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)

        // Must not write to any schema
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            for col in schema.tableColumns ?? [] {
                XCTAssertNil(col.decorators?.first(where: { $0.action == "crossSchema" }),
                             "cross-schema decorator must not leak into any schema's columns")
            }
        }
    }

    /// The inverse: nested-schema rowId with a root-schema columnId.
    func testCrossSchemaColumnMismatch_nestedRowRootColumn_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Nested rowId + root columnId → cross-schema mismatch
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/\(ChangerHandlerSample.collectionNestedRowID)/\(ChangerHandlerSample.collectionRootColumnID)"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "crossSchemaReverse")])

        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "cross-schema rowId/columnId mismatch must fire a decoratorError")

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            for col in schema.tableColumns ?? [] {
                XCTAssertNil(col.decorators?.first(where: { $0.action == "crossSchemaReverse" }),
                             "cross-schema decorator must not leak into any schema's columns")
            }
        }
    }

    func testInvalidColumnId_collection_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/\(ChangerHandlerSample.collectionRootRowID)/bogusColId"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghostCol")])

        XCTAssertEqual(mock.decoratorErrorCount, 1)
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            for col in schema.tableColumns ?? [] {
                XCTAssertNil(col.decorators?.first(where: { $0.action == "ghostCol" }))
            }
        }
    }

    func testInvalidColumnId_table_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/\(ChangerHandlerSample.tableRowID)/bogusColId"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghostTableCol")])

        XCTAssertEqual(mock.decoratorErrorCount, 1)
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        for col in field?.tableColumns ?? [] {
            XCTAssertNil(col.decorators?.first(where: { $0.action == "ghostTableCol" }))
        }
    }
}
