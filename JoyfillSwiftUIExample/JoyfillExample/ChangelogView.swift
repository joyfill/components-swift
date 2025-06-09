//
//  ChangelogView.swift
//  JoyfillExample
//
//  Created by Vivek on [Date]
//

import SwiftUI

struct ChangelogView: View {
    @ObservedObject var changeManager: ChangeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Changelogs (\(changeManager.displayedChangelogs.count))")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Button("Clear All") {
                        changeManager.displayedChangelogs.removeAll()
                    }
                    .foregroundColor(.red)
                }
                .padding()
                
                if changeManager.displayedChangelogs.isEmpty {
                    Spacer()
                    Text("No changelogs yet")
                        .foregroundColor(.gray)
                        .font(.title3)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(changeManager.displayedChangelogs.enumerated()), id: \.offset) { index, log in
                                ChangelogEntryView(log: log, index: index + 1)
                            }
                        }
                        .padding()
                    }
                    
                    HStack {
                        Button("Copy All Logs") {
                            let allLogs = changeManager.displayedChangelogs.joined(separator: "\n\n")
                            copyToClipboard(allLogs)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Export as JSON") {
                            exportAsJSON()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .navigationTitle("Change Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        // Show a toast or alert to confirm copy
        print("Copied to clipboard!")
    }
    
    private func exportAsJSON() {
        let jsonData = [
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "totalLogs": changeManager.displayedChangelogs.count,
            "logs": changeManager.displayedChangelogs
        ] as [String : Any]
        
        if let jsonString = try? JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted),
           let jsonText = String(data: jsonString, encoding: .utf8) {
            copyToClipboard(jsonText)
        }
    }
}

struct ChangelogEntryView: View {
    let log: String
    let index: Int
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("#\(index)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .leading)
                
                Text(log)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(isExpanded ? nil : 3)
                
                Spacer()
                
                Button(action: {
                    copyToClipboard(log)
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Spacer()
                
                Button(isExpanded ? "Collapse" : "Expand") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        print("Copied entry to clipboard!")
    }
}
