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
            userAccessToken: "",
            baseURL: "https://api-joy.joyfill.io/v1")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
