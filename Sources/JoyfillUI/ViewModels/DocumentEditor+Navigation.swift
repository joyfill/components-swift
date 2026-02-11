//
//  DocumentEditor+Navigation.swift
//  JoyfillUI
//
//  Goto navigation, row existence checks, and navigation types.
//

import Foundation
import JoyfillModel
import Combine

// MARK: - Navigation Types

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

// MARK: - Navigation (goto, row existence, execute)

extension DocumentEditor {

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
}
