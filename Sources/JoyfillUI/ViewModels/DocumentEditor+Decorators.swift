import JoyfillModel

public extension DocumentEditor {

    // MARK: - Path-Based API
    //
    // path = "pageId/fieldPositionId"             → field decorators
    // path = "pageId/fieldPositionId/rowId"        → row decorators
    // path = "pageId/fieldPositionId/rowId/colId"  → column decorators

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
        guard let target = resolveDecoratorTarget(path: path) else {
            events?.onError(error: .decoratorError(error: DecoratorError(message: "Failed to resolve path '\(path)'")))
            return
        }
        guard licenseAllowsDecoratorWrite(for: target, path: path) else { return }
        guard !decorators.isEmpty else { return }
        for decorator in decorators {
            if let error = validateDecorator(decorator) {
                events?.onError(error: .decoratorError(error: DecoratorError(message: error)))
                return
            }
        }
        var list = fetchDecorators(for: target)
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
        updateField(field: field)
        refreshField(fieldId: fieldID)
        valueDelegate(for: fieldID, fieldType: field.fieldType)?.decoratorsDidChange()
    }

    // MARK: Path resolution

    /// Resolved decorator scope from a path string.
    enum DecoratorTarget {
        case field(fieldID: String)
        case row(fieldID: String, schemaKey: String?)
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
        } else if let rowId = parsed.rowId {
            guard rowExistsInField(fieldID: fieldID, rowId: rowId) else { return nil }
            // 3 segments → row decorators; resolve schemaKey from the rowId
            let schemaKey = resolvedSchemaKey(forRowID: rowId, inFieldID: fieldID)
            return .row(fieldID: fieldID, schemaKey: schemaKey)
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
        updateField(field: field)
        refreshField(fieldId: fieldID)
        valueDelegate(for: fieldID, fieldType: field.fieldType)?.decoratorsDidChange()
    }

    // MARK: Generic fetch / apply routers

    /// Returns the current decorator list for a resolved target.
    func fetchDecorators(for target: DecoratorTarget) -> [Decorator] {
        switch target {
        case .field(let fieldID):
            return decorators(forFieldID: fieldID)
        case .row(let fieldID, let schemaKey):
            return rowDecoratorsForPath(fieldID: fieldID, schemaKey: schemaKey)
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
        case .column(let fieldID, let columnID, let schemaKey):
            setColumnDecoratorsForPath(decorators, fieldID: fieldID, columnID: columnID, schemaKey: schemaKey)
        }
    }
}
