![joyfill_logo](https://github.com/joyfill/examples/assets/5873346/4943ecf8-a718-4c97-a917-0c89db014e49)

# @joyfill/components-swift
We recommend visiting our official Swift setup guide https://docs.joyfill.io/docs/swift.

We offer three libraries for Swift entirely built in Swift and SwiftUI:

  **Joyfill**: The main library for integrating Joyfill into your Swift app. This library includes all the necessary UI components for displaying and interacting with Joyfill documents, including advanced features like formulas, and comprehensive table operations.

  **JoyFillModel**: A library for integrating Joyfill models into your Swift app with full support for advanced field types and data structures.

  **JoyfillAPIService**: A library for all the network interactions with the Joyfill API.

  **JoyfillFormulas**: A powerful formula engine supporting mathematical operations, string functions, date calculations, array operations, and conditional logic.

See our [API Documentation](https://docs.joyfill.io/docs) for more information on how to interact with our API.

## Install Dependency


Add Joyfill SDKs to your app
Use Swift Package Manager to install and manage Joyfill dependencies.

In Xcode, with your app project open, navigate to File > Add Packages.
When prompted, add the Joyfill Apple platforms SDK repository:

```
  https://github.com/joyfill/components-swift
```

Select the SDK version that you want to use.

Note: We recommend using the default (latest) SDK version, but you can choose an older version if needed.
Choose the Joyfill libraries you want to use.

When finished, Xcode will automatically begin resolving and downloading your dependencies in the background.

## Getting Started

### Show a Joyfill Document with SwiftUI `Form` view

```swift
import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    let documentEditor: DocumentEditor
    let changeHandler = ChangeHandler()
    
    init(document: JoyDoc) {
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeHandler, pageID: "your_Page_Id", navigation: true, isPageDuplicateEnabled: true, validateSchema: true)
    }

    var body: some View {
        Form(documentEditor: documentEditor)
    }
}
class ChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: Joyfill.FieldIdentifier) {}
    func onBlur(event: Joyfill.FieldIdentifier) {}
    func onUpload(event: Joyfill.UploadEvent) {}
    func onCapture(event: Joyfill.CaptureEvent) {}
    func onError(error: Joyfill.JoyfillError) {}
}
```

### See our example project for more details.

SwiftUI example at [/JoyfillSwiftUIExample](https://github.com/joyfill/components-swift/tree/main/JoyfillSwiftUIExample)
UIKit example at [/JoyfillUIKitExample](https://github.com/joyfill/components-swift/tree/main/JoyfillUIKitExample)
Flutter example at [/joyfillflutterexample](https://github.com/joyfill/components-swift/tree/main/joyfillflutterexample)

### `DocumentEditor`
The DocumentEditor is a key component of the Joyfill SDK, offering comprehensive features such as document editing, conditional logic, validation, page navigation, field event handling, formula evaluation, advanced table operations, and schema validation. It provides easy to use functions to access and modify documents seamlessly. Additionally, any document updates made using the helper functions in the DocumentEditor automatically trigger change events.

Below is an overview of its key components and usage:

```swift
import Joyfill
import JoyfillModel

let documentEditor = DocumentEditor(
    document: myDocument,        // Your JoyDoc instance
    mode: .fill,                 // The editor mode (fill or readonly)
    events: myChangeManager,     // Custom FormChangeEvent instance
    pageID: "your_page_ID",      // Optional: Page ID to start with
    navigation: true,            // Whether to show the page navigation view
    isPageDuplicateEnabled: true, // Enable page duplication functionality
    validateSchema: true       // Enable schema validation
)

```
## `Params`
* `mode: 'fill' | 'readonly'`
  * Enables and disables certain JoyDoc functionality and features. 
  * Default is `fill`.
  * Options
    * `fill` is the mode where you simply input the field data into the form
    * `readonly` is the mode where everything in the form is set to read-only.
* `document: JoyDoc`
  * The JoyDoc JSON object to load into the SDK. Must be in the JoyDoc JSON data structure.
  * The SDK uses object reference equality checks to determine if the `doc` or any of its internal `pages` or `fields` have changed in the JSON. Ensure you're creating new object instances when updating the document, pages, or fields before passing the updated `doc` JSON back to the SDK. This will ensure your changes are properly detected and reflected in the SDK.
* `pageID: String`
  * Specify the the page to display in the form. 
  * Utilize the `_id` property of a Page object. For instance, `page._id`.
  * If page is not found within the `doc` it will fallback to displaying the first page in the `pages` array.
  * You can use this property to navigate to a specific page in the form.
* `events: FormChangeEvent`
  * Used to listen to form events.
* `isPageDuplicateEnabled: Bool`
  * Enables page duplication functionality. Default is `false`.
  * When enabled, users can duplicate existing pages with all their fields and configurations.
* `validateSchema: Bool`
  * Enables automatic schema validation for the document. Default is `true`.
  * When enabled, validates document structure against the current SDK schema version.
  
## `Properties`
* `currentPageID: String`
  * Represents the unique identifier of the current page being displayed.
  * Changing this value will update the displayed page in the document.
* `document: JoyDoc`
  * The current document being edited (read-only access).
* `schemaError: SchemaValidationError?`
  * Contains schema validation error information if validation fails.
* `mode: Mode`
  * The current editing mode (fill or readonly).
* `isPageDuplicateEnabled: Bool`
  * Whether page duplication is enabled.
* `showPageNavigationView: Bool`
  * Whether page navigation UI is shown.
  
```swift
  // Example of changing the current page
documentEditor.currentPageID = "newPageID"

// Check for schema validation errors
if let error = documentEditor.schemaError {
    print("Schema validation failed: \(error.message)")
}
```

## `FormChangeEvent Params`
* `onChange: (changelogs: object_array, doc: object) => {}` 
  * Used to listen to any field change events.
  * `changelogs: object_array`
    * Can contain one ore more of the changelog object types supported. [Learn more about changelogs](https://docs.joyfill.io/docs/changelogs)
  * `doc: object`
    * Fully updated JoyDoc JSON structure with changes applied.
* `onFocus: (params: object, e: object) => {}`
  * Used to listen to field focus events.
  * `params: object`
    * Specifies information about the focused field.
  * `e: object`
    * Element helper methods.
    * `blur: Function`
      * Triggers the field blur event for the focused field.
      * If there are pending changes in the field that have not triggered the `onChange` event yet then the `e.blur()` function will trigger both the change and blur events in the following order: 1) `onChange` 2) `onBlur`.
      * If the focused field utilizes a modal for field modification, ie. signature, image, tables, etc. the `e.blur()` will close the modal.
* `onBlur: (params: object) => {}`
  * Used to listen to field focus events.
  * `params: object`
    * Specifies information about the blurred field.
* `onUpload: (params: object) => {}`
  * Used to listen to file upload events.
  * `params: object`
    * Specifies information about the uploaded file.
* `onError: (error: JoyfillError) => {}`
  * Used to listen to error events that occur during document processing.
  * `error: JoyfillError`
    * Error object containing details about the failure.
    * Error types include:
      * `schemaValidationError` - Document schema validation failures
      * `schemaVersionError` - SDK and document version compatibility issues

## `Functions`

### Core Document Functions

### 1. `change(changes: [Change])`
**Primary method for programmatically modifying documents**

Applies multiple changes to the document automically. This is the most powerful and flexible way to modify document data, supporting field updates, table row operations, and complex document modifications.

#### Supported Change Types:
- `field.update` - Update field values
- `field.value.rowCreate` - Create new table rows
- `field.value.rowUpdate` - Update existing table rows  
- `field.value.rowDelete` - Delete table rows
- `field.value.rowMove` - Move/reorder table rows

#### Change Object Creation:

```swift
// Method 1: Using dictionary constructor
let change = Change(dictionary: [
    "_id": "change_id",
    "v": 1,
    "sdk": "swift", 
    "target": "field.update",
    "fieldId": "field123",
    "identifier" : "doc_identifier",
    "fieldIdentifier" : "field_identifier",
    "fieldPositionId" : "field_PositionId",
    "pageId": "page456",
    "fileId": "file789",
    "change": ["value": newValue],
    "createdOn": Date().timeIntervalSince1970
])

// Method 2: Using structured constructor  
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)

let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.update",
    _id: documentEditor.documentID ?? "",
    identifier: documentEditor.documentIdentifier,
    fileId: fieldIdentifier.fileID ?? "",
    pageId: fieldIdentifier.pageID ?? "",
    fieldId: fieldIdentifier.fieldID,
    fieldIdentifier: field?.identifier,
    fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
    change: ["value": newValue],
    createdOn: Date().timeIntervalSince1970
)
```

#### Essential Change API Examples:

**1. Field Update:**
```swift
let fieldId = "textField123"
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
let field = documentEditor.field(fieldID: fieldId)

let change = Change(
    v: 1,
    sdk: "swift",
    target: "field.update",
    _id: documentEditor.documentID ?? "",
    identifier: documentEditor.documentIdentifier,
    fileId: fieldIdentifier.fileID ?? "",
    pageId: fieldIdentifier.pageID ?? "",
    fieldId: fieldIdentifier.fieldID,
    fieldIdentifier: field?.identifier,
    fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
    change: ["value": "Updated field value"],
    createdOn: Date().timeIntervalSince1970
)

documentEditor.change(changes: [change])
```

**2. Create Table Row:**
```swift
let fieldId = "tableField1"
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
let field = documentEditor.field(fieldID: fieldId)

let newRowChange = Change(
    v: 1,
    sdk: "swift",
    target: "field.value.rowCreate",
    _id: documentEditor.documentID ?? "",
    identifier: documentEditor.documentIdentifier,
    fileId: fieldIdentifier.fileID ?? "",
    pageId: fieldIdentifier.pageID ?? "",
    fieldId: fieldIdentifier.fieldID,
    fieldIdentifier: field?.identifier,
    fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
    change: [
        "row": [
            "_id": UUID().uuidString,
            "cells": [:]
        ],
        "targetRowIndex": 0
    ],
    createdOn: Date().timeIntervalSince1970
)

documentEditor.change(changes: [newRowChange])
```

**3. Update Table Row:**
```swift
let fieldId = "tableField1"
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
let field = documentEditor.field(fieldID: fieldId)

let updateRowChange = Change(
    v: 1,
    sdk: "swift",
    target: "field.value.rowUpdate",
    _id: documentEditor.documentID ?? "",
    identifier: documentEditor.documentIdentifier,
    fileId: fieldIdentifier.fileID ?? "",
    pageId: fieldIdentifier.pageID ?? "",
    fieldId: fieldIdentifier.fieldID,
    fieldIdentifier: field?.identifier,
    fieldPositionId: fieldIdentifier.fieldPositionId ?? "",
    change: [
        "rowId": "existingRowId",
        "row": [
            "_id": "existingRowId",
            "cells": [:]
        ]
    ],
    createdOn: Date().timeIntervalSince1970
)

documentEditor.change(changes: [updateRowChange])
```

### 2. `validate() -> Validation`
* Validates the current document and returns a Validation object with field-level validation results.
* Usage: `let validationResult = documentEditor.validate()`

### 3. `shouldShow(fieldID: String?) -> Bool`
* Determines if a field should be shown based on conditional logic.
* Usage: `let isFieldVisible = documentEditor.shouldShow(fieldID: "someFieldID")`

### 4. `shouldShow(pageID: String?) -> Bool`
* Determines if a page should be shown based on conditional logic.
* Usage: `let isPageVisible = documentEditor.shouldShow(pageID: "somePageID")`

### 5. `shouldShow(page: Page?) -> Bool`
* Determines if a given Page object should be shown based on conditional logic.
* Usage: `let isPageVisible = documentEditor.shouldShow(page: somePage)`

### 6. `duplicatePage(pageID: String)`
* Duplicates an entire page with all its fields and configurations.
* Usage: `documentEditor.duplicatePage(pageID: "pageID")`

### 7. `getFieldIdentifier(for fieldID: String) -> FieldIdentifier`
**Essential method for obtaining complete field identification information**

Returns a complete `FieldIdentifier` object that contains all the necessary information to uniquely identify a field within the document structure. This method is crucial when working with the Change API or other operations that require complete field context.

#### What it does:
- Takes a field ID string and returns a complete `FieldIdentifier` object
- Automatically resolves the field's page ID, file ID, and field position ID
- Searches through all pages to find where the field is positioned
- Provides fallback identification if field position is not found

#### Implementation Details:
The method performs the following steps:
1. Gets the file ID from the field's data
2. Iterates through all pages in the current view
3. Searches for field positions that match the given field ID
4. Returns a complete `FieldIdentifier` with all context information
5. Falls back to basic identification if field position is not found

#### Usage Examples:

**Basic Usage:**
```swift
let fieldId = "6857510fbfed1553e168161b"
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)

// Now you have complete field identification
print("Field ID: \(fieldIdentifier.fieldID)")
print("Page ID: \(fieldIdentifier.pageID ?? "unknown")")
print("File ID: \(fieldIdentifier.fileID ?? "unknown")")
print("Field Position ID: \(fieldIdentifier.fieldPositionId ?? "unknown")")
```

#### Returned FieldIdentifier Properties:
```swift
public struct FieldIdentifier {
    public let fieldID: String           // The original field ID (always present)
    public var pageID: String?           // ID of the page containing the field
    public var fileID: String?           // ID of the file containing the field
    public var fieldPositionId: String?  // ID of the field's position on the page
    public var fieldIdentifier: String?  // The field's identifier property
    public var _id: String?             // Document ID (optional)
    public var identifier: String?      // Document identifier (optional)
}
```

### FieldIdentifier - Uniquely identifies the field

```swift
// Example of creating a FieldIdentifier manually
let fieldIdentifier = FieldIdentifier(fieldID: "field123", pageID: "page45", fileID: "file678")

// Recommended: Use getFieldIdentifier instead
let fieldIdentifier = documentEditor.getFieldIdentifier(for: "field123")
```

## Formula (JoyfillFormulas)

The Joyfill SDK includes a powerful formula engine that supports a wide range of functions for dynamic calculations and data manipulation.

### Formula Usage Examples

#### Number Field with Basic Formula
```json
  "fields": [
    {
      "file": "6850502ad5b54e6d8570fbbf",
      "_id": "number1",
      "type": "number",
      "title": "Number1",
      "identifier": "field_68521ca1ceefb7c6c622024b",
      "value": 10
    },
    {
      "file": "6850502ad5b54e6d8570fbbf",
      "_id": "number2",
      "type": "number",
      "title": "Add 100 to number1",
      "identifier": "field_number2",
      "formulas": [
        {
          "_id": "AF_add100",
          "formula": "add100",
          "key": "value"
        }
      ]
    }
  ]
  "formulas": [
    {
      "_id": "add100",
      "desc": "Add 100 to number1",
      "type": "calc",
      "scope": "private",
      "expression": "number1 + 100"
    }
  ]
```
## Quick Demo

![Joyfill Form Demo](https://github.com/user-attachments/assets/dc1358b1-b5cd-40fd-bbc2-eeadab3b2416)

## Schema Validation

The SDK includes comprehensive schema validation to ensure document compatibility and data integrity.

### Features
- **Automatic Validation**: Documents are validated on initialization
- **Version Compatibility**: Checks SDK and schema version compatibility  
- **Error Reporting**: Detailed error messages for validation failures
- **Graceful Handling**: SDK displays error UI for invalid documents

### Schema Validation Error Handling

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

## Field Types

The Joyfill SDK supports a comprehensive set of field types for various data input and display needs:

### Basic Input Fields
- **Text Field** (`text`) - Single-line text input
- **Textarea Field** (`textarea`) - Multi-line text input  
- **Number Field** (`number`) - Numeric input with validation
- **Date Field** (`date`) - Date/time picker with customizable formats

### Selection Fields  
- **Dropdown Field** (`dropdown`) - Single selection from predefined options
- **Multi-Select Field** (`multiSelect`) - Multiple selection from predefined options

### Media Fields
- **Image Field** (`image`) - Image upload and display with multiple file support
- **Signature Field** (`signature`) - Digital signature capture

### Advanced Fields
- **Table Field** (`table`) - Structured data with rows and columns
- **Chart Field** (`chart`) - Data visualization and charting
- **Rich Text Field** (`richText`) - Formatted text with HTML support

### Display Fields
- **Block Field** (`block`) - Read-only text display with styling options

## Field Events

### Standard Field Events

* **Text**, **Textarea**, **Number**
    *  `onFocus(params: object, e: object)` is fired when the field is focused.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the field is blurred.
*  **Date**, **Dropdown**
    *  `onFocus` is fired when the field is pressed and selection modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the field is blurred and the selection modal is closed.
*  **Multiselect**
    *  `onFocus` is fired when an option is selected or unselected for the first time on the field.
    *  `onChange` is fired when an option is selected or unselected in the field.
*  **Chart**
    *  `onFocus` is fired when "view" button is pressed and modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when modal is closed.
*  **Image**
    *  `onFocus` is fired when "view" button is pressed and modal is displayed.
        *  An empty image field that is focused will also trigger the `onUploadAsync` request.
        *  A populated image field that is focused will trigger the image modal to open.
    *  `onChange` is fired when the field images are uploaded or removed.
    *  `onBlur` is fired when modal is closed.
* **Signature**
    *  `onFocus` is fired when open modal button is pressed and modal is displayed.
    *  `onChange` is fired when the field value is modified.
    *  `onBlur` is fired when the modal is closed.
        

## Table Column Types

### Standard Table Columns
Tables support the following column types:
- `text` - Text input columns
- `number` - Numeric input with validation
- `dropdown` - Single selection from predefined options
- `multiSelect` - Multiple selection from predefined options  
- `date` - Date/time picker with format options
- `image` - Image upload and display
- `block` - Read-only display text
- `signature` - Digital signature capture
- `barcode` - Barcode scanning and display

### Table Field Events

*  **Table**
    *  `onFocus` is fired when "view" button is pressed and modal is displayed.
    *  `onBlur` is fired when modal is closed.
    *  `onChange` is fired when table data is modified (rows added, deleted, moved, or cell values changed).
    
    ### Cell-Level Events (Table Columns)
    * **Text Cell**
        * `onChange` is fired when the cell value is modified.
    * **Number Cell**
        * `onChange` is fired when the numeric value is modified.
    * **Dropdown Cell**
        *  `onChange` is fired when the selected value is modified.
    * **Multi-Select Cell**
        *  `onChange` is fired when selection options are modified.
    * **Date Cell**
        *  `onChange` is fired when the date value is modified.
    * **Image Cell**
        *  `onChange` is fired when the cell images are uploaded or removed.
    * **Signature Cell**
        *  `onChange` is fired when the signature is captured or modified.
    * **Block Cell** (Display-only)
        *  No interactive events as this is a read-only display cell.
    * **Barcode Cell**
        *  `onChange` is fired when barcode data is captured.

**IMPORTANT NOTE:** JoyDoc SDK `onFocus`, `onChange` and `onBlur` events are not always called in the same order. Two different fields can be triggering events at the same time.  For instance, if you have Field A focused and then focus on Field B, the Field B onFocus event could be fired before the Field A onBlur event. Always check the event params object ids to match up the associated field events.


