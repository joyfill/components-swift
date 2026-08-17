//
//  RequiredLogicHandler.swift
//
//  Evaluates `requiredLogic` (fields, columns) and `cellRequiredLogic` (per-cell) to produce
//  an *effective* required-ness on top of the static `required` flag.
//
//  Semantics (the action only changes required-ness when its conditions match; otherwise it falls back to the static base):
//    - no logic present            -> static `required`
//    - action == "enforce"         -> required when conditions match, else static `required`
//    - action == "unenforce"         -> optional when conditions match, else static `required`
//
//  Field / column logic conditions reference page-level fields (by `field` id).
//  Cell logic conditions reference sibling column ids and resolve against the same row's cells.
//

import Foundation
import JoyfillModel

class RequiredLogicHandler {
    weak var documentEditor: DocumentEditor!

    // Is it required? — the answers the UI reads.
    private var requiredFieldMap = [String: Bool]()                      // fieldID : isRequired
    private var requiredColumnMap = [String: [ColumnSchemaID: Bool]]()   // fieldID : (columnID + schemaID) : isRequired
    private var cellRequiredMap = [String: [CellID: Bool]]()   // fieldID : (rowID + columnID) : isRequired

    // What to refresh when something changes. Built from the logic listed first, keyed by what changed.
    private var requiredFieldDependencyMap = [String: Set<String>]()                 // requiredLogic `field` conditions → changed fieldID : fields/tables to re-render
    private var cellRequiredFieldDependencyMap = [String: Set<String>]()             // cellRequiredLogic `field` conditions → changed fieldID : tables to re-render (per-row, so the column check misses it)
    private var cellRequiredSiblingDependencyMap = [String: [String: Set<String>]]() // cellRequiredLogic `column` conditions → fieldID : siblingColumnID : dependent columnIDs
    private var fieldCellRequiredDependencyMap = [String: [(tableFieldID: String, columnID: String, schemaID: String?)]]() // both logics' `field` conditions → changed fieldID : dependent (tableFieldID, columnID, schemaID); schemaID is nil for tables

    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
        documentEditor.allFields.forEach { field in
            guard let fieldID = field.id else {
                Log("Field ID not found", type: .error)
                return
            }
            requiredFieldMap[fieldID] = computeFieldRequired(field: field)
            registerFieldDependencies(field: field, ownerFieldID: fieldID)

            if field.fieldType == .table {
                buildColumnRequiredForTable(field: field, fieldID: fieldID)
                buildCellRequiredForTableField(field: field, fieldID: fieldID)
            } else if field.fieldType == .collection {
                buildColumnRequiredForCollection(field: field, fieldID: fieldID)
                buildCellRequiredForCollectionField(field: field, fieldID: fieldID)
            }
        }
    }

    // MARK: - Public API

    /// Effective required-ness of a field — an O(1) read from the cache, mirroring
    /// `ConditionalLogicHandler.shouldShow(fieldID:)`.
    func isFieldRequired(fieldID: String) -> Bool {
        return requiredFieldMap[fieldID] ?? false
    }

    /// Effective column-wide required-ness — an O(1) read from the cache, mirroring
    /// `ConditionalLogicHandler.shouldShow(columnID:fieldID:schemaKey:)`.
    func isColumnRequired(columnID: String, fieldID: String, schemaKey: String? = nil) -> Bool {
        return requiredColumnMap[fieldID]?[ColumnSchemaID(columnID: columnID, schemaID: schemaKey)] ?? false
    }

    /// Effective required-ness of a single cell — an O(1) read from the per-cell cache, mirroring
    /// `ConditionalLogicHandler.shouldShowCell`. The cache is authoritative for both tables and
    /// collections; a cell with no required signal is absent from the map and reads as `false`.
    /// `schemaKey` is accepted for call-site symmetry but not needed for the read (row IDs are unique).
    func isCellRequired(columnID: String, fieldID: String, schemaKey: String? = nil, rowID: String) -> Bool {
        let cellID = CellID(rowID: rowID, columnID: columnID)
        return cellRequiredMap[fieldID]?[cellID] ?? false
    }

    /// Fields that must be re-rendered because `fieldID` changed and some requiredLogic depends on it.
    func fieldsNeedsToBeRefreshed(fieldID: String) -> [String] {
        let cellDependentFields = cellRequiredFieldDependencyMap[fieldID] ?? Set<String>()
        var dependentFields = requiredFieldDependencyMap[fieldID] ?? Set<String>()
        dependentFields.formUnion(cellDependentFields)
        guard !dependentFields.isEmpty else { return [] }
        var refreshFieldIDs = [String]()
        for dependentFieldID in dependentFields {
            guard let field = documentEditor.field(fieldID: dependentFieldID) else { continue }
            switch field.fieldType {
            case .table, .collection:
                var changed = columnRequiredChanged(field: field, fieldID: dependentFieldID)
                // Cell-level logic is per-row and evaluated lazily, so column/field recomputation can't
                // observe it — if this change touches a cell-logic dependency, force a refresh.
                if cellDependentFields.contains(dependentFieldID) { changed = true }
                let newFieldRequired = computeFieldRequired(field: field)
                if requiredFieldMap[dependentFieldID] != newFieldRequired {
                    requiredFieldMap[dependentFieldID] = newFieldRequired
                    changed = true
                }
                if changed {
                    refreshFieldIDs.append(dependentFieldID)
                }
            default:
                let newValue = computeFieldRequired(field: field)
                if requiredFieldMap[dependentFieldID] != newValue {
                    requiredFieldMap[dependentFieldID] = newValue
                    refreshFieldIDs.append(dependentFieldID)
                }
            }
        }
        return refreshFieldIDs
    }

    // MARK: - Cache building

    private func buildColumnRequiredForTable(field: JoyDocField, fieldID: String) {
        guard let columns = field.tableColumns else { return }
        var map = [ColumnSchemaID: Bool]()
        for column in columns {
            guard let columnID = column.id else { continue }
            map[ColumnSchemaID(columnID: columnID)] = computeColumnRequired(column: column)
            registerColumnDependencies(column: column, ownerFieldID: fieldID)
        }
        requiredColumnMap[fieldID] = map
    }

    private func buildColumnRequiredForCollection(field: JoyDocField, fieldID: String) {
        guard let schema = field.schema else { return }
        var map = [ColumnSchemaID: Bool]()
        for (schemaKey, schemaValue) in schema {
            guard let columns = schemaValue.tableColumns else { continue }
            for column in columns {
                guard let columnID = column.id else { continue }
                map[ColumnSchemaID(columnID: columnID, schemaID: schemaKey)] = computeColumnRequired(column: column)
                registerColumnDependencies(column: column, ownerFieldID: fieldID)
            }
        }
        requiredColumnMap[fieldID] = map
    }

    private func registerFieldDependencies(field: JoyDocField, ownerFieldID: String) {
        register(logic: field.requiredLogic, ownerFieldID: ownerFieldID)
    }

    private func registerColumnDependencies(column: FieldTableColumn, ownerFieldID: String) {
        // Column requiredLogic references document-level fields; register those as dependencies.
        register(logic: column.requiredLogic, ownerFieldID: ownerFieldID)
        // cellRequiredLogic resolves sibling-cell (`column`) conditions from the row itself — a change
        // there already refreshes the owning table/collection. But it can ALSO reference document-level
        // fields (`field` conditions); track those separately so an external change forces the owning
        // table/collection to re-validate its per-row cells.
        registerCellLogicDependencies(logic: column.cellRequiredLogic, ownerFieldID: ownerFieldID)
    }

    private func register(logic: Logic?, ownerFieldID: String) {
        guard let conditions = logic?.conditions else { return }
        for condition in conditions {
            guard let dependentFieldID = condition.field else { continue }
            var owners = requiredFieldDependencyMap[dependentFieldID] ?? Set<String>()
            owners.insert(ownerFieldID)
            requiredFieldDependencyMap[dependentFieldID] = owners
        }
    }

    private func registerCellLogicDependencies(logic: Logic?, ownerFieldID: String) {
        guard let conditions = logic?.conditions else { return }
        for condition in conditions {
            // Only `field` (document-level) conditions are external dependencies; `column` (sibling) ones
            // resolve from the row itself.
            guard let dependentFieldID = condition.field else { continue }
            var owners = cellRequiredFieldDependencyMap[dependentFieldID] ?? Set<String>()
            owners.insert(ownerFieldID)
            cellRequiredFieldDependencyMap[dependentFieldID] = owners
        }
    }

    private func columnRequiredChanged(field: JoyDocField, fieldID: String) -> Bool {
        var map = requiredColumnMap[fieldID] ?? [:]
        var hasChange = false

        func check(column: FieldTableColumn, schemaKey: String?) {
            guard let columnID = column.id else { return }
            let key = ColumnSchemaID(columnID: columnID, schemaID: schemaKey)
            let newValue = computeColumnRequired(column: column)
            if map[key] != newValue {
                map[key] = newValue
                hasChange = true
            }
        }

        switch field.fieldType {
        case .table:
            for column in field.tableColumns ?? [] { check(column: column, schemaKey: nil) }
        case .collection:
            for (schemaKey, schemaValue) in field.schema ?? [:] {
                for column in schemaValue.tableColumns ?? [] { check(column: column, schemaKey: schemaKey) }
            }
        default:
            break
        }

        if hasChange { requiredColumnMap[fieldID] = map }
        return hasChange
    }

    // MARK: - Effective-required computation

    private func computeFieldRequired(field: JoyDocField) -> Bool {
        let staticRequired = field.required ?? false
        guard let logic = field.requiredLogic, let action = logic.action else { return staticRequired }
        let model = fieldLogicModel(logic: logic)
        return applyAction(action, matched: documentEditor.conditionalLogicHandler.shoulTakeActionOnThisField(logic: model), staticRequired: staticRequired)
    }

    private func computeColumnRequired(column: FieldTableColumn) -> Bool {
        let staticRequired = column.required ?? false
        guard let logic = column.requiredLogic, let action = logic.action else { return staticRequired }
        let model = fieldLogicModel(logic: logic)
        return applyAction(action, matched: documentEditor.conditionalLogicHandler.shoulTakeActionOnThisField(logic: model), staticRequired: staticRequired)
    }

    private func applyAction(_ action: String, matched: Bool, staticRequired: Bool) -> Bool {
        switch action {
        case "enforce": return matched ? true : staticRequired
        case "unenforce": return matched ? false : staticRequired
        default: return staticRequired
        }
    }

    // MARK: - Logic-model builders

    /// Builds a model for field/column requiredLogic whose conditions reference page-level fields.
    private func fieldLogicModel(logic: Logic) -> LogicModel {
        let conditionModels = (logic.conditions ?? []).compactMap { condition -> ConditionModel? in
            guard let conditionFieldID = condition.field,
                  let conditionField = documentEditor.field(fieldID: conditionFieldID) else { return nil }
            return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
        }
        return LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
    }

    /// Builds a model for cellRequiredLogic. Each condition is resolved by kind:
    ///   - `column` -> a sibling cell in the same row (resolved against `row.cells`)
    ///   - `field`  -> a page-level field (resolved against the document)
    private func cellLogicModel(logic: Logic, columns: [FieldTableColumn], row: ValueElement) -> LogicModel {
        let conditionModels = (logic.conditions ?? []).compactMap { condition -> ConditionModel? in
            if let siblingColumnID = condition.column {
                let columnType = columns.first(where: { $0.id == siblingColumnID })?.type?.toFieldType ?? .unknown
                let cellValue = row.cells?[siblingColumnID]
                return ConditionModel(fieldValue: cellValue, fieldType: columnType, condition: condition.condition, value: condition.value)
            } else if let conditionFieldID = condition.field,
                      let conditionField = documentEditor.field(fieldID: conditionFieldID) {
                return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
            }
            return nil
        }
        return LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
    }

    // MARK: - Lookups

    func columns(fieldID: String, schemaKey: String?) -> [FieldTableColumn] {
        guard let field = documentEditor.field(fieldID: fieldID) else { return [] }
        if let schemaKey = schemaKey {
            return field.schema?[schemaKey]?.tableColumns ?? []
        }
        return field.tableColumns ?? []
    }
}

