//
//  File.swift
//
//
//  Created by Vishnu Dutt on 05/12/24.
//

import Foundation
import JoyfillModel



// 1. Cache strcture build
// 2. Cache build in init
//   2.1 Wrte a function to check if schema needs to be shown
// 3. Call new API
// 4. Write logic to update the cache
//     on each cell change document editor will Check if needs to update the cache
//      if yes call the 2.1 to check if schema needs to be shown
//      update the cache


public struct RowSchemaID: Hashable {
    public let rowID: String
    public let schemaID: String
    
    public init(rowID: String, schemaID: String) {
        self.rowID = rowID
        self.schemaID = schemaID
    }
}

public struct ColumnSchemaID: Hashable {
    public let columnID: String
    public let schemaID: String?
    
    public init(columnID: String, schemaID: String? = nil) {
        self.columnID = columnID
        self.schemaID = schemaID
    }
}

public struct CollectionSchemaLogic {
    public var showSchemaMap = [RowSchemaID: Bool]()   // RowSchemaID : Bool
}

public struct ColumnLogic {
    public var showColumnMap = [ColumnSchemaID: Bool]()   // ColumnSchemaID : Bool
}

public struct CollectionDependency {
    public var columnDependencyMap = [String: Set<String>]() // columnID: Set of SchemaIDs
}

class ConditionalLogicHandler {
    weak var documentEditor: DocumentEditor!
    var showFieldMap = [String: Bool]()
    private var fieldConditionalDependencyMap = [String: Set<String>]()

