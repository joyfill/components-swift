//
//  Constants.swift
//  JoyFill
//
//

import Foundation

public struct Constants {
    // MARK: - API
    
    // Documents endpoint https://docs.joyfill.io/reference/overview-documents
    public static let baseURL = "https://api-joy.joyfill.io/v1"
    
    static let documentsBaseURL = "\(baseURL)/documents"
    static let templatesBaseURL = "\(baseURL)/templates"
    static let groupsBaseURL = "\(baseURL)/groups"
    static let usersBaseURL = "\(baseURL)/users"
    static let saveFormBaseURL = "\(baseURL)/changelogs"
    
    // See https://docs.joyfill.io/docs/authentication#user-access-tokens
    public static let userAccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk"
}
