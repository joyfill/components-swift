//
//  DecoratorLiveUpdateTests.swift
//  JoyfillTests
//
//  Verifies that when decorators change via the public API, any live
//  TableViewModel / CollectionViewModel registered as a delegate has its
//  cached state refreshed via `decoratorsDidChange()` — so the UI reflects
//  the change without rebuilding the modal.
//
//  Scope mapping under the new-grammar:
//    - `/rows`            → schema.rowDecorators          (row-indicator column)
//    - `/columns/{col}`   → tableColumns[col].decorators  (column indicator)
//    - `/{rowID}`         → ValueElement.decorators.all   (row-self)
//    - `/{rowID}/{col}`   → ValueElement.decorators.cells (cell)
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

    // MARK: - TableViewModel — common rows / common columns (cache-backed)

    // MARK: - `decorate` flag — live vs snapshot behavior

    /// `TableViewModel.showRowDecorators` flips live when a common-row decorator
    /// is added to an already-built view model — `decoratorsDidChange()` refreshes
    /// `tableDataModel.decorate` from the field, and the computed property re-reads it.
    func testTableViewModel_showRowDecorators_flipsLive_onCommonRowAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        XCTAssertFalse(vm.showRowDecorators, "starts false — no decorators yet")

        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        waitForMainQueueToDrain()

        XCTAssertEqual(editor.field(fieldID: ChangerHandlerSample.tableFieldID)?.decorate, true)
        XCTAssertTrue(vm.showRowDecorators,
                      "decoratorsDidChange must refresh tableDataModel.decorate so the row-indicator column appears live")
    }

    /// Row-self writes also flip `decorate` on the field (per ensureDecorateEnabled),
    /// so the VM must pick it up live too.
    func testTableViewModel_showRowDecorators_flipsLive_onRowSelfAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        XCTAssertFalse(vm.showRowDecorators)

        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "x")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.showRowDecorators,
                      "row-self writes flip field.decorate too, must reach showRowDecorators live")
    }

    /// Cell / common-column writes do NOT flip `decorate`, so `showRowDecorators` stays false.
    func testTableViewModel_showRowDecorators_notFlipped_byCellOrCommonColumnWrites() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)

        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "cell")])
        editor.addDecorators(path: ChangerHandlerSample.tableCommonColumnPath(),
                             decorators: [makeDecorator(action: "col")])
        waitForMainQueueToDrain()

        XCTAssertFalse(vm.showRowDecorators,
                       "column-scope writes must not flip the row-indicator area")
    }

    /// Inverse: if the VM is built AFTER the decorator exists, the snapshot picks
    /// up the true flag and the row-indicator column renders correctly. This path
    /// is what currently keeps tables usable — the UI typically constructs the VM
    /// fresh when the modal opens.
    func testTableViewModel_showRowDecorators_trueWhenBuiltAfterDecoratorExists() {
        let (editor, _) = makeChangerHandlerEditor()
        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "pre-existing")])

        let vm = makeTableViewModel(editor: editor)
        XCTAssertTrue(vm.showRowDecorators,
                      "VM built after the decorator exists must see decorate=true on its snapshot")
    }

    /// Collection counterpart — `hasAnyRowDecorators(schemaKey:)` reads from
    /// `tableDataModel.schema`, which `decoratorsDidChange()` does refresh.
    /// So the collection UI picks up the flag live (unlike tables).
    func testCollectionViewModel_hasAnyRowDecorators_flipsLive_onCommonRowAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)
        let rootSK = ChangerHandlerSample.collectionRootSchemaKey
        XCTAssertFalse(vm.tableDataModel.hasAnyRowDecorators(schemaKey: rootSK))

        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.tableDataModel.hasAnyRowDecorators(schemaKey: rootSK),
                      "collection's schema mirror IS refreshed, so hasAnyRowDecorators flips live")
    }

    /// Collection nested schema — same live-flip behavior.
    func testCollectionViewModel_hasAnyRowDecorators_flipsLive_onNestedCommonRowAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)
        let nestedSK = ChangerHandlerSample.collectionNestedSchemaKey

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "x")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.tableDataModel.hasAnyRowDecorators(schemaKey: nestedSK))
        // Root schema must NOT flip from a nested-only write.
        XCTAssertFalse(vm.tableDataModel.hasAnyRowDecorators(schemaKey: ChangerHandlerSample.collectionRootSchemaKey))
    }

    /// Row-self write also flips the schema's `decorate`, reaching
    /// `hasAnyRowDecorators` live via the refreshed schema mirror.
    func testCollectionViewModel_hasAnyRowDecorators_flipsLive_onRowSelfAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)
        let rootSK = ChangerHandlerSample.collectionRootSchemaKey

        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "x")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.tableDataModel.hasAnyRowDecorators(schemaKey: rootSK),
                      "row-self writes flip the schema's decorate flag, visible live through the mirror")
    }

    // MARK: - Row decorator cache (works correctly on tables too)

    func testTableViewModel_addCommonRowDecorator_refreshesRowDecoratorCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)

        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
                             decorators: [makeDecorator(action: "live-row")])
        waitForMainQueueToDrain()

        // Source of truth — field got the decorator + decorate flag.
        let field = editor.field(fieldID: ChangerHandlerSample.tableFieldID)
        XCTAssertEqual(field?.rowDecorators?.first?.action, "live-row")
        XCTAssertEqual(field?.decorate, true)

        // Delegate refresh — per-row cache populated with the common-row decorator.
        let cached = vm.tableDataModel.tableRowDecorators[ChangerHandlerSample.tableRowID] ?? []
        XCTAssertEqual(cached.first?.action, "live-row",
                       "decoratorsDidChange must refresh tableRowDecorators from field.rowDecorators")
    }

    func testTableViewModel_addCommonColumnDecorator_updatesTableColumnsDecorators() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)

        editor.addDecorators(path: ChangerHandlerSample.tableCommonColumnPath(),
                             decorators: [makeDecorator(action: "live-col")])
        waitForMainQueueToDrain()

        let col = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.action, "live-col")
    }

    func testTableViewModel_removeCommonColumnDecorator_updatesCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        let path = ChangerHandlerSample.tableCommonColumnPath()
        editor.addDecorators(path: path, decorators: [
            makeDecorator(action: "a"),
            makeDecorator(action: "b"),
        ])
        waitForMainQueueToDrain()

        editor.removeDecorator(path: path, action: "a")
        waitForMainQueueToDrain()

        let col = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.map { $0.action ?? "" }, ["b"])
    }

    func testTableViewModel_updateCommonColumnDecorator_updatesCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeTableViewModel(editor: editor)
        let path = ChangerHandlerSample.tableCommonColumnPath()
        editor.addDecorators(path: path, decorators: [makeDecorator(action: "a", label: "Old")])
        waitForMainQueueToDrain()

        editor.updateDecorator(path: path, action: "a",
                               decorator: makeDecorator(action: "a", label: "New"))
        waitForMainQueueToDrain()

        let col = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.tableColumnID })
        XCTAssertEqual(col?.decorators?.first?.label, "New")
    }

    // MARK: - TableViewModel — row-self / cell (lands on ValueElement)

    func testTableViewModel_addRowSelfDecorator_persistsOnValueElement() {
        let (editor, _) = makeChangerHandlerEditor()
        _ = makeTableViewModel(editor: editor) // ensure delegate wired

        editor.addDecorators(path: ChangerHandlerSample.tableRowSelfPath(),
                             decorators: [makeDecorator(action: "rowSelf")])
        waitForMainQueueToDrain()

        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.tableFieldID),
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "rowSelf")
    }

    func testTableViewModel_addCellDecorator_persistsOnValueElementCells() {
        let (editor, _) = makeChangerHandlerEditor()
        _ = makeTableViewModel(editor: editor)

        editor.addDecorators(path: ChangerHandlerSample.tableCellPath(),
                             decorators: [makeDecorator(action: "cell")])
        waitForMainQueueToDrain()

        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.tableFieldID),
                                   hops: [(nil, ChangerHandlerSample.tableRowID)])
        XCTAssertEqual(row?.decorators?.cells[ChangerHandlerSample.tableColumnID]?.first?.action, "cell")
    }

    // MARK: - CollectionViewModel — common-rows / common-columns

    func testCollectionViewModel_addRootCommonRowDecorator_updatesSchemaAndCache() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "rootRow")])
        waitForMainQueueToDrain()

        // The schema mirror that backs `hasAnyRowDecorators`
        let schemaRow = vm.tableDataModel.schema[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators
        XCTAssertEqual(schemaRow?.first?.action, "rootRow")
    }

    func testCollectionViewModel_addNestedCommonRowDecorator_updatesNestedSchema() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonRowsPath(),
                             decorators: [makeDecorator(action: "nested")])
        waitForMainQueueToDrain()

        let nestedSchemaRow = vm.tableDataModel.schema[ChangerHandlerSample.collectionNestedSchemaKey]?.rowDecorators
        XCTAssertEqual(nestedSchemaRow?.first?.action, "nested")
        // Should not appear in the root schema
        let rootSchemaRow = vm.tableDataModel.schema[ChangerHandlerSample.collectionRootSchemaKey]?.rowDecorators ?? []
        XCTAssertNil(rootSchemaRow.first(where: { $0.action == "nested" }))
    }

    func testCollectionViewModel_addRootCommonColumnDecorator_updatesRootTableColumns() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonColumnPath(),
                             decorators: [makeDecorator(action: "rootCol")])
        waitForMainQueueToDrain()

        // Root mirror in tableDataModel.tableColumns
        let mirroredCol = vm.tableDataModel.tableColumns.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(mirroredCol?.decorators?.first?.action, "rootCol")
        // Schema-level columns
        let schemaCol = vm.tableDataModel.schema[ChangerHandlerSample.collectionRootSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionRootColumnID })
        XCTAssertEqual(schemaCol?.decorators?.first?.action, "rootCol")
        // columnsMap (authoritative source read by CollectionModalTopNavigationView)
        let mapKey = "\(ChangerHandlerSample.collectionRootSchemaKey)_\(ChangerHandlerSample.collectionRootColumnID)"
        let mappedCol = vm.columnsMap[mapKey]
        XCTAssertEqual(mappedCol?.decorators?.first?.action, "rootCol",
                       "columnsMap must be rebuilt so the navigation view reads fresh column decorators")
    }

    func testCollectionViewModel_addNestedCommonColumnDecorator_updatesSchemaTableColumns() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedCommonColumnPath(),
                             decorators: [makeDecorator(action: "nestedCol")])
        waitForMainQueueToDrain()

        let schemaCol = vm.tableDataModel.schema[ChangerHandlerSample.collectionNestedSchemaKey]?
            .tableColumns?.first(where: { $0.id == ChangerHandlerSample.collectionNestedColumnID })
        XCTAssertEqual(schemaCol?.decorators?.first?.action, "nestedCol")
        // columnsMap — critical for nested columns, which the navigation view's old
        // code path (RowType.header.tableColumns snapshot) left stale.
        let mapKey = "\(ChangerHandlerSample.collectionNestedSchemaKey)_\(ChangerHandlerSample.collectionNestedColumnID)"
        let mappedCol = vm.columnsMap[mapKey]
        XCTAssertEqual(mappedCol?.decorators?.first?.action, "nestedCol",
                       "nested column decorators must be reflected in columnsMap")
    }

    // MARK: - CollectionViewModel — row-self / cell (ValueElement storage)

    func testCollectionViewModel_addRootRowSelfDecorator_persistsOnValueElement() {
        let (editor, _) = makeChangerHandlerEditor()
        _ = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionRootRowSelfPath(),
                             decorators: [makeDecorator(action: "rootSelf")])
        waitForMainQueueToDrain()

        let row = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.collectionFieldID),
                                   hops: [(ChangerHandlerSample.collectionRootSchemaKey,
                                           ChangerHandlerSample.collectionRootRowID)])
        XCTAssertEqual(row?.decorators?.all.first?.action, "rootSelf")
    }

    func testCollectionViewModel_addNestedRowSelfDecorator_persistsOnNestedValueElement() {
        let (editor, _) = makeChangerHandlerEditor()
        _ = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)

        editor.addDecorators(path: ChangerHandlerSample.collectionNestedRowSelfPath(),
                             decorators: [makeDecorator(action: "nestedSelf")])
        waitForMainQueueToDrain()

        let nested = findValueElement(in: editor.field(fieldID: ChangerHandlerSample.collectionFieldID),
                                      hops: [(ChangerHandlerSample.collectionRootSchemaKey,
                                              ChangerHandlerSample.collectionRootRowID),
                                             (ChangerHandlerSample.collectionNestedSchemaKey,
                                              ChangerHandlerSample.collectionNestedRowID)])
        XCTAssertEqual(nested?.decorators?.all.first?.action, "nestedSelf")
    }

    /// Regression: before the fix, `tableDataModel.schema` was not refreshed in `decoratorsDidChange()`,
    /// so `hasAnyRowDecorators` (which reads from `schema.values`) returned false even after a row
    /// decorator was added — meaning the row decorator column never appeared.
    func testCollectionViewModel_hasAnyRowDecorators_flipsTrueAfterFirstCommonRowAdd() {
        let (editor, _) = makeChangerHandlerEditor()
        let vm = makeCollectionViewModel(editor: editor)
        waitForDelegate(editor, fieldID: ChangerHandlerSample.collectionFieldID)
        let rootSK = ChangerHandlerSample.collectionRootSchemaKey
        XCTAssertFalse(vm.tableDataModel.hasAnyRowDecorators(schemaKey: rootSK), "starts with no row decorators")

        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "first")])
        waitForMainQueueToDrain()

        XCTAssertTrue(vm.tableDataModel.hasAnyRowDecorators(schemaKey: rootSK),
                      "schema must be refreshed so hasAnyRowDecorators sees the new row decorator")
        XCTAssertTrue(vm.showRowDecorators(forSchemaKey: rootSK))
    }

    // MARK: - Lazy delegate creation

    func testNoDelegateRegistered_lazilyCreates_noCrash_dataPersisted() {
        let (editor, mock) = makeChangerHandlerEditor()
        // No view model registered for the table field yet.
        XCTAssertNil(editor.delegateMap[ChangerHandlerSample.tableFieldID]?.value)

        editor.addDecorators(path: ChangerHandlerSample.tableCommonRowsPath(),
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
        editor.addDecorators(path: ChangerHandlerSample.collectionRootCommonRowsPath(),
                             decorators: [makeDecorator(action: "collOnly")])
        waitForMainQueueToDrain()

        XCTAssertFalse(tableVM.showRowDecorators,
                       "table view model must be untouched when a different field changes")
    }
}
