//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService

class ChangeManager {
    private let apiService: APIService
    private let showImagePicker: (([String]) -> Void) -> Void
    let showScan: (@escaping (ValueUnion) -> Void) -> Void

    init(apiService: APIService, showImagePicker: @escaping (([String]) -> Void) -> Void, showScan: @escaping (@escaping (ValueUnion) -> Void) -> Void) {
        self.showImagePicker = showImagePicker
        self.showScan = showScan
        self.apiService = apiService
    }

    func saveJoyDoc(document: JoyDoc) {
        apiService.updateDocument(identifier: document.identifier!, document: document) { result in
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
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
//        print(">>>>>>>>onChange", changes.first!.fieldId)
//        let changeLogs = ["changelogs": changes.map { $0.dictionary }]
//        updateDocument(identifier: document.identifier!, changeLogs: changeLogs)
    }

    func onFocus(event: FieldIdentifier) {
        print(">>>>>>>>onFocus", event.fieldID)
    }

    func onBlur(event: FieldIdentifier) {
        print(">>>>>>>>onBlur", event.fieldID)
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.fieldEvent.fieldID)
        showImagePicker(event.uploadHandler)
    }
    
    func onCapture(event: CaptureEvent) {
//        print(">>>>>>>>onCapture", event.fieldEvent.fieldID)
//        showScan(event.captureHandler)
    }
}
