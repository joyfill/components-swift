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

        let documentEditor = DocumentEditor(
            document: document,
            config: DocumentEditorConfig(
                mode: mode,
                validateSchema: false,
                display: DisplayConfig(singleClickRowEdit: singleClickRowEdit)
            )
        )
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
        XCTAssertEqual(viewModel.tableDataModel.editModeForGrid(forSchemaKey: rootSchemaKey), .readonly)
        XCTAssertEqual(viewModel.tableDataModel.editModeForGrid(forSchemaKey: childSchemaKey), .fill)
    }

    func testGridEditModeIsFillWhenEditabilityAbsent() {
        let viewModel = makeViewModel(editability: [:])
        XCTAssertEqual(viewModel.tableDataModel.editModeForGrid(forSchemaKey: rootSchemaKey), .fill)
    }

    func testReadonlyDocumentModeOverridesSchemaInlineEditability() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["inline"]], mode: .readonly)
        XCTAssertEqual(viewModel.tableDataModel.editModeForGrid(forSchemaKey: rootSchemaKey), .readonly)
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

    // MARK: - Edit icon

    func testEditIconShownWhenEditabilityAbsent() {
        let viewModel = makeViewModel(editability: [:])
        XCTAssertTrue(viewModel.tableDataModel.canShowSingleClickEditColumn(forSchemaKey: rootSchemaKey))
    }

    func testEditColumnIsReservedPerSchemaNotPerField() {
        let viewModel = makeViewModel(editability: [rootSchemaKey: ["inline"]])
        XCTAssertFalse(viewModel.tableDataModel.canShowSingleClickEditColumn(forSchemaKey: rootSchemaKey),
                       "An inline-only schema must not reserve the gutter just because a sibling schema allows the form")
        XCTAssertTrue(viewModel.tableDataModel.canShowSingleClickEditColumn(forSchemaKey: childSchemaKey))
    }

    func testEditIconHiddenWhenNoSchemaAllowsForm() {
        let keys = allSchemaKeys
        XCTAssertFalse(keys.isEmpty, "Fixture has no schemas, so the assertion below would be vacuous")
        let inlineOnlyEverywhere = Dictionary(uniqueKeysWithValues: keys.map { ($0, Optional(["inline"])) })
        let viewModel = makeViewModel(editability: inlineOnlyEverywhere)
        keys.forEach { key in
            XCTAssertFalse(viewModel.tableDataModel.canShowSingleClickEditColumn(forSchemaKey: key))
        }
    }

    func testEditIconStaysHiddenWhenHostDisablesSingleClickRowEdit() {
        let viewModel = makeViewModel(editability: [:], singleClickRowEdit: false)
        XCTAssertFalse(viewModel.tableDataModel.canShowSingleClickEditColumn(forSchemaKey: rootSchemaKey))
    }

    // MARK: - Gutter width

    private func rowWidth(_ viewModel: CollectionViewModel, schemaKey: String) -> CGFloat {
        let columns = viewModel.tableDataModel.filterTableColumns(key: schemaKey)
        XCTAssertFalse(columns.isEmpty, "Schema \(schemaKey) has no columns, so the width would be vacuous")
        return viewModel.rowWidth(columns, 1, schemaKey, tableDataModel: viewModel.tableDataModel)
    }

    func testRowWidthReclaimsTheEditColumnForInlineOnlySchema() {
        let formAllowed = makeViewModel(editability: [childSchemaKey: ["inline", "form"]])
        let inlineOnly = makeViewModel(editability: [childSchemaKey: ["inline"]])
        XCTAssertEqual(rowWidth(formAllowed, schemaKey: childSchemaKey) - rowWidth(inlineOnly, schemaKey: childSchemaKey),
                       40,
                       "An inline-only schema must reclaim exactly the 40pt the edit column occupies")
    }

    func testRowWidthIgnoresSiblingSchemaEditability() {
        let siblingAllowsForm = makeViewModel(editability: [childSchemaKey: ["inline"]])
        let noSchemaAllowsForm = makeViewModel(editability: Dictionary(uniqueKeysWithValues: allSchemaKeys.map { ($0, Optional(["inline"])) }))
        XCTAssertEqual(rowWidth(siblingAllowsForm, schemaKey: childSchemaKey),
                       rowWidth(noSchemaAllowsForm, schemaKey: childSchemaKey),
                       "A sibling schema allowing the form must not widen an inline-only level")
    }

    func testRowWidthDropsTheEditColumnWhenHostDisablesSingleClickRowEdit() {
        let enabled = makeViewModel(editability: [:])
        let disabled = makeViewModel(editability: [:], singleClickRowEdit: false)
        XCTAssertEqual(rowWidth(enabled, schemaKey: rootSchemaKey) - rowWidth(disabled, schemaKey: rootSchemaKey),
                       40,
                       "Turning off single-click row edit must reclaim the edit column's width too")
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
        XCTAssertFalse(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
    }

    func testBulkEditMenuItemShownForInlineOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline"]])
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
    }

    func testSingleRowEditMenuItemShownForFormOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["form"]])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
    }

    func testBulkEditMenuItemHiddenForFormOnlySchema() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["form"]])
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertFalse(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
    }

    func testMenuItemShownForBothSurfacesRegardlessOfSelectionSize() {
        let viewModel = makeLoadedViewModel(editability: [rootSchemaKey: ["inline", "form"]])
        viewModel.tableDataModel.selectedRows = [rootRowIDs(viewModel)[0]]
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
        viewModel.tableDataModel.selectedRows = Array(rootRowIDs(viewModel).prefix(2))
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem(forSchemaKey: viewModel.selectionSchemaKey))
    }
}
