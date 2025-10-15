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

/// Weak wrapper that stores a `DocumentEditorDelegate` without creating a retain cycle.
public class WeakDocumentEditorDelegate {
    weak var value: DocumentEditorDelegate?
    init(_ value: DocumentEditorDelegate) { self.value = value }
}

/// Delegate hooks that allow field-specific views to respond to row-level edits.
public protocol DocumentEditorDelegate: AnyObject {
    /// Applies an in-place row mutation, typically after inline editing.
    func applyRowEditChanges(change: Change)
    /// Inserts a row described by the provided change payload.
    func insertRow(for change: Change)
    /// Removes the row referenced in the change payload.
    func deleteRow(for change: Change)
    /// Reorders the row referenced in the change payload.
    func moveRow(for change: Change)
}

/// Observable controller that drives Joyfill document rendering, validation,
/// conditional logic, and formula evaluation.
public class DocumentEditor: ObservableObject {
    /// The underlying JoyDoc that is being displayed and mutated.
    private(set) public var document: JoyDoc
    
    /// The validation error generated during initialisation, if schema validation failed.
    public var schemaError: SchemaValidationError?
    
    /// The identifier of the page currently selected in the editor.
    @Published public var currentPageID: String
    @Published var currentPageOrder: [String] = []
    private var isCollectionFieldEnabled: Bool = false

    /// Determines whether the editor operates in fill or read-only mode.
    public var mode: Mode = .fill
    
    /// Indicates whether duplicate-page actions should be exposed to the UI.
    public var isPageDuplicateEnabled: Bool = true
    
    /// Indicates whether the page navigation UI should be displayed.
    public var showPageNavigationView: Bool = true
    
    /// Weak delegate registry used by table and collection views to receive row updates.
    public var delegateMap: [String: WeakDocumentEditorDelegate] = [:]
    
