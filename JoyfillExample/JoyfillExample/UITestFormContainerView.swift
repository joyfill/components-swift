import SwiftUI
import Joyfill
import JoyfillModel

func sampleJSONDocument() -> JoyDoc {
    let path = Bundle.main.path(forResource: "Joydocjson", ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    let dict = try! JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String: Any]
    return JoyDoc(dictionary: dict)
}

struct UITestFormContainerView: View {
    @State var document: JoyDoc
    @State var pageID: String
    @State var changeResult: String = ""
    
    init() {
        self.pageID = ""
        self.document = sampleJSONDocument()
    }

    var body: some View {
        VStack {
            Form(document: $document, mode: .fill, events: self, pageID: $pageID)
            Text(changeResult)
                .frame(height: 1)
                .accessibilityIdentifier("resultfield")
        }
    }
}

extension UITestFormContainerView: FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        let dictionary = changes.first!.dictionary
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            changeResult = jsonString
        } else {
            print("Failed to convert dictionary to JSON string")
        }
    }
    
    func onFocus(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
}
