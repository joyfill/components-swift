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
    static let groupsBaseURL = "\(baseURL)/groups"
    static let usersBaseURL = "\(baseURL)/users"
    static let saveFormBaseURL = "\(baseURL)/changelogs"
    
    // See https://docs.joyfill.io/docs/authentication#user-access-tokens
    public static let userAccessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY0MjIyMjU0NjE2NzcyZmFmYzdhNzc2MiJ9.vjw0KYOQ6hlo98ar7BDz-6ADYZndV4hwFRF4XAQtz58"
}
