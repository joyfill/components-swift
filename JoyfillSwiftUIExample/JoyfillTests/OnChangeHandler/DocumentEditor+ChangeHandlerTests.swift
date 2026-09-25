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
    let collectionFieldID = "67ddc52d35de157f6d7ebb63"
    
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, config: DocumentEditorConfig(validateSchema: false))
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
        _ = documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433d","67612793a6cd1f9d39c8433b"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.deleteRows(rowIDs: [], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.deleteRows(rowIDs: ["ID"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.deleteRows(rowIDs: ["67612793a6cd1f9d39c8433b"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.duplicateRows(rowIDs: ["67612793a6cd1f9d39c8433d"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.duplicateRows(rowIDs: ["ID"], fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID))
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
        _ = documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        _ = documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        _ = documentEditor.moveRowUp(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        _ = documentEditor.moveRowUp(rowID: "676127938056dcd158942bad", fieldIdentifier: fieldIdentifier)// Current index = 0
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
        _ = documentEditor.moveRowDown(rowID: "676127938056dcd158942bad", fieldIdentifier: fieldIdentifier)// Current index = 0
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
        _ = documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        _ = documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        _ = documentEditor.moveRowDown(rowID: "67612793a6cd1f9d39c8433d", fieldIdentifier: fieldIdentifier)// Current index = 4
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
        let result = documentEditor.insertRowWithFilter(id: newRowId, cellValues: cellValues, fieldIdentifier: fieldIdentifier)
        let insertedRow = result.1
        let field = documentEditor.field(fieldID: tableFieldID)
        
        //check row order
        XCTAssertEqual(field?.rowOrder?.count, 6) // Total rows count should 6 now
        
        //check row index
        XCTAssertEqual(field?.rowOrder?.firstIndex(of: (insertedRow.id)!), 5)
        
        //check Cell value
        let targetRow = field?.valueToValueElements?.first(where: { valueElement in
            valueElement.id == (insertedRow.id)!
        })
        let targetCellValue = targetRow?.cells?["676127938fb7c5fd4321a2f4"]?.text
        
        XCTAssertEqual(targetCellValue, "Hello")
                                                           
    }
    
    //InsertRow WithFilter tests
//    func testInsertRowWitFilterValueIsNil() {
//        let tableFieldID = "67612793c4e6a5e6a05e64a3"
//        //RowIds
//        _ = [
//            "676127938056dcd158942bad",
//            "67612793f70928da78973744",
//            "67612793a6cd1f9d39c8433b",
//            "67612793a6cd1f9d39c8433c",// deleted
//            "67612793a6cd1f9d39c8433d"
//        ]
//        // 5 total rows , 1 deleted by default
//        
//        //Table columns Ids
//        _ = [
//            "676127938fb7c5fd4321a2f4",
//            "67612793b5f860ae8d6a4ae6",
//            "67612793c76286eb2763c366"
//        ]
//                
//        let document = JoyDoc()
//            .setDocument()
//            .setFile()
//            .setMobileView()
//            .setPageFieldInMobileView()
//            .setPageField()
//            .setRequiredTableField(hideColumn: false, isTableRequired: false, isColumnRequired: false, areCellsEmpty: false, isZeroRows: true, isColumnsZero: false, isRowOrderNil: false)
//            .setTableFieldPosition(hideColumn: false)
//        
//        let documentEditor = documentEditor(document: document)
//        let fieldIdentifier = FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
//        let cellValues: [String: ValueUnion] = ["676127938fb7c5fd4321a2f4": .string("Hello")]
//        let newRowId = "67612793a6cd1f9d39c8434er"
//        let insertedRow = documentEditor.insertRowWithFilter(id: newRowId, cellValues: cellValues, fieldIdentifier: fieldIdentifier)
//        
//        let field = documentEditor.field(fieldID: tableFieldID)
//        
//        //check row order
//        XCTAssertEqual(field?.rowOrder?.count, 5) // Total rows count should 6 now
//        
//        // Check value is nil
//        XCTAssertEqual(field?.value?.valueElements?.count, nil)
//    }
    
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
        var newChanges: [String: [String: ValueUnion]] = [:]
        for rowId in rowIds {
            newChanges[rowId] = changes
        }
        let field2 = documentEditor.field(fieldID: tableFieldID)
        
        documentEditor.bulkEdit(changes: newChanges, selectedRows: rowIds, fieldIdentifier: fieldIdentifier, fieldData: field2?.valueToValueElements ?? [])
        
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

