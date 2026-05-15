//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService
import Joyfill

/// Kinds of events surfaced in the test changelog view.
enum ChangelogKind: String {
    case change
    case focus
    case blur
    case pageFocus
    case pageBlur
    case upload
    case capture

    var label: String {
        switch self {
        case .change:    return "Change"
        case .focus:     return "Focus"
        case .blur:      return "Blur"
        case .pageFocus: return "Page Focus"
        case .pageBlur:  return "Page Blur"
        case .upload:    return "Upload"
        case .capture:   return "Capture"
        }
    }
}

/// One entry per event callback. A single `onChange` invocation — including
/// a bulk edit that produces many `Change` rows — collapses to ONE entry.
struct ChangelogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let kind: ChangelogKind
    /// Structured payload entries displayed in the expanded view (each item is
    /// rendered as its own row card). For `change`, this is the list of changes.
    /// For single events (focus/blur/upload/capture), it has one item.
    let items: [[String: Any]]

    var count: Int { items.count }

    /// Compact one-line summary shown on the collapsed card.
    var summary: String {
        switch kind {
        case .change:
            let targets = items.compactMap { $0["target"] as? String }
            let uniqueTargets = Array(Set(targets)).sorted()
            let fields = Array(Set(items.compactMap { $0["fieldId"] as? String })).sorted()
            let rowsCount = items.reduce(0) { acc, item in
                if let inner = item["change"] as? [String: Any] {
                    if let rowIds = inner["rowIds"] as? [String] { return acc + rowIds.count }
                    if inner["rowId"] != nil { return acc + 1 }
                }
                return acc
            }
            var parts: [String] = []
            if !uniqueTargets.isEmpty { parts.append(uniqueTargets.joined(separator: ", ")) }
            if !fields.isEmpty { parts.append("field: \(fields.first!)\(fields.count > 1 ? " (+\(fields.count - 1))" : "")") }
            if rowsCount > 0 { parts.append("\(rowsCount) row\(rowsCount == 1 ? "" : "s")") }
            return parts.joined(separator: " · ")
        default:
            let first = items.first ?? [:]
            if let fieldID = first["fieldID"] as? String { return "field: \(fieldID)" }
            if let pageDict = first["page"] as? [String: Any], let pageName = pageDict["name"] as? String {
                return "page: \(pageName)"
            }
            return ""
        }
    }

    /// Multi-line plain-text dump used by Copy / Export.
    var copyText: String {
        let ts = DateFormatter.timestamp.string(from: timestamp)
        let header = "[\(ts)] \(kind.label)\(count > 1 ? " (\(count))" : "")"
        let body = items.enumerated().map { idx, item -> String in
            let prefix = count > 1 ? "  #\(idx + 1) " : "  "
            let json = (try? JSONSerialization.data(withJSONObject: item, options: [.prettyPrinted, .sortedKeys]))
                .flatMap { String(data: $0, encoding: .utf8) } ?? "<unserializable>"
            return prefix + json.replacingOccurrences(of: "\n", with: "\n  ")
        }.joined(separator: "\n")
        return header + "\n" + body
    }
}

class ChangeManager: ObservableObject {
    private let apiService: APIService?
    var showScan: (@escaping (ValueUnion) -> Void) -> Void
    private let showImagePicker:  (@escaping ([String]) -> Void) -> Void

    /// Structured entries — one per event callback. Bulk `onChange` (many
    /// changes in one call) shows up as a single entry with `items.count > 1`.
    @Published var displayedEntries: [ChangelogEntry] = []
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

    private func append(_ entry: ChangelogEntry) {
        DispatchQueue.main.async {
            self.displayedEntries.append(entry)
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
        case .decoratorError(let decoratorError):
            print("❌ Decorator Error: \(decoratorError.message)")
        }
        print("Error occurred: \(error)")
    }

    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        if let firstChange = changes.first {
            print(">>>>>>>>onChange", firstChange.fieldId ?? "", "count:", changes.count)
        } else {
            print(">>>>>>>>onChange: no changes")
        }

        let items = changes.map { $0.dictionary }
        append(ChangelogEntry(timestamp: Date(), kind: .change, items: items))

