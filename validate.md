## Schema validation

Overview of schema and version checks (separate from `DocumentEditor.validate()` which checks field-level rules like required, formats, etc.).

### Ways to validate (schema)

1) Automatic (recommended)
```swift
import Joyfill
import JoyfillModel

let editor = DocumentEditor(
    document: myDocument,
    validateSchema: true
)

if let error = editor.schemaError {
    // handle schema/version issues
}
```

2) Manual (on-demand)
```swift
import Joyfill
import JoyfillModel

let manager = JoyfillSchemaManager()
if let error = manager.validateSchema(document: myDocument) {
    // handle error (e.g., show message, block submit)
}
```

### Features
- Automatic schema validation on initialization (when enabled)
- Version compatibility checks (document vs SDK)
- Detailed error reporting
- Graceful handling: optional error UI for invalid docs

### Error handling example
```swift
// Check for validation errors
if let error = documentEditor.schemaError {
    switch error.code {
    case "ERROR_SCHEMA_VERSION":
        print("Unsupported document version")
    case "ERROR_SCHEMA_VALIDATION":
        print("Schema validation failed: \(error.message)")
    default:
        print("Unknown validation error")
    }
}

// Disable validation (not recommended for production)
let documentEditor = DocumentEditor(
    document: myDocument,
    validateSchema: false  // Skip validation
)
```

### Learn more
- Swift guide: https://docs.joyfill.io/docs/swift
- API reference: https://docs.joyfill.io/docs
