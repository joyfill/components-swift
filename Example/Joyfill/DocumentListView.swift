//
//  DocumentListView.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import SwiftUI
import JoyfillAPIService

public struct DocumentListView: View {
    public init(documentsViewModel: DocumentsViewModel = DocumentsViewModel()) {
        self.documentsViewModel = documentsViewModel
    }
    @ObservedObject var documentsViewModel = DocumentsViewModel()
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Templates List")
                    .font(.title.bold())
                List {
                    ForEach(documentsViewModel.documents) { document in
                        NavigationLink {
                            DocumentSubmissionsListView(identifier: document.identifier, name: document.name)
                        } label: {
                            HStack {
                                Image(systemName: "doc")
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                                Text(document.name)
                            }
                        }
                    }
                }
            }
            .onAppear() {
                documentsViewModel.fetchDocuments()
            }
        }
    }
}

#Preview {
    DocumentListView()
}
