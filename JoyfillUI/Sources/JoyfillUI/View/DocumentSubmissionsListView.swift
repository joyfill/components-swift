//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//  Created by Vikash on 04/02/24.
//

import SwiftUI

struct DocumentSubmissionsListView: View {
    var identifier: String
    var name: String
    
    @ObservedObject var documentsViewModel = DocumentsViewModel()
    
    var body: some View {
        Group {
            List {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(size: 20, weight: .semibold))
                    Text("Submissions")
                        .font(.system(size: 16, weight: .semibold)).foregroundStyle(.gray)
                }
                
                Button(action: {
                    documentsViewModel.createDocumentSubmission(identifier: identifier, completion: { joyDocJSON in
                        documentsViewModel.fetchDocumentSubmissions(identifier: identifier)
                    })
                }, label: {
                    Text("Fill New +")
                })
                
                ForEach(documentsViewModel.submissions) { submission in
                    NavigationLink {
                        FormView(identifier: submission.identifier)
                    } label: {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                    
                }
            }
        }.onAppear() {
            documentsViewModel.fetchDocumentSubmissions(identifier: identifier)
        }
    }
}

#Preview {
    DocumentSubmissionsListView(identifier: "sadfsedf efe  e erdocuments", name: "New Document")
}
