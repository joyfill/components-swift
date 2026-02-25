import Foundation
import SwiftUI
import JoyfillModel
import Combine

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
    public let columnId: String?
    public let focus: Bool
    
    public init(pageId: String, fieldID: String? = nil, rowId: String? = nil, openRowForm: Bool = false, columnId: String? = nil, focus: Bool = false) {
        self.pageId = pageId
        self.fieldID = fieldID
        self.rowId = rowId
        self.openRowForm = openRowForm
        self.columnId = columnId
        self.focus = focus
    }
}

/// Configuration options for the goto navigation method
public struct GotoConfig {
    /// Whether to automatically open the row form modal for table/collection rows
    public let open: Bool
    /// Whether to auto-focus the target field or cell (opens keyboard for text/number/barcode)
    public let focus: Bool
    
    public init(open: Bool = false, focus: Bool = false) {
        self.open = open
        self.focus = focus
    }
}

struct NavigationIntent {
    var rowFormOpenedViaGoto: Bool = false
    var scrollToColumnId: String?
    var focusColumnId: String?
    
    static let none = NavigationIntent()
}

// MARK: - Environment Keys

private struct NavigationFocusFieldIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var navigationFocusFieldId: String? {
        get { self[NavigationFocusFieldIdKey.self] }
        set { self[NavigationFocusFieldIdKey.self] = newValue }
    }
}

private struct NavigationFocusColumnIdKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var navigationFocusColumnId: String? {
        get { self[NavigationFocusColumnIdKey.self] }
        set { self[NavigationFocusColumnIdKey.self] = newValue }
    }
}

// MARK: - DocumentEditor Navigation

extension DocumentEditor {
    func sendNavigation(_ event: NavigationTarget) {
        if Thread.isMainThread {
            navigationPublisher.send(event)
        } else {
            DispatchQueue.main.async {
                self.navigationPublisher.send(event)
            }
        }
    }
    
    func changePageAndNavigate(pageId: String, event: NavigationTarget) {
        let execute = { [self] in
            self.currentPageID = pageId
            
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
    
    func executeNavigation(pageId: String, event: NavigationTarget, status: NavigationStatus, pageChanged: Bool) -> NavigationStatus {
        if pageChanged {
            changePageAndNavigate(pageId: pageId, event: event)
        } else {
            sendNavigation(event)
        }
        return status
    }
    
    /// Navigates to a specific page, field, row, or cell
    /// - Parameters:
    ///   - path: Navigation path in format "pageId", "pageId/fieldPositionId", "pageId/fieldPositionId/rowId", or "pageId/fieldPositionId/rowId/columnId"
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
        let columnId = components.count > 3 ? components[3] : nil
        
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
                return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, focus: gotoConfig.focus), status: .failure, pageChanged: pageChanged)
            }
            
            guard let fieldID = fieldPosition.field, shouldShow(fieldID: fieldID) else {
                Log("Field position \(fieldPositionId) is hidden by conditional logic", type: .warning)
                return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, focus: gotoConfig.focus), status: .failure, pageChanged: pageChanged)
            }
            
            if let rowId = rowId {
                guard let field = field(fieldID: fieldID) else {
                    Log("Field with id \(fieldID) not found", type: .warning)
                    return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, fieldID: fieldID, focus: gotoConfig.focus), status: .failure, pageChanged: pageChanged)
                }
                
                guard field.fieldType == .table || field.fieldType == .collection else {
                    Log("Field \(fieldID) is not a table or collection field", type: .warning)
                    return executeNavigation(pageId: pageId, event: NavigationTarget(pageId: pageId, fieldID: fieldID, focus: gotoConfig.focus), status: .failure, pageChanged: pageChanged)
                }
                let rowExists = rowExistsInField(fieldID: fieldID, rowId: rowId)
                var validColumnId: String? = nil
                var columnValid = true

                if rowExists, let columnId = columnId, !columnId.isEmpty {
                    if columnExistsInField(field, columnId: columnId) {
                        validColumnId = columnId
                    } else {
                        columnValid = false
                    }
                }

                status = (rowExists && columnValid) ? .success : .failure
                event = NavigationTarget(pageId: pageId, fieldID: fieldID, rowId: rowId, openRowForm: gotoConfig.open, columnId: validColumnId, focus: gotoConfig.focus)
            } else {
                event = NavigationTarget(pageId: pageId, fieldID: fieldID, focus: gotoConfig.focus)
            }
        } else {
            event = NavigationTarget(pageId: pageId, focus: gotoConfig.focus)
        }
        
        return executeNavigation(pageId: pageId, event: event, status: status, pageChanged: pageChanged)
    }
    
    func rowExistsInField(fieldID: String, rowId: String) -> Bool {
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
    
    func columnExistsInField(_ field: JoyDocField, columnId: String) -> Bool {
        guard let fieldID = field.id else { return false }
        switch field.fieldType {
        case .table:
            guard field.tableColumns?.contains(where: { $0.id == columnId }) == true else { return false }
            return shouldShowColumn(columnID: columnId, fieldID: fieldID)
        case .collection:
            guard let schema = field.schema else { return false }
            guard let schemaKey = schema.first(where: { $0.value.tableColumns?.contains(where: { $0.id == columnId }) == true })?.key else { return false }
            return shouldShowColumn(columnID: columnId, fieldID: fieldID, schemaKey: schemaKey)
        default:
            return false
        }
    }
    
    func rowExistsInValueElements(_ elements: [ValueElement], rowId: String) -> Bool {
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
    
    func handlePageChange(from previousPageId: String, to newPageId: String) {
        guard previousPageId != newPageId else {
            return
        }
        
        if let previousPage = firstPageFor(currentPageID: previousPageId) {
            onPageBlur(page: previousPage)
        }
        
        if let newPage = firstPageFor(currentPageID: newPageId) {
            onPageFocus(page: newPage)
        }
    }
    
    func onPageFocus(page: Page) {
        let pageEvent = PageEvent(type: "page.focus", page: page)
        self.onFocus(event: pageEvent)
    }
    
    func onPageBlur(page: Page) {
        let pageEvent = PageEvent(type: "page.blur", page: page)
        self.onBlur(event: pageEvent)
    }
}
