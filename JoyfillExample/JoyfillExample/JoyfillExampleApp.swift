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
    init() {
        JoyfillAPIService.initialize(
            userAccessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY2MjhmMTIzNDg5MjYxOGZjMTE4NTc3MyJ9.JofMjGzwWc_nOUcxAyOpuoX_IWIERX7fWJILPda_7ys",
            baseURL: "https://api-joy.joyfill.io/v1")
    }
    
    var body: some Scene {
        WindowGroup {
            //            if CommandLine.arguments.contains("FormView") {
            NavigationView {
                UITestFormContainerView()
            }
            //            } else {
            //                TemplateListView()
            //            }
        }
    }
    
}
    func jsonDocument() -> JoyDoc {
        let path = Bundle.main.path(forResource: "Joydocjson", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }

