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
                Text(changeResult)
                    .accessibilityIdentifier("resultfield")
                    .frame(height: 10)
            } else {
                UserAccessTokenTextFieldView()
            }
        }
    }
    
}

var joyfillUITestsMode: Bool {
    CommandLine.arguments.contains("JoyfillUITests")
}
