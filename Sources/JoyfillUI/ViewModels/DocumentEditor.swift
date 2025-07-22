//
//  File.swift
//
//
//  Created by Vishnu Dutt on 21/11/24.
//

import Foundation
import JoyfillModel
import JSONSchema

private enum ChangeTargetType: String {
    case fieldUpdate = "field.update"

    case fieldValueRowCreate = "field.value.rowCreate"
    case fieldValueRowUpdate = "field.value.rowUpdate"
    case fieldValueRowDelete = "field.value.rowDelete"
    case fieldValueRowMove = "field.value.rowMove"
    
    case unknown
}

// Weak wrapper to hold multiple delegates without causing retain cycles
public class WeakDocumentEditorDelegate {
    weak var value: DocumentEditorDelegate?
    init(_ value: DocumentEditorDelegate) { self.value = value }
}

public protocol DocumentEditorDelegate: AnyObject {
    func applyRowEditChanges(change: Change)
    func insertRow(for change: Change)
    func deleteRow(for change: Change)
    func moveRow(for change: Change)
}

public class DocumentEditor: ObservableObject {
    private(set) public var document: JoyDoc
    public var schemaError: SchemaValidationError?
    @Published public var currentPageID: String
    @Published var currentPageOrder: [String] = []

    public var mode: Mode = .fill
    public var isPageDuplicateEnabled: Bool = true
    public var showPageNavigationView: Bool = true
    public var delegateMap: [String: WeakDocumentEditorDelegate] = [:]
    
