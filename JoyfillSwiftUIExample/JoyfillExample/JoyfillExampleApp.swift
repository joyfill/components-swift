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
let useQuickTestMode: Bool = true

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
        self.documentEditor = DocumentEditor(document: sampleJSONDocument(), events: eventHandler)
    }

    var body: some Scene {
        WindowGroup {
            if joyfillUITestsMode {
                NavigationView {
                    UITestFormContainerView(documentEditor: documentEditor)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                Text(appState.changeResult)
                    .accessibilityIdentifier("resultfield")
                    .frame(height: 10)
            } else if useQuickTestMode {
                // Quick test mode: directly open template list with default token
                NavigationView {
                    UserAccessTokenTextFieldView(isAlreadyToken: true, enableChangelogs: false)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            } else {
                OptionSelectionView()
            }
//            ImageReplacementTest()
        }
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