//        //Table columns Ids
//        let columnIds = [
//            "676127938fb7c5fd4321a2f4",
//            "67612793b5f860ae8d6a4ae6",
//            "67612793c76286eb2763c366"
//        ]

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
        var newChanges: [String: [String: ValueUnion]] = [:]
        for rowId in rowIds {
            newChanges[rowId] = changes
        }
        let field2 = documentEditor.field(fieldID: tableFieldID)
        
        documentEditor.bulkEdit(changes: newChanges, selectedRows: rowIds, fieldIdentifier: fieldIdentifier, fieldData: field2?.valueToValueElements ?? [])
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        // Check value is nil
        XCTAssertEqual(field?.value?.valueElements?.count, nil)
    }
    
    // Pass different row id - when row id not match for bulk edit
    func testBulkEditPassDifferentRowId() {
        let tableFieldID = "67612793c4e6a5e6a05e64a3"
//        //RowIds
//        let rowIds = [
//            "676127938056dcd158942bad",
//            "67612793f70928da78973744",
//            "67612793a6cd1f9d39c8433b",
//            "67612793a6cd1f9d39c8433c",// deleted
//            "67612793a6cd1f9d39c8433d"
//        ]
//        // 5 total rows , 1 deleted by default
//
//        //Table columns Ids
//        let columnIds = [
//            "676127938fb7c5fd4321a2f4",
//            "67612793b5f860ae8d6a4ae6",
//            "67612793c76286eb2763c366"
//        ]

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
        let field2 = documentEditor.field(fieldID: tableFieldID)
        documentEditor.bulkEdit(changes: ["rowIds" : changes], selectedRows: ["rowIds"], fieldIdentifier: fieldIdentifier, fieldData: field2?.valueToValueElements ?? [])
        
        let field = documentEditor.field(fieldID: tableFieldID)
        
        let row = field?.valueToValueElements
        XCTAssertEqual(row?[0].cells?["676127938fb7c5fd4321a2f4"]?.text, "Value for Row 1, Column 1")
        XCTAssertEqual(row?[0].cells?["67612793b5f860ae8d6a4ae6"]?.text, "67612793a4c7301ba4da1d69")
        XCTAssertEqual(row?[0].cells?["67612793c76286eb2763c366"]?.number, 1712385780000)
    }
}
// MARK: - Collection (Nested Table) Tests
extension DocumentEditorChangeHandlerTests {
    
    func testDeleteNestedCollectionItem() {
        // Setup: use a document that has a nested collection in one of its rows.
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615" // a parent row that contains nested rows
        let nestedKey = "67ddc5c9910a394a1324bfbe" // key under which nested rows are stored
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Fetch the parent element and its nested children.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let initialNestedRows = children.valueToValueElements else {
            XCTFail("Nested rows not found in parent")
            return
        }
        
        // Delete one nested row (for example, the last one).
        let rowToDelete = initialNestedRows.last!.id!
        _ = documentEditor.deleteNestedRows(rowIDs: [rowToDelete],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)
        
        // Fetch the parent's nested rows again.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        XCTAssertEqual(updatedNestedRows.filter { !($0.deleted ?? false) }.count, initialNestedRows.count - 1)
    }
    
    // Deleting only a non-existent rowID must leave the document untouched and emit no rowDelete event.
    func testDeleteNonExistingRowNestedCollectionItem() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        let nonExistingRowID = "non-existing-row-id"

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        let initialElements = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements

        _ = documentEditor.deleteNestedRows(rowIDs: [nonExistingRowID],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        XCTAssertEqual(documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements, initialElements,
                       "Field elements must be untouched when rowID doesn't exist")
        XCTAssertEqual(events.onChangeCallCount, 0,
                       "onChange must not fire at all when the rowID doesn't exist")
        XCTAssertTrue(captured.isEmpty)
    }

    // Bulk delete with a mix of existing and non-existing rowIDs: only the existing ones get a rowDelete event,
    // and the document only loses the existing ones.
    func testBulkDeleteNestedCollectionItemsWithOneNonExistingRowID() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        let existingRowID = "67ddd18bc3a74e6b350987f9"
        let nonExistingRowID = "non-existing-row-id"

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        _ = documentEditor.deleteNestedRows(rowIDs: [existingRowID, nonExistingRowID],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        // Only the existing row gets removed from the tree.
        let nestedRows = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?
            .first(where: { $0.id == parentRowId })?.childrens?[nestedKey]?.valueToValueElements ?? []
        XCTAssertNil(nestedRows.first(where: { $0.id == existingRowID }),
                     "Existing row should be removed from the nested children")

        // Exactly one rowDelete event fires, for the existing row only.
        let deleteEvents = captured.filter { $0.target == "field.value.rowDelete" }
        XCTAssertEqual(deleteEvents.count, 1, "Only one rowDelete event should fire (for the existing row)")
        XCTAssertEqual(deleteEvents.first?.change?["rowId"] as? String, existingRowID)
        XCTAssertFalse((deleteEvents.first?.change?["row"] as? [String: Any])?.isEmpty ?? true,
                       "Embedded row payload must be non-empty for the existing row")
    }