    var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }
    
    @Published var pageFieldModels = [String: PageModel]()
    private var fieldPositionMap = [String: FieldPosition]()
    private var fieldIndexMap = [String: String]()
    public var events: FormChangeEvent?
    
    private var validationHandler: ValidationHandler!
    var conditionalLogicHandler: ConditionalLogicHandler!
    private var JoyfillDocContext: JoyfillDocContext!

    public init(document: JoyDoc, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String? = nil, navigation: Bool = true, isPageDuplicateEnabled: Bool = false, shouldValidate: Bool = true) {
        // Perform schema validation first
        let schemaManager = JoyfillSchemaManager()
        
        // Check for schema validation errors
        if let schemaError = schemaManager.validateSchema(document: document), shouldValidate {
            // Schema validation failed - store error and return early
            self.schemaError = schemaError
            // Set empty document
            self.document = JoyDoc()
            self.mode = mode
            self.isPageDuplicateEnabled = isPageDuplicateEnabled
            self.showPageNavigationView = navigation
            self.currentPageID = ""
            self.events = events
            
            // Trigger onError callback if events handler is available
            events?.onError(error: .schemaValidationError(error: schemaError))
            return
        }
        
        // Schema validation passed - proceed with normal initialization
        self.document = document
        self.mode = mode
        self.isPageDuplicateEnabled = isPageDuplicateEnabled
        self.showPageNavigationView = navigation
        self.currentPageID = ""
        self.events = events
        updateFieldMap()
        updateFieldPositionMap()

        guard let firstFile = files.first, let fileID = firstFile.id else {
            return
        }

        for page in document.pagesForCurrentView {
            guard let pageID = page.id else { return }
            updatePageFieldModels(page, pageID, fileID)
        }
        self.validationHandler = ValidationHandler(documentEditor: self)
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        self.currentPageID = document.firstValidPageID(for: pageID, conditionalLogicHandler: conditionalLogicHandler)
        self.JoyfillDocContext = Joyfill.JoyfillDocContext(docProvider: self)
        self.currentPageOrder = document.pageOrderForCurrentView ?? []
    }
    
    public func registerDelegate(_ delegate: DocumentEditorDelegate, for fieldID: String) {
        delegateMap[fieldID] = WeakDocumentEditorDelegate(delegate)
    }
    
    public func updateFieldMap() {
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }
    }
    
    public func updateFieldPositionMap() {
        mapWebViewToMobileViewIfNeeded(fieldPositions: document.fieldPositionsForCurrentView, isMobileViewActive: isMobileViewActive).forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
        }
    }
    
    public func validate() -> Validation {
        return validationHandler.validate()
    }
    
    public func shouldShow(fieldID: String?) -> Bool {
        return conditionalLogicHandler.shouldShow(fieldID: fieldID)
    }
    
    public func shouldShow(pageID: String?) -> Bool {
        return conditionalLogicHandler.shouldShow(pageID: pageID)
    }
    
    public func shouldShow(page: Page?) -> Bool {
        return conditionalLogicHandler.shouldShow(page: page)
    }
    
    public func shouldShowSchema(for collectionFieldID: String, rowSchemaID: RowSchemaID) -> Bool {
        return conditionalLogicHandler.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
    }
    
    public func change(changes: [Change]) {
        // TODO:
        // 1. Update JSON
        // 2. Update UI
        for change in changes {
            guard let targetValue = change.target,
                  let target = ChangeTargetType(rawValue: targetValue) else {
                logChangeError(for: change)
                continue
            }
            
            switch target {
            case .fieldUpdate:
                handleFieldUpdate(for: change)
                
            case .fieldValueRowCreate:
                handleFieldValueRowCreate(for: change)
                
            case .fieldValueRowUpdate:
                handleFieldValueRowUpdate(for: change)
                
            case .fieldValueRowDelete:
                handleFieldValueRowDelete(for: change)
                
            case .fieldValueRowMove:
                handleFieldValueRowMove(for: change)
                
            case .unknown:
                break
            }
        }
    }
    
    private func handleFieldValueRowUpdate(for change: Change) {
        guard let fieldID = change.fieldId,
              let field = fieldMap[fieldID]
        else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case .table, .collection:
            DispatchQueue.main.async(execute: {
                self.delegateMap[fieldID]?.value?.applyRowEditChanges(change: change)
            })
            
        default:
            guard var elements = field.valueToValueElements else { return }
            guard let rowID = change.change?["rowId"] as? String else { return }
            guard let rowIndex = elements.firstIndex(where: { $0.id == rowID }) else { return }
            guard let rowDict = change.change?["row"] as? [String: Any],
                  let cellsDict = rowDict["cells"] as? [String: Any] else {
                return
            }
            var updatedElement = elements[rowIndex]
            for (key, value) in cellsDict {
                updatedElement.cells?[key] = ValueUnion(value: value)
            }
            elements[rowIndex] = updatedElement
            let value = ValueUnion.valueElementArray(elements)
            updateValue(for: fieldID, value: value, shouldCallOnChange: false)
        }
    }
    
    private func handleFieldValueRowCreate(for change: Change) {
        guard let fieldID = change.fieldId,
              let field = fieldMap[fieldID]
        else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case  .table, .collection:
            delegateMap[fieldID]?.value?.insertRow(for: change)
        default:
            //TODO: Add impl
            break
        }
    }

    private func handleFieldValueRowDelete(for change: Change) {
        guard let fieldID = change.fieldId,
              let field = fieldMap[fieldID]
        else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case .table, .collection:
            delegateMap[fieldID]?.value?.deleteRow(for: change)
        default:
            //TODO: Add impl
            break
        }
    }
    
    private func handleFieldValueRowMove(for change: Change) {
        guard let fieldID = change.fieldId,
              let field = fieldMap[fieldID]
        else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case .table, .collection:
            delegateMap[fieldID]?.value?.moveRow(for: change)
        default:
            //TODO: Add impl
            break
        }
    }
    
    private func handleFieldUpdate(for change: Change) {
        //TODO: Remove fieldType != .collection if we are removing back button update json functionality
        guard let fieldID = change.fieldId,
              let fieldType = fieldMap[fieldID]?.fieldType else {
            logChangeError(for: change)
            return
        }
        guard let value = change.change?["value"] as? Any,
              let valueUnion = ValueUnion(value: value)
        else {
            logChangeError(for: change)
            return
        }
        updateValue(for: fieldID, value: valueUnion, shouldCallOnChange: false)
    }
    
    private func logChangeError(for change: Change) {
        guard let targetValue = change.target else {
            return logEventForNilObject(message: "Change target not found")
        }
        
        guard let changeId = change.id else {
            return logEventForNilObject(message: "Change id not found")
        }
        
        guard let fieldId = change.fieldId else {
            return logEventForNilObject(message: "fieldID not found for change: \(changeId)")
        }
        
        let target = ChangeTargetType(rawValue: targetValue) ?? .unknown
        
        switch target {
        case .fieldUpdate:
            logEventForNilObject(change.change?["value"], message: "value not found for change: \(changeId)")
        case .fieldValueRowCreate:
            break
        case .fieldValueRowUpdate:
            logEventForNilObject(fieldMap[fieldId], message: "field not found for change: \(changeId)")
        case .fieldValueRowDelete:
            break
        case .fieldValueRowMove:
            break
        case .unknown:
            break
        }
    }
    
    private func logEventForNilObject(_ object: Any? = nil, message: String) {
        if object == nil {
            return Log(message)
        }
    }
}

