# CLAUDE.MD - Joyfill Swift SDK

## Project Overview

This repository contains the Joyfill Swift SDK for Apple platforms (iOS 15+, macOS 10.15+). It provides comprehensive tools for displaying and interacting with Joyfill documents (forms, tables, formulas) in SwiftUI and UIKit applications.

The SDK is **SwiftUI-first** - primary support is for SwiftUI with the `Form` view component. UIKit integration is possible via hosting controllers since `DocumentEditor` conforms to `ObservableObject`.

**Primary Use Case**: Render interactive forms from JoyDoc JSON structures with built-in support for:
- Dynamic form rendering
- Real-time validation
- Formula calculations
- File uploads and camera capture
- Event-driven architecture
- Programmatic data manipulation

## Architecture

### Module Structure

The project is organized into four main Swift Package Manager targets:

1. **JoyfillModel** - Core data models
   - No external dependencies
   - Defines JoyDoc structure and field types
   - Foundation for all other modules

2. **JoyfillFormulas** - Formula evaluation engine
   - Depends on: JoyfillModel
   - Handles calculations, strings, dates, arrays, and logic
   - Includes Parser, Evaluator, and Function Registry

3. **JoyfillAPIService** - Networking layer
   - Depends on: JoyfillModel
   - Handles API communication with Joyfill backend

4. **Joyfill** (JoyfillUI) - UI components
   - Depends on: All above modules + JSONSchema.swift
   - SwiftUI and UIKit components
   - DocumentEditor for form rendering and validation

### Key Source Directories

```
Sources/
├── JoyfillModel/          # Data models and structures
├── JoyfillFormulas/       # Formula engine
│   ├── Core/
│   │   ├── Evaluator/     # Expression evaluation
│   │   ├── Parser/        # Formula parsing
│   │   ├── Functions/     # Built-in functions (Math, String, Date, Logical, Array, Higher-Order)
│   │   └── Types/         # FormulaValue types
├── JoyfillAPIService/     # API client
└── JoyfillUI/             # UI components
    └── ViewModels/        # DocumentEditor, FormulaHandler, ValidationHandler
```

### Test Structure

```
Tests/
├── JoyfillModelTests/
├── JoyfillFormulasTests/  # Includes parser, evaluator, function, and end-to-end tests
├── JoyfillAPIServiceTests/
└── JoyfillUITests/
```

## Development Guidelines

### Code Style

- Swift 5.9+ syntax
- SwiftUI-first for UI components
- Protocol-oriented design where appropriate
- Clear separation of concerns between modules

### Testing

- Unit tests for all formula functions
- Parser and evaluator tests
- End-to-end formula integration tests
- Run tests: `swift test` or use Xcode Test Navigator

### Common Tasks

**Running Tests:**
```bash
swift test
# Or specific test target:
swift test --filter JoyfillFormulasTests
```

**Building the Package:**
```bash
swift build
```

**Opening in Xcode:**
```bash
open Package.swift
```

### Key Concepts

#### JoyDoc
Standardized JSON structure for Joyfill documents containing:
- Pages with fields
- Metadata and configuration
- Files and attachments
- Form schema

Core model properties include fields, pages, file structures, and validation rules.

#### DocumentEditor
The main `ObservableObject` class for managing form documents.

**Initialization:**
```swift
init(document: JoyDoc,
     mode: Mode = .fill,
     events: FormChangeEvent? = nil,
     pageID: String? = nil,
     navigation: Bool = true,
     isPageDuplicateEnabled: Bool = true,
     validateSchema: Bool = true,
     license: String? = nil)
```

**Key Properties:**
- `document: JoyDoc` - Current document with all updates
- `allFields: [JoyDocField]` - All fields in the document
- `allFieldPositions: [FieldPosition]` - Position data for fields
- `mode: Mode` - Current mode (.fill or .readonly)
- `events: FormChangeEvent?` - Event handler for form interactions
- `schemaError: SchemaValidationError?` - Schema validation errors
- `currentPageID: String` - Currently displayed page ID
- `files: [File]` - Files associated with the document

