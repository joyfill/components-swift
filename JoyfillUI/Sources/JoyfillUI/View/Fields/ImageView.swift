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
    @State var imagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    
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
                Text("\(title)")
                    .fontWeight(.bold)
            }
            
            if !imagesArray.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                        .background(
                            Image(uiImage: imagesArray[0])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        )
                    
                    Button(action: {
                        showMoreImages = true
                        let fieldEvent = FieldEvent(field: fieldDependency.fieldData)
                        fieldDependency.eventHandler.onFocus(event: fieldEvent)
                    }, label: {
                        HStack {
                            Text("More > ")
                            
                            Text("+\(imagesArray.count)")
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 5)
                        .background(Color.white)
                        .cornerRadius(10)
                    })
                    .padding(.top, screenHeight * 0.2)
                    .padding(.bottom, 10)
                    .padding(.leading, screenWidth * 0.65)
                    .shadow(radius: 4)
                }
            } else {
                Button(action: {
                    let uploadEvent = UploadEvent(field: fieldDependency.fieldData!) { urls in
                        loadImageFromURL(imageURLs: urls)
                        showProgressView = true
                    }
                    fieldDependency.eventHandler.onUpload(event: uploadEvent)
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
        }
        .sheet(isPresented: $showMoreImages, content: {
            MoreImageView(isUploadHidden: fieldDependency.fieldPosition.primaryDisplayOnly ?? false, imagesArray: $imagesArray,eventHandler: fieldDependency.eventHandler, fieldPosition: fieldDependency.fieldPosition, fieldData: fieldDependency.fieldData)
        })
        .padding(.horizontal, 16)
        .onAppear {
            if let imageURLs = fieldDependency.fieldData?.value?.imageURLs {
                for imageURL in imageURLs {
                    self.imageURLs.append(imageURL)
                    showProgressView = true
                }
            }
            if !imageLoaded {
                loadImageFromURL(imageURLs: self.imageURLs)
            }
        }
        .onChange(of: imageURLs) { oldValue, newValue in
            guard var fieldData = fieldDependency.fieldData else { return }
            fieldData.value = .array(newValue)
            let change = FieldChange(changeData: ["value" : newValue])
            fieldDependency.eventHandler.onChange(event: ChangeEvent(fieldPosition: fieldDependency.fieldPosition, field: fieldData, changes: change))
        }
    }
    func loadImageFromURL(imageURLs: [String]) {
        imageViewModel.loadImageFromURL(imageURLs: imageURLs) { loadedImages in
            self.imagesArray = loadedImages
            showProgressView = false
            imageLoaded = true
        }
    }
}
struct MoreImageView: View {
    var isUploadHidden: Bool
    @Binding var images: [UIImage]
    @State var selectedImages: Set<UIImage> = Set()
    
    @Environment(\.presentationMode) private var presentationMode
    
    private let mode: Mode = .fill
    private let eventHandler: FieldChangeEvents
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(isUploadHidden: Bool,imagesArray: Binding<[UIImage]>,eventHandler: FieldChangeEvents, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.isUploadHidden = isUploadHidden
        _images = imagesArray
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("More Images")
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                })
            }
            if isUploadHidden {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                    .hidden()
            } else {
                UploadDeleteView(imagesArray: $images, selectedImages: $selectedImages,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
            }
            ImageGridView(primaryDisplayOnly: fieldPosition.primaryDisplayOnly ?? false, images: $images, selectedImages: $selectedImages)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
    }
}
struct UploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    @Binding var selectedImages: Set<UIImage>
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    private let mode: Mode = .fill
    private let eventHandler: FieldChangeEvents
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(imagesArray: Binding<[UIImage]>,
                selectedImages: Binding<Set<UIImage>>,
                eventHandler: FieldChangeEvents,
                fieldPosition: FieldPosition,
                fieldData: JoyDocField? = nil) {
        _imagesArray = imagesArray
        _selectedImages = selectedImages
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    
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
            if fieldData?.multi == false ?? true {
                imagesArray = []
            }
            let uploadEvent = UploadEvent(field: fieldData!) { urls in
                loadImagesFromURLs(imageURLs: urls)
            }
            eventHandler.onUpload(event: uploadEvent)
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
            deleteSelectedImages()
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
    
    func deleteSelectedImages() {
        imagesArray = imagesArray.filter { !selectedImages.contains($0) }
        selectedImages.removeAll()
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
                                    .stroke(Color.gray, lineWidth: 1)
                                    .background(
                                        Image(selectedImages.contains(image) ? "Selected_Icon" : "UnSelected_Icon")
                                            .offset(
                                                x: 60,
                                                y: -60
                                            )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
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