    // Bulk delete with all rowIDs valid: one rowDelete event per row, each with its own payload.
    func testBulkDeleteNestedCollectionItemsAllExisting() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        let rowIDs = ["67ddd18bc3a74e6b350987f9", "67ddd193eae737b64c24851a"]

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        _ = documentEditor.deleteNestedRows(rowIDs: rowIDs,
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        // Both rows are gone from the tree.
        let nestedRows = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?
            .first(where: { $0.id == parentRowId })?.childrens?[nestedKey]?.valueToValueElements ?? []
        for id in rowIDs {
            XCTAssertNil(nestedRows.first(where: { $0.id == id }), "Row \(id) should be removed")
        }

        // One rowDelete event per row, in input order, each with a non-empty payload.
        let deleteEvents = captured.filter { $0.target == "field.value.rowDelete" }
        XCTAssertEqual(deleteEvents.count, rowIDs.count, "One rowDelete event per deleted row")
        XCTAssertEqual(deleteEvents.compactMap { $0.change?["rowId"] as? String }, rowIDs,
                       "Events should be emitted in the same order as the input rowIDs")
        for event in deleteEvents {
            XCTAssertFalse((event.change?["row"] as? [String: Any])?.isEmpty ?? true,
                           "Embedded row payload must be non-empty for each deleted row")
        }
    }

    // Duplicate rowIDs in the input must produce a single rowDelete event (the second occurrence
    // can't find the already-removed row and is filtered out before emit).
    func testBulkDeleteNestedCollectionItemsWithDuplicateRowIDs() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        let duplicatedRowID = "67ddd18bc3a74e6b350987f9"

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        _ = documentEditor.deleteNestedRows(rowIDs: [duplicatedRowID, duplicatedRowID],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        let deleteEvents = captured.filter { $0.target == "field.value.rowDelete" }
        XCTAssertEqual(deleteEvents.count, 1, "Duplicate rowIDs must collapse into a single rowDelete event")
        XCTAssertEqual(deleteEvents.first?.change?["rowId"] as? String, duplicatedRowID)
    }

    // The embedded row payload in a nested rowDelete change must carry "deleted": true,
    // matching the top-level deleteRows path. The snapshot is mutated via setDeleted() on the
    // removed copy in deleteNestedRows; the underlying data is untouched (already removed).
    func testDeleteNestedCollectionItemPayloadMarksDeletedTrue() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        let rowToDelete = "67ddd18bc3a74e6b350987f9"

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        _ = documentEditor.deleteNestedRows(rowIDs: [rowToDelete],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        let deleteEvents = captured.filter { $0.target == "field.value.rowDelete" }
        XCTAssertEqual(deleteEvents.count, 1)
        let row = deleteEvents.first?.change?["row"] as? [String: Any]
        XCTAssertEqual(row?["deleted"] as? Bool, true, "Embedded row payload must record deleted: true")
    }

    // Deleting an L1 row that owns L2 grandchildren must surface the full subtree in the
    // rowDelete change-log payload. The previous test only covers leaf deletion.
    func testDeleteNestedCollectionItemPayloadIncludesSubtree() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"          // root row owning the L1 schema
        let nestedKey = "67ddc5c9910a394a1324bfbe"            // L1 schema key
        let rowToDelete = "67ddd191ab6a428ea69c77ad"          // L1 row with three L2 grandchildren
        let grandchildSchemaKey = "67ddc5f5c2477e8457956fb4"  // L2 schema key under the deleted row
        let expectedGrandchildIDs: Set<String> = [
            "67ddd1a5e6d0d62d55a7aaad",
            "67ddd1a656a259a9b6ab1263",
            "67ddd1a779642224075bf23c"
        ]

        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        var captured: [Change] = []
        let events = CaptureChangeHandler { changes, _ in captured.append(contentsOf: changes) }
        let documentEditor = DocumentEditor(document: document, config: DocumentEditorConfig(events: events, validateSchema: false))

        _ = documentEditor.deleteNestedRows(rowIDs: [rowToDelete],
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            rootSchemaKey: collectionFieldID,
                                            nestedKey: nestedKey,
                                            parentRowId: parentRowId)

        let deleteEvents = captured.filter { $0.target == "field.value.rowDelete" }
        XCTAssertEqual(deleteEvents.count, 1, "Expected exactly one rowDelete change")

        guard let change = deleteEvents.first?.change,
              let row = change["row"] as? [String: Any] else {
            return XCTFail("Missing row payload in rowDelete change")
        }
        XCTAssertEqual(row["_id"] as? String, rowToDelete)