// MARK: - CellRequiredLogic

extension RequiredLogicHandler {
    func buildCellRequiredForTableField(field: JoyDocField, fieldID: String) {
        guard let columns = field.tableColumns else { return }

        var dependencyMap = [String: Set<String>]()
        for column in columns {
            guard let columnID = column.id else { continue }
            registerCellRequiredDependencies(column: column, columnID: columnID, fieldID: fieldID, schemaID: nil, into: &dependencyMap)
        }
        cellRequiredSiblingDependencyMap[fieldID] = dependencyMap

        cellRequiredMap[fieldID] = [:]
        for row in field.valueToValueElements ?? [] {
            setCellRequired(fieldID: fieldID, columns: columns, row: row)
        }
    }

    func buildCellRequiredForCollectionField(field: JoyDocField, fieldID: String) {
        guard let schema = field.schema else { return }

        var dependencyMap = [String: Set<String>]()
        for (schemaKey, schemaValue) in schema {
            for column in schemaValue.tableColumns ?? [] {
                guard let columnID = column.id else { continue }
                registerCellRequiredDependencies(column: column, columnID: columnID, fieldID: fieldID, schemaID: schemaKey, into: &dependencyMap)
            }
        }
        cellRequiredSiblingDependencyMap[fieldID] = dependencyMap

        cellRequiredMap[fieldID] = [:]
        let rootSchemaKey = schema.first { $0.value.root == true }?.key ?? ""
        setCollectionCellRequired(fieldID: fieldID, schema: schema, valueElements: field.valueToValueElements ?? [], schemaKey: rootSchemaKey)
    }

