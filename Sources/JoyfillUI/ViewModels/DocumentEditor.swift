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
        self.validationHandler = ValidationHandler(documentEditor: self)
        self.conditionalLogicHandler = ConditionalLogicHandler(documentEditor: self)
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

    func refreshDependent(for fieldID: String) {
        let refreshFields = conditionalLogicHandler.fieldsNeedsToBeRefreshed(fieldID: fieldID)
        refreshFields.forEach(refreshField(fieldId:))
    }

    func updateField(event: FieldChangeEvent) {
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
            refreshDependent(for: event.fieldID)
        }
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

    func fieldIndexMapValue(pageID: String, index: Int) -> String {
        return "\(pageID)|\(index)"
    }

    func mapWebViewToMobileView(fieldPositions: [FieldPosition]) -> [FieldPosition] {
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

    func refreshField(fieldId: String) {
        let pageIDIndexValue = fieldIndexMap[fieldId]!
        let (pageID, index) = pageIDAndIndex(key: pageIDIndexValue)
        pageFieldModels[pageID]!.fields[index].refreshID = UUID()
    }

    private func valueElements(fieldID: String) -> [ValueElement]? {
        return field(fieldID: fieldID)?.valueToValueElements
    }
}
