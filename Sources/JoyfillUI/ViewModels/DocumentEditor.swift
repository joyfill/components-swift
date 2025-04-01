//
//  File.swift
//
//
//  Created by Vishnu Dutt on 21/11/24.
//

import Foundation
import JoyfillModel

public class DocumentEditor: ObservableObject {
    private(set) public var document: JoyDoc
    @Published public var currentPageID: String

    public var mode: Mode
    public var showPageNavigationView: Bool

    var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }

    @Published var pageFieldModels = [String: PageModel]()
    private var fieldPositionMap = [String: FieldPosition]()
    private var fieldIndexMap = [String: String]()
    var events: FormChangeEvent?

    private var validationHandler: ValidationHandler!
    private var conditionalLogicHandler: ConditionalLogicHandler!

    public init(document: JoyDoc, mode: Mode = .fill, events: FormChangeEvent? = nil, pageID: String? = nil, navigation: Bool = true) {
        self.document = document
        self.mode = mode
        self.showPageNavigationView = navigation
        self.currentPageID = ""
        self.events = events
        document.fields.forEach { field in
            guard let fieldID = field.id else { return }
            self.fieldMap[fieldID] =  field
        }

        document.fieldPositionsForCurrentView.forEach { fieldPosition in
            guard let fieldID = fieldPosition.field else { return }
            self.fieldPositionMap[fieldID] =  fieldPosition
        }

        let fileID = files[0].id!
        for page in document.pagesForCurrentView {
            guard let pageID = page.id else { return }
            var fieldListModels = [FieldListModel]()

            let fieldPositions = mapWebViewToMobileView(fieldPositions: page.fieldPositions ?? [])
            for fieldPosition in fieldPositions {
                let fieldData = fieldMap[fieldPosition.field!]
                let fieldIdentifier = FieldIdentifier(fieldID: fieldPosition.field!, pageID: pageID, fileID: fileID)
                var dataModelType: FieldListModelType = .none
                let fieldEditMode: Mode = ((fieldData?.disabled == true) || (mode == .readonly) ? .readonly : .fill)

                var fieldHeaderModel = (fieldPosition.titleDisplay == nil || fieldPosition.titleDisplay != "none") ? FieldHeaderModel(title: fieldData?.title, required: fieldData?.required, tipDescription: fieldData?.tipDescription, tipTitle: fieldData?.tipTitle, tipVisible: fieldData?.tipVisible) : nil
                
                dataModelType = getFieldModel(fieldPosition: fieldPosition, fieldIdentifier: fieldIdentifier)
                fieldListModels.append(FieldListModel(fieldIdentifier: fieldIdentifier, fieldEditMode: fieldEditMode, model: dataModelType))
                let index = fieldListModels.count - 1
                fieldIndexMap[fieldPosition.field!] = fieldIndexMapValue(pageID: pageID, index: index)
            }
            pageFieldModels[pageID] = PageModel(id: pageID, fields: fieldListModels)
        }
        self.validationHandler = ValidationHandler(documentEditor: self)
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
        self.currentPageID = document.firstValidPageID(for: pageID, conditionalLogicHandler: conditionalLogicHandler)
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
    func updateSchemaVisibility(collectionFieldID: String, columnID: String, rowID: String) {
        conditionalLogicHandler.updateSchemaVisibility(collectionFieldID: collectionFieldID, columnID: columnID, rowID: rowID)
    }
    
    func updateShowCollectionSchemaMap(collectionFieldID: String, rowID: String) {
        conditionalLogicHandler.updateShowCollectionSchemaMap(collectionFieldID: collectionFieldID, rowID: rowID)
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

    private func mapWebViewToMobileView(fieldPositions: [FieldPosition]) -> [FieldPosition] {
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
    
    func refreshField(fieldId: String) {
        let pageIDIndexValue = fieldIndexMap[fieldId]!
        let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
        let fieldPosition = self.fieldPositionMap[fieldId]
        let identifier = pageFieldModels[pageID]!.fields[index].fieldIdentifier
        let dataModelType = getFieldModel(fieldPosition: fieldPosition!, fieldIdentifier: identifier)
        pageFieldModels[pageID]!.fields[index].model = dataModelType
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
        let fieldData = fieldMap[fieldPosition.field!]
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
            let model = DisplayTextDataModel(displayText: fieldData?.value?.text,
                                             fontSize: fieldPosition.fontSize,
                                             fontWeight: fieldPosition.fontWeight,
                                             fontColor: fieldPosition.fontColor,
                                             fontStyle: fieldPosition.fontStyle)
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
            let model = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                       mode: fieldEditMode,
                                       documentEditor: self,
                                       fieldIdentifier: fieldIdentifier)
            dataModelType = .table(model)
        case .collection:
            let model = TableDataModel(fieldHeaderModel: fieldHeaderModel,
                                       mode: fieldEditMode,
                                       documentEditor: self,
                                       fieldIdentifier: fieldIdentifier)
            dataModelType = .collection(model)
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
