# Formula Function Testing Guide

This document provides a complete reference for implementing unit tests for formula functions in the Joyfill iOS project.

---

## Overview

Formula functions (like `if()`, `sum()`, `concat()`, etc.) are tested by:
1. Creating a JoyDoc JSON file with test fields and formulas
2. Creating a Swift test file that loads the JSON and validates formula results
3. Testing both **static evaluation** (initial load) and **dynamic updates** (value changes)

---

## File Structure

### JSON Test Data Location
```
components-swift/JoyfillSwiftUIExample/JoyfillExample/
└── Sample JSONs/
    └── Formula-sample/
        └── Functions/
            └── FormulaTemplate_<FunctionName>.json
```

### Swift Test File Location
```
components-swift/JoyfillSwiftUIExample/JoyfillTests/
└── Formula/
    └── Functions/
        └── FormulaTemplate_<FunctionName>Tests.swift
```

### Example App Integration
```
components-swift/JoyfillSwiftUIExample/JoyfillExample/
└── FormulaFunctionTestsView.swift  (lists all formula function tests)
```

---

## Step-by-Step Implementation

### Step 1: Create the JSON Test Data

Create a JoyDoc JSON file with:
- Document metadata (`_id`, `identifier`, `name`, etc.)
- Input fields (fields that formulas depend on)
- Output fields (fields with formulas that compute results)
- Formula definitions

**JSON Structure Template:**

```json
{
  "_id": "unique-document-id",
  "identifier": "document-<function-name>-test",
  "name": "<Function Name> Test",
  "files": [
    {
      "_id": "file-id",
      "name": "<Function Name> Test",
      "pages": [
        {
          "_id": "page-id",
          "name": "Test Page",
          "hidden": false,
          "width": 800.0,
          "height": 1000.0,
          "rowHeight": 0.5,
          "layout": "grid",
          "presentation": "normal",
          "cols": 8.0,
          "fieldPositions": [
            // Field positions for each field
          ]
        }
      ],
      "pageOrder": ["page-id"],
      "styles": {}
    }
  ],
  "fields": [
    // Input fields (no formulas)
    // Output fields (with formulas)
  ],
  "type": "document",
  "deleted": false,
  "createdOn": 1763364243718,
  "formulas": [
    // Formula definitions
  ]
}
```

**Field Types for Testing:**

| Field Type | Use Case |
|------------|----------|
| `number` | Numeric input for calculations |
| `text` | Text input or formula output |
| `dropdown` | Selection-based conditions |
| `multiSelect` | Multiple selection conditions |

**Formula Definition Structure:**

```json
{
  "_id": "formula-unique-id",
  "desc": "formula-description",
  "scope": "private",
  "type": "calc",
  "expression": "if(condition, true_value, false_value)"
}
```

**Linking Formula to Field:**

```json
{
  "_id": "output-field-id",
  "title": "Output Field Title",
  "identifier": "field-identifier",
  "formulas": [
    {
      "_id": "link-id",
      "formula": "formula-unique-id",  // References formula._id
      "key": "value"  // Updates the field's value
    }
  ],
  "type": "text",
  "file": "file-id"
}
```

---

### Step 2: Create the Swift Test File

**Test File Template:**

```swift
//
//  FormulaTemplate_<FunctionName>Tests.swift
//  JoyfillTests
//

import XCTest
import Foundation
import JoyfillModel
import Joyfill

/// Tests for the `<functionName>()` formula function
/// <Description of what the function does>
/// Syntax: <functionName>(param1, param2, ...)
class FormulaTemplate_<FunctionName>Tests: XCTestCase {

    // MARK: - Setup & Teardown
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_<FunctionName>")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }

    override func tearDown() {
        documentEditor = nil
        super.tearDown()
    }
    
    // MARK: - Static Evaluation Tests
    
    /// Test description
    func testBasicCase() {
        print("\n🔀 Test: <description>")
        print("Formula: <formula expression>")
        print("Expected: <expected result>")
        
        let result = documentEditor.value(ofFieldWithIdentifier: "<field-id>")
        let resultValue = result?.text ?? ""  // or .number for numeric results
        print("🎯 Result: \(resultValue)")
        
        XCTAssertEqual(resultValue, "<expected>", "<assertion message>")
    }
    
    // MARK: - Dynamic Update Tests
    
    /// Test dynamic value update
    func testDynamicUpdate() {
        print("\n🔀 Test: Dynamic update")
        
        // Initial state
        var result = documentEditor.value(ofFieldWithIdentifier: "<output-field>")
        XCTAssertEqual(result?.text ?? "", "<initial-value>", "Initial state")
        
        // Update input field
        documentEditor.updateValue(for: "<input-field>", value: .<valueType>(<new-value>))
        
        // Verify formula recalculated
        result = documentEditor.value(ofFieldWithIdentifier: "<output-field>")
        XCTAssertEqual(result?.text ?? "", "<expected-after-update>", "After update")
    }
}
```

---

### Step 3: Key APIs

**Reading Field Values:**
```swift
// Get field value by field ID
let result = documentEditor.value(ofFieldWithIdentifier: "<field-id>")

// Access different value types
result?.text      // String value
result?.number    // Double value
result?.multiSelector  // [String] for multi-select
```

**Updating Field Values (triggers formula re-evaluation):**
```swift
// Update with string value
documentEditor.updateValue(for: "<field-id>", value: .string("value"))

// Update with integer
documentEditor.updateValue(for: "<field-id>", value: .int(42))

// Update with double
documentEditor.updateValue(for: "<field-id>", value: .double(3.14))
```

**The `sampleJSONDocument` Helper:**
```swift
// Loads JSON from Bundle.main
let document = sampleJSONDocument(fileName: "FormulaTemplate_<Name>")
// Note: File must be added to JoyfillExample target's bundle resources
```

