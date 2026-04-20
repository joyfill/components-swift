import JoyfillModel

public extension DocumentEditor {

    // MARK: - Path-Based API
    //
    // path = "pageId/fieldPositionId"              → field decorators
    // path = "pageId/fieldPositionId/rows"         → common row decorators   (table: field.rowDecorators)
    // path = "pageId/fieldPositionId/{rowId}"      → row-specific decorators (table: ValueElement.decorators.all)
    // path = "pageId/fieldPositionId/{rowId}/colId" → column decorators
    //
    // Collection fields: the 3rd segment is always a real rowId (used to resolve the schemaKey).
    // Table fields: "rows" keyword → common; any valid rowId → row-specific (with copy-on-write from common).
    //
    // Note: Path segments are parsed with empty-component filtering;
    // consecutive or trailing slashes are treated as single separators.
    //
    // All methods in this section must be called on the main thread,
    // consistent with the DocumentEditor threading model.

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
        // Copy-on-write: if adding to a row-specific target with no existing row-specific
        // decorators, seed the list with the common row decorators first so that row
        // diverges from common while keeping all previously-visible decorators.
        if case .rowSpecific(let fID, _) = target, list.isEmpty {
            list = rowDecoratorsForPath(fieldID: fID, schemaKey: nil)
        }
        let existingActions = Set(list.compactMap { $0.action })
        let newActions = decorators.compactMap { $0.action }

        // Check duplicates within incoming batch
        if Set(newActions).count != newActions.count {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Duplicate decorators found in the incoming batch at path '\(path)'"
            )))
            return
        }

        // Check duplicates against existing decorators
        if let duplicate = newActions.first(where: { existingActions.contains($0) }) {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Decorator with action '\(duplicate)' already exists at path '\(path)'"
            )))
            return
        }
        list.append(contentsOf: decorators)
        applyDecorators(list, for: target)
        ensureDecorateEnabled(for: target)
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
        // If the new decorator's action differs from the target action, ensure it
        // doesn't collide with a different existing entry (would create duplicates).
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

// MARK: - Private helpers

private extension DocumentEditor {

    // MARK: License gating

    /// Returns the fieldID associated with a decorator target.
    func fieldID(for target: DecoratorTarget) -> String {
        switch target {
        case .field(let fieldID): return fieldID
        case .row(let fieldID, _): return fieldID
        case .rowSpecific(let fieldID, _): return fieldID
        case .column(let fieldID, _, _): return fieldID
        }
    }

    /// Blocks writes to collection-field decorators when the collection feature
    /// is not enabled by the license. Emits a decoratorError and returns false.
    func licenseAllowsDecoratorWrite(for target: DecoratorTarget, path: String) -> Bool {
        let fieldID = self.fieldID(for: target)
        guard let field = fieldMap[fieldID] else { return true }
        if field.fieldType == .collection && !isCollectionFieldEnabled {
            events?.onError(error: .decoratorError(error: DecoratorError(
                message: "Collection field decorators are not available without a valid license (path '\(path)')"
            )))
            return false
        }
        return true
    }

    // MARK: Decorate flag

    /// Sets `decorate = true` on the field (table) or schema entry (collection) when
    /// row decorators are added, so the decorator column is shown automatically.
    func ensureDecorateEnabled(for target: DecoratorTarget) {
        switch target {
        case .row(let fieldID, let schemaKey):
            guard var field = fieldMap[fieldID] else { return }
            if let schemaKey = schemaKey {
                // Collection: set decorate on the specific schema entry
                guard var schema = field.schema, var entry = schema[schemaKey] else { return }
                guard entry.decorate != true else { return }
                entry.decorate = true
                schema[schemaKey] = entry
                field.schema = schema
            } else {
                // Table: set decorate on the field
                guard field.decorate != true else { return }
                field.decorate = true
            }
            commitDecoratorChange(field: field, fieldID: fieldID)

        case .rowSpecific(let fieldID, _):
            guard var field = fieldMap[fieldID], field.decorate != true else { return }
            field.decorate = true
            commitDecoratorChange(field: field, fieldID: fieldID)

        case .field, .column:
            break
        }
    }

    /// Persists a field mutation and notifies the view layer that decorators changed.
    func commitDecoratorChange(field: JoyDocField, fieldID: String) {
        updateField(field: field)
        refreshField(fieldId: fieldID)
        valueDelegate(for: fieldID, fieldType: field.fieldType)?.decoratorsDidChange()
    }

    // MARK: Decorator validation

    /// Validates decorator properties. Returns an error message if invalid, nil if valid.
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

    // MARK: Field Decorators

    func decorators(forFieldID fieldID: String) -> [Decorator] {
        fieldMap[fieldID]?.decorators ?? []
    }

