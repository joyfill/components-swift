//
//  File.swift
//
//
//  Created by Vishnu Dutt on 21/11/24.
//

import Foundation
import JoyfillModel

@available(iOS 13.0, *)
public class DocumentEditor: ObservableObject {
    public var document: JoyDoc
    private var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }

    @Published var pageFieldModels = [String: PageModel]()
    private var fieldPositionMap = [String: FieldPosition]()
    private var fieldConditionalDependencyMap = [String: [String]]()
    var hiddenFieldMap = [String: Bool]()

    public init(document: JoyDoc) {
        self.document = document
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }

        document.fieldPositionsForCurrentView.forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
            hiddenFieldMap[fieldID] = self.shouldShow(pageID: fieldPosition.field)
        }

        for page in document.pagesForCurrentView {
            guard let pageID = page.id else { return }
            var fieldListModels = [FieldListModel]()

            for fieldPostion in page.fieldPositions ?? [] {
                fieldListModels.append(FieldListModel(fieldID: fieldPostion.field!, refreshID: UUID()))
            }
            pageFieldModels[pageID] = PageModel(id: pageID, fields: fieldListModels)
        }
    }

    public var documentID: String? {
        document.id
    }

    public var documentIdentifier: String? {
        document.identifier
    }

    public var files: [File] {
        document.files
    }

    public var pagesForCurrentView: [Page] {
        document.pagesForCurrentView
    }

    public func updatefield(field: JoyDocField?) {
        guard let fieldID = field?.id else { return }
        fieldMap[fieldID] = field
    }

    public func field(fieldID: String?) -> JoyDocField? {
        guard let fieldID = fieldID else { return nil }
        return fieldMap[fieldID]
    }

    public var allFields: [JoyDocField] {
        return fieldMap.map { $1 }
    }

    public func applyConditionalLogicAndRefreshUI(field: JoyDocField) {
        guard let dependentFields = fieldConditionalDependencyMap[field.id!] else { return }
        for dependentField in dependentFields {
            let shouldShow = shouldShow(fieldID: dependentField)
            if hiddenFieldMap[dependentField] != shouldShow {
//                fieldModels[dependentField].refreshID = UUID()
            }
        }

//        let fieldID = fieldModels[0].fieldID
//        fieldModels[0] = FieldListModel(fieldID: fieldID, refreshID: UUID())
    }

    public func fieldPosition(fieldID: String?) -> FieldPosition? {
        guard let fieldID = fieldID else { return nil }
        return fieldPositionMap[fieldID]
    }

    public func shouldShow(pageID: String?) -> Bool {
        guard let pageID = pageID else { return true }
        guard let page = document.pagesForCurrentView.first(where: { $0.id == pageID }) else { return true }
        return shouldShow(page: page)
    }

    public func shouldShow(page: Page?) -> Bool {
        guard let page = page else { return true }
        let model = conditionalLogicModel(page: page)
        return shouldShowItem(model: model)
    }

    public func shouldShow(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        let model = conditionalLogicModel(field: fieldMap[fieldID])
        return shouldShowItem(model: model)
    }

    public func shouldShow(field: JoyDocField?) -> Bool {
        guard let field = field else { return true }
        let model = conditionalLogicModel(field: field)
        return shouldShowItem(model: model)
    }

    public func validate() -> Validation {
        var fieldValidations = [FieldValidation]()
        var isValid = true
        let fieldPositionIDs = document.fieldPositionsForCurrentView.map {  $0.field }
        for field in document.fields.filter { fieldPositionIDs.contains($0.id) } {
            if shouldShow(pageID: field.id) {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }

            guard let required = field.required, required else {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }

            if let value = field.value, !value.isEmpty {
                fieldValidations.append(FieldValidation(field: field, status: .valid))
                continue
            }
            isValid = false
            fieldValidations.append(FieldValidation(field: field, status: .invalid))
        }

        return Validation(status: isValid ? .valid: .invalid, fieldValidations: fieldValidations)
    }

    public var firstPage: Page? {
        let pages = document.pagesForCurrentView
        guard pages.count > 1 else {
            return pages.first
        }
        return pages.first(where: shouldShow)
    }

    public var firstPageId: String? {
        return self.firstPage?.id
    }

    public func firstValidPageFor(currentPageID: String) -> Page? {
        return document.pagesForCurrentView.first { currentPage in
            currentPage.id == currentPageID && shouldShow(page: currentPage)
        } ?? firstPage
    }

    public func firstPageFor(currentPageID: String) -> Page? {
        return document.pagesForCurrentView.first { currentPage in
            currentPage.id == currentPageID
        }
    }

    public func conditionalLogicModel(page: Page?) -> ConditionalLogicModel? {
        guard let page = page else { return nil }
        guard let logic = page.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition ->  ConditionModel? in
            guard let fieldID = condition.field else { return nil }
            guard let field = fieldMap[condition.field!] else { return nil }
            guard let conditionFieldID = condition.field else { return nil }
            let conditionField = fieldMap[conditionFieldID]!
            return ConditionModel(fieldValue: conditionField.value, fieldType: FieldTypes(conditionField.type), condition: condition.condition, value: condition.value)
        }
        let logicModel = LogicModel(id: logic.id, action: logic.action, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: page.hidden, itemCount: document.pagesForCurrentView.count)
        return conditionModel
    }

    public func conditionalLogicModel(field: JoyDocField?) -> ConditionalLogicModel? {
        guard let field = field else { return nil }
        guard let logic = field.logic else { return nil }
        guard let conditions = logic.conditions else { return nil }

        let conditionModels = conditions.compactMap { condition -> ConditionModel?  in
            guard let fieldID = condition.field else { return nil }
            let dependentField = fieldMap[fieldID]!
            var allDependentFields = fieldConditionalDependencyMap[field.id!] ?? []
            if !allDependentFields.contains(dependentField.id!) {
                fieldConditionalDependencyMap[field.id!] = allDependentFields + [dependentField.id!]
            }
            return ConditionModel(fieldValue: dependentField.value, fieldType: FieldTypes(dependentField.type), condition: condition.condition, value: condition.value)
        }
        
        let logicModel = LogicModel(id: field.logic?.id, action: logic.action, conditions: conditionModels)
        let conditionModel = ConditionalLogicModel(logic: logicModel, isItemHidden: field.hidden, itemCount: fieldMap.count)
        return conditionModel
    }

    func conditionalLogicModels() -> [ConditionalLogicModel] {
        let fields = document.fields
        return fields.flatMap(conditionalLogicModel)
    }

    public func shouldShowItem(model: ConditionalLogicModel?) -> Bool {
        guard let model = model else {
            return true
        }
        guard model.itemCount > 1 else {
            return true
        }
        guard let logic = model.logic else { return !(model.isItemHidden ?? false) }

        if let hidden = model.isItemHidden {
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

    public func compareValue(fieldValue: ValueUnion?, condition: ConditionModel, fieldType: FieldTypes) -> Bool {
        switch condition.condition {
        case "=":
            if fieldType == .multiSelect || fieldType == .dropdown {
                if let valueUnion = fieldValue as? ValueUnion,
                   let selectedArray = valueUnion.stringArray as? [String],
                   let conditionText = condition.value?.text {
                    return selectedArray.contains { $0 == conditionText }
                }
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
            return fieldValue != condition.value
        case "?=":
            guard let fieldValue = fieldValue else {
                return false
            }
            if let fieldValueText = fieldValue.text, let conditionValueText = condition.value?.text {
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

    func shoulTakeActionOnThisField(logic: LogicModel) -> Bool {
        guard let conditions = logic.conditions else {
            return false
        }

        var conditionsResults: [Bool] = []

        for condition in conditions {
            let isValueMatching = compareValue(fieldValue: condition.fieldValue, condition: condition, fieldType: condition.fieldType)
            conditionsResults.append(isValueMatching)
        }

        if logic.eval == "and" {
            return conditionsResults.allSatisfy { $0 }
        } else {
            return conditionsResults.contains { $0 }
        }
    }
    
    func fieldIndex(fieldID: String) -> Int? {
        return document.fields.firstIndex(where: { $0.id == fieldID })
    }
    
    func valueElements(fieldID: String) -> [ValueElement]? {
        return field(fieldID: fieldID)?.valueToValueElements
    }
    
    /// Deletes a row with the specified ID from the table field.
    func deleteRow(id: String, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var element = elements[index]
        element.setDeleted()
        elements[index] = element
        let fieldIndex = fieldIndex(fieldID: fieldId)
        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
        var lastRowOrder = document.fields[fieldIndex!].rowOrder ?? []
        lastRowOrder.removeAll(where: { $0 == id })
        document.fields[fieldIndex!].rowOrder = lastRowOrder
    }

    /// Deletes a row with the specified ID from the table field.
    func duplicateRow(selectedRows: [String], fieldId: String) -> [TargetRowModel] {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return []
        }
        var targetRows = [TargetRowModel]()
        let fieldIndex = fieldIndex(fieldID: fieldId)
        var lastRowOrder = document.fields[fieldIndex!].rowOrder ?? []

        selectedRows.forEach { rowID in
            var element = elements.first(where: { $0.id == rowID })!
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
        document.fields[fieldIndex!].rowOrder = lastRowOrder
        return targetRows
    }


    func moveUP(rowID: String, fieldId: String)  -> [TargetRowModel] {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return []
        }
        let fieldIndex = fieldIndex(fieldID: fieldId)
        var lastRowOrder = document.fields[fieldIndex!].rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard lastRowIndex != 0 else {
            return []
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex-1)
        document.fields[fieldIndex!].rowOrder = lastRowOrder
        return [TargetRowModel(id: rowID, index: lastRowIndex-1)]
    }

    func moveDown(rowID: String, fieldId: String)  -> [TargetRowModel] {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return []
        }
        let fieldIndex = fieldIndex(fieldID: fieldId)
        var lastRowOrder = document.fields[fieldIndex!].rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard (lastRowOrder.count - 1) != lastRowIndex else {
            return []
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex+1)
        document.fields[fieldIndex!].rowOrder = lastRowOrder
        return [TargetRowModel(id: rowID, index: lastRowIndex+1)]
    }

    /// Adds a new row with the specified ID to the table field.
    func insertLastRow(id: String, fieldId: String) {
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []
        
        let fieldIndex = fieldIndex(fieldID: fieldId)
        elements.append(ValueElement(id: id))
        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
        document.fields[fieldIndex!].rowOrder?.append(id)
    }

    /// Adds a new row with the specified ID to the table field.
    func addRow(selectedRows: [String], fieldId: String)  -> [TargetRowModel] {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return []
        }
        let fieldIndex = fieldIndex(fieldID: fieldId)
        var targetRows = [TargetRowModel]()
        var lastRowOrder = document.fields[fieldIndex!].rowOrder ?? []

        selectedRows.forEach { rowID in
            let newRowID = generateObjectId()
            var element = ValueElement(id: newRowID)
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
        document.fields[fieldIndex!].rowOrder = lastRowOrder
        return targetRows
    }

    /// Adds a new row with the specified ID to the table field.
    func addRowWithFilter(id: String, filterModels: [FilterModel], fieldId: String) {
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []

        let fieldIndex = fieldIndex(fieldID: fieldId)
        var newRow = ValueElement(id: id)
        elements.append(newRow)
        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
        document.fields[fieldIndex!].rowOrder?.append(id)
        for filterModel in filterModels {
            cellDidChange(rowId: id, colIndex: filterModel.colIndex, editedCellId: filterModel.colID, value: filterModel.filterText, fieldId: fieldId)
        }
    }

    /// A function that updates the cell value when a change is detected.
    ///
    /// This function is called when a cell's value is edited. It updates the corresponding cell in the `elements` array based on the `rowId` and `colIndex` provided. The type of the `editedCell` determines how the cell is updated.
    ///
    /// - Parameters:
    ///   - rowId: The ID of the row containing the cell to be updated.
    ///   - colIndex: The index of the column containing the cell to be updated.
    ///   - editedCell: The cell that has been edited.
    ///
    /// - Note: The `editedCell` parameter is of type `FieldTableColumn`, which includes properties such as `type`, `id`, `title`, `defaultDropdownSelectedId`, and `images`.
     func cellDidChange(rowId: String, colIndex: Int, editedCell: FieldTableColumn, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }
        
        switch editedCell.type {
        case "text":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.title ?? ""), fieldId: fieldId)
        case "dropdown":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.string(editedCell.defaultDropdownSelectedId ?? ""), fieldId: fieldId)
        case "image":
            changeCell(elements: elements, index: index, editedCellId: editedCell.id, newCell: ValueUnion.valueElementArray(editedCell.images ?? []), fieldId: fieldId)
        default:
            return
        }
    }

    func cellDidChange(rowId: String, colIndex: Int, editedCellId: String, value: String, fieldId: String) {
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == rowId }) else {
            return
        }

        changeCell(elements: elements, index: index, editedCellId: editedCellId, newCell: ValueUnion.string(value), fieldId: fieldId)
    }

    /// A private function that updates the cell value in the elements array.
    ///
    /// This function is called when a cell's value is edited. It updates the corresponding cell in the `elements` array based on the `index` and `editedCellId` provided. The new cell value is determined by the `newCell` parameter.
    ///
    /// - Parameters:
    ///   - elements: The array of `ValueElement` objects containing the cells to be updated.
    ///   - index: The index of the element in the array to be updated.
    ///   - editedCellId: The ID of the cell to be updated.
    ///   - newCell: The new value for the cell.
    ///
    /// - Note: After updating the cell, the function updates the `value` property of the instance with the new `elements` array.
    func changeCell(elements: [ValueElement], index: Int, editedCellId: String?, newCell: ValueUnion, fieldId: String) {
        var elements = elements
        if var cells = elements[index].cells {
            cells[editedCellId ?? ""] = newCell
            elements[index].cells = cells
        } else {
            elements[index].cells = [editedCellId ?? "" : newCell]
        }
        let fieldIndex = fieldIndex(fieldID: fieldId)
        document.fields[fieldIndex!].value = ValueUnion.valueElementArray(elements)
    }
}
