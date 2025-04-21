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
    @State private var isloading = true
    @State private var showCameraScannerView = false
    @State private var scanResults: String = ""
    @State private var currentCaptureHandler: ((ValueUnion) -> Void)?
    @State var fetchSubmissions = true
    @State var identifier: String
    @State private var currentDocumentPage: Int = 1
    @State private var isLoadingMoreDocuments: Bool = false
    @State private var hasMoreDocuments: Bool = true
    
    let title: String
    private let apiService: APIService
    
    init(apiService: APIService, identifier: String, title: String) {
        self.apiService = apiService
        self.title = title
        self.identifier = identifier
    }
    
    var body: some View {
        if isloading {
            ProgressView()
                .onAppear {
                    if fetchSubmissions {
                        fetchData()
                    }
                }
        } else {
            VStack(alignment: .leading) {
                if showDocumentDetails {
                    NavigationLink("", destination: FormContainerView(document: document!, pageID: pageID, changeManager: changeManager), isActive: $showDocumentDetails)
                }
                List {
                    Section(header: Text("Documents")
                        .font(.title.bold())) {
                            ForEach(documents) { submission in
                                Button(action: {
                                    fetchDocument(submission)
                                }) {
                                    HStack {
                                        Image(systemName: "doc")
                                        Text(submission.name)
                                    }
                                }
                                .onAppear {
                                    if submission == documents.last && documents.count >= 20 {
                                        loadMoreDocuments()
                                    }
                                }
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
                
                if isLoadingMoreDocuments {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
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
        uploadHandler(["https://media.licdn.com/dms/image/D4E0BAQE3no_UvLOtkw/company-logo_200_200/0/1692901341712/joyfill_logo?e=2147483647&v=beta&t=AuKT_5TP9s5F0f2uBzMHOtoc7jFGddiNdyqC0BRtETw"])
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
    
    private func fetchDocuments(identifier: String, completion: @escaping (() -> Void)) {
        apiService.fetchDocuments(identifier: identifier, page: 1, limit: 20) { result in
            DispatchQueue.main.async {
                self.fetchSubmissions = false
                self.isloading = false
                switch result {
                case .success(let documents):
                    self.documents = documents
                    completion()
                case .failure(let error):
                    print("Error fetching documents: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchData() {
        fetchDocuments(identifier: identifier){}
    }
    
    private func loadMoreDocuments() {
        guard !isLoadingMoreDocuments, hasMoreDocuments else { return }
        isLoadingMoreDocuments = true
        let nextPage = currentDocumentPage + 1
        
        apiService.fetchDocuments(identifier: identifier, page: nextPage, limit: 20) { result in
            DispatchQueue.main.async {
                isLoadingMoreDocuments = false
                switch result {
                case .success(let newDocuments):
                    if newDocuments.isEmpty {
                        hasMoreDocuments = false
                    } else {
                        documents.append(contentsOf: newDocuments)
                        currentDocumentPage = nextPage
                    }
                case .failure(let error):
                    print("Error loading more templates: \(error.localizedDescription)")
                }
            }
        }
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
