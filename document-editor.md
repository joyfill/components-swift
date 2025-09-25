## DocumentEditor

A lightweight overview of the core editing context used by Joyfill to render and modify documents in SwiftUI.

### What it is
- Manages a `JoyDoc` and exposes helpers to read/update it
- Powers the SwiftUI `Form(documentEditor:)` view
- Handles visibility rules, validation, formulas, and table operations under the hood

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

// Validate
let result = editor.validate()
```

### Events (optional)
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
