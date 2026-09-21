//
//  SwiftUIView.swift
//  
//
//  Created by Nand Kishore on 20/03/24.
//

import SwiftUI

struct TableTextView: View {
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.navigationFocusColumnId) private var navigationFocusColumnId
    @Binding var cellModel: TableCellModel
    /// Pulled by the cell builder. Passing it in is what lets SwiftUI see it change.
    let formulaValue: CellFormulaValue?

    public init(cellModel: Binding<TableCellModel>, formulaValue: CellFormulaValue? = nil) {
        _cellModel = cellModel
        self.formulaValue = formulaValue
    }
    
    var body: some View {
        if cellModel.viewMode == .quickView {
            Text(formulaValue?.text ?? cellModel.data.title)
                .font(.system(size: 15))
                .lineLimit(1)
                .accessibilityIdentifier("TableTextFieldIdentifierReadonly")
        } else if cellModel.editMode == .readonly {
            ScrollView {
                Text(formulaValue?.text ?? cellModel.data.title)
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("TableTextFieldIdentifierReadonly")
                    .disabled(true)
            }
            .environment(\.isEnabled, true)
            .accessibilityIdentifier("TableTextFieldReadonlyScrollView")
        } else {
            if #available(iOS 16.0, *) {
                TextEditor(text: $cellModel.data.title)
                    .foregroundColor(showsResult ? .clear : .primary)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .onChange(of: cellModel.data.title) { _ in
                        updateFieldValue()
                    }
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { focused in
                        if focused {
                            // The column's formula edits like one typed into the cell.
                            if cellModel.data.title.isEmpty, let formula = cellModel.data.columnFormula {
                                cellModel.data.title = formula
                            }
                            cellModel.didFocusBlur?(.focus, cellModel.data)
                        } else {
                            cellModel.didFocusBlur?(.blur, cellModel.data)
                        }
                    }
                    .onAppear { autoFocusIfNeeded() }
                    .overlay(resultOverlay())
            } else {
                TextEditor(text: $cellModel.data.title)
                    .foregroundColor(showsResult ? .clear : .primary)
                    .font(.system(size: 15))
                    .accessibilityIdentifier("TabelTextFieldIdentifier")
                    .onChange(of: cellModel.data.title) { _ in
                        updateFieldValue()
                    }
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { focused in
                        if focused {
                            // The column's formula edits like one typed into the cell.
                            if cellModel.data.title.isEmpty, let formula = cellModel.data.columnFormula {
                                cellModel.data.title = formula
                            }
                            cellModel.didFocusBlur?(.focus, cellModel.data)
                        } else {
                            cellModel.didFocusBlur?(.blur, cellModel.data)
                        }
                    }
                    .onAppear { autoFocusIfNeeded() }
                    .overlay(resultOverlay())
            }
        }
    }
    
    /// `true` while an unfocused formula cell should show its result instead of its text.
    private var showsResult: Bool {
        formulaValue != nil && !isTextFieldFocused
    }

    @ViewBuilder
    private func resultOverlay() -> some View {
        if showsResult {
            Text(formulaValue?.text ?? "")
                .font(.system(size: 15))
                .foregroundColor(formulaValue?.isError == true ? .red : .primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 5)
                .padding(.vertical, 8)
                .allowsHitTesting(false)
                .accessibilityIdentifier("TableFormulaCellIdentifier")
        }
    }

    private func autoFocusIfNeeded() {
        if navigationFocusColumnId == cellModel.data.id {
            isTextFieldFocused = true
        }
    }
    
    func updateFieldValue() {
        // Showing the column's formula is not an edit. Until the author changes it the
        // cell still holds nothing, so nothing is written.
        guard cellModel.data.title != cellModel.data.columnFormula else { return }
        cellModel.didChange?(cellModel.data)
    }
}
