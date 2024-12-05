//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 21/11/24.
//

import JoyfillModel

struct FieldChangeData {
    let fieldID: String
    var pageID: String?
    var fileID: String?
    var updateValue: ValueUnion?
    var chartData: ChartData?
}

struct ChartData {
    var xTitle: String?
    var yTitle: String?
    var xMax: Double?
    var xMin: Double?
    var yMax: Double?
    var yMin: Double?
}

protocol FormChangeEventInternal {
    func onChange(event: FieldChangeData)
    func addRow(event: FieldChangeData, targetRowIndexes: [TargetRowModel])
    func moveRow(event: FieldChangeData, targetRowIndexes: [TargetRowModel])
    func deleteRow(event: FieldChangeData, targetRowIndexes: [TargetRowModel])
    func onFocus(event: FieldEventInternal)
    func onBlur(event: FieldEventInternal)
    func onUpload(event: UploadEvent)
}

protocol FieldChangeEvents {
    func onChange(event: FieldChangeData)
    func onFocus(event: FieldEvent)
    func onUpload(event: UploadEvent)
}
    

struct FieldEventInternal {
    let fieldID: String
    var pageID: String?
    var fileID: String?
}

struct UploadEventInternal {
    let fieldID: String
    var pageID: String?
    var fileID: String?
    
    public var uploadHandler: ([String]) -> Void
    
    public init(fieldID: String, pageID: String? = nil, fileID: String? = nil, uploadHandler: @escaping ([String]) -> Void) {
        self.fieldID = fieldID
        self.pageID = pageID
        self.fileID = fileID
        self.uploadHandler = uploadHandler
    }
}