    private var showCollectionSchemaMap = [String: CollectionSchemaLogic]() // CollectionFieldID : CollectionSchemaLogic
    private var collectionDependencyMap = [String: CollectionDependency]() // CollectionFieldID : CollectionDependency
    private var showColumnLogicMap = [String: ColumnLogic]() // Table/Collection fieldID : ColumnLogic

    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
        documentEditor.allFields.forEach { field in
            guard let fieldID = field.id else {
                Log("Field ID not found", type: .error)
                return
            }
            showFieldMap[fieldID] = self.shouldShowLocal(fieldID: fieldID)

            if field.fieldType == .table {
                buildColumnLogicForTableField(field: field, fieldID: fieldID)
            } else if field.fieldType == .collection {
                buildDependencyMap(field: field)
                buildCollectionSchemaMap(field: field)
                buildColumnLogicForCollectionField(field: field, fieldID: fieldID)
            }
        }
    }

    private func buildColumnLogicForTableField(field: JoyDocField, fieldID: String) {
        guard let columns = field.tableColumns else { return }
        var columnLogic = ColumnLogic()
        for column in columns {
            guard let columnID = column.id else { continue }
            let columnSchemaID = ColumnSchemaID(columnID: columnID)
            columnLogic.showColumnMap[columnSchemaID] = shouldShowColumnLocal(column: column, fieldID: fieldID, schemaKey: nil)
            registerColumnDependencies(column: column, parentFieldID: fieldID)
        }
        showColumnLogicMap[fieldID] = columnLogic
    }

    private func buildColumnLogicForCollectionField(field: JoyDocField, fieldID: String) {
        guard let schema = field.schema else { return }
        var columnLogic = ColumnLogic()
        for (schemaKey, schemaValue) in schema {
            guard let columns = schemaValue.tableColumns else { continue }
            for column in columns {
                guard let columnID = column.id else { continue }
                let columnSchemaID = ColumnSchemaID(columnID: columnID, schemaID: schemaKey)
                columnLogic.showColumnMap[columnSchemaID] = shouldShowColumnLocal(column: column, fieldID: fieldID, schemaKey: schemaKey)
                registerColumnDependencies(column: column, parentFieldID: fieldID)
            }
        }
        showColumnLogicMap[fieldID] = columnLogic
    }

    private func registerColumnDependencies(column: FieldTableColumn, parentFieldID: String) {
        guard let logic = column.logic, let conditions = logic.conditions else { return }
        for condition in conditions {
            guard let dependentFieldID = condition.field else { continue }
            var set = fieldConditionalDependencyMap[dependentFieldID] ?? Set()
            set.insert(parentFieldID)
            fieldConditionalDependencyMap[dependentFieldID] = set
        }
    }
    
    private func buildDependencyMap(field: JoyDocField) {
        guard let schema = field.schema, let fieldID = field.id else { return }
        
        var dependencyLogic = CollectionDependency()
        
        for (schemaID, schemaDetails) in schema {
            if let logic = schemaDetails.logic,
               let conditions = logic.schemaConditions {
                
                for condition in conditions {
                    guard let columnID = condition.columnID else { continue }
                    
                    var dependentSchemas = dependencyLogic.columnDependencyMap[columnID] ?? Set<String>()
                    dependentSchemas.insert(schemaID)
                    dependencyLogic.columnDependencyMap[columnID] = dependentSchemas
                }
            }
        }
        
        collectionDependencyMap[fieldID] = dependencyLogic
    }
    
    func buildCollectionSchemaMap(field: JoyDocField) {
        let schema = field.schema ?? [:]
        let rootSchemaKey = schema.first { $0.value.root == true }?.key ?? ""
        let showSchemaMap = buildSchemaMap(valueElements: field.valueToValueElements ?? [], schema: schema, key: rootSchemaKey)
        let collectionSchemaLogic = CollectionSchemaLogic(showSchemaMap: showSchemaMap)
        guard let fieldID = field.id else {
            Log("Field ID not found", type: .error)
            return
        }
        showCollectionSchemaMap[fieldID] = collectionSchemaLogic
    }
    
    func buildSchemaMap(valueElements: [ValueElement], schema: [String: Schema], key: String) -> [RowSchemaID: Bool] {
        var map = [RowSchemaID: Bool]()

        for element in valueElements {
            guard let rowID = element.id else { continue }
            
            if let childrens = element.childrens, childrens.count > 0 {
                childrens.forEach { (childSchemaID, child) in
                    let key = RowSchemaID(rowID: rowID, schemaID: childSchemaID)
                    map[key] = shouldShow(fullSchema: schema, schemaID: childSchemaID, valueElement: element)

                    if let nested = child.valueToValueElements {
                        let childMap = buildSchemaMap(valueElements: nested, schema: schema, key: childSchemaID)
                        map.merge(childMap) { (_, new) in new }
                    }
                }
            } else {
                for schemaID in schema[key]?.children ?? [] {
                    let key = RowSchemaID(rowID: rowID, schemaID: schemaID)
                    map[key] = shouldShow(fullSchema: schema, schemaID: schemaID, valueElement: element)
                }
            }
        }

        return map
    }

    public func shouldShow(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        return showFieldMap[fieldID] ?? true
    }

    public func shouldShow(pageID: String?) -> Bool {
        guard let pageID = pageID else { return true }
        guard let page = documentEditor.pagesForCurrentView.first(where: { $0.id == pageID }) else { return true }
        return shouldShow(page: page)
    }
    
    public func shouldShow(columnID: String, fieldID: String, schemaKey: String? = nil) -> Bool {
        let columnSchemaID = ColumnSchemaID(columnID: columnID, schemaID: schemaKey)
        return showColumnLogicMap[fieldID]?.showColumnMap[columnSchemaID] ?? true
    }

    func fieldsNeedsToBeRefreshed(fieldID: String) -> [String] {
        var refreshFieldIDs = [String]()
        guard let dependentFields = fieldConditionalDependencyMap[fieldID] else { return []}
        // Refresh dependent fields if required
        for dependentFieldId in dependentFields {
            var needsRefresh = false
            if columnsNeedsToRefreshed(dependentFieldId: dependentFieldId) {
                needsRefresh = true
            }
            // Regular field: refresh when field visibility changed
            let shouldShow = shouldShowLocal(fieldID: dependentFieldId)
            if showFieldMap[dependentFieldId] != shouldShow {
                showFieldMap[dependentFieldId] = shouldShow
                needsRefresh = true
            }
            if needsRefresh {
                refreshFieldIDs.append(dependentFieldId)
            }
        }
        return refreshFieldIDs
    }

    func columnsNeedsToRefreshed(dependentFieldId: String) -> Bool {
        guard let field = documentEditor.field(fieldID: dependentFieldId) else { return false }
        switch field.fieldType {
        case .table:
            var showColumnMap = showColumnLogicMap[dependentFieldId]?.showColumnMap ?? [:]
            let tableColumns = field.tableColumns ?? []
            for tableColumn in tableColumns {
                guard let columnID = tableColumn.id else { continue }
                let columnSchemaID = ColumnSchemaID(columnID: columnID, schemaID: nil)
                let shouldShowColumn = shouldShowColumnLocal(column: tableColumn, fieldID: dependentFieldId, schemaKey: nil)
                if showColumnMap[columnSchemaID] != shouldShowColumn {
                    showColumnMap[columnSchemaID] = shouldShowColumn
                    var columnLogic = showColumnLogicMap[dependentFieldId] ?? ColumnLogic()
                    columnLogic.showColumnMap = showColumnMap
                    showColumnLogicMap[dependentFieldId] = columnLogic
                    return true
                }
            }
            return false
        case .collection:
            guard let schema = field.schema else { return false }
            var columnLogic = showColumnLogicMap[dependentFieldId] ?? ColumnLogic()
            var showColumnMap = columnLogic.showColumnMap
            for (schemaKey, schemaValue) in schema {
                guard let tableColumns = schemaValue.tableColumns else { continue }
                for tableColumn in tableColumns {
                    guard let columnID = tableColumn.id else { continue }
                    let columnSchemaID = ColumnSchemaID(columnID: columnID, schemaID: schemaKey)
                    let shouldShowColumn = shouldShowColumnLocal(column: tableColumn, fieldID: dependentFieldId, schemaKey: schemaKey)
                    if showColumnMap[columnSchemaID] != shouldShowColumn {
                        showColumnMap[columnSchemaID] = shouldShowColumn
                        columnLogic.showColumnMap = showColumnMap
                        showColumnLogicMap[dependentFieldId] = columnLogic
                        return true
                    }
                }
            }
            return false
        default:
            return false
        }
    }

    func shouldShow(page: Page?) -> Bool {
        guard let page = page else { return true }
        let model = conditionalLogicModel(page: page)
        let lastHiddenState = page.hidden
        guard let model = model, model.itemCount > 1 else {
            if documentEditor.pagesForCurrentView.count > 1 {
                return !(lastHiddenState ?? false)
            } else {
                return true
            }
        }
        return shouldShowItem(model: model, lastHiddenState: lastHiddenState)
    }

    public func shouldShowSchema(for collectionFieldID: String, rowSchemaID: RowSchemaID) -> Bool {
        return showCollectionSchemaMap[collectionFieldID]?.showSchemaMap[rowSchemaID] ?? true
    }

    private func shouldShow(fullSchema: [String : Schema]?, schemaID: String, valueElement: ValueElement?) -> Bool {
        guard let fullSchema = fullSchema else { return true }
        let model = conditionalLogicModel(fullSchema: fullSchema, schemaID: schemaID, valueElement: valueElement)
        let lastHiddenState = fullSchema[schemaID]?.hidden
        guard let model = model else {
            return !(lastHiddenState ?? false)
        }
        return shouldShowItem(model: model, lastHiddenState: lastHiddenState)
    }

    private func conditionalLogicModel(page: Page?) -> ConditionalLogicModel? {
        guard let page = page else { return nil }
        guard let logic = page.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition ->  ConditionModel? in
            guard let conditionFieldID = condition.field else { return nil }
            guard let conditionField = documentEditor.field(fieldID: conditionFieldID) else { return nil }
            return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
        }
        let logicModel = LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: page.hidden, itemCount: documentEditor.pagesForCurrentView.count)
        return conditionModel
    }
    
    private func conditionalLogicModel(column: FieldTableColumn?) -> ConditionalLogicModel? {
        guard let column = column else { return nil }
        guard let logic = column.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition ->  ConditionModel? in
            guard let conditionFieldID = condition.field else { return nil }
            guard let conditionField = documentEditor.field(fieldID: conditionFieldID) else { return nil }
            return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
        }
        let logicModel = LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: column.hidden, itemCount: 0)
        return conditionModel
    }
    
    private func conditionalLogicModel(fullSchema: [String : Schema]?, schemaID: String, valueElement: ValueElement?) -> ConditionalLogicModel? {
        guard let fullSchema = fullSchema else { return nil }
        guard let schema = fullSchema[schemaID] else { return nil }
        guard let logic = schema.logic else { return nil }
        guard let conditions = logic.schemaConditions else { return nil }
        

        let conditionModels = conditions.compactMap { condition ->  ConditionModel? in
            //here we dont have the field we have column id and parent schema key
            //from these we need to extract the cell value
            guard let columnID = condition.columnID else { return nil }
            guard let parentSchemaKey = condition.schema else { return nil }
            let cellType = fullSchema[parentSchemaKey]?.tableColumns?.first(where: { $0.id == columnID })?.type
            
            //here we need the value associated with the column id
            let cellValue = getCellValue(for: columnID, valueElement: valueElement)
            //here we need to pass the cell value and cell type , condition and condition value
            return ConditionModel(fieldValue: cellValue, fieldType: cellType?.toFieldType ?? .unknown, condition: condition.condition, value: condition.value)
        }
        let logicModel = LogicModel(id: logic.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: schema.hidden, itemCount: 0)
        return conditionModel
    }
    
    private func getCellValue(for columnID: String, valueElement: ValueElement?) -> ValueUnion? {
        guard let valueElement = valueElement else { return nil }
        
        if let cell = valueElement.cells?.first(where: { $0.key == columnID })?.value {
            return cell
        }
        
        return nil
    }

    private func conditionalLogicModel(field: JoyDocField?) -> ConditionalLogicModel? {
        guard let field = field else { return nil }
        guard let logic = field.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition -> ConditionModel?  in
            guard let fieldID = condition.field else { return nil }
            guard let dependentField = documentEditor.field(fieldID: fieldID) else { return nil }
            guard let dependentFieldID = dependentField.id else {
                Log("Could not find dependent field ID", type: .error)
                return nil
            }

            var allDependentFields: Set<String> = fieldConditionalDependencyMap[dependentFieldID] ?? []
            if !allDependentFields.contains(dependentFieldID) {
                guard let id = field.id else {
                    Log("Could not find field ID", type: .error)
                    return nil
                }
                allDependentFields.insert(id)
                fieldConditionalDependencyMap[dependentFieldID] = allDependentFields
            }
            return ConditionModel(fieldValue: dependentField.value, fieldType: FieldTypes(dependentField.type), condition: condition.condition, value: condition.value)
        }

        let logicModel = LogicModel(id: field.logic?.id, action: logic.action, eval: logic.eval, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: field.hidden, itemCount: documentEditor.fieldsCount)
        return conditionModel
    }

    private func conditionalLogicModels() -> [ConditionalLogicModel] {
        let fields = documentEditor.allFields
        return fields.flatMap(conditionalLogicModel)
    }

    private func shouldShowColumnLocal(column: FieldTableColumn, fieldID: String, schemaKey: String?) -> Bool {
        if let views = column.hiddenViews, views.contains(ViewType.mobile.rawValue) { return false }
        
        let model = conditionalLogicModel(column: column)
        guard let model = model else {
            return !(column.hidden ?? false)
        }
        return shouldShowItem(model: model, lastHiddenState: column.hidden)
    }

    private func shouldShowItem(model: ConditionalLogicModel, lastHiddenState: Bool?) -> Bool {
        guard let logic = model.logic else {
            return !(lastHiddenState ?? false)
        }

        if let hidden = lastHiddenState {
            //Hidden is not nil
            if hidden && logic.action == "show" {
                //Hidden is true and action is show
                return self.shoulTakeActionOnThisField(logic: logic)
            } else if !hidden && logic.action == "show" {
                //Hidden is false and action is show
                return true
            } else if hidden && logic.action != "show" {
                //Hidden is true and action is hide
                return false
            } else {
                return !self.shoulTakeActionOnThisField(logic: logic)
            }
        } else {
            //Hidden is nil
            if logic.action == "show" {
                return true
            } else {
                return !self.shoulTakeActionOnThisField(logic: logic)
            }
        }
    }

    private func compareValue(fieldValue: ValueUnion?, condition: ConditionModel, fieldType: FieldTypes) -> Bool {
        switch condition.condition {
        case "=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String],
                   let conditionText = condition.value?.text {
                    return selectedArray.contains { $0 == conditionText }
                }
            }
            // For number comparison
            if fieldType == .number, let fieldNumber = fieldValue?.number, let conditionNumber = condition.value?.number {
                return fieldNumber == conditionNumber
            }
            // For text comparison
            if let fieldText = fieldValue?.text,
               let conditionText = condition.value?.text {
                return fieldText.lowercased() == conditionText.lowercased()
            }
            return fieldValue == condition.value
        case "!=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String],
                   let conditionText = condition.value?.text {
                    return !selectedArray.contains { $0 == conditionText }
                }
            }
            // For number comparison
            if fieldType == .number, let fieldNumber = fieldValue?.number, let conditionNumber = condition.value?.number {
                return fieldNumber != conditionNumber
            }
            // For text comparison
            if let fieldText = fieldValue?.text,
               let conditionText = condition.value?.text {
                return fieldText.lowercased() != conditionText.lowercased()
            }
            return fieldValue != condition.value
        case "?=":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueText = fieldValue.text?.lowercased(),
               let conditionValueText = condition.value?.text?.lowercased() {
                return fieldValueText.contains(conditionValueText)
            } else {
                return false
            }
        case ">":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber > conditionValueNumber
            } else {
                return false
            }
        case "<":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueNumber = fieldValue.number, let conditionValueNumber = condition.value?.number {
                return fieldValueNumber < conditionValueNumber
            } else {
                return false
            }
        case "null=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String] {
                    return selectedArray.isEmpty || selectedArray.allSatisfy { $0.isEmpty }
                }
            }
            if let fieldValueText = fieldValue?.text {
                return fieldValueText.isEmpty
            } else if fieldValue?.number == nil {
                return true
            } else {
                return false
            }
        case "*=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String] {
                    return !(selectedArray.isEmpty || selectedArray.allSatisfy { $0.isEmpty })
                }
            }
            if let fieldValueText = fieldValue?.text {
                return !fieldValueText.isEmpty
            } else if fieldValue?.number == nil{
                return false
            } else {
                return true
            }

        default:
            return false
        }
    }

    private func shoulTakeActionOnThisField(logic: LogicModel) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }

        var conditionsResults: [Bool] = []

        for condition in conditions {
            let isValueMatching = compareValue(fieldValue: condition.fieldValue, condition: condition, fieldType: condition.fieldType)
            conditionsResults.append(isValueMatching)
        }
        if conditionsResults.isEmpty {
            return false
        }
        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else {
            return conditionsResults.contains { $0 }
        }
    }

    func shouldShowLocal(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        guard let field = documentEditor.field(fieldID: fieldID) else { return true }
        if documentEditor.isFieldForceHiddenByView(field: field) {
            return false
        }
        let model = conditionalLogicModel(field: field)
        let lastHiddenState = field.hidden
        guard let model = model, model.itemCount > 1 else {
            return !(lastHiddenState ?? false)
        }
        return shouldShowItem(model: model, lastHiddenState: lastHiddenState)
    }

    func updateSchemaVisibility(collectionFieldID: String, columnID: String, rowID: String, valueElement: ValueElement?) {
        guard let dependencyLogic = collectionDependencyMap[collectionFieldID], let affectedSchemas = dependencyLogic.columnDependencyMap[columnID] else { return }
        
        guard let field = documentEditor.field(fieldID: collectionFieldID) else { return }
                
        for schemaID in affectedSchemas {
            let rowSchemaID = RowSchemaID(rowID: rowID, schemaID: schemaID)
            
            let newhiddenState = shouldShow(
                fullSchema: field.schema,
                schemaID: schemaID,
                valueElement: valueElement
            )
            
            let lastHiddenState = showCollectionSchemaMap[collectionFieldID]?.showSchemaMap[rowSchemaID]
            
            if lastHiddenState != newhiddenState {
                showCollectionSchemaMap[collectionFieldID]?.showSchemaMap[rowSchemaID] = newhiddenState
            }
        }
    }
    
    func updateShowCollectionSchemaMap(collectionFieldID: String, rowID: String, valueElement: ValueElement?) {
        var collectionLogic = showCollectionSchemaMap[collectionFieldID] ?? CollectionSchemaLogic()
        
        guard let field = documentEditor.field(fieldID: collectionFieldID) else { return }
        
        for (childSchemaID, child) in valueElement?.childrens ?? [:] {
            let rowSchemaID = RowSchemaID(rowID: rowID, schemaID: childSchemaID)
            let shouldBeShown = shouldShow(
                fullSchema: field.schema,
                schemaID: childSchemaID,
                valueElement: valueElement
            )
            collectionLogic.showSchemaMap[rowSchemaID] = shouldBeShown
        }
        
        showCollectionSchemaMap[collectionFieldID] = collectionLogic
    }
    
    func shouldRefreshSchema(for collectionFieldID: String, columnID: String) -> Bool {
        return collectionDependencyMap[collectionFieldID]?.columnDependencyMap.keys.contains(columnID) ?? false
    }
}

extension ColumnTypes {
    var toFieldType: FieldTypes {
        FieldTypes(rawValue: self.rawValue) ?? .unknown
    }
}
