//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService

class ChangeManager {
    private let apiService: APIService
    private let showImagePicker:  (@escaping ([String]) -> Void) -> Void

    init(apiService: APIService, showImagePicker:  @escaping(@escaping ([String]) -> Void) -> Void) {
        self.showImagePicker = showImagePicker
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
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        if let firstChange = changes.first {
            print(">>>>>>>>onChange", firstChange.fieldId ?? "")
        } else {
            print(">>>>>>>>onChange: no changes")
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
    }

    func onBlur(event: FieldIdentifier) {
        print(">>>>>>>>onBlur", event.fieldID)
    }

    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.fieldEvent.fieldID)
        showImagePicker(event.uploadHandler)
    }
}