    func setDecorators(_ decorators: [Decorator], forFieldID fieldID: String) {
        guard var field = fieldMap[fieldID] else { return }
        field.decorators = decorators
        updateField(field: field)
        refreshField(fieldId: fieldID)
    }

    // MARK: Column Decorators
    //
    // - Table fields:      columns live on field.tableColumns      → schemaKey is nil
    // - Collection fields: columns live on field.schema[key].tableColumns → schemaKey is non-nil

    func columnDecoratorsForPath(fieldID: String, columnID: String, schemaKey: String?) -> [Decorator] {
        guard let field = fieldMap[fieldID] else { return [] }
        let columns: [FieldTableColumn]?
        if field.fieldType == .collection {
            guard let schemaKey = schemaKey else { return [] }
            columns = field.schema?[schemaKey]?.tableColumns
        } else {
            columns = field.tableColumns
        }
        return columns?.first(where: { $0.id == columnID })?.decorators ?? []
    }

    func setColumnDecoratorsForPath(_ decorators: [Decorator], fieldID: String, columnID: String, schemaKey: String?) {
        guard var field = fieldMap[fieldID] else { return }
        if field.fieldType == .collection {
            // Collection field: update column inside the schema entry
            guard let schemaKey = schemaKey,
                  var schema    = field.schema,
                  var entry     = schema[schemaKey],
                  var columns   = entry.tableColumns,
                  let colIndex  = columns.firstIndex(where: { $0.id == columnID }) else { return }
            columns[colIndex].decorators = decorators
            entry.tableColumns  = columns
            schema[schemaKey]   = entry
            field.schema        = schema
        } else {
            // Table field: update column directly on the field
            guard var columns  = field.tableColumns,
                  let colIndex = columns.firstIndex(where: { $0.id == columnID }) else { return }
            columns[colIndex].decorators = decorators
            field.tableColumns = columns
        }
        commitDecoratorChange(field: field, fieldID: fieldID)
    }

    // MARK: Path resolution

    /// Resolved decorator scope from a path string.
    enum DecoratorTarget {
        case field(fieldID: String)
        case row(fieldID: String, schemaKey: String?)          // common row decorators
        case rowSpecific(fieldID: String, rowID: String)       // row-specific decorators (table only)
        case column(fieldID: String, columnID: String, schemaKey: String?)
    }

    /// Parses the path and maps it to the correct decorator scope.
    /// The rowId segment resolves the schemaKey for both row and column paths on
    /// collection fields. Table fields always resolve to schemaKey = nil.
    func resolveDecoratorTarget(path: String) -> DecoratorTarget? {
        let parsed = DocumentEditor.parsePath(path)

        guard let pageId = parsed.pageId,
              let fieldPositionId = parsed.fieldPositionId,
              let page = pagesForCurrentView.first(where: { $0.id == pageId }),
              let position = page.fieldPositions?.first(where: { $0.id == fieldPositionId }),
              let fieldID = position.field,
              let field = fieldMap[fieldID] else { return nil }

        if let columnId = parsed.columnId {
            guard let rowId = parsed.rowId else { return nil }
            guard rowExistsInField(fieldID: fieldID, rowId: rowId) else { return nil }
            // 4 segments → column decorators; rowId resolves the schema for collection fields
            let schemaKey = resolvedSchemaKey(forRowID: rowId, inFieldID: fieldID)
            guard columnExistsInField(field, columnId: columnId, schemaKey: schemaKey) else { return nil }
            return .column(fieldID: fieldID, columnID: columnId, schemaKey: schemaKey)
        } else if let rowSegment = parsed.rowId {
            if field.fieldType == .table {
                if rowSegment == "rows" {
                    // "rows" keyword → common row decorators on the field
                    return .row(fieldID: fieldID, schemaKey: nil)
                }
                // Actual rowId → row-specific decorators
                guard rowExistsInField(fieldID: fieldID, rowId: rowSegment) else { return nil }
                return .rowSpecific(fieldID: fieldID, rowID: rowSegment)
            } else {
                // Collection: rowId always resolves to schema-level row decorators
                guard rowExistsInField(fieldID: fieldID, rowId: rowSegment) else { return nil }
                let schemaKey = resolvedSchemaKey(forRowID: rowSegment, inFieldID: fieldID)
                return .row(fieldID: fieldID, schemaKey: schemaKey)
            }
        } else {
            // 2 segments → field decorators
            return .field(fieldID: fieldID)
        }
    }

    // MARK: Schema key resolution

