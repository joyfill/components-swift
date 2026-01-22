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
   - Contains `FieldTypes`, `ColumnTypes`, `ValidationStatus` enums
   - Defines conditional logic models

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
   - Contains Form view hierarchy and field-specific views
   - Includes ValidationHandler and ConditionalLogicHandler

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

## Form View Architecture

### View Hierarchy

The Form view follows a hierarchical structure:

```
Form (Entry point)
└── FilesView (Container for files)
    └── FileView (Single file wrapper)
        └── PagesView (Page navigation & management)
            └── PageView (Single page wrapper)
                └── FormView (List of fields)
                    └── Individual Field Views
```

### Form View Components

**Form** (`Sources/JoyfillUI/View/FormView.swift:5-25`)
- Entry point for rendering JoyDoc documents
- Takes `DocumentEditor` as initialization parameter
- Displays `SchemaErrorView` if schema validation fails
- Otherwise renders `FilesView` with document files

**FilesView**
- Container for document files
- Currently renders the first file in the document

**FileView**
- Wrapper for a single file
- Passes file's `pageOrder` and `pageFieldModels` to PagesView

**PagesView**
- Manages page navigation and selection
- Shows page navigation dropdown when `documentEditor.showPageNavigationView` is true
- Handles page duplication and deletion
- Filters pages based on conditional logic (`shouldShow(pageID:)`)
- Displays current page using `PageView`

**PageView**
- Wrapper for rendering a single page
- Passes page's field list to `FormView`

**FormView** (`Sources/JoyfillUI/View/FormView.swift:229-311`)
- Core field rendering component
- Uses SwiftUI `List` to display fields
- Implements `FieldChangeEvents` protocol for event handling
- Filters fields based on conditional logic (`shouldShow(fieldID:)`)
- Manages focus tracking with `currentFocusedFieldsID` and `lastFocusedFieldsID`
- Handles keyboard dismissal on scroll
- Provides `fieldView(listModelBinding:)` method that switches on field type

### Schema Error Handling

**SchemaErrorView** (`Sources/JoyfillUI/View/FormView.swift:27-80`)
- Displayed when schema validation fails
- Shows error code, SDK version, and schema version
- Handles two error types:
  - `ERROR_SCHEMA_VERSION`: Unsupported document version
  - `ERROR_SCHEMA_VALIDATION`: Invalid document structure

## Field Types and Organization

### Supported Field Types

The SDK supports 14 field types defined in `FieldTypes` enum:

1. **text** - Single-line text input
2. **textarea** - Multi-line text input
3. **number** - Numeric input with formatting
4. **dropdown** - Single selection from options
5. **multiSelect** - Multiple selection from options
6. **date** - Date/time picker
7. **signature** - Signature capture
8. **image** - Image upload and display
9. **block** - Display-only text block
10. **richText** - Rich text editor
11. **table** - Table with rows and columns
12. **collection** - Hierarchical nested table with schemas
13. **chart** - Data visualization
14. **unknown** - Fallback type

### Field Data Models

Each field type has a corresponding data model in `Sources/JoyfillUI/ViewModels/Models.swift`:

- `TextDataModel` - Single-line text
- `MultiLineDataModel` - Multi-line text (textarea)
- `NumberDataModel` - Numeric fields
- `DropdownDataModel` - Dropdown selections
- `MultiSelectionDataModel` - Multi-select fields
- `DateTimeDataModel` - Date/time fields
- `SignatureDataModel` - Signature fields
- `ImageDataModel` - Image fields
- `DisplayTextDataModel` - Block (display-only) fields
- `RichTextDataModel` - Rich text fields
- `TableDataModel` - Table and collection fields
- `ChartDataModel` - Chart fields

### Field List Model Structure

**FieldListModel** (`Sources/JoyfillUI/ViewModels/Models.swift:16-20`)
```swift
struct FieldListModel: Equatable {
    let fieldIdentifier: FieldIdentifier
    let fieldEditMode: Mode
    var model: FieldListModelType
}
```

**FieldListModelType** (`Sources/JoyfillUI/View/FormView.swift:168-215`)
- Enum wrapping all field data models
- Used for type-safe field rendering
- Provides `tableDataModel` computed property for table/collection access

