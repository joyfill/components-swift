//
//  ImageView.swift
//  JoyFill
//
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

// Logo or Graphic

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
    
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
//        _valueElements = State(initialValue: fieldDependency.fieldData?.value?.images ?? [])
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(alignment: .top) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && valueElements.isEmpty {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            if let uiImage = uiImagesArray.first {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                .frame(width: screenWidth * 0.9, height: 250)
                        )
                    
                    //                    RoundedRectangle(cornerRadius: 20)
                    //                        .stroke(Color.gray, lineWidth: 1)
                    //                        .background(
                    //                            Image(uiImage: imagesArray[0])
                    //                                .resizable()
                    //                                .aspectRatio(contentMode: .fit)
                    //                        )
                    
                    Button(action: {
                        showMoreImages = true
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
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
                    .padding(.top, screenHeight * 0.22)
                    .padding(.bottom, 8)
                    .padding(.leading, screenWidth * 0.6)
                    .shadow(radius: 4)
                }
                .frame(width: screenWidth * 0.9, height: 250)
            } else {
                Button(action: {
                    uploadAction()
                    let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                    fieldDependency.eventHandler.onFocus(event: fieldEvent)
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
                            MoreImageView(valueElements: $valueElements, isMultiEnabled: fieldDependency.fieldData?.multi ?? true, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: fieldDependency.fieldPosition.primaryDisplayOnly ?? false)
                           
                           , isActive: $showMoreImages) {
                EmptyView()
            }
        }
        .onAppear {
            if !hasAppeared {
                self.valueElements = fieldDependency.fieldData?.value?.images ?? []
                hasAppeared = true
            }
        }
        .onChange(of: valueElements) { newValue in
            fetchImages()
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .valueElementArray(newValue)
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData))
        }
    }
    
    func fetchImages() {
        uiImagesArray = []
        if let valueElement = valueElements.first {
            showProgressView = true
            imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                showProgressView = false
                self.uiImagesArray.append(image)
                self.imageDictionary[valueElement] = image
                print("imageDictionary \(imageDictionary)")
                showProgressView = false
            })
        }
    }

    func uploadAction() {
        let uploadEvent = UploadEvent(field: fieldDependency.fieldData!) { urls in
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
                    // valueElements upade
                    self.uiImagesArray.append(image)
                    showProgressView = false
                    print("imageDictionary \(urls)")
                })
            }
        }
        fieldDependency.eventHandler.onUpload(event: uploadEvent)
    }
}
struct MoreImageView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State var images: [UIImage] = []
    @State var selectedImages: Set<UIImage> = Set()
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

            if isUploadHidden {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,isMultiEnabled: $isMultiEnabled,valueElements: $valueElements, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
                    .hidden()
            } else {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,isMultiEnabled: $isMultiEnabled,valueElements: $valueElements, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
            }
            if showProgressView {
                ProgressView()
            }else {
                ImageGridView(primaryDisplayOnly: isUploadHidden, images: $images, selectedImages: $selectedImages)
            }
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
        .onAppear{
            self.imageDictionary = [:]
            for valueElement in valueElements {
                imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                    self.images.append(image)
                    self.imageDictionary[valueElement] = image
                    print("imageDictionary \(imageDictionary)")
                    showProgressView = false
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
            print(newValue.count)
            self.imageDictionary = [:]
            self.images = []
            for valueElement in valueElements {
                imageViewModel.loadSingleURL(imageURL: valueElement.url ?? "", completion: { image in
                    self.images.append(image)
                    self.imageDictionary[valueElement] = image
                    print("imageDictionary \(imageDictionary)")
                    showProgressView = false
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
            for valueElement in valueElements {
                if imageUrl == valueElement.url {
                    self.imageDictionary[valueElement] = image
                }
            }
            self.images.append(image)
        })
    }
    func deleteSelectedImages() {
        // Logic to delete selected Images from imageUrls
        for image in selectedImages {
            print("image\(image)")
            let urlToDelete = imageDictionary.first { $0.value == image }?.key
            valueElements.removeAll { $0 == urlToDelete }
        }
        images = images.filter { !selectedImages.contains($0) }
        selectedImages.removeAll()
    }

}
struct UploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    @Binding var selectedImages: Set<UIImage>
    @StateObject var imageViewModel = ImageFieldViewModel()
    @Binding var isMultiEnabled: Bool
    @Binding var valueElements: [ValueElement]
    var uploadAction: () -> Void
    var deleteAction: () -> Void
    
    var body: some View {
        HStack {
            uploadButton
            
            if selectedImages.count > 0 {
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
    @Binding var selectedImages: Set<UIImage>
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth / 2 - 32, height: screenHeight * 0.2)
                        .overlay(content: {
                            if !primaryDisplayOnly {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.allFieldBorderColor, lineWidth: 1)
                                    .background(
                                        Image(systemName: selectedImages.contains(image) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(selectedImages.contains(image) ? .blue : .white)
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
                }
            }
        }
    }
    
    private func handleImageSelection(_ image: UIImage) {
        guard !primaryDisplayOnly else { return }
        
        if selectedImages.contains(image) {
            selectedImages.remove(image)
        } else {
            selectedImages.insert(image)
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
