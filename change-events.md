## Change Events (FormChangeEvent)

Implement `FormChangeEvent` to observe edits and UI interactions across fields and tables.

### Implement handler
```swift
import Joyfill
import JoyfillModel

final class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {
        // Persist, sync, or react to changes
    }

    func onFocus(event: Joyfill.FieldIdentifier) {
        // Field focused
    }

    func onBlur(event: Joyfill.FieldIdentifier) {
        // Field blurred
    }

    func onUpload(event: Joyfill.UploadEvent) {
        // File(s) uploaded/removed
    }

    func onCapture(event: Joyfill.CaptureEvent) {
        // Media captured (e.g., camera)
    }

    func onError(error: Joyfill.JoyfillError) {
        // Schema validation/version or runtime errors
    }
}
```

### Wire up
```swift
let handler = ChangeHandler()
let editor = DocumentEditor(document: myDocument, events: handler)
```

### Notes
- Event order can interleave across fields; rely on event IDs to correlate.
- `onChange` includes the full updated `JoyDoc` for immediate UI sync.

### Learn more
- Swift guide: https://docs.joyfill.io/docs/swift
- Changelogs: https://docs.joyfill.io/docs/changelogs
