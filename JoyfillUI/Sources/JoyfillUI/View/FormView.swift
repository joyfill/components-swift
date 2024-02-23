//
//  FormView.swift
//  JoyFill
//
//  Created by Vikash on 06/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

struct FormView: View {
    let identifier: String
    @State var data: JoyDoc?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                Text("Form View")
                    .font(.title.bold())
                if let fields = data?.fields , let files = data?.files {
                    ForEach(fields) { joyDocField in
                        switch joyDocField.type {
                        case FieldTypes.text:
                            DisplayTextView(value: joyDocField.value)
                        case FieldTypes.multiSelect:
                            MultiSelectionView(value: joyDocField.value)
                        case FieldTypes.dropdown:
                            DropdownView(value: joyDocField.value)
                        case FieldTypes.textarea:
                            MultiLineTextView(value: joyDocField.value)
                        case FieldTypes.date:
                            DateTimeView(fieldPosition: getFieldPositionForField(files: files),value: joyDocField.value)
                        case FieldTypes.signature:
                            SignatureView(value: joyDocField.value)
                        case FieldTypes.block:
                            DisplayTextView(value: joyDocField.value)
                        case FieldTypes.number:
                            NumberView(value: joyDocField.value)
                        case FieldTypes.chart:
                            Text("")
                        case FieldTypes.richText:
                            Text("")
                        case FieldTypes.table:
                            Text("")
                        case FieldTypes.image:
                            ImageView(value: joyDocField.value)
                        default:
                            Text("Data no Available")
                        }
                    }
                }
            }
            .onAppear{
                APIService().fetchJoyDoc(identifier: identifier) { result in
                    switch result {
                    case .success(let data):
                        do {
                            let joyDocStruct = try JSONDecoder().decode(JoyDoc.self, from: data)
                            
                            // It will prevent tasks to perform on main thread
                            DispatchQueue.main.async {
                                self.data = joyDocStruct
                                pageIndex = 0
                                fetchDataFromJoyDoc()
                            }
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    case .failure(let error):
                        print("error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    func getFieldPositionForField(files: [File]) -> FieldPosition? {
        let fileIndex = 0
        let pageIndex = 0
        let fieldPositionIndex = 0
        let file = files[fileIndex]
        let page = file.pages?[pageIndex]
        let fieldPosition = page?.fieldPositions?[fieldPositionIndex]
        return fieldPosition
    }
}

#Preview {
    MultiSelectionView(options: ["Yes", "No", "N/A"])
}

struct FieldTypes {
    static let text = "text"
    static let multiSelect = "multiSelect"
    static let dropdown = "dropdown"
    static let textarea = "textarea"
    static let date = "date"
    static let signature = "signature"
    static let block = "block"
    static let number = "number"
    static let chart = "chart"
    static let richText = "richText"
    static let table = "table"
    static let image = "image"
}

extension ValueUnion {
    var textabc: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    var imageURL: String? {
        switch self {
        case .valueElementArray(let valueElements):
            return valueElements[0].url        
        default:
            return nil
        }
    }
    var signatureURL: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var multilineText: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var number: Int? {
        switch self {
        case .integer(let int):
            return int
        default:
            return nil
        }
    }
    func dateTime(format: String) -> String? {
        switch self {
        case .string(let string):
            let date = getTimeFromISO8601Format(iso8601String: string)
            return date
        case .integer(let integer):
            let date = timestampMillisecondsToDate(value: integer, format: format)
            return date
        default:
            return nil
        }
    }
    
}
public func getTimeFromISO8601Format(iso8601String: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    let instant = dateFormatter.date(from: iso8601String)
    
    let timeZone = TimeZone.current
    let zonedDateTime = instant ?? Date()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.timeZone = timeZone
    
    let timeString = formatter.string(from: zonedDateTime)
    return timeString
}
public func timestampMillisecondsToDate(value: Int, format: String) -> String {
    let timestampMilliseconds: TimeInterval = TimeInterval(value)
    let date = Date(timeIntervalSince1970: timestampMilliseconds / 1000.0)
    let dateFormatter = DateFormatter()
    
    if format == "MM/DD/YYYY" {
        dateFormatter.dateFormat = "MMMM d, yyyy"
    } else if format == "hh:mma" {
        dateFormatter.dateFormat = "hh:mm a"
    } else {
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
    }
    
    let formattedDate = dateFormatter.string(from: date)
    return formattedDate
}
