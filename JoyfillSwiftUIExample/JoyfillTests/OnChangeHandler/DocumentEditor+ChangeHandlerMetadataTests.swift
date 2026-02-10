//
//  DocumentEditor+ChangeHandlerMetadataTests.swift
//  JoyfillTests
//
//  Tests for metadata (deficiency capture) support in DocumentEditor+ChangeHandler:
//  - Applying field metadata from field.update change
//  - Applying row metadata from field.value.rowUpdate and field.value.rowCreate
//  - Emitting field/row metadata in onChange payloads
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
@testable import Joyfill

final class DocumentEditorChangeHandlerMetadataTests: XCTestCase {

    private let fileID = "685750ef698da1ab427761ba"
    private let pageID = "685750efeb612f4fac5819dd"
    private let tableFieldID = "685750f0489567f18eb8a9ec"
    private let tableFieldPositionId = "6857510f4313cfbfb43c516c"
    private let textColumnID = "684c3fedce82027a49234dd3"
    private let existingRowId = "684c3fedfed2b76677110b19"

    // Collection field (ChangerHandlerUnit)
    private let collectionFieldID = "6857510fbfed1553e168161b"
    private let collectionFieldPositionId = "68575112158ff5dbaa9f78e1"
    private let collectionTextColumnID = "684c3fedb0afd867adaeb3b4"
    private let collectionExistingRowId = "68575bb9cdb3707c78d6b2ff"
    private let collectionSchemaId = "collectionSchemaId"

    private func createTestDocument() -> JoyDoc {
        sampleJSONDocument(fileName: "ChangerHandlerUnit")
    }

