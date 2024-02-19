//
//  API.swift
//  JoyFill
//
//  Created by Vikash on 05/02/24.
//

import Foundation

class API {
    
    static func getDocumentsRequest(path: String, _ method: String = "GET") -> URLRequest? {
        var request = URLRequest(url: URL(string: "\(Constants.baseURL)/\(path)")!)
        request.httpMethod = method
        request.setValue("Bearer \(Constants.userAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
