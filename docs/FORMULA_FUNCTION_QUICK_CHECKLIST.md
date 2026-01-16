# Adding a New Formula Function Test - Quick Checklist

## 1. JSON Setup

- [ ] Copy JSON from `Formulas jsons joydocs/<function>.json` to:
  ```
  Sample JSONs/Formula-sample/Functions/FormulaTemplate_<FunctionName>.json
  ```
- [ ] **Fix syntax**: Replace `===` with `==` (parser only supports `==`)
- [ ] Add JSON to Xcode → **JoyfillExample target** (Copy Bundle Resources)

---

## 2. Create Swift Test File

- [ ] Create file:
  ```
  JoyfillTests/Formula/Functions/FormulaTemplate_<FunctionName>Tests.swift
  ```
- [ ] Add to Xcode → **JoyfillTests target**

### Test Template:
```swift
import XCTest
import JoyfillModel
import Joyfill

class FormulaTemplate_<FunctionName>Tests: XCTestCase {
    
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
    
    // Static test
    func testBasicCase() {
        let result = documentEditor.value(ofFieldWithIdentifier: "<field-id>")
        XCTAssertEqual(result?.text ?? "", "<expected>")
    }
    
    // Dynamic test
    func testDynamicUpdate() {
        documentEditor.updateValue(for: "<field-id>", value: .string("value"))
        let result = documentEditor.value(ofFieldWithIdentifier: "<output-field>")
        XCTAssertEqual(result?.text ?? "", "<expected>")
    }
}
```

### Test Categories:
- [ ] Static evaluation (initial values)
- [ ] Dynamic updates (value changes → formula recalculates)
- [ ] Boundary conditions (edge cases)
- [ ] Sequence tests (multiple changes)

---

## 3. Update Example App

- [ ] Add entry in `FormulaFunctionTestsView.swift`:
```swift
let formulaFunctions: [...] = [
    // existing...
    ("<function>()", "FormulaTemplate_<FunctionName>", "<description>"),
]
```

---

## 4. Test & Commit

```bash
# Run tests
xcodebuild test \
  -scheme JoyfillTests \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -only-testing:JoyfillTests/FormulaTemplate_<FunctionName>Tests

# Commit
git add -A && git commit -m "Add unit tests for <function>() formula function"
```

---

## Key APIs

### Reading Values
```swift
documentEditor.value(ofFieldWithIdentifier: "<field-id>")?.text    // String
documentEditor.value(ofFieldWithIdentifier: "<field-id>")?.number  // Double
```

### Updating Values (triggers formula re-evaluation)
```swift
documentEditor.updateValue(for: "<field-id>", value: .string("text"))
documentEditor.updateValue(for: "<field-id>", value: .int(42))
documentEditor.updateValue(for: "<field-id>", value: .double(3.14))
documentEditor.updateValue(for: "<field-id>", value: .bool(true))
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| `syntaxError: Operator '=' cannot be used` | Replace `===` with `==` in JSON |
| `Could not find JSON file in bundle` | Add JSON to JoyfillExample target |
| `0 tests executed` | Add Swift file to JoyfillTests target |
| Formula not recalculating | Use `updateValue(for:value:)` method |

---

## File Locations

```
components-swift/JoyfillSwiftUIExample/
├── JoyfillExample/
│   ├── Sample JSONs/Formula-sample/Functions/
│   │   └── FormulaTemplate_<FunctionName>.json    ← JSON here
│   └── Function tests/
│       └── FormulaFunctionTestsView.swift         ← Update list here
└── JoyfillTests/Formula/Functions/
    └── FormulaTemplate_<FunctionName>Tests.swift  ← Tests here
```

