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
        VStack(spacing: 20.0) {
            Text("Form View")
                .font(.title.bold())
            ScrollView {
                if let fields = data?.fields  {
                    ForEach(fields) { joyDocField in
                        switch joyDocField.type {
                        case FieldTypes.text:
                            DisplayTextView(value: joyDocField.value)
                        case FieldTypes.multiSelect:
                            MultiSelectionView(value: joyDocField.value)
                        case FieldTypes.selector:
                            SelectorView()
                        case FieldTypes.dropdown:
                            DropdownView(value: joyDocField.value)
                        case FieldTypes.textarea:
                            MultiLineTextView(value: joyDocField.value)
                        case FieldTypes.date:
                            DateTimeView(value: joyDocField.value)
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
            Button(action: {
                
            }, label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            })
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 50)

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

#Preview {
    MultiSelectionView(options: ["Yes", "No", "N/A"])
}

struct FieldTypes {
    static let text = "text"
    static let multiSelect = "multiSelect"
    static let selector = "selector"
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
}

