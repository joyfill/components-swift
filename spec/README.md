# Joyfill iOS SDK – Architecture Overview

This specification captures the actual structure of the Joyfill Apple platforms SDK as implemented in `components-swift/Sources`. It supersedes any stale markdown in the repository by describing the behaviour that is present in code.

## Package Targets
- **Joyfill** → SwiftUI presentation layer located in `Sources/JoyfillUI`. Exposed product used by host apps. Depends on `JoyfillModel`, `JoyfillFormulas`, and third-party `JSONSchema`.
- **JoyfillModel** → Core JoyDoc data model and helper utilities at `Sources/JoyfillModel`. Pure Swift types with no UI dependencies.
- **JoyfillFormulas** → Formula parsing/evaluation engine (`Sources/JoyfillFormulas`). Depends on `JoyfillModel` for type interop.
- **JoyfillAPIService** → REST client abstraction (`Sources/JoyfillAPIService`). Uses `JoyfillModel` for decoding responses.
- **Examples** → Lightweight playground data under `Sources/Examples`; consumed by `FormulaRunner`.
- **FormulaRunner** → CLI executable (`Sources/FormulaRunner`) that exercises the formula engine.

## High-Level Flow
1. Host apps initialize `DocumentEditor` (JoyfillUI) with a `JoyDoc` (`JoyfillModel`) plus optional change handlers.
2. `DocumentEditor` validates schemas using `JoyfillSchemaManager` (JSON schema + version checks) and builds field/page maps.
3. UI views render field models and bind to `DocumentEditor`, emitting change events through `FormChangeEvent` callbacks.
4. Mutations invoke `DocumentEditor.change(...)` or editing helpers (duplicate, delete, move rows). These update `JoyDocField` values in-memory.
5. `JoyfillDocContext` bridges `DocumentEditor` with the formula engine. `JoyfillFormulas` parses expressions, resolves field references via `DocumentEditor`, and caches results.
6. `APIService` persists changes or fetches documents/templates over HTTP, returning strongly-typed `Document`, `GroupData`, `JoyDoc`, etc.

## External Dependency
- [`kylef/JSONSchema.swift`](https://github.com/kylef/JSONSchema.swift) – runtime schema validation. Only imported by JoyfillUI and JoyfillModel.

## Testing & Tooling
- Unit tests exist for all primary targets under `components-swift/Tests`.
- `FormulaRunner` executable demonstrates parsing/evaluating sample formulas without UI.
- Logging via `JoyfillLogger` (Swift `print`) is enabled when `DEBUG` is set.

See the module-specific specs in this folder for detailed API and behaviour notes.