**PageModel** (`Sources/JoyfillUI/ViewModels/Models.swift:11-14`)
```swift
struct PageModel {
    let id: String
    var fields: [FieldListModel]
}
```

### Table and Collection Fields

**RowDataModel** (`Sources/JoyfillUI/ViewModels/Models.swift:22-47`)
```swift
struct RowDataModel: Equatable, Hashable {
    let rowID: String
    var cells: [TableCellModel]
    var rowType: RowType
    var isExpanded: Bool
    var filledCellCount: Int
    var rowWidth: CGFloat
}
```

**RowType** - Enum defining row hierarchy:
- `.row(index:)` - Regular table row
- `.header(level:tableColumns:)` - Header row at specific level
- `.nestedRow(level:index:parentID:parentSchemaKey:)` - Nested row in collection
- `.tableExpander(schemaValue:level:parentID:rowWidth:)` - Row expander for nested content

**Column Types** - For table/collection columns:
- `text`, `dropdown`, `image`, `block`, `date`, `number`, `multiSelect`, `signature`

## DocumentEditor Deep Dive

### Core Architecture

**DocumentEditor** (`Sources/JoyfillUI/ViewModels/DocumentEditor.swift`) is an `ObservableObject` that:
- Manages the JoyDoc and all field state
- Coordinates between validation, formulas, and conditional logic
- Provides programmatic API for field updates
- Handles schema validation on initialization

### Internal State Management

**Key Properties:**
```swift
private(set) public var document: JoyDoc
@Published public var currentPageID: String
@Published var pageFieldModels: [String: PageModel]
var fieldMap: [String: JoyDocField]
private var fieldPositionMap: [String: FieldPosition]
public var events: FormChangeEvent?
```

**Handler Components:**
- `validationHandler: ValidationHandler` - Manages field validation
- `conditionalLogicHandler: ConditionalLogicHandler` - Controls field/page visibility
- `joyDocContext: JoyfillDocContext` - Provides context for formula evaluation

### Field Access Methods

```swift
// Get field by ID
public func field(fieldID: String?) -> JoyDocField?

// Get field position metadata
public func fieldPosition(fieldID: String?) -> FieldPosition?

// Get complete field context for Change API
public func getFieldIdentifier(for fieldID: String) -> FieldIdentifier
```

### Change API Targets

The Change API supports these target types (`Sources/JoyfillUI/ViewModels/DocumentEditor.swift:12-21`):

- `field.update` - Update field value
- `field.value.rowCreate` - Create table/collection row
- `field.value.rowUpdate` - Update table/collection row
- `field.value.rowDelete` - Delete table/collection row
- `field.value.rowMove` - Reorder table/collection rows

**Change Processing Flow:**
1. `change(changes:)` receives array of changes
2. Validates target type and field existence
3. Delegates to specific handler methods
4. For table/collection: uses `DocumentEditorDelegate` pattern
5. Refreshes field and dependent fields
6. Triggers formula re-evaluation

### Delegate Pattern for Tables

**DocumentEditorDelegate** protocol:
```swift
protocol DocumentEditorDelegate: AnyObject {
    func applyRowEditChanges(change: Change)
    func insertRow(for change: Change)
    func deleteRow(for change: Change)
    func moveRow(for change: Change)
}
```

Table and Collection ViewModels implement this protocol and register with DocumentEditor.

## Validation System

### ValidationHandler

**Location:** `Sources/JoyfillUI/ViewModels/ValidationHandler.swift`

**Core Method:**
```swift
func validate() -> Validation
```

### Validation Logic

**Field-Level Validation:**
1. Iterates through all pages in current view
2. For each page, checks if page is visible (`shouldShow(page:)`)
3. For each field, checks if field is visible (`shouldShow(fieldID:)`)
4. Hidden pages/fields are automatically considered valid
5. Only validates fields where `required = true`

**Non-Empty Check:**
- Text fields: checks `value.text` is not empty
- Number fields: checks `value.number` exists
- Multi-select/dropdown: checks array has selected values
- Tables/Collections: special validation logic

