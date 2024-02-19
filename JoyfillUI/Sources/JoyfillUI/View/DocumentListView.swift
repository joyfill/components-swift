//
//  DocumentListView.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import SwiftUI

struct DocumentListView: View {
    @ObservedObject var documentsViewModel = DocumentsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Templates List")
                    .font(.title.bold())
                List {
                    ForEach(documentsViewModel.documents) { document in
                        NavigationLink {
                            DocumentSubmissionsListView(identifier: document.identifier, name: document.name)
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    Image(systemName: "doc")
                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                                    Text(document.name)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear() {
                documentsViewModel.fetchDocuments()
                print("view present")
            }
        }
    }
}

#Preview {
    DocumentListView()
}
