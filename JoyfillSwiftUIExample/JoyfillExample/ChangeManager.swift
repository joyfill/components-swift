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
        let fieldEvent = formatFieldIdentifier(event.fieldEvent)
        let target = event.target ?? "nil"
        let multi = event.multi
        let schemaId = event.schemaId ?? "nil"
        let parentPath = event.parentPath ?? "nil"
        let rowIds = event.rowIds?.description ?? "nil"
        let columnId = event.columnId ?? "nil"
        
        return "UploadEvent(fieldEvent: \(fieldEvent), target: \(target), multi: \(multi), schemaId: \(schemaId), parentPath: \(parentPath), rowIds: \(rowIds), columnId: \(columnId), uploadHandler: (Function))"
    }
    
    private func formatCaptureEvent(_ event: CaptureEvent) -> String {
        let fieldEvent = formatFieldIdentifier(event.fieldEvent)
        let target = event.target ?? "nil"
        let schemaId = event.schemaId ?? "nil"
        let parentPath = event.parentPath ?? "nil"
        let rowIds = event.rowIds?.description ?? "nil"
        let columnId = event.columnId ?? "nil"
        
        return "CaptureEvent(fieldEvent: \(fieldEvent), target: \(target), schemaId: \(schemaId), parentPath: \(parentPath), rowIds: \(rowIds), columnId: \(columnId), captureHandler: (Function))"
    }
    
    private func formatFieldIdentifier(_ fieldEvent: FieldIdentifier) -> String {
        let id = fieldEvent._id ?? "nil"
        let identifier = fieldEvent.identifier ?? "nil"
        let fieldID = fieldEvent.fieldID
        let fieldIdentifier = fieldEvent.fieldIdentifier ?? "nil"
        let pageID = fieldEvent.pageID ?? "nil"
        let fileID = fieldEvent.fileID ?? "nil"
        let fieldPositionId = fieldEvent.fieldPositionId ?? "nil"
        
        return "Joyfill.FieldIdentifier(_id: \(id), identifier: \(identifier), fieldID: \"\(fieldID)\", fieldIdentifier: \(fieldIdentifier), pageID: \(pageID), fileID: \(fileID), fieldPositionId: \(fieldPositionId))"
    }
}

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