**Table Validation** (`validateTableField`):
1. Gets non-deleted rows
2. Gets visible columns (filters hidden columns)
3. For each row:
   - Validates each required column has a value
   - Builds `CellValidity` for each cell
   - Builds `RowValidity` aggregating cell validities
4. Builds `ColumnValidity` for each column
5. Returns `FieldValidity` with overall status

**Collection Validation** (`validateCollectionField`):
1. Validates root schema rows and columns
2. Recursively validates nested child schemas
3. Checks schema visibility using `shouldShowSchema(for:rowSchemaID:)`
4. Validates required nested children exist
5. Returns hierarchical `FieldValidity`

### Validation Result Structure

```swift
Validation {
    status: ValidationStatus  // .valid or .invalid
    fieldValidities: [FieldValidity]
}

FieldValidity {
    field: JoyDocField
    status: ValidationStatus
    pageId: String?
    rowValidities: [RowValidity]?
    columnValidities: [ColumnValidity]?
}

RowValidity {
    status: ValidationStatus
    cellValidities: [CellValidity]
}

ColumnValidity {
    status: ValidationStatus
    cellValidities: [CellValidity]
}

CellValidity {
    status: ValidationStatus
    row: ValueElement
    column: FieldTableColumn
    reasons: [String]?
}
```

## Conditional Logic System

### ConditionalLogicHandler

**Location:** `Sources/JoyfillUI/ViewModels/ConditionalLogicHandler.swift`

**Purpose:** Controls field and page visibility based on conditions and logic rules.

### Core Data Structures

**Cache Maps:**
```swift
var showFieldMap: [String: Bool]  // fieldID -> visibility
var showCollectionSchemaMap: [String: CollectionSchemaLogic]  // collectionFieldID -> schema visibility
var fieldConditionalDependencyMap: [String: Set<String>]  // fieldID -> dependent fieldIDs
var collectionDependencyMap: [String: CollectionDependency]  // collectionFieldID -> column dependencies
```

**CollectionSchemaLogic:**
```swift
struct CollectionSchemaLogic {
    var showSchemaMap: [RowSchemaID: Bool]  // Per-row schema visibility
}

struct RowSchemaID: Hashable {
    let rowID: String
    let schemaID: String
}
```

### Initialization

On initialization, ConditionalLogicHandler:
1. Evaluates initial visibility for all fields
2. Builds dependency maps for field conditions
3. For collection fields:
   - Builds column dependency map
   - Builds initial schema visibility map for all rows

### Conditional Logic Evaluation

**shouldShow Methods:**
```swift
func shouldShow(fieldID: String?) -> Bool
func shouldShow(pageID: String?) -> Bool
func shouldShow(page: Page?) -> Bool
func shouldShowSchema(for collectionFieldID: String, rowSchemaID: RowSchemaID) -> Bool
```

**Condition Evaluation Flow:**
1. Extracts logic and conditions from field/page
2. Builds `ConditionalLogicModel` with:
   - Logic (id, action, eval)
   - Conditions array
   - Item hidden state
3. Evaluates each condition using `compareValue`
4. Combines results based on eval type ("and" or "or")
5. Applies action ("show" or "hide")

**Supported Condition Operators:**
- `=` - Equals (case-insensitive for text)
- `!=` - Not equals
- `?=` - Contains (text only)
- `>` - Greater than (numbers only)
- `<` - Less than (numbers only)
- `null=` - Is empty/null
- `*=` - Is not empty/null

**Logic Actions:**
- `show` - Show if conditions match
- `hide` - Hide if conditions match

**Logic Eval:**
- `and` - All conditions must match
- `or` - Any condition must match

### Dependency Tracking and Refresh

**Field Dependencies:**
When field A's value changes:
1. `fieldsNeedsToBeRefreshed(fieldID:)` finds dependent fields
2. Re-evaluates visibility for each dependent
3. Updates `showFieldMap` cache
4. Returns list of fields that need UI refresh

**Collection Schema Dependencies:**
When collection cell changes:
1. `updateSchemaVisibility` checks if column affects any schemas
2. Re-evaluates affected schema visibility
3. Updates `showCollectionSchemaMap` cache

