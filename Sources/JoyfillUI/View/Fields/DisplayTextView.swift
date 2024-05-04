import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    @State var displayText: String = ""
    private var fieldDependency: FieldDependency
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        if let data = fieldDependency.fieldData?.value?.displayText {
        _displayText = State(initialValue: data)
        }
    }
    
    var body: some View {
        HStack {
            Text("\(displayText)")
            Spacer()
        }
    }
}

