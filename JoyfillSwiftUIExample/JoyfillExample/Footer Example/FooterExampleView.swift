//
//  FooterExampleView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

class FooterState: ObservableObject {
    @Published var isExpanded = false
}

struct FooterExampleView: View {
    let documentEditor: DocumentEditor
    let changeHandler = FooterChangeHandler()
    let document = loadDoc(named: "footer-form")
    let footerState = FooterState()
    @State private var showFooter = true

    init() {
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeHandler, pageID: nil, navigation: true)
    }

    var body: some View {
        Form(documentEditor: documentEditor)
            .formFooter {
                if showFooter {
                    SampleFooterView(state: footerState)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(showFooter ? "Hide Footer" : "Show Footer") {
                        showFooter.toggle()
                    }
                }
            }
    }
}

struct SampleFooterView: View {
    @ObservedObject var state: FooterState

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Save Draft")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    Button(action: { withAnimation { state.isExpanded.toggle() } }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                if state.isExpanded {
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Text("Send Email")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        Button(action: {}) {
                            Text("Download PDF")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                    }
                    Button(action: {}) {
                        Text("Share with Team")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
    }
}

class FooterChangeHandler: FormChangeEvent {
    func onChange(changes: [Joyfill.Change], document: JoyfillModel.JoyDoc) {}
    func onFocus(event: Joyfill.Event) {}
    func onBlur(event: Joyfill.Event) {}
    func onUpload(event: Joyfill.UploadEvent) {}
    func onCapture(event: Joyfill.CaptureEvent) {}
    func onError(error: Joyfill.JoyfillError) {}
}

private extension FooterExampleView {
    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}
