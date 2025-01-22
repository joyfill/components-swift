//
//  DocumentEditor+ChangeHandlerTests.swift
//  JoyfillTests
//
//  Created by Vivek on 21/01/25.
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class DocumentEditorChangeHandlerTests: XCTestCase {
    let fileID = "66a0fdb2acd89d30121053b9"
    let pageID = "66aa286569ad25c65517385e"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document)
    }
    // Delete Row tests
    func testDeleteRow() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default 
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433d","67612793a6cd1f9d39c8433b"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 2)
        //2 rows should left
    }
    // Duplicate row tests
    func testDuplicateRow() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //5 RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 5)
        //5 rows should left
    }
    // Move row up tests
    func testMoveRowUp() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793a6cd1f9d39c8433d"), 3)// Row up and index should be 3 now
    }
    // Move row down tests
    func testMoveRowDown() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowDown(rowID: "676127938056dcd158942bad", fieldIdentifier: fieldIdentifier)// Current index = 0
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "676127938056dcd158942bad"), 1)// Row Down and index should be 1 now
    }
    //Insert Below tests
    func testInsertBelow() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
        
        //Table columns Ids
        _ = [
            "676127938fb7c5fd4321a2f4",
            "67612793b5f860ae8d6a4ae6",
            "67612793c76286eb2763c366"
        ]
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
        
        let insertedRow = documentEditor.insertBelow(selectedRowID: "676127938056dcd158942bad", cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, 6) // Total rows count should 6 now
        
        //check row index
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: (insertedRow?.0.id)!), 1)
        
        //check Cell value
        let targetRow = field?.valueToValueElements?.first(where: { valueElement in
            valueElement.id == (insertedRow?.0.id)!
        })
        let targetCellValue = targetRow?.cells?["676127938fb7c5fd4321a2f4"]?.text
        
        XCTAssertEqual(targetCellValue, "Hello")
                                                           
    }
    
    //InsertRow WithFilter tests
    func testInsertRowWitFilter() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        _ = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
        
        //Table columns Ids
        _ = [
            "676127938fb7c5fd4321a2f4",
            "67612793b5f860ae8d6a4ae6",
            "67612793c76286eb2763c366"
        ]
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
        let newRowId = "67612793a6cd1f9d39c8434er"
        let insertedRow = documentEditor.insertRowWithFilter(id: newRowId, cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, 6) // Total rows count should 6 now
        
        //check row index
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: (insertedRow?.id)!), 5)
        
        //check Cell value
        let targetRow = field?.valueToValueElements?.first(where: { valueElement in
            valueElement.id == (insertedRow?.id)!
        })
        let targetCellValue = targetRow?.cells?["676127938fb7c5fd4321a2f4"]?.text
        
        XCTAssertEqual(targetCellValue, "Hello")
                                                           
    }
    
    //Bulk edit tests
    func testBulkEdit() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
        //RowIds
        let rowIds = [
            "676127938056dcd158942bad",
            "67612793f70928da78973744",
            "67612793a6cd1f9d39c8433b",
            "67612793a6cd1f9d39c8433c",// deleted
            "67612793a6cd1f9d39c8433d"
        ]
        // 5 total rows , 1 deleted by default
        
        //Table columns Ids
        let columnIds = [
            "676127938fb7c5fd4321a2f4",
            "67612793b5f860ae8d6a4ae6",
            "67612793c76286eb2763c366"
        ]
                
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        
        let changes: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Hello sir"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        documentEditor.bulkEdit(changes: changes, selectedRows: rowIds, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        for row in field?.valueToValueElements ?? [] {
            XCTAssertEqual(row.cells?[columnIds[0]], .string("Hello sir"))
            XCTAssertEqual(row.cells?[columnIds[1]], .string("67612793a4c7301ba4da1d69"))
            XCTAssertEqual(row.cells?[columnIds[2]], .double(1712385780000))
        }
    }
}
