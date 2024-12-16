import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    private var displayText: String = ""
    private var fontSize: CGFloat
    private var fontWeight: Font.Weight
    private var fontColor: Color
    private var isItalic: Bool
    private var displayTextDataModel: DisplayTextDataModel

    public init(displayTextDataModel: DisplayTextDataModel) {
        self.displayTextDataModel = displayTextDataModel
        self.displayText = displayTextDataModel.displayText ?? ""
        self.fontSize = CGFloat(displayTextDataModel.fontSize ?? 12)
        
        if let weightString = displayTextDataModel.fontWeight?.lowercased() {
            switch weightString {
            case "bold":
                self.fontWeight = .bold
            default:
                self.fontWeight = .regular
            }
        } else {
            self.fontWeight = .regular
        }
        
        if let colorString = displayTextDataModel.fontColor {
            self.fontColor = Color(hex: colorString)
        } else {
            self.fontColor = .primary
        }
        
        if let styleString = displayTextDataModel.fontStyle?.lowercased() {
            if styleString == "italic" {
                self.isItalic = true
            } else {
                self.isItalic = false
            }
        } else {
            self.isItalic = false
        }
    }
    
    var body: some View {
        HStack {
            if #available(iOS 16.0, *) {
                Text("\(displayText)")
                    .italic(isItalic)
                    .font(.system(size: fontSize))
                    .fontWeight(fontWeight)
                    .foregroundColor(fontColor)
            } else {
                Text("\(displayText)")
                    .font(.system(size: fontSize))
                    .fontWeight(fontWeight)
                    .foregroundColor(fontColor)
            }
            Spacer()
        }
    }
}
