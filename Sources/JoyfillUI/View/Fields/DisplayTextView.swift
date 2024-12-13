import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    private var displayText: String = ""
    private var displayTextDataModel: DisplayTextDataModel

    let eventHandler: FieldChangeEvents

    public init(displayTextDataModel: DisplayTextDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.displayTextDataModel = displayTextDataModel
        self.displayText = displayTextDataModel.displayText ?? ""
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
