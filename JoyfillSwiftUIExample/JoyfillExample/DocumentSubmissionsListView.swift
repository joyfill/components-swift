//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService
import Joyfill

struct DocumentSubmissionsListView: View {
    @State var documents: [Document] = []
    @State var document: JoyDoc?
    @State private var showDocumentDetails = false
    @State private var isloading = false
    @State private var showCameraScannerView = false
    @State private var scanResults: String = ""
    @State private var currentCaptureHandler: ((ValueUnion) -> Void)?

    let title: String
    private let apiService: APIService

    init(apiService: APIService, documents: [Document], title: String) {
        self.apiService = apiService
        self.documents = documents
        self.title = title
    }

    var body: some View {
        if isloading {
            ProgressView()
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("", destination: FormContainerView(document: document!, pageID: pageID, changeManager: changeManager), isActive: $showDocumentDetails)
                }
                Text("Document List")
                    .padding()
                    .font(.title.bold())
                List(documents) { submission in
                    Button(action: {
                        fetchDocument(submission)
//                        fetchLocalDocument()
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text(submission.name)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .sheet(isPresented: $showCameraScannerView) {
                if #available(iOS 16.0, *) {
                    CameraScanner(startScanning: $showCameraScannerView,
                                  scanResult: $scanResults,
                                  onSave: { result in
                        if let currentCaptureHandler = currentCaptureHandler {
                            currentCaptureHandler(.string(result))
                        }
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }

    private var pageID: String {
        return ""
    }

    private var changeManager: ChangeManager {
        ChangeManager(apiService: apiService, showImagePicker: showImagePicker, showScan: showScan)
    }

    private func showImagePicker(uploadHandler: ([String]) -> Void) {
        uploadHandler(["https://example.com/sample-image"])
    }

    private func showScan(captureHandler: @escaping (ValueUnion) -> Void) {
        currentCaptureHandler = captureHandler
        showCameraScannerView = true
        presentCameraScannerView()
    }

    private func fetchLocalDocument() {
        isloading = true
        DispatchQueue.global().async {
            self.document = sampleJSONDocument(fileName: "TableNewColumns")
            DispatchQueue.main.async {
                showDocumentDetails = true
                isloading = false
            }
        }
    }

    private func fetchDocument(_ submission: Document) {
        isloading = true
        apiService.fetchJoyDoc(identifier: submission.identifier) { result in
            DispatchQueue.main.async {
                isloading = false
                switch result {
                case .success(let data):
                    do {
                        if let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            self.document = JoyDoc(dictionary: dictionary)
                            showDocumentDetails = true
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print("error: \(error.localizedDescription)")
                }
            }
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
}

extension UIViewController {
    static func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
                                    .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
                                    .first) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
