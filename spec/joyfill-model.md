# JoyfillModel Module Specification

Source: `components-swift/Sources/JoyfillModel`

## Responsibilities
- Provide Swift-native representations of Joyfill documents (`JoyDoc`) and REST payloads (`Document`, `GroupData`, `RetrieveGroup`, user models).
- Encapsulate field metadata, values, conditional logic payloads, and schema fragments used by the UI and formula engine.
- Supply helper APIs for manipulating tables/collections (row CRUD, duplication, ordering) and for time conversions.
- Define validation result structures consumed by `DocumentEditor`.

## Key Types
- `Document` (`DocumentModel.swift`) – Codable struct that mirrors GET `/documents` payloads. Holds `_id`, `type`, `identifier`, `files`, etc., plus nested `Files` and `Pages` structs.
- `JoyDoc` (`JoyDoc.swift`) – Dictionary-backed struct representing the editable document model. Provides computed accessors for metadata (id/type/stage/source/name), `files`, `fields`, `formulas`, `categories`, and view-scoped helpers:
  - `pagesForCurrentView`/`pageOrderForCurrentView` auto-select between file-level pages vs. `view.pages`.
  - Row mutation utilities on `JoyDocField` (delete, duplicate, insert, move).
  - `fieldPositionsForCurrentView` exposes flattened layout data.
- `JoyDocField` – Equatable wrapper over `[String: Any]` that exposes strongly-typed properties: identifiers, option lists, logic, table schema (`tableColumns`, `schema`, `rowOrder`, `tableColumnOrder`), value (`ValueUnion`), display settings, and mutating table helpers.
- `ValueUnion` (`ValueUnion.swift`) – Codable/Hashable enum that normalises field values (`double`, `int`, `string`, `array`, `valueElementArray`, `dictionary`, `bool`, `null`). Includes conversion initialisers from `Any` and serialization helpers.
- `ValueElement` – Codable/Identifiable struct representing table/collection rows. Stores a `[String: ValueUnion]` dictionary and exposes typed accessors plus `childrens` for nested collection rows.
- `FieldTableColumn` – Dictionary-backed struct describing table column metadata (type, identifier, width, options, format).
- `Option` – Dropdown/multiselect option definition with identifiers, color, width, deletion flag.
- `Logic`, `Condition`, `Schema` (within `JoyDoc.swift`) – Data structures for field/page conditional logic including nested schema gating for collection fields.
- `Metadata`, `FieldPosition`, `Point` – Additional layout metadata consumed by the UI layer.
- `ValidationStatus`, `Validation`, `FieldValidity`, `RowValidity`, `ColumnValidity`, `CellValidity` (`Validator.swift`) – Immutable result types returned by `DocumentEditor.validate()`.
- `LogicModel`, `ConditionModel`, `ConditionalLogicModel` (`ConditionalLogicModel.swift`) – SwiftUI-friendly logic models shared with the UI’s `ConditionalLogicHandler`.

## Utilities
- Time/date helpers in `DocumentModel.swift`: `getTimeFromISO8601Format`, `timestampMillisecondsToDate`, `dateToTimestampMilliseconds`.
- `generateObjectId()` (within `JoyDoc.swift`) creates Mongo-style identifiers for new rows.
- `JSONNull.swift` defines a `JSONNull` codable helper allowing fields to represent server-provided nulls.

## Behaviour Notes
- `JoyDoc` and `JoyDocField` intentionally mirror the mutable JSON structure; setters write back into the underlying dictionary to keep compatibility with API payloads.
- Table operations update both `value` (as `.valueElementArray`) and associated ordering arrays (`rowOrder`, `tableColumnOrder`) to satisfy UI expectations.
- Dropdown and multiselect conversions rely on `Option.id`/`Option.value` mapping; consumers must translate between display strings and backend IDs.
- Conditional logic for pages/fields is only data storage here—the evaluation lives inside `JoyfillUI`.
- Validation types do not perform checking themselves; they are containers populated by `ValidationHandler` in `JoyfillUI`.