    /// Returns the schemaKey the given rowId belongs to.
    ///
    /// - Table fields always return nil (row decorators live at field level).
    /// - Collection fields: root-level rows map to the schema entry where
    ///   `root == true`; nested rows return the key found in their parent's
    ///   `childrens` map.
    func resolvedSchemaKey(forRowID rowID: String, inFieldID fieldID: String) -> String? {
        guard let field = fieldMap[fieldID] else { return nil }

        // Table fields store row decorators at the field level, no schemaKey needed
        if field.fieldType == .table { return nil }

        let rootRows = field.valueToValueElements ?? []

        // Root schema = the schema entry flagged with root == true
        let rootSchemaKey = field.schema?.first { $0.value.root == true }?.key

        // Check root-level rows first
        if rootRows.contains(where: { $0.id == rowID }) {
            return rootSchemaKey
        }

        // Recursively search nested children
        for row in rootRows {
            if let found = schemaKey(forRowID: rowID, in: row) {
                return found
            }
        }

        return nil
    }

    /// Recursively walks a ValueElement's `childrens` map to find which
    /// schemaKey contains the given rowId.
    func schemaKey(forRowID rowID: String, in element: ValueElement) -> String? {
        guard let childrens = element.childrens else { return nil }
        for (schemaKey, children) in childrens {
            let childRows = children.valueToValueElements ?? []
            if childRows.contains(where: { $0.id == rowID }) {
                return schemaKey
            }
            // Go one level deeper
            for child in childRows {
                if let found = self.schemaKey(forRowID: rowID, in: child) {
                    return found
                }
            }
        }
        return nil
    }

    // MARK: Row-specific decorator read/write (table only)

    func rowSpecificDecoratorsForPath(fieldID: String, rowID: String) -> [Decorator] {
        guard let field = fieldMap[fieldID] else { return [] }
        return field.valueToValueElements?.first(where: { $0.id == rowID })?.decorators?.all ?? []
    }

    func setRowSpecificDecoratorsForPath(_ decorators: [Decorator], fieldID: String, rowID: String) {
        guard var field = fieldMap[fieldID],
              var rows = field.valueToValueElements,
              let index = rows.firstIndex(where: { $0.id == rowID }) else { return }
        var decs = rows[index].decorators ?? Decorators()
        decs.all = decorators
        rows[index].decorators = decs
        field.value = ValueUnion.valueElementArray(rows)
        commitDecoratorChange(field: field, fieldID: fieldID)
    }

    // MARK: Row decorator read/write (path-based, independent of the public API)

    /// Reads row decorators directly from the field model.
    /// - nil schemaKey → table field, reads `field.rowDecorators`
    /// - non-nil schemaKey → collection field, reads `field.schema[schemaKey].rowDecorators`
    func rowDecoratorsForPath(fieldID: String, schemaKey: String?) -> [Decorator] {
        guard let field = fieldMap[fieldID] else { return [] }
        if field.fieldType == .collection {
            guard let schemaKey = schemaKey else { return [] }
            return field.schema?[schemaKey]?.rowDecorators ?? []
        }
        return field.rowDecorators ?? []
    }

    /// Writes row decorators directly to the field model.
    func setRowDecoratorsForPath(_ decorators: [Decorator], fieldID: String, schemaKey: String?) {
        guard var field = fieldMap[fieldID] else { return }
        if field.fieldType == .collection {
            guard var schema = field.schema,
                  let schemaKey = schemaKey,
                  var entry  = schema[schemaKey] else { return }
            entry.rowDecorators = decorators
            schema[schemaKey]   = entry
            field.schema        = schema
        } else {
            field.rowDecorators = decorators
        }
        commitDecoratorChange(field: field, fieldID: fieldID)
    }

    // MARK: Generic fetch / apply routers

    /// Returns the current decorator list for a resolved target.
    func fetchDecorators(for target: DecoratorTarget) -> [Decorator] {
        switch target {
        case .field(let fieldID):
            return decorators(forFieldID: fieldID)
        case .row(let fieldID, let schemaKey):
            return rowDecoratorsForPath(fieldID: fieldID, schemaKey: schemaKey)
        case .rowSpecific(let fieldID, let rowID):
            return rowSpecificDecoratorsForPath(fieldID: fieldID, rowID: rowID)
        case .column(let fieldID, let columnID, let schemaKey):
            return columnDecoratorsForPath(fieldID: fieldID, columnID: columnID, schemaKey: schemaKey)
        }
    }

    /// Persists an updated decorator list for a resolved target.
    func applyDecorators(_ decorators: [Decorator], for target: DecoratorTarget) {
        switch target {
        case .field(let fieldID):
            setDecorators(decorators, forFieldID: fieldID)
        case .row(let fieldID, let schemaKey):
            setRowDecoratorsForPath(decorators, fieldID: fieldID, schemaKey: schemaKey)
        case .rowSpecific(let fieldID, let rowID):
            setRowSpecificDecoratorsForPath(decorators, fieldID: fieldID, rowID: rowID)
        case .column(let fieldID, let columnID, let schemaKey):
            setColumnDecoratorsForPath(decorators, fieldID: fieldID, columnID: columnID, schemaKey: schemaKey)
        }
    }
}
