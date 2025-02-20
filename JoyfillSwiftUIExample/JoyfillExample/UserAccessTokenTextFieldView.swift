import SwiftUI
import JoyfillAPIService

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    @State private var warningMessage: String? = nil
    
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
                .border(.black)
                .cornerRadius(3.0)
                .padding(10)
            
            Button(action: {
                let apiService = APIService(accessToken: userAccessToken,
                                            baseURL: "https://api-joy.joyfill.io/v1")
                apiService.fetchTemplates { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            warningMessage = nil
                            showTemplate = true
                        case .failure(let error):
                            warningMessage = "Invalid token: \(error.localizedDescription)"
                        }
                    }
                }
            }, label: {
                Text("Enter")
                    .foregroundStyle(userAccessToken.isEmpty ? .gray: .blue)
            })
            .disabled(userAccessToken.isEmpty)
            
            NavigationLink(destination: LazyView(TemplateListView(userAccessToken: userAccessToken)), isActive: $showTemplate) {
                EmptyView()
            }
        }
        .padding()
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
