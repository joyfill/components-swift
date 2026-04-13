//
//  DecoratorPublicAPITests.swift
//  JoyfillTests
//
//  Happy-path tests for getDecorators / addDecorators / removeDecorator / updateDecorator
//  on field, row, and column scopes for both table and collection fields.
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
        let decs = [makeDecorator(action: "a"), makeDecorator(action: "b")]
        editor.addDecorators(path: path, decorators: decs)
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.map { $0.action }, ["a", "b"])
    }

    // MARK: - addDecorators

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

    func testAddDecorators_tableRow_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableRowPath(),
                             decorators: [makeDecorator(action: "row1")])
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.rowDecorators?.first?.action, "row1")
    }

    func testAddDecorators_collectionRootRow_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowPath(),
                             decorators: [makeDecorator(action: "rootRow")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators?.first?.action, "rootRow")
    }

    func testAddDecorators_collectionNestedRow_persistsToCorrectSchema() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowPath(),
                             decorators: [makeDecorator(action: "nestedRow")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertEqual(field?.schema?[ChangerHandlerSample.collectionNestedSchemaKey]?.rowDecorators?.first?.action, "nestedRow")
    }

    func testAddDecorators_tableColumn_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableColumnPath(),
                             decorators: [makeDecorator(action: "col1")])
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let col = field?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "col1")
    }

    func testAddDecorators_collectionColumn_persists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.collectionRootColumnPath(),
                             decorators: [makeDecorator(action: "rootCol")])
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let col = field?.schema?[ChangerHandlerSample.collectionRootSchemaKey]?.tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "rootCol")
    }

    // MARK: - removeDecorator

    func testRemoveDecorator_existingAction_reducesList() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
        ])
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

    // MARK: - updateDecorator

    func testUpdateDecorator_existingAction_replacesAtSameIndex() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a", icon: "flag", label: "Flag", color: "#FF0000"),
            makeDecorator(action: "b", icon: "eye", label: "Eye", color: "#00FF00"),
        ])
        let replacement = makeDecorator(action: "a", icon: "camera", label: "Updated", color: "#0000FF")
        editor.updateDecorator(path: path, action: "a", decorator: replacement)
        let read = editor.getDecorators(path: path)
        XCTAssertEqual(read.map { $0.action }, ["a", "b"]) // index preserved
        XCTAssertEqual(read.first?.label, "Updated")
        XCTAssertEqual(read.first?.color, "#0000FF")
        XCTAssertEqual(read.first?.icon, "camera")
    }

    func testUpdateDecorator_preservesOtherDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        let path = ChangerHandlerSample.tableFieldPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
            makeDecorator(action: "c"),
        ])
        editor.updateDecorator(path: path, action: "b", decorator: makeDecorator(action: "b", label: "B-prime"))
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
