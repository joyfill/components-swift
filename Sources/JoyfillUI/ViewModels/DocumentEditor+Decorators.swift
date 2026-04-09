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
            Log("getDecorators: could not resolve path '\(path)'", type: .warning)
            return []
        }
        return fetchDecorators(for: target)
    }

    /// Appends one or more decorators at the given path.
    func addDecorators(path: String, decorators: [Decorator]) {
        guard let target = resolveDecoratorTarget(path: path) else {
            Log("addDecorators: could not resolve path '\(path)'", type: .warning)
            return
        }
        var list = fetchDecorators(for: target)
        list.append(contentsOf: decorators)
        applyDecorators(list, for: target)
    }

    /// Removes the decorator whose `action` matches at the given path.
    func removeDecorator(path: String, action: String) {
        guard let target = resolveDecoratorTarget(path: path) else {
            Log("removeDecorator: could not resolve path '\(path)'", type: .warning)
            return
        }
        var list = fetchDecorators(for: target)
        list.removeAll { $0.action == action }
        applyDecorators(list, for: target)
    }

    /// Replaces the decorator whose `action` matches with the new decorator at the given path.
    func updateDecorator(path: String, action: String, decorator: Decorator) {
        guard let target = resolveDecoratorTarget(path: path) else {
            Log("updateDecorator: could not resolve path '\(path)'", type: .warning)
            return
        }
        var list = fetchDecorators(for: target)
        guard let index = list.firstIndex(where: { $0.action == action }) else {
            Log("updateDecorator: no decorator with action '\(action)' found at path '\(path)'", type: .warning)
            return
        }
        list[index] = decorator
        applyDecorators(list, for: target)
    }
}

// MARK: - Private helpers

private extension DocumentEditor {

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

        guard
            let pageId          = parsed.pageId,
            let fieldPositionId = parsed.fieldPositionId,
            let fieldIdentifier = getFieldIdentifier(forFieldPositionID: fieldPositionId),
            fieldIdentifier.pageID == pageId
        else { return nil }

        let fieldID = fieldIdentifier.fieldID

        if let columnId = parsed.columnId {
            // 4 segments → column decorators; rowId resolves the schema for collection fields
            let schemaKey = parsed.rowId.flatMap { resolvedSchemaKey(forRowID: $0, inFieldID: fieldID) }
            return .column(fieldID: fieldID, columnID: columnId, schemaKey: schemaKey)
        } else if let rowId = parsed.rowId {
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
