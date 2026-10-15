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
import UniformTypeIdentifiers

/// A JSON file read and parsed off the main thread.
private struct LoadedJSON {
    let dictionary: [String: Any]
    let name: String
    let byteCount: Int
}

private enum JSONLoadError: LocalizedError {
    case invalidFormat
    case notAnObject
    case unreadable

    var errorDescription: String? {
        switch self {
        case .invalidFormat: return "Invalid JSON format"
        case .notAnObject: return "JSON must be an object"
        case .unreadable: return "Could not read the file"
        }
    }
}

private enum InputMode: String, CaseIterable, Identifiable {
    case file
    case paste

    var id: String { rawValue }
    var title: String { self == .file ? "File" : "Paste" }
    var icon: String { self == .file ? "doc" : "doc.on.clipboard" }
}

/// Hands out request ids and accepts a completion only if it belongs to the newest request.
struct LatestRequestGate {
    private(set) var current = 0

    mutating func begin() -> Int {
        current += 1
        return current
    }

    mutating func invalidate() {
        current += 1
    }

    func accepts(_ id: Int) -> Bool {
        id == current
    }
}

/// Above this size the pasted text is parsed but not shown, since TextEditor chokes on megabytes of text.
private let largePasteThreshold = 200_000

struct UserJsonTextFieldView: View {
    @State private var inputMode: InputMode = .file
    @State private var pastedText: String = ""
    @State private var gate = LatestRequestGate()
    @State private var parseTask: Task<Void, Never>? = nil
    @State private var loadedJSON: LoadedJSON? = nil
    @State private var isLoadingFile: Bool = false
    @State private var isDropTargeted: Bool = false
    @State private var showFileImporter: Bool = false
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
    
    // MARK: - Input views