    /// A cell's stored value is driven by its own `cellRequiredLogic` *and* by the column's
    /// `requiredLogic` (the fallback), so conditions from both are registered as invalidation triggers.
    private func registerCellRequiredDependencies(column: FieldTableColumn, columnID: String, fieldID: String, schemaID: String?, into dependencyMap: inout [String: Set<String>]) {
        let conditions = (column.cellRequiredLogic?.conditions ?? []) + (column.requiredLogic?.conditions ?? [])
        for condition in conditions {
            if let siblingColumnID = condition.column {
                dependencyMap[siblingColumnID, default: Set()].insert(columnID)
            } else if let dependentFieldID = condition.field {
                fieldCellRequiredDependencyMap[dependentFieldID, default: []].append((tableFieldID: fieldID, columnID: columnID, schemaID: schemaID))
            }
        }
    }

    private func setCollectionCellRequired(fieldID: String, schema: [String: Schema], valueElements: [ValueElement], schemaKey: String) {
        guard let columns = schema[schemaKey]?.tableColumns else { return }
        for element in valueElements {
            setCellRequired(fieldID: fieldID, columns: columns, row: element)
            for (childSchemaID, child) in element.childrens ?? [:] {
                setCollectionCellRequired(fieldID: fieldID, schema: schema, valueElements: child.valueToValueElements ?? [], schemaKey: childSchemaID)
            }
        }
    }

