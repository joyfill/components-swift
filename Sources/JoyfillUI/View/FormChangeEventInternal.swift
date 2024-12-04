//
//  File.swift
//  
//
//  Created by Vishnu Dutt on 21/11/24.
//

import JoyfillModel


/// `FieldChangeEvent` is a structure that encapsulates the changes in a field.
///
/// It contains information about the position of the field, the field itself, the page containing the field, and the file associated with the field.
struct FieldChangeEvent {
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

/// `FormChangeEventInternal` is a protocol that defines the methods to handle form change events.
protocol FormChangeEventInternal {

    /// A method that is called when a field's value changes.
    ///
    /// - Parameter event: The `FieldChangeEvent` object that contains information about the field change event.
    func onChange(event: FieldChangeEvent)

    /// Adds a row to the form with the specified field change event.
    ///
    /// - Parameters:
    ///   - event: The field change event containing the necessary information for adding a row.
    func addRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel])

    func moveRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel])

    func deleteRow(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel])

    /// Notifies the form view that it has received focus.
    ///
    /// - Parameter event: The field event associated with the focus.
    func onFocus(event: FieldEventInternal)

    /// Calls the `onBlur` event handler with the specified `event`.
    ///
    /// - Parameter event: The `FieldEvent` to pass to the `onBlur` event handler.
    func onBlur(event: FieldEventInternal)

    /// Calls the `onUpload` method of the `events` object, passing the provided `event`.
    ///
    /// - Parameter event: The `UploadEvent` to be passed to the `onUpload` method.
    func onUpload(event: UploadEvent)
}


/// A protocol that defines the field change events for a document.
protocol FieldChangeEvents {
    func onChange(event: FieldChangeEvent)
    func onFocus(event: FieldEvent)
    func onUpload(event: UploadEvent)
}
    

struct FieldEventInternal {
    let fieldID: String
    var pageID: String?
    var fileID: String?
}

/// `UploadEvent` is a structure that encapsulates an upload event in the JoyDoc system.
struct UploadEventInternal {
    let fieldID: String
    var pageID: String?
    var fileID: String?
    
    ///  A closure of type `([String]) -> Void` that handles the upload process.
    public var uploadHandler: ([String]) -> Void
    
    public init(fieldID: String, pageID: String? = nil, fileID: String? = nil, uploadHandler: @escaping ([String]) -> Void) {
        self.fieldID = fieldID
        self.pageID = pageID
        self.fileID = fileID
        self.uploadHandler = uploadHandler
    }
}
