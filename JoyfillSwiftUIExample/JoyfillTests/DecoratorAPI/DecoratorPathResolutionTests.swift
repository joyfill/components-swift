//
//  DecoratorPathResolutionTests.swift
//  JoyfillTests
//
//  Tests for the path-based decorator API under the keyword grammar:
//    rows / columns / schemas / {rowID} / {colID}
//  Covers: field / common-rows / common-column / row-self / cell / row-scoped column,
//  for both table and collection (root + nested), plus invalid-path errors.
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
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
        XCTAssertEqual(mock.decoratorErrorCount, 0)
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "fieldA")])
        XCTAssertEqual(editor.getDecorators(path: path).first?.action, "fieldA")
    }

    // MARK: - Common rows (`/rows`)

    func testCommonRows_table_writesToFieldRowDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "tRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        XCTAssertEqual(field?.rowDecorators?.first?.action, "tRows")
    }

    func testCommonRows_collectionRoot_writesToRootSchemaRowDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "rootRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first?.action, "rootRows")
    }

    func testCommonRows_collectionNested_writesToNestedSchemaRowDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nestedRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.rowDecorators?.first?.action, "nestedRows")
        // Must not leak into root schema
        XCTAssertNil(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
                        .rowDecorators?.first(where: { $0.action == "nestedRows" }))
    }

    // MARK: - Row-self (`/{rowID}` — row's own decorators on the ValueElement)

    func testRowSelf_table_writesToValueElementAll() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "tSelf")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let row = findValueElement(in: field,
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "tSelf")
        // Should NOT appear in field.rowDecorators (that's the common-rows slot)
        XCTAssertNil(field?.rowDecorators?.first(where: { $0.action == "tSelf" }))
    }

    func testRowSelf_collectionRoot_writesToValueElementAll() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rootSelf")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let row = findValueElement(in: field,
                                   hops: [(ChangerHandlerSample.collectionRootSchemaKey,
                                           ChangerHandlerSample.collectionRootRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "rootSelf")
    }

    func testRowSelf_collectionNested_writesToValueElementAll() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath(),
                             decorators: [makeDecorator(action: "nestedSelf")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let row = findValueElement(in: field, hops: [
            (ChangerHandlerSample.collectionRootSchemaKey,   ChangerHandlerSample.collectionRootRowID),
            (ChangerHandlerSample.collectionNestedSchemaKey, ChangerHandlerSample.collectionNestedRowID),
        ])
        XCTAssertEqual(row?.decorators?.all.first?.action, "nestedSelf")
    }

    // MARK: - Common column (`/columns/{col}`)

    func testCommonColumn_table_writesToTableColumnDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonColumnPath(),
                             decorators: [makeDecorator(action: "tCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "tCol")
    }

    func testCommonColumn_collectionRoot_writesToRootSchemaColumn() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonColumnPath(),
                             decorators: [makeDecorator(action: "rootCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "rootCol")
    }

    func testCommonColumn_collectionNested_writesToNestedSchemaColumn() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonColumnPath(),
                             decorators: [makeDecorator(action: "nestedCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionNestedColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "nestedCol")
    }

    // MARK: - Cell (`/{rowID}/{colID}` — bare column id)

    func testCell_table_writesToValueElementCells() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "tCell")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let row = findValueElement(in: field,
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.cells[ChangerHandlerSample.tableColumnID]?.first?.action, "tCell")
        // Column-common slot must be untouched
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertNil(col?.decorators?.first(where: { $0.action == "tCell" }))
    }

    func testCell_collectionNested_writesToValueElementCells() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCellPath(),
                             decorators: [makeDecorator(action: "nCell")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let row = findValueElement(in: field, hops: [
            (ChangerHandlerSample.collectionRootSchemaKey,   ChangerHandlerSample.collectionRootRowID),
            (ChangerHandlerSample.collectionNestedSchemaKey, ChangerHandlerSample.collectionNestedRowID),
        ])
        XCTAssertEqual(row?.decorators?.cells[ChangerHandlerSample.collectionNestedColumnID]?.first?.action, "nCell")
    }

    // MARK: - Row-scoped column (`/{rowID}/columns/{colID}` — aliases cell)

    func testRowScopedColumn_table_aliasesCellStorage() {
        let (editor, _) = makeChangerHandlerEditor()
        // Write via the row-scoped-column spelling
        editor.addDecorators(path: ChangerHandlerSample.tableRowScopedColumnPath(),
                             decorators: [makeDecorator(action: "scoped")])
        // Read back via the bare-cell spelling — same storage
        let read = editor.getDecorators(path: ChangerHandlerSample.tableCellPath())
        XCTAssertEqual(read.first?.action, "scoped",
                       "row-scoped column and cell must share the same storage slot")
    }

    // MARK: - Shared field position regression (cross-page)

    func testSharedFieldPositionId_resolvesToCorrectPage() {
        let (editor, _) = makeNavigationEditor()
        let page1Path = "\(NavigationSample.page1ID)/\(NavigationSample.sharedFieldPositionID)"
        let page2Path = "\(NavigationSample.page2ID)/\(NavigationSample.sharedFieldPositionID)"

        editor.addDecorators(path: page1Path, decorators: [makeDecorator(action: "p1")])
        editor.addDecorators(path: page2Path, decorators: [makeDecorator(action: "p2")])

        XCTAssertEqual(editor.field(fieldID: NavigationSample.page1FieldID)?.decorators?.first?.action, "p1")
        XCTAssertEqual(editor.field(fieldID: NavigationSample.page2FieldID)?.decorators?.first?.action, "p2")
        XCTAssertNil(editor.field(fieldID: NavigationSample.page1FieldID)?.decorators?.first(where: { $0.action == "p2" }))
        XCTAssertNil(editor.field(fieldID: NavigationSample.page2FieldID)?.decorators?.first(where: { $0.action == "p1" }))
    }

    // MARK: - Invalid paths — structural

    func testInvalidPageId_returnsEmptyAndFiresOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "bogusPage/\(ChangerHandlerSample.tableFieldPositionID)"
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        XCTAssertTrue(mock.lastDecoratorErrorMessage?.contains("Failed to resolve path") ?? false)
    }

    func testInvalidFieldPositionId_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        _ = editor.getDecorators(path: "\(ChangerHandlerSample.pageID)/bogusFp")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testEmptyPath_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        _ = editor.getDecorators(path: "")
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testPathWithExtraSlashes_parsesCorrectly() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Double slashes must collapse (empty segments filtered)
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

    // MARK: - Invalid grammar shapes

    /// `rows` / `columns` must appear at terminal positions — anything after rejects.
    func testInvalidGrammar_rowsFollowedByExtra_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.tableCommonRowsPath())/extra"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "extra segments after /rows must reject")
    }

    func testInvalidGrammar_columnsMissingId_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/columns"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "columns with no id must reject")
    }

    func testInvalidGrammar_schemasMissingKey_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/schemas"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "schemas with no key must reject")
    }

    func testInvalidGrammar_schemasOnTable_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Tables have no schema tree — `/schemas/...` must reject
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/schemas/anyKey/rows"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "tables must reject the schemas keyword")
    }

    func testInvalidGrammar_rowFollowedByRows_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        // `fp/rowID/rows` isn't defined — you need /schemas/sk/rows to descend into children.
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/\(ChangerHandlerSample.tableRowID)/rows"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1)
    }

    func testInvalidGrammar_consecutiveRowIDsCollection_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        // Two row ids back-to-back without /schemas/ between them is ill-formed for collections.
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/\(ChangerHandlerSample.collectionRootRowID)/\(ChangerHandlerSample.collectionNestedRowID)"
        _ = editor.getDecorators(path: path)
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "consecutive row ids without /schemas/ must reject (or be interpreted as cell on a non-existent column → also an error)")
    }

    // MARK: - Unknown IDs

    func testInvalidRowId_collection_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/unknownRowID"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghost")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            XCTAssertNil(schema.rowDecorators?.first(where: { $0.action == "ghost" }))
        }
    }

    func testInvalidRowId_table_firesOnError_doesNotPersist() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.tableFieldPositionID)/bogusRowId"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "ghostTableRow")])
        XCTAssertEqual(mock.decoratorErrorCount, 1)
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        XCTAssertNil(field?.rowDecorators?.first(where: { $0.action == "ghostTableRow" }))
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
    }

    // MARK: - Cross-schema mismatch

    /// Root row id + nested column id on the same path must reject — the column
    /// isn't part of the row's resolved schema.
    func testCrossSchemaColumnMismatch_rootRowNestedColumn_firesOnError() {
        let (editor, mock) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/\(ChangerHandlerSample.collectionRootRowID)/\(ChangerHandlerSample.collectionNestedColumnID)"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "crossSchema")])
        XCTAssertEqual(mock.decoratorErrorCount, 1,
                       "cross-schema rowId/columnId mismatch must reject")
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        for (_, schema) in field?.schema ?? [:] {
            for col in schema.tableColumns ?? [] {
                XCTAssertNil(col.decorators?.first(where: { $0.action == "crossSchema" }))
            }
        }
    }
}
