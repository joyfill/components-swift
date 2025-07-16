//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService
import Joyfill

class ChangeManager: ObservableObject {
    private let apiService: APIService
    var showScan: (@escaping (ValueUnion) -> Void) -> Void
    private let showImagePicker:  (@escaping ([String]) -> Void) -> Void
    
    // Published property to display changelogs on screen
    @Published var displayedChangelogs: [String] = []
    @Published var showChangelogView: Bool = false

    init(apiService: APIService, showImagePicker:  @escaping(@escaping ([String]) -> Void) -> Void, showScan: @escaping (@escaping (ValueUnion) -> Void) -> Void) {
        self.showImagePicker = showImagePicker
        self.showScan = showScan
        self.apiService = apiService
    }

    func saveJoyDoc(document: JoyDoc) {
        guard let identifier = document.identifier else {
            return
        }
        apiService.updateDocument(identifier: identifier, document: document) { result in
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
        apiService.updateDocument(identifier: identifier, changeLogs: changeLogs) { result in
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
//            DispatchQueue.main.async {
//                self.validationMessage = "❌ Schema Error: \(schemaError.code) - \(schemaError.message)"
//            }
        case .schemaVersionError(let versionError):
            print("❌ Schema Error: \(versionError)")

//            DispatchQueue.main.async {
//                self.validationMessage = "❌ Version Error: \(versionError.code) - \(versionError.message)"
//            }
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
            self.displayedChangelogs.append("[\(timestamp)] Upload: \(event.fieldEvent.fieldID)")
        }
        showImagePicker(event.uploadHandler)
    }
    
    func onCapture(event: CaptureEvent) {
        print(">>>>>>>>onCapture", event.fieldEvent.fieldID)
        let timestamp = DateFormatter.timestamp.string(from: Date())
        DispatchQueue.main.async {
            self.displayedChangelogs.append("[\(timestamp)] Capture: \(event.fieldEvent.fieldID)")
        }
        showScan(event.captureHandler)
    }
}

extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