        guard let children = row["children"] as? [String: Any],
              let nestedSchema = children[grandchildSchemaKey] as? [String: Any],
              let grandchildren = nestedSchema["value"] as? [[String: Any]] else {
            return XCTFail("Deleted row payload should embed the L2 subtree under children[\(grandchildSchemaKey)].value")
        }
        let ids = Set(grandchildren.compactMap { $0["_id"] as? String })
        XCTAssertEqual(ids, expectedGrandchildIDs, "All L2 grandchildren must appear in the embedded subtree")
    }

    func testDuplicateNestedCollectionItem() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Get the parent's nested rows.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let initialNestedRows = children.valueToValueElements else {
            XCTFail("Nested rows not found in parent")
            return
        }
        
        // Duplicate the first nested row.
        let nestedRowIdToDuplicate = initialNestedRows.first!.id!
        _ = documentEditor.duplicateNestedRows(selectedRowIds: [nestedRowIdToDuplicate],
                                               fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                               rootSchemaKey: collectionFieldID,
                                               nestedKey: nestedKey,
                                               parentRowId: parentRowId)
        
        // Check that the count increased by one.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        XCTAssertEqual(updatedNestedRows.count, initialNestedRows.count + 1)
    }
    
    func testMoveNestedCollectionItemUp() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Get the nested rows from the parent.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let nestedRows = children.valueToValueElements,
              nestedRows.count >= 2 else {
            XCTFail("Not enough nested rows for move up test")
            return
        }
        
        // Move the last nested row up.
        let rowIdToMove = nestedRows.last!.id!
        _ = documentEditor.moveNestedRowUp(rowID: rowIdToMove,
                                           fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                           rootSchemaKey: collectionFieldID,
                                           nestedKey: nestedKey,
                                           parentRowId: parentRowId)
        
        // Fetch updated nested rows.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        // Verify that the moved row is no longer the last.
        XCTAssertFalse(updatedNestedRows.last!.id == rowIdToMove)
    }
    
    func testMoveNestedCollectionItemDown() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Get the parent's nested rows.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let nestedRows = children.valueToValueElements,
              nestedRows.count >= 2 else {
            XCTFail("Not enough nested rows for move down test")
            return
        }
        
        // Move the first nested row down.
        let rowIdToMove = nestedRows.first!.id!
        _ = documentEditor.moveNestedRowDown(rowID: rowIdToMove,
                                             fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                             rootSchemaKey: collectionFieldID,
                                             nestedKey: nestedKey,
                                             parentRowId: parentRowId)
        
        // Fetch updated nested rows.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        // Verify that the moved row is no longer the first.
        XCTAssertFalse(updatedNestedRows.first!.id == rowIdToMove)
    }
    
    func testInsertBelowNestedCollectionItem() {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Get the parent's nested rows before insertion.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let initialNestedRows = children.valueToValueElements else {
            XCTFail("Nested rows not found")
            return
        }
        
        // Insert a new nested row below the first nested row.
        let cellValues: [String: ValueUnion] = ["dummyKey": .string("New Nested Item")]
        guard documentEditor.insertBelowNestedRow(selectedRowID: initialNestedRows.first!.id!,
                                                 cellValues: cellValues,
                                                 fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                                 childrenKeys: [nestedKey],
                                                 rootSchemaKey: collectionFieldID,
                                                 nestedKey: nestedKey,
                                                 parentRowId: parentRowId, fieldData: field.valueToValueElements ?? []) != nil else {
            XCTFail("Insertion failed")
            return
        }
        
        // Verify that the nested rows count increased by one.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        XCTAssertEqual(updatedNestedRows.count, initialNestedRows.count + 1)
        
        // Verify that the new nested row is inserted immediately after the selected one.
        if let firstIndex = updatedNestedRows.firstIndex(where: { $0.id == initialNestedRows.first!.id }),
           let newIndex = updatedNestedRows.firstIndex(where: { $0.cells?["dummyKey"] == .string("New Nested Item") }) {
            XCTAssertEqual(newIndex, firstIndex + 1)
        } else {
            XCTFail("New nested item not found in expected position")
        }
    }
    
    func testBulkEditNestedCollection() async {
        let collectionFieldID = "67ddc52d35de157f6d7ebb63"
        let parentRowId = "67ddc537b7c2fce05d0c8615"
        let nestedKey = "67ddc5c9910a394a1324bfbe"
        
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let documentEditor = self.documentEditor(document: document)
        
        // Get the parent's nested rows.
        guard let field = documentEditor.field(fieldID: collectionFieldID),
              let parentElement = field.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let children = parentElement.childrens?[nestedKey],
              let initialNestedRows = children.valueToValueElements else {
            XCTFail("Nested rows not found")
            return
        }
        
        // Bulk edit: update a specific cell for all nested rows.
        let changes: [String: ValueUnion] = ["67ddc5adbb96a9b9f9ff1480": .string("Updated Nested")]
        var newChanges: [String: [String: ValueUnion]] = [:]
        let nestedRowIds = initialNestedRows.map { $0.id! }
        for nestedRowId in nestedRowIds {
            newChanges[nestedRowId] = changes
        }
        _ = documentEditor.bulkEditForNested(changes: newChanges,
                                            selectedRows: nestedRowIds,
                                            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                            parentRowId: parentRowId,
                                            nestedKey: nestedKey,
                                            rootSchemaKey: collectionFieldID,
                                                   isRootRow: false,
                                                   fieldvalue: field.valueToValueElements ?? [])
        // Fetch the nested rows again.
        guard let updatedParent = documentEditor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == parentRowId }),
              let updatedChildren = updatedParent.childrens?[nestedKey],
              let updatedNestedRows = updatedChildren.valueToValueElements else {
            XCTFail("Updated nested rows not found")
            return
        }
        
        for row in updatedNestedRows {
            XCTAssertEqual(row.cells?["67ddc5adbb96a9b9f9ff1480"], .string("Updated Nested"))
        }
    }
    
    func testCollectionFieldConditionalLogicShow() {
        // Create a document with a collection field.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Define a logic dictionary that should show the schema.
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "or",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "joyfill",
                    "condition": "="
                ],
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db898e2fb0ad3a8d19",
                    "value": "67ddc4db77b4a1f62ae14cbd",
                    "condition": "="
                ]
            ],
            "_id": "test_logic_show_id"
        ]
        
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance for show action")
            return
        }
        
        // Update the document by setting conditional logic in the collection field.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        
        // Obtain the DocumentEditor.
        let editor = documentEditor(document: updatedDoc)
        
        // For testing, we use the first value element's row id as our row of interest.
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }
        
        // Create a RowSchemaID for the root schema key (here assumed to be "collectionSchemaId")
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionFieldConditionalLogicHide() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "",
                    "condition": "="
                ]
            ],
            "_id": "test_logic_hide_id"
        ]
        
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance for hide action")
            return
        }
        
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }
        //first row text cell value is nil
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let shouldShow = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertEqual(shouldShow, true)
    }
    
    func testCollectionFieldConditionalLogicNil() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Call with nil logic.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "collectionSchemaId", logic: nil)
        let editor = documentEditor(document: updatedDoc)
        
        // Use the first value element's row id for testing.
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }
        
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        // With nil logic applied, we expect the default (visible) behavior.
        XCTAssertTrue(isVisible, "When nil logic is passed, the collection schema should default to visible.")
    }
    
    // MARK: - Conditional Logic Tests on Collection Schema
    
    func testConditionalLogicOnRootSchemaKey_Show() {
        // Create a document with a collection field.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Define a logic that would mark the root schema as visible (action: "show").
        let logicDict: [String: Any] = [
            "action": "show",
            "eval": "or",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "joyfill",
                    "condition": "="
                ]
            ],
            "_id": "logic_root_show"
        ]
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance.")
            return
        }
        
        // Apply the logic on the root schema key.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        // For testing, use the first row of the collection value.
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or value elements not found.")
            return
        }
        
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertTrue(isVisible, "The root schema should be visible for 'show' logic.")
    }
    
    func testConditionalLogicOnChildSchemaKey_Hide() {
        // Create a document with a collection field.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Define a logic that would mark a child schema as hidden (action: "hide").
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "67ddc5c9910a394a1324bfbe",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "",
                    "condition": "="
                ]
            ],
            "_id": "logic_child_hide"
        ]
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance for child hide logic.")
            return
        }
        
        // Apply the logic on the child schema key.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found.")
            return
        }
        
        // In this test, note that the logic is applied to the child schema key.
        // We check the visibility of the root schema ("collectionSchemaId") remains unaffected.
        let rootRowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let isRootVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rootRowSchemaID)
        // Assuming default behavior is visible at root.
        XCTAssertTrue(isRootVisible, "The root schema should remain visible.")
        
        // Now check the child schema key.
        let childRowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isChildVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: childRowSchemaID)
        XCTAssertEqual(isChildVisible, true)
    }
    
    func testConditionalLogicWithNilLogic() {
        // Create a document with a collection field.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Apply nil logic on the root schema key.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "collectionSchemaId", logic: nil)
        let editor = documentEditor(document: updatedDoc)
        
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found.")
            return
        }
        
        // With nil logic, default behavior should prevail (assume visible).
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertTrue(isVisible, "With nil logic, the schema should default to visible.")
    }
    
    func testConditionalLogicOnNonexistentSchemaKey() {
        // Create a document with a collection field.
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        // Define a logic for a schema key that does not exist.
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "nonexistentSchemaKey",
                    "column": "someColumnID",
                    "value": "anyValue",
                    "condition": "="
                ]
            ],
            "_id": "logic_nonexistent"
        ]
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance for nonexistent schema key.")
            return
        }
        
        // Apply logic on a nonexistent schema key. In this case, nothing should change.
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "nonexistentSchemaKey", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        // Use the root schema key to test default behavior.
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found.")
            return
        }
        
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        // Expecting default visible (unchanged) since our logic was applied to a key that doesn't exist.
        XCTAssertTrue(isVisible, "Applying logic on a nonexistent schema key should not affect default visibility.")
    }
    
    func testCollectionFieldConditionalLogicWithGreaterThanOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc59c4aba2df34a6dd1c4",
                    "value": ValueUnion.double(100),
                    "condition": ">"
                ]
            ],
            "_id": "test_logic_gt"
        ]
        
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance")
            return
        }
        
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }
        
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionFieldConditionalLogicWithNotEqualsOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        
        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "hideMe",
                    "condition": "!="
                ]
            ],
            "_id": "test_logic_neq"
        ]
        
        guard let logic = Logic(field: logicDict) else {
            XCTFail("Failed to create Logic instance")
            return
        }
        
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)
        
        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }
        
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionConditionalLogicContainsOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc4db157f14f67da0616a",
                    "value": "joy",
                    "condition": "?="
                ]
            ],
            "_id": "test_logic_contains"
        ]

        guard let logic = Logic(field: logicDict) else { XCTFail("Logic creation failed"); return }
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)

        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }

        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionConditionalLogicLessThanOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc59c4aba2df34a6dd1c4",
                    "value": ValueUnion.double(500),
                    "condition": "<"
                ]
            ],
            "_id": "test_logic_less_than"
        ]

        guard let logic = Logic(field: logicDict) else { XCTFail("Logic creation failed"); return }
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)

        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }

        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionConditionalLogicIsNullOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc5981816e52ad55b71e6",
                    "condition": "null="
                ]
            ],
            "_id": "test_logic_is_null"
        ]

        guard let logic = Logic(field: logicDict) else { XCTFail("Logic creation failed"); return }
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)

        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }

        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertEqual(isVisible, false)
    }
    
    func testCollectionConditionalLogicIsNotNullOperator() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()

        let logicDict: [String: Any] = [
            "action": "hide",
            "eval": "and",
            "conditions": [
                [
                    "schema": "collectionSchemaId",
                    "column": "67ddc59c4aba2df34a6dd1c4",
                    "condition": "*="
                ]
            ],
            "_id": "test_logic_is_not_null"
        ]

        guard let logic = Logic(field: logicDict) else { XCTFail("Logic creation failed"); return }
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "67ddc5c9910a394a1324bfbe", logic: logic)
        let editor = documentEditor(document: updatedDoc)

        guard let field = editor.field(fieldID: collectionFieldID),
              let valueElements = field.valueToValueElements,
              let firstRowID = valueElements.first?.id else {
            XCTFail("Collection field or its value elements not found")
            return
        }

        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "67ddc5c9910a394a1324bfbe")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        XCTAssertEqual(isVisible, false)
    }

    // MARK: - Nested Schema Visibility Map (buildSchemaMap)

    // The tests above all assert against `valueElements.first`, whose `children` is
    // empty in the shared fixture. The cases below cover rows that DO hold child data:
    // their declared sibling schemas still have to be evaluated, because the collection
    // view walks the declared children when expanding a row, and an unmapped schema
    // reads back as visible.

    private var visibilityRootSchemaKey: String { "collectionSchemaId" }
    private var visibilityTypeColumnID: String { "multiselect1" }
    private var visibilityOptionA: String { "option_a" }
    private var visibilityOptionB: String { "option_b" }
    private var visibilityPopulatedSchemaID: String { "schema_populated" }
    private var visibilityMatchingSchemaID: String { "schema_matching" }
    private var visibilityNonMatchingSchemaID: String { "schema_nonmatch" }
    private var visibilityParentRowID: String { "row_001" }
    private var visibilityNestedRowID: String { "nested_row_001" }

    private func visibilityTypeColumn() -> [String: Any] {
        [
            "_id": visibilityTypeColumnID,
            "type": "multiSelect",
            "title": "Type",
            "width": 0,
            "multi": true,
            "identifier": "properties_type",
            "options": [
                ["_id": visibilityOptionA, "value": "A"],
                ["_id": visibilityOptionB, "value": "B"]
            ]
        ]
    }

    private func visibilityTextColumn(id: String) -> [String: Any] {
        ["_id": id, "type": "text", "title": "Text", "width": 0, "identifier": "field_column_\(id)"]
    }

    /// A child schema hidden by default and revealed when the parent row's type column
    /// equals `optionID` — the shape used by the NFPA-style inspection templates.
    private func visibilityHiddenChildSchema(
        title: String,
        optionID: String,
        parentSchemaKey: String,
        action: String = "show"
    ) -> [String: Any] {
        [
            "title": title,
            "hidden": true,
            "children": [String](),
            "tableColumns": [visibilityTextColumn(id: "col_\(optionID)_\(action)")],
            "logic": [
                "action": action,
                "eval": "or",
                "conditions": [
                    [
                        "condition": "=",
                        "value": optionID,
                        "column": visibilityTypeColumnID,
                        "schema": parentSchemaKey
                    ]
                ]
            ]
        ]
    }

    /// Root schema declaring three children; only one of them ever holds row data.
    private func visibilitySchema() -> [String: Any] {
        [
            visibilityRootSchemaKey: [
                "root": true,
                "title": "",
                "children": [visibilityPopulatedSchemaID, visibilityMatchingSchemaID, visibilityNonMatchingSchemaID],
                "tableColumns": [visibilityTypeColumn()]
            ],
            visibilityPopulatedSchemaID: [
                "title": "Populated",
                "children": [String](),
                "tableColumns": [visibilityTextColumn(id: "col_nested")]
            ],
            visibilityMatchingSchemaID: visibilityHiddenChildSchema(
                title: "Matching",
                optionID: visibilityOptionA,
                parentSchemaKey: visibilityRootSchemaKey
            ),
            visibilityNonMatchingSchemaID: visibilityHiddenChildSchema(
                title: "Non matching",
                optionID: visibilityOptionB,
                parentSchemaKey: visibilityRootSchemaKey
            )
        ]
    }

    /// A root row selecting `optionA`, carrying child data for the populated schema only.
    private func visibilityParentRow(
        rowID: String? = nil,
        selecting optionID: String? = nil,
        nestedChildren: [String: Any] = [:],
        populatedRows: [[String: Any]]? = nil
    ) -> [String: Any] {
        let nestedRow: [String: Any] = [
            "_id": visibilityNestedRowID,
            "deleted": false,
            "cells": ["col_nested": "value"],
            "children": nestedChildren
        ]
        return [
            "_id": rowID ?? visibilityParentRowID,
            "deleted": false,
            "cells": [visibilityTypeColumnID: [optionID ?? visibilityOptionA]],
            "children": [
                visibilityPopulatedSchemaID: ["value": populatedRows ?? [nestedRow]]
            ]
        ]
    }

    private func visibilityCollectionField(schema: [String: Any], rows: [[String: Any]]) -> JoyDocField {
        var field = JoyDocField()
        field.type = "collection"
        field.id = collectionFieldID
        field.identifier = "field_\(collectionFieldID)"
        field.title = "Collection"
        field.description = ""
        field.file = fileID
        field.dictionary["schema"] = schema
        field.value = .valueElementArray(rows.map { ValueElement(dictionary: $0) })
        return field
    }

    private func visibilityEditor(schema: [String: Any], rows: [[String: Any]]) -> DocumentEditor {
        var document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
        document.fields.append(visibilityCollectionField(schema: schema, rows: rows))
        document = document.setFieldPositionToPage(pageId: pageID, idAndTypes: [collectionFieldID: .collection])
        return documentEditor(document: document)
    }

    private func visibilityShouldShow(_ editor: DocumentEditor, rowID: String, schemaID: String) -> Bool {
        editor.shouldShowSchema(
            for: collectionFieldID,
            rowSchemaID: RowSchemaID(rowID: rowID, schemaID: schemaID)
        )
    }

    /// Regression: a declared sibling with no data on the row must still be evaluated.
    /// The map used to be built only from the keys present in `children`, so this hidden
    /// schema had no entry and the read-side default made it visible.
    func testSiblingSchemaWithoutRowDataStaysHiddenWhenLogicDoesNotMatch() {
        let editor = visibilityEditor(schema: visibilitySchema(), rows: [visibilityParentRow()])

        XCTAssertFalse(
            visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityNonMatchingSchemaID),
            "Schema is hidden and its show condition (type == B) does not match the row (type == A)"
        )
    }

    /// The matching sibling — also without data — must be revealed by its logic.
    func testSiblingSchemaWithoutRowDataIsShownWhenLogicMatches() {
        let editor = visibilityEditor(schema: visibilitySchema(), rows: [visibilityParentRow()])

        XCTAssertTrue(
            visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityMatchingSchemaID),
            "Schema's show condition (type == A) matches the row"
        )
    }

    /// The schema that does hold data keeps working as before.
    func testPopulatedChildSchemaRemainsVisible() {
        let editor = visibilityEditor(schema: visibilitySchema(), rows: [visibilityParentRow()])

        XCTAssertTrue(
            visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityPopulatedSchemaID),
            "Schema without logic and without a hidden flag is visible"
        )
    }

    /// A row with no children at all already worked; keep it covered so the two paths
    /// cannot drift apart again.
    func testRowWithoutAnyChildrenEvaluatesAllDeclaredSchemas() {
        let row: [String: Any] = [
            "_id": visibilityParentRowID,
            "deleted": false,
            "cells": [visibilityTypeColumnID: [visibilityOptionA]],
            "children": [String: Any]()
        ]
        let editor = visibilityEditor(schema: visibilitySchema(), rows: [row])

        XCTAssertTrue(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityMatchingSchemaID))
        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityNonMatchingSchemaID))
    }

    /// The same gap existed at every nesting level: a nested row's declared children
    /// were only mapped when they already had data.
    func testNestedRowDeclaredChildrenAreEvaluated() {
        let grandChildID = "schema_grandchild"
        var schema = visibilitySchema()
        schema[visibilityPopulatedSchemaID] = [
            "title": "Populated",
            "children": [grandChildID],
            "tableColumns": [visibilityTextColumn(id: "col_nested"), visibilityTypeColumn()]
        ]
        schema[grandChildID] = visibilityHiddenChildSchema(
            title: "Grandchild",
            optionID: visibilityOptionB,
            parentSchemaKey: visibilityPopulatedSchemaID
        )

        let editor = visibilityEditor(schema: schema, rows: [visibilityParentRow()])

        XCTAssertFalse(
            visibilityShouldShow(editor, rowID: visibilityNestedRowID, schemaID: grandChildID),
            "Nested row does not select option B, so its hidden grandchild schema stays hidden"
        )
    }

    /// Defensive: child data under a schema the parent does not declare is still
    /// evaluated rather than dropped from the map.
    func testUndeclaredChildDataIsStillEvaluated() {
        var schema = visibilitySchema()
        schema[visibilityRootSchemaKey] = [
            "root": true,
            "title": "",
            "children": [visibilityMatchingSchemaID, visibilityNonMatchingSchemaID], // populated schema omitted
            "tableColumns": [visibilityTypeColumn()]
        ]

        let editor = visibilityEditor(schema: schema, rows: [visibilityParentRow()])

        XCTAssertTrue(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityPopulatedSchemaID))
        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityNonMatchingSchemaID))
    }

    /// A hidden schema carrying no logic at all must stay hidden on a row that has
    /// child data — there is nothing to reveal it.
    func testHiddenSchemaWithoutLogicStaysHiddenOnRowWithChildren() {
        let plainHiddenID = "schema_plain_hidden"
        var schema = visibilitySchema()
        schema[visibilityRootSchemaKey] = [
            "root": true,
            "title": "",
            "children": [visibilityPopulatedSchemaID, plainHiddenID],
            "tableColumns": [visibilityTypeColumn()]
        ]
        schema[plainHiddenID] = [
            "title": "Plain hidden",
            "hidden": true,
            "children": [String](),
            "tableColumns": [visibilityTextColumn(id: "col_plain")]
        ]

        let editor = visibilityEditor(schema: schema, rows: [visibilityParentRow()])

        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: plainHiddenID))
    }

    /// A `hide` action on a sibling without data must be honoured too.
    func testHideActionOnSiblingSchemaWithoutRowData() {
        let hideSchemaID = "schema_hide"
        var schema = visibilitySchema()
        schema[visibilityRootSchemaKey] = [
            "root": true,
            "title": "",
            "children": [visibilityPopulatedSchemaID, hideSchemaID],
            "tableColumns": [visibilityTypeColumn()]
        ]
        // Visible by default, hidden when the row selects option A — which it does.
        schema[hideSchemaID] = [
            "title": "Hide on A",
            "hidden": false,
            "children": [String](),
            "tableColumns": [visibilityTextColumn(id: "col_hide")],
            "logic": [
                "action": "hide",
                "eval": "or",
                "conditions": [
                    [
                        "condition": "=",
                        "value": visibilityOptionA,
                        "column": visibilityTypeColumnID,
                        "schema": visibilityRootSchemaKey
                    ]
                ]
            ]
        ]

        let editor = visibilityEditor(schema: schema, rows: [visibilityParentRow()])

        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: hideSchemaID))
    }

    /// A child entry present in the data but holding an empty row array is still a row
    /// with children, so its siblings must not fall back to visible.
    func testChildSchemaWithEmptyRowArrayStillEvaluatesSiblings() {
        let row: [String: Any] = [
            "_id": visibilityParentRowID,
            "deleted": false,
            "cells": [visibilityTypeColumnID: [visibilityOptionA]],
            "children": [visibilityPopulatedSchemaID: ["value": [[String: Any]]()]]
        ]
        let editor = visibilityEditor(schema: visibilitySchema(), rows: [row])

        XCTAssertTrue(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityMatchingSchemaID))
        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityNonMatchingSchemaID))
    }

    /// Each row is evaluated against its own cells: two rows selecting different
    /// options must resolve the same schema differently.
    func testSchemaVisibilityIsEvaluatedPerRow() {
        let secondRowID = "row_002"
        let rows = [
            visibilityParentRow(),
            visibilityParentRow(
                rowID: secondRowID,
                selecting: visibilityOptionB,
                populatedRows: [["_id": "nested_row_002", "deleted": false, "cells": [String: Any](), "children": [String: Any]()]]
            )
        ]
        let editor = visibilityEditor(schema: visibilitySchema(), rows: rows)

        XCTAssertTrue(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityMatchingSchemaID))
        XCTAssertFalse(visibilityShouldShow(editor, rowID: visibilityParentRowID, schemaID: visibilityNonMatchingSchemaID))

        XCTAssertFalse(visibilityShouldShow(editor, rowID: secondRowID, schemaID: visibilityMatchingSchemaID))
        XCTAssertTrue(visibilityShouldShow(editor, rowID: secondRowID, schemaID: visibilityNonMatchingSchemaID))
    }

    /// The shared fixture's second row is the one that carries child data, and no test
    /// above asserts against it. Its nested and grand-nested rows must be mapped.
    func testFixtureRowWithChildrenMapsNestedAndGrandNestedSchemas() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setMobileView()
            .setPageFieldInMobileView()
            .setPageField()
            .setCollectionField()
            .setCollectionFieldPosition()
        let editor = documentEditor(document: document)

        // Row 2 of the fixture holds children for both declared child schemas.
        let rowWithChildren = "67ddc537b7c2fce05d0c8615"
        XCTAssertTrue(visibilityShouldShow(editor, rowID: rowWithChildren, schemaID: "67ddc5c9910a394a1324bfbe"))
        XCTAssertTrue(visibilityShouldShow(editor, rowID: rowWithChildren, schemaID: "67ddcf4f622984fb4518cbc2"))

        // A nested row of that row declares a grandchild schema.
        let nestedRow = "67ddd191ab6a428ea69c77ad"
        XCTAssertTrue(visibilityShouldShow(editor, rowID: nestedRow, schemaID: "67ddc5f5c2477e8457956fb4"))
    }
}

private final class CaptureChangeHandler: FormChangeEvent {
    private let onChanges: ([Change], JoyDoc) -> Void
    private(set) var onChangeCallCount = 0

    init(_ onChange: @escaping ([Change], JoyDoc) -> Void) {
        self.onChanges = onChange
    }

    func onChange(changes: [Change], document: JoyDoc) {
        onChangeCallCount += 1
        onChanges(changes, document)
    }
    func onFocus(event: Joyfill.Event) {}
    func onBlur(event: Joyfill.Event) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) {}
}
