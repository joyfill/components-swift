import SwiftUI
import JoyfillModel

struct ImageState: Identifiable {
    var id = UUID()
    var image: UIImage? = nil
    var isLoaded: Bool = false
    var hasError: Bool = false
}

struct ImageView: View {
    @State var imageURL: String?
    @State private var showMoreImages: Bool = false
    @State private var showProgressView : Bool = false
    @State var hasAppeared: Bool = false
    
    @State var uiImagesArray: [UIImage] = []
    @State var valueElements: [ValueElement] = []
    
    @State private var imageDictionary: [ValueElement: UIImage] = [:]
    @State var showToast: Bool = false
    @State var isMultiEnabled: Bool
    @State var images: [ImageState] = []
    
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    @State var imageDataModel: ImageDataModel!
    let eventHandler: FieldChangeEvents

    @Binding var listModel: FieldListModel

    public init(listModel: Binding<FieldListModel>, eventHandler: FieldChangeEvents) {
        self.eventHandler = eventHandler
        _listModel = listModel
        switch listModel.wrappedValue.model {
        case .image(let dataMode):
            self.isMultiEnabled = dataMode.multi ?? true
            _imageDataModel = State(initialValue: dataMode)
            _valueElements = State(initialValue: dataMode.valueElements ?? [])
        default:
            self.imageDataModel = nil
            self.isMultiEnabled = true
            break
        }
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
                            if uiImage.size == .zero {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.red)
                                    Text("Failed to load image")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            } else {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            }
                        })
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showMoreImages = true
                                eventHandler.onFocus(event: imageDataModel.fieldIdentifier)
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
                    eventHandler.onFocus(event: imageDataModel.fieldIdentifier)
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
                .disabled(imageDataModel.mode == .readonly || showProgressView)
            }
        }
        .onAppear {
            if !hasAppeared {
                self.valueElements = imageDataModel.valueElements ?? []
                fetchImages()
                hasAppeared = true
            }
        }
        .sheet(isPresented: $showMoreImages) {
            MoreImageView(images: $images,
                          valueElements: $valueElements,
                          isMultiEnabled: isMultiEnabled,
                          showToast: $showToast,
                          uploadAction: uploadAction,
                          isUploadHidden: imageDataModel.primaryDisplayOnly ?? (imageDataModel.mode == .readonly))
        }
        .onChange(of: valueElements) { newValue in
            fetchImages()
            let newImageValue = ValueUnion.valueElementArray(newValue)
            let fieldEvent = FieldChangeData(fieldIdentifier: imageDataModel.fieldIdentifier, updateValue: newImageValue)
            eventHandler.onChange(event: fieldEvent)
        }
        .onChange(of: listModel) { newValue in
            switch newValue.model {
            case .image(let dataModel):
                imageDataModel = dataModel
                self.valueElements = dataModel.valueElements ?? []
                fetchImages()
                default : break
            }

        }
    }
    
    func fetchImages() {
        uiImagesArray = []
        if let valueElement = valueElements.first {
            showProgressView = true
            imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                showProgressView = false
                if let image = image {
                    self.uiImagesArray.append(image)
                    self.imageDictionary[valueElement] = image
                } else {
                    // Create an empty UIImage as placeholder
                    let placeholderImage = UIImage()
                    self.uiImagesArray.append(placeholderImage)
                    self.imageDictionary[valueElement] = placeholderImage
                }
            })
        }
    }
    
    func uploadAction() {
        let uploadEvent = UploadEvent(fieldEvent: imageDataModel.fieldIdentifier) { urls in
            for imageURL in urls {
                showProgressView = true
                imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                    showProgressView = false
                    
                    let valueElement = valueElements.first { valueElement in
                        valueElement.url == imageURL
                    } ?? ValueElement(id: JoyfillModel.generateObjectId(), url: imageURL)
                    
                    if isMultiEnabled == false ?? true {
                        images = []
                        valueElements = []
                    }
                    
                    if let image = image {
                        self.imageDictionary[valueElement] = image
                        valueElements.append(valueElement)
                        self.uiImagesArray.append(image)
                    } else {
                        // Create an empty UIImage as placeholder for failed uploads
                        let placeholderImage = UIImage()
                        self.imageDictionary[valueElement] = placeholderImage
                        valueElements.append(valueElement)
                        self.uiImagesArray.append(placeholderImage)
                    }
                })
            }
        }
        eventHandler.onUpload(event: uploadEvent)
    }
}
struct MoreImageView: View {
    @Environment(\.presentationMode) private var presentationMode

