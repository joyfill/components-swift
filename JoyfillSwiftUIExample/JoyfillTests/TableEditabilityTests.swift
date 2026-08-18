//
//  TableEditabilityTests.swift
//  JoyfillTests
//

import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

final class TableEditabilityTests: XCTestCase {

    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "685750efeb612f4fac5819dd"
    private let tableFieldID = "685750f0489567f18eb8a9ec"

    private func makeViewModel(editability: [String]?,
                               mode: Mode = .fill,
                               singleClickRowEdit: Bool = true) -> TableViewModel {
        var document = sampleJSONDocument(fileName: "ChangerHandlerUnit")
        if let index = document.fields.firstIndex(where: { $0.id == tableFieldID }) {
            document.fields[index].editability = editability
        } else {
            XCTFail("Table field \(tableFieldID) missing from fixture")
        }

        let documentEditor = DocumentEditor(document: document,
                                            mode: mode,
                                            validateSchema: false,
                                            singleClickRowEdit: singleClickRowEdit)
        let field = documentEditor.field(fieldID: tableFieldID)
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
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        ) else {
            fatalError("TableDataModel could not be built")
        }
        return TableViewModel(tableDataModel: tableDataModel)
    }

    // MARK: - Flag resolution

    func testAbsentEditabilityAllowsBothSurfaces() {
        let flags = EditabilityFlags(rawValues: nil)
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testEmptyEditabilityAllowsBothSurfaces() {
        let flags = EditabilityFlags(rawValues: [])
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testInlineAndFormResolvesToBoth() {
        let flags = EditabilityFlags(rawValues: ["inline", "form"])
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testInlineOnlyResolvesToInline() {
        let flags = EditabilityFlags(rawValues: ["inline"])
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertFalse(flags.formAllowed)
    }

    func testFormOnlyResolvesToForm() {
        let flags = EditabilityFlags(rawValues: ["form"])
        XCTAssertFalse(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testUnrecognizedValuesFallBackToDefault() {
        let flags = EditabilityFlags(rawValues: ["sideways"])
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    func testUnrecognizedValueAlongsideKnownValueIsIgnored() {
        let flags = EditabilityFlags(rawValues: ["sideways", "form"])
        XCTAssertFalse(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)
    }

    /// Matching is deliberately case-sensitive, so a wrong-case literal is unrecognized and the
    /// whole array falls back to the permissive default rather than half-matching.
    func testEditabilityMatchingIsCaseSensitive() {
        let flags = EditabilityFlags(rawValues: ["Inline"])
        XCTAssertTrue(flags.inlineAllowed)
        XCTAssertTrue(flags.formAllowed)

        let mixed = EditabilityFlags(rawValues: ["Inline", "form"])
        XCTAssertFalse(mixed.inlineAllowed)
        XCTAssertTrue(mixed.formAllowed)
    }

    /// A table reads editability straight from its field rather than from a snapshot taken at init,
    /// so a host that swaps the field mid-session is reflected without rebuilding the model.
    func testTableEditabilityFollowsFieldDataUpdates() {
        let viewModel = makeViewModel(editability: ["inline"])
        XCTAssertFalse(viewModel.tableDataModel.editability().formAllowed)

        guard var field = viewModel.tableDataModel.documentEditor?.field(fieldID: tableFieldID) else {
            return XCTFail("Table field \(tableFieldID) missing from the document editor")
        }
        field.editability = ["form"]
        viewModel.tableDataModel.documentEditor?.updateField(field: field)

        XCTAssertTrue(viewModel.tableDataModel.editability().formAllowed)
        XCTAssertFalse(viewModel.tableDataModel.editability().inlineAllowed)
    }

    // MARK: - Grid editing

    func testGridIsEditableWhenEditabilityAbsent() {
        XCTAssertEqual(makeViewModel(editability: nil).tableDataModel.editModeForGrid(), .fill)
    }

    func testGridIsEditableForInlineAndForm() {
        XCTAssertEqual(makeViewModel(editability: ["inline", "form"]).tableDataModel.editModeForGrid(), .fill)
    }

    func testGridIsReadonlyForFormOnly() {
        XCTAssertEqual(makeViewModel(editability: ["form"]).tableDataModel.editModeForGrid(), .readonly)
    }

    func testGridIsEditableForInlineOnly() {
        XCTAssertEqual(makeViewModel(editability: ["inline"]).tableDataModel.editModeForGrid(), .fill)
    }

    func testReadonlyDocumentModeOverridesInlineEditability() {
        XCTAssertEqual(makeViewModel(editability: ["inline"], mode: .readonly).tableDataModel.editModeForGrid(), .readonly)
    }

    func testBuiltCellsCarryReadonlyModeForFormOnly() {
        let viewModel = makeViewModel(editability: ["form"])
        let cells = viewModel.tableDataModel.cellModels.flatMap { $0.cells }
        XCTAssertFalse(cells.isEmpty)
        XCTAssertTrue(cells.allSatisfy { $0.editMode == .readonly })
    }

    func testBuiltCellsStayEditableForInlineOnly() {
        let viewModel = makeViewModel(editability: ["inline"])
        let cells = viewModel.tableDataModel.cellModels.flatMap { $0.cells }
        XCTAssertFalse(cells.isEmpty)
        XCTAssertTrue(cells.allSatisfy { $0.editMode == .fill })
    }

    // MARK: - Edit icon

    /// A table has one schema, so the reserved column and the row's icon always agree.
    func testEditIconHiddenForInlineOnly() {
        let tableDataModel = makeViewModel(editability: ["inline"]).tableDataModel
        XCTAssertFalse(tableDataModel.canShowSingleClickEditIcon())
        XCTAssertFalse(tableDataModel.canShowSingleClickEditColumn())
    }

    func testEditIconShownForFormOnly() {
        let tableDataModel = makeViewModel(editability: ["form"]).tableDataModel
        XCTAssertTrue(tableDataModel.canShowSingleClickEditIcon())
        XCTAssertTrue(tableDataModel.canShowSingleClickEditColumn())
    }

    func testEditIconShownWhenEditabilityAbsent() {
        XCTAssertTrue(makeViewModel(editability: nil).tableDataModel.canShowSingleClickEditIcon())
    }

    func testEditIconStaysHiddenWhenHostDisablesSingleClickRowEdit() {
        let tableDataModel = makeViewModel(editability: ["inline", "form"], singleClickRowEdit: false).tableDataModel
        XCTAssertFalse(tableDataModel.canShowSingleClickEditIcon())
        XCTAssertFalse(tableDataModel.canShowSingleClickEditColumn())
    }

    // MARK: - Bulk edit and row form menu item

    func testSingleRowEditMenuItemHiddenForInlineOnly() {
        let viewModel = makeViewModel(editability: ["inline"])
        viewModel.tableDataModel.selectedRows = [viewModel.tableDataModel.rowOrder[0]]
        XCTAssertFalse(viewModel.tableDataModel.canShowEditRowsMenuItem())
    }

    func testBulkEditMenuItemShownForInlineOnly() {
        let viewModel = makeViewModel(editability: ["inline"])
        viewModel.tableDataModel.selectedRows = Array(viewModel.tableDataModel.rowOrder.prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem())
    }

    func testSingleRowEditMenuItemShownForFormOnly() {
        let viewModel = makeViewModel(editability: ["form"])
        viewModel.tableDataModel.selectedRows = [viewModel.tableDataModel.rowOrder[0]]
        XCTAssertTrue(viewModel.tableDataModel.canShowEditRowsMenuItem())
    }

    func testBulkEditMenuItemHiddenForFormOnly() {
        let viewModel = makeViewModel(editability: ["form"])
        viewModel.tableDataModel.selectedRows = Array(viewModel.tableDataModel.rowOrder.prefix(2))
        XCTAssertEqual(viewModel.tableDataModel.selectedRows.count, 2)
        XCTAssertFalse(viewModel.tableDataModel.canShowEditRowsMenuItem())
    }
}
