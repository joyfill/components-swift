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
    var fieldMap = [String: JoyDocField]() {
        didSet {
            document.fields = allFields
        }
    }

    @Published var pageFieldModels = [String: PageModel]()
    var fieldPositionMap = [String: FieldPosition]()
    var fieldIndexMap = [String: String]()
    var fieldConditionalDependencyMap = [String: [String]]()
    var showFieldMap = [String: Bool]()
    var events: FormChangeEvent?

    private var validationHandler: ValidationHandler!

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
        self.validationHandler = ValidationHandler(documentEditor: self)
    }

    public func validate() -> Validation {
        return validationHandler.validate()
    }

    public func shouldShow(fieldID: String?) -> Bool {
        guard let fieldID = fieldID else { return true }
        return showFieldMap[fieldID] ?? true
    }

    public func shouldShow(pageID: String?) -> Bool {
        guard let pageID = pageID else { return true }
        guard let page = document.pagesForCurrentView.first(where: { $0.id == pageID }) else { return true }
        return shouldShow(page: page)
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

    func applyConditionalLogicAndRefreshUI(event: FieldChangeEvent) {
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