    func addCellRequiredForRow(fieldID: String, schemaID: String? = nil, row: ValueElement) {
        setCellRequired(fieldID: fieldID, columns: columns(fieldID: fieldID, schemaKey: schemaID), row: row)
    }

    func removeCellRequiredForRow(fieldID: String, rowID: String) {
        cellRequiredMap[fieldID] = cellRequiredMap[fieldID]?.filter { $0.key.rowID != rowID }
    }

    /// Columns with no required signal at all can never resolve to `true`, so they stay out of the map.
    private func setCellRequired(fieldID: String, columns: [FieldTableColumn], row: ValueElement) {
        for column in columns {
            guard let columnID = column.id,
                  column.cellRequiredLogic != nil || column.requiredLogic != nil || (column.required ?? false) else { continue }
            updateCellRequired(fieldID: fieldID, columns: columns, columnID: columnID, row: row)
        }
    }

    /// The only place a cell's required-ness is computed and stored in `cellRequiredMap`; returns `true`
    /// if the value changed. Precedence: `cellRequiredLogic` (per-row) > column `requiredLogic` > static
    /// `required`, with the column-wide result acting as the static base the cell action applies on top of.
    @discardableResult
    private func updateCellRequired(fieldID: String, columns: [FieldTableColumn], columnID: String, row: ValueElement) -> Bool {
        guard let rowID = row.id, let column = columns.first(where: { $0.id == columnID }) else { return false }
        let cellID = CellID(rowID: rowID, columnID: columnID)

        let columnRequired = computeColumnRequired(column: column)
        let newValue: Bool
        if let cellLogic = column.cellRequiredLogic, let action = cellLogic.action {
            let model = cellLogicModel(logic: cellLogic, columns: columns, row: row)
            newValue = applyAction(action, matched: documentEditor.conditionalLogicHandler.shoulTakeActionOnThisField(logic: model), staticRequired: columnRequired)
        } else {
            newValue = columnRequired
        }

        let didChange = cellRequiredMap[fieldID]?[cellID] != newValue
        cellRequiredMap[fieldID, default: [:]][cellID] = newValue
        return didChange
    }

