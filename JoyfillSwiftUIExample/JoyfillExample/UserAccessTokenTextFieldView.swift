import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService
import JoyfillModel

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    @State private var warningMessage: String? = nil
    @State var templateAndDocuments: ([Document], [Document]) = ([], [])
    @State var apiService: APIService? = nil
    @State private var isFetching: Bool = false
    var isAlreadyToken: Bool
    
    var body: some View {
        if isAlreadyToken {
            NavigationLink(
                destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                       result: templateAndDocuments, isAlreadyToken: true)),
                isActive: isAlreadyToken ? Binding.constant(true) : $showTemplate
            ) {
                EmptyView()
            }
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Enter your access token here:")
                    .font(.headline)
                    .padding(.leading, 10)
                
                if let warning = warningMessage {
                    Text(warning)
                        .foregroundColor(.red)
                }
                
                TextEditor(text: $userAccessToken)
                    .frame(height: 200)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Button(action: {
                    isFetching = true
                    self.apiService = APIService(accessToken: userAccessToken,
                                                 baseURL: "https://api-joy.joyfill.io/v1")
                    fetchTemplates {
                        if warningMessage != nil || !(warningMessage?.isEmpty ?? false) {
                            isFetching = false
                        }
                    }
                }, label: {
                    Spacer()
                    Text(isFetching ? "Entering..." : "Enter")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(userAccessToken.isEmpty ? .gray: .blue)
                        .cornerRadius(8)
                    Spacer()
                })
                .disabled(userAccessToken.isEmpty || isFetching)
                
                NavigationLink(
                    destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                           result: templateAndDocuments, isAlreadyToken: false)),
                    isActive: $showTemplate
                ) {
                    EmptyView()
                        .padding()
                }
            }.padding()
        }
    }
                    
    private func fetchTemplates(page: Int = 1, limit: Int = 10, completion: @escaping () -> Void) {
        apiService?.fetchTemplates(page: page, limit: limit) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let templates):
                    self.templateAndDocuments.0 = templates
                    warningMessage = nil
                    showTemplate = true
                    isFetching = false
                case .failure(let error):
                    warningMessage = "Invalid token: \(error.localizedDescription)"
                }
                completion()
            }
        }
    }
}

struct UserJsonTextFieldView: View {
    @State private var jsonString: String = ""
    @State private var errorMessage: String? = nil
    @State var showCameraScannerView: Bool = false
    @State private var currentCaptureHandler: ((ValueUnion) -> Void)?
    @State var scanResults: String = ""
    @State private var isFetching: Bool = false
    
    private var changeManager: ChangeManager {
        ChangeManager(apiService: APIService(accessToken: "", baseURL: ""), showImagePicker: showImagePicker, showScan: showScan)
    }
    
    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
    }
    
    private func showScan(captureHandler: @escaping (ValueUnion) -> Void) {
        currentCaptureHandler = captureHandler
        showCameraScannerView = true
        presentCameraScannerView()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter your JSON here:")
                .font(.headline)
                .padding(.leading, 10)
            
            TextEditor(text: $jsonString)
                .frame(height: 200)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .onChange(of: jsonString) { _ in
                    validateJSON()
                }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.leading, 10)
            }
            
            NavigationLink(destination: destinationView()) {
                Spacer()
                Text("See Form")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(jsonString.isEmpty || errorMessage != nil ? Color.gray : Color.blue)
                    .cornerRadius(8)
                Spacer()
            }
            .disabled(jsonString.isEmpty || errorMessage != nil)
            
        }
        .onAppear() {
            jsonString = jsonString1
        }
        .padding()
    }
    
    func presentCameraScannerView() {
//        guard let topVC = UIViewController.topViewController() else {
//            print("No top view controller found.")
//            return
//        }
//        let hostingController: UIHostingController<AnyView>
//        if #available(iOS 16.0, *) {
//            let swiftUIView = CameraScanner(
//                startScanning: $showCameraScannerView,
//                scanResult: $scanResults,
//                onSave: { result in
//                    if let currentCaptureHandler = currentCaptureHandler {
//                        currentCaptureHandler(.string(result))
//                    }
//                }
//            )
//            hostingController = UIHostingController(rootView: AnyView(swiftUIView))
//        } else {
//            // Fallback on earlier versions
//            let fallbackView = Text("Camera scanner is not available on this version.")
//                .padding()
//                .multilineTextAlignment(.center)
//            hostingController = UIHostingController(rootView: AnyView(fallbackView))
//        }
//        
//        topVC.present(hostingController, animated: true, completion: nil)
    }
    
    func validateJSON() {
        guard !jsonString.isEmpty else {
            errorMessage = "Please enter a JSON object"
            return
        }
        guard let jsonData = jsonString.data(using: .utf8) else {
            errorMessage = "Invalid JSON encoding"
            return
        }
        do {
            _ = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            errorMessage = nil
        } catch {
            errorMessage = "Invalid JSON format"
        }
    }
    
    func destinationView() -> AnyView {
        guard !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            return AnyView(Text("Invalid JSON"))
        }
        
        do {
            let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] ?? [:]
            let documentEditor = DocumentEditor(
                document: JoyDoc(dictionary: dictionary),
                mode: .fill,
                events: changeManager,
                pageID: "",
                navigation: true
            )
            return AnyView(LazyView(Form(documentEditor: documentEditor)))
        } catch {
            return AnyView(Text("Invalid JSON"))
        }
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}



