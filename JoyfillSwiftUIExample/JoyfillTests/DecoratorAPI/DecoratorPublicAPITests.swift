//
//  DecoratorPublicAPITests.swift
//  JoyfillTests
//
//  Happy-path tests for getDecorators / addDecorators / removeDecorator / updateDecorator
//  across every scope of the new grammar:
//    field, common rows, row-self, common column, cell.
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class DecoratorPublicAPITests: XCTestCase {

    // MARK: - getDecorators

    func testGetDecorators_emptyField_returnsEmpty() {
        let (editor, _) = makeChangerHandlerEditor()
        XCTAssertEqual(editor.getDecorators(path: ChangerHandlerSample.tableFieldPath()).count, 0)
    }

    func testGetDecorators_returnsWhatWasWritten() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a"), makeDecorator(action: "b")])
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["a", "b"])
    }

    // MARK: - addDecorators — field scope

    func testAddDecorators_toEmptyField_appendsAll() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "x")])
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["x"])
    }

    func testAddDecorators_multipleInOneCall() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
            makeDecorator(action: "c"),
        ])
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["a", "b", "c"])
    }

    func testAddDecorators_appendsToExistingList_preservesOrder() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "first")])
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "second")])
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["first", "second"])
    }

    // MARK: - addDecorators — common rows

    func testAddDecorators_tableCommonRows_persistsOnField() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "rows1")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.rowDecorators?.first?.action, "rows1")
    }

    func testAddDecorators_collectionRootCommonRows_persistsOnRootSchema() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "rootRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first?.action, "rootRows")
    }

    func testAddDecorators_collectionNestedCommonRows_persistsOnNestedSchema() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nestedRows")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.rowDecorators?.first?.action, "nestedRows")
    }

    // MARK: - addDecorators — row-self

    func testAddDecorators_tableRowSelf_persistsOnValueElement() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "self1")])
        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.tableFieldID),
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "self1")
    }

    func testAddDecorators_collectionRootRowSelf_persistsOnValueElement() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rootSelf")])
        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.collectionFieldID),
                                   hops: [(ChangerHandlerSample.collectionRootSchemaKey,
                                           ChangerHandlerSample.collectionRootRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "rootSelf")
    }

    // MARK: - addDecorators — common column

    func testAddDecorators_tableCommonColumn_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonColumnPath(),
                             decorators: [makeDecorator(action: "col1")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "col1")
    }

    func testAddDecorators_collectionRootCommonColumn_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonColumnPath(),
                             decorators: [makeDecorator(action: "rootCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "rootCol")
    }

    // MARK: - addDecorators — cell

    func testAddDecorators_tableCell_persistsOnValueElementCells() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "cell1")])
        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.tableFieldID),
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.cells[ChangerHandlerSample.tableColumnID]?.first?.action, "cell1")
    }

    // MARK: - removeDecorator

    func testRemoveDecorator_existingAction_reducesList() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a"), makeDecorator(action: "b")])
        editor.removeDecorator(path: path, action: "a")
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["b"])
    }

    func testRemoveDecorator_lastDecorator_listBecomesEmpty() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])
        editor.removeDecorator(path: path, action: "only")
        XCTAssertEqual(editor.getDecorators(path: path).count, 0)
    }

    func testRemoveDecorator_rowSelf_roundTrip() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableRowSelfPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "keep"), makeDecorator(action: "toss")])
        editor.removeDecorator(path: path, action: "toss")
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["keep"])
    }

    func testRemoveDecorator_cell_roundTrip() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableCellPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "cellKeep"), makeDecorator(action: "cellToss")])
        editor.removeDecorator(path: path, action: "cellToss")
        XCTAssertEqual(editor.getDecorators(path: path).map { $0.action }, ["cellKeep"])
    }

    // MARK: - updateDecorator

    func testUpdateDecorator_existingAction_replacesAtSameIndex() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a", icon: "flag", label: "Flag", color: "#FF0000"),
            makeDecorator(action: "b", icon: "eye",  label: "Eye",  color: "#00FF00"),
        ])
        editor.updateDecorator(path: path, action: "a",
                               decorator: makeDecorator(action: "a", icon: "camera", label: "Updated", color: "#0000FF"))
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.map { $0.action }, ["a", "b"])
        XCTAssertEqual(read.first?.label, "Updated")
        XCTAssertEqual(read.first?.color, "#0000FF")
        XCTAssertEqual(read.first?.icon,  "camera")
    }

    func testUpdateDecorator_preservesOtherDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
            makeDecorator(action: "c"),
        ])
        editor.updateDecorator(path: path, action: "b",
                               decorator: makeDecorator(action: "b", label: "B-prime"))
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.map { $0.action }, ["a", "b", "c"])
        XCTAssertEqual(read[1].label, "B-prime")
    }

    // MARK: - End-to-end

    func testMultipleConsecutiveOperations_finalStateCorrect() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a")])
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "b")])
        editor.updateDecorator(path: path, action: "a", decorator: makeDecorator(action: "a", label: "AA"))
        editor.removeDecorator(path: path, action: "b")
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "c")])
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.map { $0.action }, ["a", "c"])
        XCTAssertEqual(read.first?.label, "AA")
    }

    func testFieldMap_reflectsDecoratorChanges() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableFieldPath(),
                             decorators: [makeDecorator(action: "live")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorators?.first?.action, "live")
    }

    // MARK: - decorate flag: flips off when scope becomes empty
    //
    // Mirror of ensureDecorateEnabled on add. After remove/update, if the
    // affected scope (table field, root schema, or nested schema) has no
    // displayable decorators left — neither common rowDecorators nor any
    // row-specific decorator on any row in that scope — decorate flips to false.

    // -- Table field

    func testDecorateFlag_table_disabledAfterRemovingLastCommonRowsDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableCommonRowsPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                          "decorate should flip off once the last common row decorator is removed")
    }

    func testDecorateFlag_table_disabledAfterRemovingLastRowSelfDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableRowSelfPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                          "decorate should flip off once the last row-self decorator is removed")
    }

    func testDecorateFlag_table_staysTrueWhenAnotherCommonRowsDecoratorRemains() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableCommonRowsPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
        ])

        editor.removeDecorator(path: path, action: "a")

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                       "decorate must stay true while any common row decorator remains")
    }

    func testDecorateFlag_table_staysTrueWhenRowSelfExistsAfterCommonRemoved() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "common")])
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])

        editor.removeDecorator(path: ChangerHandlerSample.tableCommonRowsPath(), action: "common")

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                       "decorate must stay true because a row-specific decorator still exists")
    }

    func testDecorateFlag_table_staysTrueWhenCommonExistsAfterRowSelfRemoved() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "common")])
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])

        editor.removeDecorator(path: ChangerHandlerSample.tableRowSelfPath(), action: "rowSelf")

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                       "decorate must stay true because a common decorator still exists")
    }

    /// Regression guard: deleted rows must not keep `decorate` pinned on.
    /// If the only remaining row-self decorator belongs to a soft-deleted row,
    /// removing the last common row decorator should flip `decorate` off.
    func testDecorateFlag_table_deletedRowSelfDoesNotKeepDecoratePinned() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "common")])
        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)

        let fieldIdentifier = editor.getFieldIdentifier(for: ChangerHandlerSample.tableFieldID)
        _ = editor.deleteRows(rowIDs: [ChangerHandlerSample.tableRowID],
                              fieldIdentifier: fieldIdentifier,
                              shouldSendEvent: false)
        editor.removeDecorator(path: ChangerHandlerSample.tableCommonRowsPath(), action: "common")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                          "row-self decorators on deleted rows must be ignored when deciding decorate emptiness")
    }

    // -- Collection root schema

    func testDecorateFlag_collectionRoot_disabledAfterRemovingLastCommonRowsDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootCommonRowsPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                        .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                            .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                          "root schema's decorate should flip off after last common decorator removed")
    }

    func testDecorateFlag_collectionRoot_disabledAfterRemovingLastRowSelfDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionRootRowSelfPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                            .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)
    }

    func testDecorateFlag_collectionRoot_staysTrueWhenRowSelfExistsAfterCommonRemoved() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "common")])
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])

        editor.removeDecorator(path: ChangerHandlerSample.collectionRootCommonRowsPath(), action: "common")

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                        .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                       "root schema's decorate must stay true because a row-specific decorator remains")
    }

    /// Same deleted-row regression at collection root schema scope.
    func testDecorateFlag_collectionRoot_deletedRowSelfDoesNotKeepDecoratePinned() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "common")])
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                        .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)

        // Simulate a soft-deleted root row (collection delete APIs hard-delete).
        if var field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID) {
            var rows = field.valueToValueElements ?? []
            if let idx = rows.firstIndex(where: { $0.id == ChangerHandlerSample.collectionRootRowID }) {
                var row = rows[idx]
                row.setDeleted()
                rows[idx] = row
                field.value = ValueUnion.valueElementArray(rows)
                editor.updateField(field: field)
            } else {
                XCTFail("Expected sample root collection row not found")
            }
        } else {
            XCTFail("Expected sample collection field not found")
        }

        editor.removeDecorator(path: ChangerHandlerSample.collectionRootCommonRowsPath(), action: "common")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                            .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                          "deleted root row decorators must not keep root decorate true")
    }

    // -- Collection nested schema

    func testDecorateFlag_collectionNested_disabledAfterRemovingLastCommonRowsDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionNestedCommonRowsPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                        .schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true)

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                            .schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true)
    }

    func testDecorateFlag_collectionNested_disabledAfterRemovingLastRowSelfDecorator() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.collectionNestedRowSelfPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only")])

        editor.removeDecorator(path: path, action: "only")

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                            .schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true)
    }

    // -- Scope isolation

    /// Removing a table decorator must not flip the collection's decorate flag.
    func testDecorateFlag_tableRemoval_doesNotAffectCollectionDecorate() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "t")])
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "c")])

        editor.removeDecorator(path: ChangerHandlerSample.tableCommonRowsPath(), action: "t")

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.collectionFieldID)?
                        .schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                       "collection's decorate must not flip off when a table decorator is removed")
    }

    /// Removing from nested schema must not flip the root schema's decorate off.
    func testDecorateFlag_nestedRemoval_doesNotFlipRootDecorate() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "root")])
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nested")])

        editor.removeDecorator(path: ChangerHandlerSample.collectionNestedCommonRowsPath(), action: "nested")

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true,
                       "root schema's decorate must stay true — only the nested schema scope went empty")
        XCTAssertNotEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true,
                          "nested schema's decorate must flip off")
    }

    /// Removing from root must not flip the nested schema's decorate off.
    func testDecorateFlag_rootRemoval_doesNotFlipNestedDecorate() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "root")])
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nested")])

        editor.removeDecorator(path: ChangerHandlerSample.collectionRootCommonRowsPath(), action: "root")

        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertNotEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.decorate, true)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.decorate, true,
                       "nested schema's decorate must stay true — only the root scope went empty")
    }

    // -- updateDecorator path

    /// Updating a decorator to remove its icon AND label makes it non-displayable.
    /// If it was the only one, decorate must flip off.
    func testDecorateFlag_disabledAfterUpdateMakesLastDecoratorNonDisplayable() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableCommonRowsPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only", icon: "flag", label: "Flag")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)

        // Update to a decorator with empty icon AND empty label → isDisplayable = false
        let emptyDecorator = makeDecorator(action: "only", icon: "", label: "")
        editor.updateDecorator(path: path, action: "only", decorator: emptyDecorator)

        XCTAssertNotEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                          "decorate should flip off when the only remaining decorator becomes non-displayable")
    }

    /// Updating a decorator but keeping it displayable must leave decorate on.
    func testDecorateFlag_staysTrueAfterUpdateKeepsDecoratorDisplayable() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableCommonRowsPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "only", icon: "flag", label: "Flag")])

        editor.updateDecorator(path: path, action: "only",
                               decorator: makeDecorator(action: "only", icon: "warning", label: "Warning"))

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true,
                       "decorate must remain true after a displayable update")
    }
}
