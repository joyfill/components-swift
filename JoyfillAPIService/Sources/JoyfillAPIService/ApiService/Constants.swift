//
//  Constants.swift
//  JoyFill
//
//

import Foundation

struct Constants {
    // MARK: - API
    // Documents endpoint https://docs.joyfill.io/reference/overview-documents
    static var baseURL = ""
    static let documentsBaseURL = "\(baseURL)/documents"
    static let templatesBaseURL = "\(baseURL)/templates"
    static let groupsBaseURL = "\(baseURL)/groups"
    static let usersBaseURL = "\(baseURL)/users"
    static let saveFormBaseURL = "\(baseURL)/changelogs"
    
    // See https://docs.joyfill.io/docs/authentication#user-access-tokens
    static var userAccessToken = ""
}

// Public API to set the user access token and base URL
public func initialize(userAccessToken: String, baseURL: String) {
    Constants.userAccessToken = userAccessToken
    Constants.baseURL = baseURL
}
