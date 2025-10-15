# JoyfillFormulas Module Specification

Source: `components-swift/Sources/JoyfillFormulas`

## Responsibilities
- Parse Joyfill formula strings into abstract syntax trees (AST).
- Evaluate AST nodes against an `EvaluationContext`, resolving field references supplied by the UI.
- Provide a standard library of logical, string, math, date, array, and higher-order functions.
- Surface rich error information (`FormulaError`) for invalid syntax, references, argument mismatches, and circular dependencies.

## Core Components
- **Lexer & Parser (`Parser.swift`)**
  - Tokenises identifiers, numbers, strings (single and double quotes), booleans, operators (including `==`, `!=`, `&&`, `||`, `->`), brackets, braces, and property access dots.
  - Supports array literals `[expr, ...]`, object literals `{ key: expr }`, lambda definitions `(item) -> expr`, and nested property/array access (e.g., `rows[0].value`).
  - Returns `ASTNode` trees with variants for literals, references, prefix/infix ops, function calls, lambda, array/object literals, array index, and property access.

- **AST (`ASTNode.swift`)**
  - `ASTNode` is an indirect enum with Equatable conformance for deterministic testing.
  - Property and array access nodes enable deep navigation across dictionaries/arrays produced by the evaluation context.

- **Value & Error Types (`FormulaValue.swift`)**
  - `FormulaValue` enumerates the runtime value space: numbers, strings, booleans, dates, arrays, dictionaries, null, undefined, lambdas, and embedded `FormulaError`.
  - Provides comparison helpers (`compare(to:)`) and convenient bool casting.
  - `FormulaError` covers syntax errors, missing references, type mismatches, invalid arguments, division by zero, circular references, and unknown errors.

- **Evaluator (`Evaluator.swift`)**
  - Walks the AST, invoking `EvaluationContext.resolveReference(_:)` for identifiers.
  - Handles implicit string concatenation (`string + value`), numeric operations, boolean operations, and date arithmetic (adding/subtracting milliseconds).
  - Evaluates array/object literals element-by-element and propagates the first evaluation error.
  - Executes registered functions via `FunctionRegistry`; missing functions result in `.invalidReference`.
  - Implements property access rules:
    - For `reference.property` patterns, concatenates into a compound reference (`"products.total"`).
    - For dictionary values, returns matching member or `.invalidReference`.
    - For arrays, accepts numeric property names as indices or projects dictionary properties across all rows.

- **Function Registry (`FunctionRegistry.swift`)**
  - Defines the `EvaluationContext` protocol plus a simple `DictionaryContext` implementation used by tests and `FormulaRunner`.
  - Registers built-in functions grouped by category:
    - Logical: `IF`, `AND`, `OR`, `NOT`, `EMPTY`
    - String: `CONCAT`, `CONTAINS`, `UPPER`, `LOWER`, `LENGTH`, `TONUMBER`, `TOSTRING`, `JOIN`, `EQUALS`, `TRIM`
    - Math: `SUM`, `POW`, `ROUND`, `CEIL`, `FLOOR`, `MOD`, `MAX`, `MIN`, `COUNT`, `AVG`/`AVERAGE`, `SQRT`
    - Date: `NOW`, `YEAR`, `MONTH`, `DAY`, `DATE`, `DATEADD`, `DATESUBTRACT`, `TIMESTAMP`
    - Array/Higher-order: `FLAT`, `MAP`, `FLATMAP`, `FILTER`, `REDUCE`, `FIND`, `EVERY`, `SOME`, `COUNTIF`, `UNIQUE`, `SORT`
  - Custom functions can be registered at runtime via `register(name:function:)`.

- **Function Implementations**
  - `ArrayFunctions.swift` implements higher-order operations with lambda arguments. Lambdas receive element and optional index parameters and execute inside derived evaluation contexts.
  - `MathFunctions.swift`, `LogicalFunctions.swift`, `StringFunctions.swift`, `DateFunctions.swift`, and `HigherOrderFunctions.swift` evaluate their arguments via the shared `Evaluator`, enforce arity, and return `FormulaValue` outputs.

## Integration Points
- `JoyfillUI` supplies `JoyfillDocContext` (conforming to `EvaluationContext`) to resolve field references, manage temporary lambda variables, and cache formula results.
- `FormulaRunner` executable demonstrates standalone usage by evaluating `Examples.sampleFormulas`.

## Error Handling
- Parser returns `.failure(.syntaxError(...))` on unterminated strings, unknown characters, or malformed numbers.
- Evaluator short-circuits evaluation on the first `Result.failure`, propagating detailed `FormulaError`.
- Lambda evaluation detects and surfaces circular dependencies via `JoyfillDocContext`.