fileprivate extension JoyDoc {
    func firstValidPageID(for pageID: String?, conditionalLogicHandler: ConditionalLogicHandler) -> String {
        guard let id = pageID else {
            return firstValidPageID(conditionalLogicHandler: conditionalLogicHandler) ?? ""
        }
        
        if id.isEmpty {
            return firstValidPageID(conditionalLogicHandler: conditionalLogicHandler) ?? ""
        }
        
        guard let pageOrder = files.first?.pageOrder else {
            return firstValidPageID(conditionalLogicHandler: conditionalLogicHandler) ?? ""
        }
        
        if !pageOrder.contains(id) {
            return firstValidPageID(conditionalLogicHandler: conditionalLogicHandler) ?? ""
        }
        
        if !conditionalLogicHandler.shouldShow(pageID: id) {
            return firstValidPageID(conditionalLogicHandler: conditionalLogicHandler) ?? ""
        }
        return id
    }
    
    func firstValidPageID(conditionalLogicHandler: ConditionalLogicHandler) -> String? {
        for page in pagesForCurrentView {
            if conditionalLogicHandler.shouldShow(page: page) {
                return page.id
            }
        }
        return pagesForCurrentView.first?.id
    }
}

extension DocumentEditor {
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
    
    public var allFieldPositions: [FieldPosition] {
        return fieldPositionMap.map { $1 }
    }
    
    public var fieldsCount: Int {
        return fieldMap.count
    }
    
