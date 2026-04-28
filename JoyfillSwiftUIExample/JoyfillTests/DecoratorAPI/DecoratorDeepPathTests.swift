//
//  DecoratorDeepPathTests.swift
//  JoyfillTests
//
//  Exercises unbounded-depth collection paths and the `/columns/{col}` vs bare
//  `{col}` aliasing for row-scoped columns / cells.
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DecoratorDeepPathTests: XCTestCase {

    // MARK: - Depth-2 writes land on the correct nested element

    func testNestedRowSelf_landsOnNestedValueElement_notRoot() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath(),
                             decorators: [makeDecorator(action: "nestedSelf")])

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)

        // Must land on the nested element
        let nested = findValueElement(in: field, hops: [
            (ChangerHandlerSample.collectionRootSchemaKey,   ChangerHandlerSample.collectionRootRowID),
            (ChangerHandlerSample.collectionNestedSchemaKey, ChangerHandlerSample.collectionNestedRowID),
        ])
        XCTAssertEqual(nested?.decorators?.all.first?.action, "nestedSelf")

        // Root element must be untouched
        let root = findValueElement(in: field, hops: [
            (ChangerHandlerSample.collectionRootSchemaKey, ChangerHandlerSample.collectionRootRowID)
        ])
        XCTAssertNil(root?.decorators?.all.first(where: { $0.action == "nestedSelf" }))
    }

    func testNestedCell_landsOnNestedValueElementCells() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCellPath(),
                             decorators: [makeDecorator(action: "nestedCell")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let nested = findValueElement(in: field, hops: [
            (ChangerHandlerSample.collectionRootSchemaKey,   ChangerHandlerSample.collectionRootRowID),
            (ChangerHandlerSample.collectionNestedSchemaKey, ChangerHandlerSample.collectionNestedRowID),
        ])
        XCTAssertEqual(nested?.decorators?.cells[ChangerHandlerSample.collectionNestedColumnID]?.first?.action,
                       "nestedCell")
    }

    // MARK: - Scope isolation between root and nested

    func testRootAndNested_sameColumnId_areDistinctScopes() {
        // NOTE: this test only runs meaningfully if root and nested happen to share
        // a column ID. The sample document uses distinct IDs so we instead verify
        // that schema-scoped columns don't cross-pollute via their own IDs.
        let (editor, _) = makeChangerHandlerEditor()

        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonColumnPath(),
                             decorators: [makeDecorator(action: "rootOnly")])
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonColumnPath(),
                             decorators: [makeDecorator(action: "nestedOnly")])

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let rootCol = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        let nestedCol = field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionNestedColumnID })

        XCTAssertEqual(rootCol?.decorators?.map { $0.action ?? "" }, ["rootOnly"])
        XCTAssertEqual(nestedCol?.decorators?.map { $0.action ?? "" }, ["nestedOnly"])
    }

    // MARK: - `/columns/col` on a row aliases `/col` (bare) — same storage

    func testRowScopedColumn_aliasesCellStorage_tableRoundTrip() {
        let (editor, _) = makeChangerHandlerEditor()
        // Write via `/rowID/columns/colID`
        editor.addDecorators(path: ChangerHandlerSample.tableRowScopedColumnPath(),
                             decorators: [makeDecorator(action: "scoped")])
        // Read via `/rowID/colID` — must return the same decorator.
        let bareRead = editor.getDecorators(path: ChangerHandlerSample.tableCellPath())
        XCTAssertEqual(bareRead.map { $0.action }, ["scoped"])
        // And the reverse direction too
        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "bare")])
        let scopedRead = editor.getDecorators(path: ChangerHandlerSample.tableRowScopedColumnPath())
        XCTAssertEqual(scopedRead.map { $0.action }, ["scoped", "bare"])
    }

    func testRowScopedColumn_aliasesCellStorage_collectionNested() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowScopedColumnPath(),
                             decorators: [makeDecorator(action: "nScoped")])
        let bareRead = editor.getDecorators(path: ChangerHandlerSample.collectionNestedCellPath())
        XCTAssertEqual(bareRead.map { $0.action }, ["nScoped"])
    }

    // MARK: - Common-column at schema level (`/schemas/sk/columns/col` without row)

    func testCommonColumn_atSchemaRoot_withoutEnteringAnyRow() {
        // Path: fp/schemas/rootSK/columns/rootCol — no row in between
        let (editor, _) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/schemas/\(ChangerHandlerSample.collectionRootSchemaKey)/columns/\(ChangerHandlerSample.collectionRootColumnID)"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "schemaLevelCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "schemaLevelCol")
    }

    func testCommonRows_atSchemaRoot_withoutEnteringAnyRow() {
        // Path: fp/schemas/rootSK/rows — no row in between
        let (editor, _) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/schemas/\(ChangerHandlerSample.collectionRootSchemaKey)/rows"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "schemaLevelRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first?.action,
                       "schemaLevelRows")
    }

    // MARK: - decorate flag auto-enable

    func testDecorateFlag_table_enabledAfterRowSelfAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "x")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                       "adding row-self decorator must auto-enable decorate on the table field")
    }

    func testDecorateFlag_table_enabledAfterCommonRowsAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)
    }

    func testDecorateFlag_collectionRootSchema_enabledAfterRowSelfAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let field0 = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertNotEqual(field0?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "x")])

        let field1 = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field1?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                       "decorate should flip on the schema entry the row lives in")
    }

    func testDecorateFlag_collectionNestedSchema_enabledAfterNestedCommonRowsAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true)
    }

    /// Cell writes are column-scope — they don't affect decorate (which gates the row indicator area).
    func testDecorateFlag_notEnabledByCellWrite() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "x")])
        // Cell writes should NOT flip the decorate flag (per ensureDecorateEnabled implementation)
        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)
    }

    /// Common-column writes are column-scope too — they must not flip decorate on either field or schema.
    func testDecorateFlag_notEnabledByCommonColumnWrite_table() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonColumnPath(),
                             decorators: [makeDecorator(action: "x")])
        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)
    }

    func testDecorateFlag_notEnabledByCommonColumnWrite_collectionRoot() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonColumnPath(),
                             decorators: [makeDecorator(action: "x")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertNotEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)
    }

    /// Nested row-self flips the nested schema's decorate, not the root schema's
    /// (uses `hops.last?.schemaKey` in ensureDecorateEnabled).
    func testDecorateFlag_nestedRowSelf_flipsNestedSchemaOnly_notRoot() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath(),
                             decorators: [makeDecorator(action: "x")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true,
                       "nested row-self must flip the nested schema's decorate")
        XCTAssertNotEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                          "nested row-self must NOT flip the root schema's decorate")
    }

    /// Collection writes must not leak into the unrelated table field's decorate flag.
    func testDecorateFlag_collectionRowsWrite_doesNotAffectTableField() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                          "collection row writes must not affect table field's decorate flag")
    }

    /// Schema-root common-rows path (`fp/schemas/sk/rows`, no row in between) also auto-enables decorate.
    func testDecorateFlag_flipsVia_schemaRootCommonRowsPath() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = "\(ChangerHandlerSample.pageID)/\(ChangerHandlerSample.collectionFieldPositionID)/schemas/\(ChangerHandlerSample.collectionRootSchemaKey)/rows"
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)
    }

    // NOTE: The "one-way latch" assertions that used to live here (decorate stays true
    // after removing the last decorator) encoded the pre-fix behavior. That was a bug —
    // `decorate` must flip back to false when the scope goes empty, otherwise the
    // decorator column renders with no content. The inverted-assertion replacements
    // live in `DecoratorPublicAPITests.swift`:
    //   • testDecorateFlag_table_disabledAfterRemovingLastCommonRowsDecorator
    //   • testDecorateFlag_collectionRoot_disabledAfterRemovingLastCommonRowsDecorator
}
