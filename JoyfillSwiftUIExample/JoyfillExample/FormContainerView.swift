//
//  FormContainerView.swift
//  JoyfillExample
//

import SwiftUI
import Joyfill
import JoyfillModel

struct FormContainerView: View {
    let documentEditor: DocumentEditor
    @ObservedObject var changeManager: ChangeManager
    @State private var showChangelogView = false
    let enableChangelogs: Bool

    init(document: JoyDoc, pageID: String, changeManager: ChangeManager, enableChangelogs: Bool = true) {
        self.documentEditor = DocumentEditor(document: document, mode: .fill, events: changeManager, pageID: pageID, navigation: true, isPageDuplicateEnabled: true)
        self.changeManager = changeManager
        self.enableChangelogs = enableChangelogs
    }

    var body: some View {
        VStack {
            if enableChangelogs {
                HStack {
                    Spacer()
                    
                    // Changelog button with badge
                    Button(action: {
                        showChangelogView = true
                    }) {
                        HStack {
                            Image(systemName: "list.clipboard")
                            Text("Logs")
                            if !changeManager.displayedChangelogs.isEmpty {
                                Text("\(changeManager.displayedChangelogs.count)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
            }
            
            Form(documentEditor: documentEditor)
            SaveButtonView(changeManager: changeManager, documentEditor: documentEditor)
        }
        .sheet(isPresented: $showChangelogView) {
            if enableChangelogs {
                ChangelogView(changeManager: changeManager)
            }
        }
    }
}
