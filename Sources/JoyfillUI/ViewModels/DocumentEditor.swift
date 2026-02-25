//
//  File.swift
//
//
//  Created by Vishnu Dutt on 21/11/24.
//

import Foundation
import JoyfillModel
import JSONSchema
import Combine

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

public enum NavigationStatus: String {
    case success
    case failure
}

/// Navigation target for auto-scrolling to pages and fields
public struct NavigationTarget: Equatable {
    public let pageId: String
    public let fieldID: String?
    public let rowId: String?
    public let openRowForm: Bool
    
    public init(pageId: String, fieldID: String? = nil, rowId: String? = nil, openRowForm: Bool = false) {
        self.pageId = pageId
        self.fieldID = fieldID
        self.rowId = rowId
        self.openRowForm = openRowForm
    }
}

/// Configuration options for the goto navigation method
public struct GotoConfig {
    /// Whether to automatically open the row form modal for table/collection rows
    public let open: Bool
    
    public init(open: Bool = false) {
        self.open = open
    }
}

public class DocumentEditor: ObservableObject {
    private(set) public var document: JoyDoc
    public var schemaError: SchemaValidationError?
    @Published public var currentPageID: String {
        didSet {
            handlePageChange(from: oldValue, to: currentPageID)
        }
    }
    @Published var currentPageOrder: [String] = []
    let navigationPublisher = PassthroughSubject<NavigationTarget, Never>()
    public private(set) var isCollectionFieldEnabled: Bool = false

    public var mode: Mode = .fill
    public var isPageDuplicateEnabled: Bool = true
    public var isPageDeleteEnabled: Bool = true
    public var showPageNavigationView: Bool = true
    public var singleClickRowEdit: Bool = false
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
    let backgroundQueue = DispatchQueue(label: "documentEditor.background", qos: .userInitiated)
    
    private var validationHandler: ValidationHandler!
    var conditionalLogicHandler: ConditionalLogicHandler!
    private var JoyfillDocContext: JoyfillDocContext!

    public init(document: JoyDoc,
                mode: Mode = .fill,
                events: FormChangeEvent? = nil,
                pageID: String? = nil,
                navigation: Bool = true,
                isPageDuplicateEnabled: Bool = false,
                isPageDeleteEnabled: Bool = false,
                validateSchema: Bool = true,
                license: String? = nil,
                singleClickRowEdit: Bool = false) {
        // Perform schema validation first
        if validateSchema {
            // Check for schema validation errors
            let schemaManager = JoyfillSchemaManager()
            if let schemaError = schemaManager.validateSchema(document: document) {
                // Schema validation failed - store error and return early
                self.schemaError = schemaError
                // Set empty document
                self.document = JoyDoc()
                self.mode = mode
                self.isPageDuplicateEnabled = isPageDuplicateEnabled
                self.isPageDeleteEnabled = isPageDeleteEnabled
                self.showPageNavigationView = navigation
                self.singleClickRowEdit = singleClickRowEdit
                self.currentPageID = ""
                self.events = events
                
                // Trigger onError callback if events handler is available
                events?.onError(error: .schemaValidationError(error: schemaError))
                return
            }
        }
        
        // Schema validation passed - proceed with normal initialization
        self.document = document
        self.mode = mode
        self.isPageDuplicateEnabled = mode == .readonly ? false : isPageDuplicateEnabled
        self.isPageDeleteEnabled = mode == .readonly ? false : isPageDeleteEnabled
        self.showPageNavigationView = navigation
        self.singleClickRowEdit = singleClickRowEdit
        self.currentPageID = ""
        self.events = events
        // Set feature flags from license
        self.isCollectionFieldEnabled = LicenseValidator.isCollectionEnabled(licenseToken: license)
        updateFieldMap()
        updateFieldPositionMap()
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        guard let firstFile = files.first, let fileID = firstFile.id else {
            return
        }

        for page in document.pagesForCurrentView {
            guard let pageID = page.id else { return }
            updatePageFieldModels(page, pageID, fileID)
        }
        self.validationHandler = ValidationHandler(documentEditor: self)
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
    
    public func shouldShowColumn(columnID: String, fieldID: String, schemaKey: String? = nil) -> Bool {
        return conditionalLogicHandler.shouldShow(columnID: columnID, fieldID: fieldID, schemaKey: schemaKey)
    }
    
    /// Returns true if the field is force-hidden for the current view via hiddenViews. Takes precedence over conditional logic.
    public func isFieldForceHiddenByView(field: JoyDocField) -> Bool {
        guard let views = field.hiddenViews, !views.isEmpty else { return false }
        return views.contains(ViewType.mobile.rawValue)
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
              let field = fieldMap[fieldID] else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case .table, .collection:
            DispatchQueue.main.async {
                guard let valueDelegate = self.valueDelegate(for: fieldID, fieldType: field.fieldType) else {
                    return
                }
                valueDelegate.applyRowEditChanges(change: change)
                self.refreshField(fieldId: fieldID)
                self.refreshDependent(for: fieldID)
            }
        default:
            break
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
            if let valueDelegate = valueDelegate(for: fieldID, fieldType: field.fieldType) {
                valueDelegate.insertRow(for: change)
                refreshField(fieldId: fieldID)
                refreshDependent(for: fieldID)
            }
        default:
            break
        }
    }
    
