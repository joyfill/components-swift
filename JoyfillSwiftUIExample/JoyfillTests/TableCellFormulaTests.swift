import XCTest
import Foundation
import JoyfillModel
@testable import Joyfill

/// Excel-style formulas in table cells: what counts as a formula, how references resolve,
/// what ends up in the context's result map, and what the document is left holding.
final class TableCellFormulaTests: XCTestCase {

    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    let tableFieldID = "table_formula_001"
    let documentID = "685750eff3216b45ffe73c80"
    let fieldPositionID = "6857510f4313cfbfb43c516c"

    // Positional letters follow column order: A=Qty, B=Price, C=Total, D=Double, E=Notes.
    let qtyID    = "col_qty"
    let priceID  = "col_price"
    let totalID  = "col_total"
    let doubleID = "col_double"
    let notesID  = "col_notes"

    // MARK: - Builders

    private func column(id: String,
                        type: ColumnTypes,
                        title: String,
                        identifier: String? = nil,
                        formula: String? = nil) -> FieldTableColumn {
        var dict: [String: Any] = [
            "_id": id,
            "type": type.rawValue,
            "title": title,
            "width": 0,
            "identifier": identifier ?? "field_column_\(id)"
        ]
        if let formula = formula { dict["value"] = formula }
        return FieldTableColumn(dictionary: dict)
    }

    private func row(_ id: String, _ cells: [String: Any]) -> ValueElement {
        ValueElement(dictionary: ["_id": id, "cells": cells])
    }

    private func document(columns: [FieldTableColumn], rows: [ValueElement]) -> JoyDoc {
        var field = JoyDocField()
        field.type = "table"
        field.id = tableFieldID
        field.identifier = "field_\(tableFieldID)"
        field.title = "Formula Table"
        field.file = fileID
        field.tableColumns = columns
        field.tableColumnOrder = columns.compactMap { $0.id }
        field.rowOrder = rows.compactMap { $0.id }
        field.value = .valueElementArray(rows)

        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(field)
        return document.setFieldPositionToPage(pageId: pageID, idAndTypes: [tableFieldID: .table])
    }

    /// The standard fixture: Total = A*B on the column, Double = C*2 so it reads another
    /// formula column, and Notes carries no formula at all.
    private func standardColumns(totalFormula: String = "=A*B") -> [FieldTableColumn] {
        [column(id: qtyID,    type: .number, title: "Qty"),
         column(id: priceID,  type: .number, title: "Price"),
         column(id: totalID,  type: .text,   title: "Total",  formula: totalFormula),
         column(id: doubleID, type: .text,   title: "Double", formula: "=C*2"),
         column(id: notesID,  type: .text,   title: "Notes")]
    }

