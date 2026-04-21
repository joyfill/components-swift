import JoyfillModel

public extension DocumentEditor {

    // MARK: - Path-Based API
    //
    // Grammar (segments are "/"-separated; empty segments are ignored):
    //
    //   path := page-id "/" field-position-id [ rest ]
    //   rest := "rows"                                  → common rows of root schema (or table)
    //         | "columns/" col                          → common column of root schema (or table)
    //         | "schemas/" sk "/rows"                   → common rows of schema sk
    //         | "schemas/" sk "/columns/" col           → common column of schema sk
    //         | "schemas/" sk "/" row rowRest           → a row inside schema sk
    //         | row rowRest                             → a row at root schema
    //   rowRest := ε                                     → that row's dedicated decorators
    //            | col                                   → cell (row × col)
    //            | "columns/" col                        → row-scoped column  (aliases cell storage)
    //            | "schemas/" sk "/" row rowRest         → descend into child schema
    //
    // Tables cannot use "schemas/..." — they have no schema tree.
    //
    // Storage map:
    //   field                            → field.decorators
    //   commonRows(sk?)                  → sk?  ? field.schema[sk].rowDecorators : field.rowDecorators
    //   commonColumn(sk?, col)           → sk?  ? field.schema[sk].tableColumns[col].decorators : field.tableColumns[col].decorators
    //   rowSelf                          → ValueElement.decorators.all           (at the end of the hop chain)
    //   cell(col) / rowScopedColumn(col) → ValueElement.decorators.cells[col]    (aliased storage)
    //
    // Copy-on-write: adding to rowSelf / cell / rowScopedColumn when the scope is empty
    // seeds from the matching common scope first so the specific scope diverges without
    // losing previously-visible decorators.
    //
    // All methods must be called on the main thread.

    /// Returns all decorators at the given path.
    func getDecorators(path: String) -> [Decorator] {
        guard let target = resolveDecoratorTarget(path: path) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to resolve path '\(path)'")))
            return []
        }
        return fetchDecorators(for: target)
    }

    /// Appends one or more decorators at the given path.
    func addDecorators(path: String, decorators: [Decorator]) {
        guard !decorators.isEmpty else { return }
        guard let target = resolveDecoratorTarget(path: path) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to resolve path '\(path)'")))
            return
        }
        guard licenseAllowsDecoratorWrite(for: target, path: path) else { return }

        for decorator in decorators {
            if let error = validateDecorator(decorator) {
                events?.onError(error: .decoratorError(error: DecoratorError(message: error)))
                return
            }
        }

        var list = fetchDecorators(for: target)
        // Copy-on-write seed for specific scopes
        if list.isEmpty, let seed = commonSeed(for: target) {
            list = seed
        }

        let existingActions = Set(list.compactMap { $0.action })
        let newActions = decorators.compactMap { $0.action }

        if Set(newActions).count != newActions.count {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Duplicate decorators found in the incoming batch at path '\(path)'"
            )))
            return
        }
        if let duplicate = newActions.first(where: { existingActions.contains($0) }) {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Decorator with action '\(duplicate)' already exists at path '\(path)'"
            )))
            return
        }

        list.append(contentsOf: decorators)
        ensureDecorateEnabled(for: target)
        applyDecorators(list, for: target)
    }

    /// Removes the decorator whose `action` matches at the given path.
    func removeDecorator(path: String, action: String) {
        guard let target = resolveDecoratorTarget(path: path) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to resolve path '\(path)'")))
            return
        }
        guard licenseAllowsDecoratorWrite(for: target, path: path) else { return }
        var list = fetchDecorators(for: target)
        guard let index = list.firstIndex(where: { $0.action == action }) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to remove decorator with action: '\(action)'")))
            return
        }
        list.remove(at: index)
        applyDecorators(list, for: target)
    }

    /// Replaces the decorator whose `action` matches with the new decorator at the given path.
    func updateDecorator(path: String, action: String, decorator: Decorator) {
        guard let target = resolveDecoratorTarget(path: path) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to resolve path '\(path)'")))
            return
        }
        guard licenseAllowsDecoratorWrite(for: target, path: path) else { return }
        if let error = validateDecorator(decorator) {
            events?.onError(error: .decoratorError(error: DecoratorError(message: error)))
            return
        }
        var list = fetchDecorators(for: target)
        guard let index = list.firstIndex(where: { $0.action == action }) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to update decorator with action: '\(action)'")))
            return
        }
        if let newAction = decorator.action,
           newAction != action,
           list.contains(where: { $0.action == newAction }) {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Decorator with action '\(newAction)' already exists at path '\(path)'"
            )))
            return
        }
        list[index] = decorator
        applyDecorators(list, for: target)
    }
}

