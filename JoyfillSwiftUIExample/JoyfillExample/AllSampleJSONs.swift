//
//  AllSampleJSONs.swift
//  JoyfillExample
//
//  Created by Vishnu Dutt on 27/06/25.
//

import Foundation
import JoyfillModel
import Joyfill
import SwiftUI

struct AllSampleJSONs: View, FormChangeEvent {
    let imagePicker = ImagePicker()
    @State private var documentEditor: DocumentEditor?
    @State private var selectedJSONFile: String = "JoyfillResolver_DirectSelfCircularReference"
    
    // All available JSON files from Formula-sample directory
    private let resolverFiles = [
        "JoyfillResolver_DirectSelfCircularReference",
        "JoyfillResolver_LongChainIndirectCircularDependency", 
        "JoyfillResolver_IndirectCircularError",
        "JoyfillResolverTemplate_ComplexWorking",
        "JoyfillResolver_SimpleWorking"
    ]
    
    private let fieldFiles = [
        "FormulaTemplate_TextareaField",
        "FormulaTemplate_DateField",
        "FormulaTemplate_NumberField", 
        "FormulaTemplate_TextField",
        "FormulaTemplate_CollectionField",
        "FormulaTemplate_DropdownField",
        "FormulaTemplate_MultiSelectField",
        "FormulaTemplate_TableField"
    ]
    
    private var allFiles: [String] {
        resolverFiles + fieldFiles
    }
    
    init() {
        let document = sampleJSONDocument(fileName: "JoyfillResolver_DirectSelfCircularReference")
        _documentEditor = State(initialValue: DocumentEditor(document: document, events: self))
    }

    var body: some View {
        NavigationView {
            VStack {
                // JSON File Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select JSON Sample")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Select JSON File", selection: $selectedJSONFile) {
                        Section("Resolver Files") {
                            ForEach(resolverFiles, id: \.self) { fileName in
                                Text(fileName)
                                    .tag(fileName)
                            }
                        }
                        
                        Section("Field Files") {
                            ForEach(fieldFiles, id: \.self) { fileName in
                                Text(fileName)
                                    .tag(fileName)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Form Display
                if let documentEditor = documentEditor {
                    Form(documentEditor: documentEditor)
                        .tint(.red)
                } else {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Formula Samples")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style
        .onChange(of: selectedJSONFile) { newFileName in
            loadDocument(fileName: newFileName)
        }
    }
    
    private func loadDocument(fileName: String) {
        do {
            let document = sampleJSONDocument(fileName: fileName)
            documentEditor = DocumentEditor(document: document, events: self)
        } catch {
            print("Error loading document: \(fileName) - \(error)")
            // Fallback to default if loading fails
            let document = sampleJSONDocument(fileName: "JoyfillResolver_DirectSelfCircularReference")
            documentEditor = DocumentEditor(document: document, events: self)
        }
    }

    func onChange(changes: [JoyfillModel.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: JoyfillModel.FieldIdentifier) { }
    func onBlur(event: JoyfillModel.FieldIdentifier) { }
    func onCapture(event: JoyfillModel.CaptureEvent) { }

    func onUpload(event: JoyfillModel.UploadEvent) {
        imagePicker.showPickerOptions { urls in
            let imageURL = urls.first!
            event.uploadHandler([imageURL])
            let newURL = "https://app.joyfill.io/static/img/joyfill_logo_w.png"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                documentEditor?.replaceImageURL(newURL: newURL, url: imageURL, fieldIdentifier: event.fieldEvent)
            }
        }
    }
}
