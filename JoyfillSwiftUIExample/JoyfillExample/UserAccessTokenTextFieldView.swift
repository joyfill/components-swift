//
//  ContentView.swift
//  TextFieldUser
//
//  Created by Babblu Bhaiya on 05/11/24.
//

import SwiftUI
import JoyfillAPIService

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
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