    /// Builds the view model, which is what primes the result map as it builds its cells.
    private func viewModel(_ document: JoyDoc) -> TableViewModel {
        let editor = DocumentEditor(document: document, validateSchema: false)
        let field = editor.field(fieldID: tableFieldID)
        let header = FieldHeaderModel(title: field?.title, required: field?.required,
                                      tipDescription: field?.tipDescription, tipTitle: field?.tipTitle,
                                      tipVisible: field?.tipVisible,
                                      visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let model = TableDataModel(fieldHeaderModel: header, mode: .fill, documentEditor: editor,
                                   fieldIdentifier: FieldIdentifier(fieldID: tableFieldID,
                                                                    pageID: pageID, fileID: fileID))!
        return TableViewModel(tableDataModel: model)
    }

    private func standardViewModel(totalFormula: String = "=A*B",
                                   rows: [ValueElement]? = nil) -> TableViewModel {
        viewModel(document(columns: standardColumns(totalFormula: totalFormula),
                           rows: rows ?? [row("row_1", [qtyID: 2, priceID: 3]),
                                          row("row_2", [qtyID: 5, priceID: 4])]))
    }

    private func result(_ vm: TableViewModel, _ rowID: String, _ columnID: String) -> String? {
        vm.formulaValue(columnID: columnID, rowID: rowID)?.text
    }

    // MARK: - Column formulas

    func testColumnFormulaEvaluatesPerRow() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6",  "2 * 3")
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "5 * 4")
    }

    func testLetterReferencesAreCaseInsensitive() {
        let vm = standardViewModel(totalFormula: "=a*b")
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "=a*b is the same formula as =A*B")
    }

    func testFormulaReadingAnotherFormulaColumnFollowsTheChain() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", doubleID), "12", "C is 6, so C*2 is 12")
        XCTAssertEqual(result(vm, "row_2", doubleID), "40")
    }

    func testColumnCanBeReferencedByItsIdentifier() {
        let vm = standardViewModel(totalFormula: "=field_column_col_qty * field_column_col_price")
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Identifier resolves before the letter")
    }


    /// References resolve by identifier, title, then letter. A column id is not a tier:
    /// real ids are ObjectIds, which the shared lexer cannot begin an identifier with, and
    /// teaching it to would be a change to JoyfillFormulas rather than a rewrite here.
    func testAColumnIDIsNotAReference() {
        let qty = "6aa0ea5666f683e02ea449b5"
        let columns = [column(id: qty, type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: totalID, type: .text, title: "Total", formula: "=\(qty)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qty: 2, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
    }

    func testColumnCanBeReferencedByItsTitle() {
        let vm = standardViewModel(totalFormula: "=Qty * Price")
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Title resolves when no id or identifier matches")
    }

    func testTitleIsMatchedCaseInsensitively() {
        let vm = standardViewModel(totalFormula: "=qty * pRiCe")
        XCTAssertEqual(result(vm, "row_1", totalID), "6")
    }

    // MARK: - Resolution priority: id, then name, then letter

    func testATitleIsNotShadowedByAnotherColumnsID() {
        // The first column's id is the second column's title. Ids are not references, so
        // `=qty` is the column *titled* qty and nothing is ambiguous.
        let columns = [column(id: "qty", type: .number, title: "Price"),
                       column(id: "price", type: .number, title: "qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=qty")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", ["qty": 7, "price": 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "99", "The column titled `qty`")
    }

    func testColumnNameBeatsAPositionalLetter() {
        // The second column is titled "A", which is also the first column's letter.
        let columns = [column(id: qtyID, type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "A"),
                       column(id: totalID, type: .text, title: "Total", formula: "=A")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 7, priceID: 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "99", "The column named A, not the column at position A")
    }

    func testAnIdentifierBeatsAnotherColumnsTitle() {
        // Identifiers and titles share one lookup, but every identifier is claimed before
        // any title is, so the second column's title loses to the first's identifier.
        let columns = [column(id: qtyID, type: .number, title: "Alpha", identifier: "shared"),
                       column(id: priceID, type: .number, title: "shared", identifier: "i_price"),
                       column(id: totalID, type: .text, title: "Total", formula: "=shared")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 7, priceID: 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "7", "The column whose identifier is `shared`")
    }

    func testDuplicateIdentifiersResolveToTheLeftmostColumn() {
        let columns = [column(id: qtyID, type: .number, title: "Qty", identifier: "dup"),
                       column(id: priceID, type: .number, title: "Price", identifier: "dup"),
                       column(id: totalID, type: .text, title: "Total", formula: "=dup")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 7, priceID: 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "7")
    }

    func testDuplicateTitlesResolveToTheLeftmostColumn() {
        let columns = [column(id: qtyID, type: .number, title: "Dup"),
                       column(id: priceID, type: .number, title: "Dup"),
                       column(id: totalID, type: .text, title: "Total", formula: "=Dup")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 7, priceID: 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "7", "A duplicated title never re-points an existing formula")
    }

    func testLettersContinuePastZ() {
        // 27 number columns, so the 27th is AA, then a text column carrying the formula.
        var columns = (0..<27).map { column(id: "c\($0)", type: .number, title: "C\($0)") }
        columns.append(column(id: totalID, type: .text, title: "Total", formula: "=AA"))
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["c26": 42])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "42", "Bijective base-26: index 26 is AA")
    }

    // MARK: - A cell formula resolves references the same way

    func testCellFormulaCanUseIdentifiersAndTitles() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3,
                                                        notesID: "=field_column_col_qty + Price"])])
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "One by identifier, one by title, in a cell formula")
    }

    func testBlankCellsReadAsZeroRatherThanFailing() {
        let vm = standardViewModel(rows: [row("row_1", [:])])
        XCTAssertEqual(result(vm, "row_1", totalID), "0", "Two blank numbers multiply to 0, not an error")
    }

    // MARK: - What counts as a formula

    func testColumnWithoutAFormulaHasNoResult() {
        let vm = standardViewModel()
        XCTAssertNil(result(vm, "row_1", notesID), "Plain text column is never computed")
    }

    func testNonFormulaCapableColumnIsNeverStored() {
        let vm = standardViewModel()
        XCTAssertNil(result(vm, "row_1", qtyID), "A number column holds data, not a formula")
    }

    func testCellFormulaOverridesTheColumnFormula() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "=A+B"])])
        XCTAssertEqual(result(vm, "row_1", totalID), "5", "The cell's own formula wins over =A*B")
    }

    func testLiteralCellValueOverridesTheColumnFormula() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "typed"])])
        XCTAssertNil(result(vm, "row_1", totalID), "A cell holding data is a literal, never computed")
    }

    func testLeadingWhitespaceAndSpacedEqualsStillParse() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "  =  A + B "])])
        XCTAssertEqual(result(vm, "row_1", totalID), "5")
    }

    func testBareEqualsIsNotAFormula() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "="])])
        XCTAssertNil(result(vm, "row_1", totalID), "An empty body is not a formula, so the cell is a literal")
    }

    // MARK: - Failure

    func testSyntaxErrorSurfacesAsError() {
        let vm = standardViewModel(totalFormula: "=A *")
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
        XCTAssertEqual(vm.formulaValue(columnID: totalID, rowID: "row_1")?.isError, true)
    }

    func testCircularReferenceSurfacesAsErrorRatherThanHanging() {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: totalID, type: .text,   title: "Total",  formula: "=D"),
                       column(id: doubleID, type: .text,  title: "Double", formula: "=B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 1])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error", "B and D reference each other")
    }

    // MARK: - Invalid formulas

    func testUnbalancedParenthesisIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=(A+B"), "row_1", totalID), "Error")
    }

    func testTrailingOperatorIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=A +"), "row_1", totalID), "Error")
    }

    func testUnknownFunctionIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=NOTAFUNCTION(1)"), "row_1", totalID), "Error")
    }

    func testReferenceToSomethingThatIsNeitherColumnNorFieldIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=ZZZ"), "row_1", totalID), "Error")
    }

    func testDivisionByZeroIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=A/0"), "row_1", totalID), "Error")
    }

    func testFunctionGivenTheWrongTypeIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=UPPER(A)"), "row_1", totalID), "Error",
                       "UPPER of a number column, not a string")
    }

    func testAColumnReferencingItselfIsAnError() {
        // C is Total, so this formula reads the cell it is computing.
        XCTAssertEqual(result(standardViewModel(totalFormula: "=C"), "row_1", totalID), "Error")
    }

    func testAnErrorPropagatesToColumnsThatReadIt() {
        let vm = standardViewModel(totalFormula: "=A/0")
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
        XCTAssertEqual(result(vm, "row_1", doubleID), "Error",
                       "Double reads Total, so the failure carries rather than reading as zero")
    }

    func testAnInvalidCellFormulaErrorsWithoutAffectingItsNeighbours() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, notesID: "=A +"]),
                                          row("row_2", [qtyID: 5, priceID: 4])])
        XCTAssertEqual(result(vm, "row_1", notesID), "Error")
        XCTAssertEqual(result(vm, "row_1", totalID), "6",  "the other columns of the same row still compute")
        XCTAssertEqual(result(vm, "row_2", notesID), nil,  "and other rows are unaffected")
    }

    func testFixingAnInvalidFormulaClearsTheError() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, notesID: "=A +"])])
        XCTAssertEqual(result(vm, "row_1", notesID), "Error")
        applyChange(vm, rowID: "row_1", cells: [notesID: "=A+B"])
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "The error must not stick")
    }

    /// `+` concatenates when either side is a string, so this is a value, not a failure.
    /// Pinned so a change to that operator is a deliberate one.
    func testNumberPlusStringConcatenatesRatherThanFailing() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=A + \"text\""), "row_1", totalID), "2text")
    }

    // MARK: - Refresh on change

    /// Edits a cell the way anything outside the view does: through the change API.
    private func applyChange(_ vm: TableViewModel, rowID: String, cells: [String: Any]) {
        vm.tableDataModel.documentEditor?.change(changes: [externalRowUpdate(rowID: rowID, cells: cells)])
        settle()
    }

    func testEditingASourceColumnRefreshesDependentsAndTheirChain() {
        let vm = standardViewModel()
        applyChange(vm, rowID: "row_1", cells: [qtyID: 10])
        XCTAssertEqual(result(vm, "row_1", totalID), "30", "10 * 3")
        XCTAssertEqual(result(vm, "row_1", doubleID), "60", "The chain through Total follows")
    }

    /// Types into a cell the way the grid does, bypassing the row rebuild that the
    /// change API performs.
    private func editCell(_ vm: TableViewModel, rowID: String, colIndex: Int,
                          _ mutate: (inout CellDataModel) -> Void) {
        var cell = vm.tableDataModel.filteredcellModels
            .first(where: { $0.rowID == rowID })!
            .cells[colIndex]
            .data
        mutate(&cell)
        vm.tableDataModel.valueToValueElements = vm.cellDidChange(
            rowId: rowID, colIndex: colIndex, cellDataModel: cell,
            isNestedCell: false, callOnChange: false)
    }

    /// The chain can leave the column definitions and come back: a column formula reading
    /// a column whose *cell* holds the formula is invisible to a map built from columns
    /// alone, so the refresh set has to close over the cells it picked up.
    func testAColumnFormulaReadingACellFormulaFollowsTheChain() {
        // A=Qty, B=Price, C=Notes (no column formula, the cell carries one), D=Echo.
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: notesID, type: .text,   title: "Notes"),
                       column(id: totalID, type: .text,   title: "Echo", formula: "=C*2")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 2, priceID: 3, notesID: "=A+B"])]))
        XCTAssertEqual(result(vm, "row_1", notesID), "5",  "The cell formula, 2 + 3")
        XCTAssertEqual(result(vm, "row_1", totalID), "10", "Echo reads it, 5 * 2")

        editCell(vm, rowID: "row_1", colIndex: 0) { $0.number = 10 }

        XCTAssertEqual(result(vm, "row_1", notesID), "13", "10 + 3")
        XCTAssertEqual(result(vm, "row_1", totalID), "26", "Echo follows through the cell formula")
    }

    func testClearingTheOnlyCellFormulaInAFormulaFreeTableDropsItsResult() {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: notesID, type: .text,   title: "Notes")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 2, priceID: 3, notesID: "=A+B"])]))
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "The cell formula computes")

        editCell(vm, rowID: "row_1", colIndex: 2) { $0.title = "plain" }

        XCTAssertNil(result(vm, "row_1", notesID), "The stale result must not survive")
    }

    func testTypingACellFormulaIntoAFormulaFreeTableStartsComputingIt() {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: notesID, type: .text,   title: "Notes")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertNil(result(vm, "row_1", notesID))

        editCell(vm, rowID: "row_1", colIndex: 2) { $0.title = "=A+B" }

        XCTAssertEqual(result(vm, "row_1", notesID), "5", "Nothing declared a formula before this")
    }

    func testBulkEditingAFormulaIntoAFormulaFreeTableComputesEveryRow() async {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: notesID, type: .text,   title: "Notes")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 2, priceID: 3]),
                                           row("row_2", [qtyID: 5, priceID: 4])]))
        XCTAssertNil(result(vm, "row_1", notesID))
        XCTAssertNil(result(vm, "row_2", notesID))

        vm.tableDataModel.selectedRows = ["row_1", "row_2"]
        await vm.bulkEdit(changes: [notesID: ValueUnion.string("=A+B")])

        XCTAssertEqual(result(vm, "row_1", notesID), "5",  "2 + 3")
        XCTAssertEqual(result(vm, "row_2", notesID), "9",  "5 + 4, per row")
    }

    func testBulkClearingAFormulaDropsEveryRowsResult() async {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: notesID, type: .text,   title: "Notes")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", [qtyID: 2, priceID: 3, notesID: "=A+B"]),
                                           row("row_2", [qtyID: 5, priceID: 4, notesID: "=A+B"])]))
        XCTAssertEqual(result(vm, "row_1", notesID), "5")
        XCTAssertEqual(result(vm, "row_2", notesID), "9")

        vm.tableDataModel.selectedRows = ["row_1", "row_2"]
        await vm.bulkEdit(changes: [notesID: ValueUnion.string("plain")])

        XCTAssertNil(result(vm, "row_1", notesID), "No stale result may survive")
        XCTAssertNil(result(vm, "row_2", notesID))
    }

    func testFractionalResultsDropTheBinaryFloatTail() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=1.1*3"), "row_1", totalID), "3.3")
        XCTAssertEqual(result(standardViewModel(totalFormula: "=0.1+0.2"), "row_1", totalID), "0.3")
    }

    func testFractionalResultsKeepDigitsThatAreReal() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=A*B"),
                              "row_1", totalID), "6", "whole numbers are unchanged")
        XCTAssertEqual(result(standardViewModel(totalFormula: "=5/2"), "row_1", totalID), "2.5")
        XCTAssertEqual(result(standardViewModel(totalFormula: "=1234.5678*1"), "row_1", totalID), "1234.5678")
    }

    func testABarcodeColumnDoesNotCarryAFormula() {
        let columns = [column(id: qtyID,   type: .number,  title: "Qty"),
                       column(id: priceID, type: .number,  title: "Price"),
                       column(id: totalID, type: .barcode, title: "Total", formula: "=A*B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertNil(result(vm, "row_1", totalID), "Formulas are text columns only for now")
    }

    /// The cell carries its column's formula, which is what the editor shows on tap so a
    /// column formula reads and edits like one typed into the cell.
    func testTheCellCarriesItsColumnFormula() {
        let vm = standardViewModel()
        let cells = vm.tableDataModel.filteredcellModels.first(where: { $0.rowID == "row_1" })!.cells
        XCTAssertEqual(cells.first(where: { $0.data.id == totalID })?.data.columnFormula, "=A*B")
        XCTAssertNil(cells.first(where: { $0.data.id == notesID })?.data.columnFormula,
                     "Notes declares no formula")
    }

    func testEditingOneRowLeavesOtherRowsAlone() {
        let vm = standardViewModel()
        applyChange(vm, rowID: "row_1", cells: [qtyID: 10])
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "References are same-row")
    }

    func testTypingAFormulaIntoACellStartsComputingIt() {
        let vm = standardViewModel()
        XCTAssertNil(result(vm, "row_1", notesID))
        applyChange(vm, rowID: "row_1", cells: [notesID: "=A+B"])
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "A cell formula needs no column formula")
    }

    func testClearingACellHandsTheRowBackToItsColumnFormula() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "typed"])])
        XCTAssertNil(result(vm, "row_1", totalID), "Starts as a literal")
        applyChange(vm, rowID: "row_1", cells: [totalID: ""])
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Emptying the cell restores =A*B")
    }

    func testReplacingACellFormulaWithALiteralClearsTheResult() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "=A+B"])])
        XCTAssertEqual(result(vm, "row_1", totalID), "5")
        applyChange(vm, rowID: "row_1", cells: [totalID: "plain"])
        XCTAssertNil(result(vm, "row_1", totalID), "The stale result must not survive")
    }

    // MARK: - External changes (the change API)

    /// The envelope every change carries, matching what the SDK actually sends.
    private func change(target: String, payload: [String: Any]) -> Change {
        Change(dictionary: [
            "v": 1,
            "sdk": "swift",
            "_id": documentID,
            "identifier": "doc_\(documentID)",
            "target": target,
            "fileId": fileID,
            "pageId": pageID,
            "fieldId": tableFieldID,
            "fieldIdentifier": "field_\(tableFieldID)",
            "fieldPositionId": fieldPositionID,
            "change": payload,
            "createdOn": Date().timeIntervalSince1970
        ])
    }

    private func externalRowUpdate(rowID: String, cells: [String: Any]) -> Change {
        change(target: "field.value.rowUpdate",
               payload: ["rowId": rowID, "row": ["_id": rowID, "cells": cells] as [String: Any]])
    }

    private func externalRowCreate(rowID: String, cells: [String: Any], at index: Int) -> Change {
        change(target: "field.value.rowCreate",
               payload: ["rowId": rowID, "targetRowIndex": index,
                         "row": ["_id": rowID, "cells": cells] as [String: Any]])
    }

    /// Waits for work the SDK deferred with `DispatchQueue.main.async`.
    ///
    /// The main queue is FIFO, so a block enqueued now can only run once that work has.
    /// Spinning the run loop directly is not enough: `RunLoop.run(mode:before:)` returns
    /// immediately when nothing is attached to the loop, so these waits only worked when
    /// an earlier test happened to leave something on it — and the tests failed when run
    /// on their own.
    private func settle() {
        let drained = expectation(description: "deferred main-queue work ran")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
    }

    func testExternalCellChangeRefreshesTheRowsFormulas() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Before the change")

        vm.tableDataModel.documentEditor?.change(changes: [externalRowUpdate(rowID: "row_1", cells: [qtyID: 10])])
        settle()

        XCTAssertEqual(result(vm, "row_1", totalID), "30", "10 * 3 after the external change")
        XCTAssertEqual(result(vm, "row_1", doubleID), "60", "and the chain through Total follows")
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "other rows untouched")
    }

    func testExternalCellChangeCanIntroduceACellFormula() {
        let vm = standardViewModel()
        XCTAssertNil(result(vm, "row_1", notesID))

        vm.tableDataModel.documentEditor?.change(changes: [externalRowUpdate(rowID: "row_1", cells: [notesID: "=A+B"])])
        settle()

        XCTAssertEqual(result(vm, "row_1", notesID), "5", "A formula arriving from outside is evaluated too")
    }

    func testExternallyAddedRowGetsItsFormulaValues() {
        let vm = standardViewModel()
        vm.tableDataModel.documentEditor?.change(changes: [externalRowCreate(rowID: "row_3", cells: [qtyID: 6, priceID: 7], at: 2)])

        XCTAssertEqual(result(vm, "row_3", totalID), "42", "A new row is primed as its cells are built")
        XCTAssertEqual(result(vm, "row_3", doubleID), "84")
    }

    func testExternallyAddedEmptyRowStillEvaluatesItsColumnFormula() {
        let vm = standardViewModel()
        vm.tableDataModel.documentEditor?.change(changes: [externalRowCreate(rowID: "row_3", cells: [:], at: 2)])
        XCTAssertEqual(result(vm, "row_3", totalID), "0", "Blank cells read as zero")
    }

    func testCheckChangeCheckRepeatedly() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6")

        applyChange(vm, rowID: "row_1", cells: [priceID: 10])
        XCTAssertEqual(result(vm, "row_1", totalID), "20", "2 * 10")

        applyChange(vm, rowID: "row_1", cells: [qtyID: 3])
        XCTAssertEqual(result(vm, "row_1", totalID), "30", "3 * 10")
        XCTAssertEqual(result(vm, "row_1", doubleID), "60", "and the chain each time")
    }

    // MARK: - The document is never written

    func testResultsAreNeverStoredInTheDocument() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6")

        let rows = vm.tableDataModel.documentEditor?.field(fieldID: tableFieldID)?.valueToValueElements
        let cell = rows?.first(where: { $0.id == "row_1" })?.cells?[totalID]
        XCTAssertNil(cell, "A column-driven cell stays null: neither the formula nor the result is written")
    }

    func testTypedCellFormulaIsStoredAsTheFormulaNotItsResult() {
        let vm = standardViewModel()
        applyChange(vm, rowID: "row_1", cells: [notesID: "=A+B"])

        let rows = vm.tableDataModel.documentEditor?.field(fieldID: tableFieldID)?.valueToValueElements
        let cell = rows?.first(where: { $0.id == "row_1" })?.cells?[notesID]
        XCTAssertEqual(cell?.text, "=A+B", "The cell holds what the user typed")
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "…and the result is only computed")
    }

    // MARK: - Lifetime

    func testRemovingARowDropsItsResults() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6")
        vm.tableDataModel.documentEditor?.removeFormulaValues(fieldID: tableFieldID, rowIDs: ["row_1"])
        XCTAssertNil(result(vm, "row_1", totalID))
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "Other rows are untouched")
    }
}

