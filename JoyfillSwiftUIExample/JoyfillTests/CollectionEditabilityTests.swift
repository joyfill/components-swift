//
//  CollectionEditabilityTests.swift
//  JoyfillTests
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class CollectionEditabilityTests: XCTestCase {

    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "685750efeb612f4fac5819dd"
    private let collectionFieldID = "6857510fbfed1553e168161b"
    private let rootSchemaKey = "collectionSchemaId"
    private let childSchemaKey = "685753949107b403e2e4a949"

    /// Read from the fixture so a schema added later is covered automatically instead of
    /// silently keeping the default flags.
    private var allSchemaKeys: [String] {
        let document = sampleJSONDocument(fileName: "ChangerHandlerUnit")
        guard let field = document.fields.first(where: { $0.id == collectionFieldID }) else {
            fatalError("Collection field \(collectionFieldID) missing from fixture")
        }
        return Array((field.schema ?? [:]).keys)
    }

    private func makeViewModel(editability: [String: [String]?],
                               mode: Mode = .fill,
                               singleClickRowEdit: Bool = true) -> CollectionViewModel {
        var document = sampleJSONDocument(fileName: "ChangerHandlerUnit")
        guard let index = document.fields.firstIndex(where: { $0.id == collectionFieldID }) else {
            fatalError("Collection field \(collectionFieldID) missing from fixture")
        }
        var schema = document.fields[index].schema ?? [:]
        for (key, values) in editability {
            guard var schemaValue = schema[key] else {
                fatalError("Schema \(key) missing from fixture")
            }
            schemaValue.editability = values
            schema[key] = schemaValue
        }
        document.fields[index].schema = schema

        let documentEditor = DocumentEditor(document: document,
                                            mode: mode,
                                            validateSchema: false,
                                            singleClickRowEdit: singleClickRowEdit)
        let field = documentEditor.field(fieldID: collectionFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title,
                                                required: field?.required,
                                                tipDescription: field?.tipDescription,
                                                tipTitle: field?.tipTitle,
                                                tipVisible: field?.tipVisible,
                                                visibleLimitInFields: documentEditor.decoratorConfig.visibleLimitInFields)
        guard let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: mode,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID)
        ) else {
            fatalError("TableDataModel could not be built")
        }
        return CollectionViewModel(tableDataModel: tableDataModel)
    }

    /// Root rows are built on a background queue, so wait for the load to land on the main queue.
    private func makeLoadedViewModel(editability: [String: [String]?],
                                     mode: Mode = .fill,
                                     singleClickRowEdit: Bool = true,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) -> CollectionViewModel {
        let viewModel = makeViewModel(editability: editability, mode: mode, singleClickRowEdit: singleClickRowEdit)
        let deadline = Date().addingTimeInterval(10)
        while viewModel.isLoading && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        XCTAssertFalse(viewModel.isLoading, "Collection never finished loading", file: file, line: line)
        XCTAssertFalse(viewModel.tableDataModel.filteredcellModels.isEmpty, "No rows were built", file: file, line: line)
        return viewModel
    }

    private func rootRowIDs(_ viewModel: CollectionViewModel) -> [String] {
        viewModel.tableDataModel.filteredcellModels
            .filter { $0.rowType.isRow }
            .map { $0.rowID }
    }

    // MARK: - Per-schema flag resolution

    func testAbsentEditabilityAllowsBothSurfacesForEverySchema() {
        let viewModel = makeViewModel(editability: [:])
        for key in viewModel.tableDataModel.schema.keys {
            let flags = viewModel.tableDataModel.editability(forSchemaKey: key)
            XCTAssertTrue(flags.inlineAllowed, "\(key) should allow inline")
            XCTAssertTrue(flags.formAllowed, "\(key) should allow form")
        }
    }

    func testEachSchemaResolvesItsOwnFlags() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["form"],
                                                   childSchemaKey: ["inline"]])
        let root = viewModel.tableDataModel.editability(forSchemaKey: rootSchemaKey)
        XCTAssertFalse(root.inlineAllowed)
        XCTAssertTrue(root.formAllowed)

        let child = viewModel.tableDataModel.editability(forSchemaKey: childSchemaKey)
        XCTAssertTrue(child.inlineAllowed)
        XCTAssertFalse(child.formAllowed)
    }

    func testUntouchedSiblingSchemasKeepBothSurfaces() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["form"]])
        let sibling = viewModel.tableDataModel.editability(forSchemaKey: childSchemaKey)
        XCTAssertTrue(sibling.inlineAllowed)
        XCTAssertTrue(sibling.formAllowed)
    }

    func testEmptyEditabilityAllowsBothSurfaces() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: []])
        let flags = viewModel.tableDataModel.editability(forSchemaKey: rootSchemaKey)
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testUnknownSchemaKeyFallsBackToDefault() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["form"]])
        let flags = viewModel.tableDataModel.editability(forSchemaKey: "notASchema")
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    // MARK: - Grid edit mode

    func testGridEditModeIsPerSchema() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["form"],
                                                   childSchemaKey: ["inline"]])
        XCTAssertEqual(viewModel.gridEditMode(for: viewModel.tableDataModel, schemaKey: rootSchemaKey), .readonly)
        XCTAssertEqual(viewModel.gridEditMode(for: viewModel.tableDataModel, schemaKey: childSchemaKey), .fill)
    }

    func testGridEditModeIsFillWhenEditabilityAbsent() {
        let viewModel = makeViewModel(editability: [:])
        XCTAssertEqual(viewModel.gridEditMode(for: viewModel.tableDataModel, schemaKey: rootSchemaKey), .fill)
    }

    func testReadonlyDocumentModeOverridesSchemaInlineEditability() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["inline"]], mode: .readonly)
        XCTAssertEqual(viewModel.gridEditMode(for: viewModel.tableDataModel, schemaKey: rootSchemaKey), .readonly)
    }

    func testBuiltRootCellsCarryReadonlyModeForFormOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["form"]])
        let cells = viewModel.tableDataModel.filteredcellModels.flatMap { $0.cells }
        XCTAssertFalse(cells.isEmpty)
        XCTAssertTrue(cells.allSatisfy { $0.editMode == .readonly })
    }

    func testBuiltRootCellsStayEditableForInlineOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline"]])
        let cells = viewModel.tableDataModel.filteredcellModels.flatMap { $0.cells }
        XCTAssertFalse(cells.isEmpty)
        XCTAssertTrue(cells.allSatisfy { $0.editMode == .fill })
    }

    func testNestedCellsFollowTheirOwnSchemaNotTheRoot() async {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline"],
                                                         childSchemaKey: ["form"]])
        await viewModel.setupAllCellModels(targetSchema: childSchemaKey)

        let rootCells = viewModel.tableDataModel.filteredcellModels
            .filter { $0.rowType.isRow }
            .flatMap { $0.cells }
        XCTAssertFalse(rootCells.isEmpty)
        XCTAssertTrue(rootCells.allSatisfy { $0.editMode == .fill }, "Root schema is inline, so root cells stay editable")

        let nestedCells = viewModel.tableDataModel.filteredcellModels
            .filter { $0.rowType.parentSchemaKey == childSchemaKey }
            .flatMap { $0.cells }
        XCTAssertFalse(nestedCells.isEmpty, "Expected nested rows for schema \(childSchemaKey)")
        XCTAssertTrue(nestedCells.allSatisfy { $0.editMode == .readonly }, "Nested schema is form-only, so its cells are readonly")
    }

    // MARK: - Edit icon slot

    func testEditIconSlotReservedWhenEditabilityAbsent() {
        let viewModel = makeViewModel(editability: [:])
        XCTAssertTrue(viewModel.showSingleClickEditButton(for: viewModel.tableDataModel))
    }

    func testEditIconSlotReservedWhenOnlyOneSchemaAllowsForm() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["inline"]])
        XCTAssertTrue(viewModel.showSingleClickEditButton(for: viewModel.tableDataModel),
                      "Nested schemas still allow the form, so the gutter keeps its width")
    }

    func testEditIconSlotDroppedWhenNoSchemaAllowsForm() {
        let keys = allSchemaKeys
        XCTAssertFalse(keys.isEmpty, "Fixture has no schemas, so the assertion below would be vacuous")
        let inlineOnlyEverywhere = Dictionary(uniqueKeysWithValues: keys.map { ($0, Optional(["inline"])) })
        let viewModel = makeViewModel(editability: inlineOnlyEverywhere)
        XCTAssertFalse(viewModel.showSingleClickEditButton(for: viewModel.tableDataModel))
    }

    func testEditIconSlotStaysHiddenWhenHostDisablesSingleClickRowEdit() {
        let viewModel = makeViewModel(editability: [:], singleClickRowEdit: false)
        XCTAssertFalse(viewModel.showSingleClickEditButton(for: viewModel.tableDataModel))
    }

    // MARK: - Row form route

    func testCanOpenRowFormIsPerSchema() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["inline"],
                                                   childSchemaKey: ["form"]])
        XCTAssertFalse(viewModel.canOpenRowForm(forSchemaKey: rootSchemaKey))
        XCTAssertTrue(viewModel.canOpenRowForm(forSchemaKey: childSchemaKey))
    }

    func testCanOpenRowFormAllowedWhenEditabilityAbsent() {
        let viewModel = makeViewModel(editability: [:])
        XCTAssertTrue(viewModel.canOpenRowForm(forSchemaKey: rootSchemaKey))
    }

    // MARK: - Selection schema and popover gating

    func testSelectionSchemaKeyDefaultsToRootWhenNothingSelected() {
        let viewModel = makeLoadedViewModel(editability: [:])
        XCTAssertTrue(viewModel.tableDataModel.selectedRows.isEmpty)
        XCTAssertEqual(viewModel.selectionSchemaKey, rootSchemaKey)
    }

    func testSelectionSchemaKeyResolvesRootRowsToRootSchema() {
        let viewModel = makeLoadedViewModel(editability: [:])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertEqual(viewModel.selectionSchemaKey, rootSchemaKey)
    }

    func testSingleRowEditMenuItemHiddenForInlineOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline"]])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertFalse(viewModel.showEditRowsMenuItem)
    }

    func testBulkEditMenuItemShownForInlineOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline"]])
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertTrue(viewModel.showEditRowsMenuItem)
    }

    func testSingleRowEditMenuItemShownForFormOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["form"]])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertTrue(viewModel.showEditRowsMenuItem)
    }

    func testBulkEditMenuItemHiddenForFormOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["form"]])
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertFalse(viewModel.showEditRowsMenuItem)
    }

    func testMenuItemShownForBothSurfacesRegardlessOfSelectionSize() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline", "form"]])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertTrue(viewModel.showEditRowsMenuItem)
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertTrue(viewModel.showEditRowsMenuItem)
    }
}
