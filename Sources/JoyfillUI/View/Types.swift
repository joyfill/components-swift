//
//  File.swift
//  Joyfill
//
//  Created by Vishnu Dutt on 16/07/25.
//

import Foundation
import JoyfillModel
import JSONSchema

public struct FieldIdentifier: Equatable {
    public let fieldID: String
    public var pageID: String?
    public var fileID: String?

    public init(fieldID: String, pageID: String? = nil, fileID: String? = nil) {
        self.fieldID = fieldID
        self.pageID = pageID
        self.fileID = fileID
    }
}

public struct UploadEvent {
    public var fieldEvent: FieldIdentifier
    public let multi: Bool
    public var uploadHandler: ([String]) -> Void

    public init(fieldEvent: FieldIdentifier, multi: Bool, uploadHandler: @escaping ([String]) -> Void) {
        self.fieldEvent = fieldEvent
        self.uploadHandler = uploadHandler
        self.multi = multi
    }
}

public struct CaptureEvent {
    public var fieldEvent: FieldIdentifier

    public var captureHandler: (ValueUnion) -> Void

    public init(fieldEvent: FieldIdentifier, captureHandler: @escaping (ValueUnion) -> Void) {
        self.fieldEvent = fieldEvent
        self.captureHandler = captureHandler
    }
}

public enum Mode {
    case fill
    case readonly
}

public protocol FormInterface {
    var document: JoyDoc { get }
    var mode: Mode { get }
    var events: FormChangeEvent? { get set }
}

/// A struct representing a change in a document.
public struct Change {
    /// The dictionary representation of the change.
    public var dictionary = [String: Any]()

    /// Initializes a `Change` instance with a dictionary.
    /// - Parameter dictionary: The dictionary representation of the change.
    public init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    /// The ID of the change.
    public var id: String? {
        get { dictionary["_id"] as? String }
        set { dictionary["_id"] = newValue }
    }

    /// The version of the change.
    public var v: Int? {
        dictionary["v"] as? Int
    }

    /// The SDK used for the change.
    public var sdk: String? {
        dictionary["sdk"] as? String
    }

    /// The target of the change.
    public var target: String? {
        dictionary["target"] as? String
    }

    /// The identifier of the change.
    public var identifier: String? {
        dictionary["identifier"] as? String
    }

    /// The file ID associated with the change.
    public var fileId: String? {
        dictionary["fileId"] as? String
    }

    /// The page ID associated with the change.
    public var pageId: String? {
        dictionary["pageId"] as? String
    }

    /// The field ID associated with the change.
    public var fieldId: String? {
        dictionary["fieldId"] as? String
    }

    /// The field identifier associated with the change.
    public var fieldIdentifier: String? {
        dictionary["fieldIdentifier"] as? String
    }

    /// The field position ID associated with the change.
    public var fieldPositionId: String? {
        dictionary["fieldPositionId"] as? String
    }

    /// The details of the change.
    public var change: [String: Any]? {
        dictionary["change"] as? [String: Any]
    }

    /// The timestamp when the change was created.
    public var createdOn: Double? {
        dictionary["createdOn"] as? Double
    }

    /// The title of the change.
    public var xTitle: String? {
        dictionary["xTitle"] as? String
    }

    /// The view of the change.
    public var view: String? {
        dictionary["view"] as? String
    }

    /// The viewId of the change.
    public var viewId: String? {
        dictionary["viewId"] as? String
    }

    /// Initializes a `Change` instance with the provided values.
    public init(v: Int, sdk: String, target: String, _id: String, identifier: String?, fileId: String, pageId: String, fieldId: String, fieldIdentifier: String?, fieldPositionId: String, change: [String: Any], createdOn: Double) {
        dictionary["v"] = v
        dictionary["sdk"] = sdk
        dictionary["target"] = target
        dictionary["_id"] = _id
        dictionary["identifier"] = identifier
        dictionary["fileId"] = fileId
        dictionary["pageId"] = pageId
        dictionary["fieldId"] = fieldId
        dictionary["fieldIdentifier"] = fieldIdentifier
        dictionary["fieldPositionId"] = fieldPositionId
        dictionary["change"] = change
        dictionary["createdOn"] = createdOn
    }

