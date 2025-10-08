//
//  SwiftUIView.swift
//  JoyfillExample
//
//  Created by Vivek on 30/09/25.
//

import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService
import JoyfillModel
import UIKit

struct UserJsonTextFieldView: View {
    @State private var jsonString: String = ""
    @State private var errorMessage: String? = nil
    @State var showCameraScannerView: Bool = false
    @State private var currentCaptureHandler: ((ValueUnion) -> Void)?
    @State var scanResults: String = ""
    @State private var isFetching: Bool = false
    @State private var showChangelogView = false
    @State private var showPublicApisView = false
    @State private var shouldNavigate: Bool = false
    @State private var preparedEditor: DocumentEditor? = nil
    @State private var useCustomLicense: Bool = false
    @State private var customLicenseKey: String = ""
    let imagePicker = ImagePicker()
    let enableChangelogs: Bool
    
    // Use @StateObject with a custom wrapper
    @StateObject private var changeManagerWrapper: ChangeManagerWrapper = ChangeManagerWrapper()
    
    init(enableChangelogs: Bool = false) {
        self.enableChangelogs = enableChangelogs
    }
    
    private func showScan(captureHandler: @escaping (ValueUnion) -> Void) {
        currentCaptureHandler = captureHandler
        showCameraScannerView = true
        presentCameraScannerView()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header Section
            VStack(alignment: .leading, spacing: 8) {
                Text("JSON Input")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Enter your JSON data below")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let errorMessage = errorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 20)
            
            // TextEditor Section
            VStack(spacing: 0) {
                ZStack(alignment: .trailing) {
                    TextEditor(text: $jsonString)
                        .font(.system(.body, design: .monospaced))
                        .frame(height: 180)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .onChange(of: jsonString) { _ in
                            validateJSON()
                        }
                    
                    if !jsonString.isEmpty {
                        Button(action: {
                            jsonString = ""
                            errorMessage = nil
                            validateJSON()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.blue)
                                .background(Circle().fill(.white))
                                .imageScale(.large)
                                .padding(16)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Custom License Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Toggle("Use Custom License Key", isOn: $useCustomLicense)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20)
                
                if useCustomLicense {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom License Key")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ZStack(alignment: .trailing) {
                            TextEditor(text: $customLicenseKey)
                                .font(.system(.body, design: .monospaced))
                                .frame(height: 120)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.05))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                            
                            if !customLicenseKey.isEmpty {
                                Button(action: {
                                    customLicenseKey = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(.white))
                                        .imageScale(.large)
                                        .padding(16)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if !customLicenseKey.isEmpty {
                            Text("License key length: \(customLicenseKey.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: useCustomLicense)
            
            // Button Section
            VStack(spacing: 16) {
                Button(action: {
                    guard errorMessage == nil, !jsonString.isEmpty, !isFetching else { return }
                    isFetching = true
                    preparedEditor = nil

                    let json = jsonString
                    let cm = changeManagerWrapper.changeManager
                    Task.detached {
                        let jsonData = json.data(using: .utf8) ?? Data()
                        let dictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]) ?? [:]
                        let license = await useCustomLicense ? customLicenseKey : licenseKey
                        let editor = DocumentEditor(
                            document: JoyDoc(dictionary: dictionary),
                            mode: .fill,
                            events: cm,
                            pageID: "",
                            navigation: true,
                            validateSchema: false,
                            license: license
                        )
                        await MainActor.run {
                            self.preparedEditor = editor
                            self.isFetching = false
                            self.shouldNavigate = true
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        if isFetching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("View Form")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .frame(height: 54)
                    .foregroundStyle(.white)
                    .background(
                        jsonString.isEmpty || errorMessage != nil
                        ? Color.gray.opacity(0.3)
                        : Color.blue
                    )
                    .cornerRadius(16)
                    .shadow(color: (jsonString.isEmpty || errorMessage != nil) ? .clear : .black.opacity(0.1),
                            radius: 2, x: 0, y: 1)
                }
                .disabled(jsonString.isEmpty || errorMessage != nil || isFetching)
                
                NavigationLink(
                    destination: Group {
                        if let editor = preparedEditor {
                            FormDestinationView(
                                editor: editor,
                                changeManager: changeManagerWrapper.changeManager,
                                showChangelogView: $showChangelogView,
                                enableChangelogs: enableChangelogs,
                                showPublicApis: $showPublicApisView,
                                license: useCustomLicense ? customLicenseKey : licenseKey
                            )
                        } else {
                            // Fallback (should rarely happen): keep old path
                            FormDestinationView(
                                jsonString: jsonString,
                                changeManager: changeManagerWrapper.changeManager,
                                showChangelogView: $showChangelogView,
                                enableChangelogs: enableChangelogs,
                                showPublicApis: $showPublicApisView,
                                license: useCustomLicense ? customLicenseKey : licenseKey
                            )
                        }
                    },
                    isActive: $shouldNavigate
                ) {
                    EmptyView()
                }
                
                if !jsonString.isEmpty {
                    Text("JSON length: \(jsonString.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 24)
        .onAppear {
            // Set up the scan handler after the view appears
            changeManagerWrapper.setScanHandler(showScan)
        }
    }
    
    func presentCameraScannerView() {
        guard let topVC = UIViewController.topViewController() else {
            print("No top view controller found.")
            return
        }
        let hostingController: UIHostingController<AnyView>
        if #available(iOS 16.0, *) {
            let swiftUIView = CameraScanner(
                startScanning: $showCameraScannerView,
                scanResult: $scanResults,
                onSave: { result in
                    if let currentCaptureHandler = currentCaptureHandler {
                        currentCaptureHandler(.string(result))
                    }
                }
            )
            hostingController = UIHostingController(rootView: AnyView(swiftUIView))
        } else {
            // Fallback on earlier versions
            let fallbackView = Text("Camera scanner is not available on this version.")
                .padding()
                .multilineTextAlignment(.center)
            hostingController = UIHostingController(rootView: AnyView(fallbackView))
        }
        
        topVC.present(hostingController, animated: true, completion: nil)
    }
    
    func validateJSON() {
        guard !jsonString.isEmpty else {
            errorMessage = "Please enter a JSON object"
            return
        }
        guard let jsonData = jsonString.data(using: .utf8) else {
            errorMessage = "Invalid JSON encoding"
            return
        }
        do {
            _ = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            errorMessage = nil
        } catch {
            errorMessage = "Invalid JSON format"
        }
    }
}

