import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplat: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter your access token here:")
                .font(.headline)
                .padding(.leading, 10)
            
            TextEditor(text: $userAccessToken)
                .frame(height: 200)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            
            NavigationLink {
                if !userAccessToken.isEmpty {
                    LazyView(TemplateListView(userAccessToken: userAccessToken))
                }
            } label: {
                Spacer()
                Text("Enter")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(userAccessToken.isEmpty ? .gray: .blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                Spacer()
            }
        }
        .padding()
    }
}

struct UserJsonTextFieldView: View {
    @State private var jsonString: String = ""
    @State private var errorMessage: String? = nil
    
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
            
            NavigationLink(destination: LazyView(destinationView())) {
                Spacer()
                Text("See Form")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(jsonString.isEmpty || errorMessage != nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                Spacer()
            }
            .disabled(jsonString.isEmpty || errorMessage != nil)
        }
        .padding()
    }
    
    func validateJSON() {
        guard !jsonString.isEmpty else {
            errorMessage = nil
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
