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

        if let identifier = document.identifier, let apiService = apiService, apiService.hasValidToken {
            updateDocument(identifier: identifier, changeLogs: changeLogs)
        }
    }

    func onFocus(event: Event) {
        let timestamp = DateFormatter.timestamp.string(from: Date())
        
        if let fieldEvent = event.fieldEvent {
            let fieldDict = createFieldIdentifierDict(fieldEvent)
            print(">>>>>>>>onFocus", formatDictionary(fieldDict))
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: fieldDict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.displayedChangelogs.append("[\(timestamp)] Focus: \(jsonString)")
                }
            }
        } else if let pageEvent = event.pageEvent {
            print(">>>>>>>>onPageFocus", pageEvent.type, pageEvent.page.id ?? "unknown", pageEvent.page.name ?? "Untitled")
            
            // Create proper JSON string for the viewer
            var eventDict: [String: Any] = [:]
            eventDict["type"] = pageEvent.type
            eventDict["page"] = pageEvent.page.dictionary
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: eventDict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.displayedChangelogs.append("[\(timestamp)] PageEvent: \(jsonString)")
                }
            }
        }
    }

    func onBlur(event: Event) {
        let timestamp = DateFormatter.timestamp.string(from: Date())
        
        if let fieldEvent = event.fieldEvent {
            let fieldDict = createFieldIdentifierDict(fieldEvent)
            print(">>>>>>>>onBlur", formatDictionary(fieldDict))
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: fieldDict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.displayedChangelogs.append("[\(timestamp)] Blur: \(jsonString)")
                }
            }
        } else if let pageEvent = event.pageEvent {
            print(">>>>>>>>onPageBlur", pageEvent.type, pageEvent.page.id ?? "unknown", pageEvent.page.name ?? "Untitled")
            
            // Create proper JSON string for the viewer
            var eventDict: [String: Any] = [:]
            eventDict["type"] = pageEvent.type
            eventDict["page"] = pageEvent.page.dictionary
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: eventDict, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.displayedChangelogs.append("[\(timestamp)] PageEvent: \(jsonString)")
                }
            }
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
        var eventDict: [String: Any] = [:]
        
        // Add fieldEvent details as nested dictionary
        eventDict["fieldEvent"] = createFieldIdentifierDict(event.fieldEvent)
        
        // Add non-nil optional values
        if let target = event.target {
            eventDict["target"] = target
        }
        
        eventDict["multi"] = event.multi
        
        if let schemaId = event.schemaId {
            eventDict["schemaId"] = schemaId
        }
        
        if let parentPath = event.parentPath, !parentPath.isEmpty {
            eventDict["parentPath"] = parentPath
        }
        
        if let rowIds = event.rowIds, !rowIds.isEmpty {
            eventDict["rowIds"] = rowIds
        }
        
        if let columnId = event.columnId {
            eventDict["columnId"] = columnId
        }
        
        return "UploadEvent: \(formatDictionary(eventDict))"
    }
    
    private func formatCaptureEvent(_ event: CaptureEvent) -> String {
        var eventDict: [String: Any] = [:]
        
        // Add fieldEvent details as nested dictionary
        eventDict["fieldEvent"] = createFieldIdentifierDict(event.fieldEvent)
        
        // Add non-nil optional values
        if let target = event.target {
            eventDict["target"] = target
        }
        
        if let schemaId = event.schemaId {
            eventDict["schemaId"] = schemaId
        }
        
        if let parentPath = event.parentPath, !parentPath.isEmpty {
            eventDict["parentPath"] = parentPath
        }
        
        if let rowIds = event.rowIds, !rowIds.isEmpty {
            eventDict["rowIds"] = rowIds
        }
        
        if let columnId = event.columnId {
            eventDict["columnId"] = columnId
        }
        
        return "CaptureEvent: \(formatDictionary(eventDict))"
    }
    
    private func createFieldIdentifierDict(_ fieldEvent: FieldIdentifier) -> [String: Any] {
        var fieldDict: [String: Any] = [:]
        
        // Always include fieldID (required)
        fieldDict["fieldID"] = fieldEvent.fieldID
        
        // Add optional properties if they exist
        if let id = fieldEvent._id {
            fieldDict["_id"] = id
        }
        
        if let identifier = fieldEvent.identifier {
            fieldDict["identifier"] = identifier
        }
        
        if let fieldIdentifier = fieldEvent.fieldIdentifier {
            fieldDict["fieldIdentifier"] = fieldIdentifier
        }
        
        if let pageID = fieldEvent.pageID {
            fieldDict["pageID"] = pageID
        }
        
        if let fileID = fieldEvent.fileID {
            fieldDict["fileID"] = fileID
        }
        
        if let fieldPositionId = fieldEvent.fieldPositionId {
            fieldDict["fieldPositionId"] = fieldPositionId
        }
        
        return fieldDict
    }
    
    private func formatDictionary(_ dict: [String: Any], indent: String = "") -> String {
        var result = "{\n"
        let nextIndent = indent + "  "
        
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            result += "\(nextIndent)\"\(key)\": "
            
            if let nestedDict = value as? [String: Any] {
                result += formatDictionary(nestedDict, indent: nextIndent)
            } else if let stringValue = value as? String {
                result += "\"\(stringValue)\""
            } else if let arrayValue = value as? [String] {
                result += "[\(arrayValue.map { "\"\($0)\"" }.joined(separator: ", "))]"
            } else {
                result += "\(value)"
            }
            
            result += ",\n"
        }
        
        // Remove last comma and newline, then close bracket
        if result.hasSuffix(",\n") {
            result = String(result.dropLast(2)) + "\n"
        }
        result += "\(indent)}"
        
        return result
    }
    
}

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
