//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService
import Joyfill

class ChangeManager: ObservableObject {
    private let apiService: APIService?
    var showScan: (@escaping (ValueUnion) -> Void) -> Void
    private let showImagePicker:  (@escaping ([String]) -> Void) -> Void
    
    // Published property to display changelogs on screen
    @Published var displayedChangelogs: [String] = []
    @Published var showChangelogView: Bool = false

    init(apiService: APIService? = nil, showImagePicker:  @escaping(@escaping ([String]) -> Void) -> Void, showScan: @escaping (@escaping (ValueUnion) -> Void) -> Void) {
        self.showImagePicker = showImagePicker
        self.showScan = showScan
        self.apiService = apiService
    }

    func saveJoyDoc(document: JoyDoc) {
        guard let identifier = document.identifier else {
            return
        }
        apiService?.updateDocument(identifier: identifier, document: document) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("success")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateDocument(identifier: String, changeLogs: [String: Any]) {
        apiService?.updateDocument(identifier: identifier, changeLogs: changeLogs) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    print("success:")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension ChangeManager: FormChangeEvent {
    func onError(error: Joyfill.JoyfillError) {
        switch error {
        case .schemaValidationError(let schemaError):
            print("❌ Schema Error: \(schemaError)")
        case .schemaVersionError(let versionError):
            print("❌ Schema Error: \(versionError)")
        }
        print("Error occurred: \(error)")
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        if let firstChange = changes.first {
            print(">>>>>>>>onChange", firstChange.fieldId ?? "")
        } else {
            print(">>>>>>>>onChange: no changes")
        }
        
        // Format changelogs for display
        let timestamp = DateFormatter.timestamp.string(from: Date())
        let changelogEntries = changes.map { change in
            let changeDict = change.dictionary
            let changeJson = try? JSONSerialization.data(withJSONObject: changeDict, options: .prettyPrinted)
            let changeString = changeJson.flatMap { String(data: $0, encoding: .utf8) } ?? "Invalid change data"
            return "[\(timestamp)] Change: \(changeString)"
        }
        
        DispatchQueue.main.async {
            self.displayedChangelogs.append(contentsOf: changelogEntries)
        }
        
        let changeLogs = ["changelogs": changes.map { $0.dictionary }]

        if let identifier = document.identifier {
            updateDocument(identifier: identifier, changeLogs: changeLogs)
        } else {
            print(">>>>>>>>onChange: document has no identifier")
        }
    }

    func onFocus(event: FieldIdentifier) {
        print(">>>>>>>>onFocus", event.fieldID)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        DispatchQueue.main.async {
            self.displayedChangelogs.append("[\(timestamp)] Focus: \(event.fieldID)")
        }
    }

    func onBlur(event: FieldIdentifier) {
        print(">>>>>>>>onBlur", event.fieldID)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        DispatchQueue.main.async {
            self.displayedChangelogs.append("[\(timestamp)] Blur: \(event.fieldID)")
        }
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.fieldEvent.fieldID)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        DispatchQueue.main.async {
            self.displayedChangelogs.append("[\(timestamp)] Upload: \(self.formatUploadEvent(event))")
        }
        showImagePicker(event.uploadHandler)
    }
    
    func onCapture(event: CaptureEvent) {
        print(">>>>>>>>onCapture", event.fieldEvent.fieldID)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        DispatchQueue.main.async {
            self.displayedChangelogs.append("[\(timestamp)] Capture: \(self.formatCaptureEvent(event))")
        }
        showScan(event.captureHandler)
    }
    
    // MARK: - Event Formatting Helpers
    
    private func formatUploadEvent(_ event: UploadEvent) -> String {
        var details: [String] = []
        
        // Add fieldEvent details
        details.append("fieldEvent: \(formatFieldIdentifier(event.fieldEvent))")
        
        // Add non-nil optional values
        if let target = event.target {
            details.append("target: \(target)")
        }
        
        details.append("multi: \(event.multi)")
        
        if let schemaId = event.schemaId {
            details.append("schemaId: \(schemaId)")
        }
        
        if let parentPath = event.parentPath, !parentPath.isEmpty {
            details.append("parentPath: \(parentPath)")
        }
        
        if let rowIds = event.rowIds, !rowIds.isEmpty {
            details.append("rowIds: \(rowIds)")
        }
        
        if let columnId = event.columnId {
            details.append("columnId: \(columnId)")
        }
        
        return "UploadEvent(\n   " + details.joined(separator: "\n   ") + "\n)"
    }
    
    private func formatCaptureEvent(_ event: CaptureEvent) -> String {
        var details: [String] = []
        
        // Add fieldEvent details
        details.append("fieldEvent: \(formatFieldIdentifier(event.fieldEvent))")
        
        // Add non-nil optional values
        if let target = event.target {
            details.append("target: \(target)")
        }
        
        if let schemaId = event.schemaId {
            details.append("schemaId: \(schemaId)")
        }
        
        if let parentPath = event.parentPath, !parentPath.isEmpty {
            details.append("parentPath: \(parentPath)")
        }
        
        if let rowIds = event.rowIds, !rowIds.isEmpty {
            details.append("rowIds: \(rowIds)")
        }
        
        if let columnId = event.columnId {
            details.append("columnId: \(columnId)")
        }
        
        return "CaptureEvent(\n   " + details.joined(separator: "\n   ") + "\n)"
    }
    
    private func formatFieldIdentifier(_ fieldEvent: FieldIdentifier) -> String {
        var fieldDetails: [String] = []
        
        // Always include fieldID (required)
        fieldDetails.append("fieldID: \(fieldEvent.fieldID)")
        
        // Add optional properties if they exist
        if let id = fieldEvent._id {
            fieldDetails.append("_id: \(id)")
        }
        
        if let identifier = fieldEvent.identifier {
            fieldDetails.append("identifier: \(identifier)")
        }
        
        if let fieldIdentifier = fieldEvent.fieldIdentifier {
            fieldDetails.append("fieldIdentifier: \(fieldIdentifier)")
        }
        
        if let pageID = fieldEvent.pageID {
            fieldDetails.append("pageID: \(pageID)")
        }
        
        if let fileID = fieldEvent.fileID {
            fieldDetails.append("fileID: \(fileID)")
        }
        
        if let fieldPositionId = fieldEvent.fieldPositionId {
            fieldDetails.append("fieldPositionId: \(fieldPositionId)")
        }
        
        return "FieldIdentifier(\n      " + fieldDetails.joined(separator: "\n      ") + "\n   )"
    }
    
}

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
