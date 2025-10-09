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
        let dict = try JSONDecoder().decode([String: AnyCodable].self, from: data) as! [String: Any]
//        let dict = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
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
        }
    }
}

class UITestFormContainerViewHandler: FormChangeEvent {
    var setResult: (String) -> Void
    var didReceiveChange = false
    var didReceiveUploadEvent = false
    var uploadCallback: ((Bool, Bool) -> Void)?
    
    init(setResult: @escaping (String) -> Void) {
        self.setResult = setResult
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
    
    func onFocus(event: FieldIdentifier) {
        
    }
    
    func onBlur(event: FieldIdentifier) {
        
    }
    
    func onUpload(event: UploadEvent) {
        didReceiveUploadEvent = true
        uploadCallback?(didReceiveUploadEvent, didReceiveChange)
        
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
    
    func onCapture(event: CaptureEvent) {
        event.captureHandler(.string("Scan Button Clicked"))
    }
    func onError(error: JoyfillError) {}

}


public typealias JSON = [String: Any]

public struct AnyCodable: Decodable {
    public var value: Any?

    public struct CodingKeys: CodingKey {
        public var stringValue: String
        public var intValue: Int?
        public init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        public init?(stringValue: String) { self.stringValue = stringValue }
    }

    public init(value: Any?) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = JSON()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any?]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let intVal = try? container.decode(Int64.self) {
                value = intVal
            } else if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                // Instead of throwing an error, we want to parse these values as being null, since the Assets get returned with properties that have null values
                value = nil
//                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let array = value as? [Any?] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = AnyCodable(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = value as? JSON {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = AnyCodable(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int64 {
                try container.encode(intVal)
            } else  if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let intVal = value as? Int64 {
                try container.encode(intVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else if let val = value {
                throw EncodingError.invalidValue(val, EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
            } else {
                throw EncodingError.invalidValue("nil value", EncodingError.Context.init(codingPath: [], debugDescription: "The value is nil"))
            }

        }
    }
}
