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

    // Cached effective required state, used to detect changes for dependent-field refresh.
    private var requiredFieldMap = [String: Bool]()
    private var requiredColumnMap = [String: [ColumnSchemaID: Bool]]() // fieldID -> column -> required

    // dependentFieldID (a field referenced by some requiredLogic condition) -> owning field/table/collection ids
    private var requiredDependencyMap = [String: Set<String>]()

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
            } else if field.fieldType == .collection {
                buildColumnRequiredForCollection(field: field, fieldID: fieldID)
            }
        }
    }

    // MARK: - Public API

    /// Effective required-ness of a field, honouring `requiredLogic`.
    func isFieldRequired(fieldID: String) -> Bool {
        guard let field = documentEditor.field(fieldID: fieldID) else { return false }
        return computeFieldRequired(field: field)
    }

    /// Effective column-wide required-ness, honouring the column's `requiredLogic`.
    func isColumnRequired(columnID: String, fieldID: String, schemaKey: String? = nil) -> Bool {
        guard let column = column(columnID: columnID, fieldID: fieldID, schemaKey: schemaKey) else { return false }
        return computeColumnRequired(column: column)
    }

    /// Effective required-ness of a single cell. Precedence: `cellRequiredLogic` (per-row) >
    /// `requiredLogic` (column-wide) > static `required`.
    func isCellRequired(columnID: String, fieldID: String, schemaKey: String? = nil, row: ValueElement) -> Bool {
        guard let column = column(columnID: columnID, fieldID: fieldID, schemaKey: schemaKey) else { return false }

        if let cellLogic = column.cellRequiredLogic, let action = cellLogic.action {
            let model = cellLogicModel(logic: cellLogic, columns: columns(fieldID: fieldID, schemaKey: schemaKey), row: row)
            return applyAction(action, matched: documentEditor.conditionalLogicHandler.shoulTakeActionOnThisField(logic: model), staticRequired: computeColumnRequired(column: column))
        }
        return computeColumnRequired(column: column)
    }

    /// Fields that must be re-rendered because `fieldID` changed and some requiredLogic depends on it.
    func fieldsNeedsToBeRefreshed(fieldID: String) -> [String] {
        guard let owners = requiredDependencyMap[fieldID] else { return [] }
        var refreshIDs = [String]()
        for ownerID in owners {
            guard let field = documentEditor.field(fieldID: ownerID) else { continue }
            switch field.fieldType {
            case .table, .collection:
                var changed = columnRequiredChanged(field: field, fieldID: ownerID)
                let newFieldRequired = computeFieldRequired(field: field)
                if requiredFieldMap[ownerID] != newFieldRequired {
                    requiredFieldMap[ownerID] = newFieldRequired
                    changed = true
                }
                if changed {
                    refreshIDs.append(ownerID)
                }
            default:
                let newValue = computeFieldRequired(field: field)
                if requiredFieldMap[ownerID] != newValue {
                    requiredFieldMap[ownerID] = newValue
                    refreshIDs.append(ownerID)
                }
            }
        }
        return refreshIDs
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
        // Column requiredLogic references page-level fields; register those as dependencies.
        register(logic: column.requiredLogic, ownerFieldID: ownerFieldID)
        // cellRequiredLogic references sibling cells within the same row, so a change to the owning
        // table/collection field already triggers its own refresh — no external dependency to register.
    }

    private func register(logic: Logic?, ownerFieldID: String) {
        guard let conditions = logic?.conditions else { return }
        for condition in conditions {
            guard let dependentFieldID = condition.field else { continue }
            var owners = requiredDependencyMap[dependentFieldID] ?? Set<String>()
            owners.insert(ownerFieldID)
            requiredDependencyMap[dependentFieldID] = owners
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

    /// Builds a model for cellRequiredLogic whose conditions reference sibling column ids in the same row.
    private func cellLogicModel(logic: Logic, columns: [FieldTableColumn], row: ValueElement) -> LogicModel {
        let conditionModels = (logic.conditions ?? []).compactMap { condition -> ConditionModel? in
            guard let siblingColumnID = condition.field else { return nil }
            let columnType = columns.first(where: { $0.id == siblingColumnID })?.type?.toFieldType ?? .unknown
            let cellValue = row.cells?[siblingColumnID]
            return ConditionModel(fieldValue: cellValue, fieldType: columnType, condition: condition.condition, value: condition.value)
        }
        return LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
    }

    // MARK: - Lookups

    private func columns(fieldID: String, schemaKey: String?) -> [FieldTableColumn] {
        guard let field = documentEditor.field(fieldID: fieldID) else { return [] }
        if let schemaKey = schemaKey {
            return field.schema?[schemaKey]?.tableColumns ?? []
        }
        return field.tableColumns ?? []
    }

    private func column(columnID: String, fieldID: String, schemaKey: String?) -> FieldTableColumn? {
        return columns(fieldID: fieldID, schemaKey: schemaKey).first(where: { $0.id == columnID })
    }
}