**Key Methods:**
- `field(fieldID:)` - Get specific field by ID
- `getFieldIdentifier(for:)` - Get complete field context (essential for Change API)
- `validate()` - Validate all required fields
- `change(changes:)` - Apply programmatic changes
- `duplicatePage(pageID:)` - Duplicate a page
- Table operations: `insertRow`, `deleteRows`, `duplicateRows`, `moveRowUp`, `moveRowDown`, `bulkEdit`

#### Form Modes
- **Fill Mode (.fill)** - Default mode allowing full interaction, input, uploads, validation, and page duplication
- **Read-Only Mode (.readonly)** - Display-only mode with all fields disabled, no uploads/camera, page duplication disabled

#### Change Events
Observable events via the `FormChangeEvent` protocol:
- `onChange(changes:document:)` - Field value changes
- `onFocus(event:)` - Field gains focus
- `onBlur(event:)` - Field loses focus
- `onUpload(event:)` - File upload requested
- `onCapture(event:)` - Barcode/camera capture requested
- `onError(error:)` - Schema validation or runtime errors

See: `change-events.md`

#### Change API
Programmatic document updates using the `Change` object with these targets:
- `field.update` - Update field value
- `field.value.rowCreate` - Create table row
- `field.value.rowUpdate` - Update table row
- `field.value.rowDelete` - Delete table row
- `field.value.rowMove` - Reorder table rows

See: `document-editor.md`

#### Validation
The SDK provides automatic field validation:
- Checks required fields based on `required = true` flag
- Hidden fields are always valid
- Pages that are hidden have all fields valid
- Tables validate their required columns

```swift
let validationResult = documentEditor.validate()
if validationResult.status == .valid {
    // Form is complete
} else {
    // Use validationResult.fieldValidities for specific errors
}
```

#### Schema Validation
Validates document structure against Joyfill schema:
- `ERROR_SCHEMA_VALIDATION` - Document structure is invalid
- `ERROR_SCHEMA_VERSION` - Version incompatibility

Enable/disable during initialization:
```swift
let documentEditor = DocumentEditor(
    document: document,
    validateSchema: true // Default
)
```

Check for errors via `documentEditor.schemaError`

See: `validate.md`

#### Formulas
The JoyfillFormulas module provides:
- **Parser** - Parses formula strings into Abstract Syntax Tree (AST)
- **Evaluator** - Evaluates AST to produce FormulaValue
- **FunctionRegistry** - Manages built-in and custom functions
- **Built-in Functions**: ArrayFunctions, DateFunctions, MathFunctions, StringFunctions, LogicalFunctions, HigherOrderFunctions

## Important Files

- `Package.swift` - Swift Package Manager configuration
- `README.md` - User-facing documentation
- `CHANGELOG.md` - Release history
- `document-editor.md` - DocumentEditor API details
- `change-events.md` - Event handling guide
- `validate.md` - Schema validation guide

## Examples

- **SwiftUI Example**: `JoyfillSwiftUIExample/` - Full SwiftUI implementation
- **UIKit Example**: `JoyfillUIKitExample/` - UIKit integration
- **Flutter Example**: `joyfillflutterexample/` - Flutter platform integration

## External Dependencies

