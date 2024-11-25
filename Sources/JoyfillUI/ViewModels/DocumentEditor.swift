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
    private var fieldIndexMap = [String: String]()
    private var fieldConditionalDependencyMap = [String: [String]]()
    var showFieldMap = [String: Bool]()

    public init(document: JoyDoc) {
        self.document = document
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }

        document.fieldPositionsForCurrentView.forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
            showFieldMap[fieldID] = self.shouldShowLocal(fieldID: fieldPosition.field!)
        }

        var pages: [Page]
        var mobileView = false
        if let views = document.files[0].views, let view = views.first {
            pages = view.pages ?? []
            mobileView = true
        } else {
            pages = document.files[0].pages ?? []
        }

        for page in pages {
            guard let pageID = page.id else { return }
            var fieldListModels = [FieldListModel]()
            let fieldPositions = mobileView ? page.fieldPositions ?? []: mapWebViewToMobileView(fieldPositions: page.fieldPositions ?? [])
            for fieldPostion in fieldPositions {
                fieldListModels.append(FieldListModel(fieldID: fieldPostion.field!, refreshID: UUID()))
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
        let sortedFieldPositions =
        fieldPositions
            .sorted { fp1, fp2 in
                if let y2 = fp2.y, let y1 = fp1.y {
                    return Int(y1) < Int(y2)
                }
                return true
            }

        var resultFieldPositions =  [FieldPosition]()
        for fp in sortedFieldPositions {
            if !resultFieldPositions.contains(where: { $0.field == fp.field }) {
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
        let pageIDIndexValue = fieldIndexMap[event.fieldID]!
        let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
        pageFieldModels[pageID]!.fields[index].refreshID = UUID()

        guard let dependentFields = fieldConditionalDependencyMap[event.fieldID] else { return }
        // Refresh dependent fields if required
        for dependentField in dependentFields {
            let shouldShow = shouldShowLocal(fieldID: dependentField)
            if showFieldMap[dependentField] != shouldShow {
                showFieldMap[dependentField] = shouldShow
                let pageIDIndexValue = fieldIndexMap[dependentField]!
                let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
                pageFieldModels[pageID]!.fields[index].refreshID = UUID()
            }
        }
    }

    public func fieldPosition(fieldID: String?) -> FieldPosition? {
        guard let fieldID = fieldID else { return nil }
        return fieldPositionMap[fieldID]
    }

    public func shouldShow(fieldID: String) -> Bool {
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
}
