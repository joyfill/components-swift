//
//  JoyfillExampleApp.swift
//  JoyfillExample
//
//  Created by ianmol's Macbook on 13/03/24.
//

import SwiftUI
import JoyfillAPIService
import JoyfillModel
import Joyfill

class AppState: ObservableObject {
    @Published var changeResult: String = ""
}

// MARK: - Quick Configuration
// Change this to true for quick testing with default token, false for option selection screen
let useQuickTestMode: Bool = false

let licenseKey: String = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3N1ZXIiOiJKb3lmaWxsIExMQyIsImlzc3VlZCI6IlNlcnZpY2UgVHJhZGUiLCJjb2xsZWN0aW9uRmllbGQiOnRydWV9.EA_6ZEq9viV6omtSquXzHkGMMIOtqyR2utE6sq2swATFn7-GCR032WZyxkJhc7dSl9rBG0sSNdQhfLYafKpJ07LD2jK7izKXcl0lZ4OkYWUjBlJzZqQVS9VIfkJxZg_CshuyTI5Srzw0-V8AuuaC_Lu2oAEiRxwMqCWXuZl6uHloe2sO5XmMUcZnkoOlwmNwsKwgjmL2N_9-FuuMha15jcqsEcgoA4y2caGIGsXdJlvEaQKT81nn4fN79eYGHVv_EucFutZLLLDbtZLheIYaV9gIGUrFyX210AGZ56sp6tGuadHu9yqQGM_a6kK_d5A97tnMlOzg06-CvWXzEaibMduxX1fecg8_iu6mUgA_1HN8E5FjtBtDUa6qpcIVMlGFss2rWiu1NdDBnZPhu6ZDPy9-h3edVFrGF-qCAaEk_Kvg2H4qnRhdZOzvS1JA1ZgxTKTH9UeQff5QJ8k4h83rG5_aPHuAEwj1KD9nK_h9Qlk3ClIUO_vaRxYl-SyyOffCUBBbnwCdyV4oKE4giJAxBbsup_pKYGZFKgpeBx_s3hOFvrHjShd-pFqgBJJUGf8Niz2yge4y7U0efuG9XAYKeIqAm5KF9x7_oDMmXYswF554QOb49V8SCaOmjTs3hU2zf0TzWv4WTOLW78Ahd4q3-pJVG8535r1oOH8Z7YiI6-4"

@main
struct JoyfillExampleApp: App {
    @StateObject private var appState = AppState()
    @State var showTemplate: Bool = false
    let documentEditor: DocumentEditor
    
    init() {
        let appState = AppState()
        let eventHandler =  UITestFormContainerViewHandler() { change in
            DispatchQueue.main.async {
                appState.changeResult = change
            }
        }
        _appState = StateObject(wrappedValue: appState)
        
        // Get JSON file name from launch arguments for UI tests
        let jsonFileName = Self.getJSONFileNameFromLaunchArguments()
        self.documentEditor = DocumentEditor(document: sampleJSONDocument(fileName: jsonFileName), events: eventHandler, isPageDuplicateEnabled: true, validateSchema: false, license: licenseKey)
    }

    var body: some Scene {
        WindowGroup {
            if joyfillUITestsMode && isRunOnChangeHandler() {
                OnChangeHandlerTest()
                    .navigationViewStyle(StackNavigationViewStyle())
            } else if joyfillUITestsMode {
                NavigationView {
                    UITestFormContainerView(documentEditor: documentEditor)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                Text(appState.changeResult)
                    .accessibilityIdentifier("resultfield")
                    .frame(height: 10)
            } else if useQuickTestMode {
                //Quick test mode: directly open template list with default token
                NavigationView {
                    UserAccessTokenTextFieldView(isAlreadyToken: true, enableChangelogs: false)
                }
            } else {
                OptionSelectionView()
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
    
    func isRunOnChangeHandler(_ testClass: String = "OnChangeHandlerUITests") -> Bool {
        // 1. Must be iPad
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            return false
        }
        // 2. Pull the full test name from CLI args
        let args = CommandLine.arguments
        guard let idx = args.firstIndex(of: "--test-name"),
              idx + 1 < args.count else {
            return false
        }
        let fullTestName = args[idx + 1]
        // 3. Check if it contains our test class
        return fullTestName.contains(testClass)
    }
    
    private static func getJSONFileNameFromLaunchArguments() -> String? {
        let arguments = CommandLine.arguments
        if let jsonFileIndex = arguments.firstIndex(of: "--json-file"),
           jsonFileIndex + 1 < arguments.count {
            return arguments[jsonFileIndex + 1]
        }
        return nil
    }
}

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content.gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }))
        }
    }
}

var joyfillUITestsMode: Bool {
    CommandLine.arguments.contains("JoyfillUITests")
}
