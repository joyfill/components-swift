import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    private var displayText: String
    private var fieldDependency: FieldDependency
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
        self.displayText = fieldDependency.fieldData?.value?.displayText ?? ""
    }
    
    var body: some View {
        HStack {
            Text("\(displayText)")
                .font((fieldDependency.fieldPosition.fontWeight == "bold") ? .title : .title3)
                .fontWeight((fieldDependency.fieldPosition.fontWeight == "bold") ? .bold : .regular)
            Spacer()
        }
    }
}

