//
//  DocumentModel.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import Foundation

struct Document: Codable {
    var _id: String
    var type: String
    var identifier: String
    var name: String
    var stage: String
    var createdOn: Int
    var files: [Files]
    var deleted: Bool
    
    struct Files: Codable {
        let _id: String
        let version: Int
        let name: String
        let pageOrder: [String]
        let pages: [Pages]
    }
    
    struct Pages: Codable {
        let _id: String
        let name: String
        let width: Int
        let height: Int
        let cols: Int
        let rowHeight: Int
        let layout: String
        let presentation: String
        let margin: Double
        let padding: Double
        let borderWidth: Double
    }
}

extension Document: Identifiable {
    var id: String { _id }
}

struct DocumentListResponse: Codable {
    let data: [Document]
}
