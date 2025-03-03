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
                        .padding()
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(userAccessToken.isEmpty ? .gray: .blue)
                        .foregroundColor(.white)
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
                }
            }
            .padding()
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
