import SwiftUI
import Joyfill
import JoyfillModel

func sampleJSONDocument(fileName: String = "TableNewColumns") -> JoyDoc {
    let path = Bundle.main.path(forResource: fileName, ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
    return JoyDoc(dictionary: dict)
}

struct UITestFormContainerView: View {
    let documentEditor: DocumentEditor
    @State var pageID: String = ""
    
    init(documentEditor: DocumentEditor) {
        self.documentEditor = documentEditor
    }

    var body: some View {
        VStack {
            Form(documentEditor: documentEditor)
        }
    }
}

class UITestFormContainerViewHandler: FormChangeEvent {
    var setResult: (String) -> Void
    
    init(setResult: @escaping (String) -> Void) {
        self.setResult = setResult
    }
    
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        let dictionary = changes.map { $0.dictionary }
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            setResult(jsonString)
        } else {
            print("Failed to convert dictionary to JSON string")
        }
    }
    
    func onFocus(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
    
    func onCapture(event: JoyfillModel.CaptureEvent) {
        event.captureHandler(.string("Scan Button Clicked"))
    }
}