    // instance for page.create and field.create
    public init(v: Int, sdk: String, id: String, identifier: String, target: String, fileId: String, change: [String: Any], createdOn: Double) {
        dictionary["v"] = v
        dictionary["sdk"] = sdk
        dictionary["target"] = target
        dictionary["_id"] = id
        dictionary["identifier"] = identifier
        dictionary["fileId"] = fileId
        dictionary["change"] = change
        dictionary["createdOn"] = createdOn
    }

    // instance for page.create with views
    public init(v: Int, sdk: String, id: String, identifier: String, target: String, fileId: String, viewType: String, viewId: String, change: [String: Any], createdOn: Double) {
        dictionary["v"] = v
        dictionary["sdk"] = sdk
        dictionary["target"] = target
        dictionary["_id"] = id
        dictionary["identifier"] = identifier
        dictionary["fileId"] = fileId
        dictionary["view"] = viewType
        dictionary["viewId"] = viewId
        dictionary["change"] = change
        dictionary["createdOn"] = createdOn
    }
}

/// `FormChangeEvent` is a protocol that defines methods for listening to form change events.
public protocol FormChangeEvent {

    /// Used to listen to any field change events.
    ///
    /// (changelogs: object_array, doc: object) => {}
    ///
    /// - changelogs: object_array :
    ///   - Can contain one ore more of the changelog object types supported.
    ///
    /// - doc: object :
    ///    - Fully updated JoyDoc JSON structure with changes applied.
    func onChange(changes: [Change], document: JoyDoc)

    /// Used to listen to field focus events.
    ///
    /// (params: object, e: object) => {}
    ///
    ///  params: object :
    /// - Specifies information about the focused field.
    ///
    /// e: object :
    ///  - Element helper methods.
    ///  - blur: Function :
    ///     - Triggers the field blur event for the focused field.
    ///     - If there are pending changes in the field that have not triggered the `onChange` event yet then the `e.blur()` function will trigger both the change and blur events in the following order: 1) `onChange` 2) `onBlur`.
    ///     - If the focused field utilizes a modal for field modification, ie. signature, image, tables, etc. the `e.blur()` will close the modal.
    func onFocus(event: FieldIdentifier)

    /// Used to listen to field focus events.
    ///
    ///  (params: object) => {}
    ///
    ///  params: object :
    ///  - Specifies information about the blurred field.
    func onBlur(event: FieldIdentifier)

    /// Used to listen to file upload events.
    ///
    /// (params: object) => {} :
    /// - Specifies information about the uploaded file.
    func onUpload(event:UploadEvent)

    func onCapture(event: CaptureEvent)

    func onError(error: JoyfillError)
}

public enum JoyfillError: Error {
    case schemaValidationError(error: SchemaValidationError)
    case schemaVersionError(error: SchemaVersionError)
}

public struct SchemaValidationError: Error {
    public let code: String
    public let message: String
    public let error: [JSONSchema.ValidationError]?
    public let details: Details

    public struct Details {
        public let schemaVersion: String
        public let sdkVersion: String
        
        public init(schemaVersion: String, sdkVersion: String) {
            self.schemaVersion = schemaVersion
            self.sdkVersion = sdkVersion
        }
    }

    public init(
        code: String,
        message: String,
        error: [JSONSchema.ValidationError]?,
        details: Details
    ) {
        self.code = code
        self.message = message
        self.error = error
        self.details = details
    }
}

public struct SchemaVersionError: Error {
    public let code: String
    public let message: String
    public let details: Details

    public struct Details {
        public let schemaVersion: String
        public let sdkVersion: String
        
        public init(schemaVersion: String, sdkVersion: String) {
            self.schemaVersion = schemaVersion
            self.sdkVersion = sdkVersion
        }
    }

    public init(
        code: String,
        message: String,
        details: Details
    ) {
        self.code = code
        self.message = message
        self.details = details
    }
}

