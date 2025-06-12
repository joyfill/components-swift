import SwiftUI
import Joyfill
import JoyfillModel

func sampleJSONDocument(fileName: String = "Joydocjson") -> JoyDoc {
    let path = Bundle.main.path(forResource: fileName, ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
    return JoyDoc(dictionary: dict)
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
    
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
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
    
    func onFocus(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldIdentifier) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        didReceiveUploadEvent = true
        uploadCallback?(didReceiveUploadEvent, didReceiveChange)
        //Comment this upload in some test cases
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
    
    func onCapture(event: JoyfillModel.CaptureEvent) {
        event.captureHandler(.string("Scan Button Clicked"))
    }
}