    var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }
    
    @Published var pageFieldModels = [String: PageModel]()
    private var fieldPositionMap = [String: FieldPosition]()
    private var fieldIndexMap = [String: String]()
    
    /// Event callbacks that notify hosts about user interaction.
    public var events: FormChangeEvent?
    let backgroundQueue = DispatchQueue(label: "documentEditor.background", qos: .userInitiated)
    
    private var validationHandler: ValidationHandler!
    var conditionalLogicHandler: ConditionalLogicHandler!
    private var JoyfillDocContext: JoyfillDocContext!

    /// Creates a `DocumentEditor` with the provided document and configuration.
    /// - Parameters:
    ///   - document: The JoyDoc to render.
    ///   - mode: Interaction mode (`fill` or `readonly`).
    ///   - events: Optional change/focus/upload callbacks.
    ///   - pageID: Optional initial page identifier to display.
    ///   - navigation: When `false`, hides page navigation controls.
    ///   - isPageDuplicateEnabled: Enables duplicate-page controls when `mode` is `.fill`.
    ///   - validateSchema: Set to `false` to skip JSON schema validation.
    ///   - license: Optional license token used to unlock feature flags.
    public init(document: JoyDoc,
                mode: Mode = .fill,
                events: FormChangeEvent? = nil,
                pageID: String? = nil,
                navigation: Bool = true,
                isPageDuplicateEnabled: Bool = false,
                validateSchema: Bool = true,
                license: String? = nil) {
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
                self.showPageNavigationView = navigation
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
        self.showPageNavigationView = navigation
        self.currentPageID = ""
        self.events = events
        // Set feature flags from license
        self.isCollectionFieldEnabled = LicenseValidator.isCollectionEnabled(licenseToken: license)
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
    
    /// Registers a delegate that should receive row change notifications for a specific field.
    /// - Parameters:
    ///   - delegate: The delegate instance to register.
    ///   - fieldID: The identifier of the table or collection field.
    public func registerDelegate(_ delegate: DocumentEditorDelegate, for fieldID: String) {
        delegateMap[fieldID] = WeakDocumentEditorDelegate(delegate)
    }
    
    /// Rebuilds the field map from the underlying document.
    public func updateFieldMap() {
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }
    }
    
    /// Rebuilds the field position map that powers layout and field lookup.
    public func updateFieldPositionMap() {
        mapWebViewToMobileViewIfNeeded(fieldPositions: document.fieldPositionsForCurrentView, isMobileViewActive: isMobileViewActive).forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
        }
    }
    
    /// Validates all visible fields and returns a structured result.
    /// - Returns: A `Validation` summary containing per-field validity.
    public func validate() -> Validation {
        return validationHandler.validate()
    }
    
    /// Determines whether a field should be visible based on conditional logic.
    /// - Parameter fieldID: The identifier of the field to evaluate.
    /// - Returns: `true` when the field passes conditional checks.
    public func shouldShow(fieldID: String?) -> Bool {
        return conditionalLogicHandler.shouldShow(fieldID: fieldID)
    }
    
    /// Determines whether a page should be visible based on conditional logic.
    /// - Parameter pageID: The identifier of the page to evaluate.
    /// - Returns: `true` when the page passes conditional checks.
    public func shouldShow(pageID: String?) -> Bool {
        return conditionalLogicHandler.shouldShow(pageID: pageID)
    }
    
    /// Determines whether the supplied page model should be visible.
    /// - Parameter page: The page to evaluate.
    /// - Returns: `true` when the page passes conditional checks.
    public func shouldShow(page: Page?) -> Bool {
        return conditionalLogicHandler.shouldShow(page: page)
    }
    
    /// Determines whether a nested schema segment within a collection field should be displayed.
    /// - Parameters:
    ///   - collectionFieldID: Identifier of the parent collection field.
    ///   - rowSchemaID: The row/schema composite identifier to evaluate.
    /// - Returns: `true` when the schema segment should be rendered.
    public func shouldShowSchema(for collectionFieldID: String, rowSchemaID: RowSchemaID) -> Bool {
        return conditionalLogicHandler.shouldShowSchema(for: collectionFieldID, rowSchemaID: rowSchemaID)
    }
    
    /// Applies changelog entries and notifies delegates when fields were mutated externally.
    /// - Parameter changes: The set of change records received from the host application.
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
            DispatchQueue.main.async(execute: {
                self.delegateMap[fieldID]?.value?.applyRowEditChanges(change: change)
                self.refreshField(fieldId: fieldID)
                self.refreshDependent(for: fieldID)
            })
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
            delegateMap[fieldID]?.value?.insertRow(for: change)
            refreshField(fieldId: fieldID)
            refreshDependent(for: fieldID)
        default:
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
            refreshField(fieldId: fieldID)
            refreshDependent(for: fieldID)
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
            delegateMap[fieldID]?.value?.moveRow(for: change)
            refreshField(fieldId: fieldID)
            refreshDependent(for: fieldID)
        default:
            break
        }
    }
    
    private func handleFieldUpdate(for change: Change) {
        guard let fieldID = change.fieldId else {
            logChangeError(for: change)
            return
        }
        guard let value = change.change?["value"] as? Any,
              let valueUnion = ValueUnion(value: value) else {
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
    /// Convenience accessor for `document.id`.
    public var documentID: String? {
        document.id
    }
    
    /// Convenience accessor for `document.identifier`.
    public var documentIdentifier: String? {
        document.identifier
    }
    
    /// The files associated with the current document.
    public var files: [File] {
        document.files
    }
    
    /// Pages that should be displayed for the current view context (web vs. mobile).
    public var pagesForCurrentView: [Page] {
        document.pagesForCurrentView
    }
    
    /// Updates the cached field entry for a mutated field.
    /// - Parameter field: The field that should replace the cached value.
    public func updatefield(field: JoyDocField?) {
        guard let fieldID = field?.id else { return }
        fieldMap[fieldID] = field
    }
    
    /// Retrieves the cached field for the supplied identifier.
    /// - Parameter fieldID: Identifier of the requested field.
    /// - Returns: The matching `JoyDocField`, if available.
    public func field(fieldID: String?) -> JoyDocField? {
        guard let fieldID = fieldID else { return nil }
        return fieldMap[fieldID]
    }
    
    /// All fields currently loaded by the editor.
    public var allFields: [JoyDocField] {
        return fieldMap.map { $1 }
    }
    
    /// All field positions currently loaded by the editor.
    public var allFieldPositions: [FieldPosition] {
        return fieldPositionMap.map { $1 }
    }
    
    /// The number of cached fields.
    public var fieldsCount: Int {
        return fieldMap.count
    }
    
    /// Retrieves the cached field position for the supplied identifier.
    /// - Parameter fieldID: Identifier of the requested field.
    public func fieldPosition(fieldID: String?) -> FieldPosition? {
        guard let fieldID = fieldID else { return nil }
        return fieldPositionMap[fieldID]
    }
    
    /// The first page in the active file, if any.
    public var firstPage: Page? {
        let pages = document.pagesForCurrentView
        guard pages.count > 1 else {
            return pages.first
        }
        return pages.first(where: shouldShow)
    }
    
    /// Identifier of the first visible page, if any.
    public var firstPageId: String? {
        return self.firstPage?.id
    }
    
    /// Indicates whether the current document includes a dedicated mobile view.
    public var isMobileViewActive: Bool {
        return files.first?.views?.contains(where: { $0.type == "mobile" }) ?? false
    }
    
    /// Returns the first page matching the provided identifier that passes conditional logic.
    /// - Parameter currentPageID: The page identifier to search for.
    /// - Returns: The matching page or the first valid page if the identifier is hidden.
    public func firstValidPageFor(currentPageID: String) -> Page? {
        return document.pagesForCurrentView.first { currentPage in
            currentPage.id == currentPageID && shouldShow(page: currentPage)
        } ?? firstPage
    }
    
    /// Returns the first page with the provided identifier regardless of visibility.
    /// - Parameter currentPageID: The page identifier to search for.
    /// - Returns: The matching page, if present.
    public func firstPageFor(currentPageID: String) -> Page? {
        return document.pagesForCurrentView.first { currentPage in
            currentPage.id == currentPageID
        }
    }
    
    /// Builds a `FieldIdentifier` for the supplied field by inspecting page metadata.
    /// - Parameter fieldID: The field identifier used in the JoyDoc.
    /// - Returns: A populated `FieldIdentifier` describing page/file context.
    public func getFieldIdentifier(for fieldID: String) -> FieldIdentifier {
        let fileID = field(fieldID: fieldID)?.file

        for page in pagesForCurrentView {
            if let position = page.fieldPositions?.first(where: { $0.field == fieldID }) {
                return FieldIdentifier(fieldID: fieldID, pageID: page.id, fileID: fileID, fieldPositionId: position.id)
            }
        }

        return FieldIdentifier(fieldID: fieldID, fileID: fileID)
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
    
    /// Updates the cached field to reflect a change coming from the UI layer.
    /// - Parameters:
    ///   - event: The change payload containing the new value and optional chart metadata.
    ///   - fieldIdentifier: Context describing where the field resides.
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
            updatefield(field: field)
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
    
    /// Normalises field positions produced for the web renderer so they can be reused on mobile layouts.
    /// - Parameters:
    ///   - fieldPositions: Field positions sourced from the JoyDoc.
    ///   - isMobileViewActive: Pass `true` when the document already targets mobile layout.
    /// - Returns: A deduplicated, sorted list of field positions suitable for display.
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
    
    /// Duplicates the page identified by `pageID`, including its fields and conditional logic.
    /// - Parameter pageID: The identifier of the page to duplicate.
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