- [JSONSchema.swift](https://github.com/kylef/JSONSchema.swift) (0.6.0+) - Schema validation

## Release Process

See:
- `RELEASE_GETTING_STARTED.md` - Release workflow
- `RELEASE_AUTOMATION_SUMMARY.md` - Automation details

## Installation (Swift Package Manager)

In Xcode:
1. Select your project
2. Go to Package Dependencies tab and click +
3. Enter package URL: `https://github.com/joyfill/components-swift.git`
4. Select **Version > Up to Next Minor** for controlled updates
5. Click Add Package and confirm the target selection

**Requirements:**
- Mac running macOS
- Latest stable version of Xcode

## Quick Start Examples

### Basic Form Display (SwiftUI)

```swift
import Joyfill
import JoyfillModel

struct SimpleFormExampleView: View {
    let documentEditor: DocumentEditor
    let document = loadDoc(named: "first-form")

    init() {
        self.documentEditor = DocumentEditor(document: document)
    }

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}

private extension SimpleFormExampleView {
    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}
```

### Event Handler Implementation

```swift
final class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {
        // Persist, sync, or react to changes
        if let firstChange = changes.first {
            print(">>>>>>>>onChange", firstChange.change ?? "")
        }
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

// Usage
let handler = ChangeHandler()
let editor = DocumentEditor(document: myDocument, events: handler)
```

### Image Upload Handling

```swift
// Pattern 1: Immediate Server Upload
func onUpload(event: UploadEvent) {
    let urls: [String] = [] // from gallery, camera, or other source
    event.uploadHandler(urls)
}

// Pattern 2: Programmatic Image Replacement
func onUpload(event: UploadEvent) {
    let localURLs: [String] = [] // from gallery, camera, etc.

    // Show images immediately
    event.uploadHandler(localURLs)

    // Upload and replace in background
    for localURL in localURLs {
        uploadToServer(localURL) { serverURL in
            documentEditor?.replaceImageURL(
                newURL: serverURL,
                url: localURL,
                fieldIdentifier: event.fieldEvent
            )
        }
    }
}
```

### Programmatic Field Updates (Change API)

```swift
// Get field identifier
let fieldId = "textField123"
let id = editor.getFieldIdentifier(for: fieldId)

// Create change object
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

// Apply the change
editor.change(changes: [change])
```

### Table Row Creation

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

## Core Data Structures

### JoyfillModel Module
- `JoyDoc` - Represents a Joy document
- `JoyDocField` - Represents a field in a Joy document
- `Page` - Represents a page in a document
- `File` - Represents a file
- `FieldPosition` - Position and properties of a field
- `FieldTableColumn` - Table column structure
- `ValueElement` - Value element in tables
- `AppliedFormula` - Formula applied to field/page
- `FieldValidity`, `ColumnValidity`, `CellValidity`, `RowValidity` - Validation structures
- `Validation` - Validation rules and constraints

### Event Structures
- `FieldIdentifier` - Field context information
- `FieldChangeData` - Field change data
- `UploadEvent` - Upload event details
- `CaptureEvent` - Capture event details
- `Change` - Change object for programmatic updates

### Enumerations
- `FieldTypes` - Types of fields
- `ColumnTypes` - Types of columns
- `DateFormatType` - Date format types
- `ValidationStatus` - Validation status values
- `ValueUnion` - Different value types

## Resources

### Official Documentation
- **Getting Started**: https://docs.joyfill.io/ios/getting-started
- **Form Modes**: https://docs.joyfill.io/ios/guides/modes
- **Image Upload Handling**: https://docs.joyfill.io/ios/guides/image-upload-handling
- **Required Field Validation**: https://docs.joyfill.io/ios/guides/required-field-validation
- **Populating and Extracting Data**: https://docs.joyfill.io/ios/guides/populating-and-extracting-data
- **Schema Validation**: https://docs.joyfill.io/ios/guides/schema-validation
- **Event Handling**: https://docs.joyfill.io/ios/guides/event-handling
- **API Overview**: https://docs.joyfill.io/ios/api-reference/overview

### Swift-DocC API Reference
- **Joyfill**: https://joyfill.github.io/ios-api-reference/Joyfill/documentation/joyfill
- **JoyfillAPIService**: https://joyfill.github.io/ios-api-reference/JoyfillAPIService/documentation/joyfillapiservice
- **JoyfillFormulas**: https://joyfill.github.io/ios-api-reference/JoyfillFormulas/documentation/joyfillformulas
- **JoyfillModel**: https://joyfill.github.io/ios-api-reference/JoyfillModel/documentation/joyfillmodel

### Legacy Documentation
- **Swift setup**: https://docs.joyfill.io/docs/swift
- **API reference**: https://docs.joyfill.io/docs
- **Formulas Guide**: https://docs.joyfill.io/docs/formulas
- **Changelogs**: https://docs.joyfill.io/docs/changelogs

## Working with Claude

### Useful Context to Provide

When asking for help with this codebase:
- Specify which module you're working with (Model, Formulas, API, or UI)
- For formula issues: provide the formula expression and expected behavior
- For UI issues: mention if using SwiftUI or UIKit
- Include relevant test files when debugging

### Common Development Patterns

#### Adding a New Formula Function
1. Implement function in appropriate file in `Sources/JoyfillFormulas/Core/Functions/`
   - `MathFunctions.swift` - Mathematical operations
   - `StringFunctions.swift` - String operations
   - `DateFunctions.swift` - Date-related operations
   - `LogicalFunctions.swift` - Boolean operations
   - `ArrayFunctions.swift` - Array operations
   - `HigherOrderFunctions.swift` - Map, filter, reduce, etc.
2. Register in `FunctionRegistry.swift`
3. Add comprehensive tests in `Tests/JoyfillFormulasTests/FunctionTests/`
4. Update documentation

**Formula Function Pattern:**
```swift
// In appropriate Functions file
func myFunction(args: [FormulaValue]) throws -> FormulaValue {
    // Validate argument count
    guard args.count == expectedCount else {
        throw FormulaError.invalidArgumentCount(
            expected: expectedCount,
            got: args.count
        )
    }

    // Process arguments and return result
    // ...
}

// In FunctionRegistry.swift
register("MY_FUNCTION", implementation: myFunction)
```

#### Modifying DocumentEditor
1. **Core logic**: `Sources/JoyfillUI/ViewModels/DocumentEditor.swift`
   - Main initialization and document management
   - Field access methods
   - Table operations
   - Page management
2. **Formula integration**: `Sources/JoyfillUI/ViewModels/DocumentEditor+Formulas.swift`
   - Formula evaluation logic
   - Formula dependency tracking
3. **Validation**: `Sources/JoyfillUI/ViewModels/ValidationHandler.swift`
   - Field validation logic
   - Required field checks
   - Validation result structures

#### Working with Models
1. Define in `Sources/JoyfillModel/`
2. Ensure `Codable` conformance for JSON serialization
3. Follow existing patterns for dictionary initialization
4. Add test cases in `Tests/JoyfillModelTests/`

**Model Pattern:**
```swift
public struct MyModel: Codable {
    public let id: String
    public let value: String?

    public init(dictionary: [String: Any]) {
        self.id = dictionary["_id"] as? String ?? ""
        self.value = dictionary["value"] as? String
    }
}
```

#### Implementing Event Handlers
When creating a custom event handler, implement the `FormChangeEvent` protocol:

```swift
final class MyEventHandler: FormChangeEvent {
    func onChange(changes: [Change], document: JoyDoc) {
        // Handle field changes
        // Common use cases:
        // - Persist to database
        // - Sync with backend API
        // - Update analytics
        // - Trigger side effects
    }

    func onUpload(event: UploadEvent) {
        // Handle file uploads
        // Options:
        // 1. Upload immediately and return URLs
        // 2. Show locally, upload async, then replace URLs
        event.uploadHandler(uploadedURLs)
    }

    func onError(error: JoyfillError) {
        // Handle schema validation errors
        // Present to user or log for debugging
    }

    // Implement other required methods...
}
```

#### Working with Change API
Always use `getFieldIdentifier(for:)` to get complete field context before creating changes:

```swift
// Step 1: Get field identifier
let fieldId = "myFieldId"
guard let id = editor.getFieldIdentifier(for: fieldId) else {
    return // Field not found
}

// Step 2: Create change with all required IDs
let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.update", // or other target
    _id: editor.documentID ?? "",
    identifier: editor.documentIdentifier,
    fileId: id.fileID ?? "",
    pageId: id.pageID ?? "",
    fieldId: id.fieldID,
    fieldIdentifier: nil,
    fieldPositionId: id.fieldPositionId ?? "",
    change: ["value": newValue], // Change payload
    createdOn: Date().timeIntervalSince1970
)

// Step 3: Apply change
editor.change(changes: [change])
```

#### Testing Formula Functions
Follow the pattern in `Tests/JoyfillFormulasTests/`:

```swift
func testMyFunction() throws {
    // Arrange
    let registry = FunctionRegistry()
    let evaluator = Evaluator(
        functionRegistry: registry,
        context: testContext
    )

    // Act
    let result = try evaluator.evaluate(
        parseExpression("MY_FUNCTION(arg1, arg2)")
    )

    // Assert
    XCTAssertEqual(result, expectedValue)
}
```

## Git Workflow

- Main branch: `main`
- Current worktree branch: `suspicious-buck`
- Use conventional commits for changelog generation
- See recent commits for style examples

## Best Practices & Conventions

### Validation Best Practices
- Always call `validate()` before submitting forms
- Hidden fields are automatically considered valid
- Hidden pages have all fields considered valid
- Table validation checks required columns
- Use `validationResult.fieldValidities` for field-specific error messages

### Schema Validation
- Enable `validateSchema: true` by default in production
- Check `documentEditor.schemaError` after initialization
- Handle `ERROR_SCHEMA_VERSION` for version incompatibility
- Handle `ERROR_SCHEMA_VALIDATION` for structural issues

### Event Handler Guidelines
- Implement all `FormChangeEvent` methods (even if empty)
- Keep `onChange` handlers lightweight for performance
- For `onUpload`, choose between immediate or async upload patterns
- Always handle `onError` for graceful error recovery
- Use `onChange` for persistence and syncing

### Change API Guidelines
- Always use `getFieldIdentifier(for:)` before creating changes
- Include all required IDs: `fileId`, `pageId`, `fieldId`, `fieldPositionId`
- Use appropriate `target` for the operation type
- Batch multiple changes in a single `change(changes:)` call when possible
- Set `createdOn` to current timestamp

### Formula Development
- Validate argument counts in all formula functions
- Throw descriptive `FormulaError` for invalid inputs
- Test with edge cases (null, empty arrays, zero, negative numbers)
- Follow existing function naming conventions (UPPER_CASE)
- Document expected argument types and return types

### Performance Considerations
- Formula evaluation happens automatically on field changes
- Avoid circular formula dependencies
- Keep event handlers non-blocking
- Use async patterns for file uploads
- Consider pagination for large tables

## Platform Support

- **iOS**: 15.0+
- **macOS**: 10.15+ (primarily for JoyfillFormulas)
- **Xcode**: Compatible with Xcode 14+
- **Swift**: 5.9+

## Troubleshooting Common Issues

### Schema Validation Failures
Check `documentEditor.schemaError` for details:
- Ensure JoyDoc structure matches expected schema
- Verify version compatibility
- Use `JoyfillSchemaManager.validateSchema(document:)` for manual validation

### Formula Evaluation Issues
- Verify formula syntax using Parser directly
- Check function registration in FunctionRegistry
- Ensure all referenced fields exist
- Test with FormulaRunner CLI tool

### Change API Not Working
- Confirm field exists using `editor.field(fieldID:)`
- Verify all IDs are populated from `getFieldIdentifier(for:)`
- Check that target matches operation type
- Ensure change payload structure is correct

### Validation Not Triggering
- Verify `required` flag is set on fields
- Check if fields/pages are hidden (hidden = always valid)
- Call `validate()` explicitly when needed
- Review `FieldValidity` objects for details
