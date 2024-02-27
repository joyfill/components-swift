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
    @State private var imageCount: Int = 4
    @State var imagesArray: [UIImage] = []
    @State var imageURLs: [String] = []
    @StateObject var imageViewModel = ImageFieldViewModel()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
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
            
                if let profileImage = profileImage {
                    ZStack {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                        Button(action: {
                            showMoreImages = true
                        }, label: {
                            HStack {
                                Text("More > ")
                                
                                Text("+\(imageCount)")
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.white)
                            .cornerRadius(10)
                        })
                        .padding(.top, screenHeight * 0.2)
                        .padding(.leading, screenWidth * 0.6)
                        .sheet(isPresented: $showMoreImages, content: {
                            MoreImageView(isUploadHidden: fieldPosition.primaryDisplayOnly ?? false, imagesArray: $imagesArray,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                        })
                    }
                } else {
                    Button(action: {
                        let uploadEvent = UploadEvent(field: fieldData!) { url in
                            imageURLs.append(url)
                            showProgressView = true
                            loadSingleImageFromURL(imageURL: url)
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
                imageCount = imageURLs.count
                for imageURL in imageURLs {
                    self.imageURLs.append(imageURL)
                }
            }
            if !imageLoaded {
                loadImageFromURL()
            }
        }
    }
    func loadImageFromURL() {
        imageViewModel.loadImageFromURL(imageURLs: self.imageURLs) { loadedImages in
            self.imagesArray = loadedImages
            showProgressView = false
            if loadedImages.count > 0 {
                profileImage = loadedImages[0]
            }
            imageLoaded = true
        }
    }

    func loadSingleImageFromURL(imageURL: String) {
        imageViewModel.loadSingleURL(imageURL: imageURL) { image in
            if let image = image {
                showProgressView = false
                profileImage = image
                imagesArray.append(image)
                imageLoaded = true
            }
        }
    }
    
}
struct MoreImageView: View {
    var isUploadHidden: Bool
    @Binding var images: [UIImage]
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
                UploadDeleteView(imagesArray: $images,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
                    .hidden()
            } else {
                UploadDeleteView(imagesArray: $images,eventHandler: eventHandler, fieldPosition: fieldPosition, fieldData: fieldData)
            }
            ImageGridView(images: $images)
            Spacer()
        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16)
    }
}
struct UploadDeleteView: View {
    @Binding var imagesArray: [UIImage]
    
    private let mode: Mode = .fill
    private let eventHandler: FieldEventHandler
    private let fieldPosition: FieldPosition
    private var fieldData: JoyDocField?
    @StateObject var imageViewModel = ImageFieldViewModel()
    
    public init(imagesArray: Binding<[UIImage]>,eventHandler: FieldEventHandler, fieldPosition: FieldPosition, fieldData: JoyDocField? = nil) {
        _imagesArray = imagesArray
        self.eventHandler = eventHandler
        self.fieldPosition = fieldPosition
        self.fieldData = fieldData
    }
    var body: some View {
        HStack {
            Button(action: {
                let uploadEvent = UploadEvent(field: fieldData!) { url in
                    loadSingleImageFromURL(imageURL: url)
                }
                eventHandler.onUpload(event: uploadEvent)
            }, label: {
                    Image("UploadButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 28)
            })
            
            Button(action: {
                imagesArray.remove(at: imagesArray.count - 1)
            }, label: {
                Image("DeleteButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 28)
            })
            Spacer()
        }
    }
    func loadSingleImageFromURL(imageURL: String) {
        imageViewModel.loadSingleURL(imageURL: imageURL) { image in
            if let image = image {
                imagesArray.append(image)
            }
        }
    }
}

struct ImageGridView:View {
    @Binding var images: [UIImage]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
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
