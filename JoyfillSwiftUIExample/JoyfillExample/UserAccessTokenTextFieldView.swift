import SwiftUI
import JoyfillAPIService
import JoyfillModel

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    @State private var warningMessage: String? = nil
    @State var templateAndDocuments: ([Document], [Document]) = ([], [])
    @State var apiService: APIService? = nil
    @State private var isFetching: Bool = false  
    
    var body: some View {
        VStack {
            Text("Enter your access token here:")
                .bold()
            
            if let warning = warningMessage {
                Text(warning)
                    .foregroundColor(.red)
                    .padding()
            }
            
            TextEditor(text: $userAccessToken)
                .textFieldStyle(.roundedBorder)
                .frame(height: 200)
                .border(Color.black)
                .cornerRadius(3.0)
                .padding(10)
            
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
                Text(isFetching ? "Entering..." : "Enter")
                    .foregroundStyle(userAccessToken.isEmpty ? .gray : .blue)
            })
            .disabled(userAccessToken.isEmpty || isFetching)
            
            NavigationLink(
                destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                       result: templateAndDocuments)),
                isActive: $showTemplate
            ) {
                EmptyView()
            }
        }
        .padding()
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

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
