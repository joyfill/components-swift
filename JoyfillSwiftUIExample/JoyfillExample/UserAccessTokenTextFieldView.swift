import SwiftUI
import Joyfill
import JoyfillModel
import JoyfillAPIService
import JoyfillModel

struct UserAccessTokenTextFieldView: View {
    @State private var userAccessToken: String = ""
    @State var showTemplate: Bool = false
    @State private var warningMessage: String? = nil
    @State var templateAndDocuments: ([Document], [Document]) = ([], [])
    @State var apiService: APIService? = nil
    @State private var isFetching: Bool = false
    @State private var isAnimating: Bool = false
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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to Joyfill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Enter your access token to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    // Token Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Access Token")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $userAccessToken)
                            .frame(height: 150)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Warning Message
                    if let warning = warningMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(warning)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                        .transition(.opacity)
                    }
                    
                    // Submit Button
                    Button(action: {
                        withAnimation {
                            isFetching = true
                            self.apiService = APIService(accessToken: userAccessToken,
                                                         baseURL: "https://api-joy.joyfill.io/v1")
                            fetchTemplates {
                                if warningMessage != nil || !(warningMessage?.isEmpty ?? false) {
                                    isFetching = false
                                }
                            }
                        }
                    }) {
                        HStack {
                            if isFetching {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 18))
                            }
                            Text(isFetching ? "Verifying..." : "Continue")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            userAccessToken.isEmpty ? Color.gray.opacity(0.5) :
                                isFetching ? Color.blue.opacity(0.8) : Color.blue
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(userAccessToken.isEmpty || isFetching)
                    .scaleEffect(isAnimating ? 0.95 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
                
    private func fetchTemplates(page: Int = 1, limit: Int = 10, completion: @escaping () -> Void) {
        apiService?.fetchTemplates(page: page, limit: limit) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let templates):
                    withAnimation {
                        self.templateAndDocuments.0 = templates
                        warningMessage = nil
                        showTemplate = true
                        isFetching = false
                    }
                case .failure(let error):
                    withAnimation {
                        warningMessage = "Invalid token: \(error.localizedDescription)"
                        isFetching = false
                    }
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
    @State private var isAnimating: Bool = false
    
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("JSON Form Editor")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Enter your JSON to create a form")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                // JSON Input Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("JSON Input")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $jsonString)
                        .frame(height: 200)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: jsonString) { _ in
                            validateJSON()
                        }
                }
                
                // Error Message
                if let error = errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                    .transition(.opacity)
                }
                
                // See Form Button
                NavigationLink(destination: LazyView(destinationView())) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 18))
                        Text("See Form")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        jsonString.isEmpty || errorMessage != nil ? Color.gray.opacity(0.5) : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .disabled(jsonString.isEmpty || errorMessage != nil)
                .scaleEffect(isAnimating ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
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
            let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: Any]
            guard let dict = dictionary else {
                errorMessage = "Invalid JSON format"
                return
            }
            // Check if the JSON has the required structure
            guard let files = dict["files"] as? [[String: Any]], !files.isEmpty,
                  let views = files[0]["views"] as? [[String: Any]], !views.isEmpty else {
                errorMessage = "JSON must contain 'files' array with at least one file containing 'views'"
                return
            }
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