    func hasCellDependents(fieldID: String, editedColumnID: String) -> Bool {
        return cellRequiredSiblingDependencyMap[fieldID]?[editedColumnID] != nil
    }

    func cellRequiredNeedToBeRefreshed(fieldID: String, schemaID: String? = nil, editedColumnID: String, row: ValueElement) -> [String] {
        guard let dependentColumns = cellRequiredSiblingDependencyMap[fieldID]?[editedColumnID] else { return [] }
        let columns = columns(fieldID: fieldID, schemaKey: schemaID)
        guard !columns.isEmpty else { return [] }
        return dependentColumns.filter { updateCellRequired(fieldID: fieldID, columns: columns, columnID: $0, row: row) }
    }

    /// Outside-the-table field change: re-resolve every affected cell. The owning table/collection
    /// re-renders via `fieldsNeedsToBeRefreshed`, so this only has to leave the map correct before that read.
    func cellRequiredNeedRefreshForField(fieldID: String) {
        guard let refs = fieldCellRequiredDependencyMap[fieldID] else { return }
        for ref in refs {
            guard let field = documentEditor.field(fieldID: ref.tableFieldID) else { continue }
            let columns = columns(fieldID: ref.tableFieldID, schemaKey: ref.schemaID)
            guard !columns.isEmpty else { continue }
            let rows = ref.schemaID.map { rowsForCollectionSchema(field: field, schemaID: $0) } ?? (field.valueToValueElements ?? [])
            for row in rows {
                updateCellRequired(fieldID: ref.tableFieldID, columns: columns, columnID: ref.columnID, row: row)
            }
        }
    }

    private func rowsForCollectionSchema(field: JoyDocField, schemaID: String) -> [ValueElement] {
        guard let schema = field.schema else { return [] }
        let rootSchemaKey = schema.first { $0.value.root == true }?.key ?? ""
        var rows = [ValueElement]()
        collectRows(valueElements: field.valueToValueElements ?? [], schemaKey: rootSchemaKey, targetSchemaID: schemaID, into: &rows)
        return rows
    }

    private func collectRows(valueElements: [ValueElement], schemaKey: String, targetSchemaID: String, into rows: inout [ValueElement]) {
        for element in valueElements {
            if schemaKey == targetSchemaID {
                rows.append(element)
            }
            for (childSchemaID, child) in element.childrens ?? [:] {
                collectRows(valueElements: child.valueToValueElements ?? [], schemaKey: childSchemaID, targetSchemaID: targetSchemaID, into: &rows)
            }
        }
    }
}