    private func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }

    private func waitForMainQueue() {
        let exp = expectation(description: "main")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func createCollectionViewModel(documentEditor: DocumentEditor) async throws -> CollectionViewModel {
        let field = documentEditor.field(fieldID: collectionFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible)
        let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: Mode.fill,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: collectionFieldID, pageID: pageID, fileID: fileID)
        )
        guard let tableDataModel else { fatalError("TableViewModel not found") }
        return try await CollectionViewModel(tableDataModel: tableDataModel)
    }

    // MARK: - Apply field metadata from change API (handleFieldUpdate)

    func testApplyFieldMetadataFromFieldUpdateChange() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        XCTAssertNil(editor.field(fieldID: tableFieldID)?.metadata?.dictionary["linkedPageId"])

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: tableFieldID,
            fieldIdentifier: editor.field(fieldID: tableFieldID)?.identifier,
            fieldPositionId: tableFieldPositionId,
            change: [
                "metadata": [
                    "linkType": "fieldToField",
                    "linkedPageId": "page_source",
                    "linkedFieldId": "field_source_text",
                    "linkedFieldPositionId": "fp_source_text"
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])

        let meta = editor.field(fieldID: tableFieldID)?.metadata
        XCTAssertNotNil(meta)
        XCTAssertEqual(meta?.dictionary["linkedPageId"] as? String, "page_source")
        XCTAssertEqual(meta?.dictionary["linkedFieldId"] as? String, "field_source_text")
    }

    func testApplyFieldMetadataOnlyWithoutValueInChange() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        let initialRowOrderCount = editor.field(fieldID: tableFieldID)?.rowOrder?.count

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: tableFieldID,
            fieldIdentifier: editor.field(fieldID: tableFieldID)?.identifier,
            fieldPositionId: tableFieldPositionId,
            change: [
                "metadata": [
                    "linkedPageId": "page_1",
                    "linkedFieldId": "field_1"
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])

        XCTAssertEqual(editor.field(fieldID: tableFieldID)?.rowOrder?.count, initialRowOrderCount)
        XCTAssertEqual(editor.field(fieldID: tableFieldID)?.metadata?.dictionary["linkedPageId"] as? String, "page_1")
    }

    func testApplyFieldUpdateWithBothValueAndMetadata() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: tableFieldID,
            fieldIdentifier: editor.field(fieldID: tableFieldID)?.identifier,
            fieldPositionId: tableFieldPositionId,
            change: [
                "metadata": [
                    "linkedPageId": "page_src",
                    "linkedFieldId": "field_src"
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])

        XCTAssertEqual(editor.field(fieldID: tableFieldID)?.metadata?.dictionary["linkedPageId"] as? String, "page_src")
    }

    // MARK: - Apply row metadata from change API (mergedRow in TableViewModel / applyRowEditChanges)

    func testApplyRowMetadataFromRowUpdateChange() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        waitForMainQueue()
        XCTAssertNil(editor.field(fieldID: tableFieldID)?.valueToValueElements?.first(where: { $0.id == existingRowId })?.metadata)

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowUpdate",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: tableFieldID,
            fieldIdentifier: editor.field(fieldID: tableFieldID)?.identifier,
            fieldPositionId: tableFieldPositionId,
            change: [
                "rowId": existingRowId,
                "row": [
                    "_id": existingRowId,
                    "cells": [textColumnID: "Updated cell"],
                    "metadata": [
                        "linkType": "tableRowToTableRow",
                        "linkedPageId": "page_source",
                        "linkedFieldId": "field_source_table",
                        "linkedRowId": "source_row_1"
                    ]
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])
        waitForMainQueue()

        let row = editor.field(fieldID: tableFieldID)?.valueToValueElements?.first(where: { $0.id == existingRowId })
        XCTAssertNotNil(row?.metadata)
        XCTAssertEqual(row?.metadata?.dictionary["linkedPageId"] as? String, "page_source")
        XCTAssertEqual(row?.metadata?.dictionary["linkedRowId"] as? String, "source_row_1")
    }

    func testApplyRowMetadataFromRowCreateChange() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        let viewModel = createTableViewModel(documentEditor: editor)
        waitForMainQueue()
        let newRowId = "row_new_\(Int(Date().timeIntervalSince1970))"

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowCreate",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: tableFieldID,
            fieldIdentifier: editor.field(fieldID: tableFieldID)?.identifier,
            fieldPositionId: tableFieldPositionId,
            change: [
                "row": [
                    "_id": newRowId,
                    "cells": [textColumnID: "New row"],
                    "metadata": [
                        "linkType": "tableRowToField",
                        "linkedPageId": "page_source",
                        "linkedFieldId": "field_source_text"
                    ]
                ],
                "targetRowIndex": 2
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])
        waitForMainQueue()

        let newRow = editor.field(fieldID: tableFieldID)?.valueToValueElements?.first(where: { $0.id == newRowId })
        XCTAssertNotNil(newRow, "New row should be inserted after rowCreate change")
        XCTAssertNotNil(newRow?.metadata, "Inserted row should preserve metadata from change payload")
        XCTAssertEqual(newRow?.metadata?.dictionary["linkType"] as? String, "tableRowToField")
        XCTAssertEqual(newRow?.metadata?.dictionary["linkedFieldId"] as? String, "field_source_text")
    }

    // MARK: - Collection: apply row metadata from change API (insertRow / applyRowEditChanges)

    func testCollectionApplyRowMetadataFromRowCreateChange() {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        _ = createTableViewModel(documentEditor: editor)
        waitForMainQueue()
        let newRowId = "row_coll_new_\(Int(Date().timeIntervalSince1970))"

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowCreate",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: collectionFieldID,
            fieldIdentifier: editor.field(fieldID: collectionFieldID)?.identifier,
            fieldPositionId: collectionFieldPositionId,
            change: [
                "row": [
                    "_id": newRowId,
                    "cells": [collectionTextColumnID: "New collection row"],
                    "metadata": [
                        "linkType": "collectionRowToField",
                        "linkedPageId": "page_coll",
                        "linkedFieldId": "field_coll_text"
                    ]
                ],
                "targetRowIndex": 0,
                "schemaId": collectionSchemaId,
                "parentPath": ""
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])
        waitForMainQueue()

        let newRow = editor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == newRowId })
        XCTAssertNotNil(newRow, "New collection row should be inserted after rowCreate change")
        XCTAssertNotNil(newRow?.metadata, "Inserted collection row should preserve metadata from change payload")
        XCTAssertEqual(newRow?.metadata?.dictionary["linkType"] as? String, "collectionRowToField")
        XCTAssertEqual(newRow?.metadata?.dictionary["linkedFieldId"] as? String, "field_coll_text")
    }

    func testCollectionApplyRowMetadataFromRowUpdateChange() async throws {
        let document = createTestDocument()
        let editor = documentEditor(document: document)
        _ = try await createCollectionViewModel(documentEditor: editor)
        sleep(10)
        XCTAssertNil(editor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == collectionExistingRowId })?.metadata)

        let change = Change(
            v: 1,
            sdk: "swift",
            target: "field.value.rowUpdate",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: fileID,
            pageId: pageID,
            fieldId: collectionFieldID,
            fieldIdentifier: editor.field(fieldID: collectionFieldID)?.identifier,
            fieldPositionId: collectionFieldPositionId,
            change: [
                "rowId": collectionExistingRowId,
                "schemaId": collectionSchemaId,
                "parentPath": "",
                "row": [
                    "_id": collectionExistingRowId,
                    "cells": [collectionTextColumnID: "Updated collection cell"],
                    "metadata": [
                        "linkType": "collectionRowToRow",
                        "linkedPageId": "page_coll_src",
                        "linkedRowId": "source_coll_row_1"
                    ]
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [change])
        waitForMainQueue()

        let row = editor.field(fieldID: collectionFieldID)?.valueToValueElements?.first(where: { $0.id == collectionExistingRowId })
        XCTAssertNotNil(row?.metadata)
        XCTAssertEqual(row?.metadata?.dictionary["linkedPageId"] as? String, "page_coll_src")
        XCTAssertEqual(row?.metadata?.dictionary["linkedRowId"] as? String, "source_coll_row_1")
    }

    private func createTableViewModel(documentEditor: DocumentEditor) -> TableViewModel {
        let field = documentEditor.field(fieldID: tableFieldID)
        let fieldHeaderModel = FieldHeaderModel(title: field?.title, required: field?.required, tipDescription: field?.tipDescription, tipTitle: field?.tipTitle, tipVisible: field?.tipVisible)
        let tableDataModel = TableDataModel(
            fieldHeaderModel: fieldHeaderModel,
            mode: Mode.fill,
            documentEditor: documentEditor,
            fieldIdentifier: FieldIdentifier(fieldID: tableFieldID, pageID: pageID, fileID: fileID)
        )
        guard let tableDataModel else { fatalError("TableDataModel not found") }
        return TableViewModel(tableDataModel: tableDataModel)
    }

    // MARK: - Field metadata applied from field.update change (assert via editor.field, not changelogs)

    func testEmittedFieldUpdateChangeIncludesMetadataWhenFieldHasMetadata() {
        let document = makeMinimalDocWithTextField()
        let textFieldID = "field_text_1"
        let fpID = "fp_1"
        let editor = DocumentEditor(document: document, mode: .fill, validateSchema: false)
        XCTAssertNil(editor.field(fieldID: textFieldID)?.metadata?.dictionary["linkedPageId"])

        let setMetaChange = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: "file_1",
            pageId: "page_1",
            fieldId: textFieldID,
            fieldIdentifier: editor.field(fieldID: textFieldID)?.identifier,
            fieldPositionId: fpID,
            change: [
                "metadata": [
                    "linkedPageId": "page_def",
                    "linkedFieldId": "field_def"
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [setMetaChange])

        // Assert by reading field state from editor (do not use captured changes/changelogs).
        let field = editor.field(fieldID: textFieldID)
        XCTAssertNotNil(field?.metadata)
        XCTAssertEqual(field?.metadata?.dictionary["linkedPageId"] as? String, "page_def")
        XCTAssertEqual(field?.metadata?.dictionary["linkedFieldId"] as? String, "field_def")
    }

    /// Metadata is preserved when updating in response to an onChange event (user edit); assert via editor.field.
    func testFieldMetadataPreservedWhenUpdatingInResponseToOnChangeEvent() {
        let document = makeMinimalDocWithTextField()
        let textFieldID = "field_text_1"
        let fpID = "fp_1"
        let editor = DocumentEditor(document: document, mode: .fill, validateSchema: false)
        let setMetaChange = Change(
            v: 1,
            sdk: "swift",
            target: "field.update",
            _id: editor.documentID ?? "",
            identifier: editor.documentIdentifier,
            fileId: "file_1",
            pageId: "page_1",
            fieldId: textFieldID,
            fieldIdentifier: editor.field(fieldID: textFieldID)?.identifier,
            fieldPositionId: fpID,
            change: [
                "metadata": [
                    "linkedPageId": "page_retain",
                    "linkedFieldId": "field_retain"
                ]
            ],
            createdOn: Date().timeIntervalSince1970
        )
        editor.change(changes: [setMetaChange])
        let fieldId = editor.getFieldIdentifier(for: textFieldID)
        editor.onChange(event: FieldChangeData(fieldIdentifier: fieldId, updateValue: .string("New value")))
        let field = editor.field(fieldID: textFieldID)
        XCTAssertEqual(field?.value?.text, "New value")
        XCTAssertNotNil(field?.metadata, "Field metadata should be preserved when updating in response to onChange")
        XCTAssertEqual(field?.metadata?.dictionary["linkedPageId"] as? String, "page_retain")
        XCTAssertEqual(field?.metadata?.dictionary["linkedFieldId"] as? String, "field_retain")
    }

    private func makeMinimalDocWithTextField() -> JoyDoc {
        var doc = JoyDoc(dictionary: [:])
        doc.id = "doc_1"
        doc.identifier = "doc_id_1"
        doc.type = "template"
        doc.name = "Test"
        doc.files = [
            File(dictionary: [
                "_id": "file_1",
                "name": "File 1",
                "version": 1,
                "pageOrder": ["page_1"],
                "pages": [
                    [
                        "_id": "page_1",
                        "name": "Page 1",
                        "fieldPositions": [
                            ["_id": "fp_1", "field": "field_text_1", "type": "text", "x": 0, "y": 0, "width": 8, "height": 8]
                        ]
                    ]
                ]
            ])
        ]
        doc.fields = [
            JoyDocField(field: [
                "_id": "field_text_1",
                "type": "text",
                "file": "file_1",
                "title": "Text Field",
                "identifier": "field_text_1",
                "value": "Initial"
            ])
        ]
        return doc
    }

    // MARK: - Row payload includes metadata (ValueElement.anyDictionary used in addRowChanges)

    func testValueElementAnyDictionaryIncludesMetadata() {
        let row = ValueElement(dictionary: [
            "_id": "row_def_1",
            "cells": ["col_1": "Deficiency"],
            "metadata": [
                "linkedPageId": "page_src",
                "linkedFieldId": "field_src",
                "linkedRowId": "source_row_1"
            ]
        ])
        let anyDict = row.anyDictionary
        XCTAssertNotNil(anyDict["metadata"])
        let meta = anyDict["metadata"] as? [String: Any]
        XCTAssertEqual(meta?["linkedPageId"] as? String, "page_src")
        XCTAssertEqual(meta?["linkedRowId"] as? String, "source_row_1")
    }
}

// MARK: - Capture FormChangeEvent for emission tests

private final class CaptureFormChangeEvent: FormChangeEvent {
    private let onChanges: ([Change], JoyDoc) -> Void

    init(onChange: @escaping ([Change], JoyDoc) -> Void) {
        self.onChanges = onChange
    }

    func onChange(changes: [Change], document: JoyDoc) {
        onChanges(changes, document)
    }

    func onFocus(event: FieldIdentifier) {}
    func onBlur(event: FieldIdentifier) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) {}
}
