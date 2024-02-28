//
//  ImageView.swift
//  JoyFill
//
//  Created by Babblu Bhaiya on 10/02/24.
//

import SwiftUI
import JoyfillModel
import JoyfillAPIService

// Logo or Graphic

struct ImageView: View {
    @State var imageURL: String?
    @State var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var showMoreImages: Bool = false
    @State private var imageLoaded: Bool = false
    @State private var showProgressView : Bool = false
    @State var imagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Image")
                .fontWeight(.bold)
            
            if !imagesArray.isEmpty {
                    ZStack {
                        Image(uiImage: imagesArray[0])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                        Button(action: {
                            showMoreImages = true
                        }, label: {
                            HStack {
                                Text("More > ")
                                
                                Text("+\(imagesArray.count)")
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                        })
                        .padding(.top, 200)
                        .padding(.leading, 250)
                        .sheet(isPresented: $showMoreImages, content: {
                            MoreImageView(isUploadHidden: fieldPosition.primaryDisplayOnly ?? false, imagesArray: $imagesArray,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        })
                    }
                } else {
                    Button(action: {
                        let uploadEvent = UploadEvent(field: fieldData!) { urls in
                            loadImageFromURL(imageURLs: urls)
                            showProgressView = true
                        }
                        eventHandler.onUpload(event: uploadEvent)
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
                }
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let imageURLs = fieldData?.value?.imageURLs {
                for imageURL in imageURLs {
                    self.imageURLs.append(imageURL)
                }
            }
            if !imageLoaded {
                loadImageFromURL(imageURLs: self.imageURLs)
            }
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
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    
    public init(isUploadHidden: Bool,imagesArray: Binding<[UIImage]>,eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
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
            ImageGridView(images: $images, selectedImages: $selectedImages)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
    }
}
struct UploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    @Binding var selectedImages: Set<UIImage>
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    public init(imagesArray: Binding<[UIImage]>,
                selectedImages: Binding<Set<UIImage>>,
                eventHandler: FieldEventHandler,
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
            Button(action: {
                let uploadEvent = UploadEvent(field: fieldData!) { urls in
                    loadImagesFromURLs(imageURLs: urls)
                }
                eventHandler.onUpload(event: uploadEvent)
            }, label: {
                    Image("UploadButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
            })
            
            Button(action: {
                deleteSelectedImages()
            }, label: {
                Image(selectedImages.count > 0 ? "DeleteButton" : "")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
            })
            Spacer()
        }
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
//                        .scaledToFill()
                        .scaledToFit()
                        .frame(width: screenWidth / 2 - 32, height: screenHeight * 0.2)
//                        .clipped()
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 10)
                                               .stroke(Color.gray, lineWidth: 1)
                                               .background(
                            Image(selectedImages.contains(image) ? "Selected_Icon" : "UnSelected_Icon")
                                .offset(
                                    x: 60,
                                    y: -60
                                )
                            )
                        })
                        .onTapGesture {
                            if selectedImages.contains(image) {
                                selectedImages.remove(image)
                            } else {
                                selectedImages.insert(image)
                            }
                        }
                }
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
//        imagePicker.cameraCaptureMode = .photo
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
