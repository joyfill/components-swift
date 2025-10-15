#if canImport(UIKit)
import SwiftUI
import JoyfillModel
import UIKit

struct RichTextView: View {
    @State private var text: AttributedString
    private let richTextDataModel: RichTextDataModel
    let eventHandler: FieldChangeEvents

    public init(richTextDataModel: RichTextDataModel, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        self.richTextDataModel = richTextDataModel
        let text = richTextDataModel.text ?? ""
        let data =  text.data(using: .utf8)!
        let attributedString = parseRT(data: data)
        _text = State(initialValue: attributedString!)
    }
    
    var body: some View {
        FieldHeaderView(richTextDataModel.fieldHeaderModel)
        HStack {
            Text(text)
            Spacer()
        }
    }
}

func parseRT(data: Data) -> AttributedString? {
    var attributedTextArray = NSMutableAttributedString()
    do {
        let richTextJoyDocData = try JSONDecoder().decode(RichTextData.self, from: data)
        let blocks = richTextJoyDocData.blocks
        var attributedText = NSMutableAttributedString()
        var inlineStyleValue = String()
        var inlineStyleKey = String()
        
        for block in blocks {
            if let text = block.text as NSString? {
                let attributes: [NSAttributedString.Key: Any] = [:]
                attributedText = NSMutableAttributedString(string: text as String + "\n")
                for inlineStyle in block.inlineStyleRanges {
                    let rangeStart = inlineStyle.offset
                    let rangeLength = inlineStyle.length
                    let rangeEnd = min(rangeStart + rangeLength, text.length)
                    let range = NSRange(location: rangeStart, length: rangeEnd - rangeStart)
                    
                    // Separated InlineStyleRange by "-"
                    let separatedInlineStyleValues = inlineStyle.style.components(separatedBy: "-")
                    if separatedInlineStyleValues.count == 2 {
                        inlineStyleValue = separatedInlineStyleValues[1]
                        inlineStyleKey = separatedInlineStyleValues[0]
                        
                        // Set fontsize and color to the text
                        if inlineStyleKey == "fontsize" {
                            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: CGFloat(Int(inlineStyleValue) ?? 0)), range: range)
                        } else if inlineStyleKey == "color" {
                            if inlineStyleValue.hasPrefix("#") {
                                attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: inlineStyleValue ) as Any, range: range)
                                attributedText.addAttribute(.underlineColor, value: UIColor(hexString: inlineStyleValue ) as Any, range: range)
                            } else {
                                let hexValue = rgbToHex(rgbString: inlineStyleValue)
                                attributedText.addAttribute(.foregroundColor, value: UIColor(hexString: hexValue ?? "") as Any, range: range)
                                attributedText.addAttribute(.underlineColor, value: UIColor(hexString: hexValue ?? "") as Any, range: range)
                            }
                        }
                    }
                    
                    switch inlineStyle.style {
                    case "BOLD":
                        let existingFont = attributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 17)
                        let boldFont = UIFont.boldSystemFont(ofSize: existingFont.pointSize)
                        attributedText.addAttribute(.font, value: boldFont, range: range)
                    case "ITALIC":
                        let existingFont = attributes[.font] as? UIFont ?? UIFont.systemFont(ofSize: 17)
                        if existingFont.isBold {
                            if let italicFontDescriptor = existingFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold]) {
                                let italicBoldFont = UIFont(descriptor: italicFontDescriptor, size: existingFont.pointSize)
                                attributedText.addAttribute(.font, value: italicBoldFont, range: range)
                            } else {
                                let italicFont = UIFont.italicSystemFont(ofSize: existingFont.pointSize)
                                attributedText.addAttribute(.font, value: italicFont, range: range)
                            }
                        } else {
                            let italicFont = UIFont.italicSystemFont(ofSize: existingFont.pointSize)
                            attributedText.addAttribute(.font, value: italicFont, range: range)
                        }
                    case "UNDERLINE":
                        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
                    default:
                        break
                    }
                }
                attributedTextArray.append(attributedText)
            }
        }
        return AttributedString(attributedTextArray)
    } catch {
        Log("Error parsing JSON: \(error)", type: .warning)
    }
    return AttributedString(attributedTextArray)
}

struct RichTextData: Codable {
    let blocks: [Block]
    let entityMap: [String: String]
}

struct Block: Codable {
    let key: String
    let text: String
    let type: String
    let depth: Int
    let inlineStyleRanges: [InlineStyleRange]
    let entityRanges: [String]
    let data: [String: String]
}

struct InlineStyleRange: Codable {
    let offset: Int
    let length: Int
    let style: String
}

// Function to convert RGB color to Hexa
func rgbToHex(rgbString: String) -> String? {
    // Remove "rgb(" and ")" and split the string by ","
    let components = rgbString.replacingOccurrences(of: "rgb(", with: "").replacingOccurrences(of: ")", with: "").split(separator: ",")
    
    // Ensure we have three components
    guard components.count == 3,
          let red = Int(components[0].trimmingCharacters(in: .whitespaces)),
          let green = Int(components[1].trimmingCharacters(in: .whitespaces)),
          let blue = Int(components[2].trimmingCharacters(in: .whitespaces)) else {
        return nil // Invalid format or values
    }
    
    // Convert RGB values to hex
    let redHex = String(format: "%02X", red)
    let greenHex = String(format: "%02X", green)
    let blueHex = String(format: "%02X", blue)
    
    return "#\(redHex)\(greenHex)\(blueHex)"
}


// Font Extension
extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
}

// UIColor Extension
extension UIColor {
    convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = String(hexString[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                    g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                    b = CGFloat(hexNumber & 0x0000FF) / 255.0
                    a = 1.0
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

#else
import SwiftUI
import JoyfillModel

struct RichTextView: View {
    public init(richTextDataModel: RichTextDataModel, eventHandler: FieldChangeEvents) {}
    
    var body: some View {
        FieldHeaderView(nil)
        EmptyView()
    }
}
#endif
