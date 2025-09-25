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

### FormChangeEvent Params

- onChange: (changelogs: object_array, doc: object) => {}
  - Used to listen to any field change events.
  - changelogs: object_array
    - Can contain one or more supported changelog object types. See [changelogs](https://docs.joyfill.io/docs/changelogs).
  - doc: object
    - Fully updated JoyDoc JSON structure with changes applied.

- onFocus: (params: object, e: object) => {}
  - Used to listen to field focus events.
  - params: object — info about the focused field.
  - e: object — element helper methods.
    - blur: Function
      - Triggers the field blur event for the focused field.
      - If pending changes haven’t fired `onChange` yet, `e.blur()` triggers: 1) `onChange`, 2) `onBlur`.
      - If the focused field uses a modal (signature, image, tables, etc.), `e.blur()` closes the modal.

- onBlur: (params: object) => {}
  - Used to listen to field blur events.
  - params: object — info about the blurred field.

- onUpload: (params: object) => {}
  - Used to listen to file upload events.
  - params: object — info about the uploaded file(s).

- onError: (error: JoyfillError) => {}
  - Used to listen to errors during document processing.
  - error: JoyfillError — details about the failure.
  - Error types include:
    - schemaValidationError — Document schema validation failures
    - schemaVersionError — SDK and document version compatibility issues


> IMPORTANT: `onFocus`, `onChange`, and `onBlur` are not always called in the same order. Two different fields can trigger events at the same time. For example, focusing Field B while Field A is focused may fire Field B `onFocus` before Field A `onBlur`. Always use event params to correlate associated field events.

### Learn more
- Swift guide: https://docs.joyfill.io/docs/swift
- Changelogs: https://docs.joyfill.io/docs/changelogs
