//
//  File.swift
//
//
//  Created by Vishnu Dutt on 21/11/24.
//

import Foundation
import JoyfillModel

public class DocumentEditor: ObservableObject {
    public var document: JoyDoc
    private var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }

    @Published var pageFieldModels = [String: PageModel]()
    private var fieldPositionMap = [String: FieldPosition]()
    private var fieldIndexMap = [String: String]()
    private var fieldConditionalDependencyMap = [String: [String]]()
    var showFieldMap = [String: Bool]()
    var events: FormChangeEvent?

    public init(document: JoyDoc, events: FormChangeEvent?) {
        self.document = document
        self.events = events
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }

        document.fieldPositionsForCurrentView.forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
            showFieldMap[fieldID] = self.shouldShowLocal(fieldID: fieldPosition.field!)
        }

        for page in document.pagesForCurrentView {
            guard let pageID = page.id else { return }
            var fieldListModels = [FieldListModel]()

            let fieldPositions = mapWebViewToMobileView(fieldPositions: page.fieldPositions ?? [])
            for fieldPostion in fieldPositions {
                fieldListModels.append(FieldListModel(fieldID: fieldPostion.field!, pageID: pageID, fileID: files[0].id!, refreshID: UUID()))
                let index = fieldListModels.count - 1
                fieldIndexMap[fieldPostion.field!] = fieldIndexMapValue(pageID: pageID, index: index)
            }
            pageFieldModels[pageID] = PageModel(id: pageID, fields: fieldListModels)
        }
    }

    private func fieldIndexMapValue(pageID: String, index: Int) -> String {
        return "\(pageID)|\(index)"
    }

    private func mapWebViewToMobileView(fieldPositions: [FieldPosition]) -> [FieldPosition] {
        let sortedFieldPositions = fieldPositions.sorted { fp1, fp2 in
            guard let y1 = fp1.y, let y2 = fp2.y else { return false }
            return Int(y1) < Int(y2)
        }
        var uniqueFields = Set<String>()
        var resultFieldPositions = [FieldPosition]()
        resultFieldPositions.reserveCapacity(sortedFieldPositions.count)

        for fp in sortedFieldPositions {
            if let field = fp.field, uniqueFields.insert(field).inserted {
                resultFieldPositions.append(fp)
            }
        }
        return resultFieldPositions
    }

    private func pageIDAndIndex(key: String) -> (String, Int) {
        let components = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        let pageID = components.first.map(String.init) ?? ""
        let index = components.last.map { Int(String($0))! }!
        return (pageID, index)
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

    func applyConditionalLogicAndRefreshUI(event: FieldChangeEvent) {
        // refresh current field
        refreshField(fieldId: event.fieldID)

        guard let dependentFields = fieldConditionalDependencyMap[event.fieldID] else { return }
        // Refresh dependent fields if required
        for dependentField in dependentFields {
            let shouldShow = shouldShowLocal(fieldID: dependentField)
            if showFieldMap[dependentField] != shouldShow {
                showFieldMap[dependentField] = shouldShow
                refreshField(fieldId: dependentField)
            }
        }
    }

    public func fieldPosition(fieldID: String?) -> FieldPosition? {
        guard let fieldID = fieldID else { return nil }
        return fieldPositionMap[fieldID]
    }

    public func shouldShow(fieldID: String) -> Bool {
        true
        return showFieldMap[fieldID] ?? true
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

    fileprivate func shouldShowLocal(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        let model = conditionalLogicModel(field: fieldMap[fieldID])
        return shouldShowItem(model: model)
    }

    public func validate() -> Validation {
        var fieldValidations = [FieldValidation]()
        var isValid = true
        let fieldPositionIDs = document.fieldPositionsForCurrentView.map {  $0.field }
        for field in document.fields.filter { fieldPositionIDs.contains($0.id) } {
            if shouldShowLocal(fieldID: field.id) {
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
                fieldConditionalDependencyMap[dependentField.id!] = allDependentFields + [field.id!]
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
    
    func valueElements(fieldID: String) -> [ValueElement]? {
        return field(fieldID: fieldID)?.valueToValueElements
    }
    
    /// Deletes a row with the specified ID from the table field.
    func deleteRow(id: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        guard var elements = field(fieldID: fieldId)?.valueToValueElements, let index = elements.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var element = elements[index]
        element.setDeleted()
        elements[index] = element
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        lastRowOrder.removeAll(where: { $0 == id })
        fieldMap[fieldId]?.rowOrder = lastRowOrder
    }
    
    func onChangeForDelete(tableDataModel: TableDataModel, selectedRows: [String]) {
        let changeEvent = FieldChangeEvent(fieldID: tableDataModel.fieldId!, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: fieldMap[tableDataModel.fieldId!]?.value)
        deleteRowOnChange(event: changeEvent, targetRowIndexes: selectedRows.map { TargetRowModel.init(id: $0, index: 0)})
        refreshField(fieldId: tableDataModel.fieldId!)
    }

    /// Deletes a row with the specified ID from the table field.
    func duplicateRow(selectedRows: [String], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []

        selectedRows.forEach { rowID in
            var element = elements.first(where: { $0.id == rowID })!
            let newRowID = generateObjectId()
            element.id = newRowID
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        
        let changeEvent = FieldChangeEvent(fieldID: tableDataModel.fieldId!, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }


    func moveUP(rowID: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard lastRowIndex != 0 else {
            return
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex-1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex-1)]
        let changeEvent = FieldChangeEvent(fieldID: tableDataModel.fieldId!, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: tableDataModel.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    func moveDown(rowID: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []
        let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!

        guard (lastRowOrder.count - 1) != lastRowIndex else {
            return
        }
        lastRowOrder.swapAt(lastRowIndex, lastRowIndex+1)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        let targetRows = [TargetRowModel(id: rowID, index: lastRowIndex+1)]
        let changeEvent = FieldChangeEvent(fieldID: tableDataModel.fieldId!, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: tableDataModel.value)
        moveRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    /// Adds a new row with the specified ID to the table field.
    func insertLastRow(id: String, tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []
        
        elements.append(ValueElement(id: id))
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder?.append(id)
        
        let changeEvent = FieldChangeEvent(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
        refreshField(fieldId: fieldId)
    }

    /// Adds a new row with the specified ID to the table field.
    func addRow(selectedRows: [String], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        guard var elements = field(fieldID: fieldId)?.valueToValueElements else {
            return
        }
        var targetRows = [TargetRowModel]()
        var lastRowOrder = fieldMap[fieldId]?.rowOrder ?? []

        selectedRows.forEach { rowID in
            let newRowID = generateObjectId()
            var element = ValueElement(id: newRowID)
            elements.append(element)
            let lastRowIndex = lastRowOrder.firstIndex(of: rowID)!
            lastRowOrder.insert(newRowID, at: lastRowIndex+1)
            targetRows.append(TargetRowModel(id: newRowID, index: lastRowIndex+1))
        }

        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder = lastRowOrder
        
        let changeEvent = FieldChangeEvent(fieldID: tableDataModel.fieldId!, pageID: tableDataModel.pageId , fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: targetRows)
        refreshField(fieldId: fieldId)
    }

    /// Adds a new row with the specified ID to the table field.
    func addRowWithFilter(id: String, filterModels: [FilterModel], tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        var elements = field(fieldID: fieldId)?.valueToValueElements ?? []

        var newRow = ValueElement(id: id)
        elements.append(newRow)
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
        fieldMap[fieldId]?.rowOrder?.append(id)
        for filterModel in filterModels {
            cellDidChange(rowId: id, colIndex: filterModel.colIndex, editedCellId: filterModel.colID, value: filterModel.filterText, fieldId: fieldId)
        }
        
        let changeEvent = FieldChangeEvent(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: ValueUnion.valueElementArray(elements))
        addRowOnChange(event: changeEvent, targetRowIndexes: [TargetRowModel(id: id, index: (elements.count ?? 1) - 1)])
        refreshField(fieldId: fieldId)
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
        fieldMap[fieldId]?.value = ValueUnion.valueElementArray(elements)
    }
    
    func refreshField(fieldId: String) {
        let pageIDIndexValue = fieldIndexMap[fieldId]!
        let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
        pageFieldModels[pageID]!.fields[index].refreshID = UUID()
    }
    
    func sendEventsIfNeeded(tableDataModel: TableDataModel) {
        let fieldId = tableDataModel.fieldId!
        let changeEvent = FieldChangeEvent(fieldID: fieldId, pageID: tableDataModel.pageId, fileID: tableDataModel.fileId, updateValue: fieldMap[fieldId]?.value)
        let currentField = field(fieldID: fieldId)!
        handleFieldsOnChange(event: changeEvent, currentField: currentField)
        refreshField(fieldId: tableDataModel.fieldId!)
    }
    
    func addRowOnChange(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowCreate",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: addRowChanges(fieldData: field, targetRow: targetRow),
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    func deleteRowOnChange(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowDelete",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: ["rowId": targetRow.id],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }

        events?.onChange(changes: changes, document: document)
    }

    func moveRowOnChange(event: FieldChangeEvent, targetRowIndexes: [TargetRowModel]) {
        var changes = [Change]()
        let field = field(fieldID: event.fieldID)!
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        for targetRow in targetRowIndexes {
            var change = Change(v: 1,
                                sdk: "swift",
                                target: "field.value.rowMove",
                                _id: documentID!,
                                identifier: documentIdentifier,
                                fileId: event.fileID!,
                                pageId: event.pageID!,
                                fieldId: event.fieldID,
                                fieldIdentifier: field.identifier!,
                                fieldPositionId: fieldPosition.id!,
                                change: [
                                    "rowId": targetRow.id,
                                    "targetRowIndex": targetRow.index,
                                ],
                                createdOn: Date().timeIntervalSince1970)
            changes.append(change)
        }
        events?.onChange(changes: changes, document: document)
    }

    func onChange(event: FieldChangeEvent) {
        var currentField = field(fieldID: event.fieldID)!
        guard currentField.value != event.updateValue, event.chartData != nil else { return }
        guard !((currentField.value == nil || currentField.value!.nullOrEmpty) && (event.updateValue == nil || event.updateValue!.nullOrEmpty)) else { return }
        updateValue(event: event)
        currentField = field(fieldID: event.fieldID)!
        handleFieldsOnChange(event: event, currentField: currentField)
    }
    
    func handleFieldsOnChange(event: FieldChangeEvent, currentField: JoyDocField) {
        let fieldPosition = fieldPosition(fieldID: event.fieldID)!
        var change = Change(v: 1,
                            sdk: "swift",
                            target: "field.update",
                            _id: documentID!,
                            identifier: documentIdentifier,
                            fileId: event.fileID!,
                            pageId: event.pageID!,
                            fieldId: event.fieldID,
                            fieldIdentifier: currentField.identifier!,
                            fieldPositionId: fieldPosition.id!,
                            change: changes(fieldData: currentField),
                            createdOn: Date().timeIntervalSince1970)
        events?.onChange(changes: [change], document: document)
    }

    private func changes(fieldData: JoyDocField) -> [String: Any] {
        switch fieldData.type {
        case "chart":
            return chartChanges(fieldData: fieldData)
        default:
            return ["value": fieldData.value!.dictionary]
        }
    }

    private func chartChanges(fieldData: JoyDocField) -> [String: Any] {
        var valueDict = ["value": fieldData.value!.dictionary]
        valueDict["yTitle"] = fieldData.yTitle
        valueDict["yMin"] = fieldData.yMin
        valueDict["yMax"] = fieldData.yMax
        valueDict["xTitle"] = fieldData.xTitle
        valueDict["xMin"] = fieldData.xMin
        valueDict["xMax"] = fieldData.xMax
        return valueDict
    }

    private func addRowChanges(fieldData: JoyDocField, targetRow: TargetRowModel) -> [String: Any] {
        let lastValueElement = fieldData.value!.valueElements?.first(where: { valueElement in
            valueElement.id == targetRow.id
        })
        var valueDict: [String: Any] = ["row": lastValueElement?.anyDictionary]
        valueDict["targetRowIndex"] = targetRow.index
        return valueDict
    }

    func onFocus(event: FieldEventInternal) {
        // TODO:
//        events?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEventInternal) {
        // TODO:
//        events?.onBlur(event: event)
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        events?.onUpload(event: event)
    }
    
    private func updateValue(event: FieldChangeEvent) {
        if var field = field(fieldID: event.fieldID) {
            field.value = event.updateValue
            if let chartData = event.chartData {
                field.xMin = chartData.xMin
                field.yMin = chartData.yMin
                field.xMax = chartData.xMax
                field.yMax = chartData.yMax
                field.xTitle = chartData.xTitle
                field.yTitle = chartData.yTitle
            }
            updatefield(field: field)
            document.fields = allFields
            applyConditionalLogicAndRefreshUI(event: event)
        }
    }
}
