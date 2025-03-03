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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433d","67612793a6cd1f9d39c8433b"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 2)
        //2 rows should left
    }
    
    // Pass row id empty in parameter
    func testDeleteRowIdEmpty() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        // Pass row id empty
        documentEditor.deleteRows(rowIDs: [], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 4)
        //4 rows should left - No row deleted
    }
    
    // Pass Different row id in parameter - diff from rowmodel
    func testDeleteDifferentRowId() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        // Pass row id empty
        documentEditor.deleteRows(rowIDs: ["ID"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 4)
        //4 rows should left - No row deleted
    }
    
    // Set Roworder to nil - set true to isRowOrderNil
    func testDeleteRowOrderToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: true)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //4 rows should left - No row deleted
        XCTAssertEqual(field?.value?.valueElements?.filter({ row in
            !(row.deleted ?? true)
        }).count, 4)
        
        XCTAssertEqual(field?.rowOrder?.count, nil)
    }
    
    // Set value to nil - set true to isZeroRows
    func testSetDeleteValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433b"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        // Row order count now 6 , +1 after duplicate
        XCTAssertEqual(field?.rowOrder?.count, 6)
        
        // Check new duplicate row id is nil or not
        let duplicatedRowID = field?.rowOrder?[5]
        XCTAssertNotNil(duplicatedRowID)
    }
    
    // Set value to nil - set true to isZeroRows
    func testSetDuplicateValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
        // Row order count remain same
        XCTAssertEqual(field?.rowOrder?.count, 5)
    }
    
    // Set Roworder to nil - set true to isRowOrderNil
    func testSetDuplicateRowOrderToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: true)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.count, nil)
    }
    
    // Pass different row id - when row id not match for duplicate
    func testPassDifferentDuplicateRowId() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        documentEditor.duplicateRows(rowIDs: ["ID"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
        let field = documentEditor.field(fieldID: tableFieldID)
        
        // Row order count remain same
        XCTAssertEqual(field?.rowOrder?.count, 5)
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793a6cd1f9d39c8433d"), 3)// Row up and index should be 3 now
    }
    
    // Set value to nil - set true to isZeroRows
    func testSetMoveUpRowValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793f70928da78973744"), 1)// Row not up
    }
    
    // Set Roworder to nil - set true to isRowOrderNil
    func testSetMoveUpRowRowOrderToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: true)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.count, nil)
    }
    
    // Move up First row - result not move
    func testMoveUpFirstRow() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowUp(rowID: "676127938056dcd158942bad", fieldIdentifier: fieldIdentifier)// Current index = 0
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "676127938056dcd158942bad"), 0)// Row not up
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowDown(rowID: "676127938056dcd158942bad", fieldIdentifier: fieldIdentifier)// Current index = 0
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "676127938056dcd158942bad"), 1)// Row Down and index should be 1 now
    }
    
    // Move Down last row - result not move
    func testMoveDownLastRow() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793a6cd1f9d39c8433d"), 4)// Row not up
    }
    
    // Set value to nil - set true to isZeroRows
    func testSetMoveDownRowValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793f70928da78973744"), 1)// Row not up
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: "67612793a6cd1f9d39c8433c"), 3)
    }
    
    // Set Roworder to nil - set true to isRowOrderNil
    func testSetMoveDwonRowRowOrderToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: true)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
        let field = documentEditor.field(fieldID: tableFieldID)
        
        XCTAssertEqual(field?.rowOrder?.count, nil)
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
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
    
    // Set value to nil - set true to isZeroRows
    func testInsertBelowValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
        
        _ = documentEditor.insertBelow(selectedRowID: "676127938056dcd158942bad", cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, 5) // Same row count
        
        // Check value is nil
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
    }
    
    // Set Roworder to nil - set true to isRowOrderNil
    func testInsertBelowRowOrderToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: true)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
        
        _ = documentEditor.insertBelow(selectedRowID: "676127938056dcd158942bad", cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, nil)
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
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
    
    //InsertRow WithFilter tests
    func testInsertRowWitFilterValueIsNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
        let newRowId = "67612793a6cd1f9d39c8434er"
        let insertedRow = documentEditor.insertRowWithFilter(id: newRowId, cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, 5) // Total rows count should 6 now
        
        // Check value is nil
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
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
    
    // Set value to nil - set isZeroRows true
    func testBulkEditValueToNil() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
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
        
        // Check value is nil
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
    }
    
    // Pass different row id - when row id not match for bulk edit
    func testBulkEditPassDifferentRowId() {
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
            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: false, isColumnsZero: false, isRowOrderNil: false)
            .setTableFieldPosition(hideColumn: false)
        
        let documentEditor = documentEditor(document: document)
        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        
        let changes: [String: ValueUnion] = [
            "676127938fb7c5fd4321a2f4": ValueUnion.string("Hello sir"),
            "67612793b5f860ae8d6a4ae6": ValueUnion.string("67612793a4c7301ba4da1d69"),
            "67612793c76286eb2763c366": ValueUnion.double(1712385780000)
        ]
        // Pass different row id - when row id not match for bulk edit
        documentEditor.bulkEdit(changes: changes, selectedRows: ["rowIds"], fieldIdentifier: fieldIdentifier)
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        let row = field?.valueToValueElements
        XCTAssertEqual(row?[0].cells?["676127938fb7c5fd4321a2f4"]?.text, "Value for Row 1, Column 1")
        XCTAssertEqual(row?[0].cells?["67612793b5f860ae8d6a4ae6"]?.text, "67612793a4c7301ba4da1d69")
        XCTAssertEqual(row?[0].cells?["67612793c76286eb2763c366"]?.number, 1712385780000)
    }
}
