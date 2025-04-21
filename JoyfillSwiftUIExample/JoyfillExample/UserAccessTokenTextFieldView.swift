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
            VStack(alignment: .leading, spacing: 12) {
                Text("Enter your access token here:")
                    .font(.headline)
                    .padding(.leading, 10)
                
                if let warning = warningMessage {
                    Text(warning)
                        .foregroundColor(.red)
                }
                
                TextEditor(text: $userAccessToken)
                    .frame(height: 200)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                
                Button(action: {
                    isFetching = true
                    self.apiService = APIService(accessToken: userAccessToken,
                                                 baseURL: "https://api-joy.joyfill.io/v1")
                    fetchTemplates {
                        if warningMessage != nil || !(warningMessage?.isEmpty ?? false) {
                            isFetching = false
                        }
                    }
                }, label: {
                    Spacer()
                    Text(isFetching ? "Entering..." : "Enter")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(userAccessToken.isEmpty ? .gray: .blue)
                        .cornerRadius(8)
                    Spacer()
                })
                .disabled(userAccessToken.isEmpty || isFetching)
                
                NavigationLink(
                    destination: LazyView(TemplateListView(userAccessToken: userAccessToken,
                                                           result: templateAndDocuments, isAlreadyToken: false)),
                    isActive: $showTemplate
                ) {
                    EmptyView()
                        .padding()
                }
            }.padding()
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter your JSON here:")
                .font(.headline)
                .padding(.leading, 10)
            
            TextEditor(text: $jsonString)
                .frame(height: 200)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                .onChange(of: jsonString) { _ in
                    validateJSON()
                }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.leading, 10)
            }
            
            NavigationLink(destination: LazyView(destinationView())) {
                Spacer()
                Text("See Form")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(jsonString.isEmpty || errorMessage != nil ? Color.gray : Color.blue)
                    .cornerRadius(8)
                Spacer()
            }
            .disabled(jsonString.isEmpty || errorMessage != nil)
            
        }
        .padding()
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
