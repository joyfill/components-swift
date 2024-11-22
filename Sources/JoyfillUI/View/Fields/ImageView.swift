import SwiftUI
import JoyfillModel

struct ImageView: View {
    @State var imageURL: String?
    @State private var showImagePicker: Bool = false
    @State private var showMoreImages: Bool = false
    @State private var imageLoaded: Bool = false
    @State private var showProgressView : Bool = false
    @State var hasAppeared: Bool = false
    
    @State var uiImagesArray: [UIImage] = []
    @State var valueElements: [ValueElement] = []
    
    @State private var imageDictionary: [ValueElement: UIImage] = [:]
    @State var showToast: Bool = false
    
    @StateObject var imageViewModel = ImageFieldViewModel()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    private let imageDataModel: ImageDataModel
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(imageDataModel: ImageDataModel) {
        self.imageDataModel = imageDataModel
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            FieldHeaderView(imageDataModel.fieldHeaderModel)
            if let uiImage = uiImagesArray.first {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        .frame(height: 250)
                        .overlay(content: {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        })
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showMoreImages = true
                                let fieldEvent = FieldEventInternal(fieldID: imageDataModel.fieldId!)
                                imageDataModel.eventHandler.onFocus(event: fieldEvent)
                            }, label: {
                                HStack(alignment: .center, spacing: 0) {
                                    Text("More > ")
                                    Text("+\(valueElements.count)")
                                        .foregroundColor(.black)
                                }
                                .padding(.all, 5)
                                .background(Color.white)
                                .cornerRadius(10)
                            })
                            .accessibilityIdentifier("ImageMoreIdentifier")
                            .shadow(radius: 4)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.bottom, 20)
                }
            } else {
                Button(action: {
                    uploadAction()
                    let fieldEvent = FieldEventInternal(fieldID: imageDataModel.fieldId!)
                    imageDataModel.eventHandler.onFocus(event: fieldEvent)
                }, label: {
                    ZStack {
                        HStack(spacing: 8) {
                            Text("Upload")
                                .foregroundColor(.gray)
                            
                            Image(systemName: "icloud.and.arrow.up")
                                .foregroundColor(.gray)
                        }
                        .padding(8)
                        if showProgressView {
                            ProgressView()
                        }
                    }
                })
                .accessibilityIdentifier("ImageIdentifier")
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(.gray)
                )
                .disabled(showProgressView)
            }
            
            NavigationLink(destination: 
                            MoreImageView(valueElements: $valueElements,
                                          isMultiEnabled: imageDataModel.multi ?? true,
                                          showToast: $showToast,
                                          uploadAction: uploadAction,
                                          isUploadHidden: imageDataModel.primaryDisplayOnly ?? (imageDataModel.mode == .readonly))
                           , isActive: $showMoreImages) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .hidden()
        }
        .onAppear {
            if !hasAppeared {
                self.valueElements = imageDataModel.valueElements ?? []
                hasAppeared = true
            }
        }
        .onChange(of: valueElements) { newValue in
            fetchImages()
            let newImageValue = ValueUnion.valueElementArray(newValue)
            let fieldEvent = FieldChangeEvent(fieldID: imageDataModel.fieldId!, updateValue: newImageValue)
            imageDataModel.eventHandler.onChange(event: fieldEvent)
        }
    }
    
    func fetchImages() {
        uiImagesArray = []
        if let valueElement = valueElements.first {
            showProgressView = true
            imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                showProgressView = false
                guard let image = image else { return }
                self.uiImagesArray.append(image)
                self.imageDictionary[valueElement] = image
            })
        }
    }

    func uploadAction() {
        let uploadEvent = UploadEventInternal(fieldID: imageDataModel.fieldId!) { urls in
            for imageURL in urls {
                showProgressView = true
                imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                    let valueElement = valueElements.first { valueElement in
                        if valueElement.url == imageURL {
                            return true
                        }
                        return false
                    } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
                    self.imageDictionary[valueElement] = image
                    valueElements.append(valueElement)
                    showProgressView = false
                    guard let image = image else { return }
                    // valueElements upade
                    self.uiImagesArray.append(image)
                })
            }
        }
        imageDataModel.eventHandler.onUpload(event: uploadEvent)
    }
}
struct MoreImageView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State var images: [UIImage] = []
    @State var selectedImagesIndex: Set<Int> = Set()
    @Binding var valueElements: [ValueElement]
    @State var isMultiEnabled: Bool
    @State var showProgressView: Bool = false
    @State var imageDictionary: [ValueElement: UIImage] = [:]
    @Binding var showToast: Bool
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    var uploadAction: () -> Void
    var isUploadHidden: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("More Images")
                .fontWeight(.bold)

            if !isUploadHidden {
                UploadDeleteView(imagesArray: $images, selectedImagesIndex: $selectedImagesIndex,isMultiEnabled: $isMultiEnabled,valueElements: $valueElements, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
            }
            if showProgressView {
                ProgressView()
            }else {
                ImageGridView(primaryDisplayOnly: isUploadHidden, images: $images, selectedImagesIndex: $selectedImagesIndex)
            }
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
        .onAppear{
            self.imageDictionary = [:]
            for valueElement in valueElements {
                imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                    showProgressView = false
                    guard let image = image else { return }
                    self.images.append(image)
                    self.imageDictionary[valueElement] = image
                })
            }
        }
        .onDisappear {
            images = []
        }
        .overlay(content: {
            if showToast {
                VStack {
                       Spacer()
                       ToastMessageView(message: "Image is already uploaded", duration: 2.0, isPresented: $showToast)
                           .padding(.top, 50)
                           .opacity(showToast ? 1.0 : 0.0)
                   }
            }
        })
        .onChange(of: valueElements) { newValue in
            self.imageDictionary = [:]
            self.images = []
            for valueElement in valueElements {
                imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                    showProgressView = false
                    guard let image = image else { return }
                    self.images.append(image)
                    self.imageDictionary[valueElement] = image
                })
            }
        }
    }
    
    func loadImageFromURL(imageURLs: [String]) {
        imageViewModel.loadImageFromURL(imageURLs: imageURLs) { loadedImages in
            self.images = loadedImages
            showProgressView = false
        }
    }
    func loadSingleImageFromUrl(imageUrl: String) {
        imageViewModel.loadSingleURL(imageURL: imageUrl, completion: { image in
            guard let image = image else { return }
            for valueElement in valueElements {
                if imageUrl == valueElement.url {
                    self.imageDictionary[valueElement] = image
                }
            }
            self.images.append(image)
        })
    }

    func deleteSelectedImages() {
        for index in selectedImagesIndex {
            valueElements.remove(at: index)
            images.remove(at: index)
        }
        selectedImagesIndex.removeAll()
    }
}
struct UploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    @Binding var selectedImagesIndex: Set<Int>
    @StateObject var imageViewModel = ImageFieldViewModel()
    @Binding var isMultiEnabled: Bool
    @Binding var valueElements: [ValueElement]
    var uploadAction: () -> Void
    var deleteAction: () -> Void
    
    var body: some View {
        HStack {
            uploadButton
            
            if selectedImagesIndex.count > 0 {
                deleteButton
            }
            Spacer()
        }
    }
    
    var uploadButton: some View {
        Button(action: {
            if isMultiEnabled == false ?? true {
                imagesArray = []
                valueElements = []
            }
            uploadAction()
        }, label: {
            HStack(spacing: 8) {
                Text("Upload")
                    .foregroundColor(.gray)
                
                Image(systemName: "icloud.and.arrow.up")
                    .foregroundColor(.gray)
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(.gray)
            )
        })
        .accessibilityIdentifier("ImageUploadImageIdentifier")
    }
    
    var deleteButton: some View {
        Button(action: {
            deleteAction()
        }, label: {
            HStack(spacing: 8) {
                Text("Delete")
                    .foregroundColor(.red)
                
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 1)
                    .foregroundColor(.red)
            )
        })
        .accessibilityIdentifier("ImageDeleteIdentifier")
    }
    
    func loadImagesFromURLs(imageURLs: [String]) {
        imageViewModel.loadImageFromURL(imageURLs: imageURLs) { images in
            imagesArray.append(contentsOf: images)
        }
    }
}

