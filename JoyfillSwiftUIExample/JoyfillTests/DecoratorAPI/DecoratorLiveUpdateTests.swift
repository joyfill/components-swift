//
//  DecoratorLiveUpdateTests.swift
//  JoyfillTests
//
//  Verifies that when decorators change via the public API, any live
//  TableViewModel / CollectionViewModel registered as a delegate has its
//  cached state refreshed via `decoratorsDidChange()` — so the UI reflects
//  the change without rebuilding the modal.
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
@testable import Joyfill

final class DecoratorLiveUpdateTests: XCTestCase {

    // MARK: - Helpers

    private func waitForMainQueueToDrain() {
        let exp = expectation(description: "Drain main queue")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }

    /// Polls until the delegate has been registered for the given field, or fails.
    private func waitForDelegate(_ editor: DocumentEditor, fieldID: String, timeout: TimeInterval = 5.0) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if editor.delegateMap[fieldID]?.value != nil { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTFail("Delegate for fieldID \(fieldID) was not registered within \(timeout)s")
    }

    private func makeTableViewModel(editor: DocumentEditor) -> TableViewModel {
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        let header = FieldHeaderModel(title: field?.title, required: field?.required,
                                      tipDescription: field?.tipDescription,
                                      tipTitle: field?.tipTitle, tipVisible: field?.tipVisible)
        let model = TableDataModel(
            fieldHeaderModel: header,
            mode: .fill,
            documentEditor: editor,
            fieldIdentifier: FieldIdentifier(fieldID: ChangerHandlerSample.tableFieldID,
                                             pageID: ChangerHandlerSample.pageID,
                                             fileID: ChangerHandlerSample.fileID)
        )
        return TableViewModel(tableDataModel: model!)
    }

    private func makeCollectionViewModel(editor: DocumentEditor) -> CollectionViewModel {
        let field = editor.field(fieldID: ChangerHandlerSample.collectionFieldID)
        let header = FieldHeaderModel(title: field?.title, required: field?.required,
                                      tipDescription: field?.tipDescription,
                                      tipTitle: field?.tipTitle, tipVisible: field?.tipVisible)
        let model = TableDataModel(
            fieldHeaderModel: header,
            mode: .fill,
            documentEditor: editor,
            fieldIdentifier: FieldIdentifier(fieldID: ChangerHandlerSample.collectionFieldID,
                                             pageID: ChangerHandlerSample.pageID,
                                             fileID: ChangerHandlerSample.fileID)
        )
        return CollectionViewModel(tableDataModel: model!)
    }

    // MARK: - TableViewModel

    func testTableViewModel_addRowDecorator_updatesRowDecoratorsCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        XCTAssertTrue(vm.tableDataModel.rowDecorators.isEmpty)

        editor.addDecorators(path: ChangerHandlerSample.tableRowPath(),
                             decorators: [makeDecorator(action: "live-row")])
        waitForMainQueueToDrain()