/// Collections resolve formulas per schema: column letters are positional, so `A` means a
/// different column in a root schema than in a nested one. These drive the context API
/// directly — `CollectionViewModel` builds its cells on a background queue, which is not
/// what is under test here.
final class CollectionCellFormulaTests: XCTestCase {

    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    let collectionFieldID = "collection_formula_001"
    let documentID = "685750eff3216b45ffe73c80"
    let fieldPositionID = "6857510f4313cfbfb43c516c"
    let rootSchema  = "rootSchema"
    let childSchema = "childSchema"

    let qtyID   = "col_qty"
    let priceID = "col_price"
    let totalID = "col_total"
    let notesID = "col_notes"

    // MARK: - Builders

    private func column(id: String, type: ColumnTypes, title: String, formula: String? = nil) -> [String: Any] {
        var dict: [String: Any] = ["_id": id, "type": type.rawValue, "title": title,
                                   "width": 0, "identifier": "field_column_\(id)"]
        if let formula = formula { dict["value"] = formula }
        return dict
    }

    private func row(_ id: String, _ cells: [String: Any], children: [[String: Any]] = []) -> [String: Any] {
        var dict: [String: Any] = ["_id": id, "cells": cells]
        if !children.isEmpty { dict["children"] = [childSchema: ["value": children]] }
        return dict
    }

