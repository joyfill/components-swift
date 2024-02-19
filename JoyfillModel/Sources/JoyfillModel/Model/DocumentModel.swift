//
//  DocumentModel.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import Foundation

public struct Document: Codable {
    public var _id: String
    public var type: String
    public var identifier: String
    public var name: String
    public var stage: String
    public var createdOn: Int
    public var files: [Files]
    public var deleted: Bool
    
    public struct Files: Codable {
        public let _id: String
        public let version: Int
        public let name: String
        public let pageOrder: [String]
        public let pages: [Pages]
    }
    
    public struct Pages: Codable {
        public let _id: String
        public let name: String
        public let width: Int
        public let height: Int
        public let cols: Int
        public let rowHeight: Int
        public let layout: String
        public let presentation: String
        public let margin: Double
        public let padding: Double
        public let borderWidth: Double
    }
}

extension Document: Identifiable {
    public var id: String { _id }
}

public struct DocumentListResponse: Codable {
    public let data: [Document]
}
