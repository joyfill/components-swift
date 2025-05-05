//
//  DocumentSubmissionsListView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService
import Joyfill
import UIKit
import ObjectiveC
import PhotosUI

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
    @State private var currentUploadHandler: (([String]) -> Void)?
    let imagePicker = ImagePicker()

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
        ChangeManager(apiService: apiService, showImagePicker: imagePicker.showPickerOptions, showScan: showScan)
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

class ImagePicker {
    func showPickerOptions(currentUploadHandler: (([String]) -> Void)?) {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                self.presentImagePicker(sourceType: .camera, currentUploadHandler: currentUploadHandler)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.presentPhotoPicker(currentUploadHandler: currentUploadHandler)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Add iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = UIApplication.shared.windows.first
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    private func presentPhotoPicker(currentUploadHandler: (([String]) -> Void)?) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 means no limit
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        let coordinator = PhotoPickerCoordinator(uploadHandler: { urls in
            currentUploadHandler?(urls)
        })
        picker.delegate = coordinator
        
        // Store coordinator as associated object to prevent it from being deallocated
        objc_setAssociatedObject(picker, "coordinator", coordinator, .OBJC_ASSOCIATION_RETAIN)
        
        UIApplication.shared.windows.first?.rootViewController?.present(picker, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, currentUploadHandler: (([String]) -> Void)?) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true

        let coordinator = ImagePickerCoordinator(uploadHandler: { urls in
            currentUploadHandler?(urls)
        })
        imagePickerController.delegate = coordinator

        // Store coordinator as associated object to prevent it from being deallocated
        objc_setAssociatedObject(imagePickerController, "coordinator", coordinator, .OBJC_ASSOCIATION_RETAIN)

        UIApplication.shared.windows.first?.rootViewController?.present(imagePickerController, animated: true)
    }
    
    class PhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
        let uploadHandler: ([String]) -> Void
        
        init(uploadHandler: @escaping ([String]) -> Void) {
            self.uploadHandler = uploadHandler
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let dispatchGroup = DispatchGroup()
            var imageUrls: [String] = []
            
            for result in results {
                dispatchGroup.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let image = object as? UIImage,
                          let imageUrl = self?.saveImageToTemporaryDirectory(image) else {
                        return
                    }
                    
                    imageUrls.append(imageUrl.absoluteString)
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.uploadHandler(imageUrls)
            }
        }
        
        private func saveImageToTemporaryDirectory(_ image: UIImage) -> URL? {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try imageData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let uploadHandler: ([String]) -> Void

        init(uploadHandler: @escaping ([String]) -> Void) {
            self.uploadHandler = uploadHandler
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)

            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                // Save image to temporary directory and get URL
                if let imageUrl = saveImageToTemporaryDirectory(image) {
                    uploadHandler([imageUrl.absoluteString])
                }
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        private func saveImageToTemporaryDirectory(_ image: UIImage) -> URL? {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }

            let fileName = UUID().uuidString + ".jpg"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                try imageData.write(to: fileURL)
                return fileURL
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
    }
}
