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
        let value = changes.first!.change!["value"] as Any
        let valueunion = ValueUnion(value: value)
        if let string = valueunion?.text {
            changeResult = string
        } else if let number = valueunion?.number {
            changeResult = String(number)
        } else if let multiSelector = valueunion?.multiSelector {
            changeResult = multiSelector.joined(separator: ", ")
        }
        
    }
    
    func onFocus(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onBlur(event: JoyfillModel.FieldEvent) {
        
    }
    
    func onUpload(event: JoyfillModel.UploadEvent) {
        
    }
    
    
}