---

### Step 4: Test Categories

#### A. Static Evaluation Tests
Test that formulas evaluate correctly when the document loads.

- **Basic case**: Test the simplest use of the function
- **Edge cases**: Boundary values, empty inputs, null/undefined
- **Complex expressions**: Nested functions, multiple parameters
- **Error handling**: Invalid inputs, undefined references

#### B. Dynamic Update Tests
Test that formulas recalculate when dependent fields change.

- **Single update**: Change one field, verify result
- **Boundary updates**: Test values at boundaries (e.g., =16, >16)
- **Multiple updates**: Sequential changes
- **Type switching**: Change between different valid values

---

### Step 5: Add to Example App (Optional)

Update `FormulaFunctionTestsView.swift`:

```swift
let formulaFunctions: [(name: String, fileName: String, description: String)] = [
    ("if()", "FormulaTemplate_IfFunction", "Conditional logic"),
    ("<functionName>()", "FormulaTemplate_<FunctionName>", "<description>"),
    // Add more...
]
```

---

### Step 6: Xcode Project Setup

1. **Add JSON file to bundle:**
   - Drag JSON to `JoyfillExample` folder in Xcode
   - Add to `JoyfillExample` target
   - Ensure "Copy Bundle Resources" includes the file

2. **Add Swift test file:**
   - Drag Swift file to `JoyfillTests/Formula/Functions/` in Xcode
   - Add to `JoyfillTests` target

---

### Step 7: Run Tests

```bash
# Run specific test class
xcodebuild test \
  -scheme JoyfillTests \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -only-testing:JoyfillTests/FormulaTemplate_<FunctionName>Tests

# Run specific test method
xcodebuild test \
  -scheme JoyfillTests \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -only-testing:JoyfillTests/FormulaTemplate_<FunctionName>Tests/testMethodName
```

---

## Complete Example: if() Function

### JSON File (`FormulaTemplate_IfFunction.json`)

```json
{
  "_id": "691acd933d90ecfb16a51b62",
  "identifier": "document-if-function-test",
  "name": "If Function Test",
  "fields": [
    {
      "_id": "age",
      "title": "Age",
      "identifier": "field_age",
      "type": "number",
      "value": 30.0
    },
    {
      "_id": "intermediate_example",
      "title": "Voting Eligibility",
      "formulas": [
        {
          "_id": "formula-link-id",
          "formula": "formula-id",
          "key": "value"
        }
      ],
      "type": "text"
    }
  ],
  "formulas": [
    {
      "_id": "formula-id",
      "expression": "if(age > 16, 'Can Vote', 'Cannot Vote')"
    }
  ]
}
```

### Test File (`FormulaTemplate_IfFunctionTests.swift`)

```swift
class FormulaTemplate_IfFunctionTests: XCTestCase {
    
    private var documentEditor: DocumentEditor!

    override func setUp() {
        super.setUp()
        let document = sampleJSONDocument(fileName: "FormulaTemplate_IfFunction")
        documentEditor = DocumentEditor(document: document, validateSchema: false)
    }
    
    // Static test
    func testIfWithComparisonGreaterThan() {
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Can Vote")  // age=30 > 16
    }
    
    // Dynamic test
    func testDynamicUpdateAgeUnder16() {
        documentEditor.updateValue(for: "age", value: .int(10))
        
        let result = documentEditor.value(ofFieldWithIdentifier: "intermediate_example")
        XCTAssertEqual(result?.text ?? "", "Cannot Vote")  // 10 is not > 16
    }
}
```

---

## Test Coverage Checklist

For each formula function, ensure you test:

### Static Evaluation
- [ ] Basic usage with valid inputs
- [ ] All parameter combinations
- [ ] Edge cases (empty, null, zero, negative)
- [ ] Error cases (invalid types, undefined references)
- [ ] Nested function calls
- [ ] Complex expressions

### Dynamic Updates
- [ ] Single field update → formula recalculates
- [ ] Boundary values (exactly at threshold)
- [ ] Values just above/below boundary
- [ ] Sequential updates (multiple changes)
- [ ] Switch between different valid values
- [ ] Reset to initial value

---

## Troubleshooting

### Common Issues

1. **"Could not find JSON file in bundle"**
   - Ensure file is added to JoyfillExample target
   - Check file is in "Copy Bundle Resources" build phase

2. **Formula not recalculating on update**
   - Verify `updateValue(for:value:)` is called (not direct field manipulation)
   - Check `joyDocContext.updateDependentFormulas()` is being called

3. **Test fails with unexpected value**
   - Add print statements to debug
   - Check formula expression syntax
   - Verify field IDs match between JSON and test

4. **Dropdown/MultiSelect comparisons fail**
   - Use display value (e.g., "Male") not option ID
   - The formula engine resolves to display values

---

## Files Created for if() Function

```
📁 components-swift/JoyfillSwiftUIExample/
├── 📁 JoyfillExample/
│   ├── 📁 Sample JSONs/Formula-sample/Functions/
│   │   └── 📄 FormulaTemplate_IfFunction.json
│   └── 📄 FormulaFunctionTestsView.swift
└── 📁 JoyfillTests/Formula/Functions/
    └── 📄 FormulaTemplate_IfFunctionTests.swift

Total: 16 test cases (6 static + 10 dynamic)
```

---

## Git Commits for Reference

```
f9599266 - Add unit tests for if() formula function
e478a034 - Fix if() function tests to match actual behavior  
d98a091d - Add Formula Function Tests option to example app
ed11dae2 - Fix dynamic formula re-evaluation on value update
4c72544f - Add comprehensive dynamic update tests
```

---

*Last updated: November 26, 2025*

