//
//  FormView.swift
//  JoyFill
//
//  Created by Vikash on 06/02/24.
//

import SwiftUI

struct FormView: View {
    let identifier: String
    @State var data: JoyDoc?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                Text("Form View")
                    .font(.title.bold())
                MultiSelectionView(options: ["yes","no"])
                if let fields = data?.fields  {
                    ForEach(fields) { joyDocField in
                        switch joyDocField.type {
                        case FieldTypes.text:
                            DisplayTextView(displayText: joyDocField.value?.textabc ?? "")
                        case FieldTypes.multiSelect:
                            MultiSelectionView(options: ["Yes", "No", "N/A"])
                        case FieldTypes.dropdown:
                            DropdownView()
                        case FieldTypes.textarea:
                            MultiLineTextView()
                        case FieldTypes.date:
                            DateTimeView()
                        case FieldTypes.signature:
                            SignatureView(currentImageIndex: 0, startingImageIndex: 0,signatureURL: joyDocField.value?.signatureURL)
                        case FieldTypes.block:
                            DisplayTextView(displayText: joyDocField.value?.textabc ?? "")
                        case FieldTypes.number:
                            NumberView()
                        case FieldTypes.chart:
                            Text("")
                        case FieldTypes.richText:
                            Text("")
                        case FieldTypes.table:
                            Text("")
                        case FieldTypes.image:
                            ImageView(imageURL: joyDocField.value?.url)
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

fileprivate extension ValueUnion {
    var textabc: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    var url: String? {
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
}