struct ImageGridView:View {
    var primaryDisplayOnly: Bool
    @Binding var images: [UIImage]
    @Binding var selectedImagesIndex: Set<Int>
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(Array(images.enumerated()), id: \.offset) { (index, image) in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth / 2 - 32, height: screenHeight * 0.2)
                        .overlay(content: {
                            if !primaryDisplayOnly {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                    .background(
                                        Image(systemName: selectedImagesIndex.contains(index) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedImagesIndex.contains(index) ? .blue : .white)
                                            .offset(
                                                x: 60,
                                                y: -60
                                            )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                            }
                        })
                        .onTapGesture {
                            handleImageSelection(image)
                        }
                        .accessibilityIdentifier("DetailPageImageSelectionIdentifier")
                }
            }
        }
    }
    
    private func handleImageSelection(_ image: UIImage) {
        guard !primaryDisplayOnly else { return }
        let index = images.firstIndex(of: image)!
        if selectedImagesIndex.contains(index) {
            selectedImagesIndex.remove(index)
        } else {
            selectedImagesIndex.insert(index)
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?
    var isCamera: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        imagePicker.sourceType = isCamera ? .camera : .photoLibrary
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] {
                parent.selectedImage = image as? UIImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ToastMessageView: View {
    let message: String
    let duration: TimeInterval
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(message)
                .padding()
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .transition(.move(edge: .top))
        .animation(.easeInOut)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                isPresented = false
            }
        }
    }
}

struct ImageDataModel {
    var fieldId: String?
    var multi: Bool?
    var primaryDisplayOnly: Bool?
    var valueElements: [ValueElement]?
    var mode: Mode
    var eventHandler: FieldChangeEvents
    var fieldHeaderModel: FieldHeaderModel?
}
