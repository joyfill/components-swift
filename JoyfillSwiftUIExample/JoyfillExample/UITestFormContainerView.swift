import SwiftUI
import Joyfill
import JoyfillModel

func sampleJSONDocument(fileName: String? = nil) -> JoyDoc {
    let jsonFileName = fileName ?? "Joydocjson"
    
    // Try to find the JSON file in the bundle
    guard let path = Bundle.main.path(forResource: jsonFileName, ofType: "json") else {
        print("Warning: Could not find JSON file '\(jsonFileName).json' in bundle. Using default.")
        return createDefaultJoyDoc()
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
        return JoyDoc(dictionary: dict)
    } catch {
        print("Error loading JSON file '\(jsonFileName).json': \(error). Using default.")
        return createDefaultJoyDoc()
    }
}

// Safe fallback function that creates a minimal JoyDoc
private func createDefaultJoyDoc() -> JoyDoc {
    // Create a minimal valid JoyDoc structure
    let defaultDict: [String: Any] = [
        "id": "default-doc",
        "name": "Default Document",
        "pages": [
            [
                "id": "page-1",
                "name": "Page 1",
                "fields": []
            ]
        ]
    ]
    
    do {
        return JoyDoc(dictionary: defaultDict)
    } catch {
        print("Error creating default JoyDoc: \(error)")
        // Return an even more minimal structure
        return JoyDoc(dictionary: ["id": "fallback-doc", "pages": []])
    }
}

struct UITestFormContainerView: View {
    let documentEditor: DocumentEditor
    @State var pageID: String = ""
    @State private var uploadReceived: Bool = false
    @State private var onChangeFlag: Bool = false
    
    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    var body: some View {
        VStack {
            Form(documentEditor: documentEditor)
            
            Text(uploadReceived ? "true" : "false")
                .accessibilityIdentifier("uploadflag")
            Text(onChangeFlag ? "true" : "false")
                .accessibilityIdentifier("onChangeFlag")
        }
        .onAppear {
            if let handler = documentEditor.events as? UITestFormContainerViewHandler {
                handler.uploadCallback = { didUpload, didChange in
                    self.uploadReceived = didUpload
                    self.onChangeFlag = didChange
                }
            }
            triggerGotoFromLaunchArgumentsIfNeeded()
        }
    }
    
    /// When running under UI tests with --goto-path, perform navigation after a short delay so the form is ready.
    private func triggerGotoFromLaunchArgumentsIfNeeded() {
        let args = CommandLine.arguments
        guard let pathIndex = args.firstIndex(of: "--goto-path"),
              pathIndex + 1 < args.count else { return }
        let path = args[pathIndex + 1]
        let open = args.contains("--goto-open")
        let focus = args.contains("--goto-focus")
        let gotoConfig = GotoConfig(open: open, focus: focus)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            _ = self.documentEditor.goto(path, gotoConfig: gotoConfig)
        }
    }
}

class UITestFormContainerViewHandler: FormChangeEvent {
    var setResult: (String) -> Void
    var setUploadResult: (String) -> Void
    var setFocusBlurResult: (String) -> Void
    var didReceiveChange = false
    var didReceiveUploadEvent = false
    var uploadCallback: ((Bool, Bool) -> Void)?
    private var focusBlurEvents: [[String: Any]] = []
    
    init(setResult: @escaping (String) -> Void, setUploadResult: @escaping (String) -> Void, setFocusBlurResult: @escaping (String) -> Void) {
        self.setResult = setResult
        self.setUploadResult = setUploadResult
        self.setFocusBlurResult = setFocusBlurResult
    }
    
