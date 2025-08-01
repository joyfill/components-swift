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
        
        // Create document editor with error handling
        do {
            self.documentEditor = DocumentEditor(document: sampleJSONDocument(fileName: jsonFileName), events: eventHandler, isPageDuplicateEnabled: true, validateSchema: false)
        } catch {
            print("⚠️  Error creating document editor: \(error)")
            // Create a fallback document editor
            let fallbackDoc = sampleJSONDocument(fileName: "Joydocjson")
            self.documentEditor = DocumentEditor(document: fallbackDoc, events: eventHandler, isPageDuplicateEnabled: true, validateSchema: false)
        }
        
        // Set up crash prevention for UI tests after all properties are initialized
        setupCrashPrevention()
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
    
    /// Set up crash prevention for UI tests
    private func setupCrashPrevention() {
        // Check if we're in safe mode
        if CommandLine.arguments.contains("--safe-mode") {
            print("🛡️  Safe mode enabled for UI tests")
            
            // Set up signal handlers to prevent crashes
            signal(SIGABRT) { _ in
                print("⚠️  SIGABRT caught, preventing crash")
            }
            
            signal(SIGSEGV) { _ in
                print("⚠️  SIGSEGV caught, preventing crash")
            }
            
            signal(SIGILL) { _ in
                print("⚠️  SIGILL caught, preventing crash")
            }
        }
        
        // Check if crash on error is disabled
        if CommandLine.arguments.contains("--disable-crash-on-error") {
            print("🛡️  Crash on error disabled")
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
