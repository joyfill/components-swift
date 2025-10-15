# JoyfillUI Module Specification

Source: `components-swift/Sources/JoyfillUI`

## Responsibilities
- Provide the SwiftUI rendering of Joyfill documents via the public `Form` view.
- Orchestrate editable document state through `DocumentEditor`, including schema validation, conditional logic, validation, and formula execution.
- Bridge user interactions to host applications through the `FormChangeEvent` protocol.
- Coordinate feature gating (license validation), logging, and layout utilities required by the component suite.

## Public Entry Points
- `Form` (`View/FormView.swift`) – SwiftUI view initialised with either an existing `DocumentEditor` or by passing a `JoyDoc` + configuration. Displays `SchemaErrorView` when embedded schema validation fails.
- `DocumentEditor` (`ViewModels/DocumentEditor.swift`) – Observable object that hosts document state and exposes editing APIs.
  - Initialiser validates schema (`JoyfillSchemaManager`) and sets feature flags via `LicenseValidator`.
  - Exposes `currentPageID`, `pageFieldModels`, `validationHandler`, `conditionalLogicHandler`, `JoyfillDocContext`, and computed `files`.
  - Key methods: `validate()`, `shouldShow(fieldID:)`, `shouldShow(pageID:)`, `change(changes:)`, `deleteRows`, `duplicateRows`, `moveRowUp/Down`, `insertRowAtTheEnd`, `insertBelow`, `insertRowWithFilter`, `bulkEdit`, `registerDelegate`.
  - Maintains `fieldMap`, `fieldPositionMap`, and `fieldIndexMap` used to rebuild SwiftUI models on demand (`refreshField`, `refreshDependent`).
  - Emits events via `handleFieldsOnChange`, `onFocus`, `onBlur`, `onUpload`, and changelog helpers defined in `DocumentEditor+ChangeHandler.swift`.

## View Hierarchy
1. `Form` → checks `schemaError`, otherwise renders `FilesView`.
2. `FilesView` → currently loads the first file and delegates to `FileView`.
3. `FileView` observes `DocumentEditor` and creates `PagesView`.
4. `PagesView` displays the active page, optional page navigation sheet, and binds page-specific `FieldListModel` arrays.
5. `PageView` embeds `FormView`, which maps `FieldListModelType` values to concrete field views located in `View/Fields` (text, number, textarea, dropdown, multiselect, date, signature, image, chart, table, collection, rich text).
6. `FieldHeaderView` displays shared label/required/tip UI.

Field-specific views use dedicated data models (`TextDataModel`, `NumberDataModel`, `TableDataModel`, etc.) produced by `DocumentEditor.getFieldModel(...)`. Complex field types (table, collection) register as delegates so that `DocumentEditor` can drive row-level animations and refreshes.

## Schema Validation
- `JoyfillSchemaManager` (`ViewModels/JoyfillSchemaManager.swift`) performs two-phase validation when `validateSchema` is true:
  1. Version guard – compares document major version with SDK-supported schema version.
  2. Structural validation – runs `JSONSchema.validate` against the embedded schema JSON (`joyfill-schema.swift`).
- Failing either phase sets `DocumentEditor.schemaError` and triggers `events?.onError(.schemaValidationError(...))`.

## Conditional Logic
- `ConditionalLogicHandler` builds:
  - `showFieldMap` for page/field visibility.
  - Dependency graph (`fieldConditionalDependencyMap`) to refresh dependent fields when a source field changes.
  - Collection schema gating caches (`showCollectionSchemaMap`, `collectionDependencyMap`) keyed by `RowSchemaID`.
- Supports `shouldShow(fieldID:)`, `shouldShow(pageID:)`, and `shouldShowSchema(for:rowSchemaID:)`. Evaluates conditions using live field values and schema logic definitions from `JoyfillModel`.

## Validation
- `ValidationHandler.validate()` iterates visible fields in page order, honours conditional visibility, and returns a `Validation` value conforming to `JoyfillModel`.
  - Simple fields are valid when required and non-empty (`ValueUnion.isEmpty`).
  - Tables compute per-row/per-column results, skipping deleted rows and hidden columns.
  - Collection fields validate according to schema metadata and child visibility flags from `ConditionalLogicHandler`.

## Formula Integration
- `JoyfillDocContext` (conforms to `EvaluationContext`) bridges `JoyfillFormulas` with the document model.
  - Builds dependency graph between fields and formulas, caches results, detects circular dependencies.
  - Resolves complex references (`field.property`, `array[0]`, projected `rows.column`) using `JoyDocField` values.
  - Provides APIs for clearing caches and propagating updates (`updateFieldValue`, `clearCacheForField`).
- `DocumentEditor` adopts `JoyDocProvider` (extension in `DocumentEditor+Formulas.swift`) so `JoyfillDocContext` can update field values and visibility.
- Formula evaluation is triggered during initialisation (`evaluateAllFormulas`) and when inputs mutate (via `refreshDependent` and cache invalidation).

## Eventing
- `FormChangeEvent` protocol (in `View/Types.swift`) defines `onChange`, `onFocus`, `onBlur`, `onUpload`, `onCapture`, `onError`.
- `FieldIdentifier` identifies a field/location via `fieldID`, `pageID`, and optional `fileID`.
- `Change` models changelog payloads generated when the editor mutates values/rows (`ChangeTargetType`).
- `FieldChangeData` and `FieldChangeEvents` (`FormChangeEventInternal.swift`) are used internally to relay events from views back to `DocumentEditor`.
- DocumentEditor’s row-manipulation APIs assemble appropriate `Change` dictionaries and call event hooks so host apps can persist updates.

## Licensing & Logging
- `LicenseValidator` validates RS256-signed JWTs to enable premium features (`collection` field editing). Without a valid token, collection-specific actions remain disabled.
- `JoyfillLogger` provides lightweight console logging with fatal errors during `DEBUG` builds to surface misconfigurations in development.

## Utilities
- `Utility` centralises layout constants (column widths, table scroll width), date conversion helpers, and a text change debouncer (used by text fields to batch updates).
- `Modes` (`Mode.fill` vs `Mode.readonly`) determine whether fields are editable. `DocumentEditor` also respects field-level `disabled` flags.
- `mapWebViewToMobileViewIfNeeded` normalises field positions when rendering documents designed for the web layout.

## Interaction with Other Targets
- Depends on `JoyfillModel` for document structures, validation result types, conditional logic data, and schema metadata.
- Imports `JoyfillFormulas` for parsing/evaluating formulas inside `JoyfillDocContext`.
- Uses `JSONSchema` (third-party) for runtime validation.
