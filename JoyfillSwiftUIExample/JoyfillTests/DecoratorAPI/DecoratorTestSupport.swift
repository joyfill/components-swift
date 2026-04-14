//
//  DecoratorTestSupport.swift
//  JoyfillTests
//
//  Shared helpers and constants for the Decorator API test suite.
//

import Foundation
import XCTest
import JoyfillModel
@testable import Joyfill

// MARK: - Sample document constants

/// Constants for `ChangerHandlerUnit.json` (table + collection with nested rows on a single page).
enum ChangerHandlerSample {
    static let fileID  = "685750ef698da1ab427761ba"
    static let pageID  = "685750efeb612f4fac5819dd"

    // Table
    static let tableFieldPositionID = "6857510f4313cfbfb43c516c"
    static let tableFieldID         = "685750f0489567f18eb8a9ec"
    static let tableRowID           = "684c3fedfed2b76677110b19"
    static let tableColumnID        = "684c3fedce82027a49234dd3"

    // Collection (root + 1 nested schema)
    static let collectionFieldPositionID = "68575112158ff5dbaa9f78e1"
    static let collectionFieldID         = "6857510fbfed1553e168161b"
    static let collectionRootRowID       = "68575bb9cdb3707c78d6b2ff"
    static let collectionRootSchemaKey   = "collectionSchemaId"
    static let collectionRootColumnID    = "684c3fedb0afd867adaeb3b4"
    static let collectionNestedSchemaKey = "685753949107b403e2e4a949"
    static let collectionNestedRowID     = "68575bc1921b69c15fad6c3f"
    static let collectionNestedColumnID  = "68575394ffa57501fba78c4c"

    // Path helpers
    static func tableFieldPath()  -> String { "\(pageID)/\(tableFieldPositionID)" }
    static func tableRowPath()    -> String { "\(pageID)/\(tableFieldPositionID)/\(tableRowID)" }
    static func tableColumnPath() -> String { "\(pageID)/\(tableFieldPositionID)/\(tableRowID)/\(tableColumnID)" }

    static func collectionFieldPath() -> String { "\(pageID)/\(collectionFieldPositionID)" }
    static func collectionRootRowPath() -> String { "\(pageID)/\(collectionFieldPositionID)/\(collectionRootRowID)" }
    static func collectionNestedRowPath() -> String { "\(pageID)/\(collectionFieldPositionID)/\(collectionNestedRowID)" }
    static func collectionRootColumnPath() -> String { "\(pageID)/\(collectionFieldPositionID)/\(collectionRootRowID)/\(collectionRootColumnID)" }
    static func collectionNestedColumnPath() -> String { "\(pageID)/\(collectionFieldPositionID)/\(collectionNestedRowID)/\(collectionNestedColumnID)" }
}

/// Constants for `Navigation.json` — used only for the shared-field-position-ID regression test.
enum NavigationSample {
    static let fileID = "691f3762c80bfb0005c57b48"
    static let page1ID = "69709dc281b4c8ab68c4db52"
    static let page2ID = "691f376206195944e65eef76"
    /// Same field position ID exists on both pages but points to different fields.
    static let sharedFieldPositionID = "6970918d350238d0738dd5c9"
    static let page1FieldID = "69709dc23a74ed2c22308a1d" // text
    static let page2FieldID = "6970918d6d04413439c39d8b" // text
}

// MARK: - Mock events handler

class MockDecoratorEvents: FormChangeEvent {
    var capturedErrors: [JoyfillError] = []
    var lastDecoratorErrorMessage: String? {
        guard let last = capturedErrors.last else { return nil }
        if case .decoratorError(let e) = last { return e.message }
        return nil
    }
    var decoratorErrorCount: Int {
        capturedErrors.filter { if case .decoratorError = $0 { return true } else { return false } }.count
    }

    func reset() { capturedErrors.removeAll() }

    func onChange(changes: [Change], document: JoyDoc) {}
    func onFocus(event: Joyfill.Event) {}
    func onBlur(event: Joyfill.Event) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) { capturedErrors.append(error) }
}

// MARK: - Decorator factory

func makeDecorator(action: String,
                   icon: String? = "flag",
                   label: String? = "Test",
                   color: String? = "#3B82F6") -> Decorator {
    var d = Decorator()
    d.action = action
    d.icon = icon
    d.label = label
    d.color = color
    return d
}

// MARK: - Editor factory

func makeNavigationEditor(events: MockDecoratorEvents? = nil) -> (DocumentEditor, MockDecoratorEvents) {
    let mock = events ?? MockDecoratorEvents()
    let editor = DocumentEditor(document: sampleJSONDocument(fileName: "Navigation"),
                                events: mock,
                                validateSchema: false)
    return (editor, mock)
}

func makeChangerHandlerEditor(events: MockDecoratorEvents? = nil) -> (DocumentEditor, MockDecoratorEvents) {
    let mock = events ?? MockDecoratorEvents()
    let license = (ProcessInfo.processInfo.environment["JOYFILL_TEST_LICENSE"] ?? licenseKey)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    let editor = DocumentEditor(document: sampleJSONDocument(fileName: "ChangerHandlerUnit"),
                                events: mock,
                                validateSchema: false,
                                license: license.isEmpty ? nil : license)
    return (editor, mock)
}

/// Editor with NO license — collection-field decorator writes are expected to fail.
func makeUnlicensedChangerHandlerEditor(events: MockDecoratorEvents? = nil) -> (DocumentEditor, MockDecoratorEvents) {
    let mock = events ?? MockDecoratorEvents()
    let editor = DocumentEditor(document: sampleJSONDocument(fileName: "ChangerHandlerUnit"),
                                events: mock,
                                validateSchema: false,
                                license: nil)
    return (editor, mock)
}
