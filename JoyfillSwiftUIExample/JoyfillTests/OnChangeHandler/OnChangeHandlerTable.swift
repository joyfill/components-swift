//
//  OnChangeHandlerTable.swift
//  JoyfillExample
//
//  Created by Vivek on 28/07/25.
//

import XCTest
import Foundation
import SwiftUI
import JoyfillModel
import Joyfill

final class OnChangeHandlerTableTests: XCTestCase {
    func documentEditor(document: JoyDoc) -> DocumentEditor {
        DocumentEditor(document: document, validateSchema: false)
    }
}
