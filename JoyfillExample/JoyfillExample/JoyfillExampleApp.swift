//
//  JoyfillExampleApp.swift
//  JoyfillExample
//
//  Created by ianmol's Macbook on 13/03/24.
//

import SwiftUI
import JoyfillAPIService

@main
struct JoyfillExampleApp: App {
    init() {
        JoyfillAPIService.initialize(
            userAccessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY2MjhlNTQxNDg5MjYxOGZjMTE3NjkyYyJ9.8zLjjWy5tZJb7sryRomtzJl6_hiCVpKt4EkKMcNcGBY",
            baseURL: "https://api-joy.joyfill.io/v1")
    }
    
    var body: some Scene {
        WindowGroup {
            TemplateListView()
        }
    }
}