    func onChange(changes: [Change], document: JoyfillModel.JoyDoc) {
        didReceiveChange = true
        uploadCallback?(didReceiveUploadEvent, didReceiveChange)
        let dictionary = changes.map { $0.dictionary }
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            setResult(jsonString)
        } else {
            print("Failed to convert dictionary to JSON string")
        }
    }
    
    func onFocus(event: Event) {
        guard !Self.shouldSkipFocusBlurHandler else { return }
        appendFocusBlurEvent(kind: "focus", event: event)
    }

    func onBlur(event: Event) {
        guard !Self.shouldSkipFocusBlurHandler else { return }
        appendFocusBlurEvent(kind: "blur", event: event)
    }
    
    private func appendFocusBlurEvent(kind: String, event: Event) {
        var dict: [String: Any] = ["kind": kind]
        if let field = event.fieldEvent {
            dict["fieldEvent"] = field.dictionary
        }
        if let pageEv = event.pageEvent {
            dict["pageEvent"] = ["type": pageEv.type, "pageId": pageEv.page.id ?? ""]
        }
        focusBlurEvents.append(dict)
        if let data = try? JSONSerialization.data(withJSONObject: focusBlurEvents),
           let json = String(data: data, encoding: .utf8) {
            setFocusBlurResult(json)
        }
    }
    
    func onUpload(event: UploadEvent) {
        didReceiveUploadEvent = true
        uploadCallback?(didReceiveUploadEvent, didReceiveChange)
        let dictionary = event.dictionary
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            setUploadResult(jsonString)
        } else {
            print("Failed to convert dictionary to JSON string")
        }
        // Check if we should skip the upload handler for specific test cases
        let shouldSkipUpload = shouldSkipUploadHandler()
        
        if !shouldSkipUpload {
            //Comment this upload in some test cases
            event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
        }
    }
    
    private func shouldSkipUploadHandler() -> Bool {
        // Check for launch argument to skip upload
        if CommandLine.arguments.contains("--skip-upload-handler") {
            return true
        }
        
        // Check for specific test case names (if available through launch arguments)
        let arguments = CommandLine.arguments
        if let testNameIndex = arguments.firstIndex(of: "--test-name"),
           testNameIndex + 1 < arguments.count {
            let fullTestName = arguments[testNameIndex + 1]
            
            // Extract just the method name (after the last dot)
            let testMethodName = fullTestName.components(separatedBy: ".").last ?? fullTestName
            
            // Only skip for these two specific test cases - check for exact method names
            return testMethodName == "-[ImageFieldTests testUploadWithoutCallingHandler]" ||
                   testMethodName == "-[ImageFieldTests testUploadWithoutCallingHandlerForMultiFalse]"
        }
        
        return false
    }
    
    private static let shouldSkipFocusBlurHandler: Bool = {
        let arguments = CommandLine.arguments
        guard arguments.contains("JoyfillUITests") else {
            return false
        }

        if arguments.contains("--skip-focus-blur-handler") {
            return true
        }

        if let testNameIndex = arguments.firstIndex(of: "--test-name"),
           testNameIndex + 1 < arguments.count {
            let fullTestName = arguments[testNameIndex + 1]

            // OnChangeHandlerUITests renders a different test host view and does not
            // read focus/blur payloads from this handler. Skipping here avoids
            // unnecessary UI churn from result text updates during those tests.
            return fullTestName.contains("OnChangeHandlerUITests")
        }

        return false
    }()
    
    func onCapture(event: CaptureEvent) {
        event.captureHandler(.string("Scan Button Clicked"))
    }
    func onError(error: JoyfillError) {}

}

// MARK: - UploadEvent → Dictionary helper
extension UploadEvent {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "multi": multi
        ]
        dict["fieldEvent"] = fieldEvent.dictionary   // you’ll need to make FieldIdentifier → dictionary too
        dict["target"] = target
        dict["schemaId"] = schemaId
        dict["parentPath"] = parentPath
        dict["rowIds"] = rowIds
        dict["columnId"] = columnId
        return dict
    }
}
extension FieldIdentifier {
    var dictionary: [String: Any] {
        var dict: [String: Any] = [:]
        dict["_id"] = _id
        dict["identifier"] = identifier
        dict["fieldID"] = fieldID
        dict["fieldIdentifier"] = fieldIdentifier
        dict["pageID"] = pageID
        dict["fileID"] = fileID
        dict["fieldPositionId"] = fieldPositionId
        dict["type"] = type
        dict["target"] = target
        dict["rowIds"] = rowIds
        dict["parentPath"] = parentPath
        dict["columnId"] = columnId
        return dict
    }
}