let jsonString1 = """
{
    "_id": "6805b64461a414c110f9e54d",
    "identifier": "doc_6805b64461a414c110f9e54d",
    "name": "New Doc",
    "files": [
        {
            "_id": "6805b6441ec4060843160f69",
            "name": "New File",
            "pageOrder": [
                "6805b64490b14d1cefd48fbf"
            ],
            "pages": [
                {
                    "_id": "6805b64490b14d1cefd48fbf",
                    "name": "New Page",
                    "width": 816,
                    "height": 1056,
                    "rowHeight": 8,
                    "cols": 8,
                    "fieldPositions": [
                        {
                            "_id": "6805b692de1edc776a44ed3c",
                            "type": "collection",
                            "field": "6805b644b2f2c35e2def8740",
                            "displayType": "original",
                            "x": 0,
                            "y": 0,
                            "width": 8,
                            "height": 44
                        }
                    ],
                    "layout": "grid",
                    "presentation": "normal",
                    "padding": 24
                }
            ],
            "styles": {
                "margin": 4
            }
        }
    ],
    "fields": [
        {
            "file": "6805b6441ec4060843160f69",
            "_id": "6805b644b2f2c35e2def8740",
            "type": "collection",
            "title": "It has ",
            "required": true,
            "value": [
                {
                    "_id": "6805b69956590b01f3ef990d",
                    "cells": {},
                    "children": {}
                },
                {
                    "_id": "6805b69adee7f8251d2cd79f",
                    "cells": {},
                    "children": {}
                }
            ],
            "schema": {
                "collectionSchemaId": {
                    "title": "Parent Table: ",
                    "root": true,
                    "children": [
                        "6805b7c24343d7bcba916934"
                    ],
                    "tableColumns": [
                        {
                            "_id": "6805b644fd938fd8ed7fe2e1",
                            "required": true,
                            "type": "text",
                            "title": "Text: It."
                        },
                        {
                            "_id": "6805b6442f2e0c095a07aebb",
                            "required": true,
                            "type": "dropdown",
                            "title": "Dropdown",
                            "options": [
                                {
                                    "_id": "6805b644125b5d4c3832603b",
                                    "value": "High"
                                },
                                {
                                    "_id": "6805b6443944fc0166ba80a0",
                                    "value": "Medium"
                                },
                                {
                                    "_id": "6805b644328e699f45b507fb",
                                    "value": "Low"
                                }
                            ]
                        },
                        {
                            "_id": "6805b771ab52db07a211a2f6",
                            "required": true,
                            "type": "multiSelect",
                            "title": "Multiselect Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                {
                                    "_id": "6805b771d4f71eb6c061e494",
                                    "value": "Option 1",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#f0f0f0"
                                    }
                                },
                                {
                                    "_id": "6805b7719a178ac79ef6e871",
                                    "value": "Option 2",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#f0f0f0"
                                    }
                                },
                                {
                                    "_id": "6805b77130c78af8dcbbac21",
                                    "value": "Option 3",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#f0f0f0"
                                    }
                                }
                            ],
                            "optionOrder": [
                                "6805b771d4f71eb6c061e494",
                                "6805b7719a178ac79ef6e871",
                                "6805b77130c78af8dcbbac21"
                            ]
                        },
                        {
                            "_id": "6805b644fb566d50704a9e2c",
                            "required": true,
                            "type": "image",
                            "title": "Image"
                        },
                        {
                            "_id": "6805b7796ac9ce35b30e9b7c",
                            "required": true,
                            "type": "number",
                            "title": "Number Column",
                            "deleted": false,
                            "width": 0
                        },
                        {
                            "_id": "6805b77fc568df7b031590dc",
                            "required": true,
                            "type": "date",
                            "title": "Date Column",
                            "deleted": false,
                            "width": 0,
                            "format": "hh:mma"
                        },
                        {
                            "_id": "6805b7a1f8d1629e24d804d6",
                            "required": false,
                            "type": "block",
                            "title": "Label Column",
                            "width": 0,
                            "deleted": false
                        },
                        {
                            "_id": "6805b7a813ea45f5b681dec1",
                            "required": true,
                            "type": "barcode",
                            "title": "Barcode Column",
                            "width": 0,
                            "deleted": false
                        },
                        {
                            "_id": "6805b7ac1325377829f4d92e",
                            "required": true,
                            "type": "signature",
                            "title": "Signature Column",
                            "width": 0,
                            "deleted": false
                        }
                    ]
                },
                "6805b7c24343d7bcba916934": {
                    "title": "Child Table: ",
                    "children": [],
                    "hidden": true,
                    "tableColumns": [
                        {
                            "_id": "6805b7c2dae7987557c0b602",
                            "required": true,
                            "type": "text",
                            "title": "Text Column",
                            "width": 0,
                            "deleted": false
                        },
                        {
                            "_id": "6805b7cd4d3e63602cbc0790",
                            "required": true,
                            "type": "dropdown",
                            "title": "Dropdown Column",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                {
                                    "_id": "6805b7cdd7e3afe29fc94b0c",
                                    "value": "Option 1",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": null
                                    }
                                },
                                {
                                    "_id": "6805b7cd349e0ffbbaea9185",
                                    "value": "Option 2: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": null
                                    }
                                },
                                {
                                    "_id": "6805b7cdb7aeec1d9c890548",
                                    "value": "Option 3: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": null
                                    }
                                },
                                {
                                    "_id": "6805b8269a2ded8e5b335283",
                                    "value": "Option 4: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "width": 200,
                                    "styles": null
                                },
                                {
                                    "value": "Option 5: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "_id": "6805b83a3944e46770727cea"
                                }
                            ],
                            "optionOrder": [
                                "6805b7cdd7e3afe29fc94b0c",
                                "6805b7cd349e0ffbbaea9185",
                                "6805b7cdb7aeec1d9c890548"
                            ]
                        },
                        {
                            "_id": "6805b7d26f17f6a05edeee14",
                            "type": "multiSelect",
                            "title": "Multiselect Column: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                            "deleted": false,
                            "width": 0,
                            "options": [
                                {
                                    "_id": "6805b7d247dcd4e634ccf0a5",
                                    "value": "Option 1: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#f00505"
                                    }
                                },
                                {
                                    "_id": "6805b7d244d0a2e6bbb039fb",
                                    "value": "Option 2: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#f0f0f0"
                                    }
                                },
                                {
                                    "_id": "6805b7d2b87da9ba35bd466a",
                                    "value": "Option 3: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "deleted": false,
                                    "styles": {
                                        "backgroundColor": "#1ceefd"
                                    }
                                },
                                {
                                    "_id": "6805b861b751d6a517dd4730",
                                    "value": "Option 4: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "width": 200,
                                    "styles": {
                                        "backgroundColor": "#19e642"
                                    }
                                },
                                {
                                    "_id": "6805b87a10813e0f9d6f8c76",
                                    "value": "Option 5: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "width": 200,
                                    "styles": null
                                },
                                {
                                    "value": "Option 6: It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                    "_id": "6805b88c92d744c4bc890b81"
                                }
                            ],
                            "optionOrder": [
                                "6805b7d247dcd4e634ccf0a5",
                                "6805b7d244d0a2e6bbb039fb",
                                "6805b7d2b87da9ba35bd466a"
                            ]
                        }
                    ],
                    "logic": {
                        "action": "show",
                        "eval": "and",
                        "conditions": [
                            {
                                "schema": "collectionSchemaId",
                                "column": "6805b644fd938fd8ed7fe2e1",
                                "condition": "*="
                            }
                        ]
                    }
                }
            },
            "identifier": "field_6805b6924b94f31dc8889981",
            "required": true
        }
    ],
    "type": "document"
}
"""
