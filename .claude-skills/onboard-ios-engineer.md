# Joyfill iOS SDK Onboarding Guide

**Skill Name:** onboard-ios-engineer
**Description:** Comprehensive onboarding guide for new iOS engineers joining the Joyfill Swift SDK team
**When to use:** Run this when a new iOS engineer needs to understand the codebase architecture, setup their development environment, and learn key patterns

---

## Welcome to the Joyfill iOS SDK Team!

This interactive onboarding guide will help you understand the Joyfill Swift SDK codebase, set up your development environment, and learn the key patterns used throughout the project.

## Prerequisites Check

Before we begin, let's verify you have everything installed:

**Required:**
- Mac running macOS
- Latest stable version of Xcode (14+)
- Git configured with your credentials
- Swift 5.9+ (comes with Xcode)

**Recommended:**
- Familiarity with SwiftUI
- Understanding of Swift Package Manager
- Basic knowledge of reactive programming (Combine/ObservableObject)

## Section 1: Project Overview

### What is Joyfill?

The Joyfill Swift SDK is a comprehensive toolkit for building interactive form applications on Apple platforms (iOS 15+, macOS 10.15+). It provides:

- **Dynamic Form Rendering** - Render complex forms from JSON (JoyDoc)
- **Real-time Validation** - Field, table, and collection validation
- **Formula Engine** - Spreadsheet-like calculations with 50+ built-in functions
- **Conditional Logic** - Show/hide fields based on user input
- **Event-Driven Architecture** - React to form changes in real-time
- **File Uploads** - Image and document handling

### Architecture at a Glance

The SDK is organized into **4 Swift Package Manager modules**:

```
1. JoyfillModel (Foundation)
   ↓
2. JoyfillFormulas (Formula Engine)
   ↓  ↘
3. JoyfillAPIService   4. Joyfill (UI Layer)
   (Networking)           (SwiftUI Components)
```

**Module Responsibilities:**

- **JoyfillModel**: Core data models, no dependencies
- **JoyfillFormulas**: Parser, Evaluator, Function Registry
- **JoyfillAPIService**: HTTP client for Joyfill API
- **Joyfill (JoyfillUI)**: SwiftUI views, DocumentEditor, validation, conditional logic

## Section 2: Getting Started

### Clone and Setup

```bash
# Clone the repository
git clone https://github.com/joyfill/components-swift.git
cd components-swift

# Open in Xcode
open Package.swift

# Build the package
# In Xcode: Cmd+B
# Or via command line:
swift build
```

### Run Tests

```bash
# Run all tests
swift test

# Run specific module tests
swift test --filter JoyfillFormulasTests
swift test --filter JoyfillUITests
```

### Explore Example Apps

The repo includes 3 example applications:

