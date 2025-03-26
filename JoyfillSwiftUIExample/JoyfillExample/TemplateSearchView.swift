import SwiftUI

public struct TemplateSearchView: View {
    @Binding var searchText: String

    public var body: some View {
        HStack {
            TextField("Search templates", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    HStack {
                        Spacer()
                        if !searchText.isEmpty {
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.all, 4)
                            }
                        }
                    }
                )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    TemplateSearchView(searchText: .constant(""))
}
