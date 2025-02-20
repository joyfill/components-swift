import SwiftUI
import JoyfillAPIService

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    
    var body: some View {
        VStack {
            Text("Enter your access token here:")
                .bold()
            
            TextEditor(text: $userAccessToken)
                .textFieldStyle(.roundedBorder)
                .frame(height: 200)
                .border(.black)
                .cornerRadius(3.0)
                .padding(10)
            
            Button(action: {
                showTemplate = true
            }, label: {
                Text("Enter")
                    .foregroundStyle(userAccessToken.isEmpty ? .gray: .blue)
            })
            
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