    public func fieldPosition(fieldID: String?) -> FieldPosition? {
        guard let fieldID = fieldID else { return nil }
        return fieldPositionMap[fieldID]
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
    
    public var isMobileViewActive: Bool {
        return files.first?.views?.contains(where: { $0.type == "mobile" }) ?? false
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
}

extension DocumentEditor {
    func updateSchemaVisibilityOnCellChange(collectionFieldID: String, columnID: String, rowID: String) {
        conditionalLogicHandler.updateSchemaVisibility(collectionFieldID: collectionFieldID, columnID: columnID, rowID: rowID)
    }
    
    func updateSchemaVisibilityOnNewRow(collectionFieldID: String, rowID: String) {
        conditionalLogicHandler.updateShowCollectionSchemaMap(collectionFieldID: collectionFieldID, rowID: rowID)
    }
    
    func shouldRefreshSchema(for collectionFieldID: String, columnID: String) -> Bool {
        return conditionalLogicHandler.shouldRefreshSchema(for: collectionFieldID, columnID: columnID)
    }
    
    public func updateField(event: FieldChangeData, fieldIdentifier: FieldIdentifier) {
        if var field = field(fieldID: event.fieldIdentifier.fieldID) {
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
            refreshField(fieldId: event.fieldIdentifier.fieldID)
            refreshDependent(for: event.fieldIdentifier.fieldID)
            if let identifier = field.id {
                self.JoyfillDocContext.updateDependentFormulas(forFieldIdentifier: identifier)
            }
        }
    }
    
    func getValueElementByRowID(_ rowID: String, from valueElements: [ValueElement]) -> ValueElement? {
        //Target valueElement which used by condtional logic
        for element in valueElements {
            if element.id == rowID {
                return element
            } else if let childrens = element.childrens {
                for children in childrens.values {
                    if let found = getValueElementByRowID(rowID, from: children.valueToValueElements ?? []) {
                        return found
                    }
                }
            }
        }
        return nil
    }
    
    private func fieldIndexMapValue(pageID: String, index: Int) -> String {
        return "\(pageID)|\(index)"
    }
    
    public func mapWebViewToMobileViewIfNeeded(fieldPositions: [FieldPosition], isMobileViewActive: Bool) -> [FieldPosition] {
        guard !isMobileViewActive else {
            return fieldPositions
        }
        let sortedFieldPositions = fieldPositions.sorted { fp1, fp2 in
            guard let y1 = fp1.y, let y2 = fp2.y, let x1 = fp1.x, let x2 = fp2.x else {
                return false
            }
            if Int(y1) == Int(y2) {
                return Int(x1) < Int(x2)
            } else {
                return Int(y1) < Int(y2)
            }
        }
        var uniqueFields = Set<String>()
        var resultFieldPositions = [FieldPosition]()
        resultFieldPositions.reserveCapacity(sortedFieldPositions.count)
        
        for fp in sortedFieldPositions {
            if let field = fp.field, uniqueFields.insert(field).inserted {
                var modifiableFP = fp
                modifiableFP.titleDisplay = "inline"
                resultFieldPositions.append(modifiableFP)
            }
        }
        return resultFieldPositions
    }
    
    private func pageIDAndIndex(key: String) -> (String, Int)? {
        let components = key.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
        guard let pageID = components.first.map(String.init),
              let lastComponent = components.last.map(String.init),
              let index = Int(lastComponent) else {
            return nil
        }
        return (pageID, index)
    }
    
    func refreshField(fieldId: String) {
        guard let pageIDIndexValue = fieldIndexMap[fieldId] else {
            Log("Could not find pageIDIndexValue for field \(fieldId)", type: .error)
            return
        }
        guard let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue) else {
            Log("Could not find pageID and index for field \(fieldId)")
            return
        }
        guard let fieldPosition = self.fieldPositionMap[fieldId] else {
            Log("Could not find fieldPosition for field \(fieldId)", type: .error)
            return
        }
        guard let identifier = pageFieldModels[pageID]?.fields[index].fieldIdentifier else {
            Log("Could not find fieldIdentifier for field \(fieldId)", type: .error)
            return
        }
        let dataModelType = getFieldModel(fieldPosition: fieldPosition, fieldIdentifier: identifier)
        pageFieldModels[pageID]?.fields[index].model = dataModelType
    }
    
    private func valueElements(fieldID: String) -> [ValueElement]? {
        return field(fieldID: fieldID)?.valueToValueElements
    }
    
    func refreshDependent(for fieldID: String) {
        let refreshFields = conditionalLogicHandler.fieldsNeedsToBeRefreshed(fieldID: fieldID)
        for fieldId in refreshFields {
            refreshField(fieldId: fieldId)
        }
    }
    
    func getFieldModel(fieldPosition: FieldPosition, fieldIdentifier: FieldIdentifier) -> FieldListModelType {
        guard let fieldPositionFieldID = fieldPosition.field else {
            Log("Could not find fieldPositionFieldID", type: .error)
            return .none
        }
        let fieldData = fieldMap[fieldPositionFieldID]
        var dataModelType: FieldListModelType = .none
        let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)
        
        var fieldHeaderModel = (fieldPosition.titleDisplay == nil || fieldPosition.titleDisplay != "none") ? FieldHeaderModel(title: fieldData?.title, required: fieldData?.required, tipDescription: fieldData?.tipDescription, tipTitle: fieldData?.tipTitle, tipVisible: fieldData?.tipVisible) : nil
        
        switch fieldPosition.type {
        case .text:
            let model = TextDataModel(fieldIdentifier: fieldIdentifier,
                                      text: fieldData?.value?.text ?? "",
                                      mode: fieldEditMode,
                                      fieldHeaderModel: fieldHeaderModel)
            dataModelType = .text(model)
        case .block:
            let model = DisplayTextDataModel(
                displayText: fieldData?.value?.text,
                fontSize: fieldPosition.fontSize,
                fontWeight: fieldPosition.fontWeight,
                fontColor: fieldPosition.fontColor,
                fontStyle: fieldPosition.fontStyle,
                textAlign: fieldPosition.textAlign,
                textDecoration: fieldPosition.textDecoration,
                textTransform: fieldPosition.textTransform,
                backgroundColor: fieldPosition.backgroundColor,
                borderColor: fieldPosition.borderColor,
                borderWidth: fieldPosition.borderWidth,
                borderRadius: fieldPosition.borderRadius,
                padding: fieldPosition.padding
            )
            dataModelType = .block(model)
        case .multiSelect:
            let model = MultiSelectionDataModel(fieldIdentifier: fieldIdentifier,
                                                multi: fieldData?.multi,
                                                options: fieldData?.options,
                                                multiSelector: fieldData?.value?.multiSelector,
                                                fieldHeaderModel: fieldHeaderModel)
            dataModelType = .multiSelect(model)
        case .dropdown:
            let model = DropdownDataModel(fieldIdentifier: fieldIdentifier,
                                          dropdownValue: fieldData?.value?.dropdownValue,
                                          options: fieldData?.options,
                                          fieldHeaderModel: fieldHeaderModel)
            dataModelType = .dropdown(model)
        case .textarea:
            let model = MultiLineDataModel(fieldIdentifier: fieldIdentifier,
                                           multilineText: fieldData?.value?.multilineText,
                                           mode: fieldEditMode,
                                           fieldHeaderModel: fieldHeaderModel)
            dataModelType = .textarea(model)
        case .date:
            let model = DateTimeDataModel(fieldIdentifier: fieldIdentifier,
                                          value: fieldData?.value,
                                          format: fieldPosition.format,
                                          fieldHeaderModel: fieldHeaderModel)
            dataModelType = .date(model)
        case .signature:
            let model = SignatureDataModel(fieldIdentifier: fieldIdentifier,
                                           signatureURL: fieldData?.value?.signatureURL ?? "",
                                           fieldHeaderModel: fieldHeaderModel)
            dataModelType = .signature(model)
        case .number:
            let model = NumberDataModel(fieldIdentifier: fieldIdentifier,
                                        number: fieldData?.value?.number,
                                        mode: fieldEditMode,
                                        fieldHeaderModel: fieldHeaderModel)
            
            dataModelType = .number(model)
        case .chart:
            let model = ChartDataModel(fieldIdentifier: fieldIdentifier,
                                       valueElements: fieldData?.value?.valueElements,
                                       yTitle: fieldData?.yTitle,
                                       yMax: fieldData?.yMax,
                                       yMin: fieldData?.yMin,
                                       xTitle: fieldData?.xTitle,
                                       xMax: fieldData?.xMax,
                                       xMin: fieldData?.xMin,
                                       mode: fieldEditMode,
                                       documentEditor: self,
                                       fieldHeaderModel: fieldHeaderModel)
            dataModelType = .chart(model)
        case .richText:
            let model = RichTextDataModel(text: fieldData?.value?.text,
                                          fieldHeaderModel: fieldHeaderModel)
            dataModelType = .richText(model)
        case .table:
            if let model = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                          mode: fieldEditMode,
                                          documentEditor: self,
                                          fieldIdentifier: fieldIdentifier) {
                dataModelType = .table(model)
            }
        case .collection:
            if let model = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                          mode: fieldEditMode,
                                          documentEditor: self,
                                          fieldIdentifier: fieldIdentifier) {
                dataModelType = .collection(model)
            }
        case .image:
            let model = ImageDataModel(fieldIdentifier: fieldIdentifier,
                                       multi: fieldData?.multi,
                                       primaryDisplayOnly: fieldPosition.primaryDisplayOnly,
                                       valueElements: fieldData?.value?.valueElements,
                                       mode: fieldEditMode,
                                       fieldHeaderModel: fieldHeaderModel)
            dataModelType = .image(model)
        case .none:
            dataModelType = .none
        case .some(.unknown):
            dataModelType = .none
        }
        return dataModelType
    }
}

