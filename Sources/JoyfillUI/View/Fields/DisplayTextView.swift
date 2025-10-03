import SwiftUI
import JoyfillModel

struct DisplayTextView: View {
    private var displayText: String = ""
    private var fontSize: CGFloat
    private var fontWeight: Font.Weight
    private var fontColor: Color
    private var isItalic: Bool
    private var textAlignment: TextAlignment
    private var isUnderlined: Bool
    private var isUppercase: Bool
    private var backgroundColor: Color
    private var borderColor: Color
    private var borderWidth: CGFloat
    private var borderRadius: CGFloat
    private var padding: CGFloat
    private var displayTextDataModel: DisplayTextDataModel

    public init(displayTextDataModel: DisplayTextDataModel) {
        self.displayTextDataModel = displayTextDataModel
        self.displayText = displayTextDataModel.displayText ?? ""
        self.fontSize = CGFloat(displayTextDataModel.fontSize ?? 12)
        
        // Font weight
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
        
        // Font color
        if let colorString = displayTextDataModel.fontColor, !colorString.isEmpty {
            self.fontColor = Color(hex: colorString)
        } else {
            self.fontColor = .primary
        }
        
        // Font style (italic)
        if let styleString = displayTextDataModel.fontStyle?.lowercased() {
            self.isItalic = styleString == "italic"
        } else {
            self.isItalic = false
        }
        
        // Text alignment
        if let alignString = displayTextDataModel.textAlign?.lowercased() {
            switch alignString {
            case "center":
                self.textAlignment = .center
            case "trailing", "right":
                self.textAlignment = .trailing
            default:
                self.textAlignment = .leading
            }
        } else {
            self.textAlignment = .leading
        }
        
        // Text decoration (underline)
        if let decorationString = displayTextDataModel.textDecoration?.lowercased() {
            self.isUnderlined = decorationString == "underline"
        } else {
            self.isUnderlined = false
        }
        
        // Text transform (uppercase)
        if let transformString = displayTextDataModel.textTransform?.lowercased() {
            self.isUppercase = transformString == "uppercase"
        } else {
            self.isUppercase = false
        }
        
        // Background color
        if let bgColorString = displayTextDataModel.backgroundColor, !bgColorString.isEmpty {
            self.backgroundColor = Color(hex: bgColorString)
        } else {
            self.backgroundColor = .clear
        }
        
        // Border color
        if let borderColorString = displayTextDataModel.borderColor, !borderColorString.isEmpty {
            self.borderColor = Color(hex: borderColorString)
        } else {
            self.borderColor = .clear
        }
        
        // Border width
        self.borderWidth = CGFloat(displayTextDataModel.borderWidth ?? 0)
        
        // Border radius
        self.borderRadius = CGFloat(displayTextDataModel.borderRadius ?? 0)
        
        // Padding
        self.padding = CGFloat(displayTextDataModel.padding ?? 0)
    }
    
    var body: some View {
        HStack {
            if textAlignment == .trailing || textAlignment == .center {
                Spacer()
            }
            if #available(iOS 16.0, *) {
                Text(isUppercase ? displayText.uppercased() : displayText)
                    .italic(isItalic)
                    .font(.system(size: fontSize))
                    .fontWeight(fontWeight)
                    .foregroundColor(fontColor)
                    .multilineTextAlignment(textAlignment)
                    .underline(isUnderlined)
                    
            } else {
                Text(isUppercase ? displayText.uppercased() : displayText)
                    .font(.system(size: fontSize))
                    .fontWeight(fontWeight)
                    .foregroundColor(fontColor)
                    .multilineTextAlignment(textAlignment)
            }
            if textAlignment == .leading || textAlignment == .center {
                Spacer()
            }
        }
        .padding(padding)
        .background(backgroundColor)
        .cornerRadius(borderRadius)
        .overlay(
            RoundedRectangle(cornerRadius: borderRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
    }
}
