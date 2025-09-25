## change(changes: [Change])

Programmatic updates to a JoyDoc via the `DocumentEditor`. Apply multiple updates in one call.

### Supported targets (common)
- `field.update` — update field value
- `field.value.rowCreate` — create a table row
- `field.value.rowUpdate` — update a table row
- `field.value.rowDelete` — delete a table row
- `field.value.rowMove` — reorder table rows

### Field update example
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

### Create table row example
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

### Tips
- Use `getFieldIdentifier(for:)` to resolve the full context (page, file, position) for a field ID.
- Batch multiple changes in a single call for atomic updates.

### Learn more
- Changelogs: https://docs.joyfill.io/docs/changelogs
- Swift guide: https://docs.joyfill.io/docs/swift
