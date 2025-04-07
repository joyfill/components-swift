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
        guard let insertResult = documentEditor.insertBelowNestedRow(selectedRowID: initialNestedRows.first!.id!,
                                                                       cellValues: cellValues,
                                                                       fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID),
                                                                       childrenKeys: [nestedKey],
                                                                       rootSchemaKey: collectionFieldID,
                                                                       nestedKey: nestedKey,
                                                                       parentRowId: parentRowId) else {
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
    
    func testBulkEditNestedCollection() {
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
        let nestedRowIds = initialNestedRows.map { $0.id! }
        _ = documentEditor.bulkEditForNested(changes: changes,
                                               selectedRows: nestedRowIds,
                                               fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID))
        
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
            .setCollectionField()
        
        // Define a logic dictionary that should show the schema.
        let logicDict: [String: Any] = [
            "action": "show",
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
        let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "collectionSchemaId", logic: logic)
        
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
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        
        XCTAssertTrue(isVisible, "The collection schema should be visible for the 'show' logic case.")
    }
    
    func testCollectionFieldConditionalLogicHide() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setCollectionField()
        
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
        let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
        let shouldShow = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
        XCTAssertEqual(shouldShow, true)
    }
    
    func testCollectionFieldConditionalLogicNil() {
        let document = JoyDoc()
            .setDocument()
            .setFile()
            .setCollectionField()
        
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
    
    func testCollectionFieldSchemaPresence() {
            // Create a document with a collection field.
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setCollectionField()
            
            // There should be a collection field in document.fields with the expected identifier.
            guard let field = document.fields.first(where: { $0.type == "collection" && $0.identifier == "field_67ddc530213a11e84876b001" }) else {
                XCTFail("Collection field not found.")
                return
            }
            
            // The schema should contain keys from the JSON:
//            let schemaKeys = field.schema?.keys ?? []
//            XCTAssertTrue(schemaKeys.contains("collectionSchemaId"), "The root collection schema key should be present.")
//            XCTAssertTrue(schemaKeys.contains("67ddc5c9910a394a1324bfbe"), "The child table key should be present.")
//            XCTAssertTrue(schemaKeys.contains("67ddc5f5c2477e8457956fb4"), "The grand child table key should be present.")
//            XCTAssertTrue(schemaKeys.contains("67ddcf4f622984fb4518cbc2"), "The 2nd child table key should be present.")
        }
        
        // MARK: - Conditional Logic Tests on Collection Schema
        
        func testConditionalLogicOnRootSchemaKey_Show() {
            // Create a document with a collection field.
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setCollectionField()
            
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
            let updatedDoc = document.setConditionalLogicInCollectionField(schemaKey: "collectionSchemaId", logic: logic)
            let editor = documentEditor(document: updatedDoc)
            
            // For testing, use the first row of the collection value.
            guard let field = editor.field(fieldID: collectionFieldID),
                  let valueElements = field.valueToValueElements,
                  let firstRowID = valueElements.first?.id else {
                XCTFail("Collection field or value elements not found.")
                return
            }
            
            let rowSchemaID = RowSchemaID(rowID: firstRowID, schemaID: "collectionSchemaId")
            let isVisible = editor.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
            XCTAssertTrue(isVisible, "The root schema should be visible for 'show' logic.")
        }
        
        func testConditionalLogicOnChildSchemaKey_Hide() {
            // Create a document with a collection field.
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setCollectionField()
            
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
            XCTAssertFalse(isChildVisible, "The child schema should be hidden for 'hide' logic.")
        }
        
        func testConditionalLogicWithNilLogic() {
            // Create a document with a collection field.
            let document = JoyDoc()
                .setDocument()
                .setFile()
                .setCollectionField()
            
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
                .setCollectionField()
            
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
}
