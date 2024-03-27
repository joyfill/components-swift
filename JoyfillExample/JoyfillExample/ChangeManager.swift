//
//  ChangeManager.swift
//  JoyfillExample

import Foundation
import JoyfillModel
import JoyfillAPIService

class ChangeManager {
    private let apiService: APIService = APIService()
    private let showImagePicker: (([String]) -> Void) -> Void

    init(showImagePicker: @escaping (([String]) -> Void) -> Void) {
        self.showImagePicker = showImagePicker
    }

    func saveJoyDoc(document: JoyDoc) {
        apiService.updateDocument(identifier: document.identifier!, document: document) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("success: \(data)")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateDocument(identifier: String, changeLogs: Changelog) {
        apiService.updateDocument(identifier: identifier, changeLogs: changeLogs) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("success: \(data)")
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension ChangeManager: FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        print(">>>>>>>>onChange", changes)
        let changeLogs = Changelog(changelogs: changes)
        updateDocument(identifier: document.identifier!, changeLogs: changeLogs)
    }
    
    func onFocus(event: FieldEvent) {
        print(">>>>>>>>onFocus", event.field!.identifier!)
    }
    
    func onBlur(event: FieldEvent) {
        print(">>>>>>>>onBlur", event.field!.identifier!)
    }
    
    func onUpload(event: UploadEvent) {
        print(">>>>>>>>onUpload", event.field.identifier!)
        showImagePicker(event.uploadHandler)
    }
}