// MARK: - Internal target model

private extension DocumentEditor {

    /// A resolved decorator location: a chain of hops through the row/schema tree, plus a terminator.
    struct DecoratorTarget {
        let fieldID: String
        let hops: [Hop]
        let terminator: Terminator

        struct Hop {
            /// Schema key the row lives in. Table fields: always nil.
            /// Collection fields: root hop = root schema key; nested hops = the preceding `schemas/sk` key.
            let schemaKey: String?
            let rowID: String
        }

        enum Terminator {
            case field
            case commonRows(schemaKey: String?)                       // nil → table root
            case commonColumn(schemaKey: String?, columnID: String)
            case rowSelf                                              // hops.last is the row
            case cell(columnID: String)
            case rowScopedColumn(columnID: String)                    // aliased to cell storage
        }
    }
}

// MARK: - Private helpers

private extension DocumentEditor {

    // MARK: License gating

    func licenseAllowsDecoratorWrite(for target: DecoratorTarget, path: String) -> Bool {
        guard let field = fieldMap[target.fieldID] else { return true }
        if field.fieldType == .collection && !isCollectionFieldEnabled {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Collection field decorators are not available without a valid license (path '\(path)')"
            )))
            return false
        }
        return true
    }

    // MARK: Decorator validation

    func validateDecorator(_ decorator: Decorator) -> String? {
        if let action = decorator.action, action.isEmpty {
            return "Invalid decorator property: 'action' must not be empty"
        }
        if decorator.action == nil {
            return "Invalid decorator property: 'action' is required"
        }
        if let color = decorator.color, !color.isEmpty {
            let hexPattern = "^#[0-9A-Fa-f]{6}$"
            if color.range(of: hexPattern, options: .regularExpression) == nil {
                return "Invalid decorator property: 'color' must be a hex string (e.g. #3B82F6), got '\(color)'"
            }
        }
        return nil
    }

    // MARK: Decorate flag

    /// Sets `decorate = true` on the field (table) or schema entry (collection) when
    /// row-level decorators are added, so the decorator column shows automatically.
    func ensureDecorateEnabled(for target: DecoratorTarget) {
        let schemaKey: String?
        switch target.terminator {
        case .commonRows(let sk):
            schemaKey = sk
        case .rowSelf:
            schemaKey = target.hops.last?.schemaKey
        default:
            return
        }
        guard var field = fieldMap[target.fieldID] else { return }

        if let sk = schemaKey {
            guard var schema = field.schema, var entry = schema[sk] else { return }
            guard entry.decorate != true else { return }
            entry.decorate = true
            schema[sk] = entry
            field.schema = schema
        } else {
            guard field.decorate != true else { return }
            field.decorate = true
        }
        commitDecoratorChange(field: field, fieldID: target.fieldID)
    }

    func commitDecoratorChange(field: JoyDocField, fieldID: String) {
        updateField(field: field)
        refreshField(fieldId: fieldID)
        valueDelegate(for: fieldID, fieldType: field.fieldType)?.decoratorsDidChange()
    }

    // MARK: COW seed

    /// Returns the common-scope decorators to seed a specific scope with, if any.
    func commonSeed(for target: DecoratorTarget) -> [Decorator]? {
        let seedTerminator: DecoratorTarget.Terminator
        switch target.terminator {
        case .rowSelf:
            seedTerminator = .commonRows(schemaKey: target.hops.last?.schemaKey)
        case .cell(let col), .rowScopedColumn(let col):
            seedTerminator = .commonColumn(schemaKey: target.hops.last?.schemaKey, columnID: col)
        default:
            return nil
        }
        let seedTarget = DecoratorTarget(fieldID: target.fieldID, hops: [], terminator: seedTerminator)
        return fetchDecorators(for: seedTarget)
    }

    // MARK: Path parsing

    /// Parses the path string into a DecoratorTarget, validating each segment along the way.
    func resolveDecoratorTarget(path: String) -> DecoratorTarget? {
        let segments = path
            .split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard segments.count >= 2 else { return nil }
        let pageId = segments[0]
        let fieldPositionId = segments[1]

        guard let page = pagesForCurrentView.first(where: { $0.id == pageId }),
              let position = page.fieldPositions?.first(where: { $0.id == fieldPositionId }),
              let fieldID = position.field,
              let field = fieldMap[fieldID] else { return nil }

        let isCollection = field.fieldType == .collection
        let rootSchemaKey: String? = isCollection
            ? field.schema?.first(where: { $0.value.root == true })?.key
            : nil

        var hops: [DecoratorTarget.Hop] = []
        var pendingSchema: String? = nil      // last `schemas/sk` consumed, pending binding
        var hasPendingSchema = false
        var cursor = 2

        while cursor < segments.count {
            let tok = segments[cursor]

            switch tok {
            case "schemas":
                if !isCollection { return nil }
                cursor += 1
                guard cursor < segments.count else { return nil }
                pendingSchema = segments[cursor]
                hasPendingSchema = true
                cursor += 1
                guard cursor < segments.count else { return nil } // must be followed by rows / columns / row-id

            case "rows":
                cursor += 1
                guard cursor == segments.count else { return nil }
                let sk: String?
                if hasPendingSchema {
                    sk = pendingSchema
                } else if !hops.isEmpty {
                    // fp/row-id/rows is not defined in the spec
                    return nil
                } else {
                    sk = rootSchemaKey
                }
                if let sk = sk, field.schema?[sk] == nil { return nil }
                return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .commonRows(schemaKey: sk))

            case "columns":
                cursor += 1
                guard cursor < segments.count else { return nil }
                let col = segments[cursor]
                cursor += 1
                guard cursor == segments.count else { return nil }

                let contextSk: String?
                let isRowScoped: Bool
                if hasPendingSchema {
                    contextSk = pendingSchema
                    isRowScoped = false
                } else if let lastHop = hops.last {
                    contextSk = lastHop.schemaKey
                    isRowScoped = true
                } else {
                    contextSk = rootSchemaKey
                    isRowScoped = false
                }

                guard columnExists(in: field, columnID: col, schemaKey: contextSk) else { return nil }

                if isRowScoped {
                    return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .rowScopedColumn(columnID: col))
                }
                return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .commonColumn(schemaKey: contextSk, columnID: col))

            default:
                // row-id
                let rowID = tok
                cursor += 1

                let hopSchema: String?
                if hasPendingSchema {
                    hopSchema = pendingSchema
                } else if hops.isEmpty {
                    hopSchema = rootSchemaKey  // nil for table
                } else {
                    // collection requires schemas/sk between consecutive rows; tables don't nest
                    return nil
                }
                hops.append(.init(schemaKey: hopSchema, rowID: rowID))
                pendingSchema = nil
                hasPendingSchema = false

                guard rowExistsInField(fieldID: fieldID, rowId: rowID) else { return nil }

                if cursor == segments.count {
                    return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .rowSelf)
                }

                let next = segments[cursor]
                if next == "schemas" {
                    continue // outer loop handles
                }
                if next == "columns" {
                    cursor += 1
                    guard cursor < segments.count else { return nil }
                    let col = segments[cursor]
                    cursor += 1
                    guard cursor == segments.count else { return nil }
                    guard columnExists(in: field, columnID: col, schemaKey: hopSchema) else { return nil }
                    return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .rowScopedColumn(columnID: col))
                }
                if next == "rows" {
                    // fp/.../row-id/rows not defined
                    return nil
                }
                // Bare column id → cell
                let col = next
                cursor += 1
                guard cursor == segments.count else { return nil }
                guard columnExists(in: field, columnID: col, schemaKey: hopSchema) else { return nil }
                return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .cell(columnID: col))
            }
        }

        // No rest → field-level
        if hasPendingSchema { return nil }
        return DecoratorTarget(fieldID: fieldID, hops: hops, terminator: .field)
    }

    // MARK: Column existence

    func columnExists(in field: JoyDocField, columnID: String, schemaKey: String?) -> Bool {
        let cols: [FieldTableColumn]?
        if let sk = schemaKey {
            cols = field.schema?[sk]?.tableColumns
        } else {
            cols = field.tableColumns
        }
        return (cols ?? []).contains(where: { $0.id == columnID })
    }

    // MARK: Fetch / apply

    func fetchDecorators(for target: DecoratorTarget) -> [Decorator] {
        guard let field = fieldMap[target.fieldID] else { return [] }
        switch target.terminator {
        case .field:
            return field.decorators ?? []

        case .commonRows(let sk):
            if let sk = sk {
                return field.schema?[sk]?.rowDecorators ?? []
            }
            return field.rowDecorators ?? []

        case .commonColumn(let sk, let col):
            let cols: [FieldTableColumn]?
            if let sk = sk {
                cols = field.schema?[sk]?.tableColumns
            } else {
                cols = field.tableColumns
            }
            return cols?.first(where: { $0.id == col })?.decorators ?? []

        case .rowSelf:
            guard let element = valueElement(at: target.hops, in: field) else { return [] }
            return element.decorators?.all ?? []

        case .cell(let col), .rowScopedColumn(let col):
            guard let element = valueElement(at: target.hops, in: field) else { return [] }
            return element.decorators?.cells[col] ?? []
        }
    }

    func applyDecorators(_ decorators: [Decorator], for target: DecoratorTarget) {
        guard var field = fieldMap[target.fieldID] else { return }

        switch target.terminator {
        case .field:
            field.decorators = decorators

        case .commonRows(let sk):
            if let sk = sk {
                guard var schema = field.schema, var entry = schema[sk] else { return }
                entry.rowDecorators = decorators
                schema[sk] = entry
                field.schema = schema
            } else {
                field.rowDecorators = decorators
            }

        case .commonColumn(let sk, let col):
            if let sk = sk {
                guard var schema = field.schema,
                      var entry = schema[sk],
                      var cols = entry.tableColumns,
                      let i = cols.firstIndex(where: { $0.id == col }) else { return }
                cols[i].decorators = decorators
                entry.tableColumns = cols
                schema[sk] = entry
                field.schema = schema
            } else {
                guard var cols = field.tableColumns,
                      let i = cols.firstIndex(where: { $0.id == col }) else { return }
                cols[i].decorators = decorators
                field.tableColumns = cols
            }

        case .rowSelf, .cell, .rowScopedColumn:
            guard !target.hops.isEmpty else { return }
            var rows = field.valueToValueElements ?? []
            rewriteRows(&rows, hops: target.hops, depth: 0, terminator: target.terminator, newList: decorators)
            field.value = ValueUnion.valueElementArray(rows)
        }

        commitDecoratorChange(field: field, fieldID: target.fieldID)
    }

    // MARK: Row tree walking

    /// Walks the hop chain and returns the ValueElement at the end (last hop's row).
    func valueElement(at hops: [DecoratorTarget.Hop], in field: JoyDocField) -> ValueElement? {
        guard !hops.isEmpty else { return nil }
        var currentRows: [ValueElement] = field.valueToValueElements ?? []
        for (i, hop) in hops.enumerated() {
            guard let row = currentRows.first(where: { $0.id == hop.rowID }) else { return nil }
            if i == hops.count - 1 { return row }
            // Descend into child schema specified by NEXT hop's schemaKey
            let nextHop = hops[i + 1]
            guard let sk = nextHop.schemaKey,
                  let children = row.childrens?[sk] else { return nil }
            currentRows = children.valueToValueElements ?? []
        }
        return nil
    }

    /// Recursively rewrites the row tree to apply the terminator's new decorator list at the deepest hop.
    func rewriteRows(
        _ rows: inout [ValueElement],
        hops: [DecoratorTarget.Hop],
        depth: Int,
        terminator: DecoratorTarget.Terminator,
        newList: [Decorator]
    ) {
        let hop = hops[depth]
        guard let idx = rows.firstIndex(where: { $0.id == hop.rowID }) else { return }
        var row = rows[idx]

        if depth == hops.count - 1 {
            var decs = row.decorators ?? Decorators()
            switch terminator {
            case .rowSelf:
                decs.all = newList
            case .cell(let col), .rowScopedColumn(let col):
                var cells = decs.cells
                cells[col] = newList
                decs.cells = cells
            default:
                return
            }
            row.decorators = decs
            rows[idx] = row
            return
        }

        let nextHop = hops[depth + 1]
        guard let sk = nextHop.schemaKey else { return }
        var childrens = row.childrens ?? [:]
        guard var children = childrens[sk] else { return }
        var childRows = children.valueToValueElements ?? []
        rewriteRows(&childRows, hops: hops, depth: depth + 1, terminator: terminator, newList: newList)
        children.value = ValueUnion.valueElementArray(childRows)
        childrens[sk] = children
        row.childrens = childrens
        rows[idx] = row
    }
}
