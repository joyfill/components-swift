import SwiftUI
import JoyfillAPIService

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbiI6IjY1Yzc2NDI5ZGQ5NjIwNmM3ZTA3ZWQ5YiJ9.OhI3aY3na-3f1WWND8y9zU8xXo4R0SIUSR2BLB3vbsk"
    @State var showTemplat: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Enter your access token here:")
                    .bold()

                TextEditor(text: $userAccessToken)
                    .textFieldStyle(.roundedBorder)
                    .frame(height: 200)
                    .border(.black)
                    .cornerRadius(3.0)
                    .padding(10)
                
                NavigationLink {
                    if !userAccessToken.isEmpty {
                        LazyView(TemplateListView(userAccessToken: userAccessToken))
                    }
                } label: {
                    Text("Enter")
                        .foregroundStyle(userAccessToken.isEmpty ? .gray: .blue)
                }
            }
            .padding()
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
