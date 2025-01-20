//
//  CameraScanner.swift
//  ScanningDataCamera
//
//  Created by Runhua Huang on 2022/6/8.
//
// Current Issue:
//   1. When view been presented, the ugly animation.

import SwiftUI

@available(iOS 16.0, *)
struct CameraScanner: View {
    @Binding var startScanning: Bool
    @Binding var scanResult: String
    @State private var selectedText: String = ""
    @Environment(\.presentationMode) var presentationMode
    var onSave: (String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                CameraScannerViewController(
                    startScanning: $startScanning,
                    scanResult: $selectedText
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            onSave(selectedText)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save")
                        }
                        .disabled(selectedText.isEmpty)
                    }
                }
                .interactiveDismissDisabled(true)

                // Optional: Display selected text for user confirmation
                if !selectedText.isEmpty {
                    Text("Selected Text:")
                        .font(.headline)
                        .padding(.top)
                    Text(selectedText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding()
                }
            }
        }
    }
}






