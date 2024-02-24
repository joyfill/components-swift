//
//  FormView.swift
//  JoyFill
//
//  Created by Vikash on 06/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

struct FormView: View, FormInterface {
    let identifier: String
    @State var document: JoyDoc?
    @State var mode: Mode = .fill
    var events: Events?
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0) {
                if let fields = document?.fields {
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
                            DateTimeView(fieldPosition: document?.getFieldPositionForField(),value: joyDocField.value)
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
                            self.document = joyDocStruct
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
    
    func onChange(event: FieldEvent) {
        events?.onChange(event: event)
    }
    
    func onFocus(event: FieldEvent) {
        events?.onFocus(event: event)
    }
    
    func onBlur(event: FieldEvent) {
        events?.onBlur(event: event)
    }
    
    func onUpload(event:FieldEvent) {
        events?.onBlur(event: event)
    }
}

#Preview {
    MultiSelectionView(options: ["Yes", "No", "N/A"])
}
