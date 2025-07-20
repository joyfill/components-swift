//
//  MockWeakDocumentEditorDelegate.swift
//  JoyfillExample
//
//  Created by iOS developer on 20/7/25.
//

import Foundation
import Joyfill

final class MockWeakDocumentEditorDelegate: DocumentEditorDelegate {
    typealias ArgsType = (change: Change, callCount: Int)
    
    var applyRowEditChangesArgs: ArgsType?
    func applyRowEditChanges(change: Change) {
        applyRowEditChangesArgs = (change, (applyRowEditChangesArgs?.callCount ?? 0) + 1)
    }
    
    var insertRowArgs: ArgsType?
    func insertRow(for change: Joyfill.Change) {
        insertRowArgs = (change, (insertRowArgs?.callCount ?? 0) + 1)
    }
    
    var deleteRowArgs: ArgsType?
    func deleteRow(for change: Joyfill.Change) {
        deleteRowArgs = (change, (deleteRowArgs?.callCount ?? 0) + 1)
    }
    
    var moveRowArgs: ArgsType?
    func moveRow(for change: Joyfill.Change) {
        moveRowArgs = (change, (moveRowArgs?.callCount ?? 0) + 1)
    }
}
