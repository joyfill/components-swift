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
}