    /// Columns shared by both schemas unless a test overrides one: Total = A*B.
    private func columns(totalFormula: String = "=A*B") -> [[String: Any]] {
        [column(id: qtyID, type: .number, title: "Qty"),
         column(id: priceID, type: .number, title: "Price"),
         column(id: totalID, type: .text, title: "Total", formula: totalFormula),
         column(id: notesID, type: .text, title: "Notes")]
    }

    private func editor(rootColumns: [[String: Any]],
                        childColumns: [[String: Any]],
                        rows: [[String: Any]]) -> DocumentEditor {
        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.title = "Formula Collection"
        field.file = fileID
        field.dictionary["schema"] = [
            rootSchema:  ["title": "Root",  "root": true,  "children": [childSchema], "tableColumns": rootColumns],
            childSchema: ["title": "Child", "root": false, "children": [String](),    "tableColumns": childColumns]
        ]
        field.value = .valueElementArray(rows.map { ValueElement(dictionary: $0) })

        var document = JoyDoc().setDocument().setFile().setMobileView()
            .setPageFieldInMobileView().setPageField()
        document.fields.append(field)
        document = document.setFieldPositionToPage(pageId: pageID,
                                                   idAndTypes: [collectionFieldID: .collection])
        return DocumentEditor(document: document, validateSchema: false)
    }