        let changeLogs = ["changelogs": items]
        if let identifier = document.identifier, let apiService = apiService, apiService.hasValidToken {
            updateDocument(identifier: identifier, changeLogs: changeLogs)
        }
    }

    func onFocus(event: Event) {
        if let fieldEvent = event.fieldEvent {
            let fieldDict = createFieldIdentifierDict(fieldEvent)
            print(">>>>>>>>onFocus", formatDictionary(fieldDict))
            append(ChangelogEntry(timestamp: Date(), kind: .focus, items: [fieldDict]))
        } else if let pageEvent = event.pageEvent {
            print(">>>>>>>>onPageFocus", pageEvent.type, pageEvent.page.id ?? "unknown", pageEvent.page.name ?? "Untitled")
            var eventDict: [String: Any] = [:]
            eventDict["type"] = pageEvent.type
            eventDict["page"] = pageEvent.page.dictionary
            append(ChangelogEntry(timestamp: Date(), kind: .pageFocus, items: [eventDict]))
        }
    }

    func onBlur(event: Event) {
        if let fieldEvent = event.fieldEvent {
            let fieldDict = createFieldIdentifierDict(fieldEvent)
            print(">>>>>>>>onBlur", formatDictionary(fieldDict))
            append(ChangelogEntry(timestamp: Date(), kind: .blur, items: [fieldDict]))
        } else if let pageEvent = event.pageEvent {
            print(">>>>>>>>onPageBlur", pageEvent.type, pageEvent.page.id ?? "unknown", pageEvent.page.name ?? "Untitled")
            var eventDict: [String: Any] = [:]
            eventDict["type"] = pageEvent.type
            eventDict["page"] = pageEvent.page.dictionary
            append(ChangelogEntry(timestamp: Date(), kind: .pageBlur, items: [eventDict]))
        }
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.fieldEvent.fieldID)
        append(ChangelogEntry(timestamp: Date(), kind: .upload, items: [uploadEventDict(event)]))
        showImagePicker(event.uploadHandler)
    }

    func onCapture(event: CaptureEvent) {
        print(">>>>>>>>onCapture", event.fieldEvent.fieldID)
        append(ChangelogEntry(timestamp: Date(), kind: .capture, items: [captureEventDict(event)]))
        showScan(event.captureHandler)
    }

    // MARK: - Event Formatting Helpers

    private func uploadEventDict(_ event: UploadEvent) -> [String: Any] {
        var eventDict: [String: Any] = [:]
        eventDict["fieldEvent"] = createFieldIdentifierDict(event.fieldEvent)
        if let target = event.target { eventDict["target"] = target }
        eventDict["multi"] = event.multi
        if let schemaId = event.schemaId { eventDict["schemaId"] = schemaId }
        if let parentPath = event.parentPath, !parentPath.isEmpty { eventDict["parentPath"] = parentPath }
        if let rowIds = event.rowIds, !rowIds.isEmpty { eventDict["rowIds"] = rowIds }
        if let columnId = event.columnId { eventDict["columnId"] = columnId }
        return eventDict
    }

    private func captureEventDict(_ event: CaptureEvent) -> [String: Any] {
        var eventDict: [String: Any] = [:]
        eventDict["fieldEvent"] = createFieldIdentifierDict(event.fieldEvent)
        if let target = event.target { eventDict["target"] = target }
        if let schemaId = event.schemaId { eventDict["schemaId"] = schemaId }
        if let parentPath = event.parentPath, !parentPath.isEmpty { eventDict["parentPath"] = parentPath }
        if let rowIds = event.rowIds, !rowIds.isEmpty { eventDict["rowIds"] = rowIds }
        if let columnId = event.columnId { eventDict["columnId"] = columnId }
        return eventDict
    }

    private func createFieldIdentifierDict(_ fieldEvent: FieldIdentifier) -> [String: Any] {
        var fieldDict: [String: Any] = [:]
        fieldDict["fieldID"] = fieldEvent.fieldID
        if let id = fieldEvent._id { fieldDict["_id"] = id }
        if let identifier = fieldEvent.identifier { fieldDict["identifier"] = identifier }
        if let fieldIdentifier = fieldEvent.fieldIdentifier { fieldDict["fieldIdentifier"] = fieldIdentifier }
        if let pageID = fieldEvent.pageID { fieldDict["pageID"] = pageID }
        if let fileID = fieldEvent.fileID { fieldDict["fileID"] = fileID }
        if let fieldPositionId = fieldEvent.fieldPositionId { fieldDict["fieldPositionId"] = fieldPositionId }
        if let type = fieldEvent.type { fieldDict["type"] = type }
        if let target = fieldEvent.target { fieldDict["target"] = target }
        if let rowIDs = fieldEvent.rowIds, !rowIDs.isEmpty { fieldDict["rowIds"] = rowIDs }
        if let parentPath = fieldEvent.parentPath { fieldDict["parentPath"] = parentPath }
        if let columnId = fieldEvent.columnId { fieldDict["columnId"] = columnId }
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