extension DocumentEditor {
    fileprivate func updatePageFieldModels(_ duplicatedPage: Page, _ newPageID: String, _ fileId: String?) {
        var fieldListModels = [FieldListModel]()
        let fieldPositions = mapWebViewToMobileViewIfNeeded(fieldPositions: duplicatedPage.fieldPositions ?? [], isMobileViewActive: isMobileViewActive)
        for fieldPosition in fieldPositions ?? [] {
            guard let fieldPositionFieldID = fieldPosition.field else {
                Log("FieldPositions has nil FieldID", type: .error)
                continue
            }
            let fieldData = fieldMap[fieldPositionFieldID]
            let fieldIdentifier = FieldIdentifier(fieldID: fieldPositionFieldID, pageID: newPageID, fileID: fileId)
            var dataModelType: FieldListModelType = .none
            let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)
            
            var fieldHeaderModel = (fieldPosition.titleDisplay == nil || fieldPosition.titleDisplay != "none") ? FieldHeaderModel(title: fieldData?.title, required: fieldData?.required, tipDescription: fieldData?.tipDescription, tipTitle: fieldData?.tipTitle, tipVisible: fieldData?.tipVisible) : nil
            
            dataModelType = getFieldModel(fieldPosition: fieldPosition, fieldIdentifier: fieldIdentifier)
            fieldListModels.append(FieldListModel(fieldIdentifier: fieldIdentifier, fieldEditMode: fieldEditMode, model: dataModelType))
            let index = fieldListModels.count - 1
            fieldIndexMap[fieldPositionFieldID] = fieldIndexMapValue(pageID: newPageID, index: index)
        }
        pageFieldModels[newPageID] = PageModel(id: newPageID, fields: fieldListModels)
    }
    
    fileprivate func addFieldAndFieldPositionForWeb(_ originalPage: Page, _ fieldMapping: inout [String : String], _ newFields: inout [JoyDocField], _ newFieldPositions: inout [FieldPosition], _ newPageID: String) {
        for var fieldPos in originalPage.fieldPositions ?? [] {
            guard let origFieldID = fieldPos.field else { continue }
            if let origField = field(fieldID: origFieldID) {
                var duplicateField = origField
                let newFieldID = generateObjectId()
                fieldMapping[origFieldID] = newFieldID
                
                duplicateField.id = newFieldID
                newFields.append(duplicateField)
                fieldPos.field = newFieldID
                newFieldPositions.append(fieldPos)
            }
        }
        // apply conditional logic here
        for i in 0..<newFields.count {
            if var logic = newFields[i].logic, var conditions = logic.conditions {
                for j in conditions.indices {
                    if let origPageID = originalPage.id, conditions[j].page == origPageID {
                        conditions[j].page = newPageID
                    }
                    if let origFieldRef = conditions[j].field,
                       let newFieldRef = fieldMapping[origFieldRef] {
                        conditions[j].field = newFieldRef
                    }
                }
                logic.conditions = conditions
                newFields[i].logic = logic
            }
        }
    }
    
    public func duplicatePage(pageID: String) {
        guard var firstFile = document.files.first else {
            Log("No file found in document.", type: .error)
            return
        }
        
        guard let originalPageIndex = firstFile.pages?.firstIndex(where: { $0.id == pageID }) else {
            Log("Page with id \(pageID) not found in file.pages.", type: .error)
            return
        }
        guard let pages = firstFile.pages else {
            Log("No pages found in file", type: .error)
            return
        }
        let originalPage = pages[originalPageIndex]
        let newPageID = generateObjectId()
        
        var duplicatedPage = originalPage
        duplicatedPage.id = newPageID
        
        var fieldMapping: [String: String] = [:]
        var newFields: [JoyDocField] = []
        var newFieldPositions: [FieldPosition] = []
        
        addFieldAndFieldPositionForWeb(originalPage, &fieldMapping, &newFields, &newFieldPositions, newPageID)
        
        document.fields = newFields
        duplicatedPage.fieldPositions = newFieldPositions
        
        if firstFile.pages == nil {
            firstFile.pages = []
        }
        firstFile.pages!.append(duplicatedPage)
        
        if var pageOrder = firstFile.pageOrder {
            if let index = pageOrder.firstIndex(of: pageID) {
                pageOrder.insert(newPageID, at: index + 1)
            } else {
                pageOrder.append(newPageID)
            }
            firstFile.pageOrder = pageOrder
            self.currentPageOrder = pageOrder
        }
        
        // duplicate views page
        if let altViews = firstFile.views, !altViews.isEmpty {
            var altView = altViews[0]
            if let originalAlternatePageIndex = altView.pages?.firstIndex(where: { $0.id == pageID }) {
                var originalAltPage = altView.pages![originalAlternatePageIndex]
                originalAltPage.id = duplicatedPage.id
                
                var alternateFieldMapping: [String: String] = [:]
                var alternateNewFields: [JoyDocField] = []
                var alternateNewFieldPositions: [FieldPosition] = []
                
                for var fieldPos in originalAltPage.fieldPositions ?? [] {
                    guard let origFieldID = fieldPos.field else { continue }
                    if let newField = fieldMapping[origFieldID] {
                        fieldPos.field = newField
                    }else {
                        if let origField = field(fieldID: origFieldID) {
                            var duplicateField = origField
                            let newFieldID = generateObjectId()
                            alternateFieldMapping[origFieldID] = newFieldID
                            
                            duplicateField.id = newFieldID
                            alternateNewFields.append(duplicateField)
                            fieldPos.field = newFieldID
                        }
                    }
                    alternateNewFieldPositions.append(fieldPos)
                }
                // apply conditional logic here
                for i in 0..<alternateNewFields.count {
                    if var logic = alternateNewFields[i].logic, var conditions = logic.conditions {
                        for j in conditions.indices {
                            if let origPageID = originalAltPage.id, conditions[j].page == origPageID {
                                conditions[j].page = newPageID
                            }
                            if let origFieldRef = conditions[j].field,
                               let newFieldRef = alternateFieldMapping[origFieldRef] {
                                conditions[j].field = newFieldRef
                            }
                        }
                        logic.conditions = conditions
                        alternateNewFields[i].logic = logic
                    }
                }
                
                originalAltPage.fieldPositions = alternateNewFieldPositions
                newFields.append(contentsOf: alternateNewFields)
                document.fields = newFields
                if altView.pages == nil {
                    altView.pages = [originalAltPage]
                } else {
                    altView.pages!.append(originalAltPage)
                }
                
                if var altPageOrder = altView.pageOrder {
                    if let idx = altPageOrder.firstIndex(of: pageID) {
                        altPageOrder.insert(newPageID, at: idx + 1)
                    } else {
                        altPageOrder.append(newPageID)
                    }
                    altView.pageOrder = altPageOrder
                } else {
                    altView.pageOrder = [newPageID]
                }
                // Save the updated alternate view back into the file.
                firstFile.views![0] = altView
            }
        }
        
        var files = document.files
        if let fileIndex = files.firstIndex(where: { $0.id == firstFile.id }) {
            files[fileIndex] = firstFile
        }
        document.files = files
        updateFieldMap()
        updateFieldPositionMap()
        updatePageFieldModels(duplicatedPage, newPageID, firstFile.id ?? "")
        if let views = document.files.first?.views, !views.isEmpty {
            if let page = views.first?.pages?.first(where: { $0.id == newPageID }) {
                updatePageFieldModels(page, newPageID, firstFile.id ?? "")
            }
        }
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        
        if let views = document.files.first?.views, !views.isEmpty {
            guard let targetIndex = document.files.first?.pageOrder?.firstIndex(of: newPageID) else {
                Log("Could not find index for duplicated page", type: .error)
                return
            }
            guard let viewPage = views.first?.pages?.first(where: { $0.id == newPageID }) else {
                Log("Could not find view page for duplicated page", type: .error)
                return
            }
            onChangeDuplicatePage(view: views.first, viewId: views.first?.id ?? "", page: duplicatedPage,fields: document.fields, fileId: document.files.first?.id ?? "", targetIndex: targetIndex, newFields: newFields, viewPage: viewPage)
        } else {
            guard let targetIdnex = document.files.first?.pageOrder?.firstIndex(of: newPageID) else {
                Log("Could not find index for duplicated page", type: .error)
                return
            }
            onChangeDuplicatePage(viewId: "", page: duplicatedPage, fields: document.fields, fileId: document.files[0].id ?? "", targetIndex: targetIdnex, newFields: newFields)
        }
    }
}
