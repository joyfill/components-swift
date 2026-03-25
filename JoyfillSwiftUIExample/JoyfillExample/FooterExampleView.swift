import SwiftUI
import Joyfill
import JoyfillModel

struct FooterExampleView: View {
    let documentEditor: DocumentEditor

    init() {
        let document = Self.loadDoc(named: "first-form")
        self.documentEditor = DocumentEditor(
            document: document,
            mode: .fill,
            events: FooterExampleChangeHandler(),
            validateSchema: false
        )
    }

    var body: some View {
        Form(documentEditor: documentEditor) {
            footerView
        }
    }

    private var footerView: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("Save Draft")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .frame(height: 48)
                .background(Color(UIColor.systemGray5))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }

            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("Submit")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .frame(height: 48)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(UIColor.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
        )
    }

    private static func loadDoc(named name: String) -> JoyDoc {
        let url = Bundle.main.url(forResource: name, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dict = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
        return JoyDoc(dictionary: dict)
    }
}

private class FooterExampleChangeHandler: FormChangeEvent {
    func onChange(changes: [Change], document: JoyDoc) {}
    func onFocus(event: Event) {}
    func onBlur(event: Event) {}
    func onUpload(event: UploadEvent) {}
    func onCapture(event: CaptureEvent) {}
    func onError(error: JoyfillError) {}
}
