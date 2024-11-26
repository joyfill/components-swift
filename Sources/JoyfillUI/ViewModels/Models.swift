//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 25/11/24.
//

import Foundation
import JoyfillModel

struct PageModel {
    let id: String
    var fields: [FieldListModel]
}

struct FieldListModel {
    let fieldID: String
    let pageID: String
    let fileID: String
    var refreshID: UUID
}

struct TableDataModel {
    var fieldId: String?
    var pageId: String?
    var fileId: String?
    var value: ValueUnion?
    var tableColumnOrder: [String]?
    var tableColumns: [FieldTableColumn]?
    var valueToValueElements: [ValueElement]?
    var rowOrder: [String]?
    var title: String?
    var documentEditor: DocumentEditor?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct ChartDataModel {
    var fieldId: String?
    var pageId: String?
    var fileId: String?
    var valueElements: [ValueElement]?
    var yTitle: String?
    var yMax: Double?
    var yMin: Double?
    var xTitle: String?
    var xMax: Double?
    var xMin: Double?
    var mode: Mode
    var documentEditor: DocumentEditor?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct DateTimeDataModel {
    var fieldId: String?
    var value: ValueUnion?
    var format: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct DisplayTextDataModel {
    var displayText: String?
    var fontWeight: String?
    var fieldHeaderModel: FieldHeaderModel?
}

struct DropdownDataModel {
    var fieldId: String?
    var dropdownValue: String?
    var options: [Option]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct ImageDataModel {
    var fieldId: String?
    var multi: Bool?
    var primaryDisplayOnly: Bool?
    var valueElements: [ValueElement]?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiLineDataModel {
    var fieldId: String?
    var multilineText: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct MultiSelectionDataModel {
    var fieldId: String?
    var currentFocusedFieldsDataId: String?
    var multi: Bool?
    var options: [Option]?
    var multiSelector: [String]?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct NumberDataModel {
    var fieldId: String?
    var number: Double?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct RichTextDataModel {
    var text: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct SignatureDataModel {
    var fieldId: String?
    var signatureURL: String?
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}

struct TextDataModel {
    var fieldId: String?
    var text: String?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}
