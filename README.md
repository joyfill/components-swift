![joyfill_logo](https://github.com/joyfill/examples/assets/5873346/4943ecf8-a718-4c97-a917-0c89db014e49)

# @joyfill/components-swift
We recommend visiting our official Swift setup guide https://docs.joyfill.io/docs/swift.

We offer three libraries for Swift entirely built in Swift and SwiftUI:

  **Joyfill**: The main library for integrating Joyfill into your Swift app. This library includes all the necessary UI components for displaying and interacting with Joyfill documents, including advanced features like formulas, collection fields, and comprehensive table operations.

  **JoyFillModel**: A library for integrating Joyfill models into your Swift app with full support for advanced field types and data structures.

  **JoyfillAPIService**: A library for all the network interactions with the Joyfill API.

  **JoyfillFormulas**: A powerful formula engine supporting mathematical operations, string functions, date calculations, array operations, and conditional logic.

## Project Requirements
Note userAccessTokens & identifiers will need to be stored on your end (usually on a user and set of existing form field-based data) in order to interact with our API and UI Components effectively

See our [API Documentation](https://docs.joyfill.io/docs) for more information on how to interact with our API.

- Minimum deployment target to iOS 15

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
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeHandler, pageID: "your_Page_Id", navigation: true, isPageDuplicateEnabled: true, validateSchema: true, license: "your_license")
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
The DocumentEditor is a key component of the Joyfill SDK, offering comprehensive features such as document editing, conditional logic, validation, page navigation, field event handling, formula evaluation, collection fields, advanced table operations, and schema validation. It provides easy to use functions to access and modify documents seamlessly. Additionally, any document updates made using the helper functions in the DocumentEditor automatically trigger change events.

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
    validateSchema: true,       // Enable schema validation
    license: "your_license"     // License token for enabling collection field
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
* `license: String?`
  * Optional license token for enabling advanced features.
  * Required for collection field functionality and other premium features.
  
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

## `Functions`

### Core Document Functions

### 1. `change(changes: [Change])`
**Primary method for programmatically modifying documents**

Applies multiple changes to the document automically. This is the most powerful and flexible way to modify document data, supporting field updates, table/collection row operations, and complex document modifications.

#### Supported Change Types:
- `field.update` - Update field values
- `field.value.rowCreate` - Create new table/collection rows
- `field.value.rowUpdate` - Update existing table/collection rows  
- `field.value.rowDelete` - Delete table/collection rows
- `field.value.rowMove` - Move/reorder table/collection rows

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

**4. Create Nested Collection Row:**
```swift
let fieldId = "collectionField1"
let fieldIdentifier = documentEditor.getFieldIdentifier(for: fieldId)
let schemas = field?.schema ?? [:]
let rootSchemaKey = schemas.first(where: { $0.value.root == true })?.key ?? ""
let field = documentEditor.field(fieldID: fieldId)
let existingRows = field?.valueToValueElements ?? []
let targetSchemaID = schemas[rootSchemaKey]?.children?.first ?? "" // Add your target schema ID here
let parentRowId = existingRows.first?.id ?? ""
let parentPath = documentEditor.computeParentPath(targetParentId: parentRowId, nestedKey: targetSchemaID, in: [rootSchemaKey : existingRows]) ?? ""

let nestedRowChange = Change(
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
        "parentPath": parentPath,
        "schemaId": targetSchemaID,
        "targetRowIndex": 0
    ],
    createdOn: Date().timeIntervalSince1970
)

documentEditor.change(changes: [nestedRowChange])
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

**Basic Usage (from CreateRowUISample.swift):**
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

### Supported Function Categories

#### Mathematical Functions
- `SUM(array)` - Sum of array elements
- `COUNT(array)` - Count of array elements  
- `AVG(array)` - Average of array elements
- `MAX(array)` - Maximum value in array
- `MIN(array)` - Minimum value in array
- `ROUND(number, digits)` - Round to specified decimal places
- `CEIL(number)` - Round up to nearest integer
- `FLOOR(number)` - Round down to nearest integer
- `POW(base, exponent)` - Power calculation
- `SQRT(number)` - Square root
- `MOD(dividend, divisor)` - Modulo operation

#### String Functions
- `CONCAT(strings...)` - Concatenate strings
- `LENGTH(string)` - Length of string
- `UPPER(string)` - Convert to uppercase
- `LOWER(string)` - Convert to lowercase
- `TRIM(string)` - Remove whitespace
- `CONTAINS(string, substring)` - Check if string contains substring
- `JOIN(array, separator)` - Join array elements with separator
- `TOSTRING(value)` - Convert value to string
- `TONUMBER(string)` - Convert string to number

#### Date Functions  
- `NOW()` - Current date and time
- `DATE(year, month, day)` - Create date
- `YEAR(date)` - Extract year from date
- `MONTH(date)` - Extract month from date
- `DAY(date)` - Extract day from date
- `DATEADD(date, value, unit)` - Add time to date
- `DATESUBTRACT(date, value, unit)` - Subtract time from date
- `TIMESTAMP(date)` - Convert date to timestamp

#### Array Functions
- `MAP(array, function)` - Transform array elements
- `FILTER(array, condition)` - Filter array elements
- `REDUCE(array, function, initial)` - Reduce array to single value
- `FIND(array, condition)` - Find first matching element
- `SOME(array, condition)` - Check if any element matches
- `EVERY(array, condition)` - Check if all elements match
- `COUNTIF(array, condition)` - Count elements matching condition
- `UNIQUE(array)` - Get unique elements
- `FLAT(array)` - Flatten nested arrays
- `FLATMAP(array, function)` - Map and flatten
- `SORT(array, compareFunction)` - Sort array elements

#### Logical Functions
- `IF(condition, trueValue, falseValue)` - Conditional logic
- `AND(conditions...)` - Logical AND
- `OR(conditions...)` - Logical OR  
- `NOT(condition)` - Logical NOT
- `EMPTY(value)` - Check if value is empty
- `EQUALS(value1, value2)` - Compare values for equality

### Formula Usage Example

```swift
// Formulas are defined in field configurations and automatically evaluated
// Example field with formula:
{
  "id": "totalField",
  "type": "number", 
  "formulas": [
    {
      "id": "calc1",
      "key": "value",
      "formula": "SUM(MAP(tableField, LAMBDA(row, row.quantity * row.price)))"
    }
  ]
}

// Formulas can reference other fields by their identifier
// Example: "SUM(field1, field2, field3)"
// Example: "IF(status = 'active', quantity * price, 0)"
```

## Collection Fields

Collection fields provide hierarchical data structures with nested schemas and conditional logic support.

### Key Features
- **Nested Data Structure**: Support for parent-child relationships with multiple levels
- **Dynamic Schemas**: Different row types with varying column configurations  
- **Conditional Logic**: Show/hide schemas based on field values
- **Advanced Operations**: Full CRUD operations on nested data

### Supported Column Types
Collection fields support the following column types:
- `text` - Text input columns
- `number` - Numeric input columns  
- `dropdown` - Single selection dropdowns
- `multiSelect` - Multiple selection fields
- `date` - Date/time picker columns
- `image` - Image upload columns
- `block` - Display-only text columns
- `signature` - Digital signature columns
- `barcode` - Barcode scanning columns

### Collection Schema Structure

```swift
// Example collection field configuration
{
  "type": "collection",
  "schema": {
    "rootSchema": {
      "root": true,
      "columns": [
        {"id": "name", "type": "text", "title": "Name"},
        {"id": "category", "type": "dropdown", "title": "Category"}
      ],
      "children": ["detailSchema"]
    },
    "detailSchema": {
      "root": false,
      "columns": [
        {"id": "detail", "type": "text", "title": "Detail"},
        {"id": "value", "type": "number", "title": "Value"}
      ],
      "logic": {
        "schemaConditions": [
          {
            "columnID": "category", 
            "condition": "EQUALS(category, 'premium')"
          }
        ]
      }
    }
  }
}
```


## Change API

The Change API provides programmatic control over document modifications with support for various change types.

### Change Types
- `field.update` - Update field values
- `field.value.rowCreate` - Create new table/collection rows
- `field.value.rowUpdate` - Update existing table/collection rows  
- `field.value.rowDelete` - Delete table/collection rows
- `field.value.rowMove` - Move/reorder table/collection rows

### Change Object Structure

```swift
public struct Change {
    public var id: String?           // Change identifier
    public var target: String?       // Change type (e.g., "field.update")
    public var fieldId: String?      // Target field ID
    public var pageId: String?       // Target page ID  
    public var fileId: String?       // Target file ID
    public var change: [String: Any]? // Change-specific data
    public var createdOn: Double?    // Timestamp
}
```

// Apply changes to document
documentEditor.change(changes: [fieldChange, rowCreateChange])
```

## Table and Collection Column Types

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
- `progress` - Progress bar visualization

### Collection-Specific Features
Collection fields additionally support:
- **Hierarchical Schemas**: Multiple schema types per collection
- **Conditional Schema Display**: Show/hide schemas based on parent data
- **Nested Operations**: CRUD operations on child data structures
- **Dynamic Column Configuration**: Different column sets per schema type
```

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

## License-Based Features

Certain advanced features require a valid license token:

### Collection Fields
- Requires valid license with `collectionField: true` claim
- Without license, collection fields are hidden from the UI
- License validation uses RS256 JWT signature verification

### License Usage

```swift
let documentEditor = DocumentEditor(
    document: myDocument,
    license: "your_jwt_license_token"
)

// Collection fields will be enabled if license is valid
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
- **Collection Field** (`collection`) - Hierarchical data with nested schemas (requires license)
- **Chart Field** (`chart`) - Data visualization and charting
- **Rich Text Field** (`richText`) - Formatted text with HTML support

### Display Fields
- **Block Field** (`block`) - Read-only text display with styling options
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

### Table and Collection Field Events

*  **Table** and **Collection**
    *  `onFocus` is fired when "view" button is pressed and modal is displayed.
    *  `onBlur` is fired when modal is closed.
    *  `onChange` is fired when table/collection data is modified (rows added, deleted, moved, or cell values changed).
    
    ### Cell-Level Events (Table/Collection Columns)
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
    * **Progress Cell** (Display-only)
        *  No interactive events as this is a read-only progress indicator.

**IMPORTANT NOTE:** JoyDoc SDK `onFocus`, `onChange` and `onBlur` events are not always called in the same order. Two different fields can be triggering events at the same time.  For instance, if you have Field A focused and then focus on Field B, the Field B onFocus event could be fired before the Field A onBlur event. Always check the event params object ids to match up the associated field events.