### Collection-Specific Logic

**Schema Conditions:**
- Reference column values within the same row
- Use `columnID` instead of `fieldID`
- Evaluated per-row, per-schema

**Nested Hierarchies:**
- Supports multi-level nested schemas
- Each level can have its own conditional logic
- Visibility cascades: parent hidden = children hidden

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

## Practical Implementation Patterns

### Working with Field Visibility

**Check if a field should be displayed:**
```swift
if documentEditor.shouldShow(fieldID: "myFieldId") {
    // Render field
}
```

**Check if a page should be displayed:**
```swift
if documentEditor.shouldShow(pageID: "pageId") {
    // Render page
}
```

**Check if a collection schema should be shown:**
```swift
let rowSchemaID = RowSchemaID(rowID: "row123", schemaID: "schema456")
if documentEditor.shouldShowSchema(for: "collectionFieldId", rowSchemaID: rowSchemaID) {
    // Show nested schema
}
```

### Working with Table/Collection Rows

**Insert a new row:**
```swift
let change = Change(
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
            "cells": [:],  // Empty cells or pre-filled values
            "deleted": false
        ],
        "targetRowIndex": 0  // Insert at index 0
    ],
    createdOn: Date().timeIntervalSince1970
)
editor.change(changes: [change])
```

**Update a row's cell:**
```swift
let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.value.rowUpdate",
    // ... other required fields
    change: [
        "rowId": "row123",
        "columnId": "column456",
        "value": ["text": "Updated value"]
    ],
    createdOn: Date().timeIntervalSince1970
)
```

**Delete a row:**
```swift
let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.value.rowDelete",
    // ... other required fields
    change: [
        "rowId": "row123"
    ],
    createdOn: Date().timeIntervalSince1970
)
```

### Implementing Conditional Logic

**Field with conditional logic:**
```json
{
  "_id": "field123",
  "type": "text",
  "hidden": false,
  "logic": {
    "id": "logic1",
    "action": "show",
    "eval": "and",
    "conditions": [
      {
        "field": "otherFieldId",
        "condition": "=",
        "value": { "text": "Yes" }
      }
    ]
  }
}
```

**Collection schema with conditional logic:**
```json
{
  "schemaKey": {
    "hidden": false,
    "logic": {
      "action": "show",
      "eval": "or",
      "schemaConditions": [
        {
          "columnID": "statusColumn",
          "schema": "parentSchemaKey",
          "condition": "=",
          "value": { "text": "Active" }
        }
      ]
    }
  }
}
```

### Custom Field Rendering

**Extend FormView for custom field types:**
```swift
extension FormView {
    @ViewBuilder
    func customFieldView(for model: FieldListModel) -> some View {
        switch model.model {
        case .text(let textModel):
            CustomTextView(model: textModel)
        default:
            fieldView(listModelBinding: .constant(model))
        }
    }
}
```

### Validation Workflow

**Validate before submission:**
```swift
let validation = documentEditor.validate()

if validation.status == .valid {
    // Submit form
    submitDocument(documentEditor.document)
} else {
    // Show validation errors
    for fieldValidity in validation.fieldValidities where fieldValidity.status == .invalid {
        print("Invalid field: \(fieldValidity.field.id ?? "unknown")")

        // For tables, check row/column validities
        if let rowValidities = fieldValidity.rowValidities {
            for (index, rowValidity) in rowValidities.enumerated() where rowValidity.status == .invalid {
                print("  Row \(index) has invalid cells")
            }
        }
    }
}
```

**Display field-specific errors:**
```swift
ForEach(validation.fieldValidities, id: \.field.id) { fieldValidity in
    if fieldValidity.status == .invalid {
        VStack {
            Text("Field: \(fieldValidity.field.title ?? "Untitled")")
            Text("Status: Invalid")
                .foregroundColor(.red)

            // Show cell-level errors for tables
            if let rowValidities = fieldValidity.rowValidities {
                ForEach(rowValidities.indices, id: \.self) { rowIndex in
                    if rowValidities[rowIndex].status == .invalid {
                        Text("Row \(rowIndex + 1) has errors")
                    }
                }
            }
        }
    }
}
```

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