    private func createViewModel(for fieldID: String, fieldType: FieldTypes) -> DocumentEditorDelegate? {
        if let fieldPosition = fieldPosition(fieldID: fieldID) {
            let fieldIdentifier = getFieldIdentifier(for: fieldID)
            if let tableDataModel = getFieldModel(fieldPosition: fieldPosition, fieldIdentifier: fieldIdentifier).tableDataModel {
                switch fieldType {
                case .table:
                    return TableViewModel(tableDataModel: tableDataModel)
                case .collection:
                    return CollectionViewModel(tableDataModel: tableDataModel)
                default:
                    break
                }
            }
        }
        return nil
    }

    private func valueDelegate(for fieldID: String, fieldType: FieldTypes) -> DocumentEditorDelegate? {
        if let delegate = delegateMap[fieldID]?.value {
            return delegate
        }
        guard let newDelegate = createViewModel(for: fieldID, fieldType: fieldType) else {
            return nil
        }
        delegateMap[fieldID] = WeakDocumentEditorDelegate(newDelegate)
        return newDelegate
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
            if let valueDelegate = valueDelegate(for: fieldID, fieldType: field.fieldType) {
                valueDelegate.deleteRow(for: change)
                refreshField(fieldId: fieldID)
                refreshDependent(for: fieldID)
            }
        default:
            break
        }
    }
    
    private func handleFieldValueRowMove(for change: Change) {
        guard let fieldID = change.fieldId,
              let field = fieldMap[fieldID] else {
            logChangeError(for: change)
            return
        }
        switch field.fieldType {
        case .table, .collection:
            if let valueDelegate = valueDelegate(for: fieldID, fieldType: field.fieldType) {
                valueDelegate.moveRow(for: change)
                refreshField(fieldId: fieldID)
                refreshDependent(for: fieldID)
            }
        default:
            break
        }
    }
    
    private func handleFieldUpdate(for change: Change) {
        guard let fieldID = change.fieldId else {
            logChangeError(for: change)
            return
        }
        if let value = change.change?["value"] as? Any,
           let valueUnion = ValueUnion(value: value) {
            updateValue(for: fieldID, value: valueUnion, shouldCallOnChange: false)
        }
        if let metadataDict = change.change?["metadata"] as? [String: Any],
           let meta = Metadata(dictionary: metadataDict),
           var field = fieldMap[fieldID] {
            field.metadata = meta
            updateField(field: field)
            refreshField(fieldId: fieldID)
            refreshDependent(for: fieldID)
        }
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
    
    public func updateField(field: JoyDocField?) {
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
    
    public func getFieldIdentifier(for fieldID: String) -> FieldIdentifier {
        let field = field(fieldID: fieldID)
        let fileID = field?.file
        let fieldIdentifier = field?.identifier
        for page in pagesForCurrentView {
            if let position = page.fieldPositions?.first(where: { $0.field == fieldID }) {
                return FieldIdentifier(_id: documentID, identifier: documentIdentifier, fieldID: fieldID, fieldIdentifier: fieldIdentifier, pageID: page.id, fileID: fileID, fieldPositionId: position.id)
            }
        }

        return FieldIdentifier(_id: documentID, identifier: documentIdentifier, fieldID: fieldID, fieldIdentifier: fieldIdentifier, fileID: fileID)
    }
}

extension DocumentEditor {
    func updateSchemaVisibilityOnCellChange(collectionFieldID: String, columnID: String, rowID: String, valueElement: ValueElement?) {
        conditionalLogicHandler.updateSchemaVisibility(collectionFieldID: collectionFieldID, columnID: columnID, rowID: rowID, valueElement: valueElement)
    }
    
    func updateSchemaVisibilityOnNewRow(collectionFieldID: String, rowID: String, valueElement: ValueElement?) {
        conditionalLogicHandler.updateShowCollectionSchemaMap(collectionFieldID: collectionFieldID, rowID: rowID, valueElement: valueElement)
    }
    
    func shouldRefreshSchema(for collectionFieldID: String, columnID: String) -> Bool {
        return conditionalLogicHandler.shouldRefreshSchema(for: collectionFieldID, columnID: columnID)
    }
    
    fileprivate func updateTimeZoneIfNeeded(_ field: inout JoyDocField) {
        if field.fieldType == .date {
            if let timeZoneString = field.tz {
                if timeZoneString.isEmpty || TimeZone(identifier: timeZoneString) == nil {
                    field.tz = TimeZone.current.identifier
                }
            } else {
                field.tz = TimeZone.current.identifier
            }
        }
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
            updateTimeZoneIfNeeded(&field)
            updateField(field: field)
            refreshField(fieldId: event.fieldIdentifier.fieldID)
            refreshDependent(for: event.fieldIdentifier.fieldID)
            if let identifier = field.id {
                self.JoyfillDocContext.updateDependentFormulas(forFieldIdentifier: identifier)
            }
        }
    }
    
    private func fieldIndexMapValue(pageID: String, index: Int) -> String {
        return "\(pageID)|\(index)"
    }
    
    public func mapWebViewToMobileViewIfNeeded(fieldPositions: [FieldPosition], isMobileViewActive: Bool) -> [FieldPosition] {
        var uniqueFields = Set<String>()
        var resultFieldPositions = [FieldPosition]()
        resultFieldPositions.reserveCapacity(fieldPositions.count)
        
        for fp in fieldPositions {
            if let field = fp.field, !uniqueFields.contains(field) {
                uniqueFields.insert(field)
                var modifiableFP = fp
                if !isMobileViewActive {
                    modifiableFP.titleDisplay = "inline"
                }
                resultFieldPositions.append(modifiableFP)
            }
        }
        
        return resultFieldPositions.sorted { fp1, fp2 in
            guard let y1 = fp1.y, let y2 = fp2.y, let x1 = fp1.x, let x2 = fp2.x else {
                return false
            }
            if Int(y1) == Int(y2) {
                return Int(x1) < Int(x2)
            } else {
                return Int(y1) < Int(y2)
            }
        }
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
    
    /// Returns true if the row exists and is visible for navigation.
    /// Table: row must be in field.rowOrder (same as viewModel.tableDataModel.rowOrder.contains(rowId)).
    /// Collection: row must exist in value tree and not be deleted (same idea as viewModel.getSchemaForRow(rowId:) != nil).
    private func rowExistsInField(fieldID: String, rowId: String) -> Bool {
        guard let field = field(fieldID: fieldID) else { return false }
        switch field.fieldType {
        case .table:
            return field.rowOrder?.contains(rowId) == true
        case .collection:
            guard let elements = field.valueToValueElements else { return false }
            return rowExistsInValueElements(elements, rowId: rowId)
        default:
            return false
        }
    }
    
    /// Recursively finds rowId in collection value elements (including nested); returns false if row is deleted.
    private func rowExistsInValueElements(_ elements: [ValueElement], rowId: String) -> Bool {
        for element in elements {
            if element.id == rowId {
                if element.deleted == true { return false }
                return true
            }
            if element.deleted == true { continue }
            if let childrens = element.childrens {
                for child in childrens.values {
                    if let nested = child.valueToValueElements, rowExistsInValueElements(nested, rowId: rowId) {
                        return true
                    }
                }
            }
        }
        return false
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
            let normalizedDateValue = fieldData?.value?.normalizedNumericValue
            let model = DateTimeDataModel(fieldIdentifier: fieldIdentifier,
                                          value: normalizedDateValue,
                                          format: fieldPosition.format,
                                          timezoneId: fieldData?.tz,
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

extension ValueUnion {
    /// Returns a `Double` representation for numeric-backed values.
    /// Useful when backend may send numbers as either `Int` or `Double`.
    var doubleValue: Double? {
        switch self {
        case .double(let value):
            return value
        case .int(let value):
            return Double(value)
        case .string(let value):
            return Double(value)
        default:
            return nil
        }
    }

    /// Normalizes numeric values so callers can rely on `Double`-backed numbers.
    /// - Converts `.int` -> `.double`
    /// - Converts numeric `.string` -> `.double`
    /// - Leaves non-numeric values unchanged
    var normalizedNumericValue: ValueUnion {
        if let d = doubleValue {
            return .double(d)
        }
        return self
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
            if fieldData?.fieldType == .collection && !isCollectionFieldEnabled {
                continue
            }
            let fieldIdentifier = FieldIdentifier(_id: documentID, identifier: documentIdentifier, fieldID: fieldPositionFieldID, fieldIdentifier: fieldData?.identifier, pageID: newPageID, fileID: fileId, fieldPositionId: fieldPosition.id)
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
    
    /// Remaps conditional logic conditions for duplicated fields, including field-level, tableColumn-level, and schema tableColumn-level logic.
    fileprivate func remapConditionalLogic(fields: inout [JoyDocField], fieldMapping: [String: String], origPageID: String?, newPageID: String) {
        for i in 0..<fields.count {
            // 1. Remap field-level logic
            if var logic = fields[i].logic, var conditions = logic.conditions {
                remapConditions(&conditions, fieldMapping: fieldMapping, origPageID: origPageID, newPageID: newPageID)
                logic.conditions = conditions
                fields[i].logic = logic
            }
            
            // 2. Remap tableColumns logic (for table fields)
            if fields[i].fieldType == .table, var tableColumns = fields[i].tableColumns {
                remapTableColumnsLogic(&tableColumns, fieldMapping: fieldMapping, origPageID: origPageID, newPageID: newPageID)
                fields[i].tableColumns = tableColumns
            }
            
            // 3. Remap schema tableColumns logic (for collection fields)
            if fields[i].fieldType == .collection, var schema = fields[i].schema {
                for (key, var schemaEntry) in schema {
                    if var schemaColumns = schemaEntry.tableColumns {
                        remapTableColumnsLogic(&schemaColumns, fieldMapping: fieldMapping, origPageID: origPageID, newPageID: newPageID)
                        schemaEntry.tableColumns = schemaColumns
                        schema[key] = schemaEntry
                    }
                }
                fields[i].schema = schema
            }
        }
    }
    
    /// Remaps conditions array to point to new duplicated field IDs and page ID.
    private func remapConditions(_ conditions: inout [Condition], fieldMapping: [String: String], origPageID: String?, newPageID: String) {
        for j in conditions.indices {
            if let origPage = origPageID, conditions[j].page == origPage {
                conditions[j].page = newPageID
            }
            if let origFieldRef = conditions[j].field,
               let newFieldRef = fieldMapping[origFieldRef] {
                conditions[j].field = newFieldRef
            }
        }
    }
    
    /// Remaps logic conditions inside an array of FieldTableColumn.
    private func remapTableColumnsLogic(_ tableColumns: inout [FieldTableColumn], fieldMapping: [String: String], origPageID: String?, newPageID: String) {
        for k in tableColumns.indices {
            if var colLogic = tableColumns[k].logic, var colConditions = colLogic.conditions {
                remapConditions(&colConditions, fieldMapping: fieldMapping, origPageID: origPageID, newPageID: newPageID)
                colLogic.conditions = colConditions
                tableColumns[k].logic = colLogic
            }
        }
    }
    
    fileprivate func addFieldAndFieldPositionForWeb(_ originalPage: Page, _ fieldMapping: inout [String : String], _ newFields: inout [JoyDocField], _ newFieldPositions: inout [FieldPosition], _ newPageID: String) {
        for var fieldPos in originalPage.fieldPositions ?? [] {
            guard let origFieldID = fieldPos.field else { continue }
            if let origField = field(fieldID: origFieldID) {
                if fieldMapping[origFieldID] != nil {
                    fieldPos.field = origFieldID
                    newFieldPositions.append(fieldPos)
                    continue
                }
                var duplicateField = origField
                let newFieldID = "field_\(generateObjectId())"
                fieldMapping[origFieldID] = newFieldID
                
                duplicateField.id = newFieldID
                newFields.append(duplicateField)
                fieldPos.field = newFieldID
                newFieldPositions.append(fieldPos)
            }
        }
        // apply conditional logic here
        remapConditionalLogic(fields: &newFields, fieldMapping: fieldMapping, origPageID: originalPage.id, newPageID: newPageID)
    }
    
    /// Duplicates formulas and updates field references for duplicated page
    /// - Parameters:
    ///   - newFields: Array of duplicated fields
    ///   - fieldMapping: Mapping of old field IDs to new field IDs
    /// - Returns: Mapping of old formula IDs to new formula IDs
    fileprivate func duplicateFormulasForPage(_ newFields: inout [JoyDocField], fieldMapping: [String: String]) -> [String: String] {
        var formulaMapping: [String: String] = [:]
        var newFormulas: [Formula] = []
        
        // Step 1: Collect all formula IDs referenced by duplicated fields
        var referencedFormulaIDs = Set<String>()
        for field in newFields {
            if let appliedFormulas = field.formulas {
                for appliedFormula in appliedFormulas {
                    if let formulaID = appliedFormula.formula {
                        referencedFormulaIDs.insert(formulaID)
                    }
                }
            }
        }
        
        // Step 2: Duplicate each referenced formula
        let existingFormulas = document.formulas
        for originalFormulaID in referencedFormulaIDs {
            guard let originalFormula = existingFormulas.first(where: { $0.id == originalFormulaID }) else {
                continue
            }
            
            // Create a copy of the formula
            var duplicatedFormula = originalFormula
            let newFormulaID = generateObjectId()
            duplicatedFormula.id = newFormulaID
            formulaMapping[originalFormulaID] = newFormulaID
            
            // Step 3: Update field IDs in the expression using regex
            if let originalExpression = originalFormula.expression {
                var updatedExpression = originalExpression
                
                Log("🔄 Duplicating formula \(originalFormulaID) -> \(newFormulaID)", type: .debug)
                Log("   Original expression: \(originalExpression)", type: .debug)
                
                // Sort field IDs by length (longest first) to avoid partial replacements
                // This ensures that "number11" is replaced before "number1" if both exist
                let sortedFieldMappings = fieldMapping.sorted { $0.key.count > $1.key.count }
                
                // Replace each old field ID with new field ID using negative lookahead/lookbehind
                // This ensures we only match complete identifiers, not partial matches
                for (oldFieldID, newFieldID) in sortedFieldMappings {
                    // Escape the field ID for use in regex
                    let escapedFieldID = NSRegularExpression.escapedPattern(for: oldFieldID)
                    
                    // Escape the replacement field ID to prevent regex interpretation
                    let escapedNewFieldID = newFieldID.replacingOccurrences(of: "\\", with: "\\\\")
                                                       .replacingOccurrences(of: "$", with: "\\$")
                    
                    // Pattern explanation:
                    // (?<![a-zA-Z0-9_]) = negative lookbehind: not preceded by alphanumeric or underscore
                    // (fieldID) = the actual field ID
                    // (?![a-zA-Z0-9_]) = negative lookahead: not followed by alphanumeric or underscore
                    // This prevents "number1" from matching in "number11" or "thenumber1"
                    let pattern = "(?<![a-zA-Z0-9_])\(escapedFieldID)(?![a-zA-Z0-9_])"
                    
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                        let range = NSRange(updatedExpression.startIndex..., in: updatedExpression)
                        let beforeReplace = updatedExpression
                        updatedExpression = regex.stringByReplacingMatches(
                            in: updatedExpression,
                            options: [],
                            range: range,
                            withTemplate: escapedNewFieldID
                        )
                        
                        if beforeReplace != updatedExpression {
                            Log("   Replaced '\(oldFieldID)' with '\(newFieldID)'", type: .debug)
                        }
                    }
                }
                
                Log("   Updated expression: \(updatedExpression)", type: .debug)
                duplicatedFormula.expression = updatedExpression
            }
            
            newFormulas.append(duplicatedFormula)
        }
        
        // Step 4: Add new formulas to document
        if !newFormulas.isEmpty {
            var allFormulas = document.formulas
            allFormulas.append(contentsOf: newFormulas)
            document.formulas = allFormulas
        }
        
        // Step 5: Update field.formulas references to point to new formula IDs
        for i in 0..<newFields.count {
            if var appliedFormulas = newFields[i].formulas {
                for j in 0..<appliedFormulas.count {
                    if let oldFormulaID = appliedFormulas[j].formula,
                       let newFormulaID = formulaMapping[oldFormulaID] {
                        appliedFormulas[j].formula = newFormulaID
                        // Also update the applied formula's own ID
                        appliedFormulas[j].id = generateObjectId()
                    }
                }
                newFields[i].formulas = appliedFormulas
            }
        }
        
        return formulaMapping
    }
    
    public func duplicatePage(pageID: String) {
        guard var firstFile = document.files.first else {
            Log("No file found in document.", type: .error)
            return
        }
        let originalPage: Page
        if let mainPage = firstFile.pages?.first(where: { $0.id == pageID }) {
            originalPage = mainPage
        } else {
            Log("Page with id \(pageID) not found in views or pages.", type: .error)
            return
        }

        let newPageID = generateObjectId()
        
        var duplicatedPage = originalPage
        duplicatedPage.id = newPageID
        
        var fieldMapping: [String: String] = [:]
        var newFields: [JoyDocField] = []
        var newFieldPositions: [FieldPosition] = []
        
        // duplicate views page
        if let altViews = firstFile.views, !altViews.isEmpty {
            var altView = altViews[0]
            if let originalAlternatePageIndex = altView.pages?.firstIndex(where: { $0.id == pageID }) {
                var originalAltPage = altView.pages![originalAlternatePageIndex]
                let originalAltPageID = originalAltPage.id
                originalAltPage.id = duplicatedPage.id
                
                var alternateFieldMapping: [String: String] = [:]
                var alternateNewFields: [JoyDocField] = []
                var alternateNewFieldPositions: [FieldPosition] = []
                
                for var fieldPos in originalAltPage.fieldPositions ?? [] {
                    guard let origFieldID = fieldPos.field else { continue }
                        if let origField = field(fieldID: origFieldID) {
                            var duplicateField = origField
                            let newFieldID = "field_\(generateObjectId())"
                            alternateFieldMapping[origFieldID] = newFieldID
                            
                            duplicateField.id = newFieldID
                            alternateNewFields.append(duplicateField)
                            fieldPos.field = newFieldID
                        }
                    alternateNewFieldPositions.append(fieldPos)
                }
                // apply conditional logic here
                remapConditionalLogic(fields: &alternateNewFields, fieldMapping: alternateFieldMapping, origPageID: originalAltPageID, newPageID: newPageID)
                fieldMapping = alternateFieldMapping
                // Duplicate formulas for the alternate view fields
                let _ = duplicateFormulasForPage(&alternateNewFields, fieldMapping: alternateFieldMapping)
                
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
        
        addFieldAndFieldPositionForWeb(originalPage, &fieldMapping, &newFields, &newFieldPositions, newPageID)
        
        let _ = duplicateFormulasForPage(&newFields, fieldMapping: fieldMapping)
        
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

        var files = document.files
        if let fileIndex = files.firstIndex(where: { $0.id == firstFile.id }) {
            files[fileIndex] = firstFile
        }
        document.files = files
        updateFieldMap()
        updateFieldPositionMap()
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        if !isMobileViewActive {
            updatePageFieldModels(duplicatedPage, newPageID, firstFile.id ?? "")
        }
        if let views = document.files.first?.views, !views.isEmpty {
            if let page = views.first?.pages?.first(where: { $0.id == newPageID }) {
                updatePageFieldModels(page, newPageID, firstFile.id ?? "")
            }
        }
        
        self.JoyfillDocContext = Joyfill.JoyfillDocContext(docProvider: self)
        
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
    
    // MARK: - Page Deletion
    
    /// Validates if a page can be deleted and returns warnings about dependencies
    /// - Parameter pageID: The ID of the page to validate
    /// - Returns: Tuple with canDelete flag and array of warning messages
    public func canDeletePage(pageID: String) -> (canDelete: Bool, warnings: [String]) {
        var warnings: [String] = []
        
        guard let firstFile = document.files.first else {
            return (false, ["No file found in document"])
        }
        
        // Check 1: Must have at least 2 pages (cannot delete the last page)
        let totalPages = firstFile.pages?.count ?? 0
        guard totalPages > 1 else {
            return (false, ["Cannot delete the last page. A document must have at least one page."])
        }
        
        // Check 2: Page must exist
        guard firstFile.pages?.contains(where: { $0.id == pageID }) == true else {
            return (false, ["Page with ID \(pageID) not found"])
        }
        
        return (true, warnings)
    }
    /// Determines the next page to navigate to after deleting a page
    private func determineNextPage(after deletedPageID: String) -> String {
        guard let firstFile = document.files.first,
              let pageOrder = firstFile.pageOrder,
              let deletedIndex = pageOrder.firstIndex(of: deletedPageID) else {
            return ""
        }
        
        // Try next page first
        if deletedIndex < pageOrder.count - 1 {
            return pageOrder[deletedIndex + 1]
        }
        
        // Otherwise, go to previous page
        if deletedIndex > 0 {
            return pageOrder[deletedIndex - 1]
        }
        
        // Fallback: return first valid page
        return document.firstValidPageID(for: nil, conditionalLogicHandler: conditionalLogicHandler)
    }
    
    /// Deletes a page from the document
    /// - Parameters:
    ///   - pageID: The ID of the page to delete
    ///   - force: If true, bypasses warnings and deletes anyway
    /// - Returns: Tuple with success flag and message
    public func deletePage(pageID: String) -> Bool {
        // 1. Validate
        let (canDelete, warnings) = canDeletePage(pageID: pageID)
        
        guard canDelete else {
            let message = warnings.first ?? "Cannot delete page"
            Log(message, type: .error)
            return false
        }
        
        guard var firstFile = document.files.first else {
            Log("No file found in document", type: .error)
            return false
        }
        
        // 2. Find page in either views or main pages (check both locations)
        var fieldsToDelete = Set<String>()
        var viewId: String? = nil
        var mobileViewFieldPositions: [FieldPosition] = []
        // 1) Collect from view page (if exists)
        if let view = firstFile.views?.first,
           let viewPage = view.pages?.first(where: { $0.id == pageID }) {
            viewId = view.id
            mobileViewFieldPositions = viewPage.fieldPositions ?? []
            for fPosition in mobileViewFieldPositions {
                guard let fieldID = fPosition.field else { continue }
                fieldsToDelete.insert(fieldID)
            }
        }
        var webFieldPositions: [FieldPosition] = []
        // 2) Collect from main page (if exists)
        if let mainPage = firstFile.pages?.first(where: { $0.id == pageID }) {
            webFieldPositions = mainPage.fieldPositions ?? []
            for fPosition in webFieldPositions {
                guard let fieldID = fPosition.field else { continue }
                fieldsToDelete.insert(fieldID)
            }
        }
        
        // Fire blur event for page to delete only if current page == pageID
        if currentPageID == pageID {
            if let previousPage = firstPageFor(currentPageID: pageID) {
                onPageBlur(page: previousPage)
            }
        }
                
        // 3. Handle navigation before deletion
        let shouldNavigate = currentPageID == pageID
        let nextPageID = shouldNavigate ? determineNextPage(after: pageID) : currentPageID
        
        // 4. Remove from pageOrder
        firstFile.pageOrder?.removeAll(where: { $0 == pageID })
        self.currentPageOrder.removeAll(where: { $0 == pageID })
        
        // 5. Remove page from pages array
        if let pageIndex = firstFile.pages?.firstIndex(where: { $0.id == pageID }) {
            firstFile.pages?.remove(at: pageIndex)
        }
        
        // 6. Handle views
        if var views = firstFile.views, !views.isEmpty {
            for i in views.indices {
                views[i].pageOrder?.removeAll(where: { $0 == pageID })
                if let viewPageIndex = views[i].pages?.firstIndex(where: { $0.id == pageID }) {
                    views[i].pages?.remove(at: viewPageIndex)
                }
            }
            firstFile.views = views
        }
                
        // 7. Update document state
        var files = document.files
        if let fileIndex = files.firstIndex(where: { $0.id == firstFile.id }) {
            files[fileIndex] = firstFile
        }
        document.files = files
                
        // 9. Filter out orphaned fields (fields that are still referenced by other fieldPositions)
        let remainingFieldIDs: Set<String> = {
            var ids = Set<String>()
            // Remaining pages
            for page in firstFile.pages ?? [] {
                for fp in page.fieldPositions ?? [] {
                    if let fid = fp.field {
                        ids.insert(fid)
                    }
                }
            }
            // Remaining view pages
            for view in firstFile.views ?? [] {
                for page in view.pages ?? [] {
                    for fp in page.fieldPositions ?? [] {
                        if let fid = fp.field {
                            ids.insert(fid)
                        }
                    }
                }
            }
            return ids
        }()

        let fieldsToRemove = fieldsToDelete.filter { id in
            !remainingFieldIDs.contains(id)
        }

        // Collect field data BEFORE deletion (while fields still exist)
        let fieldsData = fieldsToRemove.compactMap { fieldID -> (id: String, identifier: String?, positionId: String?)? in
            guard let field = field(fieldID: fieldID) else { return nil }
            let fieldPositionID =
                    webFieldPositions.first { $0.field == fieldID }?.id ??
                    mobileViewFieldPositions.first { $0.field == fieldID }?.id
            
            return (fieldID, field.identifier, fieldPositionID)
        }
        
        // 8. Update internal state
        updateFieldPositionMap()
        pageFieldModels.removeValue(forKey: pageID)
        
        // 10. Remove fields from fieldMap (didSet will automatically update document.fields)
        for fieldID in fieldsToRemove {
            fieldMap.removeValue(forKey: fieldID)
        }
        
        // 11. Reinitialize conditional logic handler
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        
        // 12. Handle navigation
        if shouldNavigate && !nextPageID.isEmpty {
            self.currentPageID = nextPageID
        }
        
        // 13. Fire change events with pre-collected field data
        onChangeDeletePage(pageID: pageID, fieldsData: fieldsData, fileId: firstFile.id ?? "", viewId: viewId ?? "")

        return true
    }
}

// MARK: - Navigation
extension DocumentEditor {
    /// Sends a navigation event, always on the main thread.
    /// When a page change is needed, both the page change and the navigation event
    /// are sequenced together on main so the delay is relative to the actual page change.
    private func sendNavigation(_ event: NavigationTarget) {
        if Thread.isMainThread {
            navigationPublisher.send(event)
        } else {
            DispatchQueue.main.async {
                self.navigationPublisher.send(event)
            }
        }
    }
    
    /// Changes the page and then sends a navigation event, handling modal dismissal.
    /// Phase 1: Change page so new page loads (tables/collections)
    /// Phase 2: Send full event to open target table/collection and row
    private func changePageAndNavigate(pageId: String, event: NavigationTarget) {
        let execute = { [self] in
            self.currentPageID = pageId
            
            // After new page renders, open table/collection and row
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.navigationPublisher.send(event)
            }
        }

        if Thread.isMainThread {
            execute()
        } else {
            DispatchQueue.main.async {
                execute()
            }
        }
    }
    
    /// Runs navigation (page change + event or event only) and returns status.
    private func executeNavigation(pageId: String, event: NavigationTarget, status: NavigationStatus, pageChanged: Bool) -> NavigationStatus {
        if pageChanged {
            changePageAndNavigate(pageId: pageId, event: event)
        } else {
            sendNavigation(event)
        }
        return status
    }
    
    /// Navigates to a specific page, field, or row
    /// - Parameters:
    ///   - path: Navigation path in format "pageId" or "pageId/fieldPositionId" or "pageId/fieldPositionId/rowId"
    ///   - gotoConfig: Configuration for navigation behavior
    public func goto(_ path: String, gotoConfig: GotoConfig = GotoConfig()) -> NavigationStatus {
        let components = path.split(separator: "/").map(String.init)
        
        guard !components.isEmpty else {
            Log("Navigation path is empty", type: .error)
            return .failure
        }
        
        let pageId = components[0]
        let fieldPositionId = components.count > 1 ? components[1] : nil
        let rowId = components.count > 2 ? components[2] : nil
        
        guard pagesForCurrentView.contains(where: { $0.id == pageId }) else {
            Log("Page with id \(pageId) not found", type: .warning)
            return .failure
        }
        
        guard shouldShow(pageID: pageId) else {
            Log("Page with id \(pageId) is hidden by conditional logic", type: .warning)
            return .failure
        }
        
        let pageChanged = currentPageID != pageId
        let event: NavigationTarget
        var status: NavigationStatus = .success
        
        if let fieldPositionId = fieldPositionId {
            let page = pagesForCurrentView.first(where: { $0.id == pageId })
            let fieldPosition = page?.fieldPositions?.first(where: { $0.id == fieldPositionId })
            
            guard let fieldPosition = fieldPosition else {
                Log("Field position with id \(fieldPositionId) not found on page \(pageId)", type: .warning)
                return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId), status: .failure, pageChanged: pageChanged)
            }
            
            guard let fieldID = fieldPosition.field, shouldShow(fieldID: fieldID) else {
                Log("Field position \(fieldPositionId) is hidden by conditional logic", type: .warning)
                return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId), status: .failure, pageChanged: pageChanged)
            }
            
            if let rowId = rowId {
                guard let field = field(fieldID: fieldID) else {
                    Log("Field with id \(fieldID) not found", type: .warning)
                    return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, fieldID: fieldID), status: .failure, pageChanged: pageChanged)
                }
                
                guard field.fieldType == .table || field.fieldType == .collection else {
                    Log("Field \(fieldID) is not a table or collection field", type: .warning)
                    return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, fieldID: fieldID), status: .failure, pageChanged: pageChanged)
                }
                status = rowExistsInField(fieldID: fieldID, rowId: rowId) ? .success : .failure
                event = NavigationTarget(pageId: pageId, fieldID: fieldID, rowId: rowId, openRowForm: gotoConfig.open)
            } else {
                event = NavigationTarget(pageId: pageId, fieldID: fieldID)
            }
        } else {
            event = NavigationTarget(pageId: pageId)
        }
        
        return executeNavigation(pageId: pageId, event: event, status: status, pageChanged: pageChanged)
    }
    
    /// Handles page change events, firing page.blur and page.focus callbacks
    private func handlePageChange(from previousPageId: String, to newPageId: String) {
        // Don't fire if the page didn't actually change
        guard previousPageId != newPageId else {
            return
        }
        
        // Fire blur event for previous page
        if let previousPage = firstPageFor(currentPageID: previousPageId) {
            onPageBlur(page: previousPage)
        }
        
        // Fire focus event for new page
        if let newPage = firstPageFor(currentPageID: newPageId) {
            onPageFocus(page: newPage)
        }
    }
    
    /// Fires page focus event
    private func onPageFocus(page: Page) {
        let pageEvent = PageEvent(type: "page.focus", page: page)
        self.onFocus(event: pageEvent)
    }
    
    /// Fires page blur event
    private func onPageBlur(page: Page) {
        let pageEvent = PageEvent(type: "page.blur", page: page)
        self.onBlur(event: pageEvent)
    }
}