    @Binding var images: [ImageState]
    @State var selectedImagesIndex: Set<Int> = Set()
    @Binding var valueElements: [ValueElement]
    @State var isMultiEnabled: Bool
    @State var showProgressView: Bool = false
    @State var imageDictionary: [String: (ValueElement, UIImage)] = [:]
    @Binding var showToast: Bool
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    var uploadAction: () -> Void
    var isUploadHidden: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("More Images")
                    .fontWeight(.bold)
                Spacer()
                if #available(iOS 16, *) {  }
                else {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                    })
                }
            }
            
            if !isUploadHidden {
                UploadDeleteView(imagesArray: $images, selectedImagesIndex: $selectedImagesIndex,isMultiEnabled: $isMultiEnabled,valueElements: $valueElements, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
            }
            if showProgressView {
                ProgressView()
            } else {
                ImageGridView(primaryDisplayOnly: isUploadHidden, images: $images, selectedImagesIndex: $selectedImagesIndex)
            }
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
        .onAppear {
            loadImages(from: valueElements)
        }
        .onDisappear {
            images = []
            imageDictionary.removeAll()
        }
        .onChange(of: valueElements) { newValue in
            loadImages(from: newValue)
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
    }

    private func loadImages(from elements: [ValueElement]) {
        // Initialize images array with placeholders
        images = elements.map { _ in ImageState() }

        // Process each element
        for (index, element) in elements.enumerated() {
            guard let elementId = element.id else { continue }
            
            // Check cache using element ID
            if let cached = imageDictionary[elementId] {
                // Use cached image if URL matches
                if cached.0.url == element.url {
                    if index < images.count {
                        images[index].image = cached.1
                        images[index].isLoaded = true
                        images[index].hasError = (cached.1.size == .zero)
                    }
                    continue
                }
                // URL changed, need to reload
                imageDictionary.removeValue(forKey: elementId)
            }
            
            // Load new or changed image
            imageViewModel.loadSingleURL(imageURL: element.url ?? "") { image in
                DispatchQueue.main.async {
                    // Only update if the element still exists
                    if index < self.valueElements.count && index < self.images.count {
                        self.images[index].image = image
                        self.images[index].isLoaded = true
                        self.images[index].hasError = (image?.size == .zero)
                        if let image = image {
                            self.imageDictionary[elementId] = (element, image)
                        }
                    }
                }
            }
        }
        
        // Clean up cached images that are no longer needed
        let currentElementIds = Set(elements.compactMap { $0.id })
        imageDictionary = imageDictionary.filter { currentElementIds.contains($0.key) }
    }
    
    func deleteSelectedImages() {
        let sortedDescending = selectedImagesIndex.sorted(by: >)
        for index in sortedDescending {
            if index < valueElements.count {
                // Remove from cache using element ID
                if let elementId = valueElements[index].id {
                    imageDictionary.removeValue(forKey: elementId)
                }
                valueElements.remove(at: index)
                if index < images.count {
                    images.remove(at: index)
                }
            }
        }
        selectedImagesIndex.removeAll()
    }
}
struct UploadDeleteView: View {
    @Binding var imagesArray: [ImageState]
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
            for image in images {
                imagesArray.append(ImageState(image: image, isLoaded: true, hasError: image.size == .zero))
            }
        }
    }
}

struct ImageGridView: View {
    var primaryDisplayOnly: Bool
    @Binding var images: [ImageState]
    @Binding var selectedImagesIndex: Set<Int>
    
    var body: some View {
        GeometryReader { geometry in
            let sheetWidth = geometry.size.width
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(Array(images.enumerated()), id: \.element.id) { (index, imageState) in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: sheetWidth / 2 - 32, height: sheetWidth * 0.4)
                            VStack {
                                if imageState.isLoaded {
                                    if let uiImage = imageState.image, uiImage.size != .zero {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        VStack(spacing: 8) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.red)
                                            Text("Failed to load image")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray.opacity(0.8))
                                        }
                                    }
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: sheetWidth / 2 - 32, height: sheetWidth * 0.4)
                            // Selection overlay
                            if !primaryDisplayOnly {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: selectedImagesIndex.contains(index) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedImagesIndex.contains(index) ? .blue : .black)
                                            .padding(.top, 12)
                                            .padding(.trailing, 12)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                        }
                        .onTapGesture {
                            if !primaryDisplayOnly {
                                if selectedImagesIndex.contains(index) {
                                    selectedImagesIndex.remove(index)
                                } else {
                                    selectedImagesIndex.insert(index)
                                }
                            }
                        }
                        .transition(.opacity)
                        .accessibilityIdentifier("DetailPageImageSelectionIdentifier")
                    }
                }
                .padding(8)
            }
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
