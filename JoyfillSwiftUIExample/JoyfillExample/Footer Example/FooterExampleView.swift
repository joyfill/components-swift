//
//  FooterExampleView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FooterExampleView: View {
    let footerController: SampleFormFooterController
    let documentEditor: DocumentEditor
    @State private var showFooter = true

    init() {
        let doc = Self.loadDoc(named: "footer-form")
        let controller = SampleFormFooterController()
        let editor = DocumentEditor(document: doc, mode: .fill, events: controller, pageID: nil, navigation: true, license: licenseKey)
        controller.documentEditor = editor
        self.footerController = controller
        self.documentEditor = editor
    }

    var body: some View {
        Form(documentEditor: documentEditor)
            .formFooter {
                if showFooter {
                    SampleFormFooterBar(controller: footerController)
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

private extension FooterExampleView {
    static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}
