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
    
    var body: some View {
        if isAlreadyToken {
            NavigationLink(
                destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                       result: templateAndDocuments, isAlreadyToken: true)),
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
                                                           result: templateAndDocuments, isAlreadyToken: false)),
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
    
    private var changeManager: ChangeManager {
        ChangeManager(apiService: APIService(accessToken: "", baseURL: ""), showImagePicker: showImagePicker, showScan: showScan)
    }
    
    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
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
                NavigationLink(destination: LazyView(destinationView())) {
                    HStack {
                        Spacer()
                        Text("View Form")
                            .font(.headline)
                            .fontWeight(.semibold)
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
                .disabled(jsonString.isEmpty || errorMessage != nil)
                
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
    
    func destinationView() -> AnyView {
        guard !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            return AnyView(Text("Invalid JSON"))
        }
        
        do {
            let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any] ?? [:]
            let documentEditor = DocumentEditor(
                document: JoyDoc(dictionary: dictionary),
                mode: .fill,
                events: changeManager,
                pageID: "",
                navigation: true
            )
            return AnyView(LazyView(Form(documentEditor: documentEditor)))
        } catch {
            return AnyView(Text("Invalid JSON"))
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