        XCTAssertEqual(vm.tableDataModel.rowDecorators.first?.action, "live-row")
        XCTAssertTrue(vm.showRowDecorators)
    }

    func testTableViewModel_addColumnDecorator_updatesTableColumnsDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)

        editor.addDecorators(path: ChangerHandlerSample.tableColumnPath(),
                             decorators: [makeDecorator(action: "live-col")])
        waitForMainQueueToDrain()

        let col = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "live-col")
    }

    func testTableViewModel_removeRowDecorator_updatesCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        let path = ChangerHandlerSample.tableRowPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
        ])
        waitForMainQueueToDrain()
        XCTAssertEqual(vm.tableDataModel.rowDecorators.count, 2)

        editor.removeDecorator(path: path, action: "a")
        waitForMainQueueToDrain()

        XCTAssertEqual(vm.tableDataModel.rowDecorators.map { $0.action }, ["b"])
    }

    func testTableViewModel_updateRowDecorator_updatesCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        let path = ChangerHandlerSample.tableRowPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a", label: "Old")])
        waitForMainQueueToDrain()

        editor.updateDecorator(path: path, action: "a",
                               decorator: makeDecorator(action: "a", label: "New"))
        waitForMainQueueToDrain()

        XCTAssertEqual(vm.tableDataModel.rowDecorators.first?.label, "New")
    }

    // MARK: - CollectionViewModel

    func testCollectionViewModel_addRootRowDecorator_updatesSchemaAndCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowPath(),
                             decorators: [makeDecorator(action: "rootRow")])
        waitForMainQueueToDrain()

        // The DecoratorLocal cache used for rendering
        let cached = vm.tableDataModel.rowDecoratorsBySchemaKey[ChangerHandlerSample.collectionRootSchemaKey]
        XCTAssertEqual(cached?.first?.action, "rootRow")

        // The schema mirror that backs `hasAnyRowDecorators`
        let schemaRow = vm.tableDataModel.schema[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators
        XCTAssertEqual(schemaRow?.first?.action, "rootRow")
    }

    func testCollectionViewModel_addNestedRowDecorator_updatesNestedSchema() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowPath(),
                             decorators: [makeDecorator(action: "nested")])
        waitForMainQueueToDrain()

        let cached = vm.tableDataModel.rowDecoratorsBySchemaKey[ChangerHandlerSample.collectionNestedSchemaKey]
        XCTAssertEqual(cached?.first?.action, "nested")
        // Should not appear in the root schema cache
        let rootCached = vm.tableDataModel.rowDecoratorsBySchemaKey[ChangerHandlerSample.collectionRootSchemaKey] ?? []
        XCTAssertNil(rootCached.first(where: { $0.action == "nested" }))
    }

    func testCollectionViewModel_addRootColumnDecorator_updatesRootTableColumns() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootColumnPath(),
                             decorators: [makeDecorator(action: "rootCol")])
        waitForMainQueueToDrain()

        // Root mirror in tableDataModel.tableColumns
        let mirroredCol = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(mirroredCol?.decorators?.first?.action, "rootCol")
        // Schema-level columns
        let schemaCol = vm.tableDataModel.schema[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(schemaCol?.decorators?.first?.action, "rootCol")
    }

    func testCollectionViewModel_addNestedColumnDecorator_updatesSchemaTableColumns() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedColumnPath(),
                             decorators: [makeDecorator(action: "nestedCol")])
        waitForMainQueueToDrain()

        let schemaCol = vm.tableDataModel.schema[ChangerHandlerSample.collectionNestedSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionNestedColumnID })
        XCTAssertEqual(schemaCol?.decorators?.first?.action, "nestedCol")
    }

    /// Regression: before the fix, `tableDataModel.schema` was not refreshed in `decoratorsDidChange()`,
    /// so `hasAnyRowDecorators` (which reads from `schema.values`) returned false even after a row
    /// decorator was added — meaning the row decorator column never appeared.
    func testCollectionViewModel_hasAnyRowDecorators_flipsTrueAfterFirstAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)
        XCTAssertFalse(vm.tableDataModel.hasAnyRowDecorators, "starts with no row decorators")

        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowPath(),
                             decorators: [makeDecorator(action: "first")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.tableDataModel.hasAnyRowDecorators,
                      "schema must be refreshed so hasAnyRowDecorators sees the new row decorator")
        XCTAssertTrue(vm.showRowDecorators)
    }

    // MARK: - Lazy delegate creation

    func testNoDelegateRegistered_lazilyCreates_noCrash_dataPersisted() {
        let (editor, mock) = makeChangerHandlerEditor()
        // No view model registered for the table field yet.
        XCTAssertNil(editor.delegateMap[ChangerHandlerSample.tableFieldID]?.value)

        editor.addDecorators(path: ChangerHandlerSample.tableRowPath(),
                             decorators: [makeDecorator(action: "lazy")])
        waitForMainQueueToDrain()

        XCTAssertEqual(mock.decoratorErrorCount, 0)
        // Data persisted regardless of whether a UI was listening
        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.rowDecorators?.first?.action, "lazy")
    }

    func testDelegateForOtherField_notAffected() {
        let (editor, _) = makeChangerHandlerEditor()
        let tableVM = makeTableViewModel(editor: editor)

        // Mutate the COLLECTION field — table VM should not be touched.
        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowPath(),
                             decorators: [makeDecorator(action: "collOnly")])
        waitForMainQueueToDrain()

        XCTAssertTrue(tableVM.tableDataModel.rowDecorators.isEmpty,
                      "table view model must be untouched when a different field changes")
    }
}