    private var dropZone: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    if isLoadingFile {
                        ProgressView()
                        Text("Reading file...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else if let loadedJSON {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text(loadedJSON.name)
                            .font(.headline)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 24)
                        Text(ByteCountFormatter.string(fromByteCount: Int64(loadedJSON.byteCount), countStyle: .file))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Image(systemName: isDropTargeted ? "arrow.down.doc.fill" : "square.and.arrow.down")
                            .font(.system(size: 40))
                            .foregroundColor(isDropTargeted ? .blue : .secondary)
                        Text(isDropTargeted ? "Release to load" : "Drag & drop a .json file here")
                            .font(.headline)
                        Text("or choose one below")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDropTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isDropTargeted ? Color.blue : Color.gray.opacity(0.4),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
                .animation(.easeInOut(duration: 0.15), value: isDropTargeted)
                .onDrop(of: [UTType.json, UTType.fileURL], isTargeted: $isDropTargeted) { providers in
                    handleDrop(providers)
                }

                if loadedJSON != nil {
                    Button(action: resetInput) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.blue)
                            .background(Circle().fill(.white))
                            .imageScale(.large)
                            .padding(12)
                    }
                }
            }

            Button {
                showFileImporter = true
            } label: {
                Label("Choose File", systemImage: "folder")
            }
            .buttonStyle(.bordered)
            .disabled(isLoadingFile)
        }
    }

    private var pasteEditor: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(get: { pastedText }, set: { newText in
                    pastedText = newText
                    scheduleParse(newText)
                }))
                    .font(.system(.footnote, design: .monospaced))
                    .frame(height: 180)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )

                if pastedText.isEmpty {
                    Text(loadedJSON == nil ? "Paste your JSON here..." : "Large JSON loaded from the clipboard (not shown)")
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 12) {
                Button(action: pasteFromClipboard) {
                    Label("Paste from Clipboard", systemImage: "doc.on.clipboard")
                }
                .buttonStyle(.bordered)

                if !pastedText.isEmpty || loadedJSON != nil {
                    Button(role: .destructive, action: resetInput) {
                        Label("Clear", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    @ViewBuilder
    private var statusRow: some View {
        if isLoadingFile {
            HStack(spacing: 8) {
                ProgressView()
                Text("Reading JSON...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } else if let errorMessage {
            statusChip(icon: "exclamationmark.triangle.fill", text: errorMessage, color: .red)
        } else if let loadedJSON {
            let size = ByteCountFormatter.string(fromByteCount: Int64(loadedJSON.byteCount), countStyle: .file)
            statusChip(icon: "checkmark.seal.fill", text: "Valid JSON · \(size)", color: .green)
        }
    }

    private func statusChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(text)
                .lineLimit(2)
        }
        .font(.subheadline)
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(color.opacity(0.12)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Section
            VStack(alignment: .leading, spacing: 6) {
                Text("JSON Input")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Load a form from a file, or paste its JSON")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            // Input mode switch
            Picker("Input", selection: $inputMode) {
                ForEach(InputMode.allCases) { mode in
                    Label(mode.title, systemImage: mode.icon).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .onChange(of: inputMode) { _ in
                resetInput()
            }

            // Input card
            Group {
                switch inputMode {
                case .file: dropZone
                case .paste: pasteEditor
                }
            }
            .padding(.horizontal, 20)
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    loadJSONFile(at: url)
                case .failure(let error):
                    failInput(error.localizedDescription)
                }
            }

            statusRow
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
                    guard errorMessage == nil, let dictionary = loadedJSON?.dictionary, !isFetching else { return }
                    isFetching = true
                    preparedEditor = nil

                    let cm = changeManagerWrapper.changeManager
                    Task.detached {
                        let license = await useCustomLicense ? customLicenseKey : licenseKey
                        let editor = DocumentEditor(
                            document: JoyDoc(dictionary: dictionary),
                            config: DocumentEditorConfig(
                                mode: .fill,
                                events: cm,
                                license: license,
                                validateSchema: true,
                                page: PageConfig(
                                    navigation: true,
                                    enableDuplicates: true,
                                    enableDeletes: true,
                                    currentPageID: ""
                                ),
                                display: DisplayConfig(singleClickRowEdit: true)
                            )
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
                        loadedJSON == nil || errorMessage != nil
                        ? Color.gray.opacity(0.3)
                        : Color.blue
                    )
                    .cornerRadius(16)
                    .shadow(color: (loadedJSON == nil || errorMessage != nil) ? .clear : .black.opacity(0.1),
                            radius: 2, x: 0, y: 1)
                }
                .disabled(loadedJSON == nil || errorMessage != nil || isFetching || isLoadingFile)
                
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
                            // Fallback (should rarely happen): the editor is always prepared before navigating
                            FormDestinationView(
                                jsonString: "",
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
    
    // MARK: - JSON file loading (off the main thread)

    /// Parses JSON bytes; call from a background queue.
    private nonisolated static func parseJSON(data: Data, name: String) -> Result<LoadedJSON, JSONLoadError> {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) else {
            return .failure(.invalidFormat)
        }
        guard let dictionary = object as? [String: Any] else { return .failure(.notAnObject) }
        return .success(LoadedJSON(dictionary: dictionary, name: name, byteCount: data.count))
    }

    /// Reads and parses a file; call from a background queue.
    private nonisolated static func readJSON(at url: URL) -> Result<LoadedJSON, JSONLoadError> {
        guard let data = try? Data(contentsOf: url, options: .mappedIfSafe) else { return .failure(.unreadable) }
        return parseJSON(data: data, name: url.lastPathComponent)
    }

    /// Starts a new request, invalidating any load still in flight.
    private func beginLoading() -> Int {
        parseTask?.cancel()
        let id = gate.begin()
        isLoadingFile = true
        errorMessage = nil
        loadedJSON = nil
        return id
    }

    private func resetInput() {
        parseTask?.cancel()
        gate.invalidate()
        isLoadingFile = false
        loadedJSON = nil
        errorMessage = nil
        pastedText = ""
    }

    /// Reports an input problem and drops any load still in flight.
    private func failInput(_ message: String) {
        parseTask?.cancel()
        gate.invalidate()
        isLoadingFile = false
        errorMessage = message
    }

    /// Typed or pasted text: debounced, parsed off the main thread.
    private func scheduleParse(_ text: String) {
        let id = beginLoading()
        guard !text.isEmpty else {
            isLoadingFile = false
            return
        }
        parseTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            if Task.isCancelled { return }
            let result = await Task.detached(priority: .userInitiated) {
                Self.parseJSON(data: Data(text.utf8), name: "Pasted JSON")
            }.value
            finishLoading(result, id: id)
        }
    }

    /// Large clipboard text skips the editor entirely and is parsed straight off the main thread.
    private func pasteFromClipboard() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else {
            // iOS returns nil until the user answers its paste prompt, so tell the two cases apart.
            failInput(UIPasteboard.general.hasStrings ? "Allow paste when asked, then tap again" : "The clipboard is empty")
            return
        }
        if text.utf8.count <= largePasteThreshold {
            pastedText = text
            scheduleParse(text)
            return
        }
        let id = beginLoading()
        pastedText = ""
        parseTask = Task {
            let result = await Task.detached(priority: .userInitiated) {
                Self.parseJSON(data: Data(text.utf8), name: "Pasted JSON")
            }.value
            finishLoading(result, id: id)
        }
    }

    /// Applies a result only if its request is still the newest one.
    private func finishLoading(_ result: Result<LoadedJSON, JSONLoadError>, id: Int) {
        guard gate.accepts(id) else { return }
        isLoadingFile = false
        switch result {
        case .success(let loaded): loadedJSON = loaded
        case .failure(let error): errorMessage = error.localizedDescription
        }
    }

    /// Picker path: the URL is security-scoped.
    private func loadJSONFile(at url: URL) {
        let id = beginLoading()
        Task.detached(priority: .userInitiated) {
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            let result = Self.readJSON(at: url)
            await MainActor.run { finishLoading(result, id: id) }
        }
    }

    /// Drop path: the provider's temp file only lives for the callback, so it is read inside it.
    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        let jsonID = UTType.json.identifier
        let fileURLID = UTType.fileURL.identifier
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(jsonID) }) {
            let id = beginLoading()
            provider.loadFileRepresentation(forTypeIdentifier: jsonID) { url, _ in
                let result: Result<LoadedJSON, JSONLoadError> = url.map { Self.readJSON(at: $0) } ?? .failure(.unreadable)
                DispatchQueue.main.async { finishLoading(result, id: id) }
            }
            return true
        }
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(fileURLID) }) {
            let id = beginLoading()
            provider.loadItem(forTypeIdentifier: fileURLID, options: nil) { item, _ in
                var fileURL: URL?
                if let data = item as? Data { fileURL = URL(dataRepresentation: data, relativeTo: nil) }
                else if let url = item as? URL { fileURL = url }
                let result: Result<LoadedJSON, JSONLoadError> = fileURL.map { Self.readJSON(at: $0) } ?? .failure(.unreadable)
                DispatchQueue.main.async { finishLoading(result, id: id) }
            }
            return true
        }
        failInput("Drop a .json file")
        return false
    }
}

