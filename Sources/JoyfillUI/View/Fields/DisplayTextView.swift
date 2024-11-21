import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    @State var displayText: String = ""
    private var displayTextDataModel: DisplayTextDataModel
    
    public init(displayTextDataModel: DisplayTextDataModel) {
        self.displayTextDataModel = displayTextDataModel
        if let data = displayTextDataModel.displayText {
            _displayText = State(initialValue: data)
        }
    }
    
    var body: some View {
        HStack {
            Text("\(displayText)")
                .font((displayTextDataModel.fontWeight == "bold") ? .title : .title3)
                .fontWeight((displayTextDataModel.fontWeight == "bold") ? .bold : .regular)
            Spacer()
        }
    }
}

struct DisplayTextDataModel {
    var displayText: String?
    var fontWeight: String?
    var fieldHeaderModel: FieldHeaderModel
}
