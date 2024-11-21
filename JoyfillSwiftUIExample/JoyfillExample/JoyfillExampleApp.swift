//
//  JoyfillExampleApp.swift
//  JoyfillExample
//
//  Created by ianmol's Macbook on 13/03/24.
//

import SwiftUI
import JoyfillAPIService
import JoyfillModel

@main
struct JoyfillExampleApp: App {
    @State var changeResult: String = ""
    @State var showTemplate: Bool = false

    var body: some Scene {
        WindowGroup {
            if joyfillUITestsMode {
                NavigationView {
                    UITestFormContainerView(changeResult: $changeResult)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                Text(changeResult)
                    .accessibilityIdentifier("resultfield")
                    .frame(height: 10)
            } else {
                NavigationView {
//                    UserAccessTokenTextFieldView()
                    TemplateListView(userAccessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk")
                }
                .navigationViewStyle(StackNavigationViewStyle()) // Force stack style
            }
        }
    }
    
}

var joyfillUITestsMode: Bool {
    CommandLine.arguments.contains("JoyfillUITests")
}
