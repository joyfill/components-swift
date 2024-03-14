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
    @State var uiImagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    @State private var imageDictionary: [String: UIImage] = [:]
    @State private var hasAppeared = false
    @State var showToast: Bool = false
    
    @StateObject var imageViewModel = ImageFieldViewModel()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    private let fieldDependency: FieldDependency
    @FocusState private var isFocused: Bool // Declare a FocusState property
    
    public init(fieldDependency: FieldDependency) {
        self.fieldDependency = fieldDependency
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title = fieldDependency.fieldData?.title {
                HStack(spacing: 30) {
                    Text("\(title)")
                        .font(.headline.bold())
                    
                    if fieldDependency.fieldData?.fieldRequired == true && imageURLs.isEmpty {
                        Image(systemName: "asterisk")
                            .foregroundColor(.red)
                            .imageScale(.small)
                    }
                }
            }
            
            if !uiImagesArray.isEmpty {
                ZStack {
                    Image(uiImage: uiImagesArray[0])
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
                            Text("+\(uiImagesArray.count)")
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
                        Image("ImageUploadRectSmall")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                        Image("Upload_Icon")
                            .resizable()
                            .frame(width: 69,height: 18)
                        if showProgressView {
                            ProgressView()
                        }
                    }
                })
                .disabled(showProgressView)
            }
            
            NavigationLink(destination: MoreImageView(imageUrlArray: $imageURLs, isMultiEnabled: fieldDependency.fieldData?.multi ?? true, imageDictionary: $imageDictionary, showToast: $showToast, uploadAction: uploadAction, isUploadHidden: fieldDependency.fieldPosition.primaryDisplayOnly ?? false), isActive: $showMoreImages) {
                EmptyView()
            }
        }
        .onAppear {
            //for first time
            if !hasAppeared {
                if let imageURLs = fieldDependency.fieldData?.value?.imageURLs {
                    for imageURL in imageURLs {
                        self.imageURLs.append(imageURL)
                        showProgressView = true
                        
                        imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                            self.uiImagesArray.append(image)
                            self.imageDictionary[imageURL] = image
                            print("imageDictionary \(imageDictionary)")
                            showProgressView = false
                        })
                    }
                }
                hasAppeared = true
            } else {
                // for rest of time appear
                self.uiImagesArray = []
                if imageURLs.count > 0 {
                    for imageURL in imageURLs {
                        showProgressView = true
                        imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                            self.uiImagesArray.append(image)
                            showProgressView = false
                            print("imageDictionary \(imageDictionary)")
                        })
                    }
                } else {
                    showProgressView = false
                }
            }
        }
        .onChange(of: imageURLs) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .array(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: FieldChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }

    func uploadAction() {
        let uploadEvent = UploadEvent(field: fieldDependency.fieldData!) { urls in
            for imageURL in urls {
                showProgressView = true
                imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                    self.imageDictionary[imageURL] = image
                    self.uiImagesArray.append(image)
                    showProgressView = false
                    print("imageDictionary \(imageDictionary)")
                })
            }
            for url in urls{
                if imageURLs.contains(url) {
                    showToast = true
                } else {
                    imageURLs.append(url)
                }
               
            }
        }
        fieldDependency.eventHandler.onUpload(event: uploadEvent)
    }
}
struct MoreImageView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @State var images: [UIImage] = []
    @State var selectedImages: Set<UIImage> = Set()
    @Binding var imageUrlArray: [String]
    @State var isMultiEnabled: Bool
    @State var showProgressView: Bool = true
    @Binding var imageDictionary: [String: UIImage]
    @Binding var showToast: Bool
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    var uploadAction: () -> Void
    var isUploadHidden: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("More Images")
                .fontWeight(.bold)
            
            if isUploadHidden {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,isMultiEnabled: $isMultiEnabled,imageURLArray: $imageUrlArray, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
                    .hidden()
            } else {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,isMultiEnabled: $isMultiEnabled,imageURLArray: $imageUrlArray, uploadAction: uploadAction, deleteAction: deleteSelectedImages)
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
            for imageURL in imageUrlArray {
                imageViewModel.loadSingleURL(imageURL: imageURL, completion: { image in
                    self.images.append(image)
                    self.imageDictionary[imageURL] = image
                    print("imageDictionary \(imageDictionary)")
                    showProgressView = false
                })
            }
        }
        .onChange(of: imageUrlArray) { oldValue, newValue in
            let addedImages = newValue.difference(from: oldValue).inferringMoves()
            
            for change in addedImages {
                if case .insert(_, let element, _) = change {
                    loadSingleImageFromUrl(imageUrl: element)
                }
            }
        }
        .onDisappear{
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
    }
    
    func loadImageFromURL(imageURLs: [String]) {
        imageViewModel.loadImageFromURL(imageURLs: imageURLs) { loadedImages in
            self.images = loadedImages
            showProgressView = false
        }
    }
    func loadSingleImageFromUrl(imageUrl: String) {
        imageViewModel.loadSingleURL(imageURL: imageUrl, completion: { image in
            self.imageDictionary[imageUrl] = image
            self.images.append(image)
        })
    }
    func deleteSelectedImages() {
        // Logic to delete selected Images from imageUrls
        for image in selectedImages {
            print("image\(image)")
            let urlToDelete = imageDictionary.first { $0.value == image }?.key
            imageUrlArray.removeAll { $0 == urlToDelete }
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
    @Binding var imageURLArray: [String]
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
                imageURLArray = []
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
                                        Image(selectedImages.contains(image) ? "Selected_Icon" : "UnSelected_Icon")
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