1. **JoyfillSwiftUIExample/** - Full SwiftUI implementation
2. **JoyfillUIKitExample/** - UIKit integration example
3. **joyfillflutterexample/** - Flutter platform example

**Action Item:** Open and run the SwiftUI example app to see the SDK in action.

## Section 3: Core Concepts

### 1. JoyDoc - The Data Model

Everything revolves around `JoyDoc` - a standardized JSON structure representing a form document.

**Structure:**
```
JoyDoc
├── files: [File]
│   ├── pages: [Page]
│   │   └── fields: [JoyDocField]
├── fieldPositions: [FieldPosition]
└── metadata
```

**Example JoyDoc:**
```json
{
  "_id": "doc123",
  "name": "Contact Form",
  "files": [{
    "pages": [{
      "name": "Page 1",
      "fields": [
        { "_id": "field1", "type": "text", "title": "Name" },
        { "_id": "field2", "type": "email", "title": "Email" }
      ]
    }]
  }]
}
```

### 2. DocumentEditor - The Central Controller

`DocumentEditor` is an `ObservableObject` that manages everything:

```swift
let documentEditor = DocumentEditor(
    document: joyDoc,
    mode: .fill,              // or .readonly
    events: eventHandler,      // Your event callbacks
    validateSchema: true       // Validate on init
)
```

**Key Responsibilities:**
- Manages JoyDoc state
- Coordinates validation, formulas, conditional logic
- Provides Change API for programmatic updates
- Handles schema validation

**Important Properties:**
```swift
documentEditor.document       // Current JoyDoc
documentEditor.allFields      // All fields
documentEditor.currentPageID  // Active page
documentEditor.schemaError    // Validation errors
```

**Key Methods:**
```swift
documentEditor.field(fieldID:)           // Get field
documentEditor.validate()                 // Run validation
documentEditor.change(changes:)          // Update fields
documentEditor.shouldShow(fieldID:)      // Check visibility
```

### 3. Form View Hierarchy

The UI follows this hierarchy:

```
Form (Entry)
 └─ FilesView
     └─ FileView
         └─ PagesView (Navigation)
             └─ PageView
                 └─ FormView (Field List)
                     └─ Individual Field Views
```

**Rendering a Form:**
```swift
import Joyfill
import JoyfillModel

struct MyFormView: View {
    let documentEditor: DocumentEditor

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}
```

### 4. Field Types (14 Types)

The SDK supports 14 field types:

| Field Type | Description | Use Case |
|------------|-------------|----------|
| text | Single-line input | Names, emails |
| textarea | Multi-line input | Comments, descriptions |
| number | Numeric input | Quantities, prices |
| dropdown | Single selection | Country, status |
| multiSelect | Multiple selection | Tags, categories |
| date | Date/time picker | Birthdate, deadline |
| signature | Signature capture | Legal agreements |
| image | Image upload | Photos, documents |
| block | Display-only text | Instructions |
| richText | Rich text editor | Formatted content |
| table | Rows and columns | Line items |
| collection | Nested hierarchical table | Complex data |
| chart | Data visualization | Analytics |
| unknown | Fallback | Error handling |

## Section 4: Key Systems Deep Dive

### System 1: Validation

**How it works:**
1. `DocumentEditor.validate()` returns `Validation` object
2. Iterates through all visible pages and fields
3. Checks `required = true` fields for values
4. Hidden fields/pages are always valid
5. Tables/Collections have special validation logic

**Example:**
```swift
let validation = documentEditor.validate()

if validation.status == .valid {
    // Form is complete - submit it
    submitForm(documentEditor.document)
} else {
    // Show errors to user
    for fieldValidity in validation.fieldValidities {
        if fieldValidity.status == .invalid {
            print("Field \(fieldValidity.field.id ?? "") is invalid")
        }
    }
}
```

**Location:** `Sources/JoyfillUI/ViewModels/ValidationHandler.swift`

### System 2: Conditional Logic

**Purpose:** Show/hide fields and pages based on conditions

**How it works:**
1. `ConditionalLogicHandler` evaluates logic on init
2. Builds cache maps for field/page visibility
3. Re-evaluates when dependent fields change
4. Supports 7 operators: `=`, `!=`, `?=`, `>`, `<`, `null=`, `*=`

**Example Logic:**
```json
{
  "logic": {
    "action": "show",
    "eval": "and",
    "conditions": [
      {
        "field": "countryFieldId",
        "condition": "=",
        "value": { "text": "USA" }
      }
    ]
  }
}
```

**Usage:**
```swift
if documentEditor.shouldShow(fieldID: "stateField") {
    // Only show state field if country is USA
}
```

**Location:** `Sources/JoyfillUI/ViewModels/ConditionalLogicHandler.swift`

### System 3: Formulas

**Components:**
- **Parser:** Converts formula strings to AST
- **Evaluator:** Executes AST to produce values
- **FunctionRegistry:** 50+ built-in functions

**Function Categories:**
- Math: SUM, ROUND, CEIL, FLOOR, POW, SQRT, MOD
- String: CONCAT, UPPER, LOWER, LENGTH, CONTAINS, FIND
- Date: NOW, DATE, DATE_ADD, DATE_SUBTRACT, YEAR, MONTH, DAY
- Logical: IF, AND, OR, NOT, EMPTY
- Array: MAP, FILTER, REDUCE, FLAT, SOME, EVERY
- Higher-order: MAP, FILTER, REDUCE, FLAT_MAP

**Example:**
```swift
// Formula in JoyDoc field
{
  "formula": "SUM(MAP(table.column, LAMBDA(x, x.quantity * x.price)))"
}
```

**Location:** `Sources/JoyfillFormulas/Core/`

### System 4: Change API

**Purpose:** Programmatically update fields

**5 Change Targets:**
- `field.update` - Update field value
- `field.value.rowCreate` - Create table row
- `field.value.rowUpdate` - Update table row
- `field.value.rowDelete` - Delete table row
- `field.value.rowMove` - Reorder table rows

**Pattern:**
```swift
// Step 1: Get field context
let id = editor.getFieldIdentifier(for: "fieldId")

// Step 2: Create change
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
    change: ["value": "New Value"],
    createdOn: Date().timeIntervalSince1970
)

// Step 3: Apply change
editor.change(changes: [change])
```

## Section 5: Common Development Tasks

### Task 1: Add a New Formula Function

**Steps:**
1. Choose the appropriate file in `Sources/JoyfillFormulas/Core/Functions/`
2. Implement the function following this pattern:

```swift
func myFunction(args: [FormulaValue]) throws -> FormulaValue {
    // Validate args
    guard args.count == 2 else {
        throw FormulaError.invalidArgumentCount(expected: 2, got: args.count)
    }

    // Extract values
    guard case .number(let a) = args[0],
          case .number(let b) = args[1] else {
        throw FormulaError.invalidArgumentType
    }

    // Compute result
    return .number(a + b)
}
```

3. Register in `FunctionRegistry.swift`:
```swift
register("MY_FUNCTION", implementation: myFunction)
```

4. Add tests in `Tests/JoyfillFormulasTests/FunctionTests/`

### Task 2: Implement Event Handler

**Create a class conforming to `FormChangeEvent`:**

```swift
final class MyEventHandler: FormChangeEvent {
    func onChange(changes: [Change], document: JoyDoc) {
        // Called when field values change
        // Use for: persistence, sync, analytics
    }

    func onFocus(event: FieldIdentifier) {
        // Field gained focus
    }

    func onBlur(event: FieldIdentifier) {
        // Field lost focus
    }

    func onUpload(event: UploadEvent) {
        // File upload requested
        // Option 1: Upload to server immediately
        uploadToServer(event.files) { urls in
            event.uploadHandler(urls)
        }

        // Option 2: Show local, upload async
        event.uploadHandler(localURLs)
        asyncUpload(localURLs) { remoteURLs in
            replaceURLs(local: localURLs, remote: remoteURLs)
        }
    }

    func onCapture(event: CaptureEvent) {
        // Camera/barcode capture
    }

    func onError(error: JoyfillError) {
        // Handle schema validation errors
    }
}
```

### Task 3: Add Conditional Logic to a Field

**In JoyDoc JSON:**
```json
{
  "_id": "phoneField",
  "type": "text",
  "title": "Phone Number",
  "logic": {
    "action": "show",
    "eval": "and",
    "conditions": [
      {
        "field": "countryField",
        "condition": "=",
        "value": { "text": "USA" }
      },
      {
        "field": "contactMethodField",
        "condition": "=",
        "value": { "text": "Phone" }
      }
    ]
  }
}
```

**Testing:**
The field will only show when:
- Country = "USA" AND ContactMethod = "Phone"

### Task 4: Create a Table Row Programmatically

```swift
let tableFieldId = "lineItemsTable"
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
            "cells": [
                "itemNameColumn": ["text": "Widget"],
                "quantityColumn": ["number": 5],
                "priceColumn": ["number": 9.99]
            ],
            "deleted": false
        ],
        "targetRowIndex": 0
    ],
    createdOn: Date().timeIntervalSince1970
)

editor.change(changes: [newRow])
```

## Section 6: File Organization

### Key Files to Know

**Core Documentation:**
- `CLAUDE.MD` - Comprehensive technical reference (YOU ARE HERE!)
- `README.md` - User-facing documentation
- `CHANGELOG.md` - Release history
- `document-editor.md` - DocumentEditor API details
- `change-events.md` - Event handling guide
- `validate.md` - Schema validation guide

**Source Files (Top Priority):**

| File | Purpose |
|------|---------|
| `Sources/JoyfillUI/View/FormView.swift` | Form rendering hierarchy |
| `Sources/JoyfillUI/ViewModels/DocumentEditor.swift` | Main controller |
| `Sources/JoyfillUI/ViewModels/ValidationHandler.swift` | Validation logic |
| `Sources/JoyfillUI/ViewModels/ConditionalLogicHandler.swift` | Show/hide logic |
| `Sources/JoyfillUI/ViewModels/Models.swift` | Field data models |
| `Sources/JoyfillModel/DocumentModel.swift` | Core data types |
| `Sources/JoyfillFormulas/Core/Functions/` | Formula functions |

### Test Files

```
Tests/
├── JoyfillModelTests/          # Model unit tests
├── JoyfillFormulasTests/       # Formula tests
│   ├── FunctionTests/          # Individual function tests
│   └── FormulaEndToEndTests.swift
├── JoyfillUITests/             # UI tests
└── JoyfillAPIServiceTests/     # API tests
```

## Section 7: Best Practices

### Validation Best Practices
✅ Always call `validate()` before submitting forms
✅ Hidden fields are automatically valid
✅ Use `fieldValidities` for field-specific errors
✅ Tables validate required columns only

### Change API Best Practices
✅ Always use `getFieldIdentifier(for:)` first
✅ Include all required IDs
✅ Batch multiple changes when possible
✅ Set `createdOn` to current timestamp

### Formula Development Best Practices
✅ Validate argument counts
✅ Throw descriptive errors
✅ Test edge cases (null, empty, zero, negative)
✅ Use UPPER_CASE naming convention
✅ Document expected types

### Event Handler Best Practices
✅ Implement all protocol methods
✅ Keep `onChange` lightweight
✅ Handle `onError` gracefully
✅ Use async patterns for uploads

### Performance Considerations
⚡ Formulas evaluate automatically on changes
⚡ Avoid circular dependencies
⚡ Keep event handlers non-blocking
⚡ Use async for file operations
⚡ Consider pagination for large tables

## Section 8: Troubleshooting

### Issue: Schema Validation Fails

**Symptoms:** `documentEditor.schemaError` is not nil

**Solutions:**
1. Check `schemaError.code`:
   - `ERROR_SCHEMA_VERSION`: Document version incompatible
   - `ERROR_SCHEMA_VALIDATION`: Structure invalid
2. Use `JoyfillSchemaManager.validateSchema(document:)` for details
3. Verify JoyDoc matches expected schema

### Issue: Formula Not Evaluating

**Symptoms:** Formula field shows no value

**Solutions:**
1. Verify formula syntax using Parser directly
2. Check function is registered in FunctionRegistry
3. Ensure all referenced fields exist
4. Test with FormulaRunner CLI: `Sources/FormulaRunner/main.swift`
5. Check formula dependencies aren't circular

### Issue: Validation Not Triggering

**Symptoms:** `validate()` returns `.valid` when it shouldn't

**Solutions:**
1. Verify `required = true` on fields
2. Check if field/page is hidden (hidden = always valid)
3. Call `validate()` explicitly
4. Review `FieldValidity` objects for details

### Issue: Change API Not Working

**Symptoms:** `change(changes:)` has no effect

**Solutions:**
1. Confirm field exists: `editor.field(fieldID:)`
2. Verify all IDs from `getFieldIdentifier(for:)`
3. Check target matches operation type
4. Validate change payload structure
5. Check console for error logs

## Section 9: Useful Resources

### Official Documentation
- **Getting Started**: https://docs.joyfill.io/ios/getting-started
- **Form Modes**: https://docs.joyfill.io/ios/guides/modes
- **Validation**: https://docs.joyfill.io/ios/guides/required-field-validation
- **Event Handling**: https://docs.joyfill.io/ios/guides/event-handling
- **Schema Validation**: https://docs.joyfill.io/ios/guides/schema-validation

### API Reference (Swift-DocC)
- **Joyfill**: https://joyfill.github.io/ios-api-reference/Joyfill/documentation/joyfill
- **JoyfillFormulas**: https://joyfill.github.io/ios-api-reference/JoyfillFormulas/documentation/joyfillformulas
- **JoyfillModel**: https://joyfill.github.io/ios-api-reference/JoyfillModel/documentation/joyfillmodel

### Internal Documentation
- `CLAUDE.MD` - Complete technical reference (1,290 lines!)
- `document-editor.md` - DocumentEditor API
- `change-events.md` - Event system
- `validate.md` - Validation guide

### Git Workflow
- Main branch: `main`
- Use conventional commits
- See recent commits for style examples
- Create feature branches from `main`

## Section 10: Your First Contribution

### Starter Tasks (Pick One)

**Easy:**
1. Add a new math formula function (e.g., `ABS`, `SIGN`)
2. Add unit tests for existing formula functions
3. Fix typos or improve code comments

**Medium:**
1. Add validation for a new field type
2. Implement a new conditional logic operator
3. Add integration tests for Change API

**Advanced:**
1. Optimize formula evaluation performance
2. Add new field type support
3. Improve conditional logic caching

### Contribution Workflow

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes and test
swift test

# 3. Commit with conventional commit message
git add .
git commit -m "feat: add ABS function to math operations

- Implement ABS function for absolute values
- Add comprehensive tests
- Update function registry

Co-Authored-By: Your Name <your.email@example.com>"

# 4. Push and create PR
git push origin feature/your-feature-name
gh pr create --title "Add ABS function" --body "..."
```

## Congratulations! 🎉

You now have a comprehensive understanding of the Joyfill iOS SDK codebase!

### Next Steps:
1. ✅ Set up your development environment
2. ✅ Run the example apps
3. ✅ Read through key source files
4. ✅ Pick a starter task
5. ✅ Make your first contribution

### Questions?
- Check `CLAUDE.MD` for detailed technical info
- Review example apps for real-world usage
- Look at existing tests for patterns
- Ask your team for guidance

**Welcome to the team! Happy coding! 🚀**