    /// Opens the collection the way the screen does, then expands every root row — which is
    /// the tap that makes nested rows appear.
    private func open(rootColumns: [[String: Any]]? = nil,
                      childColumns: [[String: Any]]? = nil,
                      rows: [[String: Any]]) -> (vm: CollectionViewModel, editor: DocumentEditor) {
        let editor = editor(rootColumns: rootColumns ?? columns(),
                            childColumns: childColumns ?? columns(),
                            rows: rows)
        let field = editor.field(fieldID: collectionFieldID)
        let header = FieldHeaderModel(title: field?.title, required: field?.required,
                                      tipDescription: field?.tipDescription, tipTitle: field?.tipTitle,
                                      tipVisible: field?.tipVisible,
                                      visibleLimitInFields: editor.decoratorConfig.visibleLimitInFields)
        let model = TableDataModel(fieldHeaderModel: header, mode: .fill, documentEditor: editor,
                                   fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID,
                                                                    pageID: pageID, fileID: fileID))!
        let vm = CollectionViewModel(tableDataModel: model)
        let deadline = Date().addingTimeInterval(2)
        while vm.isLoading && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.01))
        }
        XCTAssertFalse(vm.isLoading, "CollectionViewModel did not finish loading")

        for rowModel in vm.tableDataModel.filteredcellModels where rowModel.rowType.isRow {
            vm.expandTables(rowDataModel: rowModel, level: rowModel.rowType.level ?? 0)
        }
        return (vm, editor)
    }

    private func value(_ vm: CollectionViewModel, _ rowID: String, _ columnID: String) -> String? {
        vm.formulaValue(columnID: columnID, rowID: rowID)?.text
    }

    /// Waits for work the SDK deferred with `DispatchQueue.main.async`.
    ///
    /// The main queue is FIFO, so a block enqueued now can only run once that work has.
    /// Spinning the run loop directly is not enough: `RunLoop.run(mode:before:)` returns
    /// immediately when nothing is attached to the loop, so these waits only worked when
    /// an earlier test happened to leave something on it — and the tests failed when run
    /// on their own.
    private func settle() {
        let drained = expectation(description: "deferred main-queue work ran")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
    }

    private func externalRowUpdate(rowID: String, cells: [String: Any], schemaID: String) -> Change {
        Change(dictionary: [
            "v": 1,
            "sdk": "swift",
            "_id": documentID,
            "identifier": "doc_\(documentID)",
            "target": "field.value.rowUpdate",
            "fileId": fileID,
            "pageId": pageID,
            "fieldId": collectionFieldID,
            "fieldIdentifier": "field_\(collectionFieldID)",
            "fieldPositionId": fieldPositionID,
            "change": ["rowId": rowID, "schemaId": schemaID,
                       "row": ["_id": rowID, "cells": cells] as [String: Any]],
            "createdOn": Date().timeIntervalSince1970
        ])
    }

    private var oneRootWithOneChild: [[String: Any]] {
        [row("root_1", [qtyID: 2, priceID: 3],
             children: [row("child_1", [qtyID: 4, priceID: 5])])]
    }

    // MARK: - Opening a collection shows computed values

    func testOpeningACollectionShowsComputedValuesInRootAndNestedRows() {
        let (vm, _) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "2 * 3")
        XCTAssertEqual(value(vm, "child_1", totalID), "20", "4 * 5, against the child schema")
    }

    /// The same formula text in two schemas whose columns are ordered differently must mean
    /// different columns. A setup cached per field rather than per field-and-schema would
    /// give both rows the same answer.
    func testTheSameLetterMeansADifferentColumnInEachSchema() {
        let rootColumns = [column(id: qtyID, type: .number, title: "Qty"),
                           column(id: priceID, type: .number, title: "Price"),
                           column(id: totalID, type: .text, title: "Total", formula: "=A")]
        let childColumns = [column(id: priceID, type: .number, title: "Price"),   // order swapped
                            column(id: qtyID, type: .number, title: "Qty"),
                            column(id: totalID, type: .text, title: "Total", formula: "=A")]
        let (vm, _) = open(rootColumns: rootColumns, childColumns: childColumns,
                           rows: [row("root_1", [qtyID: 7, priceID: 99],
                                      children: [row("child_1", [qtyID: 7, priceID: 99])])])

        XCTAssertEqual(value(vm, "root_1", totalID), "7",  "A is Qty in the root schema")
        XCTAssertEqual(value(vm, "child_1", totalID), "99", "A is Price in the child schema")
    }

    func testTheSameTitleMeansEachSchemasOwnColumn() {
        // Both schemas have a column titled "Qty", but they are different columns.
        let rootColumns = [column(id: "root_qty", type: .number, title: "Qty"),
                           column(id: totalID, type: .text, title: "Total", formula: "=Qty")]
        let childColumns = [column(id: "child_qty", type: .number, title: "Qty"),
                            column(id: totalID, type: .text, title: "Total", formula: "=Qty")]
        let (vm, _) = open(rootColumns: rootColumns, childColumns: childColumns,
                           rows: [row("root_1", ["root_qty": 7],
                                      children: [row("child_1", ["child_qty": 99])])])

        XCTAssertEqual(value(vm, "root_1", totalID), "7",  "the root schema's Qty")
        XCTAssertEqual(value(vm, "child_1", totalID), "99", "the child schema's Qty")
    }

    /// Results come from the context's init, not from building cells — so a nested row
    /// nothing has expanded still has its value. `editor(...)` alone builds no view model.
    func testNestedRowsAreEvaluatedWithoutBuildingAnyCells() {
        let editor = editor(rootColumns: columns(), childColumns: columns(),
                            rows: [row("root_1", [qtyID: 2, priceID: 3],
                                       children: [row("child_1", [qtyID: 4, priceID: 5])])])

        XCTAssertEqual(editor.cellFormulaValue(columnID: totalID, fieldID: collectionFieldID,
                                               rowID: "child_1")?.text, "20", "4 * 5, never expanded")
        XCTAssertEqual(editor.cellFormulaValue(columnID: totalID, fieldID: collectionFieldID,
                                               rowID: "root_1")?.text, "6", "2 * 3")
    }

    func testACellFormulaInANestedRowOverridesItsColumnFormula() {
        let (vm, _) = open(rows: [row("root_1", [qtyID: 2, priceID: 3],
                                      children: [row("child_1", [qtyID: 4, priceID: 5, totalID: "=A+B"])])])
        XCTAssertEqual(value(vm, "child_1", totalID), "9", "The nested cell's own formula wins")
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "The root row still uses the column formula")
    }

    func testEachSchemaKeepsItsOwnColumnFormula() {
        let (vm, _) = open(rootColumns: columns(totalFormula: "=A*2"),
                           childColumns: columns(totalFormula: "=A*10"),
                           rows: [row("root_1", [qtyID: 3], children: [row("child_1", [qtyID: 3])])])
        XCTAssertEqual(value(vm, "root_1", totalID), "6")
        XCTAssertEqual(value(vm, "child_1", totalID), "30")
    }

    // MARK: - Editing

    func testEditingANestedCellUpdatesItsRow() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20")

        editor.change(changes: [externalRowUpdate(rowID: "child_1", cells: [qtyID: 10], schemaID: childSchema)])
        settle()

        XCTAssertEqual(value(vm, "child_1", totalID), "50", "10 * 5")
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "the parent row is untouched")
    }

    // MARK: - External changes

    func testExternalCellChangeOnARootRowUpdatesWhatIsShown() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "6")

        editor.change(changes: [externalRowUpdate(rowID: "root_1", cells: [qtyID: 10], schemaID: rootSchema)])
        settle()

        XCTAssertEqual(value(vm, "root_1", totalID), "30", "10 * 3")
    }

    func testExternalCellChangeOnANestedRowUpdatesWhatIsShown() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20")

        editor.change(changes: [externalRowUpdate(rowID: "child_1", cells: [qtyID: 10], schemaID: childSchema)])
        settle()

        XCTAssertEqual(value(vm, "child_1", totalID), "50", "10 * 5")
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "the parent row is untouched")
    }

    func testExternalChangeCanIntroduceACellFormulaInANestedRow() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertNil(value(vm, "child_1", notesID))

        editor.change(changes: [externalRowUpdate(rowID: "child_1", cells: [notesID: "=A+B"], schemaID: childSchema)])
        settle()

        XCTAssertEqual(value(vm, "child_1", notesID), "9", "4 + 5")
    }

    // MARK: - The document is never written

    func testAColumnDrivenNestedCellStaysNullInTheDocument() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20")

        let rootRows = editor.field(fieldID: collectionFieldID)?.valueToValueElements ?? []
        let child = rootRows.first?.childrens?[childSchema]?.valueToValueElements?.first
        XCTAssertNil(child?.cells?[totalID], "Neither the formula nor the result is written to a nested cell")
    }

    // MARK: - Invalid formulas

    func testAnInvalidColumnFormulaErrorsInBothSchemas() {
        let (vm, _) = open(rootColumns: columns(totalFormula: "=A *"),
                           childColumns: columns(totalFormula: "=A *"),
                           rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "Error")
        XCTAssertEqual(value(vm, "child_1", totalID), "Error")
    }

    func testAnInvalidFormulaInOneSchemaLeavesTheOtherWorking() {
        let (vm, _) = open(rootColumns: columns(totalFormula: "=A*B"),
                           childColumns: columns(totalFormula: "=NOTAFUNCTION(A)"),
                           rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "6")
        XCTAssertEqual(value(vm, "child_1", totalID), "Error")
    }

    func testDivisionByZeroInANestedSchemaIsAnError() {
        let (vm, _) = open(rootColumns: columns(totalFormula: "=A*B"),
                           childColumns: columns(totalFormula: "=A/0"),
                           rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "Error")
    }

    func testAColumnThatExistsOnlyInAnotherSchemaCannotBeReferenced() {
        var childColumns = columns()
        childColumns.append(column(id: "col_child_only", type: .number, title: "ChildOnly"))
        let (vm, _) = open(rootColumns: columns(totalFormula: "=ChildOnly"),
                           childColumns: childColumns,
                           rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "Error", "Each schema resolves against its own columns only")
        XCTAssertEqual(value(vm, "child_1", totalID), "20")
    }

    func testANestedColumnReferencingItselfIsAnError() {
        let (vm, _) = open(rootColumns: columns(totalFormula: "=A*B"),
                           childColumns: columns(totalFormula: "=C"),
                           rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "root_1", totalID), "6")
        XCTAssertEqual(value(vm, "child_1", totalID), "Error", "C is Total, the cell being computed")
    }

    func testAnInvalidCellFormulaInANestedRowErrors() {
        let (vm, _) = open(rows: [row("root_1", [qtyID: 2, priceID: 3],
                                      children: [row("child_1", [qtyID: 4, priceID: 5, totalID: "=A +"])])])
        XCTAssertEqual(value(vm, "child_1", totalID), "Error")
        XCTAssertEqual(value(vm, "root_1", totalID), "6", "and the root row is untouched")
    }
}
