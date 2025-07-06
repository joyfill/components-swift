import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService
import JoyfillModel
import UIKit

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    @State private var warningMessage: String? = nil
    @State var templateAndDocuments: ([Document], [Document]) = ([], [])
    @State var apiService: APIService? = nil
    @State private var isFetching: Bool = false
    var isAlreadyToken: Bool
    let enableChangelogs: Bool
    
    init(isAlreadyToken: Bool, enableChangelogs: Bool = false) {
        self.isAlreadyToken = isAlreadyToken
        self.enableChangelogs = enableChangelogs
    }
    
    var body: some View {
        if isAlreadyToken {
            NavigationLink(
                destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                       result: templateAndDocuments, isAlreadyToken: true, enableChangelogs: enableChangelogs)),
                isActive: isAlreadyToken ? Binding.constant(true) : $showTemplate
            ) {
                EmptyView()
            }
        } else {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Access Token")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Enter your access token to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let warning = warningMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(warning)
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
                        TextEditor(text: $userAccessToken)
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
                        
                        if !userAccessToken.isEmpty {
                            Button(action: {
                                userAccessToken = ""
                                warningMessage = nil
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
                
                // Button Section
                VStack(spacing: 16) {
                    Button(action: {
                        isFetching = true
                        self.apiService = APIService(accessToken: userAccessToken,
                                                     baseURL: "https://api-joy.joyfill.io/v1")
                        fetchTemplates {
                            if warningMessage != nil || !(warningMessage?.isEmpty ?? false) {
                                isFetching = false
                            }
                        }
                    }) {
                        HStack {
                            Spacer()
                            if isFetching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }
                            Text(isFetching ? "Verifying..." : "Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .frame(height: 54)
                        .foregroundStyle(.white)
                        .background(
                            userAccessToken.isEmpty
                            ? Color.gray.opacity(0.3)
                            : Color.blue
                        )
                        .cornerRadius(16)
                        .shadow(color: userAccessToken.isEmpty ? .clear : .black.opacity(0.1),
                                radius: 2, x: 0, y: 1)
                    }
                    .disabled(userAccessToken.isEmpty || isFetching)
                    
                    if !userAccessToken.isEmpty {
                        Text("Token length: \(userAccessToken.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 20)
                
                NavigationLink(
                    destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                           result: templateAndDocuments, isAlreadyToken: false, enableChangelogs: enableChangelogs)),
                    isActive: $showTemplate
                ) {
                    EmptyView()
                }
            }
            .padding(.vertical, 24)
        }
    }
                    
    private func fetchTemplates(page: Int = 1, limit: Int = 10, completion: @escaping () -> Void) {
        apiService?.fetchTemplates(page: page, limit: limit) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let templates):
                    self.templateAndDocuments.0 = templates
                    warningMessage = nil
                    showTemplate = true
                    isFetching = false
                case .failure(let error):
                    warningMessage = "Invalid token: \(error.localizedDescription)"
                }
                completion()
            }
        }
    }
}

struct UserJsonTextFieldView: View {
    @State private var jsonString: String = ""
    @State private var errorMessage: String? = nil
    @State var showCameraScannerView: Bool = false
    @State private var currentCaptureHandler: ((ValueUnion) -> Void)?
    @State var scanResults: String = ""
    @State private var isFetching: Bool = false
    @State private var showChangelogView = false
    @State private var shouldNavigate: Bool = false
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
            
