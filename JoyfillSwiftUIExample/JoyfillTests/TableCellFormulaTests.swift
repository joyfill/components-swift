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

    private func document(columns: [FieldTableColumn], rows: [ValueElement],
                          extraFields: [JoyDocField] = []) -> JoyDoc {
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
        document.fields.append(contentsOf: extraFields)
        // One call with every field: it replaces the page's positions rather than adding.
        var idAndTypes: [String: FieldTypes] = [tableFieldID: .table]
        for extra in extraFields {
            if let id = extra.id { idAndTypes[id] = extra.fieldType }
        }
        return document.setFieldPositionToPage(pageId: pageID, idAndTypes: idAndTypes)
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

    private func reorderedTableViewModel() -> TableViewModel {
        var doc = document(columns: standardColumns(totalFormula: "=A-B"),
                           rows: [row("row_1", [qtyID: 2, priceID: 7, notesID: "=A/B"])])
        let index = doc.fields.firstIndex(where: { $0.id == tableFieldID })!
        var fields = doc.fields
        fields[index].tableColumnOrder = [priceID, qtyID, totalID, doubleID, notesID]
        doc.fields = fields
        return viewModel(doc)
    }

    func testLetterReferencesFollowTableColumnOrder() {
        let vm = reorderedTableViewModel()
        XCTAssertEqual(vm.tableDataModel.tableColumns.first?.id, priceID)
        XCTAssertEqual(result(vm, "row_1", totalID), "5", "A is Price and B is Qty")
        XCTAssertEqual(result(vm, "row_1", doubleID), "10", "Chained formulas use the same order")
        XCTAssertEqual(result(vm, "row_1", notesID), "3.5", "Cell formulas use the same order")
    }

    func testReorderedLetterReferencesRefreshAfterEditingTheirSource() {
        let vm = reorderedTableViewModel()
        vm.tableDataModel.documentEditor?.change(changes: [
            externalRowUpdate(rowID: "row_1", cells: [priceID: 10])
        ])
        settle()
        XCTAssertEqual(result(vm, "row_1", totalID), "8")
        XCTAssertEqual(result(vm, "row_1", doubleID), "16")
        XCTAssertEqual(result(vm, "row_1", notesID), "5")
    }

    func testFormulaReadingAnotherFormulaColumnFollowsTheChain() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", doubleID), "12", "C is 6, so C*2 is 12")
        XCTAssertEqual(result(vm, "row_2", doubleID), "40")
    }

    func testColumnCanBeReferencedByItsID() {
        let vm = standardViewModel(totalFormula: "=\(qtyID) * \(priceID)")
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "id resolves before the title or the letter")
    }

    /// References resolve by id, title, then letter. A column's `identifier` field plays no
    /// part. Real ids are ObjectIds, which start with a digit — the shared lexer cannot begin
    /// an identifier with one, so this specific shape of id is still unreachable; teaching the
    /// lexer to accept it would be a change to JoyfillFormulas rather than a rewrite here.
    func testADigitLeadingColumnIDIsNotAReference() {
        let qty = "6aa0ea5666f683e02ea449b5"
        let columns = [column(id: qty, type: .number, title: "Qty"),
                       column(id: priceID, type: .number, title: "Price"),
                       column(id: totalID, type: .text, title: "Total", formula: "=\(qty)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qty: 2, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
    }

    func testColumnCanBeReferencedByItsTitle() {
        let vm = standardViewModel(totalFormula: "=Qty * Price")
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Title resolves when no id matches")
    }

    func testTitleIsMatchedCaseInsensitively() {
        let vm = standardViewModel(totalFormula: "=qty * pRiCe")
        XCTAssertEqual(result(vm, "row_1", totalID), "6")
    }

    // MARK: - Names a formula can actually write

    /// The lexer makes an identifier from letters, digits and `_`, so a multi-word title
    /// is two tokens and can never be referenced. The column is still reachable by its
    /// id or its letter.
    func testAMultiWordTitleCannotBeReferenced() {
        let columns = [column(id: qtyID, type: .number, title: "Unit Price"),
                       column(id: priceID, type: .number, title: "Qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=Unit Price * B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 4, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
    }

    func testAColumnWithAMultiWordTitleIsStillReachableByID() {
        let columns = [column(id: qtyID, type: .number, title: "Unit Price"),
                       column(id: priceID, type: .number, title: "Qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=\(qtyID) * B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 4, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "12")
    }

    func testAColumnWithAMultiWordTitleIsStillReachableByLetter() {
        let columns = [column(id: qtyID, type: .number, title: "Unit Price"),
                       column(id: priceID, type: .number, title: "Qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=A * B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 4, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "12")
    }

    func testTitlesWithPunctuationCannotBeReferenced() {
        for title in ["Qty (kg)", "Price%", "Notes!", "Unit/Price"] {
            let columns = [column(id: qtyID, type: .number, title: title),
                           column(id: totalID, type: .text, title: "Total", formula: "=\(title)")]
            let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 4])]))
            XCTAssertEqual(result(vm, "row_1", totalID), "Error", "`\(title)` is not one token")
        }
    }

    /// A title made of operators is read as the expression it looks like, not as a name.
    /// `Total-Cost` subtracts, `50/50` divides — neither reaches the resolver.
    func testATitleThatLooksLikeAnExpressionIsEvaluatedAsOne() {
        let numeric = [column(id: qtyID, type: .number, title: "50/50"),
                       column(id: totalID, type: .text, title: "Total", formula: "=50/50")]
        XCTAssertEqual(result(viewModel(document(columns: numeric, rows: [row("row_1", [qtyID: 4])])),
                              "row_1", totalID), "1", "Arithmetic on two numbers, not the column titled 50/50")

        let hyphen = [column(id: qtyID, type: .number, title: "Total-Cost"),
                      column(id: priceID, type: .number, title: "Cost"),
                      column(id: totalID, type: .text, title: "Total", formula: "=Total-Cost")]
        XCTAssertEqual(result(viewModel(document(columns: hyphen,
                                                 rows: [row("row_1", [qtyID: 4, priceID: 3])])),
                              "row_1", totalID), "Error",
                       "Reads as Total minus Cost; Total is a text column, so it fails rather than guessing")
    }

    /// A column's `identifier` field is not part of resolution at all — a formula typing it
    /// finds nothing, whether it is one word or several.
    func testAColumnsIdentifierFieldDoesNotResolveAnything() {
        let columns = [column(id: qtyID, type: .number, title: "Qty", identifier: "myIdentifier"),
                       column(id: totalID, type: .text, title: "Total", formula: "=myIdentifier")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 4])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
    }

    // MARK: - Resolution priority: id, then name, then letter

    func testAColumnsIDBeatsAnotherColumnsTitle() {
        // The first column's id is the second column's title. id is the top resolution
        // tier, so `=qty` is the column *whose id is* qty, not the column titled qty.
        let columns = [column(id: "qty", type: .number, title: "Price"),
                       column(id: "price", type: .number, title: "qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=qty")]
        let vm = viewModel(document(columns: columns,
                                    rows: [row("row_1", ["qty": 7, "price": 99])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "7", "The column whose id is `qty`")
    }

    /// A column's own id is referenceable even when its `identifier` is something else
    /// entirely and its title is multi-word (and so unreferenceable on its own).
    func testAColumnIsReferenceableByItsOwnID() {
        let columns = [column(id: "text1", type: .text, title: "Operand A", identifier: "table3_column_text1"),
                       column(id: "text2", type: .text, title: "Operand B", identifier: "table3_column_text2"),
                       column(id: "text3", type: .text, title: "SUM(A,B)", formula: "=SUM(text1,text2)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["text1": "10", "text2": "21"])]))
        XCTAssertEqual(result(vm, "row_1", "text3"), "31")
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

    func testCellFormulaCanUseIDsAndTitles() {
        let vm = standardViewModel(rows: [row("row_1", [qtyID: 2, priceID: 3,
                                                        notesID: "=\(qtyID) + Price"])])
        XCTAssertEqual(result(vm, "row_1", notesID), "5", "One by id, one by title, in a cell formula")
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

    /// A bare reference to a circular cell surfaces cleanly (the test above), but `+`
    /// stringifies its operands — so without the fix a circular value reached through it
    /// rendered as raw text like `prefix#CIRC!(Circular reference at column 'B')` instead.
    func testCircularReferenceInsideConcatenationStillSurfacesAsError() {
        let columns = [column(id: qtyID,   type: .number, title: "Qty"),
                       column(id: totalID, type: .text,   title: "Total",  formula: "=D"),
                       column(id: doubleID, type: .text,  title: "Double", formula: "=B"),
                       column(id: notesID, type: .text,   title: "Notes",  formula: "=\"prefix\" + B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 1])]))
        XCTAssertEqual(result(vm, "row_1", notesID), "Error", "not the raw '#CIRC!(...)' text")
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

    func testReferenceToSomethingThatIsNotAColumnIsAnError() {
        XCTAssertEqual(result(standardViewModel(totalFormula: "=ZZZ"), "row_1", totalID), "Error")
    }

    /// A formula reads its own row only. Reaching a field outside the table used to work
    /// and then go stale, because nothing registers a dependency from a field back to a
    /// table — so it is refused instead.
    func testAReferenceToADocumentFieldIsAnError() {
        var field = JoyDocField()
        field.type = "number"
        field.id = "num_field_001"
        field.identifier = "taxRate"
        field.file = fileID
        field.value = .double(3)

        let document = self.document(columns: standardColumns(totalFormula: "=A * taxRate"),
                                     rows: [row("row_1", [qtyID: 2, priceID: 3])],
                                     extraFields: [field])

        XCTAssertEqual(result(viewModel(document), "row_1", totalID), "Error",
                       "`taxRate` is a document field, not a column of this row")
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

    /// Text stays text, so arithmetic on it asks for TONUMBER. Coercing at read time
    /// would change the value for every consumer, not only the operators.
    /// `*` (like the rest of arithmetic) now coerces a text-cell operand automatically —
    /// explicit TONUMBER is no longer required, though it still reads the same.
    func testArithmeticOnATextCellCoercesAutomatically() {
        let rows = [row("row_1", [qtyID: 1, priceID: 1, notesID: "23"])]
        XCTAssertEqual(result(standardViewModel(totalFormula: "=E * 2", rows: rows), "row_1", totalID),
                       "46", "`=E * 2` on a text cell coerces automatically")
        XCTAssertEqual(result(standardViewModel(totalFormula: "=TONUMBER(E) * 2", rows: rows), "row_1", totalID),
                       "46", "TONUMBER still works too")
    }

    /// SUM's whole job is numeric aggregation, so its own direct column arguments get the
    /// same implicit TONUMBER a whole-column array argument already gets — same rule as
    /// the arithmetic operators just above.
    func testSumCoercesTextCellsHoldingNumbers() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_c", type: .text, title: "C", formula: "=SUM(A, B)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "2", "col_b": "3"])]))
        XCTAssertEqual(result(vm, "row_1", "col_c"), "5", "SUM reads numeric-looking text cells")
    }

    /// The coercion is still TONUMBER underneath, so genuinely non-numeric text is still an
    /// error rather than being silently treated as zero.
    func testSumStillErrorsOnGenuinelyNonNumericText() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_c", type: .text, title: "C", formula: "=SUM(A, B)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "hello", "col_b": "3"])]))
        XCTAssertEqual(result(vm, "row_1", "col_c"), "Error")
    }

    func testSumStillWorksOnNumberColumns() {
        let vm = standardViewModel(totalFormula: "=SUM(A,B)")
        XCTAssertEqual(result(vm, "row_1", totalID), "5", "2 + 3, unaffected by the text-cell coercion")
    }

    /// The same rule applies to the rest of the numeric-function family, not just SUM.
    func testOtherNumericFunctionsAlsoCoerceTextCells() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_min", type: .text, title: "Min", formula: "=MIN(A, B)"),
                       column(id: "col_max", type: .text, title: "Max", formula: "=MAX(A, B)"),
                       column(id: "col_avg", type: .text, title: "Avg", formula: "=AVG(A, B)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "2", "col_b": "8"])]))
        XCTAssertEqual(result(vm, "row_1", "col_min"), "2")
        XCTAssertEqual(result(vm, "row_1", "col_max"), "8")
        XCTAssertEqual(result(vm, "row_1", "col_avg"), "5")
    }

    /// `-`/`*`/`/` have no string meaning, unlike `+`, so a text-cell operand is always safe
    /// to coerce — this is the direct `=text2-text1` case.
    func testArithmeticOperatorsCoerceTextCellsDirectly() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_sub", type: .text, title: "Sub", formula: "=B-A"),
                       column(id: "col_mul", type: .text, title: "Mul", formula: "=A*B"),
                       column(id: "col_div", type: .text, title: "Div", formula: "=B/A")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "2", "col_b": "8"])]))
        XCTAssertEqual(result(vm, "row_1", "col_sub"), "6")
        XCTAssertEqual(result(vm, "row_1", "col_mul"), "16")
        XCTAssertEqual(result(vm, "row_1", "col_div"), "4")
    }

    /// The coercion recurses, so an arithmetic expression nested inside a numeric function's
    /// argument is reached too, not just a bare reference — e.g. `ROUND(text2/text1, 2)`.
    func testArithmeticNestedInsideANumericFunctionArgumentIsAlsoCoerced() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_c", type: .text, title: "C", formula: "=ROUND(B/A, 2)")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "3", "col_b": "10"])]))
        XCTAssertEqual(result(vm, "row_1", "col_c"), "3.33")
    }

    /// `+` stays ambiguous on purpose: two text cells still concatenate rather than add.
    /// Two bare column references either side of `+` add, matching `-`/`*`/`/`.
    func testPlusAddsTwoTextCellColumnReferences() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B"),
                       column(id: "col_c", type: .text, title: "C", formula: "=A+B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "2", "col_b": "8"])]))
        XCTAssertEqual(result(vm, "row_1", "col_c"), "10", "2 + 8, not string concatenation")
    }

    /// A already-numeric column needs no coercion; only B (text) is wrapped in TONUMBER.
    /// The result is still plain numeric addition, not concatenation.
    func testPlusAddsANumberColumnAndATextColumn() {
        let columns = [column(id: "col_a", type: .number, title: "A"),
                       column(id: "col_b", type: .text,   title: "B"),
                       column(id: "col_c", type: .text,   title: "C", formula: "=A+B")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": 5, "col_b": "5"])]))
        XCTAssertEqual(result(vm, "row_1", "col_c"), "10", "5 + 5, not \"55\"")
    }

    /// But a text cell next to anything that is not itself a bare column reference — a
    /// literal, a function result — still concatenates, including when the cell holds
    /// genuinely non-numeric text. Coercing this case would turn a working formula into
    /// an error the moment the cell held something TONUMBER can't parse.
    /// `+` means addition unconditionally now, even against a non-numeric text cell — use
    /// CONCAT() to join strings instead.
    func testPlusOnANonNumericTextCellIsAnErrorNotConcatenation() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B", formula: "=A + \" notes\"")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "hello"])]))
        XCTAssertEqual(result(vm, "row_1", "col_b"), "Error", "use CONCAT(A, \" notes\") to join text")
    }

    func testConcatIsHowToJoinATextCellWithALiteral() {
        let columns = [column(id: "col_a", type: .text, title: "A"),
                       column(id: "col_b", type: .text, title: "B", formula: "=CONCAT(A, \" notes\")")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", ["col_a": "hello"])]))
        XCTAssertEqual(result(vm, "row_1", "col_b"), "hello notes")
    }

    func testTextThatLooksNumericIsStillTextToStringFunctions() {
        let vm = standardViewModel(totalFormula: "=CONCAT(\"n\", E)",
                                   rows: [row("row_1", [qtyID: 1, priceID: 1, notesID: "23"])])
        XCTAssertEqual(result(vm, "row_1", totalID), "n23")
    }

    /// The regression that read-time coercion caused: `00123` reached CONCAT as `123`.
    func testLeadingZerosSurviveStringFunctions() {
        let vm = standardViewModel(totalFormula: "=CONCAT(E, \"-\")",
                                   rows: [row("row_1", [qtyID: 1, priceID: 1, notesID: "00123"])])
        XCTAssertEqual(result(vm, "row_1", totalID), "00123-", "A part number is not a quantity")
    }

    func testIdentifiersThatBeginWithDigitsAreNotReshaped() {
        for stored in ["00123", "0800", "+1 555 0100", "1.50.2", "007"] {
            let vm = standardViewModel(totalFormula: "=CONCAT(E, \"|\")",
                                       rows: [row("row_1", [qtyID: 1, priceID: 1, notesID: stored])])
            XCTAssertEqual(result(vm, "row_1", totalID), "\(stored)|", "\(stored) must reach CONCAT unchanged")
        }
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

    private func externalRowDelete(rowID: String) -> Change {
        change(target: "field.value.rowDelete", payload: ["rowId": rowID])
    }

    private func externalRowMove(rowID: String, to index: Int) -> Change {
        change(target: "field.value.rowMove", payload: ["rowId": rowID, "targetRowIndex": index])
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

    /// Called from a background queue; only the internal main-queue hop needs main.
    func testExternalCellChangeFromBackgroundQueueRecomputesWithoutCrashing() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6", "Before the change")

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            vm.tableDataModel.documentEditor?.change(changes: [self.externalRowUpdate(rowID: "row_1", cells: [self.qtyID: 10])])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)
        settle() // drain the main-queue hop the background call just scheduled

        XCTAssertEqual(result(vm, "row_1", totalID), "30", "10 * 3 after a background-thread change")
        XCTAssertEqual(result(vm, "row_1", doubleID), "60", "and the chain through Total follows")
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "other rows untouched")
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

    /// Unlike rowUpdate, rowCreate has no main-queue hop — it runs inline on the caller's thread.
    func testExternalRowCreateFromBackgroundQueueRecomputesWithoutCrashing() {
        let vm = standardViewModel()

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            vm.tableDataModel.documentEditor?.change(changes: [self.externalRowCreate(rowID: "row_3", cells: [self.qtyID: 6, self.priceID: 7], at: 2)])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        XCTAssertEqual(result(vm, "row_3", totalID), "42", "A new row is primed as its cells are built")
        XCTAssertEqual(result(vm, "row_3", doubleID), "84")
    }

    /// Same reasoning: rowDelete also runs inline.
    func testExternalRowDeleteFromBackgroundQueueDoesNotCrash() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "Before the change")

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            vm.tableDataModel.documentEditor?.change(changes: [self.externalRowDelete(rowID: "row_1")])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        let rows = vm.tableDataModel.documentEditor?.field(fieldID: tableFieldID)?.valueToValueElements?.filter { $0.deleted != true }
        XCTAssertEqual(rows?.count, 1, "row_1 must be gone")
        XCTAssertNil(rows?.first(where: { $0.id == "row_1" }))
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "the surviving row's formula is untouched")
    }

    /// Same reasoning for rowMove.
    func testExternalRowMoveFromBackgroundQueueDoesNotCrash() {
        let vm = standardViewModel()

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            vm.tableDataModel.documentEditor?.change(changes: [self.externalRowMove(rowID: "row_2", to: 0)])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        XCTAssertEqual(vm.tableDataModel.rowOrder.first, "row_2", "row_2 must now lead")
        XCTAssertEqual(result(vm, "row_2", totalID), "20", "moving a row must not disturb its formula")
        XCTAssertEqual(result(vm, "row_1", totalID), "6",  "or the row it passed")
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

    // MARK: - Validation

    /// A required formula column is satisfied by what it computes. The cell itself stays
    /// null, so validating the stored value alone would make such a column impossible to
    /// satisfy. No view model here — `validate()` is called on the editor directly.
    private func validity(totalFormula: String, rows: [ValueElement],
                          requiredColumn: Bool = true) -> ValidationStatus? {
        var columns = standardColumns(totalFormula: totalFormula)
        if requiredColumn, let index = columns.firstIndex(where: { $0.id == totalID }) {
            var dict = columns[index].dictionary
            dict["required"] = true
            columns[index] = FieldTableColumn(dictionary: dict)
        }
        let editor = DocumentEditor(document: document(columns: columns, rows: rows), validateSchema: false)
        return editor.validate().fieldValidities.first(where: { $0.fieldId == tableFieldID })?.status
    }

    func testARequiredFormulaColumnIsSatisfiedByItsComputedValue() {
        XCTAssertEqual(validity(totalFormula: "=A*B", rows: [row("row_1", [qtyID: 2, priceID: 3])]),
                       .valid, "The cell is null but it shows 6")
    }

    func testARequiredFormulaColumnIsUnsatisfiedWhenItComputesNothing() {
        XCTAssertEqual(validity(totalFormula: "=\"\"", rows: [row("row_1", [qtyID: 2, priceID: 3])]),
                       .invalid, "An empty result is no better than an empty cell")
    }

    func testARequiredFormulaColumnIsUnsatisfiedWhenTheFormulaFails() {
        XCTAssertEqual(validity(totalFormula: "=A *", rows: [row("row_1", [qtyID: 2, priceID: 3])]),
                       .invalid, "Error is not a value")
    }

    /// The text of a formula is not a value either: a cell storing `=A *` is non-empty,
    /// but it shows Error.
    func testACellHoldingABrokenFormulaDoesNotSatisfyRequired() {
        XCTAssertEqual(validity(totalFormula: "=A*B",
                                rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "=A *"])]),
                       .invalid)
    }

    func testARequiredColumnWithoutAFormulaStillNeedsAValue() {
        var columns = standardColumns()
        let index = columns.firstIndex(where: { $0.id == totalID })!
        var dict = columns[index].dictionary
        dict["value"] = nil
        dict["required"] = true
        columns[index] = FieldTableColumn(dictionary: dict)
        let editor = DocumentEditor(document: document(columns: columns,
                                                       rows: [row("row_1", [qtyID: 2, priceID: 3])]),
                                    validateSchema: false)
        XCTAssertEqual(editor.validate().fieldValidities.first(where: { $0.fieldId == tableFieldID })?.status,
                       .invalid, "No formula and no stored value")
    }

    func testARequiredFormulaColumnIsSatisfiedByACellFormulaToo() {
        XCTAssertEqual(validity(totalFormula: "=A *",
                                rows: [row("row_1", [qtyID: 2, priceID: 3, totalID: "=A+B"])]),
                       .valid, "The cell's own formula computes even though the column's is broken")
    }

    // MARK: - The required indicator

    /// What `TableModalView` puts the red border on: required, and not filled.
    private func showsRequiredIndicator(_ vm: TableViewModel, rowID: String, columnID: String) -> Bool? {
        guard let cell = vm.tableDataModel.cellModels.first(where: { $0.rowID == rowID })?
            .cells.first(where: { $0.data.id == columnID }) else { return nil }
        return vm.isCellRequired(columnID: columnID, rowID: rowID) && !cell.isFilled
    }

    private func requiredTotal(_ columns: [FieldTableColumn]) -> [FieldTableColumn] {
        columns.map { column in
            guard column.id == totalID else { return column }
            var dict = column.dictionary
            dict["required"] = true
            return FieldTableColumn(dictionary: dict)
        }
    }

    func testARequiredFormulaCellShowsNoIndicatorWhenItComputesAValue() {
        let vm = viewModel(document(columns: requiredTotal(standardColumns()),
                                    rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "6")
        XCTAssertEqual(showsRequiredIndicator(vm, rowID: "row_1", columnID: totalID), false,
                       "The cell is null but it shows 6, so no red border")
    }

    func testARequiredFormulaCellShowsTheIndicatorWhenTheFormulaFails() {
        let vm = viewModel(document(columns: requiredTotal(standardColumns(totalFormula: "=A *")),
                                    rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "Error")
        XCTAssertEqual(showsRequiredIndicator(vm, rowID: "row_1", columnID: totalID), true,
                       "Error is not a value")
    }

    func testARequiredFormulaCellShowsTheIndicatorWhenItComputesNothing() {
        let vm = viewModel(document(columns: requiredTotal(standardColumns(totalFormula: "=\"\"")),
                                    rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertEqual(showsRequiredIndicator(vm, rowID: "row_1", columnID: totalID), true)
    }

    func testTheRequiredCounterCountsAComputedCellAsFilled() {
        let vm = viewModel(document(columns: requiredTotal(standardColumns()),
                                    rows: [row("row_1", [qtyID: 2, priceID: 3])]))
        XCTAssertEqual(vm.getProgress(rowId: "row_1").0, 1,
                       "The one required column is satisfied by its computed value")
    }

    // MARK: - Only a text column evaluates

    /// A barcode column never carries a formula, so text that merely looks like one is
    /// literal — including when another formula reads it.
    func testABarcodeCellHoldingFormulaTextIsReadAsText() {
        let columns = [column(id: qtyID, type: .barcode, title: "Code"),
                       column(id: totalID, type: .text, title: "Total", formula: "=CONCAT(A, \"x\")")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: "=1+1"])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "=1+1x", "Not 2x")
    }

    func testABarcodeColumnDefaultThatLooksLikeAFormulaIsAlsoText() {
        let columns = [column(id: qtyID, type: .barcode, title: "Code", formula: "=1+1"),
                       column(id: totalID, type: .text, title: "Total", formula: "=CONCAT(A, \"x\")")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [:])]))
        XCTAssertNil(result(vm, "row_1", qtyID), "A barcode column carries no formula")
        XCTAssertNotEqual(result(vm, "row_1", totalID), "2x")
    }

    func testANumberCellIsNeverEvaluated() {
        let columns = [column(id: qtyID, type: .number, title: "Qty"),
                       column(id: totalID, type: .text, title: "Total", formula: "=A*2")]
        let vm = viewModel(document(columns: columns, rows: [row("row_1", [qtyID: 21])]))
        XCTAssertEqual(result(vm, "row_1", totalID), "42")
        XCTAssertNil(result(vm, "row_1", qtyID))
    }

    // MARK: - Replacing a field's whole value

    /// `field.update` and `updateValue(for:value:)` can swap out every row at once. The
    /// cache is maintained a row at a time, so it has to be rebuilt or the surviving rows
    /// keep results from their old cells and the new rows have none.
    func testReplacingTheWholeValueRefreshesSurvivingAndNewRows() {
        let vm = standardViewModel()
        XCTAssertEqual(result(vm, "row_1", totalID), "6")

        vm.tableDataModel.documentEditor?.updateValue(for: tableFieldID, value: .valueElementArray([
            ValueElement(dictionary: ["_id": "row_1", "cells": [qtyID: 50, priceID: 2]]),
            ValueElement(dictionary: ["_id": "row_9", "cells": [qtyID: 9, priceID: 2]])
        ]))

        XCTAssertEqual(result(vm, "row_1", totalID), "100", "a surviving row recomputes from its new cells")
        XCTAssertEqual(result(vm, "row_9", totalID), "18", "a row that did not exist before gets results")
    }

    func testReplacingTheWholeValueThroughTheChangeAPIRefreshesResults() {
        let vm = standardViewModel()
        let change = change(target: "field.update", payload: ["value": [
            ["_id": "row_1", "cells": [qtyID: 7, priceID: 6]] as [String: Any]
        ]])
        vm.tableDataModel.documentEditor?.change(changes: [change])
        RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))

        XCTAssertEqual(result(vm, "row_1", totalID), "42")
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

    /// `parentPath` is `"<rootRowIndex>.<schemaId>"` — how `insertRow(for:)`/`moveRow(for:)`
    /// find the parent row via `decodeParentPath`. Root-only rows (`parentPath: nil`) skip it.
    private func externalRowCreate(rowID: String, cells: [String: Any], at index: Int,
                                   schemaID: String, parentPath: String? = nil) -> Change {
        var payload: [String: Any] = ["schemaId": schemaID, "targetRowIndex": index,
                                      "row": ["_id": rowID, "cells": cells] as [String: Any]]
        if let parentPath = parentPath { payload["parentPath"] = parentPath }
        return Change(dictionary: [
            "v": 1,
            "sdk": "swift",
            "_id": documentID,
            "identifier": "doc_\(documentID)",
            "target": "field.value.rowCreate",
            "fileId": fileID,
            "pageId": pageID,
            "fieldId": collectionFieldID,
            "fieldIdentifier": "field_\(collectionFieldID)",
            "fieldPositionId": fieldPositionID,
            "change": payload,
            "createdOn": Date().timeIntervalSince1970
        ])
    }

    private func externalRowDelete(rowID: String, schemaID: String) -> Change {
        Change(dictionary: [
            "v": 1,
            "sdk": "swift",
            "_id": documentID,
            "identifier": "doc_\(documentID)",
            "target": "field.value.rowDelete",
            "fileId": fileID,
            "pageId": pageID,
            "fieldId": collectionFieldID,
            "fieldIdentifier": "field_\(collectionFieldID)",
            "fieldPositionId": fieldPositionID,
            "change": ["rowId": rowID, "schemaId": schemaID],
            "createdOn": Date().timeIntervalSince1970
        ])
    }

    private func externalRowMove(rowID: String, to index: Int, schemaID: String, parentPath: String? = nil) -> Change {
        var payload: [String: Any] = ["rowId": rowID, "targetRowIndex": index, "schemaId": schemaID]
        if let parentPath = parentPath { payload["parentPath"] = parentPath }
        return Change(dictionary: [
            "v": 1,
            "sdk": "swift",
            "_id": documentID,
            "identifier": "doc_\(documentID)",
            "target": "field.value.rowMove",
            "fileId": fileID,
            "pageId": pageID,
            "fieldId": collectionFieldID,
            "fieldIdentifier": "field_\(collectionFieldID)",
            "fieldPositionId": fieldPositionID,
            "change": payload,
            "createdOn": Date().timeIntervalSince1970
        ])
    }

    /// The child rows under `parentRowID`, in document order, skipping soft-deleted ones.
    private func childRows(_ editor: DocumentEditor, parentRowID: String, schemaID: String) -> [ValueElement] {
        guard let parent = editor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowID }),
              case .valueElementArray(let children) = parent.childrens?[schemaID]?.value
        else { return [] }
        return children.filter { $0.deleted != true }
    }

    private var oneRootWithOneChild: [[String: Any]] {
        [row("root_1", [qtyID: 2, priceID: 3],
             children: [row("child_1", [qtyID: 4, priceID: 5])])]
    }

    private var oneRootWithTwoChildren: [[String: Any]] {
        [row("root_1", [qtyID: 2, priceID: 3],
             children: [row("child_1", [qtyID: 4, priceID: 5]),
                        row("child_2", [qtyID: 1, priceID: 1])])]
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

    /// Same as the table-level version, for the nested/collection path.
    func testExternalCellChangeFromBackgroundQueueOnANestedRowRecomputesWithoutCrashing() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20")

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            editor.change(changes: [self.externalRowUpdate(rowID: "child_1", cells: [self.qtyID: 10], schemaID: self.childSchema)])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)
        settle() // drain the main-queue hop the background call just scheduled

        XCTAssertEqual(value(vm, "child_1", totalID), "50", "10 * 5")
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "the parent row is untouched")
    }

    /// The new row is never expanded in the view model, so this reads the context directly —
    /// same lookup as `testNestedRowsAreEvaluatedWithoutBuildingAnyCells`.
    func testExternalRowCreateFromBackgroundQueueOnANestedRowRecomputesWithoutCrashing() {
        let (vm, editor) = open(rows: oneRootWithOneChild)

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            editor.change(changes: [self.externalRowCreate(rowID: "child_2", cells: [self.qtyID: 6, self.priceID: 7],
                                                            at: 1, schemaID: self.childSchema, parentPath: "0.\(self.childSchema)")])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        XCTAssertEqual(editor.cellFormulaValue(columnID: totalID, fieldID: collectionFieldID, rowID: "child_2")?.text,
                       "42", "6 * 7, primed as the row is built")
        XCTAssertEqual(value(vm, "root_1", totalID), "6",  "the parent row is untouched")
    }

    func testExternalRowDeleteFromBackgroundQueueOnANestedRowDoesNotCrash() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20", "Before the change")

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            editor.change(changes: [self.externalRowDelete(rowID: "child_1", schemaID: self.childSchema)])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        XCTAssertTrue(childRows(editor, parentRowID: "root_1", schemaID: childSchema).isEmpty,
                      "child_1 must be gone")
        XCTAssertEqual(value(vm, "root_1", totalID), "6", "the parent row's formula is untouched")
    }

    func testExternalRowMoveFromBackgroundQueueOnANestedRowDoesNotCrash() {
        let (vm, editor) = open(rows: oneRootWithTwoChildren)
        XCTAssertEqual(childRows(editor, parentRowID: "root_1", schemaID: childSchema).map { $0.id },
                       ["child_1", "child_2"], "Before the change")

        let dispatched = expectation(description: "background change call returned")
        DispatchQueue.global(qos: .userInitiated).async {
            editor.change(changes: [self.externalRowMove(rowID: "child_2", to: 0, schemaID: self.childSchema,
                                                         parentPath: "0.\(self.childSchema)")])
            dispatched.fulfill()
        }
        wait(for: [dispatched], timeout: 2)

        XCTAssertEqual(childRows(editor, parentRowID: "root_1", schemaID: childSchema).map { $0.id },
                       ["child_2", "child_1"], "child_2 must now lead")
        XCTAssertEqual(value(vm, "child_1", totalID), "20", "moving a row must not disturb its formula")
        XCTAssertEqual(value(vm, "child_2", totalID), "1",  "or the row it passed")
    }

    // MARK: - The document is never written

    func testAColumnDrivenNestedCellStaysNullInTheDocument() {
        let (vm, editor) = open(rows: oneRootWithOneChild)
        XCTAssertEqual(value(vm, "child_1", totalID), "20")

        let rootRows = editor.field(fieldID: collectionFieldID)?.valueToValueElements ?? []
        let child = rootRows.first?.childrens?[childSchema]?.valueToValueElements?.first
        XCTAssertNil(child?.cells?[totalID], "Neither the formula nor the result is written to a nested cell")
    }

    // MARK: - Validation

    /// Validation reads the document, where a column-driven cell is null, so it has to
    /// consult what the cell computes — in nested rows as much as root ones.
    /// Collections are excluded from validation without a licence, so these skip rather
    /// than fail where one is not available.
    private func validity(rootFormula: String, childFormula: String,
                          rows: [[String: Any]]) throws -> ValidationStatus? {
        let license = ProcessInfo.processInfo.environment["JOYFILL_TEST_LICENSE"] ?? licenseKey
        try XCTSkipUnless(LicenseValidator.isCollectionEnabled(licenseToken: license),
                          "No licence, so the collection field is excluded from validation")
        func required(_ columns: [[String: Any]]) -> [[String: Any]] {
            columns.map { c in
                guard c["_id"] as? String == totalID else { return c }
                var copy = c
                copy["required"] = true
                return copy
            }
        }
        let document = editor(rootColumns: required(columns(totalFormula: rootFormula)),
                              childColumns: required(columns(totalFormula: childFormula)),
                              rows: rows).document
        let licensed = DocumentEditor(document: document, validateSchema: false, license: license)
        return licensed.validate().fieldValidities.first(where: { $0.fieldId == collectionFieldID })?.status
    }

    func testARequiredFormulaColumnIsSatisfiedInRootAndNestedRows() throws {
        XCTAssertEqual(try validity(rootFormula: "=A*B", childFormula: "=A*B", rows: oneRootWithOneChild),
                       .valid, "Both rows compute a value even though both cells are null")
    }

    func testARequiredFormulaColumnIsUnsatisfiedWhenANestedRowComputesNothing() throws {
        XCTAssertEqual(try validity(rootFormula: "=A*B", childFormula: "=\"\"", rows: oneRootWithOneChild),
                       .invalid, "The nested row's formula produces nothing")
    }

    func testARequiredFormulaColumnIsUnsatisfiedWhenANestedFormulaFails() throws {
        XCTAssertEqual(try validity(rootFormula: "=A*B", childFormula: "=A *", rows: oneRootWithOneChild),
                       .invalid, "Error is not a value")
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
