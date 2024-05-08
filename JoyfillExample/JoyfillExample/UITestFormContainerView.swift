import SwiftUI
import Joyfill
import JoyfillModel

struct UITestFormContainerView: View {
    @State var document: JoyDoc
    @State var pageID: String
    @State var changeResult: String = ""
    
    init() {
        self.pageID = ""
        self.document = jsonDocument()
    }

    var body: some View {
        VStack {
            Form(document: $document, mode: .fill, events: self, pageID: $pageID)
//            SaveButtonView(changeManager: changeManager, document: $document)
            Text(changeResult)
                .accessibilityIdentifier("resultfield")
        }
    }
}

extension UITestFormContainerView: FormChangeEvent {
    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {
        let dictionary = changes.first?.dictionary
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            changeResult = jsonString
        } else {
            print("Failed to convert dictionary to JSON string")
        }
//        let value = changes.first!.change!["value"] as Any
//        let valueunion = ValueUnion(value: value)
//        changeResult = valueunion?.dictionary
//        if let string = valueunion?.text {
//            changeResult = string
//        } else if let number = valueunion?.number {
//            changeResult = String(number)
//        } else if let multiSelector = valueunion?.multiSelector {
//            changeResult = multiSelector.joined(separator: ", ")
//        }
        
    }
    
    func onFocus(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        event.uploadHandler(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSLD0BhkQ2hSend6_ZEnom7MYp8q4DPBInwtA&s"])
    }
    
    
}