            // Button Section
            VStack(spacing: 16) {
                Button(action: {
                    isFetching = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFetching = false
                        shouldNavigate = true
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
                    destination: FormDestinationView(
                        jsonString: jsonString,
                        changeManager: changeManagerWrapper.changeManager,
                        showChangelogView: $showChangelogView,
                        enableChangelogs: enableChangelogs
                    ),
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

// Separate view for the form destination that properly manages DocumentEditor state
struct FormDestinationView: View {
    let jsonString: String
    @ObservedObject var changeManager: ChangeManager
    @Binding var showChangelogView: Bool
    @StateObject private var documentEditor: DocumentEditor
    let enableChangelogs: Bool
    
    init(jsonString: String, changeManager: ChangeManager, showChangelogView: Binding<Bool>, enableChangelogs: Bool) {
        self.jsonString = jsonString
        self.changeManager = changeManager
        self._showChangelogView = showChangelogView
        self.enableChangelogs = enableChangelogs
        
        // Create DocumentEditor ONCE during initialization
        let jsonData = jsonString.data(using: .utf8) ?? Data()
        let dictionary = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]) ?? [:]
        
        self._documentEditor = StateObject(wrappedValue: DocumentEditor(
            document: JoyDoc(dictionary: dictionary),
            mode: .fill,
            events: changeManager,
            pageID: "",
            navigation: true
        ))
    }
    
    var body: some View {
        VStack {
            if enableChangelogs {
                HStack {
                    Spacer()
                    
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
            SaveButtonView(changeManager: changeManager, documentEditor: documentEditor, showBothButtons: false)
        }
        .sheet(isPresented: $showChangelogView) {
            ChangelogView(changeManager: changeManager)
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
extension UIViewController {
    static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

// Wrapper class to handle ChangeManager initialization and scan functionality
class ChangeManagerWrapper: ObservableObject {
    @Published var changeManager: ChangeManager
    private var scanHandler: ((@escaping (ValueUnion) -> Void) -> Void)?
    
    init() {
        let imagePicker = ImagePicker()
        
        // Initialize ChangeManager with a simple closure first
        self.changeManager = ChangeManager(
            apiService: APIService(accessToken: "", baseURL: ""),
            showImagePicker: imagePicker.showPickerOptions,
            showScan: { captureHandler in
                // Provide default implementation
                captureHandler(.string("default"))
            }
        )
    }
    
    func setScanHandler(_ handler: @escaping (@escaping (ValueUnion) -> Void) -> Void) {
        self.scanHandler = handler
        
        // Recreate the ChangeManager with the proper scan handler
        let imagePicker = ImagePicker()
        self.changeManager = ChangeManager(
            apiService: APIService(accessToken: "", baseURL: ""),
            showImagePicker: imagePicker.showPickerOptions,
            showScan: { [weak self] captureHandler in
                self?.scanHandler?(captureHandler) ?? captureHandler(.string("default"))
            }
        )
    }
}

// MARK: - Option Selection View

struct OptionSelectionView: View {
    @State private var selectedOption: OptionType? = nil
    @State private var isNavigating: Bool = false
    
    enum OptionType: CaseIterable {
        case token
        case jsonToForm
        case testingChangelogs
        
        var title: String {
            switch self {
            case .token:
                return "Token"
            case .jsonToForm:
                return "JSON to Form"
            case .testingChangelogs:
                return "Testing Changelogs"
            }
        }
        
        var description: String {
            switch self {
            case .token:
                return "Enter your access token to work with templates"
            case .jsonToForm:
                return "Input JSON data to create forms directly"
            case .testingChangelogs:
                return "Use both token and JSON with changelog testing"
            }
        }
        
        var icon: String {
            switch self {
            case .token:
                return "key.fill"
            case .jsonToForm:
                return "doc.text.fill"
            case .testingChangelogs:
                return "testtube.2"
            }
        }
        
        var color: Color {
            switch self {
            case .token:
                return .blue
            case .jsonToForm:
                return .green
            case .testingChangelogs:
                return .orange
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header Section
                VStack(spacing: 16) {
                    Image(systemName: "app.badge")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Joyfill Example")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Choose how you'd like to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Options Section
                VStack(spacing: 16) {
                    ForEach(OptionType.allCases, id: \.self) { option in
                        OptionCard(
                            option: option,
                            isSelected: selectedOption == option
                        ) {
                            selectedOption = option
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Continue Button
                NavigationLink(
                    destination: destinationView(),
                    isActive: Binding(
                        get: { isNavigating },
                        set: { newValue in
                            isNavigating = newValue
                            if !newValue {
                                // Reset selectedOption when navigation is dismissed
                                selectedOption = nil
                            }
                        }
                    )
                ) {
                    Button(action: {
                        if selectedOption != nil {
                            isNavigating = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 54)
                        .background(
                            selectedOption == nil
                            ? Color.gray.opacity(0.3)
                            : Color.blue
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: selectedOption == nil ? .clear : .black.opacity(0.1),
                            radius: 2, x: 0, y: 1
                        )
                    }
                    .disabled(selectedOption == nil)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func destinationView() -> some View {
        switch selectedOption {
        case .token:
            ScrollView {
                VStack {
                    UserAccessTokenTextFieldView(isAlreadyToken: false, enableChangelogs: false)
                }
            }
            .modifier(KeyboardDismissModifier())
        case .jsonToForm:
            ScrollView {
                VStack {
                    UserJsonTextFieldView(enableChangelogs: false)
                }
            }
            .modifier(KeyboardDismissModifier())
        case .testingChangelogs:
            TestingChangelogsView()
        case .none:
            EmptyView()
        }
    }
}

struct OptionCard: View {
    let option: OptionSelectionView.OptionType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(option.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 24))
                        .foregroundColor(option.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(option.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? option.color : .gray.opacity(0.3))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? option.color : Color.gray.opacity(0.15),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TestingChangelogsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Testing Changelogs")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Both token and JSON options with changelog testing enabled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Token Section
                UserAccessTokenTextFieldView(isAlreadyToken: false, enableChangelogs: true)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // JSON Section
                UserJsonTextFieldView(enableChangelogs: true)
                
                // Changelog Testing Note
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("Changelog Testing Enabled")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text("This mode includes additional logging and testing features for development purposes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 24)
        }
        .modifier(KeyboardDismissModifier())
    }
}

