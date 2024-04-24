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
            userAccessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY2MjhmMTIzNDg5MjYxOGZjMTE4NTc3MyJ9.JofMjGzwWc_nOUcxAyOpuoX_IWIERX7fWJILPda_7ys",
            baseURL: "https://api-joy.joyfill.io/v1")
    }
    
    var body: some Scene {
        WindowGroup {
            TemplateListView()
        }
    }
}
