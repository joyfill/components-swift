## DocumentEditor

A lightweight overview of the core editing context used by Joyfill to render and modify documents/UI in SwiftUI.

### What it is
- Manages a `JoyDoc` and exposes helpers to read/update it
- Powers the SwiftUI `Form(documentEditor:)` view
- Handles visibility rules, validation, formulas, and table operations under the hood
- Supports programmatic updates from outside the form via `change(changes:)` to update the UI

### Initialize

Simplest form:
```swift
import Joyfill
import JoyfillModel

let editor = DocumentEditor(document: myDocument)
```

Common options (pass only what you need):
```swift
let editor = DocumentEditor(
    document: myDocument,
    mode: .fill,                // or .readonly
    events: myChangeHandler,    // conforms to FormChangeEvent
    pageID: nil,                // start page (optional)
    navigation: true,           // show page navigation UI
    isPageDuplicateEnabled: false,
    validateSchema: true
)
```

### Use with SwiftUI
```swift
import SwiftUI
import Joyfill

struct FormContainerView: View {
    let editor: DocumentEditor

    init(document: JoyDoc) {
        editor = DocumentEditor(document: document)
    }

    var body: some View {
        Form(documentEditor: editor)
    }
}
```

### Common operations
```swift
// Navigate
editor.currentPageID = "page_123"

// Duplicate a page
editor.duplicatePage(pageID: "page_123")

// Field validation (required, formats, etc.)
let result = editor.validate()
```

### Change API

Programmatic updates to a JoyDoc via the editor. Apply multiple updates in one call.

#### Supported targets (common)
- `field.update` — update field value
- `field.value.rowCreate` — create a table row
- `field.value.rowUpdate` — update a table row
- `field.value.rowDelete` — delete a table row
- `field.value.rowMove` — reorder table rows

#### Field update example
```swift
let fieldId = "textField123"
let id = editor.getFieldIdentifier(for: fieldId)

let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.update",
    _id: editor.documentID ?? "",
    identifier: editor.documentIdentifier,
    fileId: id.fileID ?? "",
    pageId: id.pageID ?? "",
    fieldId: id.fieldID,
    fieldIdentifier: nil,
    fieldPositionId: id.fieldPositionId ?? "",
    change: ["value": "Updated value"],
    createdOn: Date().timeIntervalSince1970
)

editor.change(changes: [change])
```

#### Create table row example
```swift
let tableFieldId = "tableField1"
let id = editor.getFieldIdentifier(for: tableFieldId)

let newRow = Change(
    v: 1,
    sdk: "swift",
    target: "field.value.rowCreate",
    _id: editor.documentID ?? "",
    identifier: editor.documentIdentifier,
    fileId: id.fileID ?? "",
    pageId: id.pageID ?? "",
    fieldId: id.fieldID,
    fieldIdentifier: nil,
    fieldPositionId: id.fieldPositionId ?? "",
    change: [
        "row": [
            "_id": UUID().uuidString,
            "cells": [:]
        ],
        "targetRowIndex": 0
    ],
    createdOn: Date().timeIntervalSince1970
)

editor.change(changes: [newRow])
```

#### Tips
- Use `getFieldIdentifier(for:)` to resolve the full context (page, file, position) for a field ID.
- Batch multiple changes in a single call for atomic updates.

### Events (optional)
For a deeper guide to change/focus/blur/upload/capture/error events, see [change-events.md](./change-events.md).
Provide a handler to receive `onChange`, `onFocus`, `onBlur`, uploads, and errors.
```swift
final class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: Joyfill.FieldIdentifier) {}
    func onBlur(event: Joyfill.FieldIdentifier) {}
    func onUpload(event: Joyfill.UploadEvent) {}
    func onCapture(event: Joyfill.CaptureEvent) {}
    func onError(error: Joyfill.JoyfillError) {}
}
```

### Learn more
- Swift guide: https://docs.joyfill.io/docs/swift
- API reference: https://docs.joyfill.io/docs
